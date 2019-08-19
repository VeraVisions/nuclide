/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class item_longjump:CBaseTrigger
{
	void() item_longjump;

	virtual void() touch;
	virtual void() Respawn;
};

void item_longjump::touch(void)
{
	if (other.classname == "player") {
		player pl = (player)other;
		if (pl.g_items & ITEM_LONGJUMP) {
			return;
		}
		sound(other, CHAN_ITEM, "fvox/blip.wav", 1, ATTN_NORM);
		sound(other, CHAN_VOICE, "fvox/powermove_on.wav", 1, ATTN_NORM);
		pl.g_items |= ITEM_LONGJUMP;

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

void item_longjump::Respawn(void)
{
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_TOSS;
	setsize(this, [-16,-16,0],[16,16,16]);
	setorigin(this, m_oldOrigin);
	setmodel(this, m_oldModel);

	think = __NULL__;
	nextthink = -1;
	sound(this, CHAN_ITEM, "items/suitchargeok1.wav", 1, ATTN_NORM, 150);
}

void item_longjump::item_longjump(void)
{
	model = "models/w_longjump.mdl";
	precache_sound("items/suitchargeok1.wav");
	precache_sound("fvox/powermove_on.wav");
	precache_sound("fvox/blip.wav");
	CBaseTrigger::CBaseTrigger();
	Respawn();
}
