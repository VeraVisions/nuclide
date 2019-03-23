/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void CSQC_Init(float apilevel, string enginename, float engineversion)
{
	pSeat = &seats[0];

	registercommand("vox_test");
	registercommand("+attack2");
	registercommand("-attack2");
	registercommand("+reload");
	registercommand("-reload");
	registercommand("+use");
	registercommand("-use");
	registercommand("+duck");
	registercommand("-duck");
	
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

	/* Fonts */
	FONT_16 = loadfont("16", "fonts/default", "16", -1);
	FONT_CON  = loadfont("font", "", "12", -1);
	FONT_20  = loadfont("cr", "creditsfont?fmt=h", "20", -1);
	drawfont = FONT_CON;

	/* Materials */
	SHADER_CULLED = shaderforname("mirror_cull");

	/* Particles */
	PARTICLE_SPARK 			= particleeffectnum("part_spark");
	PARTICLE_PIECES_BLACK 	= particleeffectnum("part_pieces_black");
	PARTICLE_SMOKE_GREY 	= particleeffectnum("part_smoke_grey");
	PARTICLE_SMOKE_BROWN 	= particleeffectnum("part_smoke_brown");
	PARTICLE_BLOOD 			= particleeffectnum("part_blood");
	DECAL_SHOT 				= particleeffectnum("decal_shot");
	DECAL_GLASS 			= particleeffectnum("decal_glass");

	/* 2D Pics */
	precache_pic("gfx/vgui/icntlk_sv");
	precache_pic("gfx/vgui/icntlk_pl");

	/* GS-Entbase */
	Fade_Init();

	/* VOX */
	Sound_InitVOX();

	/* View */
	View_Init();
	
	/* Effects */
	Effects_Init();
	precache_sound("misc/talk.wav");

	/* Game specific inits */
	HUD_Init();
	Scores_Init();
	Client_Init(apilevel, enginename, engineversion);
	DSP_Init();
}

void CSQC_UpdateView(float w, float h, float focus)
{
	player pl;
	float needcursor;
	int s;

	if (w == 0 || h == 0) {
		return;
	}

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
		pSeat->fVGUI_Display = VGUI_MOTD;
		pSeat->ePlayer = world;
	}

	for (s = numclientseats; s-- > 0;) {
		pSeat = &seats[s];
		
		View_CalcViewport(s, w, h);
		setproperty(VF_ACTIVESEAT, (float)s);

		pSeat->ePlayer = self = findfloat(world, entnum, player_localentnum);
		pl = (player)self;

		Predict_PreFrame((player)self);

		pSeat->vPlayerOrigin = pl.origin;
		pSeat->vPlayerVelocity = pl.velocity;
		pSeat->fPlayerFlags = pl.flags;

		// Render 3D Game Loop
#ifdef CSTRIKE
		Cstrike_PreDraw();
#endif

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
		setsensitivityscaler(pl.viewzoom);
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
			View_DrawViewModel();
		}

		addentities(MASK_ENGINE);
		setproperty(VF_MIN, video_mins);
		setproperty(VF_SIZE, video_res);
		setproperty(VF_ANGLES, view_angles + pSeat->vPunchAngle);
		setproperty(VF_DRAWWORLD, 1);
		renderscene();

		pl.w_attack_next -= clframetime;
		pl.w_idle_next -= clframetime;

		if (pl.w_attack_next <= 0) {
			pl.w_attack_next = 0;
		}
		if (pl.w_idle_next <= 0) {
			pl.w_idle_next = 0;
		}

		View_DropPunchAngle();
		Fade_Update((int)video_mins[0],(int)video_mins[1], (int)w, (int)h);

#ifdef CSTRIKE
		Cstrike_PostDraw((int)video_mins[0],(int)video_mins[1], (int)w, (int)h);
#endif
		View_PostDraw();

		if(focus == TRUE) {
			GameText_Draw();

			// The spectator sees things... differently
			if (getplayerkeyvalue(player_localnum, "*spec") != "0") {
				VGUI_DrawSpectatorHUD();
			} else {
				HUD_Draw();
			}

			///HUD_DrawOrbituaries();
			Voice_DrawHUD();
			Chat_Draw();
			Print_Draw();

			// Don't even try to draw centerprints and VGUI menus when scores are shown
			if (pSeat->iShowScores == TRUE) {
				Scores_Draw();
			} else {
				CSQC_DrawCenterprint();
#ifdef CSTRIKE
				needcursor |= CSQC_VGUI_Draw();
#endif
			}
		}

		Predict_PostFrame((player)self);
	}

	DSP_UpdateListener();
	pSeat = (void*)0x70000000i;

	if (needcursor) {
		setcursormode(TRUE, "gfx/cursor", [0,0,0], 1.0f);
	} else {
		setcursormode(FALSE, "gfx/cursor", [0,0,0], 1.0f);
	}

	Sound_ProcessWordQue();
}

/*
=================
CSQC_InputEvent

Updates all our input related globals for use in other functions
=================
*/
float CSQC_InputEvent(float fEventType, float fKey, float fCharacter, float fDeviceID)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];

	switch (fEventType) {
		case IE_KEYDOWN:
			if (fKey == K_MOUSE1) {
				fMouseClick = 1;
			} else {
				pSeat->fInputKeyDown = 1;
			}

			pSeat->fInputKeyCode = fKey;
			pSeat->fInputKeyASCII = fCharacter;
			break;
		case IE_KEYUP:
			if (fKey == K_MOUSE1) {
				fMouseClick = 0;
			} else {
				pSeat->fInputKeyDown = 0;
			}
			pSeat->fInputKeyCode = 0;
			pSeat->fInputKeyASCII = 0;
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
	return FALSE;
}

/*
=================
CSQC_Input_Frame

Hijacks and controls what input globals are being sent to the server
=================
*/
void CSQC_Input_Frame(void)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];


	// If we are inside a VGUI, don't let the client do stuff outside
	if ((pSeat->fVGUI_Display != VGUI_NONE)) {
		pSeat->fInputSendNext = time + 0.2;
	} else if ((pSeat->fHUDWeaponSelected) && (input_buttons & INPUT_BUTTON0)) {
		HUD_DrawWeaponSelect_Trigger();
		input_buttons = 0;
		pSeat->fInputSendNext = time + 0.2;
	}

	if (pSeat->fInputSendNext > time) {
		input_impulse = 0;
		input_buttons = 0;
		return;
	}
	
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
void CSQC_Parse_Event(void)
{
	/* always 0, unless it was sent with a MULTICAST_ONE or MULTICAST_ONE_R to p2+ */
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];
	
	float fHeader = readbyte();
	
	switch (fHeader) {
		case EV_FADE:
			Fade_Parse();
			break;
		case EV_SPRITE:
			Sprite_ParseEvent();
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
			vector vBloodAngle;
			
			vBloodPos[0] = readcoord();
			vBloodPos[1] = readcoord();
			vBloodPos[2] = readcoord();
			
			vBloodAngle[0] = readcoord();
			vBloodAngle[1] = readcoord();
			vBloodAngle[2] = readcoord();
			
			Effect_CreateBlood(vBloodPos, vBloodAngle);
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

float CSQC_ConsoleCommand(string sCMD)
{
	/* the engine will hide the p1 etc commands... which is fun... */
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];
	
	tokenize(sCMD);
	
	switch (argv(0)) {
	case "+zoomin":
		pSeat->iZoomed = TRUE;
		break;
	case "-zoomin":
		pSeat->iZoomed = FALSE;
		break;
	case "buildcubemaps":
		CMap_Build();
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
		localcmd("impulse 1\n");
		break;
	case "slot2":
		localcmd("impulse 2\n");
		break;
	case "slot3":
		localcmd("impulse 3\n");
		break;
	case "slot4":
		localcmd("impulse 4\n");
		break;
	case "slot5":
		localcmd("impulse 5\n");
		break;
	case "slot6":
		localcmd("impulse 6\n");
		break;
	case "slot7":
		localcmd("impulse 7\n");
		break;
	case "slot8":
		localcmd("impulse 8\n");
		break;
	case "slot9":
		localcmd("impulse 9\n");
		break;
	case "slot10":
		localcmd("impulse 10\n");
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
float CSQC_Parse_CenterPrint(string sMessage)
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
float CSQC_Ent_ParseMapEntity(void)
{
	CBaseEntity eEnt = __NULL__;
	string strField, strValue;
	__fullspawndata = "";
	int iClass = FALSE;

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
				switch (strValue) {
				case "worldspawn":
					eEnt = spawn(worldspawn);
					iClass = TRUE;
					break;
				case "env_sound":
					eEnt = spawn(env_sound);
					iClass = TRUE;
					break;
				case "env_cubemap":
					eEnt = spawn(env_cubemap);
					iClass = TRUE;
					break;
				#ifdef REWOLF
				case "decore_asteroid":
					eEnt = spawn(decore_asteroid);
					iClass = TRUE;
					break;
				case "decore_baboon":
					eEnt = spawn(decore_baboon);
					iClass = TRUE;
					break;
				case "decore_bodygib":
					eEnt = spawn(decore_bodygib);
					iClass = TRUE;
					break;
				case "decore_butterflyflock":
					eEnt = spawn(decore_butterflyflock);
					iClass = TRUE;
					break;
				case "decore_explodable":
					eEnt = spawn(decore_explodable);
					iClass = TRUE;
					break;
				case "decore_foot":
					eEnt = spawn(decore_foot);
					iClass = TRUE;
					break;
				case "decore_goldskull":
					eEnt = spawn(decore_goldskull);
					iClass = TRUE;
					break;
				case "decore_hatgib":
					eEnt = spawn(decore_hatgib);
					iClass = TRUE;
					break;
				case "decore_nest":
					eEnt = spawn(decore_nest);
					iClass = TRUE;
					break;
				case "decore_pteradon":
					eEnt = spawn(decore_pteradon);
					iClass = TRUE;
					break;
				case "decore_torch":
					eEnt = spawn(decore_torch);
					iClass = TRUE;
					break;
				case "decore_spacedebris":
					eEnt = spawn(decore_spacedebris);
					iClass = TRUE;
					break;
				case "decore_swampplants":
					eEnt = spawn(decore_swampplants);
					iClass = TRUE;
					break;
				case "decore_mushroom":
					eEnt = spawn(decore_mushroom);
					iClass = TRUE;
					break;
				case "decore_mushroom2":
					eEnt = spawn(decore_mushroom2);
					iClass = TRUE;
					break;
				#endif
				default:
					eEnt.classname = strValue;
				}
				break;
			default:
				__fullspawndata = sprintf("%s\"%s\" \"%s\" ", __fullspawndata, strField, strValue);
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
void CSQC_WorldLoaded(void)
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
}

void CSQC_RendererRestarted(string rstr)
{
	Sky_Update();
	Game_RendererRestarted(rstr);
}

/*
=================
CSQC_Shutdown

Incase you need to free something
=================
*/
void CSQC_Shutdown(void)
{
	
}
