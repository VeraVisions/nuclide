/*
 * Copyright (c) 2023 Vera Visions LLC.
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