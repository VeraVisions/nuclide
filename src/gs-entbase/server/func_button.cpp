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

/*QUAKED func_button (0 .5 .8) ? SF_BTT_NOMOVE x x x x SF_BTT_TOGGLE SF_BTT_SPARKS x SF_BTT_TOUCH_ONLY
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"speed"         Movement speed of the door in game-units per second.
"lip"           How many units remain visible when fully pushed in.
"snd_pressed"   The sound shader name to play when pressed.
"snd_unpressed" The sound shader name to play when the button becomes unpressed.
"wait"          Time to wait in seconds before the button becomes unpressed.
"delay"         Delay until the Target gets triggered.
"sounds"        Obsolete legacy key for HL/Q1 style buttons to decide
                which sounds to play.

A brush entity which can be used either by touching, interaction (via a games'
use-key/button or other targetting methods.
It will then travel, similar to a door to a specified direction.
Once it's fully pushed in, it'll trigger its targets, then return back to its
original position.

When SF_BTT_NOMOVE is set, the only visual indicator you'll get is a possible
change of texture of your button. The button will not move.

When SF_BTT_TOGGLE is set, the button will never return to its original position
or state automatically. The 'wait' key will be ignored and a something will have
to manually untoggle it again.

When SF_BTT_SPARKS is set, the button will create a bunch of sparks when used.

When SF_BTT_TOUCH_ONLY is set, the use key/button cannot be used to interact
with the button, it has to collide against a player.
*/

/* compatibility */
string g_q1button_src[4] = {
	"buttons/airbut1.wav",
	"buttons/switch21.wav",
	"buttons/switch02.wav",
	"buttons/switch04.wav"
};
string g_hlbutton_sfx[21] = {
	"common/null.wav",
	"buttons/button1.wav",
	"buttons/button2.wav",
	"buttons/button3.wav",
	"buttons/button4.wav",
	"buttons/button5.wav",
	"buttons/button6.wav",
	"buttons/button7.wav",
	"buttons/button8.wav",
	"buttons/button9.wav",
	"buttons/button10.wav",
	"buttons/button11.wav",
	"buttons/latchlocked1.wav",
	"buttons/latchunlocked1.wav",
	"buttons/lightswitch2.wav",
	"buttons/lever1.wav",
	"buttons/lever2.wav",
	"buttons/lever3.wav",
	"buttons/lever4.wav",
	"buttons/lever5.wav",
	"buttons/button9.wav"
};

enumflags
{
	SF_BTT_NOMOVE,
	SF_BTT_RESERVED1,
	SF_BTT_RESERVED2,
	SF_BTT_RESERVED3,
	SF_BTT_RESERVED4,
	SF_BTT_TOGGLE,
	SF_BTT_SPARKS,
	SF_BTT_RESERVED5,
	SF_BTT_TOUCH_ONLY
};

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

class func_button:CBaseTrigger
{
	float m_flSpeed;
	float m_flLip;
	int m_iDamage;
	int m_iState;
	vector m_vecPos1;
	vector m_vecPos2;

	float m_flNextTrigger;
	vector m_vecDest;
	float m_flWait;
	float m_flDelay;
	vector m_vecMoveDir;
	virtual void(void) m_pMove = 0;

	/* full-path versus sound-shaders */
	int m_iSoundCompat;
	string m_strSndPressed;
	string m_strSndUnpressed;
	
	virtual void(void) Precache;
	virtual void(void) Respawn;
	virtual void(void) Arrived;
	virtual void(void) Returned;
	virtual void(void) MoveBack;
	virtual void(void) MoveAway;
	virtual void(void) Touch;
	virtual void(void) Blocked;
	virtual void(int) Trigger;
	virtual void(void) Use;
	virtual void(int) Pain;
	virtual void(int) Death;
	
	virtual void(void) SetMovementDirection;
	virtual void(vector, void(void)) MoveToDestination;
	virtual void(void) MoveToDestination_End;
};

void func_button::Precache(void)
{
	if (m_strSndPressed) {
		if (m_iSoundCompat)
			precache_sound(m_strSndPressed);
		else
			Sound_Precache(m_strSndPressed);
	}

	if (m_strSndUnpressed) {
		if (m_iSoundCompat)
			precache_sound(m_strSndUnpressed);
		else
			Sound_Precache(m_strSndUnpressed);
	}
}

void func_button::Arrived(void)
{
	m_iState = STATE_RAISED;
	
	if (spawnflags & SF_BTT_TOUCH_ONLY) {
		touch = Touch;
	} else {
		touch = __NULL__;
	}

	if (spawnflags & SF_BTT_TOGGLE) {
		return;
	}
	
	if (m_flWait != -1) {
		think = MoveBack;
		nextthink = (ltime + m_flWait);
	}
}

void func_button::Returned(void)
{
	if (spawnflags & SF_BTT_TOUCH_ONLY) {
		touch = Touch;
	}
    
	m_iState = STATE_LOWERED;
	SetFrame(FRAME_OFF);
}

void func_button::MoveBack(void)
{
	touch = __NULL__;
	m_iState = STATE_DOWN;
	m_iValue = 0;

	if (m_strSndUnpressed) {
		if (m_iSoundCompat)
			sound(this, CHAN_VOICE, m_strSndUnpressed, 1.0, ATTN_NORM);
		else
			Sound_Play(this, CHAN_VOICE, m_strSndUnpressed);
	}

	if (m_vecPos2 != m_vecPos1) {
		MoveToDestination (m_vecPos1, Returned);
	} else {
		Returned();
	}
}

void func_button::MoveAway(void)
{
	if (m_iState == STATE_UP) {
		return;
	}
	touch = __NULL__;

	if (m_iState == STATE_RAISED) {
		nextthink = (ltime + m_flWait);
		return;
	}
	
	m_iState = STATE_UP;
	
	if (m_vecPos2 != m_vecPos1) {
		MoveToDestination(m_vecPos2, Arrived);
	} else {
		Arrived();
	}

	m_iValue = 1;
	SetFrame(FRAME_ON);
}

/* TODO: Handle state */
void func_button::Trigger(int state)
{
	if (m_flNextTrigger > time) {
		return;
	}

	m_flNextTrigger = time + m_flWait;
	
	if ((m_iState == STATE_UP) || (m_iState == STATE_RAISED)){
		if (m_flWait != -1) {
			MoveBack();
		}
		return;
	}

	if (m_strSndPressed) {
		if (m_iSoundCompat)
			sound(this, CHAN_VOICE, m_strSndPressed, 1.0, ATTN_NORM);
		else
			Sound_Play(this, CHAN_VOICE, m_strSndPressed);
	}

	MoveAway();

	if (m_flDelay) {
		UseTargets_Delay(TRIG_TOGGLE, m_flDelay);
	} else {
		UseTargets(TRIG_TOGGLE);
	}
}

void func_button::Touch(void)
{
	if (other.movetype == MOVETYPE_WALK) {
		eActivator = other;
		Trigger(TRIG_TOGGLE);
    
		if (!(spawnflags & SF_BTT_TOUCH_ONLY)) {
			touch = __NULL__;
		}
	}
}

void func_button::Use(void)
{
	Trigger(TRIG_TOGGLE);
}

void func_button::Pain (int body)
{
	Trigger(TRIG_TOGGLE);
}

void func_button::Death (int body)
{
	Trigger(TRIG_TOGGLE);
}

void func_button::Blocked(void)
{
	if (m_iDamage) {
		//Damage_Apply(other, this, dmg, other.origin, FALSE);
	}

	if (m_flWait >= 0) {
		if (m_iState == STATE_DOWN) {
			MoveAway();
		} else {
			MoveBack();
		}
	}
}

void func_button::SetMovementDirection(void)
{
	if (m_oldAngle == [0,-1,0]) {
		m_vecMoveDir = [0,0,1];
	} else if (m_oldAngle == [0,-2,0]) {
		m_vecMoveDir = [0,0,-1];
	} else {
		makevectors(m_oldAngle);
		m_vecMoveDir = v_forward;
	}
}

void func_button::MoveToDestination_End(void)
{
	SetOrigin(m_vecDest);
	velocity = [0,0,0];
	nextthink = -1;
	m_pMove();
}

void func_button::MoveToDestination(vector vecDest, void(void) func)
{
	vector vecDifference;
	float flTravel, fTravelTime;

	if (!m_flSpeed) {
		objerror("No speed defined for moving entity! Will not divide by zero.");
	}

	m_pMove = func;
	m_vecDest = vecDest;
	think = MoveToDestination_End;

	if (vecDest == origin) {
		velocity = [0,0,0];
		nextthink = (ltime + 0.1);
		return;
	}

	vecDifference = (vecDest - origin);
	flTravel = vlen(vecDifference);
	fTravelTime = (flTravel / m_flSpeed);

	if (fTravelTime < 0.1) {
		velocity = [0,0,0];
		nextthink = ltime + 0.1;
		return;
	}

	nextthink = (ltime + fTravelTime);
	velocity = (vecDifference * (1 / fTravelTime));
}

void func_button::Respawn(void)
{
	SetMovementDirection();

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetOrigin(m_oldOrigin);
	SetModel(m_oldModel);

	blocked = Blocked;
	velocity = [0,0,0];
	nextthink = -1;
	health = m_oldHealth;

	if (health > 0) {
		takedamage = DAMAGE_YES;
	}

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}

	if (spawnflags & SF_BTT_TOUCH_ONLY) {
		touch = Touch;
		PlayerUse = __NULL__;
	} else {
		touch = __NULL__;
		PlayerUse = Use;
	}

	m_vecPos1 = m_oldOrigin;

	if (spawnflags & SF_BTT_NOMOVE) {
		m_vecPos2 = m_vecPos1;
	} else {
		m_vecPos2 = (m_vecPos1 + m_vecMoveDir * (fabs(m_vecMoveDir * size) - m_flLip));
	}

	m_iState = STATE_LOWERED;
	SetAngles([0,0,0]);
}

void func_button::func_button(void)
{
	CBaseTrigger::CBaseTrigger();

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "speed":
			m_flSpeed = stof(argv(i+1));
			break;
		case "lip":
			m_flLip = stof(argv(i+1));
			break;
		case "snd_pressed":
			m_strSndPressed = argv(i+1);
			break;
		case "snd_unpressed":
			m_strSndUnpressed = argv(i+1);
			break;
		case "wait":
			m_flWait = stof(argv(i+1));
			break;
		case "delay":
			m_flDelay = stof(argv(i+1));
			break;
		/* compatibility */
		case "sounds":
			int sfx;
			sfx = stoi(argv(i+1));
			m_strSndPressed = g_hlbutton_sfx[sfx];
			m_iSoundCompat = TRUE;
			break;
		default:
			break;
		}
	}
	Precache();
}
