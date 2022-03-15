/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

/*
=================
CSQC_UpdateSeat

Updates our seat pointers, call this when you need to verify we're
getting the current player's info and not someone elses on the same
machine (splitscreen)
=================
*/
void
CSQC_UpdateSeat(void)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	pSeatLocal = &g_seatslocal[s];
}

/*
=================
CSQC_Init

First thing inited in the progs. Before any world is initialized.
=================
*/
void
CSQC_Init(float apilevel, string enginename, float engineversion)
{
	print("--------- Initializing Client Game ----------\n");

	pSeat = &g_seats[0];
	pSeatLocal = &g_seatslocal[0];

	Cmd_Init();

	/* Sound shaders */
	Sound_Init();
	PropData_Init();
	precache_sound("common/wpn_hudon.wav");
	precache_sound("common/wpn_hudoff.wav");
	precache_sound("common/wpn_moveselect.wav");
	precache_sound("common/wpn_select.wav");

	/* VGUI */
	VGUI_Init();

	/* Game specific inits */
	ClientGame_Init(apilevel, enginename, engineversion);
	EFX_Init();
	Titles_Init();
	Sentences_Init();
	Decals_Init();
	Way_Init();

	/* let the menu know we're a multi or a singleplayer game */
	if (serverkeyfloat("sv_playerslots") == 1)
		cvar_set("_menu_singleplayer", "1");
	else
		cvar_set("_menu_singleplayer", "0");

	/* end msg */
	print("Client game initialized.\n");
}

/*
=================
CSQC_RendererRestarted

Called by vid_reload callbacks
=================
*/
void
CSQC_RendererRestarted(string rstr)
{
	print("--------- Reloading Graphical Resources ----------\n");

	/* Fonts */
	Font_Load("fonts/font16.font", FONT_16);
	Font_Load("fonts/font20.font", FONT_20);
	Font_Load("fonts/fontcon.font", FONT_CON);

	/* Particles */
	PART_DUSTMOTE = particleeffectnum("volume.dustmote");
	PART_BURNING = particleeffectnum("burn.burning");

	/* 2D Pics */
	precache_pic("gfx/vgui/icntlk_sv");
	precache_pic("gfx/vgui/icntlk_pl");

	/* View */
	Chat_Init();
	Weapons_Init();
	Scores_Init();
	View_Init();
	ClientGame_RendererRestart(rstr);
	HUD_Init();

	/* GS-Entbase */
	Fade_Init();
	Decal_Reload();
	Sky_Update(TRUE);
	Entities_RendererRestarted();
	DetailTex_Init();

	//g_shellchrome = spriteframe("sprites/shellchrome.spr", 0, 0.0f);
	g_shellchromeshader = shaderforname("shellchrome", sprintf("{\ndeformVertexes bulge 1.25 1.25 0\n{\nmap %s\ntcGen environment\nrgbGen entity\n}\n}", "textures/sfx/reflection.tga"));

	/* end msg */
	print("Graphical resources reloaded\n");
}

/* this is so that profile_csqc reports more accurate statistics as to
   what causes computation time */
void
CSQC_RenderScene(void)
{
	renderscene();
}

/*
=================
CSQC_UpdateView

Run every single frame we're connected to a session.
=================
*/
void
CSQC_UpdateView(float w, float h, float focus)
{
	player pl = __NULL__;
	spectator spec;
	int s;

	if (w == 0 || h == 0) {
		return;
	} else {
		/* First time we can effectively call VGUI
		*  because until now we don't know the video res.
		*/
		if (!video_res[0] && !video_res[1]) {
			video_res[0] = w;
			video_res[1] = h;
			ClientGame_InitDone();
		}
	}

	/* While the init above may have already happened,
	   people are able to resize windows dynamically too. */
	if (w != video_res[0] || h != video_res[1]) {
		video_res[0] = w;
		video_res[1] = h;
		VGUI_Reposition();
	}

	Fog_Update();
	Sky_Update(FALSE);
	cvar_set("_background", serverkey("background"));

	if (serverkeyfloat("background") == 1) {
		setpause(FALSE);
	}

	clearscene();
	setproperty(VF_DRAWENGINESBAR, 0);
	setproperty(VF_DRAWCROSSHAIR, 0);

	//just in case...
	if (numclientseats > g_seats.length) {
		numclientseats = g_seats.length;
	}

	for (s = g_seats.length; s-- > numclientseats;) {
		pSeat = &g_seats[s];
		pSeatLocal = &g_seatslocal[s];
		pSeat->m_ePlayer = world;
	}

	for (s = numclientseats; s-- > 0;) {
		pSeat = &g_seats[s];
		pSeatLocal = &g_seatslocal[s];

		/* set up our single/split viewport */
		View_CalcViewport(s, w, h);
		setproperty(VF_ACTIVESEAT, (float)s);
		setproperty(VF_MIN, video_mins);
		setproperty(VF_SIZE, video_res);

		pSeat->m_ePlayer = self = findfloat(world, entnum, player_localentnum);
		pl = (player)self;

		/* player slot not present */
		if (!self) {
			continue;
		}

		/* this needs to be moved into a base_client method */
#if 1
		if (self.classname == "player") {
			Predict_PlayerPreFrame(pl);

			pSeat->m_vecPredictedOrigin = pl.origin;
			pSeat->m_vecPredictedVelocity = pl.velocity;
			pSeat->m_flPredictedFlags = pl.flags;

			/* Don't hide the player entity */
			if (autocvar_cl_thirdperson == TRUE && pl.health) {
				setproperty(VF_VIEWENTITY, (float)0);
			} else {
				setproperty(VF_VIEWENTITY, (float)player_localentnum);
			}

			float oldzoom = pl.viewzoom;
			if (pl.viewzoom == 1.0f) {
				pl.viewzoom = 1.0 - (0.5 * pSeat->m_flZoomTime);

				/* +zoomin requested by Slacer */
				if (pSeat->m_iZoomed) {
					pSeat->m_flZoomTime += clframetime * 15;
				} else {
					pSeat->m_flZoomTime -= clframetime * 15;
				}
				pSeat->m_flZoomTime = bound(0, pSeat->m_flZoomTime, 1);
			}

			setproperty(VF_AFOV, cvar("fov") * pl.viewzoom);

			if (autocvar_zoom_sensitivity && pl.viewzoom < 1.0f) {
				setsensitivityscaler(pl.viewzoom * autocvar_zoom_sensitivity);
			} else {
				setsensitivityscaler(pl.viewzoom);
			}

			if (pl.viewzoom <= 0.0f) {
				setsensitivityscaler(1.0f);
			}

			pl.viewzoom = oldzoom;

			View_PreDraw();
		} else if (self.classname == "spectator") {
			spec = (spectator)self;
			Predict_SpectatorPreFrame(spec);

			pSeat->m_vecPredictedOrigin = spec.origin;
			pSeat->m_vecPredictedVelocity = spec.velocity;
			pSeat->m_flPredictedFlags = spec.flags;
		}
#endif

		addentities(MASK_ENGINE);

		/* ideally move this into a base_player method */
#if 1
		if (pSeat->m_flCameraTime > time || pSeat->m_flCameraTime == -1) {
			view_angles = pSeat->m_vecCameraAngle;
			setproperty(VF_ORIGIN, pSeat->m_vecCameraOrigin);
			setproperty(VF_CL_VIEWANGLES, view_angles);
			setproperty(VF_ANGLES, view_angles);
		} else {
			if (getplayerkeyvalue(pl.entnum-1, "*spec") == "0") {
				setproperty(VF_ORIGIN, pSeat->m_vecPredictedOrigin + pl.view_ofs);

				if (pl.flags & FL_INVEHICLE) {
					NSVehicle veh = (NSVehicle)pl.vehicle;
					
					if (veh.UpdateView)
						veh.UpdateView();
				} else if (pl.health) {
					if (autocvar_cl_thirdperson == TRUE) {
						makevectors(view_angles);
						vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
						vector vEnd = vStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
						traceline(vStart, vEnd, FALSE, self);
						setproperty(VF_ORIGIN, trace_endpos + (v_forward * 5));
					}
				}

				Shake_Update(pl);
				setproperty(VF_ANGLES, view_angles + pl.punchangle);
			} else if (getplayerkeyvalue(pl.entnum-1, "*spec") == "1") {
				spec = (spectator)self;
				switch (spec.spec_mode) {
				case SPECMODE_THIRDPERSON:
					makevectors(view_angles);
					vector vecStart;
					vecStart[0] = pSeat->m_vecPredictedOrigin[0];
					vecStart[1] = pSeat->m_vecPredictedOrigin[1];
					vecStart[2] = pSeat->m_vecPredictedOrigin[2] + 16;
					vecStart += (v_right * 4);

					vector vecEnd = vecStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
					traceline(vecStart, vecEnd, FALSE, self);
					setproperty(VF_ORIGIN, trace_endpos + (v_forward * 5));
					break;
				case SPECMODE_FIRSTPERSON:
					entity c;
					c = findfloat(world, ::entnum, spec.spec_ent);
					
					if (c.classname == "player") {
						player bp = (player)c;
						removeentity(c);
						setproperty(VF_ORIGIN, pSeat->m_vecPredictedOrigin + bp.view_ofs);
						setproperty(VF_ANGLES, bp.v_angle);
						setproperty(VF_CL_VIEWANGLES, bp.v_angle);
					}
					break;
				default:
					setproperty(VF_ORIGIN, pSeat->m_vecPredictedOrigin);
				}
			} else if (getplayerkeyvalue(pl.entnum-1, "*spec") == "2") {
				setproperty(VF_ORIGIN, pSeat->m_vecPredictedOrigin);
				Shake_Update(pl);
				setproperty(VF_ANGLES, view_angles + pl.punchangle);
			}

			if (g_iIntermission) {
				view_angles = pSeat->m_vecCameraAngle;
				view_angles += [sin(time), sin(time * 2)];
				setproperty(VF_ORIGIN, pSeat->m_vecCameraOrigin);
				setproperty(VF_CL_VIEWANGLES, view_angles);
			}
		}
#endif

		setproperty(VF_DRAWWORLD, 1);
		SkyCamera_Setup(getproperty(VF_ORIGIN));

		/* draw the viewmodel in a second pass if desired */
		if (autocvar_r_viewmodelpass && pl.health > 0) {
			CSQC_RenderScene();
			clearscene();
			setproperty(VF_MIN, video_mins);
			setproperty(VF_SIZE, video_res);
			setproperty(VF_ANGLES, view_angles + pl.punchangle);
			setproperty(VF_DRAWWORLD, 0);
			setproperty(VF_AFOV, autocvar_r_viewmodelfov);
			setproperty(VF_ORIGIN, pSeat->m_vecPredictedOrigin + pl.view_ofs);
			View_DrawViewModel();
		} else if (pl.health > 0) {
			View_DrawViewModel();
		} else if (getplayerkeyvalue(pl.entnum-1, "*dead") == "1") {
			pl.UpdateDeathcam();
		}

		/* this is running whenever we're doing 'buildcubemaps' */
		if (g_iCubeProcess == TRUE) {
			setproperty(VF_ORIGIN, g_vecCubePos);
			setproperty(VF_SIZE_X, g_dCubeSize);
			setproperty(VF_SIZE_Y, g_dCubeSize);
			print(sprintf("cubesize: %d\n", g_dCubeSize));
			setproperty(VF_AFOV, 90);
		}

		/* render the scene, then put monitor RenderTargets on top */
		CSQC_RenderScene();
		RenderTarget_Monitor_Update();

		/* all 2D operations happen after this point */
		for (entity b = world; (b = findfloat(b, ::isCSQC, 1));) {
			NSEntity pf = (NSEntity) b;
			pf.postdraw();
		}

		Fade_Update((int)video_mins[0],(int)video_mins[1], (int)w, (int)h);
		View_PostDraw();

		if (g_iIntermission) {
			Scores_Draw();
		} else if (focus == TRUE) {
			GameText_Draw();
			PointMessage_Draw();

			if (getplayerkeyvalue(pl.entnum-1, "*spec") == "0") {
				HUD_Draw();
			} else if (self.classname == "player") {
				HUD_DrawSpectator();
			}

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

		/* move this into base_client methods */
#if 1
		if (self.classname == "player")
			Predict_PlayerPostFrame((player)self);
		else if (self.classname == "spectator")
			Predict_SpectatorPostFrame((spectator)self);
#endif
	}

	/* this sucks and doesn't take seats into account */
	EFX_UpdateListener();
	DSP_UpdateSoundscape();

	/* draw AL debug info (no regard for seating */
	if (autocvar_s_al_debug)
		EFX_DebugInfo();

	/* make sure we're not running these on invalid seats post frame */
	pSeat = __NULL__;
	pSeatLocal = __NULL__;
}

/*
=================
CSQC_InputEvent

Updates all our input related globals for use in other functions
=================
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
		mouse_pos[0] = fKey;
		mouse_pos[1] = fCharacter;
		break;
	case IE_MOUSEDELTA:
		mouse_pos[0] += fKey;
		mouse_pos[1] += fCharacter;

		if (mouse_pos[0] < 0) {
			mouse_pos[0] = 0;
		} else if (mouse_pos[0] > video_res[0]) {
			mouse_pos[0] = video_res[0];
		}

		if (mouse_pos[1] < 0) {
			mouse_pos[1] = 0;
		} else if (mouse_pos[1] > video_res[1]) {
			mouse_pos[1] = video_res[1];
		}
		break;
	default:
		return (1);
	}

	VGUI_Input(fEventType, fKey, fCharacter, fDeviceID);

	if (g_vguiWidgetCount) {
		setcursormode(TRUE, "gfx/cursor", [0,0,0], 1.0f);
	} else {
		setcursormode(FALSE, "gfx/cursor", [0,0,0], 1.0f);
	}

	if (VGUI_Active())
		return (1);
	else
		return (0);
}

/*
=================
CSQC_Input_Frame

Hijacks and controls what input globals are being sent to the server
=================
*/
void
CSQC_Input_Frame(void)
{
	entity me;

	CSQC_UpdateSeat();
	me = pSeat->m_ePlayer;

	if (me.classname == "player" || me.classname == "spectator") {
		base_client pl = (base_client)me;
		pl.ClientInputFrame();
	}
}


/*
=================
CSQC_Parse_Event

Whenever we call a SVC_CGAMEPACKET on the SSQC, this is being run
=================
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

/*
=================
CSQC_ConsoleCommand

Commands not protected by the engine get passed here.
If we return 0 this means the engine needs to either handle
the command or throw a 'unrecognized command' message.
=================
*/
float
CSQC_ConsoleCommand(string sCMD)
{
	/* the engine will hide the p1 etc commands... which is fun... */
	CSQC_UpdateSeat();

	tokenize(sCMD);

	/* give us a chance to override commands */
	int ret = ClientGame_ConsoleCommand();

	/* successful override */
	if (ret == (1))
		return (1);

	return Cmd_Parse(sCMD);
}

/*
=================
CSQC_ConsoleCommand

Engine or server game will occasionally pass messages through here.
There are 4 different types currently:
PRINT_LOW = low on the screen.
PRINT_MEDIUM = medium level on the screen.
PRINT_HIGH  = top level on the screen
PRINT_CHAT = chat message
Currently, everything but chat gets piped into a single printbuffer,
similar to NetQuake. 
FIXME: We'd like to expose this further to modification.
=================
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


/*
=================
CSQC_Parse_CenterPrint

Catches every centerprint call and allows us to tinker with it.
That's how we are able to add color, alpha and whatnot.
Keep in mind that newlines need to be tokenized
=================
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

/*
=================
CSQC_Ent_Update

Called when an entity is being networked from the server game.
ClientGame_EntityUpdate allows the project to do game specific
overrides. If that returns 0 Nuclide will attempt to handle it.
If neither handles it we'll get a protocol error.
=================
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

/*
=================
CSQC_WorldLoaded

Whenever the world is fully initialized...
=================
*/
void
CSQC_WorldLoaded(void)
{
	print("--------- Initializing Client World ----------\n");
	//DetailTex_Init();

	/* Primarily for the flashlight */
	if (serverkeyfloat("*bspversion") != BSPVER_HL) {
		localcmd("r_shadow_realtime_dlight 1\n");
	} else {
		localcmd("r_shadow_realtime_dlight 0\n");
	}

	string strTokenized;
	getentitytoken(0);

	while (1) {
		strTokenized = getentitytoken();
		if (strTokenized == "") {
			break;
		}
		if (strTokenized != "{") {
			print("^1[WARNING] ^7Bad entity data\n");
			break;
		}
		if (!Entities_ParseLump()) {
			print("^1[WARNING] ^7Bad entity data\n");
			break;
		}
	}

	print("Client world initialized.\n");
}

/*
=================
CSQC_Ent_Remove

Whenever an entity gets removed from the server and will no longer
receive entity updates.
=================
*/
void
CSQC_Ent_Remove(void)
{
	if (self.isCSQC) {
		NSEntity me = (NSEntity)self;
		me.ClientRemove();
		remove(self);
	}
}

/*
=================
CSQC_Shutdown

Incase you need to free something
=================
*/
void
CSQC_Shutdown(void)
{
	print("--------- Shutting Client Game ----------\n");
	Decal_Shutdown();
	Sentences_Shutdown();
	Titles_Shutdown();
	Sound_Shutdown();
	PropData_Shutdown();
	EFX_Shutdown();
	print("Client game shutdown.\n");
}
