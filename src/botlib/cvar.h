/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

typedef enum
{
	BOTSKILL_EASY = 1,
	BOTSKILL_MEDIUM,
	BOTSKILL_HARD
} botskill_t;

var botskill_t autocvar_bot_skill = BOTSKILL_MEDIUM;

var string autocvar_bot_prefix = "";
