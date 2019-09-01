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
	BUTTON_VISIBLE,
	BUTTON_HOVER,
	BUTTON_DOWN,
	BUTTON_LASTACTIVE
};

class CUIButton : CUIWidget
{
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecSize;
	string m_strTitle;
	string m_strTitleActive;
	string m_strIcon;
	
	void() CUIButton;
	virtual void() m_vFunc = 0;
	virtual void() Draw;
	virtual void( vector ) SetSize;
	virtual vector() GetSize;
	virtual int() GetSizeWidth;
	virtual int() GetSizeHeight;
	virtual void( string ) SetTitle;
	virtual void( string ) SetIcon;
	virtual void( void() ) SetFunc;
	virtual void( float, float, float, float ) Input;
};

void CUIButton :: CUIButton ( void )
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
	m_vecSize = '96 24';
	m_iFlags = BUTTON_VISIBLE;
}

void CUIButton :: SetSize ( vector vecSize )
{
	m_vecSize = vecSize;
}
vector CUIButton :: GetSize ( void )
{
	return m_vecSize;
}
int CUIButton :: GetSizeWidth ( void )
{
	return m_vecSize[0];
}
int CUIButton :: GetSizeHeight ( void )
{
	return m_vecSize[1];
}

void CUIButton :: SetTitle ( string strName )
{
	m_strTitle = strName;
	m_strTitleActive = sprintf( "^3%s", m_strTitle );
	SetSize( [ stringwidth( m_strTitle, TRUE, [ g_fntDefault.iScale, g_fntDefault.iScale ] ) + 16, 24 ] );
}
void CUIButton :: SetIcon ( string strName )
{
	m_strIcon = strName;
}
void CUIButton :: SetFunc ( void() vFunc )
{
	m_vFunc = vFunc;
}

void CUIButton :: Draw ( void )
{

#ifndef CLASSIC_VGUI
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, m_flAlpha );

	if ( m_iFlags & BUTTON_DOWN ) {
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], '1 1 1', 0.5f );
	} else {
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], '0 0 0', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], '1 1 1', 0.5f );
		drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], '0 0 0', 0.5f );
	}
#else
	if ( m_iFlags & BUTTON_DOWN ) {
		drawfill( m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, 0.25f );
	}
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f );
#endif

	if ( m_strTitle ) {
		if ( m_iFlags & BUTTON_LASTACTIVE ) {
			Font_DrawText( m_parent.m_vecOrigin + m_vecOrigin + [ 8, 8 ], m_strTitleActive, g_fntDefault );
		} else {
			Font_DrawText( m_parent.m_vecOrigin + m_vecOrigin + [ 8, 8 ], m_strTitle, g_fntDefault );
		}
	}
	if ( m_strIcon ) {
		drawpic( m_parent.m_vecOrigin + m_vecOrigin + '2 2', m_strIcon, '16 16', '1 1 1', 1.0f );
	}
}

void CUIButton :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
	if ( flEVType == IE_KEYDOWN ) {
		if ( flKey == K_MOUSE1 ) {
			FlagRemove( BUTTON_LASTACTIVE );
			if ( Util_MouseAbove( getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, m_vecSize ) ) {
				//m_iFlags |= BUTTON_DOWN;
				FlagAdd( BUTTON_DOWN );
				FlagAdd( BUTTON_LASTACTIVE );
			}
		}
	} else if ( flEVType == IE_KEYUP ) {
		if ( flKey == K_MOUSE1 ) {
			if ( m_iFlags & BUTTON_DOWN && Util_MouseAbove( getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, m_vecSize ) ) {
				if ( m_vFunc ) {
					m_vFunc();
				}
			}
			FlagRemove( BUTTON_DOWN );
		}
	}
}
