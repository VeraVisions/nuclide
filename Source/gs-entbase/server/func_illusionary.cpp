/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CFuncIllusionary : CBaseEntity
{
	virtual void() Use;
};

void CFuncIllusionary :: CFuncIllusionary ( void )
{
	precache_model( model );
	//angles = '0 0 0';
	movetype = MOVETYPE_PUSH;
	self.solid = SOLID_NOT;
	setmodel( this, model );
	CBaseEntity::CBaseEntity();
}

void CFuncIllusionary :: Use ( void )
{
	skin = 1 - skin;
}

CLASSEXPORT( func_illusionary, CFuncIllusionary )
