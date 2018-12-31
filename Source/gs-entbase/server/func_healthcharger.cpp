/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CFuncHealthCharger:CBaseTrigger
{
	float m_flDelay;

	void() CFuncHealthCharger;
	virtual void() PlayerUse;
};

void CFuncHealthCharger::PlayerUse(void)
{
	eActivator.flags = (eActivator.flags - FL_USERELEASED);

	if (m_flDelay > time) {
		return;
	}

	eActivator.health = bound(0, eActivator.health += 15, 100);
	m_flDelay = time + 1.0f;
}

void CFuncHealthCharger::CFuncHealthCharger(void)
{
	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	setorigin(this, origin);
	setmodel(this, model);
	gflags = GF_USABLE;
}

CLASSEXPORT(func_healthcharger, CFuncHealthCharger)
