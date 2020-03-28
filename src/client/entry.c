/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

void
CSQC_Init(float apilevel, string enginename, float engineversion)
{
	pSeat = &seats[0];

	registercommand("titles_test");
	registercommand("vox_test");
	registercommand("+attack2");
	registercommand("-attack2");
	registercommand("+reload");
	registercommand("-reload");
	registercommand("+use");
	registercommand("-use");
	registercommand("+duck");
	registercommand("-duck");
	registercommand( "callvote" );
	registercommand( "vote" );

	/* Requested by Slacer */
	registercommand("+zoomin");
	registercommand("-zoomin");

	registercommand("slot1");
	registercommand("slot2");
	registercommand("slot3");
	registercommand("slot4");
	registercommand("slot5");
	registercommand("slot6");
	registercommand("slot7");
	registercommand("slot8");
	registercommand("slot9");
	registercommand("slot10");
	registercommand("lastinv");
	registercommand("invnext");
	registercommand("invprev");
	registercommand("+showscores");
	registercommand("-showscores");
	registercommand("buildcubemaps");

	precache_model("sprites/640_pain.spr");
	precache_model("sprites/crosshairs.spr");

	precache_model("sprites/muzzleflash1.spr");
	precache_model("sprites/muzzleflash2.spr");
	precache_model("sprites/muzzleflash3.spr");

	/* VOX */
	Sound_InitVOX();

	/* Effects */
	Effects_Init();

	precache_sound("common/wpn_hudon.wav");
	precache_sound("common/wpn_hudoff.wav");
	precache_sound("common/wpn_moveselect.wav");
	precache_sound("common/wpn_select.wav");

	/* VGUI */
	VGUI_Init();

	/* Game specific inits */
	Client_Init(apilevel, enginename, engineversion);
	DSP_Init();
	CSQC_RendererRestarted("init");
	Titles_Init();
	Sentences_Init();
}

/* Rendering Caches */
void
CSQC_RendererRestarted(string rstr)
{
	/* Fonts */
	FONT_16 = loadfont("16", "fonts/default", "16", -1);
	FONT_20 = loadfont("cr", "creditsfont?fmt=h", "20", -1);
	FONT_CON = loadfont("font", "", "12", -1);
	drawfont = FONT_CON;

	/* Particles */
	PARTICLE_SPARK 		= particleeffectnum("part_spark");
	PARTICLE_PIECES_BLACK 	= particleeffectnum("part_pieces_black");
	PARTICLE_SMOKE_GREY 	= particleeffectnum("part_smoke_grey");
	PARTICLE_SMOKE_BROWN 	= particleeffectnum("part_smoke_brown");
	PARTICLE_BLOOD 		= particleeffectnum("part_blood");
	DECAL_SHOT 		= particleeffectnum("decal_shot");
	DECAL_GLASS 		= particleeffectnum("decal_glass");
	PART_DUSTMOTE = particleeffectnum("volume.dustmote");

	/* 2D Pics */
	precache_pic("gfx/vgui/icntlk_sv");
	precache_pic("gfx/vgui/icntlk_pl");

	/* View */
	Scores_Init();
	View_Init();
	HUD_Init();

	/* GS-Entbase */
	Fade_Init();
	Sky_Update();
	Decal_Reload();
	Game_RendererRestarted(rstr);
}

void
CSQC_UpdateView(float w, float h, float focus)
{
	player pl;
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
			Client_InitDone();
		}
	}

	/* While the init above may have already happened,
	   people are able to resize windows dynamically too. */
	video_res[0] = w;
	video_res[1] = h;

	if ( g_iCubeProcess == TRUE ) {
		clearscene();
		setproperty( VF_DRAWWORLD, TRUE );
		setproperty( VF_DRAWENGINESBAR, FALSE );
		setproperty( VF_DRAWCROSSHAIR, FALSE );
		setproperty( VF_ENVMAP, "$whiteimage" );
		setproperty( VF_ORIGIN, g_vecCubePos );
		setproperty( VF_AFOV, 90 );
		renderscene();
		return;
	}

	clearscene();
	setproperty(VF_DRAWENGINESBAR, 0);
	setproperty(VF_DRAWCROSSHAIR, 0);

	//just in case...
	if (numclientseats > seats.length) {
		numclientseats = seats.length;
	}

	for (s = seats.length; s-- > numclientseats;) {
		pSeat = &seats[s];
		pSeat->ePlayer = world;
	}

	for (s = numclientseats; s-- > 0;) {
		pSeat = &seats[s];
		
		View_CalcViewport(s, w, h);
		setproperty(VF_ACTIVESEAT, (float)s);

		pSeat->ePlayer = self = findfloat(world, entnum, player_localentnum);

		if (!self) {
			continue;
		}

		pl = (player)self;

		Predict_PreFrame((player)self);

		pSeat->vPlayerOrigin = pl.origin;
		pSeat->vPlayerVelocity = pl.velocity;
		pSeat->fPlayerFlags = pl.flags;

		// Don't hide the player entity
		if (autocvar_cl_thirdperson == TRUE && pl.health) {
			setproperty(VF_VIEWENTITY, (float)0);
		} else {
			setproperty(VF_VIEWENTITY, (float)player_localentnum);
		}

		float oldzoom = pl.viewzoom;
		if (pl.viewzoom == 1.0f) {
			pl.viewzoom = 1.0 - (0.5 * pSeat->flZoomTime);

			/* +zoomin requested by Slacer */
			if (pSeat->iZoomed) {
				pSeat->flZoomTime += frametime * 15;
			} else {
				pSeat->flZoomTime -= frametime * 15;
			}
			pSeat->flZoomTime = bound(0, pSeat->flZoomTime, 1);
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
		
		View_Stairsmooth();

		// When Cameratime is active, draw on the forced coords instead
		if (pSeat->fCameraTime > time) {
			setproperty(VF_ORIGIN, pSeat->vCameraPos);
			setproperty(VF_CL_VIEWANGLES, pSeat->vCameraAngle);
		} else {
			if (pl.health) {
				if (autocvar_cl_thirdperson == TRUE) {
					makevectors(view_angles);
					vector vStart = [pSeat->vPlayerOrigin[0], pSeat->vPlayerOrigin[1], pSeat->vPlayerOrigin[2] + 16] + (v_right * 4);
					vector vEnd = vStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
					traceline(vStart, vEnd, FALSE, self);
					setproperty(VF_ORIGIN, trace_endpos + (v_forward * 5));
				} else {
					setproperty(VF_ORIGIN, pSeat->vPlayerOrigin + pl.view_ofs);
				}
			} else {
				setproperty(VF_ORIGIN, pSeat->vPlayerOrigin);
			}
		}

		addentities(MASK_ENGINE);
		setproperty(VF_MIN, video_mins);
		setproperty(VF_SIZE, video_res);
		setproperty(VF_ANGLES, view_angles + pl.punchangle);
		setproperty(VF_DRAWWORLD, 1);

		if (g_skyscale != 0 && g_skypos) {
			vector porg;
			vector realpos;

			porg = getproperty(VF_ORIGIN);
			if (autocvar_dev_skyscale) {
				realpos[0] = porg[0] / autocvar_dev_skyscale;
				realpos[1] = porg[1] / autocvar_dev_skyscale;
				realpos[2] = porg[2] / autocvar_dev_skyscale;
			} else {
				realpos[0] = porg[0] / g_skyscale;
				realpos[1] = porg[1] / g_skyscale;
				realpos[2] = porg[2] / g_skyscale;
			}
			setproperty(VF_SKYROOM_CAMERA, g_skypos + realpos);
		}

		/* draw the world/entities */
		renderscene();

		/* Now we draw the viewmodel in a second pass */
		clearscene();
		setproperty(VF_MIN, video_mins);
		setproperty(VF_SIZE, video_res);
		setproperty(VF_ANGLES, view_angles + pl.punchangle);
		setproperty(VF_DRAWWORLD, 0);
		setproperty(VF_AFOV, cvar("cl_viewmodelfov"));
		setproperty(VF_ORIGIN, pSeat->vPlayerOrigin + pl.view_ofs);
		View_DrawViewModel();
		renderscene();

		/* Run this on all players */
		for (entity b = world; (b = find(b, ::classname, "player"));) {
			player pf = (player) b;
			pf.postdraw();
		}

		Fade_Update((int)video_mins[0],(int)video_mins[1], (int)w, (int)h);

#ifdef CSTRIKE
		Cstrike_PostDraw((int)video_mins[0],(int)video_mins[1], (int)w, (int)h);
#endif
		View_PostDraw();

		if (focus == TRUE) {
			GameText_Draw();

			// The spectator sees things... differently
			if (getplayerkeyvalue(player_localnum, "*spec") != "0") {
				//VGUI_DrawSpectatorHUD();
			} else {
				HUD_Draw();
			}

			Obituary_Draw();
			///HUD_DrawOrbituaries();
			Voice_DrawHUD();
			Chat_Draw();
			Print_Draw();

			// Don't even try to draw centerprints and VGUI menus when scores are shown
			if (pSeat->iShowScores == TRUE) {
				Scores_Draw();
			} else {
				VGUI_Draw();
				CSQC_DrawCenterprint();
			}
		}

		Predict_PostFrame((player)self);
	}

	DSP_UpdateListener();
	pSeat = (void*)0x70000000i;

	Sound_ProcessWordQue();
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
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];

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
			return TRUE;
	}

	VGUI_Input(fEventType, fKey, fCharacter, fDeviceID);

	if (g_vguiWidgetCount) {
		setcursormode(TRUE, "gfx/cursor", [0,0,0], 1.0f);
	} else {
		setcursormode(FALSE, "gfx/cursor", [0,0,0], 1.0f);
	}

	return FALSE;
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
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];

	// If we are inside a VGUI, don't let the client do stuff outside
	if (g_vguiWidgetCount > 0) {
		input_impulse = 0;
		input_buttons = 0;
		return;
	}

	/* The HUD needs more time */
	if ((pSeat->fHUDWeaponSelected) && (input_buttons & INPUT_BUTTON0)) {
		HUD_DrawWeaponSelect_Trigger();
		input_buttons = 0;
		pSeat->fInputSendNext = time + 0.2;
	}

	/* prevent accidental input packets */
	if (pSeat->fInputSendNext > time) {
		input_impulse = 0;
		input_buttons = 0;
		return;
	}

	/* compat*/
	if (input_impulse == 201) {
		sendevent("Spraylogo", "");
	}

	if (pSeat->iInputAttack2 == TRUE) {
		input_buttons |= INPUT_BUTTON3;
	} 

	if (pSeat->iInputReload == TRUE) {
		input_buttons |= INPUT_BUTTON4;
	} 

	if (pSeat->iInputUse == TRUE) {
		input_buttons |= INPUT_BUTTON5;
	} 

	if (pSeat->iInputDuck == TRUE) {
		input_buttons |= INPUT_BUTTON8;
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
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];

	float fHeader = readbyte();

	switch (fHeader) {
	case EV_MUSICTRACK:
		Music_ParseTrack();
		break;
	case EV_MUSICLOOP:
		Music_ParseLoop();
		break;
	case EV_OBITUARY:
		Obituary_Parse();
		break;
	case EV_SPEAK:
		string msg;
		float pit;
		entity t = findfloat( world, entnum, readentitynum() );
		msg = readstring();
		pit = readfloat();
		sound(t, CHAN_VOICE, msg, 1.0, ATTN_NORM, pit);
		break;
	case EV_SENTENCE:
		CBaseEntity_ParseSentence();
		break;
	case EV_FADE:
		Fade_Parse();
		break;
	case EV_SPRITE:
		EnvSprite_ParseEvent();
		break;
	case EV_TEXT:
		GameText_Parse();
		break;
	case EV_MESSAGE:
		GameMessage_Parse();
		break;
	case EV_SPARK:
		vector vSparkPos, vSparkAngle;
		vSparkPos[0] = readcoord();
		vSparkPos[1] = readcoord();
		vSparkPos[2] = readcoord();
		vSparkAngle[0] = readcoord();
		vSparkAngle[1] = readcoord();
		vSparkAngle[2] = readcoord();
		Effect_CreateSpark(vSparkPos, vSparkAngle);
		break;
	case EV_GIBHUMAN:
		vector vGibPos;
		vGibPos[0] = readcoord();
		vGibPos[1] = readcoord();
		vGibPos[2] = readcoord();
		Effect_GibHuman(vGibPos);
		break;
	case EV_BLOOD:
		vector vBloodPos;
		vector vBloodColor;

		vBloodPos[0] = readcoord();
		vBloodPos[1] = readcoord();
		vBloodPos[2] = readcoord();

		vBloodColor[0] = readbyte() / 255;
		vBloodColor[1] = readbyte() / 255;
		vBloodColor[2] = readbyte() / 255;

		Effect_CreateBlood(vBloodPos, vBloodColor);
		break;
	case EV_EXPLOSION:
		vector vExploPos;

		vExploPos[0] = readcoord();
		vExploPos[1] = readcoord();
		vExploPos[2] = readcoord();

		Effect_CreateExplosion(vExploPos);
		break;
	case EV_MODELGIB:
		vector vPos;
		vPos[0] = readcoord();
		vPos[1] = readcoord();
		vPos[2] = readcoord();

		vector vSize;
		vSize[0] = readcoord();
		vSize[1] = readcoord();
		vSize[2] = readcoord();

		float fStyle = readbyte();
		int count = readbyte();
		Effect_BreakModel(count, vPos, vSize, [0,0,0], fStyle);
		break;
	case EV_CAMERATRIGGER:
		pSeat->vCameraPos.x = readcoord();
		pSeat->vCameraPos.y = readcoord();
		pSeat->vCameraPos.z = readcoord();

		pSeat->vCameraAngle.x = readcoord();
		pSeat->vCameraAngle.y = readcoord();
		pSeat->vCameraAngle.z = readcoord();

		pSeat->fCameraTime = time + readfloat();
		break;
	case EV_IMPACT:
		int iType;
		vector vOrigin, vNormal;

		iType = (int)readbyte();
		vOrigin[0] = readcoord();
		vOrigin[1] = readcoord();
		vOrigin[2] = readcoord();

		vNormal[0] = readcoord();
		vNormal[1] = readcoord();
		vNormal[2] = readcoord();

		Effect_Impact(iType, vOrigin, vNormal);
		break;
	default:
		Game_Parse_Event(fHeader);
	}
}

float
CSQC_ConsoleCommand(string sCMD)
{
	/* the engine will hide the p1 etc commands... which is fun... */
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];
	
	tokenize(sCMD);
	
	switch (argv(0)) {
	case "vote":
		if (argv(1) == "yes") {
			sendevent("VoteY", "");
		} else if (argv(1) == "no") {
			sendevent("VoteN", "");
		}
		break;
	case "callvote":
		sendevent("CallVote", "s", substring(sCMD, 9, strlen(sCMD)-9));
		break;
	case "+zoomin":
		pSeat->iZoomed = TRUE;
		break;
	case "-zoomin":
		pSeat->iZoomed = FALSE;
		break;
	case "buildcubemaps":
		CMap_Build();
		break;
	case "titles_test":
		GameMessage_Setup(argv(1));
		break;
	case "vox_test":
		Sound_PlayVOX(sCMD);
		break;
	case "+attack2":
		pSeat->iInputAttack2 = TRUE;
		break;
	case "-attack2":
		pSeat->iInputAttack2 = FALSE;
		break;
	case "+reload":
		pSeat->iInputReload = TRUE;
		break;
	case "-reload":
		pSeat->iInputReload = FALSE;
		break;
	case "+use":
		pSeat->iInputUse = TRUE;
		break;
	case "-use":
		pSeat->iInputUse = FALSE;
		break;
	case "+duck":
		pSeat->iInputDuck = TRUE;
		break;
	case "-duck":
		pSeat->iInputDuck = FALSE;
		break;
	case "invnext":
		HUD_DrawWeaponSelect_Back();
		break;
	case "invprev":
		HUD_DrawWeaponSelect_Forward();
		break;
	case "lastinv":
		HUD_DrawWeaponSelect_Last();
		break;
	case "+showscores":
		pSeat->iShowScores = TRUE;
		break;
	case "-showscores":
		pSeat->iShowScores = FALSE;
		break;
	case "slot1":
		HUD_SlotSelect(0);
		break;
	case "slot2":
		HUD_SlotSelect(1);
		break;
	case "slot3":
		HUD_SlotSelect(2);
		break;
	case "slot4":
		HUD_SlotSelect(3);
		break;
	case "slot5":
		HUD_SlotSelect(4);
		break;
	case "slot6":
		HUD_SlotSelect(5);
		break;
	case "slot7":
		HUD_SlotSelect(6);
		break;
	case "slot8":
		HUD_SlotSelect(7);
		break;
	case "slot9":
		HUD_SlotSelect(8);
		break;
	case "slot10":
		HUD_SlotSelect(9);
		break;
	default:
		return Game_ConsoleCommand();
	}
	return TRUE;
}

void CSQC_Parse_Print(string sMessage, float fLevel)
{
	// This gives messages other than chat an orange tint
	if (fLevel == PRINT_CHAT) {
		Chat_Parse(sMessage);
		return;
	}

	if (g_printlines < (4)) {
		g_printbuffer[g_printlines + 1] = sMessage;
		g_printlines++;
	} else {
		for (int i = 0; i < (4); i++) {
			g_printbuffer[i] = g_printbuffer[i + 1];
		}
		g_printbuffer[4] = sMessage;
	}

	g_printtime = time + CHAT_TIME;

	// Log to console
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
	fCenterPrintLines = tokenizebyseparator(sMessage, "\n");

	for (int i = 0; i < (fCenterPrintLines); i++) {
		sCenterPrintBuffer[i] = sprintf("^xF80%s", argv(i));
	}

	fCenterPrintAlpha = 1;
	fCenterPrintTime = time + 3;

	return TRUE;
}

/*
=================
CSQC_Ent_ParseMapEntity
=================
*/
float
CSQC_Ent_ParseMapEntity(void)
{
	entity eOld;
	CBaseEntity eEnt = __NULL__;
	string strField, strValue;
	__fullspawndata = "";
	int iClass = FALSE;

	eOld = self;

	while (1) {
		strField = getentitytoken();

		if (!strField) {
			break;
		}

		if (strField == "}") {
			if (!eEnt.classname) {
				break;
			}
			if (iClass == TRUE) {
				eEnt.Init();
				return TRUE;
			}
			if (eEnt) {
				remove(eEnt);
			}
			return TRUE;
		}

		strValue = getentitytoken();
		if (!strValue) {
			break;
		}

		switch (strField) {
		case "classname":
			eEnt = (CBaseEntity)spawn();
			if (isfunction(strcat("spawnfunc_", strValue))) {
				self = eEnt;
				callfunction(strcat("spawnfunc_", strValue));
				self = eOld;
				iClass = TRUE;
			} else {
				eEnt.classname = strValue;
			}
			break;
		default:
			__fullspawndata = sprintf("%s\"%s\" \"%s\" ",
				__fullspawndata, strField, strValue);
			break;
		}
	}

	return FALSE;
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
	precache_pic("{shot1", TRUE);
	precache_pic("{shot2", TRUE);
	precache_pic("{shot3", TRUE);
	precache_pic("{shot4", TRUE);
	precache_pic("{shot5", TRUE);
	precache_pic("{bigshot1", TRUE);
	precache_pic("{bigshot2", TRUE);
	precache_pic("{bigshot3", TRUE);
	precache_pic("{bigshot4", TRUE);
	precache_pic("{bigshot5", TRUE);
	precache_pic("{scorch1", TRUE);
	precache_pic("{scorch2", TRUE);
	precache_pic("{scorch3", TRUE);

	/* Primarily for the flashlight */
	if (serverkeyfloat("*bspversion") != 30) {
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
			return;
		}
		if (!CSQC_Ent_ParseMapEntity()) {
			print("^1[WARNING] ^7Bad entity data\n");
			return;
		}
	}
	Sky_Update();
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
	
}
