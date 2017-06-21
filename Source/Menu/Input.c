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
Menu_InputCheckMouse

Checks a specified region and returns TRUE if the mouse is above it.
=================
*/
int Menu_InputCheckMouse( vector vPos, vector vReg ) {
	vector vSMins, vSMaxs;

	vSMins = vPos;
	vSMaxs = vPos;
	vSMins_x = vPos_x;
	vSMaxs_y = vPos_y - 1;

	vSMaxs_x = vPos_x + vReg_x;
	vSMaxs_y = vPos_y + vReg_y;

	if ( vMousePos_x >= vSMins_x && vMousePos_x <= vSMaxs_x ) {
		if ( vMousePos_y >= vSMins_y && vMousePos_y <= vSMaxs_y ) {
			return TRUE;
		}
	}
	
	return FALSE;
}

/*
=================
Menu_InputEvent

New FTE routine for advanced mouse input in menuqc!
=================
*/
float Menu_InputEvent( float fEventType, float fKey, float fCharacter, float fDeviceID ) {
	if ( fEventType == IE_KEYDOWN ) {
		if ( fKey == K_MOUSE1 ) {
			fMouseClick = 1;
		} else {
			if ( fKey == K_ESCAPE ) {
				m_toggle( 0 );
			}
		
			fInputKeyDown = 1;
		}
		
		fInputKeyCode = fKey;
		fInputKeyASCII = fCharacter;
	} else if ( fEventType == IE_KEYUP ) {
		if ( fKey == K_MOUSE1 ) {
			fMouseClick = 0;
		} else {
			fInputKeyDown = 0;
		}
		
		fInputKeyCode = 0;
		fInputKeyASCII = 0;
	} else if ( fEventType == IE_MOUSEABS ) {
		vMousePos_x = fKey;
		vMousePos_y = fCharacter;
	} 
	
	return TRUE;
}

/*
=================
m_display, m_hide, m_toggle

Essentially what happens when togglemenu is used, called by the engine as well.
=================
*/
void m_display( void ) {
	iMenuActive = TRUE;
	setkeydest( KEY_MENU );
	setmousetarget( TARGET_MENU );
	setcursormode( TRUE, "gfx/cursor", '0 0 0', 1.0f );
}

void m_hide( void ) {
	iMenuActive = FALSE;
	setkeydest( KEY_GAME );
	setmousetarget( TARGET_CLIENT );
	setcursormode( FALSE );
}

void m_toggle( float fMode ) {
	if ( fMode == FALSE ) {
		m_hide();
	} else {
		m_display();
	}
}

float m_consolecommand( string sCMD ) {
	tokenize( sCMD );
	switch ( argv( 0 ) ) {
		case "togglemenu":
		m_display( );
		return TRUE;
		break;
		
	}
	return FALSE;
}
