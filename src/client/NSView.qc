void
NSView::SetupView(void)
{
	setproperty(VF_DRAWENGINESBAR, 0);
	setproperty(VF_DRAWCROSSHAIR, 0);
	setproperty(VF_DRAWWORLD, 1);
	setproperty(VF_ACTIVESEAT, m_iSeat);
	setproperty(VF_MIN, m_vecPosition);
	setproperty(VF_SIZE, m_vecSize);
	setproperty(VF_AFOV, m_flFieldOfView);

	/* this will hide said entity */
	setproperty(VF_VIEWENTITY, num_for_edict(m_viewTarget));

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