/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

#define SF_BTT_NOMOVE		1
#define SF_BTT_TOGGLE		32
#define SF_BTT_SPARKS		64
#define SF_BTT_TOUCH_ONLY	256

enum
{
	STATE_RAISED,
	STATE_LOWERED,
	STATE_UP,
	STATE_DOWN
};

enum
{
	FRAME_OFF,
	FRAME_ON
};

class func_button : CBaseTrigger
{
	float m_flSpeed;
	float m_flLip;
	int m_iDamage;
	int m_iState;
	vector m_vecPos1;
	vector m_vecPos2;
	int m_iSounds;
	float m_flNextTrigger;
	vector m_vecDest;
	string m_strNoise;
	float m_flWait;
	float m_flDelay;
	virtual void() m_pMove = 0;
	
	virtual void() Precache;
	virtual void() Arrived;
	virtual void() Returned;
	virtual void() MoveBack;
	virtual void() MoveAway;
	virtual void() Touch;
	virtual void() Blocked;
	virtual void() Trigger;
	virtual void() PlayerUse;
	
	virtual void() SetMovementDirection;
	virtual void(vector vdest, void() func) MoveToDestination;
	virtual void() MoveToDestination_End;
};

void func_button :: Precache( void )
{
	precache_model( model );
	switch( m_iSounds ) {
		case 0: 
			m_strNoise = "common/null.wav";
			break;
		case 1:
			m_strNoise = "buttons/button1.wav";
			break;
		case 2:
			m_strNoise = "buttons/button2.wav";
			break;
		case 3:
			m_strNoise = "buttons/button3.wav";
			break;
		case 4:
			m_strNoise = "buttons/button4.wav";
			break;
		case 5:
			m_strNoise = "buttons/button5.wav";
			break;
		case 6:
			m_strNoise = "buttons/button6.wav";
			break;
		case 7:
			m_strNoise = "buttons/button7.wav";
			break;
		case 8:
			m_strNoise = "buttons/button8.wav";
			break;
		case 9:
			m_strNoise = "buttons/button9.wav";
			break;
		case 10:
			m_strNoise = "buttons/button10.wav";
			break;
		case 11:
			m_strNoise = "buttons/button11.wav";
			break;
		case 12:
			m_strNoise = "buttons/latchlocked1.wav";
			break;
		case 13:
			m_strNoise = "buttons/latchunlocked1.wav";
			break;
		case 14:
			m_strNoise = "buttons/lightswitch2.wav";
			break;
		case 21:
			m_strNoise = "buttons/lever1.wav";
			break;
		case 22:
			m_strNoise = "buttons/lever2.wav";	
			break;
		case 23:
			m_strNoise = "buttons/lever3.wav";
			break;
		case 24:
			m_strNoise = "buttons/lever4.wav";
			break;
		case 25:
			m_strNoise = "buttons/lever5.wav";
			break;
		default:
			m_strNoise = "buttons/button9.wav";
	}
	
	precache_sound( m_strNoise );
}

void func_button :: Arrived( void )
{
	m_iState = STATE_RAISED;
	
	if ( !( spawnflags & SF_BTT_TOUCH_ONLY ) ) {
		touch = Touch;
	}
	if ( spawnflags & SF_BTT_TOGGLE ) {
		return;
	}
	
	if ( m_flWait != -1 ) {
		think = MoveBack;
		nextthink = ( ltime + m_flWait );
	}
}

void func_button :: Returned( void )
{
	if ( !( spawnflags & SF_BTT_TOUCH_ONLY ) ) {
		touch = Touch;
	}
    
	m_iState = STATE_LOWERED;
	frame = FRAME_OFF;
}

void func_button :: MoveBack( void )
{
	if ( !( spawnflags & SF_BTT_TOUCH_ONLY ) ) {
		touch = __NULL__;
	}
    
	m_iState = STATE_DOWN;
	
	if ( m_vecPos2 != m_vecPos1 ) {
		func_button::MoveToDestination ( m_vecPos1, Returned );
	} else {
		func_button::Returned();
	}
}

void func_button :: MoveAway( void )
{
	if ( m_iState == STATE_UP ) {
		return;
	}

	if ( m_iState == STATE_RAISED ) {
		nextthink = ( ltime + m_flWait );
		return;
	}
	
	m_iState = STATE_UP;
	
	if ( m_vecPos2 != m_vecPos1 ) {
		func_button::MoveToDestination( m_vecPos2, Arrived );
	} else {
		func_button::Arrived();
	}
	
	frame = FRAME_ON;
}

void func_button :: Trigger( void )
{
	if ( m_flNextTrigger > time ) {
		return;
	}

	m_flNextTrigger = time + m_flWait;
	
	if ( ( m_iState == STATE_UP ) || ( m_iState == STATE_RAISED ) ){
		if ( m_flWait != -1 ) {
			func_button::MoveBack();
		}
		return;
	}

	sound( this, CHAN_VOICE, m_strNoise, 1.0, ATTN_NORM );
	func_button::MoveAway();
	
	if ( m_flDelay ) {
#ifdef GS_DEVELOPER
		dprint( sprintf( "func_button: Delayed trigger of `%s`\n", m_strTarget ) );
#endif
		CBaseTrigger::UseTargets_Delay( m_flDelay );
	} else {
#ifdef GS_DEVELOPER
		print( sprintf( "func_button: Normal trigger of `%s`\n", m_strTarget ) );
#endif
		CBaseTrigger::UseTargets();
	}
}

void func_button :: Touch( void )
{
	if ( other.movetype == MOVETYPE_WALK ) {
		func_button::Trigger();
    
		if ( !( spawnflags & SF_BTT_TOUCH_ONLY ) ) {
			touch = __NULL__;
		}
	}
}

void func_button :: PlayerUse ( void )
{
	Trigger();
}

void func_button :: Blocked( void )
{
	if ( m_iDamage ) {
		//Damage_Apply( other, this, dmg, other.origin, FALSE );
	}
	
	if ( m_flWait >= 0 ) {
		if ( m_iState == STATE_DOWN ) {
			func_button::MoveAway ();
		} else {
			func_button::MoveBack ();
		}
	}
}

void func_button :: SetMovementDirection( void )
{
	if ( angles == '0 -1 0' ) {
		movedir = '0 0 1';
	} else if ( angles == '0 -2 0' ) {
		movedir = '0 0 -1';
	} else {
		makevectors( angles );
		movedir = v_forward;
	}
	
	angles = '0 0 0';
}

void func_button :: MoveToDestination_End( void )
{
	setorigin( this, m_vecDest );
	velocity = '0 0 0';
	nextthink = -1;
	m_pMove();
}

void func_button :: MoveToDestination( vector vDestination, void() func )
{
	vector vecDifference;
	float flTravel, fTravelTime;

	if ( !m_flSpeed ) {
		objerror( "No speed defined for moving entity! Will not divide by zero." );
	}

	m_pMove = func;
	m_vecDest = vDestination;
	think = MoveToDestination_End;

	if ( vDestination == origin ) {
		velocity = '0 0 0';
		nextthink = ( ltime + 0.1 );
		return;
	}

	vecDifference = ( vDestination - origin );
	flTravel = vlen( vecDifference );
	fTravelTime = ( flTravel / m_flSpeed );

	if ( fTravelTime < 0.1 ) {
		velocity = '0 0 0';
		nextthink = ltime + 0.1;
		return;
	}
	
	nextthink = ( ltime + fTravelTime );
	velocity = ( vecDifference * ( 1 / fTravelTime ) );
}

void func_button :: func_button( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "speed":
			m_flSpeed = stof( argv( i + 1 ) );
			break;
		case "lip":
			m_flLip = stof( argv( i + 1 ) );
			break;
		case "sounds":
			m_iSounds = stoi( argv( i + 1 ) );
			break;
		case "wait":
			m_flWait = stof( argv( i + 1 ) );
			break;
		case "delay":
			m_flDelay = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}

	func_button::Precache();
	func_button::SetMovementDirection();
	CBaseTrigger::CBaseTrigger();

	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	setorigin( this, origin );
	setmodel( this, model );
	blocked = Blocked;

	if ( !m_flSpeed ) {
		m_flSpeed = 100;
	}

	if ( spawnflags & SF_BTT_TOUCH_ONLY ) {
		touch = Touch;
		gflags -= gflags & GF_USABLE;
	} else {
		touch = __NULL__;
		gflags |= GF_USABLE;
	}

	m_vecPos1 = origin;

	if ( spawnflags & SF_BTT_NOMOVE ) {
		m_vecPos2 = m_vecPos1;
	} else {
		m_vecPos2 = ( m_vecPos1 + movedir * ( fabs( movedir * size ) - m_flLip ) );
	}

	m_iState = STATE_LOWERED;
}
