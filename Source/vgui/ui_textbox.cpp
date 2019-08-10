/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	TEXTBOX_VISIBLE,
	TEXTBOX_HOVER,
	TEXTBOX_DOWN,
	TEXTBOX_FOCUS,
};

class CUITextBox : CUIWidget
{
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecSize;
	string m_strText;
	float m_flTime;
	
	void() CUITextBox;
	virtual void() Draw;
	virtual void( vector ) SetSize;
	virtual void( string ) SetText;
	virtual string() GetText;
	virtual void( float, float, float, float ) Input;
};

void CUITextBox :: CUITextBox ( void )
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
	m_vecSize = '96 24';
	m_iFlags = BUTTON_VISIBLE;
}

void CUITextBox :: SetSize ( vector vecSize )
{
	m_vecSize = vecSize;
}
void CUITextBox :: SetText ( string strName )
{
	m_strText = strName;
}
string CUITextBox :: GetText ( void )
{
	return m_strText;
}

void CUITextBox :: Draw ( void )
{

#ifdef CLASSIC_VGUI
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f );
#else
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, '0 0 0', 0.25f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], '0 0 0', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], '1 1 1', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], '0 0 0', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], '1 1 1', 0.5f );
#endif
	m_flTime += frametime * 2;

	// blinking cursor
	if ( m_iFlags & TEXTBOX_FOCUS ) {
		if ( rint( m_flTime ) & 1 ) {
			Font_DrawText( m_parent.m_vecOrigin + m_vecOrigin + [ 8, 8 ], sprintf( "%s|", m_strText ), g_fntDefault );
			return;
		}
	}
	
	if ( m_strText ) {
		Font_DrawText( m_parent.m_vecOrigin + m_vecOrigin + [ 8, 8 ], m_strText, g_fntDefault );
	}
}

void CUITextBox :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
	if ( flEVType == IE_KEYDOWN ) {
		switch ( flKey ) {
		case K_MOUSE1 :
			if ( Util_MouseAbove( getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, m_vecSize ) ) {
				m_iFlags |= TEXTBOX_DOWN;
			}
			break;
		case K_BACKSPACE:
			if ( m_iFlags & TEXTBOX_FOCUS ) {
				m_strText = substring( m_strText, 0, strlen( m_strText ) - 1 );
			}
			break;
		default:
			if ( m_iFlags & TEXTBOX_FOCUS ) {
				m_strText = sprintf( "%s%s", m_strText, chr2str( flChar ) );
			}
		}
	} else if ( flEVType == IE_KEYUP ) {
		if ( flKey == K_MOUSE1 ) {
			if ( m_iFlags & TEXTBOX_DOWN && Util_MouseAbove( getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, m_vecSize ) ) {
				m_iFlags |= TEXTBOX_FOCUS;
			} else {
				m_iFlags -= ( m_iFlags & TEXTBOX_FOCUS );
			}
			m_iFlags -= ( m_iFlags & TEXTBOX_DOWN );
		}
	}
}
