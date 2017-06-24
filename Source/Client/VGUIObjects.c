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

#include "VGUI.h"

vector HUD_GetChatColor( float fTeam ) {
	if ( fTeam == TEAM_CT ) {
		return '0.45 0.60 0.75';
	} else if ( fTeam == TEAM_T ) {
		return '0.75 0.1875 0.1875';
	} else {
		return '0.75 0.75 0.75';
	}
}

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
	drawfill( vPos, vSize, VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Draw the outline START
	v1_x = vPos_x + vSize_x;
	v1_y = vPos_y + 1;
	drawline( 1.0, vPos, v1, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	
	v2_x = vPos_x;
	v2_y = vPos_y + vSize_y;
	drawline( 1.0, vPos, v2, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );

	v3 = vPos + vSize;
	drawline( 1.0, v1 - '1 0', v3 - '1 0', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	drawline( 1.0, v2, v3, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	// Draw the outline END

	// Draw the window title
	CSQC_DrawText( vPos + '16 16 0', sTitle, '16 16 0', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_16 );
	drawline( 1.0, vPos + '0 48 0', v1 + '0 48 0', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
}

// Draws window with outline, border and title
void VGUI_WindowSmall( string sTitle, vector vPos, vector vSize ) {
	vector v1, v2, v3;

	// Draw the background
	drawfill( vPos, vSize, VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Draw the outline START
	v1_x = vPos_x + vSize_x;
	v1_y = vPos_y + 1;
	drawline( 1.0, vPos, v1, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	
	v2_x = vPos_x;
	v2_y = vPos_y + vSize_y;
	drawline( 1.0, vPos, v2, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );

	v3 = vPos + vSize;
	drawline( 1.0, v1 - '1 0', v3 - '1 0', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	drawline( 1.0, v2, v3, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	// Draw the outline END

	// Draw the window title
	CSQC_DrawText( vPos + '8 8 0', sTitle, '8 8 0', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_16 );
	drawline( 1.0, vPos + '0 24 0', v1 + '0 24 0', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
}

// Draws a button, returns whether or not a mouse is hovering over it (for inheritance' sake)
float VGUI_Button( string sLabel, void() vFunction, vector vPos, vector vSize ) {
	vector v1, v2, v3, v4;
	
	// Draw the outline START
	v1_x = vPos_x + vSize_x;
	v1_y = vPos_y + 1;
	drawline( 1.0, vPos, v1, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	
	v2_x = vPos_x;
	v2_y = vPos_y + vSize_y;
	drawline( 1.0, vPos, v2, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );

	v3 = vPos + vSize;
	drawline( 1.0, v1 - '1 0', v3 - '1 0', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	drawline( 1.0, v2, v3, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	// Draw the outline END

	// Draw the button label
	v4_x = vPos_x + 16;
	v4_y = vPos_y + ( ( vSize_y / 2 ) - 4 );

	if( VGUI_CheckMouse( vPos, vSize ) ) {
		if ( fMouseClick == TRUE ) {
			vFunction();
			fMouseClick = FALSE;
		}

		CSQC_DrawText( v4, sLabel, '8 8 0', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_DEFAULT );
		drawline( 1.0, v4 + '0 10 0', v4 + '0 10 0' + [ (strlen( sLabel ) * 8 ), 0 ], vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
		return TRUE;
	} else {
		CSQC_DrawText( v4, sLabel, '8 8 0', vVGUIColor * 0.8, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_DEFAULT );
	}

	return FALSE;
}

void VGUI_FakeButton( string sLabel, vector vPos, vector vSize ) {
	vector v1, v2, v3, v4;
	
	// Draw the outline START
	v1_x = vPos_x + vSize_x;
	v1_y = vPos_y + 1;
	drawline( 1.0, vPos, v1, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	
	v2_x = vPos_x;
	v2_y = vPos_y + vSize_y;
	drawline( 1.0, vPos, v2, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );

	v3 = vPos + vSize;
	drawline( 1.0, v1 - '1 0', v3 - '1 0', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	drawline( 1.0, v2, v3, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE );
	// Draw the outline END

	// Draw the button label
	v4_x = vPos_x + 16;
	v4_y = vPos_y + ( ( vSize_y / 2 ) - 4 );
	CSQC_DrawText( v4, sLabel, '8 8 0', vVGUIColor * 0.5, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_DEFAULT );
}

// Wrapper for simple VGUI Text labels
void VGUI_Text( string sText, vector vPos, vector vSize, float fFont ) {
	CSQC_DrawText( vPos, sText, vSize, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, fFont );
}

void VGUI_RightText( vector vPos, string sText, vector vSize, vector vColor, float fFont ) {
	vPos_x -= stringwidth( sText, FALSE, vSize );
	CSQC_DrawText( vPos, sText, vSize, vColor, 1, 0, fFont );
}