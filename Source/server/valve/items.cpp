/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* PICKUP ITEMS */
class item_pickup:CBaseEntity
{
	int id;
	void() item_pickup;

	virtual void() touch;
	virtual void(int i) setitem;
	virtual void() Respawn;
};

void item_pickup::touch(void)
{
	if (other.classname == "player") {
		if (Weapons_IsPresent((player)other, id) == TRUE) {
			return;
		}
		sound(other, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM);
		Weapons_AddItem((player)other, id);

		if (cvar("sv_playerslots") == 1) {
			remove(self);
		} else {
			Hide();
			think = Respawn;
			nextthink = time + 30.0f;
		}
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
	setsize(this, [-24,-24,-16], [24,24,16]);
	setorigin(this, origin);
	
	/* At some points, the item id might not yet be set */
	if (m_oldModel) {
		setmodel(this, m_oldModel);
	}
	
	think = __NULL__;
	nextthink = -1;
	sound(this, CHAN_ITEM, "items/suitchargeok1.wav", 1, ATTN_NORM, 150);
}

void item_pickup::item_pickup(void)
{
	precache_sound("items/suitchargeok1.wav");
	CBaseEntity::CBaseEntity();
	Respawn();
}
