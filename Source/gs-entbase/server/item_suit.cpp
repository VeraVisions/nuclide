/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class item_suit:CBaseTrigger
{
	void() item_suit;
	virtual void() touch;
};

void item_suit::touch(void)
{
	Trigger();
	Hide();
}

void item_suit::item_suit(void)
{
	CBaseTrigger::CBaseTrigger();

	precache_model("models/w_kevlar.mdl");
	setmodel( self, "models/w_kevlar.mdl");
	InitPointTrigger();
}
