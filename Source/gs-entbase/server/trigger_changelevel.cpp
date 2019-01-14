/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

vector g_landmarkpos;

enumflags
{
	LC_NOINTERMISSION,	// Unused?
	LC_USEONLY
};

class trigger_changelevel : CBaseTrigger
{
	string m_strMap;
	string m_strLandmark;
	float m_flChangeDelay;
	entity m_activator;

	void() trigger_changelevel;
	virtual void() Change;
	virtual void() Trigger;
	virtual int( entity, entity ) IsInside;
};

int trigger_changelevel :: IsInside ( entity ePlayer, entity eVolume ) {
	if ( ePlayer.absmin[0] > eVolume.absmax[0] ||
		 ePlayer.absmin[1] > eVolume.absmax[1] ||
		 ePlayer.absmin[2] > eVolume.absmax[2] ||
		 ePlayer.absmax[0] < eVolume.absmin[0] ||
		 ePlayer.absmax[1] < eVolume.absmin[1] ||
		 ePlayer.absmax[2] < eVolume.absmin[2] )
		 return FALSE;
	return TRUE;
}

void trigger_changelevel :: Change ( void )
{
	if ( m_strLandmark ) {
		entity landmark = find( world, ::targetname, m_strLandmark );
		g_landmarkpos = m_activator.origin - landmark.origin;
		changelevel( m_strMap, m_strLandmark );
	} else {
		changelevel( m_strMap );
	}
}

void trigger_changelevel :: Trigger ( void )
{
	//entity eVolume;
	
	if ( time < 5 ) {
		return;
	}
	
	/*eVolume = find( world, ::targetname, m_strLandmark );
	if ( eVolume && eVolume.classname == "CTriggerVolume" ) {
		if ( IsInside( other, eVolume ) == FALSE ) {
			return;
		}
	}*/

	m_activator = other;
	if ( m_flChangeDelay ) {
		think = Change;
		nextthink = time + m_flChangeDelay;
	} else {
		Change();
	}
}

void trigger_changelevel :: trigger_changelevel ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "map":
			m_strMap = argv( i + 1 );
			break;
		case "landmark":
			m_strLandmark = argv( i + 1 );
			break;
		case "changedelay":
			m_flChangeDelay = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
	
	if ( !( spawnflags & LC_USEONLY ) ) {
		touch = Trigger;
	}

	CBaseTrigger::InitBrushTrigger();
}

CLASSEXPORT( info_landmark, info_notnull )

vector Landmark_GetSpot(void)
{
	entity landmark = find(world, targetname, startspot);
	return landmark.origin + g_landmarkpos;
}
