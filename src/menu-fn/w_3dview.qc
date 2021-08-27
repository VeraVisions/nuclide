
noref .vector angles;
noref .float colormap;
noref .float frame, frame2, lerpfrac, renderflags, frame1time;

enumflags
{
	VIEW_VISIBLE
};

class CUI3DView:CWidget
{
	vector m_vecSize;
	vector m_vec3DPos;
	vector m_vec3DAngles;
	float m_flFOV;

	void(void) CUI3DView;
	virtual void(void) m_vDrawFunc = 0;
	virtual void(float, float, float, float) m_vInputFunc = 0;
	virtual void(void) Draw;
	virtual vector() GetSize;
	virtual vector() Get3DPos;
	virtual vector() Get3DAngles;
	virtual void(vector) SetSize;
	virtual void(vector) Set3DPos;
	virtual void(vector) Set3DAngles;
	virtual void(void(void)) SetDrawFunc;
	virtual void(void(float, float, float, float)) SetInputFunc;
	virtual void(float, float, float, float) Input;
};

void
CUI3DView::CUI3DView(void)
{
	m_flFOV = 90;
	m_vecSize = [64,64];
	m_vec3DPos = m_vec3DAngles = [0,0,0];
}

void
CUI3DView::SetSize(vector vecSize)
{
	m_vecSize = vecSize;
}

vector
CUI3DView::GetSize(void)
{
	return m_vecSize;
}

void
CUI3DView::Set3DAngles(vector vecAngles)
{
	m_vec3DAngles = vecAngles;
}

vector
CUI3DView::Get3DAngles(void)
{
	return m_vec3DAngles;
}

void
CUI3DView::Set3DPos(vector vecPos)
{
	m_vec3DPos = vecPos;
}

vector
CUI3DView::Get3DPos(void)
{
	return m_vec3DPos;
}

void
CUI3DView::SetDrawFunc(void(void) vFunc)
{
	m_vDrawFunc = vFunc;
}

void
CUI3DView::SetInputFunc(void(float, float, float, float) vFunc)
{
	m_vInputFunc = vFunc;
}

void
CUI3DView::Draw(void)
{
	if (!m_vDrawFunc) {
		return;
	}

	clearscene();
	setproperty(VF_VIEWPORT, [m_x + g_menuofs[0],m_y + g_menuofs[1]], m_vecSize);
	setproperty(VF_AFOV, 90);
	setproperty(VF_ORIGIN, m_vec3DPos);
	setproperty(VF_ANGLES, m_vec3DAngles);

	if (m_vDrawFunc) {
		m_vDrawFunc();
		renderscene();
	}
}

void
CUI3DView::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	if (!m_vInputFunc) {
		return;
	}

	m_vInputFunc(flEVType, flKey, flChar, flDevID);
}

/* 3D helper functions */


// menuqc doesn't have access to makevectors... screw you, guys
noref vector v_forward;
noref vector v_up;
noref vector v_right;
void AngleVectors ( vector angles )
{
	float angle;
	float sr, sp, sy, cr, cp, cy;
	
	angle = angles[1] * (M_PI*2 / 360);
	sy = sin(angle);
	cy = cos(angle);
	angle = angles[0] * (M_PI*2 / 360);
	sp = sin(angle);
	cp = cos(angle);
	angle = angles[2] * (M_PI*2 / 360);
	sr = sin(angle);
	cr = cos(angle);

	v_forward[0] = cp*cy;
	v_forward[1] = cp*sy;
	v_forward[2] = -sp;

	v_right[0] = (-1*sr*sp*cy+-1*cr*-sy);
	v_right[1] = (-1*sr*sp*sy+-1*cr*cy);
	v_right[2] = -1*sr*cp;

	v_up[0] = (cr*sp*cy+-sr*-sy);
	v_up[1] = (cr*sp*sy+-sr*cy);
	v_up[2] = cr*cp;
}
