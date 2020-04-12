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

/* PICKUP ITEMS */
class item_pickup:CBaseTrigger
{
	int id;
	void(void) item_pickup;

	virtual void(void) touch;
	virtual void(int i) setitem;
	virtual void(void) Respawn;
};

void item_pickup::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	/* don't remove if AddItem fails */
	if (Weapons_AddItem((player)other, id) == FALSE) {
		return;
	}

	Logging_Pickup(other, this, __NULL__);
	sound(other, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM);

	CBaseTrigger::UseTargets();

	if (cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 30.0f;
	}
}

void item_pickup::setitem(int i)
{
	id = i;
	m_oldModel = Weapons_GetWorldmodel(id);
	setmodel(this, m_oldModel);
}

void item_pickup::Respawn(void)
{
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_TOSS;
	setorigin(this, m_oldOrigin);

	/* At some points, the item id might not yet be set */
	if (m_oldModel) {
		setmodel(this, m_oldModel);
	}

	setsize(this, [-16,-16,0], [16,16,16]);
	
	think = __NULL__;
	nextthink = -1;
	sound(this, CHAN_ITEM, "items/suitchargeok1.wav", 1, ATTN_NORM, 150);
	droptofloor();
}

void item_pickup::item_pickup(void)
{
	precache_sound("items/suitchargeok1.wav");
	CBaseTrigger::CBaseTrigger();
	Respawn();
}
