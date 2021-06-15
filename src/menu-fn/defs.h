/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

var int autocvar_menu_intro = TRUE;
var int autocvar__menu_singleplayer;

#define KEY_UNKNOWN		-1
#define KEY_GAME		0
#define KEY_MENU		2
#define KEY_MENU_GRABBED	3

#define TARGET_MENU		1
#define TARGET_CLIENT		2

enumflags
{
	SEARCH_INSENSITIVE,
	SEARCH_FULLPACKAGE,
	SEARCH_ALLOWDUPES,
	SEARCH_FORCESEARCH,
	SEARCH_MULTISEARCH,
	SEARCH_NAMESORT
};

/* Basic Menu Globals */
int g_vidsize[2];
int g_menuofs[2];
int g_mousepos[2];
vector g_logosize;
int g_lastmousepos[2];
int g_active;
float g_btnofs;
float frametime;
var int g_background = FALSE;

/* Font IDs */
int font_label;
int font_label_b;
int font_console;
int font_arial;
int font_label_p;

var int autocvar_menu_helptext_size = 11;

#define HELPTXT_SIZE autocvar_menu_helptext_size

typedef struct
{
	void(void) m_init;
	void(void) m_draw;
	void(float evtype, float scanx, float chary, float devid) m_input;
} menupage_t;

typedef enum
{
	GAMEINFO_NONE,
	GAMEINFO_MANIFEST,
	GAMEINFO_GITXT,
	GAMEINFO_LIBLIST
} gi_type;

typedef struct
{
	string game;
	string gamedir;
	string base_dir;
	string url_info;
	string url_dl;
	string version;
	string readme;
	int size;
	int svonly;
	int cldll;
	string type;
	string hlversion;
	string pkgname;
	string pkgfile;
	int pkgid;
	int nomodels;
	int nosprays;
	int installed;
	string mpentity;
	string gamedll;
	string startmap;
	string trainingmap;
	string fallback_dir;
	string chatroom;
	string introvideo;
	int steambg;
	gi_type info_type;
} gameinfo_t;

var int gameinfo_current = -1;
int gameinfo_count;
gameinfo_t *games;
string(float id, float b) getgamedirinfo = #0;
string(int packageidx, int desiredfield) getpackagemanagerinfo = #0;

enum
{
	GPMI_NAME,			// name of the package, for use with the pkg command.
	GPMI_CATEGORY,		// category text
	GPMI_TITLE,			// name of the package, for showing the user.
	GPMI_VERSION,		// version info (may have multiple with the same name but different versions)
	GPMI_DESCRIPTION,	// some blurb
	GPMI_LICENSE,		// what license its distributed under
	GPMI_AUTHOR,		// name of the person(s) who created it
	GPMI_WEBSITE,		// where to contribute/find out more info/etc
	GPMI_INSTALLED,		// current state
	GPMI_ACTION,		// desired state
	GPMI_AVAILABLE,		// whether it may be downloaded or not.
	GPMI_FILESIZE,		// whether it may be downloaded or not.
};

typedef struct
{
	string name;
	string category;
	string title;
	string version;
	string description;
	string license;
	string author;
	string website;
	string installed;
	int size;
	int uid;
} update_t;
int update_count;
update_t *updates;

int g_menupage;

enum
{
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
	PAGE_CHATROOMS_LIST,
	PAGE_CREATEGAME,
	PAGE_CREATEGAMEINET,
	PAGE_ADVANCEDMPOPTIONS,
	PAGE_FILTER,
	PAGE_VIEWGAMEINFO,
	PAGE_LANGAMES,
	PAGE_SPECTATEGAMES,
	PAGE_NEWGAME,
	PAGE_VIEWREADME,
	PAGE_UPDATES
};

void m_hide(void);
