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
string *strActBind;
string *strActDescr;
void Menu_Configuration_Init( void ) {
	int iCount = 0;
	string sTemp;
	filestream fileActList = fopen( "gfx/shell/kb_act.lst", FILE_READ );

	// Count the valid entries.
	if ( fileActList >= 0 ) {
		while ( ( sTemp = fgets( fileActList ) ) ) {			
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
	fseek( fileActList, 0 );
	
	// Parse the bindings in
	while ( ( sTemp = fgets( fileActList ) ) ) {		
		// Tokenize and just parse this stuff in
		if ( tokenize_console( sTemp ) == 2 ) {
			strActBind[ iCount ] = argv( 0 );
			strActDescr[ iCount ] = argv( 1 );
			//print( sprintf( "%s %s\n", strActBind[ iCount ], strActDescr[ iCount ] ) );
			iCount++;
		}
	}
	fclose( fileActList );
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
	Object_Button( '32 148', BTN_OK, Menu_Configuration_ButtonOK, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_CANCEL, Menu_Configuration_ButtonCancel, fButtonAlpha[1] );
}

/*
=================
Menu_Configuration_Audio
=================
*/
void Menu_Configuration_Audio( void ) {
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