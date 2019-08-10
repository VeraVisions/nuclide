/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

font_s g_fntDefault;
var int g_vguiWidgetCount;

#ifdef CLASSIC_VGUI
	#define UI_MAINCOLOR '255 200 0' / 255
	#define UI_MAINALPHA 255
#else
	var vector UI_MAINCOLOR;
	var float UI_MAINALPHA;
#endif

int Util_MouseAbove(vector vecMousePos, vector vecPos, vector vecSize)
{
	if (vecMousePos[0] >= vecPos[0] && vecMousePos[0] <= vecPos[0] + vecSize[0]) {
		if (vecMousePos[1] >= vecPos[1] && vecMousePos[1] <= vecPos[1] + vecSize[1]) {
			return 1;
		}
	}
	return 0;
}

class CUIWidget
{
	vector m_vecOrigin;
	CUIWidget m_next;
	CUIWidget m_parent;
	int m_iFlags;

	virtual void( CUIWidget ) Add;
	virtual void( int ) FlagAdd;
	virtual void( int ) FlagRemove;
	virtual void( vector ) SetPos;
	virtual vector() GetPos;
	virtual int() GetPosWidth;
	virtual int() GetPosHeight;
	virtual void( ) Draw;
	virtual void( float, float, float, float ) Input;
};

void CUIWidget :: SetPos ( vector vecPos )
{
	m_vecOrigin = vecPos;
}
vector CUIWidget :: GetPos ( void )
{
	return m_vecOrigin;
}
int CUIWidget :: GetPosWidth ( void )
{
	return m_vecOrigin[0];
}
int CUIWidget :: GetPosHeight ( void )
{
	return m_vecOrigin[1];
}

void CUIWidget :: FlagAdd ( int iFlag )
{
	m_iFlags |= iFlag;
}
void CUIWidget :: FlagRemove ( int iFlag )
{
	m_iFlags -= ( m_iFlags & iFlag );
}

void CUIWidget :: Add ( CUIWidget wNew )
{
	CUIWidget wNext = this;
	CUIWidget wParent;
	do {
		wParent = wNext;
		wNext = wNext.m_next;
	} while ( wNext );
	wParent.m_next = wNew;
	wNew.m_parent = this;
}

void CUIWidget :: Draw ( void )
{
	CUIWidget wNext = this;
	do {
		wNext = wNext.m_next;
		if ( wNext && wNext.m_iFlags & 1 && wNext.m_parent.m_iFlags & 1 ) {
			wNext.Draw();
		}
	} while ( wNext );
}

void CUIWidget :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
	CUIWidget wNext = this;

	g_vguiWidgetCount = 0;
	do {
		wNext = wNext.m_next;
		if ( wNext && wNext.m_iFlags & 1 && wNext.m_parent.m_iFlags & 1 ) {
			g_vguiWidgetCount++;
			wNext.Input( flEVType, flKey, flChar, flDevID );
		}
	} while ( wNext );
}

void UISystem_Init ( void )
{
#ifndef CLASSIC_VGUI
	string strTemp;
	string strUIFile = "scripts/ui_style.txt";
	filestream fileUI = fopen( strUIFile, FILE_READ );
	
	UI_MAINCOLOR = '68 68 68' / 255;
	UI_MAINALPHA = 1.0f;
	
	if ( fileUI >= 0 ) {
		while ( ( strTemp = fgets( fileUI ) ) ) {
			if ( tokenizebyseparator( strTemp, "=" ) == 2 ) {
				switch ( argv( 0 ) ) {
					case "COLOR":
						UI_MAINCOLOR = stov( argv( 1 ) ) / 255;
						break;
					case "ALPHA":
						UI_MAINALPHA = stof( argv( 1 ) ) / 255;
						break;
				}
			}
		}
		fclose( fileUI );
	} else {
		error( sprintf( "[MENU] Cannot load UI file %s!", strUIFile ) );
	}
#endif
	Font_Load( "scripts/ui_font.txt", g_fntDefault );
	precache_pic( "textures/ui/steam/icon_radiosel" );
	precache_pic( "textures/ui/steam/icon_radiounsel" );
	precache_pic( "textures/ui/steam/icon_checked" );
	precache_pic( "textures/ui/steam/icon_emptybox" );
	precache_pic( "textures/ui/steam/icon_down" );
	precache_pic( "textures/ui/steam/icon_up" );
	precache_pic( "textures/ui/steam/icon_close" );
}
