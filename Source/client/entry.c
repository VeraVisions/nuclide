/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void CSQC_UpdateView(float w, float h, float focus)
{
	float needcursor;
	int s;

	if (w == 0 || h == 0) {
		return;
	}

	vVideoResolution_x = w;
	vVideoResolution_y = h;

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
		
		CSQC_CalcViewport(s, w, h);
		setproperty(VF_ACTIVESEAT, (float)s);

		pSeat->ePlayer = self = findfloat(world, entnum, player_localentnum);
		if (self) {
			Player_PreUpdate();
		}
		
		pSeat->vPlayerOrigin = self.origin;
		pSeat->vPlayerVelocity = self.velocity;
		pSeat->fPlayerFlags = self.flags;

		// Render 3D Game Loop
#ifdef CSTRIKE
		Cstrike_PreDraw();
#endif

		// Don't hide the player entity
		if (autocvar_cl_thirdperson == TRUE && getstatf(STAT_HEALTH)) {
			setproperty(VF_VIEWENTITY, (float)0);
		} else {
			setproperty(VF_VIEWENTITY, (float)player_localentnum);
		}
	
		setproperty(VF_AFOV, cvar("fov") * (getstatf(STAT_VIEWZOOM)));
		setsensitivityscaler((getstatf(STAT_VIEWZOOM)));

		View_Stairsmooth();

		// When Cameratime is active, draw on the forced coords instead
		if (pSeat->fCameraTime > time) {
			setproperty(VF_ORIGIN, pSeat->vCameraPos);
			setproperty(VF_CL_VIEWANGLES, pSeat->vCameraAngle);
		} else {
			if (getstatf(STAT_HEALTH)) {
				if (autocvar_cl_thirdperson == TRUE ) {
					makevectors(view_angles);
					vector vStart = [pSeat->vPlayerOrigin[0], pSeat->vPlayerOrigin[1], pSeat->vPlayerOrigin[2] + 16] + (v_right * 4);
					vector vEnd = vStart + (v_forward * -48) + '0 0 16' + (v_right * 4);
					traceline(vStart, vEnd, FALSE, self);
					setproperty(VF_ORIGIN, trace_endpos + (v_forward * 5));
				} else {
					setproperty(VF_ORIGIN, pSeat->vPlayerOrigin + self.view_ofs);
				}
			} else {
				setproperty(VF_ORIGIN, pSeat->vPlayerOrigin);
			}
			View_DrawViewModel();
		}

		addentities(MASK_ENGINE);
		setproperty(VF_MIN, vVideoMins);
		setproperty(VF_SIZE, vVideoResolution);
		setproperty(VF_ANGLES, view_angles + pSeat->vPunchAngle);
		setproperty(VF_DRAWWORLD, 1);
		renderscene();

		View_DropPunchAngle();
		Fade_Update((int)vVideoMins[0],(int)vVideoMins[1], (int)w, (int)h);
#ifdef CSTRIKE
		Cstrike_PostDraw((int)vVideoMins[0],(int)vVideoMins[1], (int)w, (int)h);
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

			HUD_DrawOrbituaries();
			HUD_DrawVoice();
			CSQC_DrawChat();

			// Don't even try to draw centerprints and VGUI menus when scores are shown
			if (pSeat->iShowScores == TRUE || getstatf(STAT_GAMESTATE) == GAME_OVER) {
				VGUI_Scores_Show();
			} else {
				CSQC_DrawCenterprint();
				needcursor |= CSQC_VGUI_Draw();
			}
		}

		if (self) {
			Player_ResetPrediction();
		}
	}

	pSeat = (void*)0x70000000i;

	if (needcursor) {
		setcursormode(TRUE, "gfx/cursor", '0 0 0', 1.0f);
	} else {
		setcursormode(FALSE, "gfx/cursor", '0 0 0', 1.0f);
	}

	Sound_ProcessWordQue();
}
