/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

// TODO: These are missing
enumflags
{
	TM_MONSTERS,
	TM_NOCLIENTS,
	TM_PUSHABLES
};

class trigger_multiple : CBaseTrigger
{
	float m_flDelay;
	float m_flWait;
	void() trigger_multiple;
	virtual void() touch;
	virtual void() Respawn;
};

void trigger_multiple :: touch ( void )
{
	eActivator = other;

	if ( m_flDelay > 0 ) {
		CBaseTrigger::UseTargets_Delay( m_flDelay );
	} else {
		CBaseTrigger::UseTargets();
	}
	
	/* This is effectively a trigger_once...*/
	if (m_flWait != -1) {
		think = Respawn;
		nextthink = time + m_flWait;
	}
	solid = SOLID_NOT;
	
#ifdef GS_DEVELOPER
	alpha = 0.001f;
#endif
}

void trigger_multiple :: Respawn ( void )
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void trigger_multiple :: trigger_multiple ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "delay":
			m_flDelay = stof( argv( i + 1 ) );
			break;
		case "wait":
			m_flWait = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}

	trigger_multiple::Respawn();
	CBaseEntity::CBaseEntity();
	CBaseTrigger::InitBrushTrigger();
}
