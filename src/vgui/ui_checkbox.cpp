/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

enumflags
{
	CHECKBOX_VISIBLE,
	CHECKBOX_HOVER,
	CHECKBOX_DOWN,
	CHECKBOX_CHECKED
};

class CUICheckbox : CUIWidget
{
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecSize;
	string m_strTitle;
	
	void() CUICheckbox;
	virtual void() Draw;
	virtual void( vector ) SetSize;
	virtual void( string ) SetTitle;
	virtual int() GetValue;
	virtual void( int ) SetValue;
	virtual void( float, float, float, float ) Input;
};

void CUICheckbox :: CUICheckbox ( void )
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
	m_vecSize = '96 18';
	m_iFlags = CHECKBOX_VISIBLE;
}

void CUICheckbox :: SetSize ( vector vecSize )
{
	m_vecSize = vecSize;
}
void CUICheckbox :: SetTitle ( string strName )
{
	m_strTitle = strName;
}
int CUICheckbox :: GetValue ( void )
{
	if ( m_iFlags & CHECKBOX_CHECKED ) {
		return TRUE;
	} else {
		return FALSE;
	}
}
void CUICheckbox :: SetValue ( int iValue )
{
	if ( iValue == TRUE ) {
		m_iFlags |= CHECKBOX_CHECKED;
	} else {
		m_iFlags -= ( m_iFlags & CHECKBOX_CHECKED );
	}
}

void CUICheckbox :: Draw ( void )
{
#ifndef CLASSIC_VGUI
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, m_flAlpha );

	if ( m_iFlags & CHECKBOX_DOWN ) {
		drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], '1 1 1', 0.5f );
	}
	
	if ( m_iFlags & CHECKBOX_CHECKED ) {
		drawpic( m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_checked", '16 16', '1 1 1', 1.0f, 0);
	} else {
		drawpic( m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_emptybox", '16 16', '1 1 1', 1.0f, 0);
	}
#else
	if ( m_iFlags & CHECKBOX_DOWN ) {
		drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f );
	}
	
	if ( m_iFlags & CHECKBOX_CHECKED ) {
		drawpic( m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_checked", '16 16', m_vecColor, 1.0f, 0);
	} else {
		drawpic( m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_emptybox", '16 16', m_vecColor, 1.0f, 0);
	}
#endif
	if ( m_strTitle ) {
		Font_DrawText( m_parent.m_vecOrigin + m_vecOrigin + [ 24, 3 ], m_strTitle, g_fntDefault );
	}
}

void CUICheckbox :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
	if ( flEVType == IE_KEYDOWN ) {
		if ( flKey == K_MOUSE1 ) {
			if ( Util_MouseAbove( getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, m_vecSize ) ) {
				m_iFlags |= CHECKBOX_DOWN;
			}
		}
	} else if ( flEVType == IE_KEYUP ) {
		if ( flKey == K_MOUSE1 ) {
			if ( m_iFlags & CHECKBOX_DOWN && Util_MouseAbove( getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, m_vecSize ) ) {
				SetValue( !GetValue() );
			}
			m_iFlags -= ( m_iFlags & CHECKBOX_DOWN );
		}
	}
}
