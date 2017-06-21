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

#define MENU_FGCOLOR '1 0.59 0.19'

/*
=================
drawmenupic

Wrapper for drawpic that cares about resolution and scales.
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
	
	drawstring( vPosition, sButtonLabels[ iButtonID ], '16 16', MENU_FGCOLOR, 1.0f, 0 );
	drawstring( vPosition, sButtonLabels[ iButtonID ], '16 16', '1 1 1', fAlpha, 0 );
}

void Object_Button_Right( vector vPosition, int iButtonID, void() vFunction, __inout float fAlpha ) {
	vPosition_x -= stringwidth( sButtonLabels[ iButtonID ], TRUE, '16 16' );
	Object_Button( vPosition, iButtonID, vFunction, fAlpha );
}

// Draws window with outline, border and title
void Object_Frame( vector vPos, vector vSize ) {
	vPos += vMenuOffset;
	
	// Draw the background
	drawfill( vPos, vSize, '0 0 0', 1.0f );
	
	drawfill( vPos, [vSize_x, 1], MENU_FGCOLOR, 1.0f ); // Top
	drawfill( [vPos_x, vPos_y + vSize_y], [vSize_x, 1], MENU_FGCOLOR, 1.0f ); // Bottom
	
	drawfill( vPos, [1, vSize_y], MENU_FGCOLOR, 1.0f ); // Left
	drawfill( [vPos_x + vSize_x, vPos_y], [1, vSize_y], MENU_FGCOLOR, 1.0f ); // Right
}
