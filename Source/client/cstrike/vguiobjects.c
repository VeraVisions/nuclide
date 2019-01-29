/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
====================
HUD_GetChatColor

Returns an RGB color vector for the specified team
====================
*/
vector HUD_GetChatColor( float fTeam ) {
	if ( fTeam == TEAM_CT ) {
		return '0.45 0.60 0.75';
	} else if ( fTeam == TEAM_T ) {
		return '0.75 0.1875 0.1875';
	} else {
		return '0.75 0.75 0.75';
	}
}

/*
====================
HUD_GetChatColor

Returns a HEX color string prefix for the specified team
====================
*/
string HUD_GetChatColorHEX( float fTeam ) {
	if ( fTeam == TEAM_CT ) {
		return "^x7AC";
	} else if ( fTeam == TEAM_T ) {
		return "^xC33";
	} else {
		return "^xCCC";
	}
}

/*
====================
HUD_GetChatColor

Returns a HEX color string prefix with teamname
====================
*/
string HUD_GetChatColorHEXTeam( float fTeam ) {
	if ( fTeam == TEAM_CT ) {
		return "^x7AC(Counter-Terrorist) ";
	} else if ( fTeam == TEAM_T ) {
		return "^xC33(Terrorist) ";
	} else {
		return "^xCCC(Spectator) ";
	}
}

/*
====================
VGUI_CheckMouse

Returns whether or not our mouse cursor hovers over a region
====================
*/
float VGUI_CheckMouse( vector vPos, vector vReg ) {
	vector vSMins, vSMaxs;
	
	vSMins = vPos;
	vSMaxs = vPos;
	vSMins[0] = vPos[0];
	vSMaxs[1] = vPos[1] - 1;

	vSMaxs[0] = vPos[0] + vReg[0];
	vSMaxs[1] = vPos[1] + vReg[1];

	if ( mouse_pos[0] >= vSMins[0] && mouse_pos[0] <= vSMaxs[0] ) {
		if (mouse_pos[1] >= vSMins[1] && mouse_pos[1] <= vSMaxs[1] ) {
			return 1;
		}
	}

	return 0;
}


/*
====================
VGUI_Window

Draws window with outline, border and title
====================
*/
void VGUI_Window( string sTitle, vector vPosition, vector vSize ) {
	// Draw the background
	drawfill( vPosition, vSize, VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Sides
	drawfill( vPosition, [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );

	// Draw the window title
	CSQC_DrawText( vPosition + '16 16', sTitle, '12 12', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_CON );
	drawfill( vPosition + '0 48', [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
}


/*
====================
VGUI_WindowSmall

Draws smaller window with outline, border and title
====================
*/
void VGUI_WindowSmall( string sTitle, vector vPosition, vector vSize ) {
	// Draw the background
	drawfill( vPosition, vSize, VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Sides
	drawfill( vPosition, [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );

	// Draw the window title
	CSQC_DrawText( vPosition + '8 8', sTitle, '12 12', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_CON );
	drawfill( vPosition + '0 24', [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
}

/*
====================
VGUI_WindowSmall

Draws a button, returns whether or not a mouse is hovering over it (for inheritance' sake)
====================
*/
float VGUI_Button( string sLabel, void() vFunction, vector vPosition, vector vSize ) {
	vector vLabelPos;
	
	if ( iVGUIKey < 57 ) {
		iVGUIKey++;
	}
	
	drawfill( vPosition, [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );

	// Draw the button label
	vLabelPos[0] = vPosition[0] + 16;
	vLabelPos[1] = vPosition[1] + ( ( vSize[1] / 2 ) - 4 );
	
	if ( ( iVGUIKey == pSeat->fInputKeyCode ) ) {
		vFunction();
		pSeat->fInputKeyCode = 0;
		return TRUE;
	}
	
	if ( VGUI_CheckMouse( vPosition, vSize ) ) {
		if ( fMouseClick == TRUE ) {
			vFunction();
			fMouseClick = FALSE;
		}

		CSQC_DrawText( vLabelPos, sLabel, '12 12', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_CON );
		drawfill( vLabelPos + '0 10 0', [ stringwidth( sLabel, TRUE, '12 12' ), 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
		return TRUE;
	} else {
		CSQC_DrawText( vLabelPos, sLabel, '12 12', vVGUIColor * 0.8, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_CON );
	}
	
	return FALSE;
}

/*
====================
VGUI_FakeButton

Looks like a button, doesn't function though. Meant for dead buttons
====================
*/
void VGUI_FakeButton( string sLabel, vector vPosition, vector vSize ) {
	vector vLabelPos;
	
	drawfill( vPosition, [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );

	// Draw the button label
	vLabelPos[0] = vPosition[0] + 16;
	vLabelPos[1] = vPosition[1] + ( ( vSize[1] / 2 ) - 4 );

	CSQC_DrawText( vLabelPos, sLabel, '12 12', vVGUIColor * 0.5, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_CON );
}

/*
====================
VGUI_Text

Wrapper for simple GUI text labels
====================
*/
void VGUI_Text( string sText, vector vPos, vector vSize, float fFont ) {
	CSQC_DrawText( vPos, sText, vSize, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, fFont );
}

/*
====================
VGUI_RightText

Right-aligned version of above
====================
*/
void VGUI_RightText( vector vPos, string sText, vector vSize, vector vColor, float fFont ) {
	vPos[0] -= stringwidth( sText, FALSE, vSize );
	CSQC_DrawText( vPos, sText, vSize, vColor, 1, 0, fFont );
}
