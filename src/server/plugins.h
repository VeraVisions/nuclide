/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*! @file plugins.h
    @brief Server-Plugin APIs, similar to MetaMod.
*/

typedef struct
{
	string m_strPath;
	float m_flProgsID;
} plugin_t;


var bool g_plugins_enabled = false;
var bool autocvar_sv_plugins = false;

void Plugin_Init(void);
void Plugin_Shutdown(void);

void Plugin_InitEnts(void);
int Plugin_RunClientCommand(void);
string Plugin_ParseClientCommand(string);
int Plugin_PlayerConnect(NSClientPlayer);
int Plugin_PlayerDisconnect(NSClientPlayer);
int Plugin_PlayerEntered(NSClientPlayer);
void Plugin_PlayerObituary(entity, entity, int, bodyType_t, int);
