/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class info_null
{
	void() info_null;
};

void info_null :: info_null ( void )
{
	remove( self );
}

class info_notnull:CBaseTrigger
{
	void() info_notnull;
};

void info_notnull :: info_notnull ( void )
{
	CBaseTrigger::CBaseTrigger();
}

CLASSEXPORT( info_node, info_notnull )
CLASSEXPORT( info_target, info_notnull )

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
