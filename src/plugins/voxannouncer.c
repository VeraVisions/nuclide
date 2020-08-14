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

void
VoxFunc(string strMessage)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, 27);
	WriteString(MSG_MULTICAST, strMessage);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);
}

void
FMX_PlayerObituary(entity attk, entity targ, int weapon, int body, int dmg)
{
	/* silly announcer */
	if (attk != world && attk != targ) {
		int r = rint(random(0,10));

		switch (r) {
		case 0:
			VoxFunc("buzwarn go go go");
			break;
		case 1:
			VoxFunc("buzwarn goodbye");
			break;
		case 2:
			VoxFunc("buzwarn kill one out");
			break;
		case 3:
			VoxFunc("buzwarn woop woop");
			break;
		case 4:
			VoxFunc("buzwarn terminated");
			break;
		case 5:
			VoxFunc("buzwarn slow soldier");
			break;
		case 6:
			VoxFunc("buzwarn that is hot");
			break;
		case 7:
			VoxFunc("buzwarn great kill");
			break;
		case 8:
			VoxFunc("buzwarn good kill");
			break;
		default:
			VoxFunc("buzwarn exterminate exterminate");
			break;
		}
	}
}
