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

float fldName;
float fldAddress;
float fldPing;
float fldPlayers;
float fldMaxplayers;
float fldMap;
float fldTimelimit;
float fldFraglimit;
float fMaxServers;
float fServerClickTime;

void Menu_Multiplayer_Connect( int iServerID ) {
	if ( gethostcachenumber( fldMaxplayers, iServerID ) <= 0 ) {
		return;
	}
	
	if ( iServerID >= 0 ) {
		localcmd( sprintf( "connect %s\n", gethostcachestring( fldAddress, iServerID ) ) );
		m_hide();
	}
}

void Menu_Multiplayer_Find_Item( float fPos, int i, __inout int iSelected ) {
	float fButtonAlpha = fMenuAlpha;
	
	if ( Menu_InputCheckMouse( [ 47, fPos ], [ 314, 8 ] ) == TRUE ) {
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
		fButtonAlpha *= 0.5;
	}
	
	if ( iSelected == i ) {
		drawmenufill( [ 40, fPos - 1 ], [ 323, 10 ], '1 1 1', fMenuAlpha * 0.5, 2 );
		drawmenustring( [48, fPos], sprintf( "%.16s", gethostcachestring( fldName, i ) ), '8 8 0', '1 1 1', fMenuAlpha, FALSE );
		drawmenustring( [184, fPos], sprintf( "%.10s", gethostcachestring( fldMap, i ) ), '8 8 0', '1 1 1', fMenuAlpha,  FALSE );
		drawmenustring( [264, fPos], sprintf( "%d/%d", gethostcachenumber( fldPlayers, i ), gethostcachenumber( fldMaxplayers, i ) ), '8 8 0', '1 1 1', fMenuAlpha, FALSE );
		drawmenustring( [328, fPos], sprintf( "%.3s", ftos( gethostcachenumber( fldPing, i ) ) ), '8 8 0', '1 1 1', fMenuAlpha, FALSE );
	} else {
		drawmenustring( [48, fPos], sprintf( "^2%.16s", gethostcachestring( fldName, i ) ), '8 8 0', '1 1 1', fButtonAlpha, FALSE );
		drawmenustring( [184, fPos], sprintf( "%.10s", gethostcachestring( fldMap, i ) ), '8 8 0', '1 1 1', fButtonAlpha, FALSE );
		drawmenustring( [264, fPos], sprintf( "%d/%d", gethostcachenumber( fldPlayers, i ), gethostcachenumber( fldMaxplayers, i ) ), '8 8 0', '1 1 1', fButtonAlpha,  FALSE );
		drawmenustring( [328, fPos], sprintf( "%.3s", ftos( gethostcachenumber( fldPing, i ) ) ), '8 8 0', '1 1 1', fButtonAlpha, FALSE );
	}
}

void m_button_findserver( void ) {
	static int iSelectedServer = -1;
	static float fServerOffset;
	
	static void Menu_Multiplayer_Find_Refresh( void ) {
		refreshhostcache();
		resorthostcache();
	}
	static void Menu_Multiplayer_Find_ScrollDown( void ) {
		fServerOffset++;
		if ( fServerOffset > fMaxServers ) {
			fServerOffset = fMaxServers;
		}
	}
	static void Menu_Multiplayer_Find_ScrollUp( void ) {
		fServerOffset--;
		if ( fServerOffset < 0 ) {
			fServerOffset = 0;
		}
	}
	static void Menu_Multiplayer_Find_Connect( void ) {
		Menu_Multiplayer_Connect( iSelectedServer );
	}
	
	m_drawmenushadow();
	drawmenustring( '43 60 0', "FIND SERVER", '16 16 0', '1 1 1', fMenuAlpha, FALSE );
	
	if ( iSelectedServer == -1 ) {
		localcmd( "com_protocolname FTE-Quake\n" );
		//clear the filter
		resethostcachemasks();
		sethostcachemaskstring( 0, gethostcacheindexforkey("gamedir"), "freecs", SLIST_TEST_EQUAL );
		sethostcachesort( gethostcacheindexforkey( "ping" ), FALSE );
		refreshhostcache();
		resorthostcache();
		iSelectedServer = 0;
	}
	
	fMaxServers = gethostcachevalue( SLIST_HOSTCACHEVIEWCOUNT );
	if ( fMaxServers >= 28 ) {
		fMaxServers -= 28;
	}
	
	fldName = gethostcacheindexforkey("name");
	fldAddress = gethostcacheindexforkey("cname");
	fldPing = gethostcacheindexforkey("ping");
	fldPlayers = gethostcacheindexforkey("numhumans");
	fldMaxplayers = gethostcacheindexforkey("maxplayers");
	fldMap = gethostcacheindexforkey("map");
	fldTimelimit = gethostcacheindexforkey("timelimit");
	fldFraglimit = gethostcacheindexforkey("fraglimit");
		
	drawmenustring( '48 100 0', "Name", '8 8 0', '1 1 1', fMenuAlpha, FALSE );
	drawmenustring( '184 100 0', "Map", '8 8 0', '1 1 1', fMenuAlpha, FALSE );
	drawmenustring( '264 100 0', "Players", '8 8 0', '1 1 1', fMenuAlpha, FALSE );
	drawmenustring( '328 100 0', "Ping", '8 8 0', '1 1 1', fMenuAlpha, FALSE );
	
	float fPos = 120;
	for ( float i = fServerOffset; i < ( 28 + fServerOffset ); i++ ) {
		Menu_Multiplayer_Find_Item( fPos, i, iSelectedServer );
		fPos += 10;
	}
	
	menu_buttoncmd( '128 410', "Refresh", '8 8', Menu_Multiplayer_Find_Refresh );
	menu_buttoncmd( '280 420', "Connect >>", '8 8', Menu_Multiplayer_Find_Connect );
	
	// Scrollbars
	menu_buttoncmd( '368 100', "<", '8 8', Menu_Multiplayer_Find_ScrollUp );
	menu_buttoncmd( '368 400', ">", '8 8', Menu_Multiplayer_Find_ScrollDown );
}
