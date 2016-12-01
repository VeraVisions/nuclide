/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

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

#include "VGUI.h"

// Returns whether or not our mouse cursor hovers over a region
float VGUI_CheckMouse( vector vPos, vector vReg ) {
	vector vSMins, vSMaxs;
	
	vSMins = vPos;
	vSMaxs = vPos;
	vSMins_x = vPos_x;
	vSMaxs_y = vPos_y - 1;

	vSMaxs_x = vPos_x + vReg_x;
	vSMaxs_y = vPos_y + vReg_y;

	if ( vMousePos_x >= vSMins_x && vMousePos_x <= vSMaxs_x ) {
		if (vMousePos_y >= vSMins_y && vMousePos_y <= vSMaxs_y ) {
			return 1;
		}
	}
	
	return 0;
}

// Draws window with outline, border and title
void VGUI_Window( string sTitle, vector vPos, vector vSize ) {
	vector v1, v2, v3;

	// Draw the background
	drawfill( vPos, vSize - '1 1 0', VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Draw the outline START
	v1_x = vPos_x + vSize_x;
	v1_y = vPos_y;
	drawline( 1.0, vPos - '1 0 0', v1, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	
	v2_x = vPos_x;
	v2_y = vPos_y + vSize_y;
	drawline( 1.0, vPos, v2, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );

	v3 = vPos + vSize;
	drawline( 1.0, v1, v3, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	drawline( 1.0, v2, v3, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	// Draw the outline END

	// Draw the window title
	drawstring( vPos + '16 16 0', sTitle, '16 16 0', VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	drawline( 1.0, vPos + '0 48 0', v1 + '0 48 0', VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
}

// Draws a button, returns whether or not a mouse is hovering over it (for inheritance' sake)
float VGUI_Button( string sLabel, void() vFunction, vector vPos, vector vSize ) {
	vector v1, v2, v3, v4;
	
	// Draw the outline START
	v1_x = vPos_x + vSize_x;
	v1_y = vPos_y;
	drawline( 1.0, vPos - '1 0 0', v1, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	
	v2_x = vPos_x;
	v2_y = vPos_y + vSize_y;
	drawline( 1.0, vPos, v2, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );

	v3 = vPos + vSize;
	drawline( 1.0, v1, v3, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	drawline( 1.0, v2, v3, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	// Draw the outline END

	// Draw the button label
	v4_x = vPos_x + 16;
	v4_y = vPos_y + ( ( vSize_y / 2 ) - 4 );

	if( VGUI_CheckMouse( vPos, vSize ) ) {
		if ( fMouseClick == TRUE ) {
			vFunction();
			fMouseClick = FALSE;
		}

		drawstring( v4, sLabel, '8 8 0', VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
		drawline( 1.0, v4 + '0 10 0', v4 + '0 10 0' + [ (strlen( sLabel ) * 8 ), 0 ], VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
		return TRUE;
	} else {
		drawstring( v4, sLabel, '8 8 0', VGUI_WINDOW_FGCOLOR * 0.8, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	}

	return FALSE;
}

void VGUI_FakeButton( string sLabel, vector vPos, vector vSize ) {
	vector v1, v2, v3, v4;
	
	// Draw the outline START
	v1_x = vPos_x + vSize_x;
	v1_y = vPos_y;
	drawline( 1.0, vPos - '1 0 0', v1, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA * 0.5, DRAWFLAG_ADDITIVE );
	
	v2_x = vPos_x;
	v2_y = vPos_y + vSize_y;
	drawline( 1.0, vPos, v2, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA * 0.5, DRAWFLAG_ADDITIVE );

	v3 = vPos + vSize;
	drawline( 1.0, v1, v3, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA * 0.5, DRAWFLAG_ADDITIVE );
	drawline( 1.0, v2, v3, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA * 0.5, DRAWFLAG_ADDITIVE );
	// Draw the outline END

	// Draw the button label
	v4_x = vPos_x + 16;
	v4_y = vPos_y + ( ( vSize_y / 2 ) - 4 );


	drawstring( v4, sLabel, '8 8 0', VGUI_WINDOW_FGCOLOR * 0.5, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
}

// Wrapper for simple VGUI Text labels
void VGUI_Text( string sText, vector vPos, vector vSize ) {
	drawstring( vPos, sText, vSize, VGUI_WINDOW_FGCOLOR, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
}
