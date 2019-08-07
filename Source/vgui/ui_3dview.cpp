/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	VIEW_VISIBLE
};

class CUI3DView : CUIWidget
{
	vector m_vecSize;
	vector m_vec3DPos;
	vector m_vec3DAngles;
	float m_flFOV;
	
	void() CUI3DView;
	virtual void() m_vDrawFunc = 0;
	virtual void( float, float, float, float ) m_vInputFunc = 0;
	virtual void() Draw;
	virtual void( vector ) SetSize;
	virtual vector() GetSize;
	virtual void( vector ) Set3DAngles;
	virtual vector() Get3DAngles;
	virtual void( vector ) Set3DPos;
	virtual vector() Get3DPos;
	virtual void( void() ) SetDrawFunc;
	virtual void( void(float, float, float, float) ) SetInputFunc;
	virtual void( float, float, float, float ) Input;
};

void CUI3DView :: CUI3DView ( void )
{
	m_flFOV = 90;
	m_vecSize = '64 64';
	m_vec3DPos = m_vec3DAngles = '0 0 0';
	m_iFlags = VIEW_VISIBLE;
}

void CUI3DView :: SetSize ( vector vecSize )
{
	m_vecSize = vecSize;
}
vector CUI3DView :: GetSize ( void)
{
	return m_vecSize;
}

void CUI3DView :: Set3DAngles ( vector vecAngles )
{
	m_vec3DAngles = vecAngles;
}
vector CUI3DView :: Get3DAngles ( void)
{
	return m_vec3DAngles;
}

void CUI3DView :: Set3DPos ( vector vecPos )
{
	m_vec3DPos = vecPos;
}
vector CUI3DView :: Get3DPos ( void)
{
	return m_vec3DPos;
}

void CUI3DView :: SetDrawFunc ( void() vFunc )
{
	m_vDrawFunc = vFunc;
}
void CUI3DView :: SetInputFunc ( void(float, float, float, float) vFunc )
{
	m_vInputFunc = vFunc;
}

noref .vector origin;
noref .vector angles;
noref .vector mins;
noref .vector maxs;
noref .string model;
noref .float frame, frame2, lerpfrac, renderflags, frame1time;

void CUI3DView :: Draw ( void )
{
	if ( m_vDrawFunc ) {
		clearscene();
		setproperty( VF_VIEWPORT, m_vecOrigin + m_parent.m_vecOrigin, m_vecSize );
		setproperty( VF_AFOV, 90 );
		setproperty( VF_ORIGIN, m_vec3DPos );
		setproperty( VF_ANGLES, m_vec3DAngles );
		//setproperty( VF_PERSPECTIVE, 1 );
		m_vDrawFunc();
		renderscene();
	}
}

void CUI3DView :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
	if ( m_vInputFunc ) {
		m_vInputFunc( flEVType, flKey, flChar, flDevID );
	}
}