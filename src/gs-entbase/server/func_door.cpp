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

/*QUAKED func_door (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

STUB!
*/

// TODO: Finish these
#define SF_MOV_OPEN			1
#define SF_MOV_UNLINK 		4
#define SF_MOV_PASSABLE		8
#define SF_MOV_TOGGLE		32
#define SF_MOV_USE			256

enum
{
	DOORSTATE_RAISED,
	DOORSTATE_LOWERED,
	DOORSTATE_UP,
	DOORSTATE_DOWN
};

class func_door:CBaseTrigger
{
	vector m_vecPos1;
	vector m_vecPos2;
	vector m_vecDest;
	vector m_vecMoveDir;
	string m_strFire;
	float m_flSpeed;
	float m_flLip;
	float m_iState;
	float m_flNextTrigger;
	float m_flWait;
	float m_flDelay;
	int m_iDamage;
	int m_iLocked;

	string m_strSndMove;
	string m_strSndStop;

	void(void) func_door;
	virtual void(void) SetMovementDirection;
	virtual void(vector vdest, void(void) func) MoveToDestination;
	virtual void(void) MoveToDestination_End;
	virtual void(void) MoveAway;
	virtual void(void) MoveBack;
	virtual void(void) Arrived;
	virtual void(void) Returned;
	virtual void(void) Respawn;
	virtual void(void) Trigger;
	virtual void(void) Blocked;
	virtual void(void) Touch;
	virtual void(void) Use;
	virtual void(void) m_pMove = 0;
};

const string g_hldoormove_sfx[10] = {
	"doors/doormove1.wav",
	"doors/doormove2.wav",
	"doors/doormove3.wav",
	"doors/doormove4.wav",
	"doors/doormove5.wav",
	"doors/doormove6.wav",
	"doors/doormove7.wav",
	"doors/doormove8.wav",
	"doors/doormove9.wav",
	"doors/doormove10.wav"
};

const string g_hldoorstop_sfx[8] = {
	"doors/doorstop1.wav",
	"doors/doorstop2.wav",
	"doors/doorstop3.wav",
	"doors/doorstop4.wav",
	"doors/doorstop5.wav",
	"doors/doorstop6.wav",
	"doors/doorstop7.wav",
	"doors/doorstop8.wav"
};

void func_door::Use(void)
{
	eActivator.gflags &= ~GF_USE_RELEASED;
	Trigger();
}

void func_door::Arrived(void)
{
	m_iState = DOORSTATE_RAISED;

	if (m_strSndStop) {
		sound(this, CHAN_VOICE, m_strSndStop, 1.0, ATTN_NORM);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
	}

	if (!(spawnflags & SF_MOV_USE)) {
		touch = Touch;
	}
	if (m_flWait < 0) {
		return;
	}

	if (!(spawnflags & SF_MOV_TOGGLE)) {
		think = MoveBack;
		nextthink = (ltime + m_flWait);
	}
}

void func_door::Returned(void)
{
	if (m_strSndStop) {
		sound(this, CHAN_VOICE, m_strSndStop, 1.0, ATTN_NORM);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
	}

	if (!(spawnflags & SF_MOV_USE)) {
		touch = Touch;
	}

	if (m_strFire) {
		CBaseTrigger t;
		t = (CBaseTrigger)find(world, CBaseTrigger::m_strTargetName, m_strFire);
		
		if (t) {
			t.Trigger();
		}
	}

	m_iState = DOORSTATE_LOWERED;
}

void func_door::MoveBack(void)
{
	if (m_strSndMove) {
		sound(this, CHAN_VOICE, m_strSndMove, 1.0, ATTN_NORM);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
	}

	if (!(spawnflags & SF_MOV_USE)) {
		touch = __NULL__;
	}

	m_iState = DOORSTATE_DOWN;
	MoveToDestination(m_vecPos1, Returned);
}

void func_door::MoveAway(void)
{
	if (m_iState == DOORSTATE_UP) {
		return;
	}

	if (m_strSndMove) {
		sound(this, CHAN_VOICE, m_strSndMove, 1.0, ATTN_NORM);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
	}

	if (!(spawnflags & SF_MOV_TOGGLE)) {
		if (m_iState == DOORSTATE_RAISED) {
			nextthink = (ltime + m_flWait);
			return;
		}
	}

	m_iState = DOORSTATE_UP;
	MoveToDestination(m_vecPos2, Arrived);
}

void func_door::Trigger(void)
{
	if (m_flNextTrigger > time) {
		if (!(spawnflags & SF_MOV_TOGGLE)) {
			return;
		}
	}
	m_flNextTrigger = time + m_flWait;

	// Only trigger stuff when we are done moving
	if ((m_iState == DOORSTATE_RAISED) || (m_iState == DOORSTATE_LOWERED)) {
		if (m_flDelay > 0) {
			CBaseTrigger::UseTargets_Delay(m_flDelay);
		} else {
			CBaseTrigger::UseTargets();
		}
	}

	if ((m_iState == DOORSTATE_UP) || (m_iState == DOORSTATE_RAISED)){
		MoveBack();
		return;
	}

	MoveAway();
}

void func_door::Touch(void)
{
	if (spawnflags & SF_MOV_TOGGLE) {
		return;
	}

	if (m_iLocked) {
		return;
	}

	if (other.movetype == MOVETYPE_WALK) {
		if (other.absmin[2] <= maxs[2] - 2) {
			eActivator = other;
			Trigger();
		}
	}
}

void func_door::Blocked(void)
{
	if (m_iDamage) {
		Damage_Apply(other, this, m_iDamage, 0, DMG_CRUSH);
	}

	if (m_flWait >= 0) {
		if (m_iState == DOORSTATE_DOWN) {
			MoveAway ();
		} else {
			MoveBack ();
		}
	}
}

void func_door::SetMovementDirection(void)
{
	if (angles == [0,-1,0]) {
		m_vecMoveDir = [0,0,1];
	} else if (angles == [0,-2,0]) {
		m_vecMoveDir = [0,0,-1];
	} else {
		makevectors(angles);
		m_vecMoveDir = v_forward;
	}
}

void func_door::MoveToDestination_End(void)
{
	SetOrigin(m_vecDest);
	velocity = [0,0,0];
	nextthink = -1;
	m_pMove();
}

void func_door::MoveToDestination(vector vecDest, void(void) func)
{
	vector vecDifference;
	float flTravel;
	float fTravelTime;

	if (!m_flSpeed) {
		objerror("func_door: No speed defined!");
		return;
	}

	m_pMove = func;
	m_vecDest = vecDest;
	think = MoveToDestination_End;

	if (vecDest == origin) {
		velocity = [0,0,0];
		nextthink = (ltime + 0.1f);
		return;
	}

	vecDifference = (vecDest - origin);
	flTravel = vlen(vecDifference);
	fTravelTime = (flTravel / m_flSpeed);

	if (fTravelTime < 0.1) {
		velocity = [0,0,0];
		nextthink = ltime + 0.1f;
		return;
	}

	nextthink = (ltime + fTravelTime);
	velocity = (vecDifference * (1 / fTravelTime));
}

void func_door::Respawn(void)
{
	/* reset */
	m_vecPos1 = [0,0,0];
	m_vecPos2 = [0,0,0];
	m_vecDest = [0,0,0];
	m_vecMoveDir = [0,0,0];

	/* angles to vecMoveDir */
	angles = m_oldAngle;
	SetMovementDirection();
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	blocked = Blocked;
	think = __NULL__;
	nextthink = 0;
	m_pMove = 0;

	if (m_flWait == -1) {
		spawnflags |= SF_MOV_TOGGLE;
	}

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}

	if (!m_iDamage) {
		m_iDamage = 2;
	}

	if (spawnflags & SF_MOV_USE) {
		touch = __NULL__;
		PlayerUse = Use;
	} else {
		touch = Touch;
		PlayerUse = __NULL__;
	}

	m_iState = DOORSTATE_LOWERED;
	m_vecPos1 = m_oldOrigin;
	m_vecPos2 = (m_vecPos1 + m_vecMoveDir * (fabs(m_vecMoveDir * size) - m_flLip));

	if (spawnflags & SF_MOV_OPEN) {
		SetOrigin(m_vecPos2);
		m_vecPos2 = m_vecPos1;
		m_vecPos1 = origin;
	}

	if (m_strTargetName) {
		m_iLocked = TRUE;
	}

	SetAngles([0,0,0]);
}

void func_door::func_door(void)
{
	int x;

	CBaseTrigger::CBaseTrigger();

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "speed":
			m_flSpeed = stof(argv(i+1));
			break;
		case "lip":
			m_flLip = stof(argv(i+1));
			break;
		case "delay":
			m_flDelay = stof(argv(i+1));
			break;
		case "wait":
			m_flWait = stof(argv(i+1));
			break;
		case "netname":
			m_strFire = argv(i+1);
			netname = __NULL__;
			break;
		case "dmg":
			m_iDamage = stoi(argv(i+1));
			break;
		case "noise1":
			m_strSndMove = argv(i+1);
			break;
		case "noise2":
			m_strSndStop = argv(i+1);
			break;
		/* GoldSrc compat */
		case "movesnd":
			x = stoi(argv(i+1));
			if (x > 0 && x <= g_hldoormove_sfx.length) {
				m_strSndMove = g_hldoormove_sfx[x-1];
			}
			break;
		case "stopsnd":
			x = stoi(argv(i+1));
			if (x > 0 && x <= g_hldoorstop_sfx.length) {
				m_strSndStop = g_hldoorstop_sfx[x-1];
			}
			break;
		default:
			break;
		}
	}

	if (m_strSndMove)
		precache_sound(m_strSndMove);
	if (m_strSndStop)
		precache_sound(m_strSndStop);
}

void func_water(void)
{
	spawnfunc_func_door();
	self.classname = "func_water";
	self.solid = SOLID_BSP;
	self.skin = CONTENT_WATER;
	self.effects |= EF_FULLBRIGHT;
	self.spawnflags |= SF_MOV_TOGGLE;
	setorigin(self, self.origin); // relink. have to do this.
}
