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

// Server fields!
float fldName;
float fldAddress;
float fldPing;
float fldPlayers;
float fldMaxplayers;
float fldMap;
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
				fServerClickTime = time + 0.5;
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
		drawfill( [ vPosition_x, vPosition_y - 1 ], [ 397, 14 ], '1 1 1', 0.5, 2 );
		drawstring( [vPosition_x + 8, vPosition_y], sprintf( "%.25s", gethostcachestring( fldName, i ) ), '12 12', autocvar_menu_fgcolor, 1.0f, FALSE );
		drawstring( [vPosition_x + 186, vPosition_y], sprintf( "%.10s", gethostcachestring( fldMap, i ) ), '12 12', autocvar_menu_fgcolor, 1.0f, FALSE );
		drawstring( [vPosition_x + 298, vPosition_y], sprintf( "%d/%d", gethostcachenumber( fldPlayers, i ), gethostcachenumber( fldMaxplayers, i ) ), '12 12', autocvar_menu_fgcolor, 1.0f, FALSE );
		drawstring( [vPosition_x + 362, vPosition_y], sprintf( "%.3s", ftos( gethostcachenumber( fldPing, i ) ) ), '12 12', autocvar_menu_fgcolor, 1.0f, FALSE );
	} else {
		drawstring( [vPosition_x + 8, vPosition_y], sprintf( "^3%.25s", gethostcachestring( fldName, i ) ), '12 12', autocvar_menu_fgcolor, fItemAlpha, FALSE );
		drawstring( [vPosition_x + 186, vPosition_y], sprintf( "%.10s", gethostcachestring( fldMap, i ) ), '12 12', autocvar_menu_fgcolor, fItemAlpha, FALSE );
		drawstring( [vPosition_x + 298, vPosition_y], sprintf( "%d/%d", gethostcachenumber( fldPlayers, i ), gethostcachenumber( fldMaxplayers, i ) ), '12 12', autocvar_menu_fgcolor, fItemAlpha, FALSE );
		drawstring( [vPosition_x + 362, vPosition_y], sprintf( "%.3s", ftos( gethostcachenumber( fldPing, i ) ) ), '12 12', autocvar_menu_fgcolor, fItemAlpha, FALSE );
	}
}

/*
=================
Menu_Multiplayer

First mulitplayer screen with the server browser
=================
*/
void Menu_Multiplayer(void) {
	static string strCustomIP;
	static int iSelectedServer = -1;
	static int iScrollServer;
	static int iServersTotal;
	static int iAddServer = FALSE;
	
	static void Multiplayer_ButtonJoin(void) {
		if ( iSelectedServer >= 0 ) {
			localcmd( sprintf( "connect %s\n", gethostcachestring( fldAddress, iSelectedServer ) ) );
			m_hide();
		}
	}
	static void Multiplayer_ButtonCreate(void) {
		iMenu = MENU_MULTIPLAYER_CREATE;
	}
	static void Multiplayer_ButtonRefresh(void) {
		refreshhostcache();
		resorthostcache();
	}
	static void Multiplayer_ButtonUpdate(void) {
		refreshhostcache(TRUE);
		resorthostcache();
	}
	static void Multiplayer_ButtonDone(void) {
		iMenu = MENU_MAIN;
	}
	static void Multiplayer_ButtonIRC(void) {
		iMenu = MENU_MULTIPLAYER_IRC;	
	}
	static void Multiplayer_ButtonAdd(void) {
		iAddServer = 1 - iAddServer;	
	}
	static void Multiplayer_ButtonJoinIP(void) {
		if ( strCustomIP ) {
			localcmd( sprintf( "connect %s\n", strCustomIP ) );
			m_hide();
		}
	}
	
	// Initialize it on the first run
	if ( iSelectedServer == -1 ) {
		//clear the filter
		resethostcachemasks();
		//sethostcachemaskstring( 0, gethostcacheindexforkey( "gamedir" ), "freecs", SLIST_TEST_EQUAL );
		sethostcachesort( gethostcacheindexforkey( "ping" ), FALSE );
		refreshhostcache();
		iSelectedServer = -2;
	}
	
	resorthostcache();
	fldName = gethostcacheindexforkey("name");
	fldAddress = gethostcacheindexforkey("cname");
	fldPing = gethostcacheindexforkey("ping");
	fldPlayers = gethostcacheindexforkey("numhumans");
	fldMaxplayers = gethostcacheindexforkey("maxplayers");
	fldMap = gethostcacheindexforkey("map");
	
	iServersTotal = gethostcachevalue( SLIST_HOSTCACHEVIEWCOUNT );
	
	Menu_SetClipArea( '32 148', '164 256' );
	Object_Button( '32 148', BTN_JOINGAME, Multiplayer_ButtonJoin, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_CREATE, Multiplayer_ButtonCreate, fButtonAlpha[1] );
	Object_Button( '32 212', BTN_GAMEINFO, __NULL__, fButtonAlpha[2] );
	Object_Button( '32 244', BTN_REFRESHLIST, Multiplayer_ButtonRefresh, fButtonAlpha[3] );
	Object_Button( '32 276', BTN_UPDATELIST, Multiplayer_ButtonUpdate, fButtonAlpha[4] );
	Object_Button( '32 308', BTN_ADDSERVER, Multiplayer_ButtonAdd, fButtonAlpha[5] );
	
	//if ( checkcommand( "irc" ) ) {
		Object_Button( '32 340', BTN_IRCCHAT, Multiplayer_ButtonIRC, fButtonAlpha[6] );
	//}
	
	Object_Button( '32 372', BTN_DONE, Multiplayer_ButtonDone, fButtonAlpha[7] );
	Menu_ResetClipArea();
	
	Object_Frame( '196 140', '404 308' );
	Object_Scrollbar( '604 140', 308, iScrollServer );
	
	Object_Label( '208 124', _("MP_GAME"), '12 12' );
	Object_Label( '386 124', _("MP_MAP"), '12 12' );
	Object_Label( '498 124', _("MP_PLAYERS"), '12 12' );
	Object_Label( '562 124', _("MP_PING"), '12 12' );
	
	Menu_SetClipArea( '196 141', '404 306' );
	vector vListPos = '200 145';
	vListPos_y -= fabs( ( ( iServersTotal - 8 ) * 10 ) * ( iScrollServer / 308 ) );
	
	for ( int i = 0; i < iServersTotal; i++ ) {
		Menu_Multiplayer_Find_Item( vListPos, i, iSelectedServer );
		vListPos_y += 14;
	}
	
	Menu_ResetClipArea();

	if ( iAddServer ) {
		Object_Frame( '192 192', '256 96' );
		Object_Label( '212 216', "IP/Hostname:", '12 12' );
		Object_Textfield( '212 232', strCustomIP, 25 );
		
		Object_Button( '208 248', BTN_JOIN, Multiplayer_ButtonJoinIP, fButtonAlpha[6] );
		Object_Button( '364 248', BTN_CANCEL, Multiplayer_ButtonAdd, fButtonAlpha[7] );
	}
	
	
}

/*
=================
Menu_Multiplayer_Create

Server creation menu screen
=================
*/
void Menu_Multiplayer_Create(void) {
	static int iSelectedMap;
	static int iScrollMap;
	static int iFirst = 1;
	static string strHostname;
	
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
		
		if ( fInputKeyCode == K_UPARROW ) {
			iSelectedMap--;
			fInputKeyCode = 0;
		} else if ( fInputKeyCode == K_DOWNARROW ) {
			iSelectedMap++;
			fInputKeyCode = 0;
		}
		
		if ( iSelectedMap >= iMapCount ) {
			iSelectedMap = iMapCount - 1;
		} else if ( iSelectedMap < 0 ) {
			iSelectedMap = 0;
		}
		
		if ( iSelectedMap == iIndex ) {
			drawfill( [ vPosition_x, vPosition_y - 1 ], [ 182, 14 ], '1 1 1', 0.25f, 2 );
			drawstring( vPosition + '8 0', sMapList[ iIndex ], '12 12', autocvar_menu_fgcolor, 1.0f, 0 );	
		} else {
			drawstring( vPosition + '8 0', sMapList[ iIndex ], '12 12', autocvar_menu_fgcolor, fAlpha, 0 );
		}
	}
	static void Create_ButtonAdvanced(void) {
		// Advanced options
		iMenu = MENU_MULTIPLAYER_OPTIONS;
	}
	static void Create_ButtonOK(void) {
		// Apply the configurations
		if ( strHostname != __NULL__ ) {
			localcmd( sprintf( "hostname %s\n", strHostname ) );
		} else {
			strHostname = cvar_string( "hostname" );
		}
		
		// Start server
		localcmd( sprintf( "map %s\n", sMapList[ iSelectedMap ] ) );
	}
	static void Create_ButtonCancel(void) {
		iMenu = MENU_MULTIPLAYER;
	}
	
	if ( iFirst == 1 ) {
		strHostname = cvar_string( "hostname" );
		iFirst = 0;
	}
	
	Object_Button( '32 148', BTN_ADVOPTIONS, Create_ButtonAdvanced, fButtonAlpha[0] );
	Object_Button( '32 180', BTN_OK, Create_ButtonOK, fButtonAlpha[1] );
	Object_Button( '32 212', BTN_CANCEL, Create_ButtonCancel, fButtonAlpha[2] );
	
	// Options
	Object_Label( '196 148', _("SERVER_NAME"), '12 12' );
	Object_Textfield( '196 160', strHostname, 20 );
	Object_CvarToggle( '196 185', "Public", "sv_public" );

	// Map list
	Object_Label( '384 148', _("MP_MAPS"), '12 12' );
	Object_Frame( '384 164', '190 288' );
	Object_Scrollbar( '576 164', 272, iScrollMap );
	
	// Maplist
	vector vListPos = '392 172';
	Menu_SetClipArea( '386 166', '188 284' );
	vListPos_y -= fabs( ( ( iMapCount - rint( 272 / 14 ) ) * 14 ) * ( iScrollMap / 272 ) );
	for ( int i = 0; i < iMapCount; i++ ) {
		Create_ListMap( vListPos, i );
		vListPos_y += 14;
	}
	Menu_ResetClipArea();
}

int iIRCShowRooms;
var string irc_currentroom;

static string stockrooms[] = {
	"FreeCS Chat", "#freecs",
	"Maps & Mods", "#maps",
	"Off-Topic", "#general",
	"Support", "#support"
};
	
void Menu_Multiplayer_IRC_Rooms(void)
{
	static int iRoomsInitialized = FALSE;
	static string roomlist;

	static void IRC_ButtonDone(void) {
		iIRCShowRooms = FALSE;
	}
	
	if (!iRoomsInitialized) {
		//roomlist
	}
	
	Object_Button( '32 308', BTN_DONE, IRC_ButtonDone, fButtonAlpha[0] );
}

void Menu_Multiplayer_IRC(void) {
	static int iIRCInit = FALSE;
	static string currenttab;
	string showtab;
	static string s;
	static string strGameDir_Lobby;
	static string strGameDir_Support;
	static string strGameDir_Maps;
	static string strGameDir_Mods;
	
	static void IRC_ButtonDone(void) {
		iMenu = MENU_MULTIPLAYER;
	}
	static void IRC_ButtonSelect(void) {
		if (currenttab)
			con_input(currenttab, IE_FOCUS, 0/*mouse focus*/, 0/*key focus*/, 0);
		if (s)
		{
			currenttab = s;
			con_input(currenttab, IE_FOCUS, 1/*mouse focus*/, 1/*key focus*/, 0);
		}
	}

	if ( iIRCInit == FALSE ) {
		localcmd("plug_load irc\n");
		localcmd(sprintf("irc_nick %s\n", cvar_string("name")));
		strGameDir_Lobby = sprintf("#%s_lobby", cvar_string("game"));
		strGameDir_Support = sprintf("#%s_support", cvar_string("game"));
		strGameDir_Maps = sprintf("#%s_maps", cvar_string("game"));
		strGameDir_Mods = sprintf("#%s_mods", cvar_string("game"));
		localcmd("irc /connect www.vera-visions.com\n");
		iIRCInit = TRUE;
		iIRCShowRooms = TRUE;
	}

	if (iIRCShowRooms) {
		Menu_Multiplayer_IRC_Rooms();
		return;
	}

	int iTabIdx;
	vector vTabPos = '196 140';
	for (s = "", iTabIdx = 0; s; s = con_getset(s, "next"))
	{
		if (substring(s, 0, 3) == "IRC")
		{
			con_getset( s, "hidden", "1" );	//Hide all IRC consoles. We're evil like that.

			string title = con_getset( s, "title" );

			iTabIdx++;
			if (fButtonAlpha[iTabIdx] < 0.5)
				fButtonAlpha[iTabIdx] = 0.5;
			Object_TextButton( vTabPos, title, IRC_ButtonSelect, fButtonAlpha[iTabIdx] );
			vTabPos_x += stringwidth(title, TRUE, '12 12') + 8;
		}
	}
	//TODO: scroll tabs.
	//TODO: add a close button
	//TODO: make it friendly when in-game.

	showtab = currenttab;

	if not (showtab)	//the channel we're trying to target
		for (s = ""; s; s = con_getset(s, "next"))
		{	//try to find our target channel
			print(sprintf("TAB: %s\n", s));
			if (substring(s, 0, 3) == "IRC" && substring(s, -7, -1) == "#freecs")
			{
				showtab = s;
				break;
			}
		}
	if (!showtab)	//the server-messages channel. used more as a loading screen than anything else.
		for (s = ""; s; s = con_getset(s, "next"))
		{
			if (substring(s, 0, 3) == "IRC" && substring(s, -1, -1) == ":")
			{
				showtab = s;
				break;
			}
		}

	//TODO: propagate input events to the currenttab.
	if (currenttab)
	{
		if (Menu_InputCheckMouse( vMenuOffset + '196 148', '404 308' ))
		{
			con_input(currenttab, IE_MOUSEABS, vMousePos_x, vMousePos_y, 0);

			if (fMouseClick)
			{
				con_input(currenttab, IE_KEYDOWN, K_MOUSE1, 0, 0);
				con_input(currenttab, IE_KEYUP, K_MOUSE1, 0, 0);
			}
			con_input(currenttab, IE_FOCUS, 1/*mouse focus*/, 1/*key focus*/, 0);
		}
		else
			con_input(currenttab, IE_FOCUS, 0/*mouse focus*/, 1/*key focus*/, 0);

		//this is hideous
		//BUG BUG BUG FIXME: The engine attempts to restrict con_input inputs.
		//as a result, it can only be called inside CSQC_Input_Event (or menuqc equivelents)
		//note that if you wish to handle IME strings then you should be doing that anyway.
		if (fInputKeyCode != K_MOUSE1 && (fInputKeyCode || fInputKeyASCII))
		{
			//print(sprintf("Sending input: %f %f %c\n", fInputKeyCode, fInputKeyASCII, fInputKeyASCII));
			con_input(currenttab, IE_KEYDOWN, fInputKeyCode, fInputKeyASCII, 0);
			con_input(currenttab, IE_KEYUP, fInputKeyCode, fInputKeyASCII, 0);
			fInputKeyCode = 0;
			fInputKeyASCII = 0;
		}
	}
	
	if (showtab)
		con_draw( showtab, vMenuOffset + '196 148', '404 308', 8 );
	else
		Object_Label( '196 148', _("No IRC Output"), '12 12' );
	
	Object_Button( '32 308', BTN_DONE, IRC_ButtonDone, fButtonAlpha[0] );
}
