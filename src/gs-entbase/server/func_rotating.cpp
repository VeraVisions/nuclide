/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/*QUAKED func_rotating (0 .5 .8) ? FR_STARTON FR_REVERSE FR_ZAXIS FR_XAXIS FR_ACCDCC FR_FANPAIN FR_NOTSOLID FR_SMALLRADIUS FR_MRADIUS FR_LRADIUS FR_TOGGLEDIR
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"speed"         Speed in units per second.
"dmg"           Damage applied to entity blocking its rotational path.

Rotating brush object. Useful for fans, etc.
*/

#ifdef GS_DEVELOPER
var int autocvar_dev_rotspeed = 0;
#endif

enumflags
{
	FR_STARTON, // 1
	FR_REVERSE, // 2
	FR_ZAXIS, // 4
	FR_XAXIS, // 8
	FR_ACCDCC, // 16
	FR_FANPAIN, // 32
	FR_NOTSOLID, // 64
	FR_SMALLRADIUS, // 128
	FR_MRADIUS, // 256
	FR_LRADIUS, // 512
	FR_TOGGLEDIR // 1024
};

class func_rotating : CBaseTrigger
{
	vector m_vecMoveDir;
	float m_flSpeed;
	float m_flDamage;
	float m_flDir;

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
		float flSpeed;

		if (spawnflags & FR_TOGGLEDIR && m_flDir) {
			flSpeed = m_flSpeed * -1;
		} else {
			flSpeed = m_flSpeed;
		}

		avelocity = m_vecMoveDir * flSpeed;
		m_flDir = 1 - m_flDir;
	}
}

void func_rotating :: Blocked ( void )
{
	if (avelocity == [0,0,0]) {
		return;
	}

	if (other.takedamage == DAMAGE_YES) {
		Damage_Apply(other, this, m_flDamage, 0, DMG_CRUSH);
	}
}

void func_rotating :: Respawn ( void )
{
#ifdef GS_DEVELOPER
	if (autocvar_dev_rotspeed != 0) {
		m_flSpeed = autocvar_dev_rotspeed;
	}
#endif

	m_flDir = 0; /* Reset */

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
}
