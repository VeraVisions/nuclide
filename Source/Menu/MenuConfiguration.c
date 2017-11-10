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
			strActBind[ iCount ] = argv( 0 );
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
			drawfill( [ vPosition_x, vPosition_y - 1 ], [ 156, 10 ], '1 1 1', 0.5, 2 );
			drawstring( [vPosition_x + 8, vPosition_y], strResolution[ i ], '8 8 0', '1 1 1', 1.0f, FALSE );
		} else {
			drawstring( [vPosition_x + 8, vPosition_y], strResolution[ i ], '8 8 0', '1 1 1', fItemAlpha, FALSE );
		}
	}
	
	Object_Label( '196 148', _("VIDEO_RES"), '8 8' );
	Object_Frame( '196 160', '164 300' );
	
	Object_Scrollbar( '372 160', 284, iScrollRes );
	
	Menu_SetClipArea( '196 160', '164 300' );
	
	vector vListPos = '200 165';
	vListPos_y -= fabs( ( ( iResCount - 8 ) * 10 ) * ( iScrollRes / 300 ) );
	
	for ( int i = 0; i < iResCount; i++ ) {
		Video_DisplayRes( vListPos, i, iSelectedResolution );
		vListPos_y += 10;
	}
	
	Menu_ResetClipArea();
	
	Object_CvarToggle( '400 165', "Fullscreen", "vid_fullscreen_standalone" );
	Object_CvarToggle( '400 185', "Triple Buffering", "vid_triplebuffer" );
	Object_CvarToggle( '400 205', "Virtual Synchronisation", "vid_vsync" );
	
	Object_Button( '32 148', BTN_OK, Video_Apply, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_CANCEL, Menu_Configuration_ButtonCancel, fButtonAlpha[1] );
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
	
	Object_Label( '196 148', _("AUDIO_MASTER"), '8 8' );
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
	Object_Button( '32 148', BTN_OK, Menu_Configuration_ButtonOK, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_CANCEL, Menu_Configuration_ButtonCancel, fButtonAlpha[1] );
}

/*
=================
Menu_Configuration_Controls
=================
*/
void Menu_Configuration_Controls( void ) {
	static float fActClickTime;
	void Controls_DisplayAct( vector vPosition, int i, __inout int iSelected ) {
		float fItemAlpha = 1.0f;
		
		vPosition += vMenuOffset;
		
		if ( Menu_InputCheckMouse( [ vPosition_x, vPosition_y ], [ 397, 8 ] ) == TRUE ) {
			if ( fMouseClick == TRUE ) {
				if ( iSelected != i ) {
					iSelected = i;
					fInputKeyCode = 0;
					fMouseClick = FALSE;
					fActClickTime = time + 0.2;
				} else {
					// change bind
					iSelected = -2;
					fInputKeyCode = 0;
					fMouseClick = FALSE;
				}
			}
		} else {
			fItemAlpha = 0.8;
		}
		
		if ( iSelected == i ) {
			drawfill( [ vPosition_x, vPosition_y - 1 ], [ 397, 10 ], '1 1 1', 0.5, 2 );
			drawstring( [vPosition_x + 8, vPosition_y], strActBind[ i ], '8 8 0', '1 1 1', 1.0f, FALSE );
			drawstring( [vPosition_x + 128, vPosition_y], strActDescr[ i ], '8 8 0', '1 1 1', 1.0f, FALSE );
		} else {
			drawstring( [vPosition_x + 8, vPosition_y], strActBind[ i ], '8 8 0', '1 1 1', fItemAlpha, FALSE );
			drawstring( [vPosition_x + 128, vPosition_y], strActDescr[ i ], '8 8 0', '1 1 1', fItemAlpha, FALSE );
		}
	}
	
	static int iSelectedAct = -1;
	static int iScrollAct;
	
	Object_Button( '32 148', BTN_OK, Menu_Configuration_ButtonOK, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_CANCEL, Menu_Configuration_ButtonCancel, fButtonAlpha[1] );
	
	Object_Frame( '196 140', '404 308' );
	Object_Scrollbar( '604 140', 308, iScrollAct );
	
	Object_Label( '208 124', _("Keybind"), '8 8' );
	Object_Label( '328 124', _("Description"), '8 8' );

	Menu_SetClipArea( '196 141', '404 306' );
	vector vListPos = '200 145';
	vListPos_y -= fabs( ( ( iActCount - 8 ) * 10 ) * ( iScrollAct / 308 ) );
	
	for ( int i = 0; i < iActCount; i++ ) {
		Controls_DisplayAct( vListPos, i, iSelectedAct );
		vListPos_y += 10;
	}
	Menu_ResetClipArea();
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