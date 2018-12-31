/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CItemFood
{
	int m_iIsCan;
	void() CItemFood;
	virtual void() Setup;
	virtual void() Touch;
};

void CItemFood :: Touch ( void )
{
	if ( other.classname != "Player" ) {
		return;
	}
	
	if ( owner != __NULL__ ) {
		CEnvBeverage bevOwner = (CEnvBeverage)owner;
		bevOwner.m_iReady = TRUE;
	}
	
	solid = SOLID_NOT;
	remove( this );
}

void CItemFood :: Setup ( void )
{
	solid = SOLID_TRIGGER;
	setsize( this, '-8 -8 -8', '8 8 8' );
	touch = Touch;

	if ( m_iIsCan ) {
		sound( this, CHAN_ITEM, "weapons/g_bounce3.wav", 1.0f, ATTN_NORM );
	}
}

void CItemFood :: CItemFood ( void )
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

CLASSEXPORT( item_sodacan, CItemFood )
CLASSEXPORT( item_food, CItemFood )
