/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CTriggerCDAudio : CBaseTrigger
{
	int m_iCDTrack;
	void() CTriggerCDAudio;
	virtual void() Trigger;
};

void CTriggerCDAudio :: Trigger ( void )
{
	//dprint( sprintf( "CTriggerCDAudio: Now playing CD track %i", m_iCDTrack ) );
	WriteByte( MSG_ALL, 32 ); // aka SVC_CDTRACK
	WriteByte( MSG_ALL, m_iCDTrack );
	remove( this );
}

void CTriggerCDAudio :: CTriggerCDAudio ( void )
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

CLASSEXPORT( trigger_cdaudio, CTriggerCDAudio )
