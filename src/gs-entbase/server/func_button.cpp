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

/*QUAKED func_button (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

STUB!
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
	virtual void(void) Trigger;
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

	SetFrame(FRAME_ON);
}

void func_button::Trigger(void)
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
		UseTargets_Delay(m_flDelay);
	} else {
		UseTargets();
	}
}

void func_button::Touch(void)
{
	if (other.movetype == MOVETYPE_WALK) {
		eActivator = other;
		Trigger();
    
		if (!(spawnflags & SF_BTT_TOUCH_ONLY)) {
			touch = __NULL__;
		}
	}
}

void func_button::Use(void)
{
	Trigger();
}

void func_button::Pain (int body)
{
	Trigger();
}

void func_button::Death (int body)
{
	Trigger();
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
