/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class func_illusionary : CBaseEntity
{
	virtual void() Use;
};

void func_illusionary :: func_illusionary ( void )
{
	CBaseEntity::CBaseEntity();
	precache_model( model );
	//angles = '0 0 0';
	movetype = MOVETYPE_PUSH;
	solid = SOLID_NOT;
	setmodel( this, model );

	// FIXME: Add support for (skin) -1 = Empty, -7 = Volumetric light
	if (skin < 0 ) {
		skin = 0;
	}
}

void func_illusionary :: Use ( void )
{
	skin = 1 - skin;
}
