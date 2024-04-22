/*
 * Copyright (c) 2024 Vera Visions LLC.
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

/* for full description check the docs. */
var bool autocvar_bot_enable = true;
var bool autocvar_bot_pause = false;
var bool autocvar_bot_noChat = false;
var bool autocvar_bot_fastChat = false;
var bool autocvar_bot_debug = false;
var bool autocvar_bot_developer = false;
var int autocvar_bot_minClients = -1i;

typedef enum
{
	BOTSKILL_EASY = 1,
	BOTSKILL_MEDIUM,
	BOTSKILL_HARD
} botskill_t;

var botskill_t autocvar_bot_skill = BOTSKILL_MEDIUM;

var bool autocvar_bot_aimless = false;
var bool autocvar_bot_crouch = false;
var bool autocvar_bot_walk = false;
var bool autocvar_bot_prone = false;
var bool autocvar_bot_dont_shoot = false;