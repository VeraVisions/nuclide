/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	FTW_STARTHIDDEN
};

class func_wall_toggle:CBaseTrigger
{
	void() func_wall_toggle;
	virtual void() Trigger;
};

void func_wall_toggle::func_wall_toggle(void)
{
	precache_model(model);
	//angles = '0 0 0';
	movetype = MOVETYPE_PUSH;
	solid = SOLID_BSP;
	setmodel(this, model);
	CBaseTrigger::CBaseTrigger();
	
	if (spawnflags & FTW_STARTHIDDEN) {
		Trigger();
	}
}

void func_wall_toggle::Trigger(void)
{
	if (solid == SOLID_BSP) {
		solid = SOLID_NOT;
		modelindex = 0;
		model = "";
	} else {
		solid = SOLID_BSP;
		model = m_oldModel;
		setmodel(this, model);
	}
}
