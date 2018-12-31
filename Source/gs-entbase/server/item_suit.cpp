/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CItemSuit:CBaseTrigger
{
	void() CItemSuit;
	virtual void() touch;
};

void CItemSuit::touch(void)
{
	Trigger();
	Hide();
}

void CItemSuit::CItemSuit(void)
{
	CBaseTrigger::CBaseTrigger();

	precache_model("models/w_kevlar.mdl");
	setmodel( self, "models/w_kevlar.mdl");
	InitPointTrigger();
}

CLASSEXPORT(item_suit, CItemSuit)
