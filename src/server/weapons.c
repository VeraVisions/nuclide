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

/* force the drawing of the first weapon that's picked up */
var int autocvar_sv_forceweapondraw = TRUE;

int
Weapon_GetCount(void)
{
	return g_weapons.length;
}

int
Weapon_GetBitID(int i)
{
	return g_weapons[i].id;
}

void
Weapons_PickupNotify(base_player pl, int w)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_WEAPON_PICKUP);
	WriteByte(MSG_MULTICAST, w);
	msg_entity = (entity)pl;
	multicast([0,0,0], MULTICAST_ONE);
}

void
Weapons_RefreshAmmo(base_player pl)
{
	if (g_weapons[pl.activeweapon].updateammo != __NULL__) {
		g_weapons[pl.activeweapon].updateammo((player)pl);
    }
}

void
Weapons_SwitchBest(base_player pl)
{
	entity oldself = self;
	self = pl;

	for (float i = g_weapons.length - 1; i >= 1 ; i--) {
		if (pl.g_items & g_weapons[i].id) {
			pl.activeweapon = i;
			break;
		}
	}

	Weapons_Draw();
	self = oldself;
	pl.gflags |= GF_SEMI_TOGGLED;
}

/* returns TRUE if weapon pickup gets removed from this world */
int
Weapons_AddItem(base_player pl, int w, int startammo)
{
	int value;
	entity oldself = self;
	self = pl;

	/* let's check if we've got a limit */
	int maxit;
	CGameRules rules = (CGameRules)g_grMode;
	maxit = rules.MaxItemPerSlot(g_weapons[w].slot);
	if (maxit > 0) {
		int wantslot = g_weapons[w].slot;
		int c = 0;
		for (int i = 0; i < g_weapons.length; i++) {
			if (pl.g_items & g_weapons[i].id && g_weapons[i].slot == wantslot) {
				c++;

				/* we're over the slot limit. */
				if (c >= maxit) {
					self = oldself;
					return FALSE;
				}
			}
		}
	}

	/* in case programmer decided not to add a pickup callback */
	if (g_weapons[w].pickup == __NULL__) {
		if (pl.g_items & g_weapons[w].id) {
			/* already present, skip */
			value = FALSE;
		} else {
			/* new to our arsenal */
			pl.g_items |= g_weapons[w].id;
			value = TRUE;

			/* it's new, so autoswitch? */
			if (pl.activeweapon == 0 && autocvar_sv_forceweapondraw == 1) {
				pl.activeweapon = w;
				Weapons_Draw();
			} else {
				Weapons_PickupNotify(pl, w);
			}
		}
	} else {
		/* call pickup to handle the ammo */
		if (pl.g_items & g_weapons[w].id) {
			value = g_weapons[w].pickup(FALSE, startammo);
		} else {
			/* new to our arsenal */
			pl.g_items |= g_weapons[w].id;
			value = g_weapons[w].pickup(TRUE, startammo);

			/* it's new, so autoswitch? */
			if (pl.activeweapon == 0 && autocvar_sv_forceweapondraw == 1) {
				pl.activeweapon = w;
				Weapons_Draw();
			} else {
				Weapons_PickupNotify(pl, w);
			}
		}
	}

	Weapons_RefreshAmmo(pl);
	self = oldself;
	return value;
}

void
Weapons_RemoveItem(base_player pl, int w)
{
	if (pl.activeweapon == w)
		pl.activeweapon = WEAPON_NONE;

	pl.g_items &= ~g_weapons[w].id;

	if (autocvar_sv_forceweapondraw == 1)
		Weapons_SwitchBest(pl);
}

void
Weapons_InitItem(int w)
{
	item_pickup it = (item_pickup)self;
	spawnfunc_item_pickup();
	it.SetItem(w);
}

void
Weapons_UpdateAmmo(base_player pl, int a1, int a2, int a3)
{
	/* no change */
	if (a1 == -1) {
		a1 = pl.a_ammo1;
	}
	if (a2 == -1) {
		a2 = pl.a_ammo2;
	}
	if (a3 == -1) {
		a3 = pl.a_ammo3;
	}

	/* Networked as bytes, since we don't need more. Clamp to avoid errors */
	pl.a_ammo1 = bound(0, a1, 255);
	pl.a_ammo2 = bound(0, a2, 255);
	pl.a_ammo3 = bound(0, a3, 255);
}

void
Weapons_ReloadWeapon(base_player pl, .int mag, .int ammo, int max)
{
	int iNeed = max - pl.(mag);
	int iHave = pl.(ammo);

	if (iNeed > iHave) {
		pl.(mag) += iHave;
		pl.(ammo) = 0;
	} else {
		pl.(mag) += iNeed;
		pl.(ammo) -= iNeed;
	}
}

void
Weapon_DropCurrentWeapon(base_player pl)
{
	
	static void DropWeapon_Enable(void)
	{
		self.solid = SOLID_TRIGGER;
	}

	if (!pl.activeweapon)
		return;

	if (g_weapons[pl.activeweapon].allow_drop != TRUE)
		return;

	item_pickup drop = spawn(item_pickup, m_iWasDropped: TRUE, m_iClip: pl.a_ammo1);
	drop.SetItem(pl.activeweapon);
	setorigin(drop, pl.origin);
	drop.solid = SOLID_NOT;
	drop.think = DropWeapon_Enable;
	drop.nextthink = time + 1.5f;
	drop.movetype = MOVETYPE_TOSS;
	drop.classname = "remove_me";

	makevectors(pl.v_angle);
	drop.velocity = v_forward * 256;
	drop.avelocity[1] = 500;
	Weapons_RemoveItem(pl, pl.activeweapon);
}

void
CSEv_DropWeapon(void)
{
	player pl = (player)self;
	Weapon_DropCurrentWeapon(pl);
}
