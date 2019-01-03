/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class trigger_cdaudio : CBaseTrigger
{
	int m_iCDTrack;
	void() trigger_cdaudio;
	virtual void() Trigger;
};

void trigger_cdaudio :: Trigger ( void )
{
	//dprint( sprintf( "trigger_cdaudio: Now playing CD track %i", m_iCDTrack ) );
	WriteByte( MSG_ALL, 32 ); // aka SVC_CDTRACK
	WriteByte( MSG_ALL, m_iCDTrack );
	remove( this );
}

void trigger_cdaudio :: trigger_cdaudio ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "health":
			m_iCDTrack = stoi( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
	CBaseTrigger::InitBrushTrigger();
	touch = Trigger;
}
