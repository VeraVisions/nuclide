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

#pragma target fte_5768
//#pragma flag enable assumeint
#pragma PROGS_DAT  "../../base/plugins/connectsounds.dat"
#define SERVER

#include "../server/api.h"

entity g_cnspk;

bool
Plug_ClientConnect(entity clientEntity)
{
	string strIP;
	sound(g_cnspk, CHAN_VOICE, "sound/buttons/bell1.wav", 1.0f, ATTN_NONE);
	strIP = infokey(clientEntity, INFOKEY_P_IP);
	bprint(PRINT_CHAT, sprintf("%s joined (%s)\n", clientEntity.netname, strIP));
	return (true);
}

void
Plug_ClientDisconnect(entity clientEntity)
{
	string strIP;
	sound(g_cnspk, CHAN_VOICE, "sound/buttons/blip1.wav", 1.0f, ATTN_NONE);
	strIP = infokey(clientEntity, INFOKEY_P_IP);
	bprint(PRINT_CHAT, sprintf("%s left (%s)\n", clientEntity.netname, strIP));
}

bool
Plug_Load(void)
{
	precache_sound("sound/buttons/blip1.wav");
	precache_sound("sound/buttons/bell1.wav");
	return (true);
}

void
Plug_ServerActivate(void)
{
	if (!g_cnspk) {
		g_cnspk = spawn();
	}
}
