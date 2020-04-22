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

class item_ammo:CBaseEntity
{
	void(void) item_ammo;
	virtual void(void) Respawn;
	virtual void(void) touch;
};

void item_ammo::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}

	player pl = (player)other;
	Sound_Play(other, CHAN_ITEM, "ammo.pickup");
	Weapons_RefreshAmmo(pl);
	Logging_Pickup(other, this, __NULL__);

	if (cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 20.0f;
	}
}

void item_ammo::Respawn(void)
{
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_TOSS;

	if (m_oldModel) {
		SetModel(m_oldModel);
	}

	setsize(this, [-16,-16,0], [16,16,16]);
	SetOrigin(origin);

	think = __NULL__;
	nextthink = -1;
	Sound_Play(this, CHAN_ITEM, "ammo.respawn");
	droptofloor();
}

void item_ammo::item_ammo(void)
{
	m_oldModel = model;
	SetModel(m_oldModel);
	CBaseEntity::CBaseEntity();
}

/*
 * Ammo for the Crossbow.
 * A single ammo_bolts will provide 5 bolts.
 */

class 
ammo_bolts:item_ammo
{
	void(void) ammo_bolts;
};

void 
ammo_bolts::ammo_bolts(void)
{
	model = "models/w_crossbow_clip.mdl";
}

/*QUAKED ammo_nailclip (0 0 0.8) (-16 -16 0) (16 16 32)

Poke646 (2001) ENTITY

Ammo for the nailguns.
A single ammo_nailclip will provide 25 nails.

*/
class ammo_nailclip:item_ammo
{
	void(void) ammo_nailclip;
	virtual void(void) touch;
};

void ammo_nailclip::ammo_nailclip(void)
{
	model = "models/w_nailclip.mdl";
	item_ammo::item_ammo();
}
void ammo_nailclip::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_nail < MAX_A_NAIL) {
			pl.ammo_nail = bound(0, pl.ammo_nail + 25, MAX_A_NAIL);
			item_ammo::touch();
		}
	}
}

/*QUAKED ammo_nailround (0 0 0.8) (-16 -16 0) (16 16 32)

Poke646 (2001) ENTITY

Ammo for the nailguns.
A single ammo_nailround will provide 50 nails.

*/
class ammo_nailround:item_ammo
{
	void(void) ammo_nailround;
	virtual void(void) touch;
};

void ammo_nailround::ammo_nailround(void)
{
	model = "models/w_nailround.mdl";
	item_ammo::item_ammo();
}
void ammo_nailround::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_nail < MAX_A_NAIL) {
			pl.ammo_nail = bound(0, pl.ammo_nail + 50, MAX_A_NAIL);
			item_ammo::touch();
		}
	}
}

/*QUAKED ammo_xencandy (0 0 0.8) (-16 -16 0) (16 16 32)

Poke646 (2001) ENTITY

Ammo for the alien.
A single ammo_xencandy will provide 20 snacks.

*/

class ammo_xencandy:item_ammo
{
	void(void) ammo_xencandy;
	virtual void(void) touch;
};

void ammo_xencandy::ammo_xencandy(void)
{
	model = "models/w_xencandy.mdl";
	item_ammo::item_ammo();
}
void ammo_xencandy::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_xencandy < MAX_A_XENCANDY) {
			pl.ammo_xencandy = bound(0, pl.ammo_xencandy + 20, MAX_A_XENCANDY);
			item_ammo::touch();
		}
	}
}
