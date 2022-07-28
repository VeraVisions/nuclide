void
NSView::SetupView(void)
{
	setproperty(VF_DRAWENGINESBAR, 0);
	setproperty(VF_DRAWCROSSHAIR, 0);
	setproperty(VF_DRAWWORLD, 1);
	setproperty(VF_ACTIVESEAT, (float)m_iSeat);
	setproperty(VF_MIN, m_vecPosition);
	setproperty(VF_SIZE, m_vecSize);
	setproperty(VF_AFOV, m_flFieldOfView);

	/* this will hide said entity */
	setproperty(VF_VIEWENTITY, player_localentnum);

	setproperty(VF_ORIGIN, origin);
	//setproperty(VF_CL_VIEWANGLES, angles);
	setproperty(VF_ANGLES, angles);
}

void
NSView::RenderView(void)
{
	renderscene();
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
NSView::SetViewMode(viewmode_e new_mode)
{
	m_viewmode = new_mode;
}

viewmode_e
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

vector
NSView::GetHUDCanvasPos(void)
{
	if (autocvar_cl_hudaspect <= 0) {
		return m_vecPosition;
	} else {
		return [m_vecPosition[0] + ((m_vecSize[0] / 2) - ((m_vecSize[1] * autocvar_cl_hudaspect) / 2)), m_vecPosition[1]];
	}
}

vector
NSView::GetHUDCanvasSize(void)
{
	if (autocvar_cl_hudaspect <= 0) {
		return m_vecSize;
	} else {
		return [m_vecSize[1] * autocvar_cl_hudaspect, m_vecSize[1]];
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

void View_PreDraw();
void View_PostDraw();
void View_DrawViewModel();
void Chat_Draw();
void Print_Draw();
void GameText_Draw();
void Voice_DrawHUD();
void Print_DrawCenterprint();
int VGUI_Draw();

void
NSView::Render2D(void)
{
	Fade_Update(m_vecPosition[0], m_vecPosition[1], m_vecSize[0], m_vecSize[1]);
}

void
NSView::UpdateView(void)
{
	player pl = (player)m_viewTarget;
	NSClient cl = (NSClient)m_viewTarget;
	NSClientSpectator spec = (NSClientSpectator)m_viewTarget;
	entity c;

	if (!cl)
		return;

	/* run preframe code on our viewtarge */
	cl.PreFrame();

	/* some mods use this */
	View_PreDraw();

	/* put entities into the scene (and call their predraws */
	addentities(MASK_ENGINE);

	/* after predraws we can act upon their new positions */
	switch (GetViewMode()) {
	case VIEWMODE_FPS:
		cl.UpdateAliveCam();

		if (Client_InIntermission()) {
			cl.UpdateIntermissionCam();
		}

		pSeat->m_vecPredictedOrigin = cl.GetEyePos();
		SetCameraOrigin(cl.GetEyePos());
		SetCameraAngle(view_angles);

		if (Client_IsDead(pl))
			pl.UpdateDeathcam();
		else
			View_DrawViewModel();

		
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
			}
			break;
		default:
			SetCameraOrigin(cl.GetEyePos());
		}

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
		break;
	default:
		break;
	}

	if (pSeat->m_flCameraTime > time || pSeat->m_flCameraTime == -1) {

	} else {

	}


	addentities(MASK_GLOWS);
	//setproperty(VF_DRAWWORLD, 1);
	SkyCamera_Setup(getproperty(VF_ORIGIN));
	XR_UpdateView(m_viewTarget);

	/* this is running whenever we're doing 'buildcubemaps' */
	if (g_iCubeProcess == TRUE) {
		//setproperty(VF_ORIGIN, g_vecCubePos);
		//setproperty(VF_SIZE_X, g_dCubeSize);
		//setproperty(VF_SIZE_Y, g_dCubeSize);
		//setproperty(VF_AFOV, 90);
	}

	/* render the scene, then put monitor RenderTargets on top */
	SetupView();
	RenderView();
	RenderTarget_Monitor_Update();

	if (g_iCubeProcess == TRUE) {
		cl.PostFrame();
		return;
	}

	/* all 2D operations happen after this point */
	for (entity b = world; (b = findfloat(b, ::isCSQC, 1));) {
		NSEntity pf = (NSEntity) b;
		pf.postdraw();
	}

	Render2D();

	View_PostDraw();

	/* move this into NSClient methods */
	cl.PostFrame();
}

void
NSView::NSView(void)
{
	m_viewTarget = __NULL__;
	m_vecPosition = [0,0];
	m_vecSize = [0,0];
	m_iSeat = 0;
	m_flFieldOfView = 90.0f;
	m_client = __NULL__;
}