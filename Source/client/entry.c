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
	
	/* Effects */
	precache_sound("debris/bustglass1.wav");
	precache_sound("debris/bustglass2.wav");
	precache_sound("debris/bustglass3.wav");
	precache_sound("debris/bustcrate1.wav");
	precache_sound("debris/bustcrate2.wav");
	precache_sound("debris/bustcrate3.wav");
	precache_sound("debris/bustmetal1.wav");
	precache_sound("debris/bustmetal2.wav");
	precache_sound("debris/bustflesh1.wav");
	precache_sound("debris/bustflesh2.wav");
	precache_sound("debris/bustconcrete1.wav");
	precache_sound("debris/bustconcrete2.wav");
	precache_sound("debris/bustceiling.wav");

	/* Game specific inits */
	HUD_Init();
	Client_Init(apilevel, enginename, engineversion);
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
	
		setproperty(VF_AFOV, cvar("fov") * pl.viewzoom);
		setsensitivityscaler(pl.viewzoom);

		View_Stairsmooth();

		// When Cameratime is active, draw on the forced coords instead
		if (pSeat->fCameraTime > time) {
			setproperty(VF_ORIGIN, pSeat->vCameraPos);
			setproperty(VF_CL_VIEWANGLES, pSeat->vCameraAngle);
		} else {
			if (pl.health) {
				if (autocvar_cl_thirdperson == TRUE ) {
					makevectors(view_angles);
					vector vStart = [pSeat->vPlayerOrigin[0], pSeat->vPlayerOrigin[1], pSeat->vPlayerOrigin[2] + 16] + (v_right * 4);
					vector vEnd = vStart + (v_forward * -48) + '0 0 16' + (v_right * 4);
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
				///VGUI_DrawSpectatorHUD();
			} else {
				HUD_Draw();
			}

			///HUD_DrawOrbituaries();
			Voice_DrawHUD();
			///CSQC_DrawChat();

#ifdef CSTRIKE
			// Don't even try to draw centerprints and VGUI menus when scores are shown
			if (pSeat->iShowScores == TRUE || getstatf(STAT_GAMESTATE) == GAME_OVER) {
				VGUI_Scores_Show();
			} else {
				CSQC_DrawCenterprint();
				needcursor |= CSQC_VGUI_Draw();
			}
#endif
		}

		Predict_PostFrame((player)self);
	}

	pSeat = (void*)0x70000000i;

	if (needcursor) {
		setcursormode(TRUE, "gfx/cursor", '0 0 0', 1.0f);
	} else {
		setcursormode(FALSE, "gfx/cursor", '0 0 0', 1.0f);
	}

	Sound_ProcessWordQue();
	
	CSQC_DrawText([16,16], "THIS IS A TEST.\n", [20,20], [1,1,1], 1.0f, 
					0, FONT_20);
}

/*
=================
CSQC_InputEvent

Updates all our input related globals for use in other functions
=================
*/
float CSQC_InputEvent(float fEventType, float fKey, float fCharacter,
					   float fDeviceID)
{
	switch(fEventType) {
		case IE_KEYDOWN:
			if (fKey == K_MOUSE1) {
				fMouseClick = 1;
			} else {
				fInputKeyDown = 1;
			}

			fInputKeyCode = fKey;
			fInputKeyASCII = fCharacter;
			break;
		case IE_KEYUP:
			if (fKey == K_MOUSE1) {
				fMouseClick = 0;
			} else {
				fInputKeyDown = 0;
			}
			fInputKeyCode = 0;
			fInputKeyASCII = 0;
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

#ifdef CSTRIKE
	// If we are inside a VGUI, don't let the client do stuff outside
	if ((pSeat->fVGUI_Display != VGUI_NONE)) {
		fInputSendNext = time + 0.2;
	} else if ((pSeat->fHUDWeaponSelected) && (input_buttons & INPUT_BUTTON0)) {
		HUD_DrawWeaponSelect_Trigger();
		input_buttons = 0;
		fInputSendNext = time + 0.2;
	}
#endif

	if (fInputSendNext > time) {
		input_impulse = 0;
		input_buttons = 0;
		return;
	}
	
	if (input_impulse == 101) {
		print("This aint Half-Life.\n");
		input_impulse = 0;
	}
	
	if (input_impulse == 201) {
		sendevent("Spraylogo", "");
	}
	
	if (iInputAttack2 == TRUE) {
		input_buttons |= INPUT_BUTTON3;
	} 

	if (iInputReload == TRUE) {
		input_buttons |= INPUT_BUTTON4;
	} 
	
	if (iInputUse == TRUE) {
		input_buttons |= INPUT_BUTTON5;
	} 
	
	if (iInputDuck == TRUE) {
		input_buttons |= INPUT_BUTTON8;
	}
	
	input_angles += pSeat->vPunchAngle;
}


/*
=================
CSQC_Parse_Event

Whenever we call a SVC_CGAMEPACKET on the SSQC, this is being run
=================
*/
void CSQC_Parse_Event(void) {
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
			vSparkPos_x = readcoord();
			vSparkPos_y = readcoord();
			vSparkPos_z = readcoord();
			vSparkAngle_x = readcoord();
			vSparkAngle_y = readcoord();
			vSparkAngle_z = readcoord();
			Effect_CreateSpark(vSparkPos, vSparkAngle);
			break;
		case EV_EXPLOSION:
			vector vExploPos;
			
			vExploPos_x = readcoord();
			vExploPos_y = readcoord();
			vExploPos_z = readcoord();
			
			Effect_CreateExplosion(vExploPos);
			break;
		case EV_MODELGIB:
			vector vPos;
			vPos_x = readcoord();
			vPos_y = readcoord();
			vPos_z = readcoord();
			
			vector vSize;
			vSize_x = readcoord();
			vSize_y = readcoord();
			vSize_z = readcoord();

			float fStyle = readbyte();
			Effect_BreakModel(vPos, vSize, '0 0 0', fStyle);
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
			vOrigin_x = readcoord();
			vOrigin_y = readcoord();
			vOrigin_z = readcoord();

			vNormal_x = readcoord();
			vNormal_y = readcoord();
			vNormal_z = readcoord();
			
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
		case "vox_test":
			Sound_PlayVOX(sCMD);
			break;
		case "+attack2":
			iInputAttack2 = TRUE;
			break;
		case "-attack2":
			iInputAttack2 = FALSE;
			break;
		case "+reload":
			iInputReload = TRUE;
			break;
		case "-reload":
			iInputReload = FALSE;
			break;
		case "+use":
			iInputUse = TRUE;
			break;
		case "-use":
			iInputUse = FALSE;
			break;
		case "+duck":
			iInputDuck = TRUE;
			break;
		case "-duck":
			iInputDuck = FALSE;
			break;
		default:
			return Game_ConsoleCommand();
	}
	return TRUE;
}

/*
=================
CSQC_WorldLoaded

Whenever the world is fully initialized...
=================
*/
void CSQC_WorldLoaded(void)
{
	
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
