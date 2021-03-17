/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

var int autocvar_v_camroll = TRUE;

void
View_Init(void)
{
	for (int s = g_seats.length; s-- > numclientseats;) {
		pSeat = &g_seats[s];
		if(!pSeat->m_eViewModel) {
			pSeat->m_eViewModel = spawn();
			pSeat->m_eViewModel.classname = "vm";
			pSeat->m_eViewModel.renderflags = RF_DEPTHHACK;
			pSeat->m_eViewModel.effects |= EF_NOSHADOW;

			pSeat->m_eMuzzleflash = spawn();
			pSeat->m_eMuzzleflash.classname = "mflash";
			pSeat->m_eMuzzleflash.renderflags = RF_ADDITIVE;
			pSeat->m_eMuzzleflash.effects |= EF_NOSHADOW;
			pSeat->m_pWeaponFX = spawn(CBaseFX);
		}
	}

	/* there's also muzzleflash.spr, but that's just MUZZLE_SMALL again */
	MUZZLE_RIFLE = (int)getmodelindex("sprites/muzzleflash1.spr");
	MUZZLE_SMALL = (int)getmodelindex("sprites/muzzleflash2.spr");
	MUZZLE_WEIRD = (int)getmodelindex("sprites/muzzleflash3.spr");
}

void
View_SetMuzzleflash(int index)
{
	pSeat->m_eMuzzleflash.modelindex = (float)index;
}

void 
View_CalcViewport(int s, float fWinWidth, float fWinHeight)
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

	/* generate usable hud variables */
	if (autocvar_cl_hudaspect <= 0) {
		g_hudmins = video_mins;
		g_hudres = video_res;
	} else {
		g_hudmins = video_mins;
		g_hudmins[0] += (video_res[0] / 2) - ((video_res[1] * autocvar_cl_hudaspect) / 2);
		g_hudres[0] = video_res[1] * autocvar_cl_hudaspect;
		g_hudres[1] = video_res[1];
	}
}

void
View_CalcBob(void)
{
	float cycle;
	vector vel;

	if (self.flags & FL_ONGROUND == -1) {
		return;	
	}

	pSeat->m_flBobTime += clframetime;
	cycle = pSeat->m_flBobTime - (int)(pSeat->m_flBobTime / autocvar_v_bobcycle) * autocvar_v_bobcycle;
	cycle /= autocvar_v_bobcycle;
	
	if (cycle < autocvar_v_bobup) {
		cycle = MATH_PI * cycle / autocvar_v_bobup;
	} else {
		cycle = MATH_PI + MATH_PI * (cycle - autocvar_v_bobup)/(1.0 - autocvar_v_bobup);
	}

	vel = pSeat->m_vecPredictedVelocity;
	vel[2] = 0;

	float flBob = sqrt(vel[0] * vel[0] + vel[1] * vel[1]) * autocvar_v_bob;
	flBob = flBob * 0.3 + flBob * 0.7 * sin(cycle);
	pSeat->m_flBob = bound(-7, flBob, 4);
}

float
View_CalcRoll(void)
{
	float roll;
	makevectors(view_angles);

	roll = dotproduct(pSeat->m_vecPredictedVelocity, v_right);
	roll *= 0.015f;
	return autocvar_v_camroll ? roll : 0;
}

/*
====================
View_DrawViewModel

Really convoluted function that makes the gun,
muzzleflash, dynamic lights and so on appear
====================
*/
void
View_DrawViewModel(void)
{
	entity m_eViewModel = pSeat->m_eViewModel;
	entity m_eMuzzleflash = pSeat->m_eMuzzleflash;
	
	player pl = (player) self;

	if (pl.health <= 0) {
		return;
	}

	if (cvar("r_drawviewmodel") == 0 || autocvar_cl_thirdperson == TRUE) {
		return;
	}

	View_CalcBob();
	View_UpdateWeapon(m_eViewModel, m_eMuzzleflash);
	float fBaseTime = m_eViewModel.frame1time;
	m_eViewModel.frame2time = pl.weapontime;
    	m_eViewModel.frame1time = pl.weapontime;
	processmodelevents(m_eViewModel.modelindex, m_eViewModel.frame, fBaseTime,
		m_eViewModel.frame1time, ClientGame_ModelEvent);

	makevectors(view_angles);
	m_eViewModel.angles = view_angles;

	// Give the gun a tilt effect like in old HL/CS versions
	if (autocvar_v_bobclassic == 1) {
		m_eViewModel.angles[2] = -pSeat->m_flBob;
	}

	/* now apply the scale hack */
	m_eViewModel.scale = autocvar_r_viewmodelscale;
	pSeat->m_flBob *= autocvar_r_viewmodelscale;

	m_eViewModel.origin = pSeat->m_vecPredictedOrigin + pl.view_ofs;
	m_eViewModel.origin += [0,0,-1] + (v_forward * (pSeat->m_flBob * 0.4))
			+ (v_forward * autocvar_v_gunofs[0])
			+ (v_right * autocvar_v_gunofs[1])
			+ (v_up * autocvar_v_gunofs[2]);

	// Left-handed weapons
	if (autocvar_v_lefthanded) {
		v_right *= -1;
		m_eViewModel.renderflags |= RF_USEAXIS;
		//m_eViewModel.forceshader = SHADER_CULLED;
	} else {
		if (m_eViewModel.forceshader) {
			m_eViewModel.forceshader = 0;
			m_eViewModel.renderflags &= ~RF_USEAXIS;
		}
	}

	// Only bother when zoomed out
	if (pl.viewzoom == 1.0f) {
		// Update muzzleflash position and draw it
		if (m_eMuzzleflash.alpha > 0.0f) {
			makevectors(getproperty(VF_ANGLES));
			m_eMuzzleflash.origin = gettaginfo(m_eViewModel, m_eMuzzleflash.skin);
			/*dynamiclight_add(pSeat->m_vecPredictedOrigin + (v_forward * 32), 400 * m_eMuzzleflash.alpha, [1,0.45,0]);*/
			
			setorigin(m_eMuzzleflash, m_eMuzzleflash.origin);
			addentity(m_eMuzzleflash);
		}
		setorigin(m_eViewModel, m_eViewModel.origin);
		addentity(m_eViewModel);
	}

	if (pl.movetype == MOVETYPE_WALK) {
		view_angles[2] = View_CalcRoll();
		setproperty(VF_ANGLES, view_angles + pl.punchangle);
	}
}

void
View_Stairsmooth(void)
{
	vector currentpos = pSeat->m_vecPredictedOrigin;
	vector endpos = currentpos;
	static vector oldpos;

	/* Have we gone up since last frame? */
	if ((pSeat->m_flPredictedFlags & FL_ONGROUND) && (endpos[2] - oldpos[2] > 0)) {
		endpos[2] = oldpos[2] += (clframetime * 150);

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
	pSeat->m_vecPredictedOrigin = endpos;
	oldpos = endpos;
}


void
View_PreDraw(void)
{
	ClientGame_PreDraw();
	View_Stairsmooth();
}

void
View_PostDraw(void)
{
	entity m_eMuzzleflash = pSeat->m_eMuzzleflash;

	// Take away alpha once it has drawn fully at least once
	if (m_eMuzzleflash.alpha > 0.0f) {
		m_eMuzzleflash.alpha -= (clframetime * 16);
	}

	ClientGame_PostDraw();
}

/*
====================
View_PlayAnimation

Resets the timeline and plays a new sequence
onto the view model
====================
*/
void
View_PlayAnimation(int iSequence)
{
	pSeat->m_eViewModel.frame = (float)iSequence;
	player pl = (player)pSeat->m_ePlayer;
	pl.weapontime = 0.0f;
}

int
View_GetAnimation(void)
{
	return pSeat->m_eViewModel.frame;
}
