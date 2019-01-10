/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class env_shooter : CBaseTrigger
{
	int m_iGibs;
	int m_iGibsLeft;

	float m_flDelay;
	float m_flVelocity;
	float m_flVariance;
	float m_flGibLife;
	string m_strShootModel;
	float m_flShootSounds;
	float m_flScale;
	float m_flSkin;
	
	void() env_shooter;
	virtual void() Respawn;
	virtual void() ShootGib;
	virtual void() Trigger;
};

void env_shooter::ShootGib(void)
{
	static void Gib_Remove ( void ) { remove( self ); }

	entity eGib = spawn();
	eGib.movetype = MOVETYPE_BOUNCE;
	setmodel(eGib, m_strShootModel);
	setorigin(eGib, origin);

	makevectors(angles);
	eGib.velocity = v_forward * m_flVelocity + [0,0,64 + (random()*64)];
	eGib.avelocity[0] = Math_CRandom() * 32;
	eGib.avelocity[1] = Math_CRandom() * 32;
	eGib.avelocity[2] = Math_CRandom() * 32;

	eGib.think = Gib_Remove;
	eGib.nextthink = time + m_flGibLife;
	eGib.angles = angles;

	m_iGibsLeft--;

	if (m_iGibsLeft) {
		nextthink = time + m_flVariance;
	}
}

void env_shooter :: Trigger ( void )
{
	think = ShootGib;
	nextthink = time + m_flVariance;
}

void env_shooter :: Respawn ( void )
{
	m_iGibsLeft = m_iGibs;
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
	env_shooter::Respawn();
}
