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
Menu_Configuration_Init

Initializes external control scheme file, etc.
=================
*/
int iActCount;
int iResCount;
string *strActBind;
string *strActDescr;
string *strResolution;
void Menu_Configuration_Init( void ) {
	int iCount = 0;
	string sTemp;
	filestream fileSettings = fopen( "gfx/shell/kb_act.lst", FILE_READ );

	// Count the valid entries.
	if ( fileSettings >= 0 ) {
		while ( ( sTemp = fgets( fileSettings ) ) ) {			
			if ( tokenize_console( sTemp ) == 2 ) {
				iActCount++;
			}
		}
	} else {
		error( "Cannot parse gfx/shell/kb_act.lst!" );
	}
	
	// Reset filestream position after allocating the strings
	strActBind = memalloc( sizeof( string ) * iActCount );
	strActDescr = memalloc( sizeof( string ) * iActCount );
	fseek( fileSettings, 0 );
	
	// Parse the bindings in
	while ( ( sTemp = fgets( fileSettings ) ) ) {		
		// Tokenize and just parse this stuff in
		if ( tokenize_console( sTemp ) == 2 ) {
			// FTE uses +voip, so replace the GoldSrc bind with that
			if ( argv( 0 ) != "+voicerecord" ) {
				strActBind[ iCount ] = argv( 0 );
			} else {
				strActBind[ iCount ] = "+voip";
			}
			strActDescr[ iCount ] = argv( 1 );
			//print( sprintf( "%s %s\n", strActBind[ iCount ], strActDescr[ iCount ] ) );
			iCount++;
		}
	}
	fclose( fileSettings );
	
	fileSettings = fopen( "resolutions.txt", FILE_READ );
	// Count the valid entries.
	if ( fileSettings >= 0 ) {
		while ( ( sTemp = fgets( fileSettings ) ) ) {			
			if ( tokenize_console( sTemp ) == 2 ) {
				iResCount++;
			}
		}
	} else {
		error( "Cannot parse resolutions.txt!" );
	}
	
	// Reset filestream position after allocating the strings
	strResolution = memalloc( sizeof( string ) * iResCount );
	fseek( fileSettings, 0 );
	
	// Parse the bindings in
	iCount = 0;
	while ( ( sTemp = fgets( fileSettings ) ) ) {		
		strResolution[ iCount ] = sTemp;
		iCount++;
	}
	fclose( fileSettings );
}

/*
=================
Menu_Configuration_ButtonOK
=================
*/
void Menu_Configuration_ButtonOK( void ) {	
	iMenu = MENU_CONFIGURATION;
}

/*
=================
Menu_Configuration_ButtonCancel
=================
*/
void Menu_Configuration_ButtonCancel( void ) {
	iMenu = MENU_CONFIGURATION;
}

/*
=================
Menu_Configuration_Video
=================
*/
void Menu_Configuration_Video( void ) {
	static int iScrollRes = 0;
	static int iSelectedResolution = -1;
	static int iVideoScale = -1;
	
	static void Video_Apply( void ) {
		if ( iSelectedResolution != -1 ) {
			tokenizebyseparator( strResolution[ iSelectedResolution ], "x", " " );
			cvar_set( "vid_width", argv( 0 ) );
			cvar_set( "vid_height", argv( 1 ) );
			localcmd( "vid_restart\n" );
		}
	}
	
	static void Video_DisplayRes( vector vPosition, int i, __inout int iSelected ) {
		float fItemAlpha = 1.0f;
		
		vPosition += vMenuOffset;
		
		if ( Menu_InputCheckMouse( [ vPosition_x, vPosition_y ], [ 284, 8 ] ) == TRUE ) {
			if ( fMouseClick == TRUE ) {
				if ( iSelected != i ) {
					iSelected = i;
					fInputKeyCode = 0;
					fMouseClick = FALSE;
				}
			}
		} else {
			fItemAlpha = 0.8;
		}
		
		if ( iSelected == i ) {
			drawfill( [ vPosition_x, vPosition_y - 1 ], [ 156, 10 ], autocvar_menu_fgcolor, 0.5, 2 );
			drawstring( [vPosition_x + 8, vPosition_y], strResolution[ i ], '12 12', autocvar_menu_fgcolor, 1.0f, FALSE );
		} else {
			drawstring( [vPosition_x + 8, vPosition_y], strResolution[ i ], '12 12', autocvar_menu_fgcolor, fItemAlpha, FALSE );
		}
	}
	
	// Get the current scale method... and resolution
	if ( iVideoScale == -1 ) {
		if ( cvar( "vid_conautoscale" ) == 0 ) {
			iVideoScale = 1;
		} else {
			iVideoScale = 0;
		}
		
		for ( int i = 1; i < iResCount; i++ ) {
			tokenizebyseparator( strResolution[ i ], "x", " " );
			if ( ( stof( argv( 0 ) ) == vVideoSize_x && ( stof( argv( 1 ) ) == vVideoSize_y ) ) ) {
				iSelectedResolution = i;
			}
		}
	}
	
	Object_Label( '196 148', _("VIDEO_RES"), '12 12' );
	Object_Frame( '196 160', '164 300' );
	
	Object_Scrollbar( '372 160', 284, iScrollRes );
	
	Menu_SetClipArea( '196 162', '164 298' );
	
	vector vListPos = '200 165';
	vListPos_y -= fabs( ( ( iResCount - 8 ) * 10 ) * ( iScrollRes / 300 ) );
	
	for ( int i = 0; i < iResCount; i++ ) {
		Video_DisplayRes( vListPos, i, iSelectedResolution );
		vListPos_y += 10;
	}
	
	Menu_ResetClipArea();
	
	static void Video_ScaleSwitch( void ) {
		iVideoScale = 1 - iVideoScale;
		if ( iVideoScale == 1 ) {
			cvar_set( "vid_conautoscale", "0" );
			cvar_set( "vid_conwidth", "0" );
			cvar_set( "vid_conheight", "480" );
		} else {
			cvar_set( "vid_conautoscale", "1" );
		}
	}
	
	Object_CvarToggle( '400 165', "Fullscreen", "vid_fullscreen" );
	Object_CvarToggle( '400 185', "Triple Buffering", "vid_triplebuffer" );
	Object_CvarToggle( '400 205', "Virtual Synchronisation", "vid_vsync" );
	Object_FuncToggle( '400 225', "HDPI Mode", Video_ScaleSwitch, iVideoScale );
	
	drawtextfield( vMenuOffset + '400 265', '200 200', 1, _("VIDEO_RESTARTMSG") ) ;
	
	Object_Button( '32 148', BTN_REFRESH, Video_Apply, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_DONE, Menu_Configuration_ButtonCancel, fButtonAlpha[1] );
}

/*
=================
Menu_Configuration_Audio
=================
*/
void Menu_Configuration_Audio( void ) {
	static int iAudioMaster = -1;
	static int iLastMaster = -1;
	
	// Page is first opened, initialize the scrollbar variables
	if ( iAudioMaster == -1 ) {
		iAudioMaster = cvar( "volume" ) * 256;
		iLastMaster = iAudioMaster;
	}
	
	Object_Label( '196 148', _("AUDIO_MASTER"), '12 12' );
	Object_ScrollbarH( '196 160', 256, iAudioMaster );
	
	if ( iAudioMaster != iLastMaster ) {
		localcmd( sprintf( "volume %f\n", iAudioMaster / 256 ) );
		iLastMaster = iAudioMaster;
	}
	
	Object_Button( '32 148', BTN_OK, Menu_Configuration_ButtonOK, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_CANCEL, Menu_Configuration_ButtonCancel, fButtonAlpha[1] );
}

/*
=================
Menu_Configuration_Player
=================
*/
void Menu_Configuration_Player( void ) {
	static string strPlayername;
	static int iFirst = 1;
	static color cCross;
	static color cVGUI;
	static color cCon;
	
	static void Player_OK( void ) {
		if ( strPlayername != __NULL__ ) {
			localcmd( sprintf( "name %s\n", strPlayername ) );
			iMenu = MENU_CONFIGURATION;
		} else {
			strPlayername = cvar_string( "name" );
		}
		
		cvar_set( "cross_color", sprintf( "%i %i %i", cCross.iR, cCross.iG, cCross.iB ) );
		cvar_set( "vgui_color", sprintf( "%i %i %i", cVGUI.iR, cVGUI.iG, cVGUI.iB ) );
		cvar_set( "con_color", sprintf( "%i %i %i", cCon.iR, cCon.iG, cCon.iB ) );
	}
	
	if ( iFirst == 1 ) {
		float fCheck;
		strPlayername = cvar_string( "name" );
	
		fCheck = tokenize( cvar_string( "cross_color" ) );
		if ( fCheck == 3 ) {
			cCross.iR = stof( argv( 0 ) );
			cCross.iG = stof( argv( 1 ) );
			cCross.iB = stof( argv( 2 ) );
		} else {
			// TODO... put this in a more global location? If this is changed, change Defs.h in Source/Client too!
			cCross.iR = 0;
			cCross.iG = 255;
			cCross.iB = 0;
			cvar_set( "cross_color", "0 255 0" );
		}
		
		fCheck = tokenize( cvar_string( "vgui_color" ) );
		if ( fCheck == 3 ) {
			cVGUI.iR = stof( argv( 0 ) );
			cVGUI.iG = stof( argv( 1 ) );
			cVGUI.iB = stof( argv( 2 ) );
		} else {
			cVGUI.iR = 255;
			cVGUI.iG = 170;
			cVGUI.iB = 0;
			cvar_set( "vgui_color", "255 170 0" );
		}
		
		fCheck = tokenize( cvar_string( "con_color" ) );
		if ( fCheck == 3 ) {
			cCon.iR = stof( argv( 0 ) );
			cCon.iG = stof( argv( 1 ) );
			cCon.iB = stof( argv( 2 ) );
		} else {
			cCon.iR = 255;
			cCon.iG = 170;
			cCon.iB = 0;
			cvar_set( "con_color", "255 170 0" );
		}
		
		iFirst = 0;
	}
	
	Object_Label( '196 148', _("PLAYER_NICK"), '12 12' );
	Object_Textfield( '196 160', strPlayername, 16 );
	
	Object_Label( '196 200', _("PLAYER_CROSSCOLOR"), '12 12' );
	Object_ScrollbarH( '196 212', 255, cCross.iR );
	Object_ScrollbarH( '196 230', 255, cCross.iG );
	Object_ScrollbarH( '196 248', 255, cCross.iB );
	Object_Frame( '468 388', '52 52' );
	drawfill( vMenuOffset + '469 213', '50 50', [ cCross.iR / 255, cCross.iG / 255, cCross.iB / 255 ], 1.0f );
	
	Object_Label( '196 288', _("PLAYER_GUICOLOR"), '12 12' );
	Object_ScrollbarH( '196 300', 255, cVGUI.iR );
	Object_ScrollbarH( '196 318', 255, cVGUI.iG );
	Object_ScrollbarH( '196 336', 255, cVGUI.iB );
	Object_Frame( '468 388', '52 52' );
	drawfill( vMenuOffset + '469 300', '50 50', [ cVGUI.iR / 255, cVGUI.iG / 255, cVGUI.iB / 255 ], 1.0f );
	
	Object_Label( '196 376', _("PLAYER_HUDCOLOR"), '12 12' );
	Object_ScrollbarH( '196 388', 255, cCon.iR );
	Object_ScrollbarH( '196 406', 255, cCon.iG );
	Object_ScrollbarH( '196 424', 255, cCon.iB );
	Object_Frame( '468 388', '52 52' );
	drawfill( vMenuOffset + '469 388', '50 50', [ cCon.iR / 255, cCon.iG / 255, cCon.iB / 255 ], 1.0f );
	
	Object_Button( '32 148', BTN_OK, Player_OK, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_CANCEL, Menu_Configuration_ButtonCancel, fButtonAlpha[1] );
}

/*
=================
Menu_Configuration_Controls
=================
*/
void Menu_Configuration_Controls( void ) {
	static float fActClickTime;
	static int iBindKey = -1;
	
	void Controls_Default( void ) {
		localcmd( "unbindall\nexec default.cfg\n" );
	}
	
	void Controls_DisplayAct( vector vPosition, int i, __inout int iSelected ) {
		float fItemAlpha = 0.8f;
		
		float fBindKey = tokenize( findkeysforcommand( strActBind[ i ] ) );
		string sBindTx = "";
		float j, k;
		
		for( j = 0; j < fBindKey; ++j ) {
			k = stof( argv( j ) );
			if( k != -1 ) {
				if( sBindTx != "" ) {
					sBindTx = strcat( sBindTx, ", " );
				}
				sBindTx = strcat( sBindTx, keynumtostring( k ) );
			}
		}
		
		vPosition += vMenuOffset;
		
		if ( Menu_InputCheckMouse( [ vPosition_x, vPosition_y ], [ 397, 8 ] ) == TRUE ) {
			if ( strActBind[ i ] != "blank" ) {
				fItemAlpha = 1.0f;
				if ( fMouseClick == TRUE ) {
					if ( iSelected != i ) {
						iSelected = i;
						fInputKeyCode = 0;
						fMouseClick = FALSE;
						fActClickTime = time + 0.2;
					} else {
						// change bind
						iBindKey = iSelected;
						fInputKeyCode = 0;
						fMouseClick = FALSE;
					}
				}
			}
		}
		
		if ( iSelected == i ) {
			drawfill( [ vPosition_x, vPosition_y - 1 ], [ 397, 14 ], autocvar_menu_fgcolor, 0.5, 2 );
			drawstring( [vPosition_x + 8, vPosition_y], sBindTx, '12 12', autocvar_menu_fgcolor, 1.0f, FALSE );
			drawstring( [vPosition_x + 128, vPosition_y], strActDescr[ i ], '12 12', autocvar_menu_fgcolor, 1.0f, FALSE );
		} else {
			drawstring( [vPosition_x + 8, vPosition_y], sBindTx, '12 12', autocvar_menu_fgcolor, fItemAlpha, FALSE );
			drawstring( [vPosition_x + 128, vPosition_y], strActDescr[ i ], '12 12', autocvar_menu_fgcolor, fItemAlpha, FALSE );
		}
	}
	
	static int iSelectedAct = -1;
	static int iScrollAct;
	
	Object_Button( '32 148', BTN_OK, Menu_Configuration_ButtonOK, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_CANCEL, Menu_Configuration_ButtonCancel, fButtonAlpha[1] );
	Object_Button( '32 244', BTN_DEFAULTS, Controls_Default, fButtonAlpha[2] );
	
	Object_Frame( '196 140', '404 308' );
	Object_Scrollbar( '604 140', 308, iScrollAct );
	
	Object_Label( '208 124', _("Keybind"), '12 12' );
	Object_Label( '328 124', _("Description"), '12 12' );

	Menu_SetClipArea( '196 141', '404 306' );
	vector vListPos = '200 145';
	vListPos_y -= fabs( ( ( iActCount - rint( 308 / iActCount ) ) * 10 ) * ( iScrollAct / 308 ) );
	
	for ( int i = 0; i < iActCount; i++ ) {
		Controls_DisplayAct( vListPos, i, iSelectedAct );
		vListPos_y += 14;
	}
	Menu_ResetClipArea();
	
	if ( iBindKey >= 0 ) {
		Object_Frame( '196 150', '404 100' );
		drawstring( vMenuOffset + '216 170', "Press any button to assign it to:", '12 12', autocvar_menu_fgcolor, 1.0f, FALSE );
		drawstring( vMenuOffset + '216 232', "To clear, press Backspace.", '12 12', autocvar_menu_fgcolor, 1.0f, FALSE );
		drawstring( vMenuOffset + '216 190', strActDescr[ iBindKey ], '16 16', autocvar_menu_fgcolor, 1.0f, FALSE );
		
		if ( fInputKeyCode > 0 ) {
			if( fInputKeyCode == K_BACKSPACE ) {
				float fBindKey = tokenize( findkeysforcommand( strActBind[ iBindKey ] ) );
				
				for ( int i = 0; i < fBindKey; i++ ) {
					localcmd( sprintf( "unbind %s\n", keynumtostring( stof( argv( i ) ) ) ) );
				}
					
				iBindKey = -1;
				fInputKeyCode = 0;
				fInputKeyASCII = 0;
			} else if ( fInputKeyCode != K_ESCAPE ) {
				localcmd( sprintf( "bind %s %s\n", keynumtostring( fInputKeyCode ), strActBind[ iBindKey ] ) );
				iBindKey = -1;
				fInputKeyCode = 0;
				fInputKeyASCII = 0;
			} else {
				iBindKey = -1;
				fInputKeyCode = 0;
				fInputKeyASCII = 0;
			}
		}
	}
}

/*
=================
Menu_Configuration

First config screen
=================
*/
void Menu_Configuration( void ) {
	static void Configuration_ButtonAudio( void ) {
		iMenu = MENU_CONFIGURATION_AUDIO;
	}
	static void Configuration_ButtonVideo( void ) {
		iMenu = MENU_CONFIGURATION_VIDEO;
	}
	static void Configuration_ButtonCustomize( void ) {
		iMenu = MENU_CONFIGURATION_PLAYER;
	}
	static void Configuration_ButtonControls( void ) {
		iMenu = MENU_CONFIGURATION_CONTROLS;
	}
	static void Configuration_ButtonDone( void ) {
		iMenu = MENU_MAIN;
	}
	Object_Button( '32 148', BTN_AUDIO, Configuration_ButtonAudio, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_VIDEO, Configuration_ButtonVideo, fButtonAlpha[1] );
	Object_Button( '32 212', BTN_CUSTOMIZE, Configuration_ButtonCustomize, fButtonAlpha[2] );
	Object_Button( '32 244', BTN_CONTROLS, Configuration_ButtonControls, fButtonAlpha[3] );
	Object_Button( '32 276', BTN_DONE, Configuration_ButtonDone, fButtonAlpha[4] );
}
