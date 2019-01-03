/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class func_wall : CBaseTrigger
{
	void() func_wall;
	virtual void() Trigger;
};

void func_wall :: func_wall ( void )
{
	precache_model( model );
	//angles = '0 0 0';
	movetype = MOVETYPE_PUSH;
	solid = SOLID_BSP;
	setmodel( this, model );
	CBaseTrigger::CBaseTrigger();
}

void func_wall :: Trigger ( void )
{
	frame = 1 - frame;
}

CLASSEXPORT( func_train, func_wall )
