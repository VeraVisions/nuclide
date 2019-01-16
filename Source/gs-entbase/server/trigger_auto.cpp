/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class trigger_auto : CBaseTrigger
{
	float m_flDelay;
	
	void() trigger_auto;
	virtual void() think;
};

void trigger_auto :: think ( void )
{
	// This is weird, because ents may not be spawned yet.
	// However, Half-Life doesn't care about this, either.
	// So why should we?
	CBaseTrigger::UseTargets_Delay( m_flDelay );

	if ( spawnflags & 1 ) {
		remove( this );
	}
}

void trigger_auto :: trigger_auto ( void )
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
	CBaseTrigger::CBaseTrigger();
	nextthink = time + 0.2f;
}
