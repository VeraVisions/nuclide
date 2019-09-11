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

class item_battery:CBaseEntity
{
	void() item_battery;
	virtual void() Respawn;
	virtual void() touch;
};

void item_battery::touch(void)
{
	if (other.classname != "player") {
		return;
	}
	
	if (other.armor >= 100) {
		return;
	}
	/* Move this somewhere else? */
	other.armor += 15;
	if (other.armor > 100) {
		other.armor = 100;
	}

	Logging_Pickup(other, this, __NULL__);
	sound(other, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM);

	if (cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 20.0f;
	}
}

void item_battery::Respawn(void)
{
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_TOSS;
	setmodel(this, m_oldModel);

	setsize(this, [-16,-16,0], [16,16,16]);
	setorigin(this, m_oldOrigin);

	think = __NULL__;
	nextthink = -1;
	sound(this, CHAN_ITEM, "items/suitchargeok1.wav", 1, ATTN_NORM, 150);
	droptofloor();
}

void item_battery::item_battery(void)
{
	model = "models/w_battery.mdl";
	CBaseEntity::CBaseEntity();
	item_healthkit::Respawn();
}
