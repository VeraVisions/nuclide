/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void View_Init(void)
{
#ifdef CSTRIKE
	string wm;
	for (int i = 0; i < (CS_WEAPON_COUNT - 1); i++) {
		wm = sprintf("models/%s", sViewModels[i]);
		precache_model(wm);
	}
#endif

	for (int s = seats.length; s-- > numclientseats;) {
		pSeat = &seats[s];
		if(!pSeat->eViewModel) {
			pSeat->eViewModel = spawn();
			pSeat->eViewModel.classname = "vm";
			pSeat->eViewModel.renderflags = RF_DEPTHHACK;
			
			pSeat->eMuzzleflash = spawn();
			pSeat->eMuzzleflash.classname = "mflash";
			pSeat->eMuzzleflash.renderflags = RF_ADDITIVE;
		}
	}
}

void View_CalcViewport(int s, float fWinWidth, float fWinHeight)
{
	//FIXME: this is awkward. renderscene internally rounds to pixels.
	//on the other hand, drawpic uses linear filtering and multisample and stuff.
	//this means that there can be a pixel or so difference between scene and 2d.
	//as a general rule, you won't notice unless there's some big drawfills.
	switch (numclientseats) {
	case 3:
		if (!s) {
	case 2:
		video_res = [fWinWidth, fWinHeight * 0.5];
		video_mins = [0, (s & 1) * video_res[1]];
		break;
		}
		s++;
	case 4:
		video_res = [fWinWidth, fWinHeight] * 0.5;
		video_mins = [(s&1) * video_res[0], (s / 2i) * video_res[1]];
		break;
	default:
		video_res = [fWinWidth, fWinHeight];
		video_mins = [0, 0];
		break;
	}
}

/*
====================
View_CalcBob
====================
*/
void View_CalcBob(void)
{
	float cycle;

	vector vel;
	
	if (self.flags & FL_ONGROUND == -1) {
		return;	
	}

	pSeat->fBobTime += clframetime;
	cycle = pSeat->fBobTime - (int)(pSeat->fBobTime / autocvar_v_bobcycle) * autocvar_v_bobcycle;
	cycle /= autocvar_v_bobcycle;
	
	if (cycle < autocvar_v_bobup) {
		cycle = MATH_PI * cycle / autocvar_v_bobup;
	} else {
		cycle = MATH_PI + MATH_PI * (cycle - autocvar_v_bobup)/(1.0 - autocvar_v_bobup);
	}

	vel = pSeat->vPlayerVelocity;
	vel_z = 0;

	float fBob = sqrt(vel_x * vel_x + vel_y * vel_y) * autocvar_v_bob;
	fBob = fBob * 0.3 + fBob * 0.7 * sin(cycle);
	pSeat->fBob = bound(-7, fBob, 4);
}

/*
====================
View_DropPunchAngle

Quickly lerp to the original viewposition
====================
*/
void View_DropPunchAngle(void)
{
	float lerp;
	lerp = 1.0f - (clframetime * 4);
	pSeat->vPunchAngle *= lerp;
}

/*
====================
View_AddPunchAngle

Gives the angle a bit of an offset/punch/kick
====================
*/
void View_AddPunchAngle(vector add)
{
	pSeat->vPunchAngle /*+*/= add;
}

/*
====================
View_DrawViewModel

Really convoluted function that makes the gun,
muzzleflash, dynamic lights and so on appear
====================
*/
void View_DrawViewModel(void)
{
	entity eViewModel = pSeat->eViewModel;
	entity eMuzzleflash = pSeat->eMuzzleflash;
	
	player pl = (player) self;

	if (pl.health <= 0) {
		return;
	}
	
	if (cvar("r_drawviewmodel") == 0) {
		return;
	}

	// Don't update when paused
	if (serverkeyfloat("pausestate") == 0) {
		View_CalcBob();
		View_UpdateWeapon(eViewModel, eMuzzleflash);
		float fBaseTime = eViewModel.frame1time;
		eViewModel.frame1time += clframetime;
		eViewModel.frame2time += clframetime;
		processmodelevents(eViewModel.modelindex, eViewModel.frame, fBaseTime, eViewModel.frame1time, Event_ProcessModel);
	}
	
	makevectors(view_angles);
	eViewModel.angles = view_angles;
	eViewModel.origin = pSeat->vPlayerOrigin + pl.view_ofs;
	eViewModel.origin += [0,0,-1] + (v_forward * (pSeat->fBob * 0.4))
			+ (v_forward * autocvar_v_gunofs[0])
			+ (v_right * autocvar_v_gunofs[1])
			+ (v_up * autocvar_v_gunofs[2]);
	
	// Left-handed weapons
	if (autocvar_v_lefthanded) {
		v_right *= -1;
		eViewModel.renderflags |= RF_USEAXIS;
		eViewModel.forceshader = SHADER_CULLED;
	} else {
		if (eViewModel.forceshader) {
			eViewModel.forceshader = 0;
			eViewModel.renderflags -= RF_USEAXIS;
		}
	}
	
	// Give the gun a tilt effect like in old HL/CS versions
	if (autocvar_v_bobclassic == 1) {
		eViewModel.angles_z = -pSeat->fBob;
	}

	// Only bother when zoomed out
	if (pl.viewzoom == 1.0f) {
		// Update muzzleflash position and draw it
		if (eMuzzleflash.alpha > 0.0f) {
			makevectors(getproperty(VF_ANGLES));
			eMuzzleflash.origin = gettaginfo(eViewModel, eMuzzleflash.skin);
			dynamiclight_add(pSeat->vPlayerOrigin + (v_forward * 32), 400 * eMuzzleflash.alpha, [1,0.45,0]);
			addentity(eMuzzleflash);
		}
		addentity(eViewModel);
	}
}

void View_PostDraw(void)
{
	entity eMuzzleflash = pSeat->eMuzzleflash;

	// Take away alpha once it has drawn fully at least once
	if (eMuzzleflash.alpha > 0.0f) {
		eMuzzleflash.alpha -= (clframetime * 16);			
	}
}

void View_Stairsmooth(void)
{
	vector currentpos = pSeat->vPlayerOrigin;
	vector endpos = currentpos;
	static vector oldpos;

	/* Have we gone up since last frame? */
	if ((pSeat->fPlayerFlags & FL_ONGROUND) && (endpos[2] - oldpos[2] > 0)) {
		endpos[2] = oldpos[2] += (frametime * 150);

		if (endpos[2] > currentpos[2]) {
			endpos[2] = currentpos[2];
		}
		if (currentpos[2] - endpos[2] > 18) {
			endpos[2] = currentpos[2] - 18;
		}
	}

	// Teleport hack
	if (fabs(currentpos[2] - oldpos[2]) > 64) {
		endpos[2] = currentpos[2];
	}

	//setproperty(VF_ORIGIN, endpos);
	pSeat->vPlayerOrigin = endpos;
	oldpos = endpos;
}

/*
====================
View_PlayAnimation

Resets the timeline and plays a new sequence
onto the view model
====================
*/
void View_PlayAnimation(int iSequence)
{
	pSeat->eViewModel.frame = (float)iSequence;
	pSeat->eViewModel.frame1time = 0.0f;
}
