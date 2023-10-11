/*
 * Copyright (c) 2022 Vera Visions LLC.
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

var bool autocvar_r_skipWorld = false;

void
NSView::NSView(void)
{
	m_viewTarget = __NULL__;
	m_vecPosition = [0,0];
	m_vecSize = [0,0];
	m_iSeat = 0;
	m_flFieldOfView = 90.0f;
	m_client = __NULL__;
	m_flSensitivity = 1.0f;
}

void
NSView::SetupView(void)
{
	setproperty(VF_DRAWENGINESBAR, (float)0);
	setproperty(VF_DRAWCROSSHAIR, (float)0);

	if (g_cheats == true)
		setproperty(VF_DRAWWORLD, autocvar_r_skipWorld ? false : true);
	else
		setproperty(VF_DRAWWORLD, (float)1);

	setproperty(VF_ACTIVESEAT, (float)m_iSeat);
	setproperty(VF_MIN, m_vecPosition);
	setproperty(VF_SIZE, m_vecSize);
	setproperty(VF_AFOV, m_flFieldOfView);
	setsensitivityscaler(m_flSensitivity);

	/* if yes, draw everything. */
	if (m_bDrawLocalPlayer)
		setproperty(VF_VIEWENTITY, 0);
	else
		setproperty(VF_VIEWENTITY, player_localentnum);

	/* handle camera override */
	if (pSeat->m_flCameraTime > time || pSeat->m_flCameraTime == -1) {
		setproperty(VF_ORIGIN, pSeat->m_vecCameraOrigin);
		setproperty(VF_CL_VIEWANGLES, pSeat->m_vecCameraAngle);
		setproperty(VF_ANGLES, pSeat->m_vecCameraAngle);
	} else {
		setproperty(VF_ORIGIN, origin);
		//setproperty(VF_CL_VIEWANGLES, angles);
		setproperty(VF_ANGLES, angles);
		pSeat->m_flCameraTime = 0.0f;
	}

	/* the view may not have gotten the chance to set the client angle early on */
	/* honestly this could be handled a lot better, but I don't know of a more reliable solution right now */
	if (m_bSetClientAngle == true || cltime <= 0.5) {
		setproperty(VF_ANGLES, m_vecClientAngle);
		setproperty(VF_CL_VIEWANGLES, m_vecClientAngle);
		m_bSetClientAngle = false;
	}

	m_vecLastOrigin = origin;
}

void
NSView::RenderView(void)
{
	renderscene();
}

void
NSView::SetDrawLocalPlayer(bool choice)
{
	m_bDrawLocalPlayer = choice;
}

void
NSView::StairSmooth(void)
{
	/* don't run this on anything going up or down... */
	if (fabs(m_viewTarget.groundentity.velocity[2]))
		return;

	/* handle stair stepping */
	if (GetViewMode() == VIEWMODE_FPS) {
		vector endpos = origin;

		/* Have we gone up since last frame? */
		if ((m_viewTarget.flags & FL_ONGROUND) && (endpos[2] - m_vecLastOrigin[2] > 0)) {
			endpos[2] = m_vecLastOrigin[2] += (frametime * 150);

			if (endpos[2] > origin[2]) {
				endpos[2] = origin[2];
			}
			if (origin[2] - endpos[2] > 18) {
				endpos[2] = origin[2] - 18;
			}
		}

		// Teleport hack
		if (fabs(origin[2] - m_vecLastOrigin[2]) > 64) {
			endpos[2] = origin[2];
		}

		origin = endpos;
	}
}

void
NSView::SetViewPosition(vector new_pos)
{
	m_vecPosition = new_pos;
}

void
NSView::SetViewSize(vector new_size)
{
	m_vecSize = new_size;
}

void
NSView::SetViewTarget(NSEntity new_target)
{
	m_viewTarget = new_target;
}

void
NSView::SetCameraOrigin(vector new_origin)
{
	origin = new_origin;
}

void
NSView::SetCameraAngle(vector new_angle)
{
	angles = new_angle;
}

vector
NSView::GetCameraOrigin(void)
{
	return origin;
}

vector
NSView::GetCameraAngle(void)
{
	return angles;
}

void
NSView::SetClientAngle(vector new_angle)
{
	m_vecClientAngle = new_angle;
	m_bSetClientAngle = true;
}

void
NSView::SetViewMode(viewmode_t new_mode)
{
	m_viewmode = new_mode;
}

viewmode_t
NSView::GetViewMode(void)
{
	return m_viewmode;
}

void
NSView::SetSeatID(int new_id)
{
	m_iSeat = new_id;
}

void
NSView::SetClientOwner(NSClient new_owner)
{
	m_client = new_owner;
}

void
NSView::SetAFOV(float new_fov)
{
	m_flFieldOfView = new_fov;
}

float
NSView::GetAFOV(void)
{
	return m_flFieldOfView;
}

void
NSView::SetSensitivity(float new_fov)
{
	m_flSensitivity = new_fov;
}

float
NSView::GetSensitivity(void)
{
	return m_flSensitivity;
}

vector
NSView::GetHUDCanvasPos(void)
{
	if (autocvar_cg_hudAspect <= 0) {
		return m_vecPosition;
	} else {
		return [m_vecPosition[0] + ((m_vecSize[0] / 2) - ((m_vecSize[1] * autocvar_cg_hudAspect) / 2)), m_vecPosition[1]];
	}
}

vector
NSView::GetHUDCanvasSize(void)
{
	if (autocvar_cg_hudAspect <= 0) {
		return m_vecSize;
	} else {
		return [m_vecSize[1] * autocvar_cg_hudAspect, m_vecSize[1]];
	}
}

float
NSView::GetViewWidth(void)
{
	return m_vecSize[0];
}

float
NSView::GetViewHeight(void)
{
	return m_vecSize[1];
}

void
NSView::AddPunchAngle(vector vecAdd)
{
	angles += vecAdd;
}

void View_PreDraw();
void View_PostDraw();
void View_DrawViewModel();

void
NSView::UpdateView(void)
{
	player pl = (player)m_viewTarget;
	NSClient cl = (NSClient)m_viewTarget;
	NSClientSpectator spec = (NSClientSpectator)m_viewTarget;
	entity c;

	if (!cl)
		return;

	clearscene();

	/* run preframe code on our viewtarget */
	cl.PreFrame();

	/* update our player seat info with predicted info */
	pSeat->m_vecPredictedOrigin = cl.origin;
	pSeat->m_flPredictedFlags = cl.flags;
	pSeat->m_vecPredictedVelocity = cl.velocity;

	/* put entities into the scene (and call their predraws */
	addentities(MASK_ENGINE);

	/* after predraws we can act upon their new positions */
	switch (GetViewMode()) {
	case VIEWMODE_FPS:
		if (Client_InIntermission()) {
			cl.UpdateIntermissionCam();
		} else {
			if (Client_IsDead(pl)) {
				SetAFOV(cvar("fov"));
				SetSensitivity(1.0f);
				pl.UpdateDeathcam();
			} else {
				SetAFOV(cvar("fov") * pl.viewzoom);
				SetSensitivity(pl.viewzoom);
				cl.UpdateAliveCam();
				StairSmooth();
				View_DrawViewModel();
			}
		}
		break;
	case VIEWMODE_THIRDPERSON:
		break;
	case VIEWMODE_SPECTATING:
		spec = (NSClientSpectator)m_viewTarget;

		switch (spec.spec_mode) {
		case SPECMODE_THIRDPERSON:
			makevectors(view_angles);
			vector vecStart = spec.GetEyePos();
			vecStart[2] += 16;
			vecStart += (v_right * 4);

			vector vecEnd = vecStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
			traceline(vecStart, vecEnd, FALSE, m_viewTarget);

			SetCameraOrigin(trace_endpos + (v_forward * 5));
			SetCameraAngle(view_angles);
			break;
		case SPECMODE_FIRSTPERSON:
			c = findfloat(world, ::entnum, spec.spec_ent);

			if (c.classname == "player") {
				player bp = (player)c;
				removeentity(c);
				SetCameraOrigin(bp.GetEyePos());
				SetCameraAngle(bp.v_angle);
				SetAFOV(cvar("fov") * bp.viewzoom);

				/* 0 means world */
				if (spec.spec_ent) {
					c = findfloat(world, ::entnum, spec.spec_ent);

					/* we found them */
					if (c && c != spec) {
						player ps = (player)c;
						if (ps.health <= 0)
							pl.UpdateDeathcam();
						else
							View_DrawViewModel();
					}
				}
			}
			break;
		default:
			SetCameraOrigin(cl.GetEyePos());
			SetCameraAngle(view_angles);
		}
		break;
	default:
		break;
	}

	View_PreDraw();

	/* prepare our scene properties */
	SetupView();

	/* properties are locked in place, run logic that depends on final values */
	addentities(MASK_GLOWS);
	SkyCamera_Setup(origin);
	XR_UpdateView(m_viewTarget);

	/* render our frame */
	RenderView();
	RenderTarget_Monitor_Update();

	/* all 2D operations happen after this point */
	for (entity b = world; (b = findfloat(b, ::isCSQC, 1));) {
		NSEntity pf = (NSEntity) b;
		pf.postdraw();
	}

	/* the blinding stuff */
	Fade_Update(m_vecPosition[0], m_vecPosition[1], m_vecSize[0], m_vecSize[1]);

	View_PostDraw();

	/* move this into NSClient methods */
	cl.PostFrame();

	if (autocvar(r_showView, 0) == false)
		return;

	Font_DrawText(m_vecPosition + [8,8], "NSView Debug Information", FONT_CON);
	Font_DrawText(m_vecPosition + [8,20], sprintf("Seat: %i", m_iSeat), FONT_CON);
	Font_DrawText(m_vecPosition + [8,32], sprintf("FOV: %d", m_flFieldOfView), FONT_CON);
	Font_DrawText(m_vecPosition + [8,44], sprintf("Origin: %v", origin), FONT_CON);
	Font_DrawText(m_vecPosition + [8,56], sprintf("Angles: %v", angles), FONT_CON);
	Font_DrawText(m_vecPosition + [8,68], sprintf("View-Target: %d", num_for_edict(m_viewTarget)), FONT_CON);
	Font_DrawText(m_vecPosition + [8,80], sprintf("View-Mode: %d", m_viewmode), FONT_CON);
}
