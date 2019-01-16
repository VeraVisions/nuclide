/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class func_recharge:CBaseTrigger
{
	float m_flDelay;
	
	void() func_recharge;
	virtual void() PlayerUse;
};

void func_recharge::PlayerUse(void)
{
	eActivator.gflags &= ~GF_USE_RELEASED;

	if (m_flDelay > time) {
		return;
	}

	eActivator.armor = bound(0, eActivator.armor += 15, 100);
	m_flDelay = time + 1.0f;
}

void func_recharge::func_recharge(void)
{
	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	setorigin(this, origin);
	setmodel(this, model);
}
