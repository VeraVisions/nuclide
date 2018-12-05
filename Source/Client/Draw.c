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

#define CHAT_LINES 	5
#define CHAT_TIME 	20
var int iLineScroll = 0;

float fChatTime;
float fChatAlpha;
string sMSGBuffer[ CHAT_LINES ];

/*
=================
CSQC_Parse_Print

Receives a message and sorts it into the chat messagebuffer
=================
*/
void CSQC_Parse_Print(string sMessage, float fLevel ) {
	// This gives messages other than chat an orange tint
	if ( fLevel != PRINT_CHAT ) {
		sMessage = sprintf( "^xF80%s", sMessage );
	}
	
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
	fChatAlpha = 1.0f;
	
	// Log to console
	localcmd( sprintf( "echo \"%s\"\n", sMessage ) );
}

/*
=================
CSQC_DrawChat

Just prints whatever is in the chat buffer and removes lines after some time.
=================
*/
void CSQC_DrawChat( void ) {
	vector vChatPos = vVideoMins + [ 16, vVideoResolution_y - 128 ];
	
	// Remove messages after a fChatTime has passed
	if ( fChatTime < time ) {
		fChatAlpha -= frametime;
	} else {
		fChatAlpha = 1.0f;
	}
	
	if ( fChatAlpha > 0.0f ) {
#if 1
		for ( int i = 0; i < CHAT_LINES; i++ ) {
			drawstring( vChatPos, sMSGBuffer[ i ], '12 12', '1 1 1', fChatAlpha, 0 );
			vChatPos_y += 14;
		}
#else
		string sDraw = sMSGBuffer[ 0 ];
		for ( int i = 1; i < CHAT_LINES; i++ ) {
			sDraw = sprintf( "%s\n%s\n", sDraw, sMSGBuffer[ i ] );
		}
		
		drawtextfield( vChatPos, [vVideoResolution_x - 32, CHAT_LINES * 12 ], 1, sDraw );
#endif
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
	
	vCenterPrintPos_y = vVideoMins_y + ( vVideoResolution_y / 2 ) - ( fCenterPrintLines - 4 );
	
	for ( int i = 0; i < ( fCenterPrintLines ); i++ ) {
		vCenterPrintPos_x = vVideoMins_x + ( vVideoResolution_x / 2 ) - ( stringwidth( sCenterPrintBuffer[ i ], TRUE, '12 12' ) / 2 );
		drawstring( vCenterPrintPos, sCenterPrintBuffer[ i ], '12 12', '1 1 1', fCenterPrintAlpha, 0 );
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
		sCenterPrintBuffer[ i ] = sprintf( "^xF80%s", argv( i ) );
	}
	
	fCenterPrintAlpha = 1;
	fCenterPrintTime = time + 3;
	
	return TRUE;
}

void CSQC_CalcViewport( int s, float fWinWidth, float fWinHeight ) {
	//FIXME: this is awkward. renderscene internally rounds to pixels.
	//on the other hand, drawpic uses linear filtering and multisample and stuff.
	//this means that there can be a pixel or so difference between scene and 2d.
	//as a general rule, you won't notice unless there's some big drawfills.
	switch ( numclientseats ) {
	case 3:
		if ( !s ) {
	case 2:
		vVideoResolution = [ fWinWidth, fWinHeight * 0.5 ];
		vVideoMins = [ 0, ( s & 1 ) * vVideoResolution_y ];
		break;
		}
		s++;
	case 4:
		vVideoResolution = [ fWinWidth, fWinHeight ] * 0.5;
		vVideoMins = [ (s&1) * vVideoResolution_x, ( s / 2i ) * vVideoResolution_y ];
		break;
	default:
		vVideoResolution = [ fWinWidth, fWinHeight ];
		vVideoMins = [ 0, 0 ];
		break;
	}
}

/*
=================
CSQC_UpdateView

Entry point for drawing on the client
=================
*/
void CSQC_UpdateView( float fWinWidth, float fWinHeight, float fGameFocus ) {
	float needcursor;
	int s;
	vVideoResolution_x = fWinWidth;
	vVideoResolution_y = fWinHeight;

	clearscene();
	setproperty( VF_DRAWENGINESBAR, 0 );
	setproperty( VF_DRAWCROSSHAIR, 0 );

	//just in case...
	if ( numclientseats > seats.length ) {
		numclientseats = seats.length;
	}
	
	for ( s = seats.length; s-- > numclientseats; ) {
		pSeat = &seats[ s ];
		pSeat->fVGUI_Display = VGUI_MOTD;
		pSeat->ePlayer = world;
	}
	for ( s = numclientseats; s-- > 0; ) {
		pSeat = &seats[ s ];
		setproperty( VF_ACTIVESEAT, (float)s );
		pSeat->ePlayer = self = findfloat( world, entnum, player_localentnum );
		if ( self ) {
			Player_Predict();
		}
	}

	addentities( MASK_ENGINE );

	// Render 3D Game Loop
	for ( s = 0; s < numclientseats; s++ ) {
		pSeat = &seats[ s ];
		setproperty( VF_ACTIVESEAT, (float)s );
		Nightvision_PreDraw();

		// Don't hide the player entity
		if ( autocvar_cl_thirdperson == TRUE && getstatf( STAT_HEALTH ) ) {
			setproperty( VF_VIEWENTITY, (float)0 );
		} else {
			setproperty( VF_VIEWENTITY, (float)player_localentnum );
		}
	
		setproperty( VF_AFOV, cvar( "fov" ) * ( getstatf( STAT_VIEWZOOM ) ) );
		setsensitivityscaler( ( getstatf( STAT_VIEWZOOM ) ) );
	
		// When Cameratime is active, draw on the forced coords instead
		if ( pSeat->fCameraTime > time ) {
			setproperty( VF_ORIGIN, pSeat->vCameraPos ) ;
		} else {
			if ( getstatf( STAT_HEALTH ) ) {
				if ( autocvar_cl_thirdperson == TRUE  ) {
					makevectors( view_angles );
					vector vStart = [ pSeat->vPlayerOrigin[0], pSeat->vPlayerOrigin[1], pSeat->vPlayerOrigin[2] + 16 ] + ( v_right * 4 );
					vector vEnd = vStart + ( v_forward * -48 ) + '0 0 16' + ( v_right * 4 );
					traceline( vStart, vEnd, FALSE, self );
					setproperty( VF_ORIGIN, trace_endpos + ( v_forward * 5 ) );
				} else {
					setproperty( VF_ORIGIN, pSeat->vPlayerOrigin + [ 0, 0, getstatf( STAT_VIEWHEIGHT ) ] );
				}
			} else {
				setproperty( VF_ORIGIN, pSeat->vPlayerOrigin );
			}
			View_DrawViewModel();
		}
	
		CSQC_CalcViewport( s, fWinWidth, fWinHeight );
		setproperty( VF_MIN, vVideoMins );
		setproperty( VF_SIZE, vVideoResolution );
		setproperty( VF_ANGLES, view_angles + pSeat->vPunchAngle );
		setproperty( VF_DRAWWORLD, 1 );
		renderscene();
	}
	
	// Render Overlays, such as the HUD
	for ( s = 0; s < numclientseats; s++ ) {
		pSeat = &seats[ s ];
		setproperty( VF_ACTIVESEAT, (float)s );
		
		CSQC_CalcViewport( s, fWinWidth, fWinHeight );
		View_DropPunchAngle();
		Nightvision_PostDraw();

		if( fGameFocus == TRUE ) {
			// The spectator sees things... differently
			if ( getplayerkeyvalue( player_localnum, "*spec" ) != "0" ) {
				VGUI_DrawSpectatorHUD();
			} else {
				HUD_Draw();
			}
			
			HUD_DrawOrbituaries();
			HUD_DrawVoice();
			CSQC_DrawChat();
			
			// Don't even try to draw centerprints and VGUI menus when scores are shown
			if ( pSeat->iShowScores == TRUE || getstatf( STAT_GAMESTATE ) == GAME_OVER ) {
				VGUI_Scores_Show();
			} else { 
				CSQC_DrawCenterprint();
				needcursor |= CSQC_VGUI_Draw();
			}
		}
	}
	
	pSeat = (void*)0x70000000i;
	
	if ( needcursor ) {
		setcursormode( TRUE, "gfx/cursor", '0 0 0', 1.0f );
	} else {
		setcursormode( FALSE, "gfx/cursor", '0 0 0', 1.0f );
	}
	
	Sound_ProcessWordQue();
}

/*
=================
CSQC_UpdateViewLoading

Doesn't really do anything useful yet
=================
*/
void CSQC_UpdateViewLoading( float fWinWidth, float fWinHeight, float fGameFocus ) {
	drawfill( [ 0, 0 ], [ fWinWidth, fWinHeight ], [ 1, 1, 1 ], 1, 0 );
}
