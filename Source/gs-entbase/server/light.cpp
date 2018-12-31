/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CLight : CBaseTrigger
{
	string m_strPattern;
	int m_iEnabled;
	float m_flStyle;
	void() CLight;
	virtual void() Trigger;
};

void CLight :: Trigger ( void )
{
	if ( m_iEnabled == TRUE ) {
		//dprint( "CLight: Turned off!\n" );
		lightstyle( m_flStyle, "a" );
		m_iEnabled = FALSE;
	} else {
		//dprint( "CLight: Turned on!\n" );
		lightstyle( m_flStyle, m_strPattern );
		m_iEnabled = TRUE;
	}
}

void CLight :: CLight ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "pattern":
			m_strPattern = argv( i + 1 );
			break;
		case "style":
			m_flStyle = stof( argv( i + 1 ) );
			style = __NULL__;
			break;
		default:
			break;
		}
	}

	/*if ( !m_strPattern ) {
		m_strPattern = getlightstyle( m_flStyle );
	}*/

	if ( !m_strPattern ) {
		m_strPattern = "m";
	}

	if ( spawnflags & 1 ) {
		lightstyle( m_flStyle, "a" );
		m_iEnabled = FALSE;
	} else {
		lightstyle( m_flStyle, m_strPattern );
		m_iEnabled = TRUE;
	}
}

CLASSEXPORT( light, CLight )
CLASSEXPORT( light_spot, CLight )

