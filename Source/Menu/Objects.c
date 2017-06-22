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
	"BTN_NEWGAME",
	"BTN_RESUMEGAME",
	"BTN_TRAINING",
	"BTN_CONFIG",
	"BTN_LOADGAME",
	"BTN_SAVELOAD",
	"BTN_README",
	"BTN_QUIT",
	"BTN_MULTIPLAYER",
	"BTN_EASY",
	"BTN_MEDIUM",
	"BTN_DIFFICULT",
	"BTN_SAVEGAME",
	"BTN_LOADGAME2",
	"BTN_CANCEL",
	"BTN_OPTIONS",
	"BTN_VIDEO",
	"BTN_AUDIO",
	"BTN_CONTROLS",
	"BTN_DONE",
	"BTN_QUICKSTART",
	"BTN_DEFAULTS",
	"BTN_OK",
	"BTN_VIDEOOPTIONS",
	"BTN_VIDEOMODES",
	"BTN_ADVCONTROLS",
	"BTN_ORDER",
	"BTN_DELETE",
	"BTN_INTERNET",
	"BTN_IRCCHAT",
	"BTN_LAN",
	"BTN_CUSTOMIZE",
	"BTN_SKIP",
	"BTN_EXIT",
	"BTN_CONNECT",
	"BTN_REFRESH",
	"BTN_FILTER",
	"BTN_CREATE",
	"BTN_CREATEGAME",
	"BTN_CHATROOMS",
	"BTN_LISTROOMS",
	"BTN_SEARCH",
	"BTN_SERVERS",
	"BTN_JOIN",
	"BTN_FIND",
	"BTN_CREATEROOM",
	"BTN_JOINGAME",
	"BTN_SEARCHGAMES",
	"BTN_FINDGAME",
	"BTN_STARTGAME",
	"BTN_GAMEINFO",
	"BTN_UPDATE",
	"BTN_ADDSERVER",
	"BTN_DISCONNECT",
	"BTN_CONSOLE",
	"BTN_CONTENTCONTROL",
	"BTN_UPDATE",
	"BTN_VISITWON",
	"BTN_PREVIEWS",
	"BTN_ADVOPTIONS",
	"BTN_3DINFO",
	"BTN_CUSTOMGAME",
	"BTN_ACTIVATE",
	"BTN_INSTALL",
	"BTN_VISITWEB",
	"BTN_REFRESHLIST",
	"BTN_DEACTIVATE",
	"BTN_SPECTATEGAME",
	"BTN_SPECTATEGAMES"
};

#define autocvar_menu_color '1 0.59 0.19'

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
	
	float sWidth = stringwidth( sButtonLabels[ iButtonID ], TRUE, '16 16' );
	
	if ( Menu_InputCheckMouse( vPosition, [ sWidth, 16 ] ) == TRUE ) {
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
	
	drawstring( vPosition, sButtonLabels[ iButtonID ], '16 16', autocvar_menu_color, 1.0f, 0 );
	drawstring( vPosition, sButtonLabels[ iButtonID ], '16 16', '1 1 1', fAlpha, 0 );
}

/*
=================
Object_Button_Right

A right-aligned version of Object_Button
=================
*/
void Object_Button_Right( vector vPosition, int iButtonID, void() vFunction, __inout float fAlpha ) {
	vPosition_x -= stringwidth( sButtonLabels[ iButtonID ], TRUE, '16 16' );
	Object_Button( vPosition, iButtonID, vFunction, fAlpha );
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
	
	drawfill( vPosition, [vSize_x, 1], autocvar_menu_color, 1.0f ); // Top
	drawfill( [vPosition_x, vPosition_y + vSize_y], [vSize_x, 1], autocvar_menu_color, 1.0f ); // Bottom
	
	drawfill( vPosition, [1, vSize_y], autocvar_menu_color, 1.0f ); // Left
	drawfill( [vPosition_x + vSize_x, vPosition_y], [1, vSize_y + 1], autocvar_menu_color, 1.0f ); // Right
}

/*
=================
Object_Label

A label in a cvar driven color scheme
=================
*/
void Object_Label( vector vPosition, string sLabel, vector vSize ) {
	vPosition += vMenuOffset;
	drawstring( vPosition, sLabel, vSize, autocvar_menu_color, 1.0f, 0 );	
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
	
	drawfill( [vPosition_x, vPosition_y + iProgress], [ 16, 16 ], autocvar_menu_color, 1.0f );
}

