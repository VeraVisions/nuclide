/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	FR_STARTON,
	FR_REVERSE,
	FR_ZAXIS,
	FR_XAXIS,
	FR_ACCDCC,
	FR_FANPAIN,
	FR_NOTSOLID,
	FR_SMALLRADIUS,
	FR_MRADIUS,
	FR_LRADIUS
};

class CFuncRotating : CBaseTrigger
{
	vector m_vecMoveDir;
	float m_flSpeed;
	void() CFuncRotating;
	virtual void() Respawn;
	virtual void() Trigger;
	virtual void() Rotate;
	virtual void() SetMovementDirection;
};

void CFuncRotating :: Rotate( void )
{
	nextthink = ltime + 10.0f;
}
void CFuncRotating :: Trigger ( void )
{
	if ( vlen( avelocity ) ) {
		avelocity = [0,0,0];
	} else {
		avelocity = m_vecMoveDir * m_flSpeed;
	}
}

void CFuncRotating :: Blocked ( void )
{
	if ( spawnflags & FR_FANPAIN ) {
//		Damage_Apply( other, this, m_iDamage, other.origin, FALSE );
	}
}

void CFuncRotating :: Respawn ( void )
{
	movetype = MOVETYPE_PUSH;
	setorigin( this, origin );
	setmodel( this, model );

	if ( spawnflags & FR_NOTSOLID ) {
		solid = SOLID_NOT;
	} else {
		solid = SOLID_BSP;
	}

	if ( spawnflags & FR_STARTON ) {
		avelocity = m_vecMoveDir * m_flSpeed;
		think = Rotate;
		nextthink = ltime + 1.5f;
	}
}

void CFuncRotating :: SetMovementDirection ( void )
{
	if ( spawnflags & FR_ZAXIS ) {
		m_vecMoveDir = '0 0 1';
	} else if ( spawnflags & FR_XAXIS ) {
		m_vecMoveDir = '1 0 0';
	} else {
		m_vecMoveDir = '0 1 0';
	}

	if ( spawnflags & FR_REVERSE ) {
		m_vecMoveDir *= -1;
	}
}

void CFuncRotating :: CFuncRotating ( void )
{
	precache_model( model );
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		/*case "spawnorigin":
			setorigin( this, stov( argv( i + 1 ) ) );
			break;*/
		case "speed":
			m_flSpeed = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	
	if ( !m_flSpeed ) {
		m_flSpeed = 100;
	}

	CBaseTrigger::CBaseTrigger();
	CFuncRotating::SetMovementDirection();
	CFuncRotating::Respawn();
}

CLASSEXPORT( func_rotating, CFuncRotating )
