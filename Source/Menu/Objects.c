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

string sButtonLabels[ MENU_BUTTONS ] = {
	_("BTN_NEWGAME"),
	_("BTN_RESUMEGAME"),
	_("BTN_TRAINING"),
	_("BTN_CONFIG"),
	_("BTN_LOADGAME"),
	_("BTN_SAVELOAD"),
	_("BTN_README"),
	_("BTN_QUIT"),
	_("BTN_MULTIPLAYER"),
	_("BTN_EASY"),
	_("BTN_MEDIUM"),
	_("BTN_DIFFICULT"),
	_("BTN_SAVEGAME"),
	_("BTN_LOADGAME2"),
	_("BTN_CANCEL"),
	_("BTN_OPTIONS"),
	_("BTN_VIDEO"),
	_("BTN_AUDIO"),
	_("BTN_CONTROLS"),
	_("BTN_DONE"),
	_("BTN_QUICKSTART"),
	_("BTN_DEFAULTS"),
	_("BTN_OK"),
	_("BTN_VIDEOOPTIONS"),
	_("BTN_VIDEOMODES"),
	_("BTN_ADVCONTROLS"),
	_("BTN_ORDER"),
	_("BTN_DELETE"),
	_("BTN_INTERNET"),
	_("BTN_IRCCHAT"),
	_("BTN_LAN"),
	_("BTN_CUSTOMIZE"),
	_("BTN_SKIP"),
	_("BTN_EXIT"),
	_("BTN_CONNECT"),
	_("BTN_REFRESH"),
	_("BTN_FILTER"),
	_("BTN_CREATE"),
	_("BTN_CREATEGAME"),
	_("BTN_CHATROOMS"),
	_("BTN_LISTROOMS"),
	_("BTN_SEARCH"),
	_("BTN_SERVERS"),
	_("BTN_JOIN"),
	_("BTN_FIND"),
	_("BTN_CREATEROOM"),
	_("BTN_JOINGAME"),
	_("BTN_SEARCHGAMES"),
	_("BTN_FINDGAME"),
	_("BTN_STARTGAME"),
	_("BTN_GAMEINFO"),
	_("BTN_UPDATE"),
	_("BTN_ADDSERVER"),
	_("BTN_DISCONNECT"),
	_("BTN_CONSOLE"),
	_("BTN_CONTENTCONTROL"),
	_("BTN_UPDATE"),
	_("BTN_VISITWON"),
	_("BTN_PREVIEWS"),
	_("BTN_ADVOPTIONS"),
	_("BTN_3DINFO"),
	_("BTN_CUSTOMGAME"),
	_("BTN_ACTIVATE"),
	_("BTN_INSTALL"),
	_("BTN_VISITWEB"),
	_("BTN_REFRESHLIST"),
	_("BTN_DEACTIVATE"),
	_("BTN_SPECTATEGAME"),
	_("BTN_SPECTATEGAMES")
};

/*
=================
Object_Button

Used for the (used to be) bitmap buttons in the menu
=================
*/
void Object_Button( vector vPosition, int iButtonID, void() vFunction, __inout float fAlpha ) {
	static int iLastButton = -1;
	
	vPosition += vMenuOffset;
	
	if ( fAlpha > 0.0f ) {
		fAlpha -= frametime;
	} else {
		fAlpha = 0.0f;
	}
	
	if ( Menu_InputCheckMouse( vPosition, '156 26' ) == TRUE ) {
		if ( iLastButton != iButtonID ) {
			localcmd( "play ../media/launch_deny2.wav\n" );
		}
		iLastButton = iButtonID;
		fAlpha = 1.0f;
		
		if ( fMouseClick == TRUE ) {
			vFunction();
			localcmd( "play ../media/launch_select2.wav\n" );
			fMouseClick = FALSE;
		}
	}

	vector vSrcPos, vSrcSize;
	vSrcPos_x = 0;
	vSrcPos_y = ( 78 * iButtonID ) / 5538;
	vSrcSize = [ 1, 26 / 5538 ];
	drawsubpic( vPosition, '156 26', "gfx/shell/btns_main", vSrcPos, vSrcSize, '1 1 1', 1.0f, 1 );
	drawsubpic( vPosition, '156 26', "gfx/shell/btns_main", vSrcPos + [ 0, 52 / 5538 ], vSrcSize, '1 1 1', fAlpha, 1 );
}

/*
=================
Object_Frame

A filled "window" of sorts
=================
*/
void Object_Frame( vector vPosition, vector vSize ) {
	vPosition += vMenuOffset;
	
	// Draw the background
	drawfill( vPosition, vSize, '0 0 0', 1.0f );
	
	drawfill( vPosition, [vSize_x, 1], autocvar_menu_fgcolor, 1.0f ); // Top
	drawfill( [vPosition_x, vPosition_y + vSize_y - 1], [vSize_x, 1], autocvar_menu_fgcolor, 1.0f ); // Bottom
	
	drawfill( vPosition, [1, vSize_y], autocvar_menu_fgcolor, 1.0f ); // Left
	drawfill( [vPosition_x + vSize_x - 1, vPosition_y], [1, vSize_y], autocvar_menu_fgcolor, 1.0f ); // Right
}

/*
=================
Object_Label

A label in a cvar driven color scheme
=================
*/
void Object_Label( vector vPosition, string sLabel, vector vSize ) {
	vPosition += vMenuOffset;
	drawstring( vPosition, sLabel, vSize, autocvar_menu_fgcolor, 1.0f, 0 );	
}

/*
=================
Object_Label_Right

A right-aligned version of Object_Label
=================
*/
void Object_Label_Right( vector vPosition, string sLabel, vector vSize ) {
	vPosition_x -= stringwidth( sLabel, TRUE, vSize );
	Object_Label( vPosition, sLabel, vSize );
}

/*
=================
Object_Scrollbar

A scrollbar, for different types of purposes.
Note: Only have one at a time.
=================
*/
void Object_Scrollbar( vector vPosition, int iHeight, __inout int iProgress ) {
	Object_Frame( vPosition, [ 16, iHeight ] );
	
	vPosition += vMenuOffset;
	iHeight -= 16;
	if ( ( iScrollbarHold == TRUE ) || ( Menu_InputCheckMouse( [vPosition_x, vPosition_y + iProgress ], '16 16' ) == TRUE ) ) {
		if ( fMouseClick == TRUE ) {
			iProgress = ( vMousePos_y - vPosition_y ) - 8;
			iScrollbarHold = TRUE;
		}
	}
	
	if ( fScrollWheel == SCROLL_DOWN ) {
		iProgress += 2;
		fScrollWheel = SCROLL_NONE;
	} else if ( fScrollWheel == SCROLL_UP ) {
		iProgress -= 2;
		fScrollWheel = SCROLL_NONE;
	}
	
	if ( iProgress < 0 ) {
		iProgress = 0;
	} else if ( iProgress > iHeight ) {
		iProgress = iHeight;
	} 
			
	iHeight += 16;
	
	drawfill( [vPosition_x, vPosition_y + iProgress], [ 16, 16 ], autocvar_menu_fgcolor, 1.0f );
}

