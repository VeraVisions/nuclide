/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum { 
	USE_TOGGLE,
	USE_CONTINOUS
};

class CBaseTrigger : CBaseEntity
{
	int m_strGlobalState;
	string m_strTarget;
	string m_strTargetName;
	string m_strKillTarget;
	string m_strMessage;
	int m_iUseType;
	void() CBaseTrigger;
	virtual void() Trigger;
	virtual void() UseTargets;
	virtual int() GetValue;
	virtual void( float del ) UseTargets_Delay;
	virtual void() InitBrushTrigger;
	virtual void() InitPointTrigger;
};

void CBaseTrigger :: UseTargets ( void )
{
	for ( entity eFind = world; ( eFind = find( eFind, CBaseTrigger::m_strTargetName, m_strTarget ) ); ) {
		CBaseTrigger trigger = (CBaseTrigger) eFind;
#ifdef GS_DEVELOPER
		print( sprintf( "%s: Triggering %s `%s`\n", 
				this.classname, eFind.classname, trigger.m_strTargetName ) );
#endif
		trigger.Trigger();
	}

	if ( m_strKillTarget ) {
		entity eKill = find( world, CBaseTrigger::m_strTargetName, m_strKillTarget );
		if ( eKill ) {
			remove( eKill );
		}
	}
}

int CBaseTrigger :: GetValue ( void )
{
	return TRUE;
}

void CBaseTrigger :: UseTargets_Delay ( float fDelay )
{
	static void Entities_UseTargets_Delay_Think( void ) {
		CBaseTrigger::UseTargets();
		remove( self );
	}

#ifdef GS_DEVELOPER
	print( sprintf( "CBaseTrigger: Delaying trigger of `%s`\n", m_strTarget ) );
#endif

	CBaseTrigger eTimer = spawn( CBaseTrigger );
	eTimer.owner = self;
	eTimer.think = Entities_UseTargets_Delay_Think;
	eTimer.m_strTarget = m_strTarget;
	eTimer.nextthink = time + fDelay;
}

void CBaseTrigger :: Trigger ( void )
{
	
}

void CBaseTrigger :: InitPointTrigger ( void )
{
	setsize( this, VEC_HULL_MIN, VEC_HULL_MAX );
	solid = SOLID_TRIGGER;
}

void CBaseTrigger :: InitBrushTrigger ( void )
{
	precache_model( model );
	movetype = MOVETYPE_NONE;
	solid = SOLID_TRIGGER;
	setmodel( this, model );
#ifdef GS_DEVELOPER
	alpha = 0.5f;
	effects = EF_FLAG2;
#else
	modelindex = 0;
	model = "";
#endif
}

void CBaseTrigger :: CBaseTrigger ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "target":
			m_strTarget = argv( i + 1 );
			target = __NULL__;
			break;
		case "targetname":
			m_strTargetName = argv( i + 1 );
			targetname = __NULL__;
			break;
		case "killtarget":
			m_strKillTarget = argv( i + 1 );
			break;
		case "message":
			m_strMessage = argv( i + 1);
			break;
		default:
			break;
		}
	}
	CBaseEntity::CBaseEntity();
}
