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

/*QUAKED ammo_556 (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

Ammo for the M249.
A single ammo_556 will provide 50 bullets.

*/
class ammo_556:item_ammo
{
	void() ammo_556;
	virtual void() touch;
};

void
ammo_556::ammo_556(void)
{
	model = "models/w_saw_clip.mdl";
	item_ammo::item_ammo();
}
void
ammo_556::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_556 < 200) {
			pl.ammo_556 = bound(0, pl.ammo_556 + 50, 200);
			item_ammo::touch();
		}
	}
}

/*QUAKED ammo_762 (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

Ammo for the M-40A1 Sniper.
A single ammo_762 will provide 5 bullets.

*/
class ammo_762:item_ammo
{
	void() ammo_762;
	virtual void() touch;
};

void
ammo_762::ammo_762(void)
{
	model = "models/w_m40a1clip.mdl";
	item_ammo::item_ammo();
}
void
ammo_762::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.ammo_762 < 15) {
			pl.ammo_762 = bound(0, pl.ammo_762 + 5, 15);
			item_ammo::touch();
		}
	}
}

/*QUAKED ammo_spore (0 0 0.8) (-16 -16 0) (16 16 32)

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

Ammo for the Spore Launcher.
A single ammo_spore will provide 1 spore.
The angle key refers to the direction the entity will fire (?)
when shot. The model itself uses decal-like logic to determine
the direction the model is aiming.

*/
class ammo_spore:item_ammo
{
	void() ammo_spore;
	virtual void() touch;
	virtual void() Respawn;
	virtual void(int) Death;
};

void
ammo_spore::ammo_spore(void)
{
	movetype = MOVETYPE_NONE;
	model = "models/spore_ammo.mdl";
	item_ammo::item_ammo();
}

void
ammo_spore::Death(int)
{
	makevectors(m_oldAngle);
	Sporelauncher_AltFire(this, origin, v_forward);
	frame = 2;
	m_iBody = 0;
	solid = SOLID_NOT;
	think = Respawn;
	nextthink = time + 10.0f;
}

void ammo_spore::Respawn(void)
{
	frame = 1;
	m_iBody = 2;
	movetype = MOVETYPE_NONE;
	takedamage = DAMAGE_YES;
	health = 1;

	if (m_oldModel) {
		setmodel(this, m_oldModel);
	}

	solid = SOLID_NOT;
	setsize(this, [0,0,0], [0,0,0]);
	setorigin(this, m_oldOrigin);

	decal_pickwall(this, m_oldOrigin);

	/* we never hit any wall. */
	if (g_tracedDecal.fraction == 1.0f) {
		print(sprintf("^xFA0Warning^7: ammo_spore tracing failed at %v\n", origin));
		return;
	}

	origin = g_tracedDecal.endpos;
	makevectors(vectoangles(g_tracedDecal.endpos - origin ));
	vector cpl = v_forward - (v_forward * g_tracedDecal.normal) * g_tracedDecal.normal;

	if (g_tracedDecal.normal[2] == 0) {
		cpl = [0, 0, 1];
	}
	angles = vectoangles(cpl, g_tracedDecal.normal);

	solid = SOLID_BBOX;
	setsize(this, [-16,-16,-16], [16,16,16]);
	think = __NULL__;
	nextthink = -1;
}

void
ammo_spore::touch(void)
{
	if not (other.flags & FL_CLIENT) {
		return;
	}

	player pl = (player)other;
	if (pl.ammo_spore < 20) {
		pl.ammo_spore = bound(0, pl.ammo_spore + 1, 20);
		player pl = (player)other;
		Weapons_RefreshAmmo(pl);
		Logging_Pickup(other, this, __NULL__);
		frame = 2;
		m_iBody = 0;
		think = Respawn;
		nextthink = time + 10.0f;
	}
}
