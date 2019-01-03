/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class env_shooter : CBaseTrigger
{
	float m_iGibs;
	float m_flDelay;
	float m_flVelocity;
	float m_flVariance;
	float m_flGibLife;
	string m_strShootModel;
	float m_flShootSounds;
	float m_flScale;
	float m_flSkin;
};

void env_shooter :: Trigger ( void )
{
	static void Gib_Remove ( void ) { remove( self ); }
	for ( int i = 0; i < m_iGibs; i++ ) {
		entity eGib = spawn();
		eGib.movetype = MOVETYPE_BOUNCE;
		setmodel( eGib, m_strShootModel );
		
		makevectors( angles );
		eGib.velocity = v_forward * m_flVelocity;
		eGib.think = Gib_Remove;
		eGib.nextthink = m_flGibLife;
	}
}

void env_shooter :: env_shooter ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "m_iGibs":
			m_iGibs = stoi( argv( i + 1 ) );
			break;
		case "m_flDelay":
			m_flDelay = stof( argv( i + 1 ) );
			break;
		case "m_flVelocity":
			m_flVelocity = stof( argv( i + 1 ) );
			break;
		case "m_flVariance":
			m_flVariance = stof( argv( i + 1 ) );
			break;
		case "m_flGibLife":
			m_flGibLife = stof( argv( i + 1 ) );
			break;
		case "shootmodel":
			m_strShootModel = argv( i + 1 );
			break;
		case "shootsounds":
			m_flShootSounds = stof( argv( i + 1 ) );
			break;
		case "scale":
			m_flScale = stof( argv( i + 1 ) );
			break;
		case "skin":
			m_flSkin = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	
	precache_model( m_strShootModel );
	CBaseTrigger::CBaseTrigger();
}
