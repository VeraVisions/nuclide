/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#include "../client/font.h"

var int autocvar_menu_intro = TRUE;
var int autocvar__menu_singleplayer;
var bool autocvar_menu_steambg = false;

#define KEY_UNKNOWN		-1
#define KEY_GAME		0
#define KEY_MENU		2
#define KEY_MENU_GRABBED	3

#define TARGET_MENU		1
#define TARGET_CLIENT		2

#define DRAWFLAG_ADDITIVE 1

/* Font IDs */
font_s font_label;
font_s font_label_b;
font_s font_arial;
font_s font_label_p;
font_s font_console;

var int autocvar_menu_helptext_size = 13;

#define HELPTXT_SIZE autocvar_menu_helptext_size

typedef struct
{
	void(void) m_init;
	void(void) m_draw;
	void(float evtype, float scanx, float chary, float devid) m_input;
} menupage_t;

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

typedef enum
{
	RESOURCE_UNCHECKED,	/**<< State of the resource is unknown. Check it with Resource_Check() first. */
	RESOURCE_AVAILABLE, /**<< The resource exists. */
	RESOURCE_MISSING	/**<< The resource is unavailable. */
} resource_t;

resource_t
Resource_Check(string fname)
{
	if not (whichpack(fname))
		return RESOURCE_MISSING;

	return RESOURCE_AVAILABLE;
}

bool
Resource_Available(resource_t res)
{
	if (res == RESOURCE_AVAILABLE)
		return true;

	return false;
}

void m_hide(void);

void
warning(string msg)
{
	print(sprintf("^1WARNING: ^7%s\n", msg));
}

bool
mp_connected(void)
{
	return (!autocvar__menu_singleplayer && clientstate() == 2 && !g_background) ? true : false;
}
