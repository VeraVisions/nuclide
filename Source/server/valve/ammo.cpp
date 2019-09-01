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
	if (other.classname == "player") {
		player pl = (player)other;
		sound(other, CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
		
		if (cvar("sv_playerslots") == 1) {
			remove(self);
		} else {
			Hide();
			think = Respawn;
			nextthink = time + 20.0f;
		}
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
 * Ammo for the .357 Magnum Revolver.
 * A single ammo_357 will provide 6 bullets.
 */
class ammo_357:item_ammo
{
	void() ammo_357;
	virtual void() touch;
};

void ammo_357::ammo_357(void)
{
	model = "models/w_357ammobox.mdl";
	item_ammo::item_ammo();
}
void ammo_357::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_357 < 36) {
			pl.ammo_357 = bound(0, pl.ammo_357 + 6, 36);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the 9mm Handgun and the 9mm AR.
 * A single ammo_9mmAR will provide 50 bullets.
 */
class ammo_9mmAR:item_ammo
{
	void() ammo_9mmAR;
	virtual void() touch;
};

void ammo_9mmAR::ammo_9mmAR(void)
{
	model = "models/w_9mmarclip.mdl";
	item_ammo::item_ammo();
}
void ammo_9mmAR::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_9mm < 250) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 50, 250);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the 9mm Handgun and the 9mm AR.
 * A single ammo_9mmbox will provide 200 bullets.
 */
class ammo_9mmbox:item_ammo
{
	void() ammo_9mmbox;
	virtual void() touch;
};

void ammo_9mmbox::ammo_9mmbox(void)
{
	model = "models/w_chainammo.mdl";
	item_ammo::item_ammo();
}
void ammo_9mmbox::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_9mm < 250) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 200, 250);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the 9mm Handgun and the 9mm AR.
 * A single ammo_9mmclip will provide 17 bullets.
 */
class ammo_9mmclip:item_ammo
{
	void() ammo_9mmclip;
	virtual void() touch;
};

void ammo_9mmclip::ammo_9mmclip(void)
{
	model = "models/w_9mmclip.mdl";
	item_ammo::item_ammo();
}
void ammo_9mmclip::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_9mm < 250) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 17, 250);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the 9mm AR's secondary fire.
 * A single ammo_ARgrenades will provide 2 AR grenades.
 */
class ammo_ARgrenades:item_ammo
{
	void() ammo_ARgrenades;
	virtual void() touch;
};

void ammo_ARgrenades::ammo_ARgrenades(void)
{
	model = "models/w_argrenade.mdl";
	item_ammo::item_ammo();
}
void ammo_ARgrenades::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_m203_grenade < 10) {
			pl.ammo_m203_grenade = bound(0, pl.ammo_m203_grenade + 2, 10);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the Shotgun.
 * A single ammo_buckshot will provide 12 shells.
 */
class ammo_buckshot:item_ammo
{
	void() ammo_buckshot;
	virtual void() touch;
};

void ammo_buckshot::ammo_buckshot(void)
{
	model = "models/w_shotbox.mdl";
	item_ammo::item_ammo();
}
void ammo_buckshot::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_buckshot < 125) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 12, 125);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the Crossbow.
 * A single ammo_crossbow will provide 5 bolts.
 */
class ammo_crossbow:item_ammo
{
	void() ammo_crossbow;
	virtual void() touch;
};

void ammo_crossbow::ammo_crossbow(void)
{
	model = "models/w_crossbow_clip.mdl";
	item_ammo::item_ammo();
}
void ammo_crossbow::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_bolt < 50) {
			pl.ammo_bolt = bound(0, pl.ammo_bolt + 5, 50);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the Tau Cannon and the Gluon Gun.
 * A single ammo_gaussclip will provide 20 cells.
 */
class ammo_gaussclip:item_ammo
{
	void() ammo_gaussclip;
	virtual void() touch;
};

void ammo_gaussclip::ammo_gaussclip(void)
{
	model = "models/w_gaussammo.mdl";
	item_ammo::item_ammo();
}
void ammo_gaussclip::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_uranium < 100) {
			pl.ammo_uranium = bound(0, pl.ammo_uranium + 20, 100);
			item_ammo::touch();
		}
	}
}

/*
 * Ammo for the RPG.
 * A single ammo_rpgclip will provide 1 rocket.
 */
class ammo_rpgclip:item_ammo
{
	void() ammo_rpgclip;
	virtual void() touch;
};

void ammo_rpgclip::ammo_rpgclip(void)
{
	model = "models/w_rpgammo.mdl";
	item_ammo::item_ammo();
}
void ammo_rpgclip::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_rocket < 5) {
			pl.ammo_rocket = bound(0, pl.ammo_rocket + 1, 5);
			item_ammo::touch();
		}
	}
}
