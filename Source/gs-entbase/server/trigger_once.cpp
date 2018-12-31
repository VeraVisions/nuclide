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
	TO_MONSTERS,
	TO_NOCLIENTS,
	TO_PUSHABLES
};

class CTriggerOnce : CBaseTrigger
{
	float m_flDelay;
	void() CTriggerOnce;
	virtual void() touch;
	virtual void() Respawn;
};

void CTriggerOnce :: touch ( void )
{
	if ( m_flDelay > 0 ) {
		CBaseTrigger::UseTargets_Delay( m_flDelay );
	} else {
		CBaseTrigger::UseTargets();
	}
	solid = SOLID_NOT;
#ifdef GS_DEVELOPER
	alpha = 0.001f;
#endif
}

void CTriggerOnce :: Respawn ( void )
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void CTriggerOnce :: CTriggerOnce ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "delay":
			m_flDelay = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	CTriggerOnce::Respawn();
	CBaseEntity::CBaseEntity();
	CBaseTrigger::InitBrushTrigger();
}

CLASSEXPORT( trigger_once, CTriggerOnce )
