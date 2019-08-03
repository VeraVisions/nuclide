/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	SLIDER_VISIBLE,
	SLIDER_HOVER,
	SLIDER_DOWN,
};

class CUISlider : CUIWidget
{
	float m_flAlpha;
	vector m_vecSize;
	vector m_vecColor;

	void() CUISlider;
	virtual void() Draw;
	virtual void( float, float, float, float ) Input;
	virtual void( vector ) SetSize;
	virtual void( string ) SetTitle;
};

void CUISlider :: CUISlider ( void )
{
	m_vecColor = '76 88 68' / 255;
	m_flAlpha = 1.0f;
	m_vecSize = '96 24';
	m_iFlags = BUTTON_VISIBLE;
}

void CUISlider :: Draw ( void )
{
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, m_flAlpha );
	
	if ( m_iFlags & BUTTON_DOWN ) {
		drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], '1 1 1', 0.5f );
	} else {
		drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], '0 0 0', 0.5f );
	}
	
	if ( m_strTitle ) {
		Font_DrawText( m_parent.m_vecOrigin + m_vecOrigin + [ 8, 8 ], m_strTitle, g_fntDefault );
	}
	if ( m_strIcon ) {
		drawpic( m_parent.m_vecOrigin + m_vecOrigin + '2 2', m_strIcon, '16 16', '1 1 1', 1.0f );
	}
}

void CUISlider :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{

}

void CUISlider :: SetSize ( vector vecSize )
{
	m_vecSize = vecSize;
}
void CUISlider :: SetTitle ( string strName )
{
	m_strTitle = strName;
}
