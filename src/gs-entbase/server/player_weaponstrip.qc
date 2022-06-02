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

/*QUAKED player_weaponstrip (1 0 0) (-8 -8 -8) (8 8 8)
Strips the activator of all of its weapons.

-------- KEYS --------
"targetname" : Name

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class player_weaponstrip:NSPointTrigger
{
	void(void) player_weaponstrip;

	virtual void(entity, int) Trigger;
};

void
player_weaponstrip::Trigger(entity act, int unused)
{
	NSClientPlayer pl;

	if (!(act.flags & FL_CLIENT)) {
		return;
	}

	pl = (NSClientPlayer)act;

	for (int i = 1; i < Weapon_GetCount(); i++) {
		pl.g_items &= ~Weapon_GetBitID(i);
		pl.activeweapon = 0;
	}
}

void
player_weaponstrip::player_weaponstrip(void)
{
}
