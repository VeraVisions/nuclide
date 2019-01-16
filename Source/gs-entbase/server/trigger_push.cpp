/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define TP_ONCE		1
#define TP_STARTOFF	2
#define TP_AAAA		4

class trigger_push : CBaseTrigger
{
	vector m_vecMoveDir;
	float m_flDelay;
	float m_flSpeed;
	void() trigger_push;
	virtual void() touch;
	virtual void() Respawn;
	virtual void() Trigger;
	virtual void() SetMovementDirection;
};

void trigger_push :: SetMovementDirection ( void )
{
	if ( angles == '0 -1 0' ) {
		m_vecMoveDir = '0 0 1';
	} else if ( angles == '0 -2 0' ) {
		m_vecMoveDir = '0 0 -1';
	} else {
		makevectors( angles );
		m_vecMoveDir = v_forward;
	}

	angles = '0 0 0';
	//m_vecMoveDir *= 1;
}

void trigger_push :: Trigger ( void )
{
	if ( solid == SOLID_NOT ) {
		solid = SOLID_TRIGGER;
	} else {
		solid = SOLID_NOT;
	}
}

void trigger_push :: touch ( void )
{
	switch( other.movetype )
	{
	case MOVETYPE_NONE:
	case MOVETYPE_PUSH:
	case MOVETYPE_NOCLIP:
	case MOVETYPE_FOLLOW:
		return;
	}

	if ( other.solid != SOLID_NOT && other.solid != SOLID_BSP ) {
		if ( spawnflags & TP_ONCE ) {
			other.velocity = other.velocity + (m_flSpeed * m_vecMoveDir);
			if ( other.velocity[2] > 0 )
				other.flags &= ~FL_ONGROUND;
			remove( self );
		} else {
			/*vector vecPush = m_flSpeed * m_vecMoveDir;
			if ( other.flags & FL_BASEVELOCITY ) {
				vecPush = vecPush + other.basevelocity;
			}

			other.basevelocity = vecPush;
			other.flags |= FL_BASEVELOCITY;*/
		}
	}
}

void trigger_push :: Respawn ( void )
{
	if ( angles == '0 0 0' ) {
		angles[1] = 360;
	}
	SetMovementDirection();

	if ( m_flSpeed == 0 ) {
		m_flSpeed = 100;
	}

	if ( spawnflags & TP_STARTOFF ) {
		solid = SOLID_NOT;
	}
}
	
void trigger_push :: trigger_push ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "speed":
			m_flSpeed = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	
	CBaseTrigger::CBaseTrigger();
	CBaseTrigger::InitBrushTrigger();
	trigger_push::Respawn();
}
