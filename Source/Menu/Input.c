/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

var vector vMenuClickMins;
var vector vMenuClickMaxs;

/*
=================
Menu_InputCheckMouse

Checks a specified region and returns TRUE if the mouse is above it.
=================
*/
int Menu_InputCheckMouse( vector vPosition, vector vRegion ) {
	vector vSMins, vSMaxs;

	// Some elements will be blocked (scrolling lists) outside of this region
	if ( vMousePos_x >= vMenuClickMins_x && vMousePos_x <= vMenuClickMaxs_x ) {
		if ( vMousePos_y >= vMenuClickMins_y && vMousePos_y <= vMenuClickMaxs_y ) {
			vSMins = vSMaxs = vPosition;
			vSMaxs_y = vPosition_y - 1;
		
			vSMaxs_x = vPosition_x + vRegion_x;
			vSMaxs_y = vPosition_y + vRegion_y;
		
			if ( vMousePos_x >= vSMins_x && vMousePos_x <= vSMaxs_x ) {
				if ( vMousePos_y >= vSMins_y && vMousePos_y <= vSMaxs_y ) {
					return TRUE;
				}
			}
		}
	}
	
	return FALSE;
}

/*
=================
Menu_SetClipArea

This will set the region in which mouse activity and drawing
of objects will happen. Use it to clip text and mouse activity.
=================
*/
void Menu_SetClipArea( vector vPosition, vector vRegion ) {
	vPosition += vMenuOffset;
	vMenuClickMins = vPosition;
	vMenuClickMaxs = vPosition;
	vMenuClickMins_x = vPosition_x;
	vMenuClickMaxs_y = vPosition_y - 1;
		
	vMenuClickMaxs_x = vPosition_x + vRegion_x;
	vMenuClickMaxs_y = vPosition_y + vRegion_y;
	
	drawsetcliparea( vPosition_x, vPosition_y, vRegion_x, vRegion_y );
}

/*
=================
Menu_ResetClipArea

Resets the clip area that was set via Menu_SetClipArea
=================
*/
void Menu_ResetClipArea( void ) {
	vMenuClickMins = vMenuOffset;
	vMenuClickMaxs = vMenuOffset + '640 480';
	drawresetcliparea();
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
		
		if ( fKey == K_MWHEELDOWN ) {
			fScrollWheel = SCROLL_DOWN;
		} else if ( fKey == K_MWHEELUP ) {
			fScrollWheel = SCROLL_UP;
		}
		
		fInputKeyCode = fKey;
		fInputKeyASCII = fCharacter;
	} else if ( fEventType == IE_KEYUP ) {
		if ( fKey == K_MOUSE1 ) {
			fMouseClick = 0;
			iScrollbarHold = FALSE;
		} else {
			fInputKeyDown = 0;
		}
		
		fInputKeyCode = 0;
		fInputKeyASCII = 0;
	} else if ( fEventType == IE_MOUSEABS ) {
		vMousePos_x = fKey;
		vMousePos_y = fCharacter;
	} else if ( fEventType == IE_MOUSEDELTA ) {
		vMousePos_x += fKey;
		vMousePos_y += fCharacter;
		
		if ( vMousePos_x < 0 ) {
			vMousePos_x = 0;
		} else if ( vMousePos_x > vVideoSize_x ) {
			vMousePos_x = vVideoSize_x;
		}
		
		if ( vMousePos_y < 0 ) {
			vMousePos_y = 0;
		} else if ( vMousePos_y > vVideoSize_y ) {
			vMousePos_y = vVideoSize_y;
		}
	} else {
		return FALSE;
	}

	m_draw(vVideoSize);

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
		case "menu_quit":
			iMenu = MENU_QUIT;
			return TRUE;
		break;
		
	}
	return FALSE;
}
