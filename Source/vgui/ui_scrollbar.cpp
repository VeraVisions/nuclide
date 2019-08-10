/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	SCROLLBAR_VISIBLE,
	SCROLLBAR_UP_DOWN,
	SCROLLBAR_DN_DOWN,
	SCROLLBAR_SLIDER_DOWN
};

class CUIScrollbar : CUIWidget
{
	vector m_vecColor;
	float m_flAlpha;
	
	int m_iLength;
	
	float m_flMin;
	float m_flMax;
	float m_flStep;
	float m_flValue;
	
	void() CUIScrollbar;
	virtual void() m_vChangedCB = 0;
	
	virtual void( int ) SetLength;
	virtual int() GetLength;
	virtual void( float ) SetMin;
	virtual float() GetMin;
	virtual void( float ) SetMax;
	virtual float() GetMax;
	virtual void( float ) SetStep;
	virtual float() GetStep;
	virtual void( float, int ) SetValue;
	virtual float() GetValue;
	
	virtual void( void() ) CallOnChange;
	
	virtual void( float, float, float, float ) Input;
	virtual void() Draw;
};

void CUIScrollbar :: CUIScrollbar ( void )
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
	m_iFlags = SCROLLBAR_VISIBLE;
}

void CUIScrollbar :: Draw ( void )
{
	vector vecSize = [ 20, m_iLength ];

#ifndef CLASSIC_VGUI
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, m_flAlpha );

	if ( m_iFlags & BUTTON_DOWN ) {
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, vecSize[1] - 1], [vecSize[0], 1], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin, [vecSize[0], 1], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, vecSize[1] - 2], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ vecSize[0] - 1, 1], [1, vecSize[1] - 2], '1 1 1', 0.5f );
	} else {
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, vecSize[1] - 1], [vecSize[0], 1], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin, [vecSize[0], 1], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, vecSize[1] - 2], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ vecSize[0] - 1, 1], [1, vecSize[1] - 2], '0 0 0', 0.5f );
	}
#else
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, vecSize[1] - 1], [vecSize[0], 1], m_vecColor, 1.0f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, [vecSize[0], 1], m_vecColor, 1.0f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, vecSize[1] - 2], m_vecColor, 1.0f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ vecSize[0] - 1, 1], [1, vecSize[1] - 2], m_vecColor, 1.0f );
#endif

	vector vecUpPos = m_parent.m_vecOrigin + m_vecOrigin;
	vector vecDownPos = m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_iLength - 20 ];
	vector vecSliderPos = m_parent.m_vecOrigin + m_vecOrigin + [ 0, 20 ];
	
	vecSliderPos[1] += ( m_iLength - 60 ) * ( m_flValue / m_flMax );
	
	// Slider Button
	drawfill( vecSliderPos, '20 20', m_vecColor, m_flAlpha );
	if ( m_iFlags & SCROLLBAR_SLIDER_DOWN ) {
		drawfill( vecSliderPos, [20, 1], '0 0 0', 0.5f );
		drawfill( vecSliderPos + [ 0, 19], [20, 1], '1 1 1', 0.5f );
		drawfill( vecSliderPos + [ 0, 1], [1, 18], '0 0 0', 0.5f );
		drawfill( vecSliderPos + [ 19, 1], [1, 18], '1 1 1', 0.5f );
	} else {
		drawfill( vecSliderPos, [20, 1], '1 1 1', 0.5f );
		drawfill( vecSliderPos + [ 0, 19], [20, 1], '0 0 0', 0.5f );
		drawfill( vecSliderPos + [ 0, 1], [1, 18], '1 1 1', 0.5f );
		drawfill( vecSliderPos + [ 19, 1], [1, 18], '0 0 0', 0.5f );
	}

	// Button UP
#ifndef CLASSIC_VGUI
	drawfill( vecUpPos, '20 20', m_vecColor, m_flAlpha );
	if ( m_iFlags & SCROLLBAR_UP_DOWN ) {
		drawfill( vecUpPos, [20, 1], '0 0 0', 0.5f );
		drawfill( vecUpPos + [ 0, 19], [20, 1], '1 1 1', 0.5f );
		drawfill( vecUpPos + [ 0, 1], [1, 18], '0 0 0', 0.5f );
		drawfill( vecUpPos + [ 19, 1], [1, 18], '1 1 1', 0.5f );
	} else {
		drawfill( vecUpPos, [20, 1], '1 1 1', 0.5f );
		drawfill( vecUpPos + [ 0, 19], [20, 1], '0 0 0', 0.5f );
		drawfill( vecUpPos + [ 0, 1], [1, 18], '1 1 1', 0.5f );
		drawfill( vecUpPos + [ 19, 1], [1, 18], '0 0 0', 0.5f );
	}
	drawpic( vecUpPos + '2 2', "textures/ui/steam/icon_up", '16 16', '1 1 1', 1.0f );
#else
	if ( m_iFlags & SCROLLBAR_UP_DOWN ) {
		drawfill( vecUpPos, '20 20', m_vecColor, 0.25f );
		drawfill( vecUpPos, [20, 1], m_vecColor, 1.0f );
		drawfill( vecUpPos + [ 0, 19], [20, 1], m_vecColor, 1.0f );
		drawfill( vecUpPos + [ 0, 1], [1, 18], m_vecColor, 1.0f );
		drawfill( vecUpPos + [ 19, 1], [1, 18], m_vecColor, 1.0f );
	} else {
		drawfill( vecUpPos, [20, 1], '1 1 1', 0.5f );
		drawfill( vecUpPos + [ 0, 19], [20, 1], m_vecColor, 1.0f );
		drawfill( vecUpPos + [ 0, 1], [1, 18], m_vecColor, 1.0f );
		drawfill( vecUpPos + [ 19, 1], [1, 18], m_vecColor, 1.0f );
	}
	drawpic( vecUpPos + '2 2', "textures/ui/steam/icon_up", '16 16', m_vecColor, 1.0f );
#endif
	// Button DOWN
#ifndef CLASSIC_VGUI
	drawfill( vecDownPos, '20 20', m_vecColor, m_flAlpha );
	if ( m_iFlags & SCROLLBAR_DN_DOWN ) {
		drawfill( vecDownPos, [20, 1], '0 0 0', 0.5f );
		drawfill( vecDownPos + [ 0, 19], [20, 1], '1 1 1', 0.5f );
		drawfill( vecDownPos + [ 0, 1], [1, 18], '0 0 0', 0.5f );
		drawfill( vecDownPos + [ 19, 1], [1, 18], '1 1 1', 0.5f );
	} else {
		drawfill( vecDownPos, [20, 1], '1 1 1', 0.5f );
		drawfill( vecDownPos+ [ 0, 19], [20, 1], '0 0 0', 0.5f );
		drawfill( vecDownPos + [ 0, 1], [1, 18], '1 1 1', 0.5f );
		drawfill( vecDownPos + [ 19, 1], [1, 18], '0 0 0', 0.5f );
	}
	drawpic( vecDownPos + '2 2', "textures/ui/steam/icon_down", '16 16', '1 1 1', 1.0f );
#else
	if ( m_iFlags & SCROLLBAR_DN_DOWN ) {
		drawfill( vecDownPos, '20 20', m_vecColor, 0.25f );
		drawfill( vecDownPos, [20, 1], m_vecColor, 1.0f );
		drawfill( vecDownPos + [ 0, 19], [20, 1], m_vecColor, 1.0f );
		drawfill( vecDownPos + [ 0, 1], [1, 18], m_vecColor, 1.0f );
		drawfill( vecDownPos + [ 19, 1], [1, 18], m_vecColor, 1.0f );
	} else {
		drawfill( vecDownPos, [20, 1], m_vecColor, 1.0f );
		drawfill( vecDownPos+ [ 0, 19], [20, 1], m_vecColor, 1.0f );
		drawfill( vecDownPos + [ 0, 1], [1, 18], m_vecColor, 1.0f );
		drawfill( vecDownPos + [ 19, 1], [1, 18], m_vecColor, 1.0f );
	}
	drawpic( vecDownPos + '2 2', "textures/ui/steam/icon_down", '16 16', m_vecColor, 1.0f );
#endif
}

void CUIScrollbar :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
	vector vecUpPos = m_parent.m_vecOrigin + m_vecOrigin;
	vector vecDownPos = m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_iLength - 20 ];
	
	if ( flEVType == IE_KEYDOWN ) {
		if ( flKey == K_MOUSE1 ) {
			if ( Util_MouseAbove( getmousepos(), vecUpPos, '20 20' ) ) {
				m_iFlags |= SCROLLBAR_UP_DOWN;
			} else if ( Util_MouseAbove( getmousepos(), vecDownPos, '20 20' ) ) {
				m_iFlags |= SCROLLBAR_DN_DOWN;
			}
		}
	} else if ( flEVType == IE_KEYUP ) {
		if ( flKey == K_MOUSE1 ) {
			if ( m_iFlags & SCROLLBAR_UP_DOWN && Util_MouseAbove( getmousepos(), vecUpPos, '20 20' ) ) {
				SetValue( GetValue() - GetStep(), TRUE );
			} else if ( m_iFlags & SCROLLBAR_DN_DOWN && Util_MouseAbove( getmousepos(), vecDownPos, '20 20' ) ) {
				SetValue( GetValue() + GetStep(), TRUE );
			}
			m_iFlags -= ( m_iFlags & SCROLLBAR_UP_DOWN );
			m_iFlags -= ( m_iFlags & SCROLLBAR_DN_DOWN );
		} else if ( flKey == K_MWHEELDOWN && Util_MouseAbove( getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, [ 20, m_iLength ] ) ) {
			SetValue( GetValue() + GetStep(), TRUE );
		} else if ( flKey == K_MWHEELUP && Util_MouseAbove( getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, [ 20, m_iLength ] ) ) {
			SetValue( GetValue() - GetStep(), TRUE );
		}
	}
}

void CUIScrollbar :: SetLength ( int iLength )
{
	m_iLength = iLength;
}
int CUIScrollbar :: GetLength ( void )
{
	return m_iLength;
}

void CUIScrollbar :: SetMin ( float flVal )
{
	m_flMin = flVal;
}
float CUIScrollbar :: GetMin ( void )
{
	return m_flMin;
}

void CUIScrollbar :: SetMax ( float flVal )
{
	m_flMax = flVal;
}
float CUIScrollbar :: GetMax ( void )
{
	return m_flMax;
}

void CUIScrollbar :: SetStep ( float flVal )
{
	m_flStep = flVal;
}
float CUIScrollbar :: GetStep ( void )
{
	return m_flStep;
}

void CUIScrollbar :: SetValue ( float flVal, int iCallBack )
{
	m_flValue = bound( m_flMin, flVal, m_flMax );
	
	if ( m_vChangedCB && iCallBack ) {
		m_vChangedCB();
	}
}
float CUIScrollbar :: GetValue ( void )
{
	return m_flValue;
}

void CUIScrollbar :: CallOnChange ( void() vFunc )
{
	m_vChangedCB = vFunc;
}
