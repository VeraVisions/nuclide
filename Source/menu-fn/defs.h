/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

var int autocvar_menu_intro = FALSE;

#define KEY_UNKNOWN 		-1
#define KEY_GAME 			0
#define KEY_MENU 			2
#define KEY_MENU_GRABBED 	3

#define TARGET_MENU 		1
#define TARGET_CLIENT 		2

/* Basic Menu Globals */
int g_vidsize[2];
int g_menuofs[2];
int g_mousepos[2];
vector g_logosize;
int g_lastmousepos[2];
int g_active;
float g_btnofs;
float frametime;

/* Font IDs */
int font_label;
int font_label_b;
int font_console;
int font_arial;
int font_label_p;

typedef struct {
	void() m_init;
	void() m_draw;
	void(float evtype, float scanx, float chary, float devid) m_input;
} menupage_t;

typedef struct
{
	string game;
	string gamedir;
	string url_info;
	string url_dl;
	string version;
	int size;
	int svonly;
	int cldll;
	string type;
	string hlversion;
	int nomodels;
	string mpentity;
	string gamedll;
	string startmap;
	string trainingmap;
} gameinfo_t;

var int gameinfo_current = -1;
int gameinfo_count;
gameinfo_t *games;
string(float id, float b) getgamedirinfo = #0;

int g_menupage;

enum {
	PAGE_MAIN,
	PAGE_CONFIGURATION,
	PAGE_AUDIO,
	PAGE_CONTENTCONTROL,
	PAGE_CONTROLS,
	PAGE_ADVANCEDCONTROLS,
	PAGE_VIDEO,
	PAGE_VIDEOMODES,
	PAGE_VIDEOOPTIONS,
	PAGE_CUSTOMGAME,
	PAGE_LOADGAME,
	PAGE_MULTIPLAYER,
	PAGE_CUSTOMIZE,
	PAGE_ADVANCEDCUSTOMIZE,
	PAGE_INTERNETGAMES,
	PAGE_ADDSERVER,
	PAGE_CHATROOMS,
	PAGE_CREATEGAME,
	PAGE_CREATEGAMEINET,
	PAGE_ADVANCEDMPOPTIONS,
	PAGE_FILTER,
	PAGE_VIEWGAMEINFO,
	PAGE_LANGAMES,
	PAGE_SPECTATEGAMES,
	PAGE_NEWGAME,
	PAGE_VIEWREADME
};

void m_hide(void);
void cvar_init(void);
