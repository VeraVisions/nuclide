/*
OpenCS Project
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

#define CHAT_LINES 5
#define CHAT_TIME 4
int iLineScroll;
float fChatTime;
string sMSGBuffer[ CHAT_LINES ];

/*
=================
CSQC_Parse_Print

Receives a message and sorts it into the chat messagebuffer
=================
*/
void CSQC_Parse_Print(string sMessage, float fLevel ) {
	if ( iLineScroll < ( CHAT_LINES - 1 ) ) {
		sMSGBuffer[ iLineScroll + 1 ] = sMessage;
		iLineScroll++;
	} else {
		for ( int i = 0; i < ( CHAT_LINES - 1 ); i++ ) {
			sMSGBuffer[ i ] = sMSGBuffer[ i + 1 ];
		}
		sMSGBuffer[ CHAT_LINES - 1 ] = sMessage;
	}
		
	fChatTime = time + CHAT_TIME;
}

/*
=================
CSQC_DrawChat

Just prints whatever is in the chat buffer and removes lines after some time.
=================
*/
void CSQC_DrawChat( void ) {
	vector vChatPos = [ 16, vVideoResolution_y - 128 ];
	
	// Remove messages after a fChatTime has passed
	if ( fChatTime < time && iLineScroll >= 0 ) {
		sMSGBuffer[ iLineScroll ] = "";
		iLineScroll--;
		fChatTime = time + CHAT_TIME;
	}
	
	for ( int i = 0; i < CHAT_LINES; i++ ) {
		drawstring( vChatPos + '1 1', sMSGBuffer[ i ], '8 8 0', '0 0 0', VGUI_WINDOW_FGALPHA, 0 );
		drawstring( vChatPos, sMSGBuffer[ i ], '8 8 0', vHUDColor, 1, DRAWFLAG_ADDITIVE );
		vChatPos_y += 12;
	}
}

/*
=================
CSQC_DrawCenterprint

Read centerprints from a buffer and display them with alpha and whatnot
=================
*/
float fCenterPrintAlpha;
float fCenterPrintTime;
float fCenterPrintLines;
string sCenterPrintBuffer[ 18 ];

void CSQC_DrawCenterprint( void ) {	
	if ( fCenterPrintAlpha <= 0 ) {
		return;
	}
	
	vector vCenterPrintPos;
	
	if ( fCenterPrintTime > time ) {
		fCenterPrintAlpha = 1;
	} else {
		fCenterPrintAlpha -= frametime;
		
		if ( fCenterPrintAlpha < 0 ) {
			fCenterPrintAlpha = 0;
		}
	}
	
	vCenterPrintPos_y = ( vVideoResolution_y / 2 ) - ( fCenterPrintLines - 4 );
	for ( int i = 0; i < ( fCenterPrintLines ); i++ ) {
		vCenterPrintPos_x = ( vVideoResolution_x / 2 ) - ( stringwidth( sCenterPrintBuffer[ i ], FALSE ) / 2 );
		drawstring( vCenterPrintPos + '1 1', sCenterPrintBuffer[ i ], '8 8 0', '0 0 0', fCenterPrintAlpha, 0 );
		drawstring( vCenterPrintPos, sCenterPrintBuffer[ i ], '8 8 0', vHUDColor, fCenterPrintAlpha, DRAWFLAG_ADDITIVE );
		vCenterPrintPos_y += 8;
	}
}

/*
=================
CSQC_Parse_CenterPrint

Catches every centerprint call and allows us to tinker with it.
That's how we are able to add color, alpha and whatnot.
Keep in mind that newlines need to be tokenized
=================
*/
float CSQC_Parse_CenterPrint( string sMessage ) {
	
	fCenterPrintLines = tokenizebyseparator( sMessage, "\n" );
	
	for( int i = 0; i < ( fCenterPrintLines ); i++ ) {
		sCenterPrintBuffer[ i ] = argv( i );
	}
	
	fCenterPrintAlpha = 1;
	fCenterPrintTime = time + 3;
	
	return TRUE;
}

/*
=================
CSQC_UpdateView

Entry point for drawing on the client
=================
*/
void CSQC_UpdateView( float fWinWidth, float fWinHeight, float fGameFocus ) {
	vVideoResolution_x = fWinWidth;
	vVideoResolution_y = fWinHeight;

	clearscene();
	setproperty( VF_DRAWENGINESBAR, 0 );
	setproperty( VF_DRAWCROSSHAIR, 0 );

	addentities( MASK_ENGINE );
	
	Nightvision_PreDraw();
	
	// When Cameratime is active, draw on the forced coords instead
	if ( fCameraTime > time ) {
		setproperty( VF_ORIGIN, vCameraPos) ;
		setproperty( VF_ANGLES, vCameraAngle );
	} else {
		setproperty( VF_ORIGIN, vPlayerOrigin + [ 0, 0, getstatf( STAT_VIEWHEIGHT ) ] );
		setproperty( VF_ANGLES, view_angles );
		View_DrawViewModel();
	}
	
	renderscene();
	
	Nightvision_PostDraw();
	
	if( fGameFocus == TRUE ) {
		// The spectator sees things... differently
		if ( getplayerkeyvalue( player_localnum, "*spectator" ) == "1" ) {
			VGUI_DrawSpectatorHUD();
		} else {
			HUD_Draw();
		}
		
		CSQC_DrawChat();
		
		// Don't even try to draw centerprints and VGUI menus when scores are shown
		if ( iShowScores == TRUE ) {
			VGUI_Scores_Show();
		} else { 
			CSQC_DrawCenterprint();
			CSQC_VGUI_Draw();
		}
	}
}

/*
=================
CSQC_UpdateViewLoading

Doesn't really do anything useful yet
=================
*/
void CSQC_UpdateViewLoading( float fWinWidth, float fWinHeight, float fGameFocus ) {
	
}
