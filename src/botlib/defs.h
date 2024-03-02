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

#include "NSBot.h"

vector Route_SelectDestination( NSBot target );

var int autocvar_bot_aimless = FALSE;

var int autocvar_nav_linksize = 256;
var int autocvar_nav_radius = 8;

var bool autocvar_bot_crouch = false;
var bool autocvar_bot_walk = false;
var bool autocvar_bot_stop = false;
var bool autocvar_bot_dont_shoot = false;

var bool autocvar_bot_join_after_player = false;
var float autocvar_bot_join_delay = 0.0f;
var int autocvar_bot_quota = 0i;
var string autocvar_bot_quota_mode = "normal";
var string autocvar_bot_chatter = "normal";
var bool autocvar_bot_developer = false;

void
_BotLog(string functionName, string msg)
{
	print(sprintf("%f ^xF05%s ^7: %s\n", time, functionName, msg));
}

/** Logs an bot system specific log message.
	 The console variable `bot_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define BotLog(...) if (autocvar_bot_developer) _BotLog(__FUNC__, sprintf(__VA_ARGS__))

void
_BotEntLog(string className, string functionName, float edictNum, string warnMessage)
{
	print(sprintf("%f ^xF05%s (id: %d) ^7: %s\n", time, functionName, edictNum, warnMessage));
}

/** Logs an bot specific entity class log message.
	 The console variable `bot_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define BotEntLog(...) if (autocvar_bot_developer) _BotEntLog(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))

typedef enum
{
	BOTSKILL_EASY = 1,
	BOTSKILL_MEDIUM,
	BOTSKILL_HARD
} botskill_t;

var botskill_t autocvar_bot_skill = BOTSKILL_MEDIUM;

var string autocvar_bot_prefix = "";

/* BotScript
	script/bots.txt

	Listing of various bot profiles
	where infokeys can be set and interpreted
	by the game-logic at will.

	The `name` keys has to _always_ be present.
	The `funname` key is optional.

	Name acts as both an identifier as well
	as a nickname when `funname` is not present.

	Anything else is considered to be extra.
*/

typedef struct
{
	string m_strName;
	string m_strNetName;
	string m_strExtra;
} botScript_t;

#define BOTSCRIPT_MAX 32
botScript_t g_bots[BOTSCRIPT_MAX];
var int g_botScriptCount;