/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class func_ladder : CBaseEntity {
	void() func_ladder;
};

void func_ladder :: func_ladder ( void )
{
	setmodel( this, model );
	movetype = MOVETYPE_NONE;
	skin = CONTENT_LADDER;
	solid = SOLID_BSP;
	
#ifdef GS_DEVELOPER
	alpha = 0.5f;
	effects = EF_ADDITIVE;
#else
	effects = EF_NODRAW;
	alpha = 0.0001f;
#endif
}
