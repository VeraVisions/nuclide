/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define SF_HURT_ONCE 			1 // Turn off once it fired the first time
#define SF_HURT_OFF 			2 // Needs to be triggered in order to work again
#define SF_HURT_NOPLAYERS 		8 // Don't hurt players
#define SF_HURT_FIREONPLAYER 	16 // Only call UseTarget functions when it's a player
#define SF_HURT_TOUCHPLAYER 	32 // Only hurt players

class trigger_hurt : CBaseTrigger
{
	float	m_flNextTrigger;
	int		m_iDamage;
	float	m_flDelay;
	void()	trigger_hurt;
	
	virtual void() Trigger;
	virtual void() Touch;
};

void trigger_hurt :: Trigger ( void )
{
	if ( solid == SOLID_NOT ) {
		solid = SOLID_TRIGGER;
	} else {
		solid = SOLID_NOT;
	}
}

void trigger_hurt :: Touch ( void )
{
	if ( m_flNextTrigger > time ) {
		return;
	} else if ( other.takedamage == DAMAGE_NO ) {
		return;
	} else if ( ( spawnflags & SF_HURT_TOUCHPLAYER ) && !( other.flags & FL_CLIENT ) ) {
		return;
	} else if ( ( spawnflags & SF_HURT_NOPLAYERS ) && ( other.flags & FL_CLIENT ) ) {
		return;
	}

	if ( spawnflags & SF_HURT_FIREONPLAYER ) {
		if ( other.flags & FL_CLIENT ) {
			if ( m_flDelay > 0 ) {
				CBaseTrigger::UseTargets_Delay( m_flDelay );
			} else {
				CBaseTrigger::UseTargets();
			}
		}
	} else {
		if ( m_flDelay > 0 ) {
			CBaseTrigger::UseTargets_Delay( m_flDelay );
		} else {
			CBaseTrigger::UseTargets();
		}
	}

	Damage_Apply( other, this, m_iDamage, other.origin, FALSE );
	//Damage_Apply( other, world, m_iDamage, DAMAGE_BLEED, WEAPON_NONE );
	
	// Shut it down if used once
	if ( spawnflags & SF_HURT_ONCE ) {
		solid = SOLID_NOT;
	}

	m_flNextTrigger = time + 0.5;
}

void trigger_hurt :: Respawn ( void )
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif

	if ( spawnflags & SF_HURT_OFF ) {
		solid = SOLID_NOT;
	}
	touch = Touch;
}

void trigger_hurt :: trigger_hurt ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "dmg":
			m_iDamage = stoi( argv( i + 1 ) );
			break;
		case "wait":
		case "delay":
			m_flDelay = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	CBaseTrigger::InitBrushTrigger();
	trigger_hurt::Respawn();
	CBaseEntity::CBaseEntity();
}
