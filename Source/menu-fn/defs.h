/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

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
	string fallback_dir;
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
