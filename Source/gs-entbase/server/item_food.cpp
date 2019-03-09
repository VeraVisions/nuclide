/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class item_food
{
	int m_iIsCan;
	void() item_food;
	virtual void() Setup;
	virtual void() Touch;
};

void item_food :: Touch ( void )
{
	if ( other.classname != "player" ) {
		return;
	}
	
	if ( owner != __NULL__ ) {
		env_beverage bevOwner = (env_beverage)owner;
		bevOwner.m_iReady = TRUE;
	}
	
	Damage_Apply(other, this, -1, other.origin, FALSE);
	solid = SOLID_NOT;
	remove( this );
}

void item_food :: Setup ( void )
{
	solid = SOLID_TRIGGER;
	setsize( this, '-16 -16 -16', '16 16 16' );
	touch = Touch;

	if ( m_iIsCan ) {
		sound( this, CHAN_ITEM, "weapons/g_bounce3.wav", 1.0f, ATTN_NORM );
	}
}

void item_food :: item_food ( void )
{
	// TODO: differentiate between item_sodacan and item_food
	m_iIsCan = 1;

	solid = SOLID_NOT;
	movetype = MOVETYPE_TOSS;

	if ( m_iIsCan ) {
		setmodel( this, "models/can.mdl" );
	}

	setsize( this, '0 0 0', '0 0 0' );
	think = Setup;
	nextthink = time + 1.0f;
}

CLASSEXPORT( item_sodacan, item_food )
