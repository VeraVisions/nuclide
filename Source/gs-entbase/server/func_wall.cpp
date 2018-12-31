/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CFuncWall : CBaseTrigger
{
	void() CFuncWall;
	virtual void() Trigger;
};

void CFuncWall :: CFuncWall ( void )
{
	precache_model( model );
	//angles = '0 0 0';
	movetype = MOVETYPE_PUSH;
	solid = SOLID_BSP;
	setmodel( this, model );
	CBaseTrigger::CBaseTrigger();
}

void CFuncWall :: Trigger ( void )
{
	frame = 1 - frame;
}

CLASSEXPORT( func_wall, CFuncWall )
CLASSEXPORT( func_train, CFuncWall )
