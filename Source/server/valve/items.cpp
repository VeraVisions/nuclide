/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* WEAPON ITEMS */
class itemweapon:CBaseEntity
{
	int id;
	void() itemweapon;
	virtual void() touch;
	virtual void(int i) setitem;
	
	virtual void() Respawn;
};

void itemweapon::touch(void)
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

void itemweapon::setitem(int i)
{
	id = i;
	m_oldModel = Weapons_GetWorldmodel(id);
	setmodel(this, m_oldModel);
}

void itemweapon::Respawn(void)
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
	sound(this, CHAN_ITEM, "items/suitchargeok1.wav", 1, ATTN_NORM);
}

void itemweapon::itemweapon(void)
{
	CBaseEntity::CBaseEntity();
	Respawn();
}
