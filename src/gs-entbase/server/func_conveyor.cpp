/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED func_conveyor (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

STUB!
*/

#define SF_CONVEYOR_VISUAL		1
#define SF_CONVEYOR_NOTSOLID	2

class func_conveyor : func_wall
{
	float m_flSpeed;
	vector m_vecMoveDir;
	void() func_conveyor;
	virtual void() Trigger;
	virtual void() touch;
	virtual void() SetMovementDirection;
	virtual void( float ) UpdateSpeed;
};

void func_conveyor :: SetMovementDirection ( void )
{
	if ( angles == [0,-1,0] ) {
		m_vecMoveDir = [0,0,1];
	} else if ( angles == [0,-2,0] ) {
		m_vecMoveDir = [0,0,-1];
	} else {
		makevectors( angles );
		m_vecMoveDir = v_forward;
	}

	angles = [0,0,0];
}


// HACKHACK -- This is ugly, but encode the speed in the rendercolor to avoid adding more data to the network stream
void func_conveyor :: UpdateSpeed( float flSpeed )
{
	// Encode it as an integer with 4 fractional bits
	/*int speedCode = (int)( fabs( flSpeed ) * 16.0f );

	if ( flSpeed < 0 ) {
		pev->rendercolor.x = 1;
	} else {
		pev->rendercolor.x = 0;
	}

	pev->rendercolor.y = (speedCode >> 8);
	pev->rendercolor.z = (speedCode & 0xFF);*/
}

void func_conveyor :: touch ( void )
{
	//other.basevelocity = m_vecMoveDir * m_flSpeed;
}


void func_conveyor :: Trigger ( void )
{
    m_flSpeed = -m_flSpeed;
	UpdateSpeed( m_flSpeed );
}

void func_conveyor :: func_conveyor ( void )
{
	SetMovementDirection();
	func_wall::func_wall();

	if ( !( spawnflags & SF_CONVEYOR_VISUAL ) ) {
		//SetBits( pev->flags, FL_CONVEYOR );
	}

	// HACKHACK - This is to allow for some special effects
	if ( spawnflags & SF_CONVEYOR_NOTSOLID ) {
		solid = SOLID_NOT;
		skin = 0;
	}

	if ( m_flSpeed == 0 ) {
		m_flSpeed = 100;
	}

	UpdateSpeed( m_flSpeed );
}
