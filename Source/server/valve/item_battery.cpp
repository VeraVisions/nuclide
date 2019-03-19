/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class item_battery:CBaseEntity
{
	void() item_battery;
	virtual void() Respawn;
	virtual void() touch;
};

void item_battery::touch(void)
{
	if (other.classname == "player") {
		if (other.armor >= 100) {
			return;
		}
		/* Move this somewhere else? */
		other.armor += 15;
		if (other.armor > 100) {
			other.armor = 100;
		}

		sound(other, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM);

		if (cvar("sv_playerslots") == 1) {
			remove(self);
		} else {
			Hide();
			think = Respawn;
			nextthink = time + 20.0f;
		}
	}
}

void item_battery::Respawn(void)
{
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_TOSS;
	setmodel(this, m_oldModel);

	setsize(this, [-8,-8,0], [8,8,48]);
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
