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

#define VERSION	"0.1a"

#define KEY_UNKNOWN 		-1
#define KEY_GAME 			0
#define KEY_MENU 			2
#define KEY_MENU_GRABBED 	3

#define TARGET_MENU 	1
#define TARGET_CLIENT 	2

var vector vVideoSize;
var vector vMenuOffset;
var vector autocvar_menu_fgcolor = '1 0.59 0.19';
var string autocvar_cl_logofile = "lambda";
var vector autocvar_cl_logocolor = '255 0 0';
var vector vHeaderButtonPos;

var vector vMousePos;
var float fInputKeyCode;
var float fInputKeyASCII;
var float fInputKeyDown;
var float fMouseClick;
var float fButtonAlpha[8];
var float fScrollWheel;
var int iHLContent = 0;

var vector vMenuButtonsSize;

enum {
	SCROLL_NONE,
	SCROLL_UP,
	SCROLL_DOWN
};

var int iMenuActive;
var int iScrollbarHold; // Because of this, don't put more than one scrollbar per screen :)

float frametime;
float fLastTime;

int iMenu;
string *sMapList;
int iMapCount;

string *sLogos;
var int iLogos;

var float FONT_MENU;

#define MENU_COUNT 11
enum {
	MENU_MAIN,
	MENU_CONFIGURATION,
	MENU_CONFIGURATION_AUDIO,
	MENU_CONFIGURATION_VIDEO,
	MENU_CONFIGURATION_PLAYER,
	MENU_CONFIGURATION_CONTROLS,
	MENU_MULTIPLAYER,
	MENU_MULTIPLAYER_CREATE,
	MENU_MULTIPLAYER_OPTIONS,
	MENU_MULTIPLAYER_IRC,
	MENU_QUIT	
};

enum {
	HEAD_ADVANCED,
	HEAD_ADVOPTIONS,
	HEAD_AUDIO,
	HEAD_CONFIG,
	HEAD_CONTROLS,
	HEAD_CREATEGAME,
	HEAD_CREATEROOM,
	HEAD_CUSTOM,
	HEAD_CUSTOMIZE,
	HEAD_FILTER,
	HEAD_GAMEOPTS,
	HEAD_GORE,
	HEAD_INETGAMES,
	HEAD_KEYBOARD,
	HEAD_LAN,
	HEAD_LOAD,
	HEAD_MULTI,
	HEAD_README,
	HEAD_ROOM,
	HEAD_ROOMS,
	HEAD_SAVE,
	HEAD_SAVELOAD,
	HEAD_SPECGAMES,
	HEAD_VIDEO,
	HEAD_VIDMODES,
	HEAD_VIDOPTIONS
};

#define MENU_BUTTONS 69
enum {
	BTN_NEWGAME,
	BTN_RESUMEGAME,
	BTN_TRAINING,
	BTN_CONFIG,
	BTN_LOADGAME,
	BTN_SAVELOAD,
	BTN_README,
	BTN_QUIT,
	BTN_MULTIPLAYER,
	BTN_EASY,
	BTN_MEDIUM,
	BTN_DIFFICULT,
	BTN_SAVEGAME,
	BTN_LOADGAME2,
	BTN_CANCEL,
	BTN_OPTIONS,
	BTN_VIDEO,
	BTN_AUDIO,
	BTN_CONTROLS,
	BTN_DONE,
	BTN_QUICKSTART,
	BTN_DEFAULTS,
	BTN_OK,
	BTN_VIDEOOPTIONS,
	BTN_VIDEOMODES,
	BTN_ADVCONTROLS,
	BTN_ORDER,
	BTN_DELETE,
	BTN_INTERNET,
	BTN_IRCCHAT,
	BTN_LAN,
	BTN_CUSTOMIZE,
	BTN_SKIP,
	BTN_EXIT,
	BTN_CONNECT,
	BTN_REFRESH,
	BTN_FILTER1,
	BTN_FILTER2,
	BTN_CREATE,
	BTN_CREATEGAME,
	BTN_CHATROOMS,
	BTN_LISTROOMS,
	BTN_SEARCH,
	BTN_SERVERS,
	BTN_JOIN,
	BTN_FIND,
	BTN_CREATEROOM,
	BTN_JOINGAME,
	BTN_SEARCHGAMES,
	BTN_FINDGAME,
	BTN_STARTGAME,
	BTN_GAMEINFO,
	BTN_UPDATE,
	BTN_ADDSERVER,
	BTN_DISCONNECT,
	BTN_CONSOLE,
	BTN_CONTENTCONTROL,
	BTN_UPDATE,
	BTN_VISITWON,
	BTN_PREVIEWS,
	BTN_ADVOPTIONS,
	BTN_3DINFO,
	BTN_CUSTOMGAME,
	BTN_ACTIVATE,
	BTN_INSTALL,
	BTN_VISITWEB,
	BTN_REFRESHLIST,
	BTN_DEACTIVATE,
	BTN_SPECTATEGAME,
	BTN_SPECTATEGAMES
};

typedef struct {
	void() vMenu;
	int iHeaderID;
} fcsMenu;

typedef struct {
	int iR;
	int iG;
	int iB;
} color;

void Menu_SetClipArea( vector vPosition, vector vRegion );
void Menu_ResetClipArea( void );
