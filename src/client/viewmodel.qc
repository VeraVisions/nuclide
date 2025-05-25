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

var bool autocvar_cg_viewmodelLag = 0;

void
View_Init(void)
{
	for (int s = g_seats.length; s-- > numclientseats;) {
		pSeat = &g_seats[s];
		if(!pSeat->m_eViewModel) {
			/* right side */
			pSeat->m_eViewModel = spawn(ncRenderableEntity);
			pSeat->m_eViewModel.classname = "vm";
			pSeat->m_eViewModel.renderflags = RF_DEPTHHACK | RF_FIRSTPERSON;
			pSeat->m_eViewModel.effects |= EF_NOSHADOW;
			pSeat->m_eViewModel.alpha = 1.0f;
			pSeat->m_eViewModel.drawmask = 0;

			setsize(pSeat->m_eViewModel, [0,0,0], [0,0,0]);

			/* left side */
			pSeat->m_eViewModelL = spawn(ncRenderableEntity);
			pSeat->m_eViewModelL.classname = "vm";
			pSeat->m_eViewModelL.renderflags = RF_DEPTHHACK | RF_FIRSTPERSON;
			pSeat->m_eViewModelL.effects |= EF_NOSHADOW;
			pSeat->m_eViewModelL.alpha = 1.0f;
			pSeat->m_eViewModelL.drawmask = 0;
			setsize(pSeat->m_eViewModelL, [0,0,0], [0,0,0]);
		}
	}
}

void
View_SetMuzzleflash(int index)
{
	ncRenderableEntity viewModel = (ncRenderableEntity)pSeat->m_eViewModelL;
	viewModel.m_iMuzzleModel = (float)index;
	viewModel = (ncRenderableEntity)pSeat->m_eViewModel;
	viewModel.m_iMuzzleModel = (float)index;
}

void
View_AddEvent(void(void) pCallback, float flTime)
{
	pSeat->m_pEventCall = pCallback;
	pSeat->m_flEventTime = flTime;
	pSeat->m_flEventFrame = pSeat->m_eViewModel.frame;
	pSeat->m_flEventMdl = pSeat->m_eViewModel.modelindex;
	ncPlayer pl = (ncPlayer)pSeat->m_ePlayer;
	pSeat->m_iEventEntity = self;
}

void
View_ClearEvents(void)
{
	pSeat->m_pEventCall = __NULL__;
	pSeat->m_flEventTime = 0;
	pSeat->m_flEventFrame = 0;
	pSeat->m_flEventMdl = 0;
	pSeat->m_iEventEntity = __NULL__;

	pSeat->m_eViewModelL.frame1time = 0.0f;
	pSeat->m_eViewModel.frame1time = 0.0f;
}

void
View_CalcViewport(int s, float fWinWidth, float fWinHeight)
{
	switch (numclientseats) {
	case 3:
		if (!s) {
	case 2:
		g_viewSeats[s].SetViewSize([fWinWidth, fWinHeight * 0.5]);
		g_viewSeats[s].SetViewPosition([0, (s & 1) * g_viewSeats[s].GetViewHeight()]);
		break;
		}
		s++;
	case 4:
		g_viewSeats[s].SetViewSize([fWinWidth, fWinHeight] * 0.5);
		g_viewSeats[s].SetViewPosition([(s&1) * g_viewSeats[s].GetViewWidth(), (s / 2i) * g_viewSeats[s].GetViewHeight()]);
		break;
	default:
		g_viewSeats[s].SetViewSize([fWinWidth, fWinHeight]);
		//g_viewSeats[s].SetViewPosition([0, 0]);
		break;
	}

	g_vidsize = g_viewSeats[s].m_vecSize;
	video_mins = g_viewSeats[s].m_vecPosition;
	g_hudmins = g_viewSeats[s].GetHUDCanvasPos();
	g_hudres = g_viewSeats[s].GetHUDCanvasSize();
}

void
View_DrawViewmodel_Single(int weapon, float weapontime)
{
	
}

static void 
View_HandleAnimEvent(float flTimeStamp, int iCode, string strData)
{
	ncWeapon viewModel = (ncWeapon)self;

	if (viewModel)
		viewModel.HandleAnimEvent(flTimeStamp, iCode, strData);
}

void
View_ForceChange(ncPlayer pl, int targetWeapon)
{
	ncRenderableEntity m_eViewModel = (ncRenderableEntity)pSeat->m_eViewModel;
	ncRenderableEntity m_eViewModelL = (ncRenderableEntity)pSeat->m_eViewModelL;
	sendevent("PlayerSwitchWeapon", "i", targetWeapon);
	View_ClearEvents();
	View_DisableViewmodel();
	View_SetMuzzleflash(0);
	m_eViewModel.frame1time = 0.0f;
	m_eViewModelL.frame1time = 0.0f;
}

var float autocvar_cg_gunX = 0.0f;
var float autocvar_cg_gunY = 0.0f;
var float autocvar_cg_gunZ = 0.0f;

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
	vector currentAngle = g_view.GetCameraAngle();
	ncRenderableEntity m_eViewModel = (ncRenderableEntity)pSeat->m_eViewModel;
	ncRenderableEntity m_eViewModelL = (ncRenderableEntity)pSeat->m_eViewModelL;

	if (!m_eViewModel) {
		return;
	}

	ncPlayer pl = __NULL__;
	ncPlayer cl = (ncPlayer)pSeat->m_ePlayer;

	/* it's either us or us spectating */
	if (Client_IsSpectator(cl)) {
		ncSpectator spec = (ncSpectator)pSeat->m_ePlayer;
		pl = (ncPlayer)findfloat(world, ::entnum, spec.m_spectatingEntity);

		if (spec.m_spectatingMode != SPECMODE_FIRSTPERSON) {
			return;
		}
	} else {
		pl = (ncPlayer)pSeat->m_ePlayer;
	}

	if (!pl)
		return;

	float fBaseTime2 = m_eViewModel.frame1time;
	float fBaseTime = m_eViewModel.frame1time;
	m_eViewModelL.frame = m_eViewModel.frame = pl.m_weaponAnimSequence;
	m_eViewModelL.frame1time =
	m_eViewModelL.frame2time =
	m_eViewModel.frame2time =
	m_eViewModel.frame1time = pl.WeaponAnimTime();

	/* used to be View_UpdateWeapon */
	/* only bother upon change */
	/* TODO: MOVE THIS INTO NSWEAPON OR SOMETING */
	if (pSeat->m_iLastWeapon != pl.activeweapon) {
		pSeat->m_iOldWeapon = pSeat->m_iLastWeapon;
		pSeat->m_iLastWeapon = pl.activeweapon;

		if (pl.activeweapon) {
			/* hack, we changed the wep, move this into Game_Input/PMove */
			//Weapons_Draw((ncPlayer)pl);
		} else {
			pSeat->m_eViewModel.modelindex =
			pSeat->m_eViewModelL.modelindex = 0;
		}

		ncRenderableEntity viewModel = (ncRenderableEntity)pSeat->m_eViewModelL;
		viewModel._UpdateBoneCount();
		viewModel = (ncRenderableEntity)pSeat->m_eViewModel;
		viewModel._UpdateBoneCount();
		View_EnableViewmodel();
		View_ClearEvents();
	}

	Event_Callback(m_eViewModel.frame1time, fBaseTime2);

	entity oldSelf = self;
	self = m_eViewModel;
	processmodelevents(m_eViewModel.modelindex, m_eViewModel.frame, fBaseTime,
		m_eViewModel.frame1time, View_HandleAnimEvent);
	self = oldSelf;

	if (pl.health <= 0) {
		return;
	}

	if (pl.vehicle) {
		ncVehicle veh = (ncVehicle)pl.vehicle;

		if (veh.HideViewWeapon() == true)
			return;
	}

	if (cvar("r_drawviewmodel") == 0 || autocvar_pm_thirdPerson == TRUE) {
		return;
	}


	makevectors(currentAngle);

	if (autocvar_cg_viewmodelLag == 0)
		m_eViewModel.angles = currentAngle;
	else {
		float limit;
		float speed;
		makevectors(pSeat->m_vecLag);
		pSeat->m_vecLag = v_forward;
		makevectors(view_angles);

		if (autocvar_cg_viewmodelLag == 2) {
			float pitchfix = fabs(view_angles[0] / 180);
			limit = dotproduct(pSeat->m_vecLag, v_forward) * (1.0 - pitchfix);
			speed = (1.0 - limit) * clframetime;
			speed *= 90;
		} else {
			speed = clframetime * 20;
		}

		pSeat->m_vecLag = vectorLerp(pSeat->m_vecLag, v_forward, speed);
		pSeat->m_vecLag = vectorToAngles(pSeat->m_vecLag);
		m_eViewModel.angles = pSeat->m_vecLag;
	}

	/* apply to the left side */
	m_eViewModelL.angles = m_eViewModel.angles;
	m_eViewModelL.colormap = m_eViewModel.colormap = pSeat->m_ePlayer.colormap;

	/* now apply the scale hack */
	m_eViewModelL.scale = m_eViewModel.scale = autocvar_cg_viewmodelScale;

	if (Client_IsSpectator(cl) || XR_Available(cl) == false) {
		m_eViewModelL.origin = g_view.GetCameraOrigin();
		makevectors(currentAngle);
		m_eViewModelL.origin += (v_forward * cvar("cg_gunX"));
		m_eViewModelL.origin += (v_right * cvar("cg_gunY"));
		m_eViewModelL.origin += (v_up * cvar("cg_gunZ"));
		m_eViewModel.origin = m_eViewModelL.origin;

		if (Client_IsSpectator(cl)) {
			m_eViewModelL.angles = m_eViewModel.angles = currentAngle;
			/* HACK: fool Viewmodel_CalcBob(); */
			pSeat->m_vecPredictedVelocity = pl.velocity;
		}

		/* we only calculate bob on the right model, to avoid double speed bobbing */
		Viewmodel_CalcBob();
		makevectors(currentAngle);
		Viewmodel_ApplyBob(m_eViewModel);
		Viewmodel_ApplyBob(m_eViewModelL);
	} else {
		m_eViewModelL.origin = pl.m_xrInputLeft.GetOrigin();
		m_eViewModel.origin = pl.m_xrInputRight.GetOrigin();
		m_eViewModel.angles = pl.m_xrInputRight.GetAngles();
		m_eViewModelL.angles = pl.m_xrInputLeft.GetAngles();
	}

	if (pl.m_activeWeapon) {
		pl.m_activeWeapon.ClientFX(false);
	}

	/* this is currently broken */
#if 0
	// Left-handed weapons
	if (autocvar_cg_viewmodelFlip) {
		v_right *= -1;
		m_eViewModel.renderflags |= RF_USEAXIS;
		//m_eViewModel.forceshader = SHADER_CULLED;
	} else {
		if (m_eViewModel.forceshader) {
			m_eViewModel.forceshader = 0;
			m_eViewModel.renderflags &= ~RF_USEAXIS;
		}
	}
#endif

	/* only draw the model when it's 'enabled'... */
	if (m_eViewModel.IsHidden() == false) {
		float oldModelindex;
		setorigin(m_eViewModel, m_eViewModel.origin);
		setorigin(m_eViewModelL, m_eViewModel.origin);

		m_eViewModel.SetRenderMode(pl.GetRenderMode());
		m_eViewModel.SetRenderFX(pl.GetRenderFX());
		m_eViewModel.SetRenderColor(pl.GetRenderColor());
		m_eViewModel.SetRenderAmt(pl.GetRenderAmt());

		m_eViewModelL.SetRenderMode(pl.GetRenderMode());
		m_eViewModelL.SetRenderFX(pl.GetRenderFX());
		m_eViewModelL.SetRenderColor(pl.GetRenderColor());
		m_eViewModelL.SetRenderAmt(pl.GetRenderAmt());

		m_eViewModel.RenderFXPass();
		m_eViewModelL.RenderFXPass();

		m_eViewModelL.renderflags = RF_DEPTHHACK | RF_FIRSTPERSON;
		m_eViewModel.renderflags = RF_DEPTHHACK | RF_FIRSTPERSON;


		m_eViewModel.bonecontrol1 = m_eViewModel.m_studioBoneController1;
		m_eViewModel.bonecontrol2 = m_eViewModel.m_studioBoneController2;
		m_eViewModel.bonecontrol3 = m_eViewModel.m_studioBoneController3;
		m_eViewModel.bonecontrol4 = m_eViewModel.m_studioBoneController4;
		m_eViewModel.bonecontrol5 = m_eViewModel.m_studioBoneController5;

		if (m_eViewModel.GetRenderMode() != RM_DONTRENDER || pl.viewzoom < 1.0f) {
			addentity(m_eViewModel);

			/* TODO: clean this up. */
			if (m_eViewModel.modelindex2) {
				oldModelindex = m_eViewModel.modelindex;
				m_eViewModel.modelindex = m_eViewModel.modelindex2;
				addentity(m_eViewModel);
				m_eViewModel.modelindex = oldModelindex;
			}

			if (m_eViewModel.modelindex3) {
				oldModelindex = m_eViewModel.modelindex;
				m_eViewModel.modelindex = m_eViewModel.modelindex3;
				addentity(m_eViewModel);
				m_eViewModel.modelindex = oldModelindex;
			}

			if (m_eViewModel.modelindex4) {
				oldModelindex = m_eViewModel.modelindex;
				m_eViewModel.modelindex = m_eViewModel.modelindex4;
				addentity(m_eViewModel);
				m_eViewModel.modelindex = oldModelindex;
			}
		}
		if (m_eViewModelL.GetRenderMode() != RM_DONTRENDER) {
			addentity(m_eViewModelL);
		}
	}
}

void
View_PreDraw(void)
{
	ClientGame_PreDraw();
}

void
View_PostDraw(void)
{
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
	pSeat->m_eViewModel.frame =
	pSeat->m_eViewModelL.frame = (float)iSequence;
}
void
View_PlayAnimationLeft(int iSequence)
{
	pSeat->m_eViewModelL.frame = (float)iSequence;
}
void
View_PlayAnimationRight(int iSequence)
{
	pSeat->m_eViewModel.frame = (float)iSequence;
}

int
View_GetAnimation(void)
{
	return pSeat->m_eViewModel.frame;
}

void
View_EnableViewmodel(void)
{
	ncRenderableEntity viewModel;
	viewModel = (ncRenderableEntity)pSeat->m_eViewModel;
	viewModel.Show();
	viewModel = (ncRenderableEntity)pSeat->m_eViewModelL;
	viewModel.Show();
}

void
View_DisableViewmodel(void)
{
	ncRenderableEntity viewModel;
	viewModel = (ncRenderableEntity)pSeat->m_eViewModel;
	viewModel.Hide();
	viewModel = (ncRenderableEntity)pSeat->m_eViewModelL;
	viewModel.Hide();
}

void
View_SetViewmodelSkin(float skinValue)
{
	pSeat->m_eViewModel.skin =
	pSeat->m_eViewModelL.skin = skinValue;
}
