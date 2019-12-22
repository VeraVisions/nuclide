/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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
	void() item_ammo;
	virtual void() Respawn;
	virtual void() touch;
};

void item_ammo::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	player pl = (player)other;
	sound(other, CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
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
		setmodel(this, m_oldModel);
	}

	setsize(this, [-16,-16,0], [16,16,16]);
	setorigin(this, origin);

	think = __NULL__;
	nextthink = -1;
	sound(this, CHAN_ITEM, "items/suitchargeok1.wav", 1, ATTN_NORM, 150);
	droptofloor();
}

void item_ammo::item_ammo(void)
{
	m_oldModel = model;
	setmodel(this, m_oldModel);
	CBaseEntity::CBaseEntity();
	item_ammo::Respawn();
}

/*
 * Ammo for the Crossbow.
 * A single ammo_bolts will provide 5 bolts.
 */

class 
ammo_bolts:item_ammo
{
	void() ammo_bolts;
};

void 
ammo_bolts::ammo_bolts(void)
{
	model = "models/w_crossbow_clip.mdl";
}

/*
 * Ammo for the nailguns.
 * A single ammo_nailclip will provide 25 nails.
 */

class 
ammo_nailclip:item_ammo
{
	void() ammo_nailclip;
};

void 
ammo_nailclip::ammo_nailclip(void)
{
	model = "models/w_nailclip.mdl";
}

/*
 * Ammo for the Nailgun.
 * A single ammo_nailround will provide 50 nails.
 */

class 
ammo_nailround:item_ammo
{
	void() ammo_nailround;
};

void 
ammo_nailround::ammo_nailround(void)
{
	model = "models/w_nailround.mdl";
}

/*
 * Ammo for the alien.
 * A single ammo_xencandy will provide 20 snacks.
 */

class 
ammo_xencandy:item_ammo
{
	void() ammo_xencandy;
};

void
ammo_xencandy::ammo_xencandy(void)
{
	model = "models/w_xencandy.mdl";
}
