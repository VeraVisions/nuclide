/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

/*
=================
drawmenupic

Wrapper for drawpic that cares about resolution and scales.
=================
*/
void drawmenupic( vector vPosition, string sPic, vector vSize, vector vRGB, float fAlpha, float fDrawflag ) {
	vSize = vSize * fMenuScale;
	vPosition = vPosition * fMenuScale;
	drawpic( vPosition + [ iMenuPadding, 0, 0 ], sPic, vSize, vRGB, fAlpha, fDrawflag );
}

/*
=================
drawmenufill

Wrapper for drawpic that cares about resolution and scales.
=================
*/
void drawmenufill( vector vPosition, vector vSize, vector vRGB, float fAlpha, float fDrawflag ) {
	vSize = vSize * fMenuScale;
	vPosition = vPosition * fMenuScale;
	drawfill( vPosition + [ iMenuPadding, 0, 0 ], vSize, vRGB, fAlpha, fDrawflag );
}

/*
=================
drawmenustring

Wrapper for drawstring that cares about resolution and scales.
=================
*/
void drawmenustring( vector vPosition, string sText, vector vSize, vector vRGB, float fAlpha, float fDrawflag ) {
	vSize = vSize * fMenuScale;
	vPosition = vPosition * fMenuScale;
	drawstring( vPosition + [ iMenuPadding, 0, 0 ], sText, vSize, vRGB, fAlpha, fDrawflag );
}

/*
=================
m_mainbutton

Buttons on the main menu screen
=================
*/
void m_mainbutton( vector vPos, string sText, int iItem, void() vFunc) {
	static float fSelectionAlpha;
	
	if ( Menu_InputCheckMouse( vPos, '182 14' ) == TRUE ) {
		if ( iButtonSelected != iItem ) {
			iButtonSelected = iItem;
			fSelectionAlpha = 0.0f;
		}
		
		if ( fMouseClick == TRUE ) {
			if ( iMenu == iItem ) {
				iMenu = 0;
			} else {
				iMenu = iItem;
			}
			fMenuAlpha = 0.0f;
			fMouseClick = FALSE;
			localsound( "buttons/button9.wav" );
		}
	}

	if ( iMenu == iItem ) {
		drawmenustring( vPos, sText, '14 14', '1 0.5 0', 1.0f, 0 );
		vFunc();
	} else {
		if ( iButtonSelected == iItem ) {
			drawmenustring( vPos, sText, '14 14', '1 1 1', 1 - fSelectionAlpha, 0 );
			drawmenustring( vPos, sText, '14 14', '0.3 0.3 1', fSelectionAlpha, 0 );
		} else {
			drawmenustring( vPos, sText, '14 14', '1 1 1', fFadeAlpha, 0 );
		}
	}
	
	if ( fSelectionAlpha < 1.0f ) {
		fSelectionAlpha += frametime;
		if ( fSelectionAlpha > 1.0f ) {
			fSelectionAlpha = 1.0f;
		}
	}
}


void menu_buttoncmd( vector vPosition, string sLabel, vector vFSize, void() vFunc ) {
	float fButtonAlpha = fMenuAlpha;
	if ( Menu_InputCheckMouse( vPosition, [ stringwidth( sLabel, TRUE, vFSize), vFSize_y ] ) == TRUE ) {
		if ( fMouseClick == TRUE ) {
			vFunc();
			fMouseClick = FALSE;
			localsound( "buttons/button7.wav" );
		}
		drawmenufill( vPosition + [ 0, vFSize_y + 2 ], [ stringwidth( sLabel, TRUE, vFSize ), 2 ], '1 1 1', fMenuAlpha * 0.5, 0 );
	} else {
		fButtonAlpha *= 0.5;
	}
	drawmenustring( vPosition, sLabel, vFSize, '1 1 1', fButtonAlpha, FALSE );
}

#define OUTLINE_COLOR '0.8 0.8 1'
void m_drawmenushadow( void ) {
	drawmenufill( '16 32', '380 430', '0 0 0', fMenuAlpha * 0.75, 2 ); // Backdrop
	drawmenufill( '15 32', '1 430', OUTLINE_COLOR, fMenuAlpha * 0.5, 2 ); // Left
	drawmenufill( '397 32', '1 430', OUTLINE_COLOR, fMenuAlpha * 0.5, 2 ); // Right
	drawmenufill( '15 31', '383 1', OUTLINE_COLOR, fMenuAlpha * 0.5, 2 ); // Up
	drawmenufill( '15 462', '383 1', OUTLINE_COLOR, fMenuAlpha * 0.5, 2 ); // Down
}
