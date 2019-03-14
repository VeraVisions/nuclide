/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class item_suit:CBaseTrigger
{
	void() item_suit;

	virtual void() touch;
	virtual void() Respawn;
};

void item_suit::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.g_items & ITEM_SUIT) {
			return;
		}
		sound(other, CHAN_ITEM, "fvox/bell.wav", 1, ATTN_NORM);
		sound(other, CHAN_VOICE, "fvox/hev_logon.wav", 1, ATTN_NORM);
		pl.g_items |= ITEM_SUIT;

		CBaseTrigger::UseTargets();
	
		if (cvar("sv_playerslots") == 1) {
			remove(self);
		} else {
			Hide();
			think = Respawn;
			nextthink = time + 30.0f;
		}
	}
}

void item_suit::Respawn(void)
{
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_TOSS;
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	setorigin(this, m_oldOrigin);
	setmodel(this, m_oldModel);

	think = __NULL__;
	nextthink = -1;
	sound(this, CHAN_ITEM, "items/suitchargeok1.wav", 1, ATTN_NORM, 150);
}

void item_suit::item_suit(void)
{
	model = "models/w_suit.mdl";
	precache_sound("items/suitchargeok1.wav");
	precache_sound("fvox/hev_logon.wav");
	precache_sound("fvox/bell.wav");
	CBaseTrigger::CBaseTrigger();
	Respawn();
}
