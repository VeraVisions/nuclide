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

// Server fields!
float fldName;
float fldAddress;
float fldPing;
float fldPlayers;
float fldMaxplayers;
float fldMap;
float fldTimelimit;
float fldFraglimit;
float fServerClickTime;

/*
=================
Menu_Multiplayer_Connect

Connect to a specific ServerID from the hostcache
=================
*/
void Menu_Multiplayer_Connect( int iServerID ) {
	// Filter dead entries 
	if ( gethostcachenumber( fldMaxplayers, iServerID ) <= 0 ) {
		return;
	}
	
	// Connect as long as a real server is actually selected
	if ( iServerID >= 0 ) {
		localcmd( sprintf( "connect %s\n", gethostcachestring( fldAddress, iServerID ) ) );
		m_hide();
	}
}

/*
=================
Menu_Multiplayer_Find_Item

Draw a single server item from the hostcache
=================
*/
void Menu_Multiplayer_Find_Item( vector vPosition, int i, __inout int iSelected ) {
	float fItemAlpha = 1.0f;
	
	vPosition += vMenuOffset;
	
	if ( Menu_InputCheckMouse( [ vPosition_x, vPosition_y ], [ 397, 8 ] ) == TRUE ) {
		if ( fMouseClick == TRUE ) {
			if ( iSelected != i ) {
				iSelected = i;
				fInputKeyCode = 0;
				fMouseClick = FALSE;
				fServerClickTime = time + 0.2;
			} else {
				if ( fServerClickTime > time ) {
					Menu_Multiplayer_Connect( i );
				}
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
		drawstring( [vPosition_x + 8, vPosition_y], sprintf( "%.25s", gethostcachestring( fldName, i ) ), '8 8 0', '1 1 1', 1.0f, FALSE );
		drawstring( [vPosition_x + 218, vPosition_y], sprintf( "%.10s", gethostcachestring( fldMap, i ) ), '8 8 0', '1 1 1', 1.0f, FALSE );
		drawstring( [vPosition_x + 298, vPosition_y], sprintf( "%d/%d", gethostcachenumber( fldPlayers, i ), gethostcachenumber( fldMaxplayers, i ) ), '8 8 0', '1 1 1', 1.0f, FALSE );
		drawstring( [vPosition_x + 362, vPosition_y], sprintf( "%.3s", ftos( gethostcachenumber( fldPing, i ) ) ), '8 8 0', '1 1 1', 1.0f, FALSE );
	} else {
		drawstring( [vPosition_x + 8, vPosition_y], sprintf( "^3%.25s", gethostcachestring( fldName, i ) ), '8 8 0', '1 1 1', fItemAlpha, FALSE );
		drawstring( [vPosition_x + 218, vPosition_y], sprintf( "%.10s", gethostcachestring( fldMap, i ) ), '8 8 0', '1 1 1', fItemAlpha, FALSE );
		drawstring( [vPosition_x + 298, vPosition_y], sprintf( "%d/%d", gethostcachenumber( fldPlayers, i ), gethostcachenumber( fldMaxplayers, i ) ), '8 8 0', '1 1 1', fItemAlpha, FALSE );
		drawstring( [vPosition_x + 362, vPosition_y], sprintf( "%.3s", ftos( gethostcachenumber( fldPing, i ) ) ), '8 8 0', '1 1 1', fItemAlpha, FALSE );
	}
}

/*
=================
Menu_Multiplayer

First mulitplayer screen with the server browser
=================
*/
void Menu_Multiplayer( void ) {
	static int iSelectedServer = -1;
	static int iScrollServer;
	static int iServersTotal;
	
	static void Multiplayer_ButtonCreate( void ) {
		iMenu = MENU_MULTIPLAYER_CREATE;
	}
	static void Multiplayer_ButtonRefresh( void ) {
		refreshhostcache();
		resorthostcache();
	}
	static void Multiplayer_ButtonDone( void ) {
		iMenu = MENU_MAIN;
	}
	
	// Initialize it on the first run
	if ( iSelectedServer == -1 ) {
		localcmd( "com_protocolname FTE-Quake\n" );
		//clear the filter
		resethostcachemasks();
		//sethostcachemaskstring( 0, gethostcacheindexforkey( "gamedir" ), "freecs", SLIST_TEST_EQUAL );
		sethostcachesort( gethostcacheindexforkey( "ping" ), FALSE );
		refreshhostcache();
		resorthostcache();
		iSelectedServer = 0;
	}
	
	fldName = gethostcacheindexforkey("name");
	fldAddress = gethostcacheindexforkey("cname");
	fldPing = gethostcacheindexforkey("ping");
	fldPlayers = gethostcacheindexforkey("numhumans");
	fldMaxplayers = gethostcacheindexforkey("maxplayers");
	fldMap = gethostcacheindexforkey("map");
	fldTimelimit = gethostcacheindexforkey("timelimit");
	fldFraglimit = gethostcacheindexforkey("fraglimit");
	
	iServersTotal = gethostcachevalue( SLIST_HOSTCACHEVIEWCOUNT );
	
	Menu_SetClipArea( '32 148', '164 160' );
	Object_Button( '32 148', BTN_JOINGAME, __NULL__, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_CREATE, Multiplayer_ButtonCreate, fButtonAlpha[1] );
	Object_Button( '32 212', BTN_GAMEINFO, __NULL__, fButtonAlpha[2] );
	Object_Button( '32 244', BTN_REFRESHLIST, Multiplayer_ButtonRefresh, fButtonAlpha[3] );
	Object_Button( '32 276', BTN_DONE, Multiplayer_ButtonDone, fButtonAlpha[4] );
	Menu_ResetClipArea();
	
	Object_Frame( '196 140', '404 308' );
	Object_Scrollbar( '604 140', 308, iScrollServer );
	
	Object_Label( '208 124', _("MP_GAME"), '8 8' );
	Object_Label( '418 124', _("MP_MAP"), '8 8' );
	Object_Label( '498 124', _("MP_PLAYERS"), '8 8' );
	Object_Label( '562 124', _("MP_PING"), '8 8' );
	
	Menu_SetClipArea( '196 141', '404 306' );
	vector vListPos = '200 145';
	vListPos_y -= fabs( ( ( iServersTotal - 8 ) * 10 ) * ( iScrollServer / 308 ) );
	
	for ( int i = 0; i < iServersTotal; i++ ) {
		Menu_Multiplayer_Find_Item( vListPos, i, iSelectedServer );
		vListPos_y += 10;
	}
	Menu_ResetClipArea();
}

/*
=================
Menu_Multiplayer_Create

Server creation menu screen
=================
*/
void Menu_Multiplayer_Create( void ) {
	static int iSelectedMap;
	static int iScrollMap;
	
	static void Create_ListMap( vector vPosition, int iIndex ) {
		float fAlpha = 0.8;
		vPosition += vMenuOffset;
		
		if ( iScrollbarHold == FALSE ) {
			if ( Menu_InputCheckMouse( vPosition, '182 10' ) == TRUE ) {
				if ( fMouseClick == TRUE ) {
					iSelectedMap = iIndex;
					fMouseClick = FALSE;
				}
				fAlpha = 1.0f;
			}
		}
		
		if ( iSelectedMap == iIndex ) {
			drawfill( [ vPosition_x, vPosition_y - 1 ], [ 182, 10 ], '1 1 1', 0.5, 2 );
			drawstring( vPosition, sMapList[ iIndex ], '8 8', '1 1 1', 1.0f, 0 );	
		} else {
			drawstring( vPosition, sMapList[ iIndex ], '8 8', '0.9 0.9 0.9', fAlpha, 0 );
		}
	}
	static void Create_ButtonAdvanced( void ) {
		// Advanced options
		iMenu = MENU_MULTIPLAYER_OPTIONS;
	}
	static void Create_ButtonOK( void ) {
		// Start server
		localcmd( sprintf( "map %s\n", sMapList[ iSelectedMap ] ) );
	}
	static void Create_ButtonCancel( void ) {
		iMenu = MENU_MULTIPLAYER;
	}
	
	Object_Button( '32 148', BTN_ADVOPTIONS, Create_ButtonAdvanced, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_OK, Create_ButtonOK, fButtonAlpha[1] );
	Object_Button( '32 212', BTN_CANCEL, Create_ButtonCancel, fButtonAlpha[2] );
	
	Object_Label( '384 148', _("MP_MAPS"), '8 8' );
	Object_Frame( '384 164', '190 288' );
	Object_Scrollbar( '576 164', 288, iScrollMap );
	
	// Maplist
	vector vListPos = '392 172';
	Menu_SetClipArea( '386 166', '188 286' );
	vListPos_y -= fabs( ( ( iMapCount - 21 ) * 10 ) * ( iScrollMap / 288 ) );
	for ( int i = 0; i < iMapCount; i++ ) {
		Create_ListMap( vListPos, i );
		vListPos_y += 10;
	}
	Menu_ResetClipArea();
}