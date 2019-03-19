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

class func_rotating : CBaseTrigger
{
	vector m_vecMoveDir;
	float m_flSpeed;
	float m_flDamage;
	void() func_rotating;
	virtual void() Respawn;
	virtual void() Trigger;
	virtual void() Rotate;
	virtual void() Blocked;
	virtual void() SetMovementDirection;
};

void func_rotating :: Rotate( void )
{
	nextthink = ltime + 10.0f;
}
void func_rotating :: Trigger ( void )
{
	if ( vlen( avelocity ) ) {
		avelocity = [0,0,0];
	} else {
		avelocity = m_vecMoveDir * m_flSpeed;
	}
}

void func_rotating :: Blocked ( void )
{
	if (avelocity == [0,0,0]) {
		return;
	}

	if (other.takedamage == DAMAGE_YES) {
		Damage_Apply(other, this, m_flDamage, other.origin, TRUE);
	}
}

void func_rotating :: Respawn ( void )
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
	
	blocked = Blocked;
	
	if (spawnflags & FR_FANPAIN) {
		touch = Blocked;
	}
}

void func_rotating :: SetMovementDirection ( void )
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

void func_rotating :: func_rotating ( void )
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
		case "dmg":
			m_flDamage = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}

	if ( !m_flSpeed ) {
		m_flSpeed = 100;
	}

	CBaseTrigger::CBaseTrigger();
	func_rotating::SetMovementDirection();
	func_rotating::Respawn();
}
