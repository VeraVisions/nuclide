/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

void EFX_UpdateListener(ncView);

void
init(float prevprogs)
{
	_client_main();
	_shared_main();
}

string CSQC_GenerateMaterial(string shadername)
{
	Materials_OnLoad(shadername);
	return (__NULL__);
// 	return (shadername);
// 	ncError("%S", shadername);
}

/** Updates our seat pointers.
Call this when you need to verify we're
getting the current player's info and not someone elses on the same
machine (splitscreen).
*/
void
CSQC_UpdateSeat(void)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	pSeatLocal = &g_seatslocal[s];
	g_view = g_viewSeats[s];
}

/** Entry function that is required by the engine.
Called once when the csprogs.dat file is loaded upon loading our client.
Also called when map changes happen.
*/
void
CSQC_Init(float apilevel, string enginename, float engineversion)
{
	InitPrint("Initializing Client Game");
	ncLog("Built: %s %s", __DATE__, __TIME__);
	ncLog("QCC: %s", __QCCVER__);

	for (int i = 0i; i < 4i; i++) {
		g_viewSeats[i] = spawn(ncView);
		g_viewSeats[i].SetSeatID(i);
	}

	pSeat = &g_seats[0];
	pSeatLocal = &g_seatslocal[0];
	g_view = g_viewSeats[0];

	g_numplayerslots = (int)serverkeyfloat("sv_playerslots");

	Cmd_Init();

	Constants_Init();
	SoundDef_Init();
	SurfData_Init();
	PropData_Init();
	DecalGroups_Init();

	/* VGUI */
	Locale_Init();
	VGUI_Init();

	/* Game specific inits */
	ClientGame_Init(apilevel, enginename, engineversion);
	Titles_Init();
	Sentences_Init();
	Decals_Init();
	Way_Init();
	Materials_Init();
	MOTD_Init();
	Commandmenu_Init();
	Activities_Init();

	/* let the menu know we're a multi or a singleplayer game */
	if (serverinfo.GetInteger("sv_playerslots") == 1i) {
		ncLog("Running a singleplayer game.");
		cvars.SetBool("_menu_singleplayer", true);
	} else {
		ncLog("Running a multiplayer game.");
		cvars.SetBool("_menu_singleplayer", false);
	}

	g_cheats = (serverkey("*cheats") == "ON") ? true : false;

	EntityDef_Init();
	Ammo_Init();
	WorldSpawn_Init();

	g_overview = ncRadar::InitForCurrentMap();

	HUD_Init();

	/* end msg */
	ncLog("Client game initialized.");

	/* because the engine will do really bad hacks to our models otherwise. e.g. R6284 */
	cvar_set("r_fullbrightSkins", "0");

	/* ENGINE, PLS FIX */
	input_cursor_entitynumber = 0;

	/* soundDef caches */
	for (int i = -4096; i < 4096; i++) {
		string tmp = modelnameforindex(i);

		if (substring(tmp, 0, 3) == "*S:") {
			SoundDef_Precache(substring(tmp, 3, -1));
		}
	}
}

/** Called by the engine whenever video resources need to be reloaded.
This is only called when something like 'vid_reload' happens.
We also call it once upon init. The idea is that any resources that are
meant to be loaded into video-memory need to be precached within this
function. This will ensure no missing resources later.

Sub-games need to implement their own `ClientGame_RendererRestart` function
somewhere in csprogs.dat to ensure their resources are reloaded properly.
*/
void
CSQC_RendererRestarted(string rstr)
{
	InitStart();

	/* Fonts */
	Font_Load("fonts/font16.font", FONT_16);
	Font_Load("fonts/font20.font", FONT_20);
	Font_Load("fonts/console.font", FONT_CON);
	Font_Load("fonts/centerprint.font", FONT_CENTERPRINT);

	/* Particles */
	PART_DUSTMOTE = particleeffectnum("volume.dustmote");
	PART_BURNING = particleeffectnum("burn.burning");

	/* 2D Pics */
	precache_pic("gfx/vgui/icntlk_sv");
	precache_pic("gfx/vgui/icntlk_pl");

	/* View */
	Chat_Reload();
	Scores_Init();
	View_Init();
	ClientGame_RendererRestart(rstr);
	HUD_ReloadVideoResources();
	Locale_Reload();

	/* GS-Entbase */
	Fade_Reload();
	Decal_Reload();
	Sky_Update(TRUE);
	Entities_ReloadVideoResources();
	DetailTex_Reload();

	g_shellchromeshader = shaderforname("shellchrome", sprintf("{\ndeformVertexes bulge 1.25 1.25 0\n{\nmap %s\ntcMod scroll -0.1 0.1\ntcGen environment\nblendFunc add\nrgbGen entity\n}\n}", "textures/sfx/reflection.tga"));
	g_shellchromeshader_cull = shaderforname("shellchrome2", sprintf("{\ncull back\ndeformVertexes bulge 1.5 1.5 0\n{\nmap %s\ntcMod scroll -0.1 0.1\ntcGen environment\nrgbGen entity\n}\n}", "textures/sfx/reflection.tga"));

	InitEnd();
}

/** Always call this instead of renderscene(); !
We want you to avoid calling renderscene() directly because it misrepresents
how much time is spent rendering otherwise. The profile will group engine calls
to a single function. So call this tiny wrapper function instead so you have
a clear overview about how much time is spent in the renderer when using `profile_csqc`
when debugging in the game's console.
*/
void
CSQC_RenderScene(void)
{
	renderscene();
}

/** Called on top of every 3D rendered view. This just again ensures we box
and seperate 2D plane operations from 3D ones. This is where the HUD, Chat etc.
will be drawn. They don't necessarily have to be 2D but this is just a clear
distinction from 3D world elements and overlays.
*/
void
CSQC_Update2D(float w, float h, bool focus)
{
	ncPlayer cl = (ncPlayer)pSeat->m_ePlayer;
	self = cl;

	if (Util_GetMaxPlayers() > 1 && !VGUI_Active() && (Client_InIntermission() || (!cl.IsFakeSpectator() && cl.IsDead()))) {
		HUD_Draw();
		Textmenu_Draw();
		Scores_Draw();
		Chat_Draw();
		Print_Draw();
	} else if (Util_IsFocused() == true) {
		GameText_Draw();
		PointMessage_Draw();

		/* bleurgh */
		if (cl.activeweapon == 0 || wasfreed(cl.m_activeWeapon) || cl.m_activeWeapon._isWeapon == false) {
			cl.m_activeWeapon = 0;
		}

		if (Client_IsSpectator(cl) == false) {
			if (cl.m_activeWeapon)
				cl.m_activeWeapon.UpdateGUI();
			HUD_Draw();
		} else {
			HUD_DrawSpectator();
		}

		Textmenu_Draw();
		Voice_DrawHUD();
		Chat_Draw();
		Print_Draw();

		/* no prints overlapping scoreboards */
		if (pSeat->m_iScoresVisible == TRUE) {
			Scores_Draw();
		} else {
			VGUI_Draw();
			Print_DrawCenterprint();
		}
	}
}


/** Called every single frame by the engine's renderer to construct a frame.
This is for all clients on display. So we handle splitscreen/multiple-views
in here.
*/
void
CSQC_UpdateView(float w, float h, float focus)
{
	ncPlayer cl = __NULL__;
	int s;
	vector vecViewAngles = view_angles;

	g_focus = (bool)focus;

	if (w == 0 || h == 0) {
		return;
	} else {
		/* First time we can effectively call VGUI
		*  because until now we don't know the video res.
		*/
		if (!g_vidsize[0] && !g_vidsize[1]) {
			g_vidsize[0] = w;
			g_vidsize[1] = h;
			ClientGame_InitDone();
			Sky_Update(true);
		}
	}

	/* While the init above may have already happened,
	   people are able to resize windows dynamically too. */
	if (w != g_vidsize[0] || h != g_vidsize[1]) {
		g_vidsize[0] = w;
		g_vidsize[1] = h;
		VGUI_Reposition();
	}

	/* these have to be checked every frame */
	Fog_Update();
	Sky_Update(false);
	cvar_set("_background", serverkey("background"));

	/* ensure background maps do not get paused */
	if (serverkeyfloat("background") == 1)
		setpause(FALSE);


	/* bounds sanity check */
	if (numclientseats > g_seats.length) {
		numclientseats = g_seats.length;
	}

	/* null our globals */
	for (s = g_seats.length; s-- > numclientseats;) {
		pSeat = &g_seats[s];
		pSeatLocal = &g_seatslocal[s];
		g_view = g_viewSeats[0];
		pSeat->m_ePlayer = world;
	}

	/* this is running whenever we're doing 'buildcubemaps' */
	if (g_iCubeProcess == TRUE) {
		setproperty(VF_DRAWENGINESBAR, (float)0);
		setproperty(VF_DRAWCROSSHAIR, (float)0);
		setproperty(VF_DRAWWORLD, (float)1);
		setproperty(VF_MIN, [0,0]);
		setproperty(VF_VIEWENTITY, player_localentnum);
		setproperty(VF_ORIGIN, g_vecCubePos);
		setproperty(VF_ANGLES, vecViewAngles);
		setproperty(VF_CL_VIEWANGLES, vecViewAngles);
		setproperty(VF_SIZE_X, g_dCubeSize);
		setproperty(VF_SIZE_Y, g_dCubeSize);
		setproperty(VF_AFOV, 90.0f);
		CSQC_RenderScene();
	} else {
		/* now render each player seat */
		for (s = numclientseats; s-- > 0;) {
			pSeat = &g_seats[s];
			pSeatLocal = &g_seatslocal[s];
			g_view = g_viewSeats[s];

			pSeat->m_ePlayer = findfloat(world, ::entnum, player_localentnum);

            if (pSeat->m_ePlayer == world)
                continue;

			cl = (ncPlayer)pSeat->m_ePlayer;
			setproperty(VF_ACTIVESEAT, (float)s);

			/* bleurgh */
			if (cl.activeweapon == 0 || wasfreed(cl.m_activeWeapon) || cl.m_activeWeapon._isWeapon == false) {
				cl.m_activeWeapon = 0;
			}

			/* set up our single/split viewport */
			View_CalcViewport(s, w, h);

			/* our view target ourselves, if we're alive... */
			g_view.SetViewTarget((ncEntity)pSeat->m_ePlayer);

			if (Client_IsSpectator(cl))
				g_view.SetViewMode(VIEWMODE_SPECTATING);
			else
				g_view.SetViewMode(VIEWMODE_FPS);

			/* ugly hack to force-cache dlight shader */
			if (g_dlight_cached == false) {
				g_dlight_cached = true;
				dynamiclight_add(g_view.GetCameraOrigin(), 2048.0f, [0.1,0.1,0.1]);
			}

			g_view.UpdateView();

			/* 2D calls happen here, after rendering is done */
			CSQC_Update2D(w, h, focus);
			Commandmenu_Draw();

			EFX_UpdateListener(g_view);
			DSP_UpdateSoundscape(g_view);
			clframetime = 0.0f;
			frametime = 0.0f;
		}
	}

	/* make sure we're not running these on invalid seats post frame */
	pSeat = __NULL__;
	pSeatLocal = __NULL__;

	g_modelSpinAngle = time * autocvar_cg_modelSpinSpeed;
	g_modelSpinRoll = sin(time * autocvar_cg_modelSpinRollSpeed);
	g_modelSpinPitch = sin(time * autocvar_cg_modelSpinPitchSpeed);
	g_modelSpinRoll *= autocvar_cg_modelSpinRoll;
	g_modelSpinPitch *= autocvar_cg_modelSpinPitch;
	g_modelBobHeight = sin(time * autocvar_cg_modelBobHeightSpeed);
	g_modelBobHeight *= autocvar_cg_modelBobHeight;
}

/** Called every time an input event (keys pressed, mouse moved etc.) happens.
When this returns FALSE, the engine is free to interpret the input event as it
wishes. If it returns TRUE the engine is not set on ignoring it.
*/
float
CSQC_InputEvent(float fEventType, float fKey, float fCharacter, float fDeviceID)
{
	CSQC_UpdateSeat();

	switch (fEventType) {
	case IE_KEYDOWN:
		break;
	case IE_KEYUP:
		break;
	case IE_MOUSEABS:
		g_vecMousePos[0] = fKey;
		g_vecMousePos[1] = fCharacter;
		break;
	case IE_MOUSEDELTA:
		g_vecMousePos[0] += fKey;
		g_vecMousePos[1] += fCharacter;
		break;
	default:
		return (true);
	}

	pSeat->m_bInterfaceFocused = false;

	for (entity e = world; (e = find(e, ::classname, "ncInteractiveSurface"));) {
		vector vecPos = pSeat->m_ePlayer.origin + pSeat->m_ePlayer.view_ofs;
		ncInteractiveSurface surf = (ncInteractiveSurface) e;

		if (surf.FocusCheck(vecPos, view_angles)) {
			pSeat->m_bInterfaceFocused = true;
			surf.Input(fEventType, fKey, fCharacter, fDeviceID);
			break;
		}
	}

	//g_vecMousePos = getmousepos();

	bool vgui_pressed;
	vgui_pressed = Commandmenu_Input(fEventType, fKey, fCharacter, fDeviceID);

	if (!vgui_pressed) {
		vgui_pressed = VGUI_Input(fEventType, fKey, fCharacter, fDeviceID);
	}

	if (g_vguiWidgetCount) {
		setcursormode(TRUE, "gfx/cursor", [0,0,0], 1.0f);
	} else {
		setcursormode(FALSE, "gfx/cursor", [0,0,0], 1.0f);
	}

	return (vgui_pressed);
}

/** Intercepts and controls what input globals are being sent to the server.
This is where you have the chance to suppress analog and digital movement/action values.
Prediction will also avoid them.
*/
void
CSQC_Input_Frame(void)
{
	entity me;

	if (Util_IsPaused()) {
		return;
	}

	CSQC_UpdateSeat();
	me = pSeat->m_ePlayer;

	if (is.Player(me)) {
		ncPlayer pl = (ncClient)me;
		bool inventoryChanged = false;

			//ncLog("Relinking inventory for local player %d", pl.entnum);

			/* redo the references. */
			for (ncItem itemChain = world; (itemChain = next.Item(itemChain));) {
				entity oldOwner = itemChain.owner;
				itemChain.owner = findentity(world, ::entnum, itemChain.owner_entnum);
				itemChain.m_nextItem = (ncItem)findentity(world, ::entnum, itemChain.chain_entnum);

				/* the owner has changed. */
				if (itemChain.owner == pl && itemChain.owner && oldOwner != itemChain.owner) {
					itemChain._AddedCallback();
					inventoryChanged = true;
				}
			}

		ncWeapon oldWeapon = pl.m_activeWeapon;
		pl.m_activeWeapon = findentity(world, ::entnum, pl.activeweapon);

		if (pl.activeweapon) { /* has a weapon selected */
			if (pl.m_activeWeapon && oldWeapon != pl.m_activeWeapon) { /* got a valid entity ref, and its a different one from last input frame. */
				if (oldWeapon) {
					oldWeapon._SwitchedFromCallback();
				}
				if (pl.m_activeWeapon && pl.m_activeWeapon.declclass != oldWeapon.declclass) {
					pl.m_activeWeapon.owner = pl;
					pl.m_activeWeapon._SwitchedToCallback();
				}
				inventoryChanged = true;
			}
		}

		if (inventoryChanged == true) {
			pl.SortWeaponChain();
		}

		pl.vehicle = findentity(world, ::entnum, pl.vehicle_entnum);
		pl.m_itemList = findentity(world, ::entnum, pl.m_itemStart);

		pl.SharedInputFrame();
		float delayInputs = HUD_ClientInputFrame(input_buttons);

		if (delayInputs > 0.0f) {
			pSeat->m_flInputBlockTime = time + delayInputs;
		}

		g_clientInitialized = true;
		pl.ClientInputFrame();

		if (pSeat->m_flInputBlockTime > time) {
			input_buttons &= ~INPUT_PRIMARY;
			input_buttons &= ~INPUT_SECONDARY;
			pSeat->m_iInputAttack2 = false;
			return;
		}
	}
}

/** Handles every SVC_CGAMEPACKET that the engine passes onto us that the server sent.
To maintain protocol compatibility, SVC_CGAMEPACKET is the only user controlled event.
You cannot intercept networked events here.
*/
void
CSQC_Parse_Event(void)
{
	/* always 0, unless it was sent with a MULTICAST_ONE or MULTICAST_ONE_R to p2+ */
	CSQC_UpdateSeat();

	float fHeader = readbyte();

	int ret = ClientGame_EventParse(fHeader);
	if (ret == 1) {
		return;
	}

	Event_Parse(fHeader);
}

/** Console commands not protected by the engine get handled here.
If we return FALSE this means the engine needs to handle
the command itself which can result in a 'unrecognized command' message in console.

The server-side equivalent is `ConsoleCmd` (src/server/entry.qc)
*/
float
CSQC_ConsoleCommand(string sCMD)
{
	/* the engine will hide the p1 etc commands... which is fun... */
	CSQC_UpdateSeat();

	tokenize(sCMD);

	/* give us a chance to override commands */
	return (ClientGame_ConsoleCommand()) ? true : Cmd_Parse(sCMD);
}


/** Prints to console and heads up display are handled here.

There are 4 different types currently:
PRINT_LOW = low on the screen.
PRINT_MEDIUM = medium level on the screen.
PRINT_HIGH  = top level on the screen
PRINT_CHAT = chat message

Currently, everything but chat gets piped into a single printbuffer,
similar to NetQuake.

FIXME: We'd like to expose this further to modification.
*/
void
CSQC_Parse_Print(string sMessage, float fLevel)
{
	CSQC_UpdateSeat();

	/* chat goes through here */
	if (fLevel == PRINT_CHAT) {
		Chat_Parse(sMessage);
		return;
	}

	/* the rest goes into our print buffer */
	if (pSeat->m_iPrintLines < 4) {
		pSeat->m_strPrintBuffer[pSeat->m_iPrintLines + 1] = sMessage;
		pSeat->m_iPrintLines++;
	} else {
		for (int i = 0; i < 4; i++) {
			pSeat->m_strPrintBuffer[i] = pSeat->m_strPrintBuffer[i + 1];
		}
		pSeat->m_strPrintBuffer[4] = sMessage;
	}

	pSeat->m_flPrintTime = time + CHAT_TIME;

	/* log to console */
	localcmd(sprintf("echo \"%s\"\n", sMessage));
}

/** Catches every centerprint call and allows us to tinker with it.
That's how we are able to add color, alpha and whatnot.
Keep in mind that newlines need to be tokenized.
*/
float
CSQC_Parse_CenterPrint(string sMessage)
{
	CSQC_UpdateSeat();

	pSeat->m_iCenterprintLines = tokenizebyseparator(sMessage, "\n");

	for (int i = 0; i < (pSeat->m_iCenterprintLines); i++) {
		pSeat->m_strCenterprintBuffer[i] = sprintf("^xF80%s", argv(i));
	}

	pSeat->m_flCenterprintAlpha = 1;
	pSeat->m_flCenterprintTime = time + 3;

	return (1);
}

/** Called when an entity is being networked from the server game.
ClientGame_EntityUpdate allows the sub-games to do game specific
overrides. If that returns FALSE Nuclide will attempt to handle it here.
If neither handles it we'll get a protocol error which will disconnect the client.
*/
void
CSQC_Ent_Update(float new)
{
	float t;
	t = readbyte();

	/* client didn't override anything */
	if (ClientGame_EntityUpdate(t, new)) {
		return;
	}

	Entity_EntityUpdate(t, new);
}

/** Called by the engine when the map has fully initialized.

Within this function we can make some safe assumptions about
the world, its format and get start loading the entity lump
ourselves if need be.
*/
void
CSQC_WorldLoaded(void)
{
	InitStart();

	//DetailTex_Init();

#if 1
	string strTokenized;
	getentitytoken(0);

	while (1) {
		strTokenized = getentitytoken();
		if (strTokenized == "") {
			break;
		}
		if (strTokenized != "{") {
			ncWarning("Bad entity data");
			break;
		}
		if (!Entities_ParseLump()) {
			ncWarning("Bad entity data");
			break;
		}
	}
#endif

	g_client_world_loaded = true;

	/* wad files will most likely have loaded now */
	DecalGroups_Precache();

	InitEnd();
}

/** Called when a server tells us an active entity gets removed.

In this function 'self' refers to the entity that's scheduled for removal.
We manually call remove(); on it at the end. We get the chance to
remove the playback of sounds, skeletal objects and so on.
*/
void
CSQC_Ent_Remove(void)
{
	if (self.identity) {
		ncEntity me = (ncEntity)self;
		me.removed = 1; /* mark this as cleanly removed */

		/* we don't want to call Destroy, as that's delayed by a frame...
		   so we need to call this ourselves */
		if (me.OnRemoveEntity)
			me.OnRemoveEntity();

		/* frees one slot the engine won't free for us */
		if (me.skeletonindex)
			skel_delete(me.skeletonindex);

		/* we're done, remove it once and for all */
		remove(self);
	} else {
		remove(self);
	}
}

/** The last function that the engine will ever call onto this csprogs.

You want to close file handles and possible free memory here, as
that is the last thing that will be called.
*/
void
CSQC_Shutdown(void)
{
	InitPrint("Shutting Client Game");
	Decal_Shutdown();
	Sentences_Shutdown();
	Titles_Shutdown();
	SoundDef_Shutdown();
	PropData_Shutdown();
	ncLog("Client game shutdown.");

	/* ENGINE, PLS FIX */
	input_cursor_entitynumber = 0;
}
