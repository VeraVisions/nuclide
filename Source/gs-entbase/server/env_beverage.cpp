/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

// Dependency from item_food.cpp
void item_sodacan( void );

// TODO: Implement support for skins
enum
{
	SKIN_COCACOLA,
	SKIN_SPRITE,
	SKIN_DIETCOKE,
	SKIN_ORANGE,
	SKIN_SURGE,
	SKIN_MOXIE,
	SKIN_RANDOM
};

class CEnvBeverage : CBaseTrigger
{
	int m_iUses;
	int m_iReady;
	int m_iSkin;
	void() CEnvBeverage;
	virtual void() Trigger;
};

void CEnvBeverage :: Trigger ( void )
{
	if ( m_iReady == FALSE || m_iUses <= 0 ) {
		return;
	}

	entity eCan = spawn();
	setorigin( eCan, origin );
	eCan.angles = angles;
	eCan.owner = this;
	eCan.think = item_sodacan;
	eCan.nextthink = time;

	m_iUses--;
	m_iReady = FALSE;
}

void CEnvBeverage :: CEnvBeverage ( void )
{
	precache_model( "models/can.mdl" );
	precache_sound( "weapons/g_bounce3.wav" );
	CBaseTrigger::CBaseTrigger();

	for ( int i = 1; i < (  tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "health":
			m_iUses = stoi( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}

	if ( !m_iUses ) {
		m_iUses = 10;
	}
	m_iReady = TRUE;
}

CLASSEXPORT( env_beverage, CEnvBeverage )
