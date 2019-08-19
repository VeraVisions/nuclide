/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class item_healthkit:CBaseEntity
{
	void() item_healthkit;
	virtual void() Respawn;
	virtual void() touch;
};

void item_healthkit::touch(void)
{
	if (other.classname == "player") {
		if (other.health >= other.max_health) {
			return;
		}
		Damage_Apply(other, this, -20, this.origin, TRUE);
		sound(this, CHAN_ITEM, "items/smallmedkit1.wav", 1, ATTN_NORM);

		if (cvar("sv_playerslots") == 1) {
			remove(self);
		} else {
			Hide();
			think = Respawn;
			nextthink = time + 20.0f;
		}
	}
}

void item_healthkit::Respawn(void)
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

void item_healthkit::item_healthkit(void)
{
	precache_sound("items/smallmedkit1.wav");
	precache_sound("items/suitchargeok1.wav");
	model = "models/w_medkit.mdl";
	CBaseEntity::CBaseEntity();
	item_healthkit::Respawn();
}
