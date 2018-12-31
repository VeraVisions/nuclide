/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CInfoNull
{
	void() CInfoNull;
};

void CInfoNull :: CInfoNull ( void )
{
	remove( self );
}

class CInfoNotNull
{
	void() CInfoNotNull;
};

void CInfoNotNull :: CInfoNotNull ( void )
{
	
}

CLASSEXPORT( info_null, CInfoNull )
CLASSEXPORT( info_notnull, CInfoNotNull )
CLASSEXPORT( info_node, CInfoNotNull )
CLASSEXPORT( info_target, CInfoNotNull )

/*class CSuit : CBaseTrigger
{
	void CSuit;
	virtual void() Trigger;
};

void CSuit :: Trigger ( void )
{
	CBaseTrigger::UseTargets();
	remove( self );
}

void CSuit :: CSuit ( void )
{
	CBaseTrigger::CBaseTrigger();
	
	solid = SOLID_TRIGGER;
	model = "models/w_suit.mdl";
	precache_model( model );
	setmodel( this, model );
	touch = Trigger;
}
SPAWNEXPORT item_suit ( void ) { spawnfunc_CSuit(); }
SPAWNEXPORT world_items ( void ) { spawnfunc_CSuit(); }*/
