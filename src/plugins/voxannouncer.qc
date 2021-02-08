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

#include "../shared/events.h"

void
VoxFunc(string strMessage)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_CHAT_VOX);
	WriteString(MSG_MULTICAST, strMessage);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);
}

void
FMX_PlayerObituary(entity attk, entity targ, int weapon, int body, int dmg)
{
	/* silly announcer */
	if (attk != world && attk != targ) {
		int r = floor(random(0,20));

		switch (r) {
		case 0:
			VoxFunc("buzwarn go go go");
			break;
		case 1:
			VoxFunc("buzwarn goodbye");
			break;
		case 2:
			VoxFunc("buzwarn woop woop");
			break;
		case 3:
			VoxFunc("buzwarn terminated");
			break;
		case 4:
			VoxFunc("buzwarn to slow pal");
			break;
		case 5:
			VoxFunc("buzwarn that is hot");
			break;
		case 6:
			VoxFunc("buzwarn great kill");
			break;
		case 7:
			VoxFunc("buzwarn good kill");
			break;
		case 8:
			VoxFunc("buzwarn beyond extreme");
			break;
		case 9:
			VoxFunc("buzwarn must explode go bust");
			break;
		case 10:
			VoxFunc("buzwarn supercooled");
			break;
		case 11:
			VoxFunc("buzwarn kill life");
			break;
		case 12:
			VoxFunc("buzwarn kill that pal");
			break;
		case 13:
			VoxFunc("buzwarn explode that pal");
			break;
		case 14:
			VoxFunc("buzwarn life denied");
			break;
		case 15:
			VoxFunc("buzwarn no mercy");
			break;
		case 16:
			VoxFunc("buzwarn target destroyed");
			break;
		case 17:
			VoxFunc("buzwarn adios mister");
			break;
		case 18:
			VoxFunc("buzwarn expect an oscar for that kill");
			break;
		default:
			VoxFunc("buzwarn exterminate exterminate");
			break;
		}
	}
}
