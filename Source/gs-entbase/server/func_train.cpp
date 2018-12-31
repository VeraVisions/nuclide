/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

/*class CPathCorner
{
	float m_flSpeed;
	float m_flWait;
	string m_strTarget;
	void() CPathCorner;
};

void CPathCorner :: CPathCorner ( void )
{
	m_flSpeed = 100;
	m_flWait = 1.0f;
}

CLASSEXPORT(path_corner, CPathCorner)

class CFuncTrain
{
	int m_iDamage;
	float m_flNextBlockAttack;
	float m_flTraveltime;
	float m_flWait;
	float m_flSpeed;
	vector m_vecDestination;
	vector m_vecDestDelta;

	// We don't need to inherit CBaseTrigger for these yet
	string m_strTarget;
	entity m_eTarget;

	void() CFuncTrain;
	virtual void() Move;
	virtual void() Blocked;
	virtual void() Trigger;
	virtual void() Find;
	virtual void() Trigger;
	virtual void() Wait;
	virtual void() Next;
	virtual void() m_pMove = 0;
};

void CFuncTrain :: Done ( void )
{
	setorigin( this, m_vecDestination );
	velocity = '0 0 0';
	nextthink = -1;

	if ( m_pMove ) {
		m_pMove();
	}
}

void CFuncTrain :: Blocked ( void )
{
	if ( time < m_flNextBlockAttack ) {
		return;
	}
	m_flNextBlockAttack = time + 0.5;
	//other.deathtype = "squish";
	//T_Damage (other, self, self, m_iDamage);
}

void CFuncTrain :: Trigger ( void )
{
	// already activated
	if ( think != Find ) {
		return;
	}
	Next();
}

void CFuncTrain :: Wait ( void )
{
	if ( m_flWait ) {
		nextthink = ltime + m_flWait;
		sound (self, CHAN_VOICE, noise, 1, ATTN_NORM);
	} else {
		nextthink = ltime + 0.1f;
	}
	
	think = Next;
}

void CFuncTrain :: Next ( void )
{
	float flLen;
	CPathCorner pTarget;

	m_eTarget = find( world, ::targetname, m_strTarget );
	pTarget = (CPathCorner) m_eTarget;
	m_strTarget = pTarget.m_strTarget;

	if ( !m_strTarget ) {
		objerror( "train_next: no next target" );
	}

	if ( pTarget.m_flWait ) {
		m_flWait = pTarget.m_flWait;
	} else {
		m_flWait = 0;
	}
	
	sound( self, CHAN_VOICE, noise1, 1, ATTN_NORM );
	
	m_vecDestination = pTarget.origin - mins;
	m_flSpeed = pTarget.m_flSpeed;
	m_pMove = Wait;
	think = Done;

	if ( m_vecDestination == origin ) {
		velocity = '0 0 0';
		nextthink = ltime + 0.1;
		return;
	}

	// set destdelta to the vector needed to move
	m_vecDestDelta = m_vecDestination - origin;
	flLen = vlen( m_vecDestDelta ); // calculate length of vector
	m_flTraveltime = flLen / m_flSpeed; // divide by speed to get time to reach dest

	if ( m_flTraveltime < 0.1 ) {
		velocity = '0 0 0';
		nextthink = ltime + 0.1;
		return;
	}

	nextthink = ltime + m_flTraveltime; // set nextthink to trigger a think when dest is reached
	velocity = m_vecDestDelta * ( 1 / m_flTraveltime ); // scale the destdelta vector by the time spent traveling to get velocity
}

void CFuncTrain :: Find ( void )
{
	CPathCorner pTarget;
	m_eTarget = find(world, ::targetname, m_strTarget);
	pTarget = (CPathCorner) m_eTarget;
	m_strTarget = pTarget.m_strTarget;
	setorigin (this, m_eTarget.origin - mins);

	// not triggered, so start immediately
	if ( !targetname ) {
		nextthink = ltime + 0.1;
		think = Next;
	}
}

void CFuncTrain :: CFuncTrain ( void )
{
	if ( !m_flSpeed ) {
		m_flSpeed = 100;
	}
	if ( !m_strTarget ) {
		objerror ("func_train without a target");
	}
	if ( !m_iDamage ) {
		m_iDamage = 2;
	}

	if ( sounds == 0 ) {
		noise = ("misc/null.wav");
		precache_sound ("misc/null.wav");
		noise1 = ("misc/null.wav");
		precache_sound ("misc/null.wav");
	}

	if ( sounds == 1 ) {
		noise = ("plats/train2.wav");
		precache_sound ("plats/train2.wav");
		noise1 = ("plats/train1.wav");
		precache_sound ("plats/train1.wav");
	}

	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	blocked = Blocked;

	setmodel( this, model );
	setsize( this, mins , maxs );
	setorigin( this, origin );

	// start trains on the second frame, to make sure their targets have had
	// a chance to spawn
	nextthink = ltime + 0.1;
	think = Find;
}

CLASSEXPORT(func_train, CFuncTrain)*/
