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

#include "cvars.h"
#include "profiles.h"

/** @defgroup bot Bot
@brief Multiplayer game opponents, allies.
@ingroup ai

![](computer.png) Computer controlled opponents are called "Bots". If a game supports them, they will be added with either `bot_minClients #` in the server console, or with the `addBot` command.

## See also

- @ref bot_profile
- @ref bot_cvars
- @ref bot_info
- @ref NSBot

@{
*/

vector Route_SelectDestination( NSBot target );

var int autocvar_nav_linksize = 256;
var int autocvar_nav_radius = 8;

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

var string autocvar_bot_prefix = "";

/** @} */ // end of bot
