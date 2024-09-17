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
			pSeat->m_eViewModel = spawn(NSRenderableEntity);
			pSeat->m_eViewModel.classname = "vm";
			pSeat->m_eViewModel.renderflags = RF_DEPTHHACK | RF_FIRSTPERSON;
			pSeat->m_eViewModel.effects |= EF_NOSHADOW;
			pSeat->m_eViewModel.alpha = 1.0f;
			pSeat->m_eViewModel.drawmask = 0;

			setsize(pSeat->m_eViewModel, [0,0,0], [0,0,0]);

			/* left side */
			pSeat->m_eViewModelL = spawn(NSRenderableEntity);
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
	NSRenderableEntity viewModel = (NSRenderableEntity)pSeat->m_eViewModelL;
	viewModel.m_iMuzzleModel = (float)index;
	viewModel = (NSRenderableEntity)pSeat->m_eViewModel;
	viewModel.m_iMuzzleModel = (float)index;
}

void
View_AddEvent(void(void) pCallback, float flTime)
{
	pSeat->m_pEventCall = pCallback;
	pSeat->m_flEventTime = flTime;
	pSeat->m_flEventFrame = pSeat->m_eViewModel.frame;
	pSeat->m_flEventMdl = pSeat->m_eViewModel.modelindex;
	NSClientPlayer pl = (NSClientPlayer)pSeat->m_ePlayer;
	pSeat->m_iEventWeapon = pl.activeweapon;
}

void
View_ClearEvents(void)
{
	pSeat->m_pEventCall = __NULL__;
	pSeat->m_flEventTime = 0;
	pSeat->m_flEventFrame = 0;
	pSeat->m_flEventMdl = 0;
	pSeat->m_iEventWeapon = 0;

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
	NSRenderableEntity viewModel = (NSRenderableEntity)self;
	viewModel.HandleAnimEvent(flTimeStamp, iCode, strData);
}

void
View_ForceChange(NSClientPlayer pl, int targetWeapon)
{
	NSRenderableEntity m_eViewModel = (NSRenderableEntity)pSeat->m_eViewModel;
	NSRenderableEntity m_eViewModelL = (NSRenderableEntity)pSeat->m_eViewModelL;
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
	NSRenderableEntity m_eViewModel = (NSRenderableEntity)pSeat->m_eViewModel;
	NSRenderableEntity m_eViewModelL = (NSRenderableEntity)pSeat->m_eViewModelL;

	NSClientPlayer pl = __NULL__;
	NSClient cl = (NSClient)pSeat->m_ePlayer;

	/* it's either us or us spectating */
	if (Client_IsSpectator(cl)) {
		NSClientSpectator spec = (NSClientSpectator)pSeat->m_ePlayer;
		pl = (NSClientPlayer)findfloat(world, ::entnum, spec.spec_ent);

		if (spec.spec_mode != SPECMODE_FIRSTPERSON)
			return;
	} else {
		pl = (NSClientPlayer)pSeat->m_ePlayer;
	}

	if (!pl)
		return;

	if (pl.health <= 0) {
		return;
	}

	if (pl.vehicle) {
		NSVehicle veh = (NSVehicle)pl.vehicle;

		if (veh.HideViewWeapon() == true)
			return;
	}

	if (cvar("r_drawviewmodel") == 0 || autocvar_pm_thirdPerson == TRUE) {
		return;
	}

	/* used to be View_UpdateWeapon */
	/* only bother upon change */
	/* TODO: MOVE THIS INTO NSWEAPON OR SOMETING */
	if (pSeat->m_iLastWeapon != pl.activeweapon) {
		pSeat->m_iOldWeapon = pSeat->m_iLastWeapon;
		pSeat->m_iLastWeapon = pl.activeweapon;

		if (pl.activeweapon) {
			/* hack, we changed the wep, move this into Game_Input/PMove */
			//Weapons_Draw((NSClientPlayer)pl);
		} else {
			pSeat->m_eViewModel.modelindex =
			pSeat->m_eViewModelL.modelindex = 0;
		}

		NSRenderableEntity viewModel = (NSRenderableEntity)pSeat->m_eViewModelL;
		viewModel._UpdateBoneCount();
		viewModel = (NSRenderableEntity)pSeat->m_eViewModel;
		viewModel._UpdateBoneCount();
		View_EnableViewmodel();
		View_ClearEvents();
	}

	float fBaseTime2 = m_eViewModel.frame1time;
	float fBaseTime = m_eViewModel.frame1time;
	m_eViewModelL.frame = m_eViewModel.frame = pl.weaponframe;
	m_eViewModelL.frame1time =
	m_eViewModelL.frame2time =
	m_eViewModel.frame2time =
	m_eViewModel.frame1time = pl.weapontime;
	Event_Callback(m_eViewModel.frame1time, fBaseTime2);

	entity oldSelf = self;
	self = m_eViewModel;
	processmodelevents(m_eViewModel.modelindex, m_eViewModel.frame, fBaseTime,
		m_eViewModel.frame1time, View_HandleAnimEvent);
	self = oldSelf;

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

		if (m_eViewModel.GetRenderMode() != RM_DONTRENDER) {
			addentity(m_eViewModel);

			/* TODO: clean this up. */
			if (m_eViewModel.modelindex2) {
				float oldModelindex = m_eViewModel.modelindex;
				m_eViewModel.modelindex = m_eViewModel.modelindex2;
				addentity(m_eViewModel);
				m_eViewModel.modelindex = oldModelindex;
			}

			if (m_eViewModel.modelindex3) {
				float oldModelindex = m_eViewModel.modelindex;
				m_eViewModel.modelindex = m_eViewModel.modelindex3;
				addentity(m_eViewModel);
				m_eViewModel.modelindex = oldModelindex;
			}

			if (m_eViewModel.modelindex4) {
				float oldModelindex = m_eViewModel.modelindex;
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
	NSRenderableEntity viewModel;
	viewModel = (NSRenderableEntity)pSeat->m_eViewModel;
	viewModel.Show();
	viewModel = (NSRenderableEntity)pSeat->m_eViewModelL;
	viewModel.Show();
}

void
View_DisableViewmodel(void)
{
	NSRenderableEntity viewModel;
	viewModel = (NSRenderableEntity)pSeat->m_eViewModel;
	viewModel.Hide();
	viewModel = (NSRenderableEntity)pSeat->m_eViewModelL;
	viewModel.Hide();
}

void
View_SetViewmodelSkin(float skinValue)
{
	pSeat->m_eViewModel.skin =
	pSeat->m_eViewModelL.skin = skinValue;
}
