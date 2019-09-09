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

/*QUAKED func_door_rotating (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

STUB!
*/

enumflags
{
	SF_ROT_OPEN,
	SF_ROT_BACKWARDS,
	SF_ROT_UNUSED1,
	SF_ROT_PASSABLE,
	SF_ROT_ONEWAY,
	SF_ROT_TOGGLE,
	SF_ROT_ZAXIS,
	SF_ROT_XAXIS,
	SF_ROT_USE,
	SF_ROT_NOMONSTERS
};

#define SF_DOOR_SILENT 0x80000000i

class func_door_rotating:CBaseTrigger
{
	int m_iMoveSnd;
	int m_iStopSnd;
	int m_iDamage;
	int m_iLocked;
	float m_flDistance;
	float m_flSpeed;
	float m_flLip;
	float m_iState;
	float m_flNextAction;
	float m_flWait;
	float m_flDelay;
	vector m_vecDest;
	vector m_vecPos1;
	vector m_vecPos2;
	vector m_vecMoveDir;
	virtual void() m_pMove = 0;
	
	void() func_door_rotating;
	virtual void() Respawn;
	virtual void() Precache;
	virtual void() Arrived;
	virtual void() Returned;
	virtual void() Back;
	virtual void() Away;
	virtual void() Trigger;
	virtual void() Use;
	virtual void() Touch;
	virtual void() Blocked;
	virtual void() SetMovementDirection;
	virtual void(vector angle, void() func) RotToDest;
	virtual void() RotToDest_End;
};

void func_door_rotating::Precache(void)
{
	if (spawnflags & SF_DOOR_SILENT) {
		return;
	}

	if (m_iMoveSnd > 0 && m_iMoveSnd <= 10) {
		precache_sound(sprintf("doors/doormove%i.wav", m_iMoveSnd));
	} else {
		precache_sound("common/null.wav");
	}

	if (m_iStopSnd > 0 && m_iStopSnd <= 8) {
		precache_sound(sprintf("doors/doorstop%i.wav", m_iStopSnd));
	} else {
		precache_sound("common/null.wav");
	}
}

void func_door_rotating::Arrived(void)
{
	m_iState = STATE_RAISED;

	if (m_iStopSnd > 0 && m_iStopSnd <= 8) {
		sound(this, CHAN_VOICE, sprintf("doors/doorstop%i.wav", m_iStopSnd), 1.0, ATTN_NORM);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
	}

	if (!(spawnflags & SF_ROT_USE)) {
		touch = Touch;
	}
	if (m_flWait < 0) {
		return;
	}

	think = Back;
	nextthink = (ltime + m_flWait);
}

void func_door_rotating::Returned(void)
{
	if (!(spawnflags & SF_ROT_USE)) {
		touch = Touch;
	}
    
	m_iState = STATE_LOWERED;
}

void func_door_rotating::Back(void)
{
	if (!(spawnflags & SF_DOOR_SILENT)) {
		if (m_iMoveSnd > 0 && m_iMoveSnd <= 10) {
			sound(this, CHAN_VOICE, sprintf("doors/doormove%i.wav", m_iMoveSnd), 1.0, ATTN_NORM);
		} else {
			sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
		}
	}

	if (!(spawnflags & SF_ROT_USE)) {
		touch = __NULL__;
	}
    
	m_iState = STATE_DOWN;
	RotToDest(m_vecPos1, Returned);
}

void func_door_rotating::Away(void)
{
	float fDirection = 1.0;

	if (m_iState == STATE_UP) {
		return;
	}

	if (!(spawnflags & SF_DOOR_SILENT)) {
		if (m_iMoveSnd > 0 && m_iMoveSnd <= 10) {
			sound(this, CHAN_VOICE, sprintf("doors/doormove%i.wav", m_iMoveSnd), 1.0, ATTN_NORM);
		} else {
			sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
		}
	}
  
	if (m_iState == STATE_RAISED) {	
		nextthink = (ltime + m_flWait);
		return;
	}

	m_iState = STATE_UP;

	if (!(spawnflags & SF_ROT_ONEWAY)) {
		/* One way doors only work on the Y axis */
		if (!(spawnflags & SF_ROT_ZAXIS || spawnflags & SF_ROT_XAXIS)) {
			vector vDifference = (eActivator.origin - eActivator.view_ofs) - origin;
			vector vAngles = eActivator.angles;
			vAngles[0] = vAngles[2] = 0;

			makevectors(vAngles);
			vAngles = (eActivator.origin + (v_forward * 10)) - origin;

			if (((vDifference[0] * vAngles[1]) - (vDifference[1] * vAngles[0])) < 0) {
				fDirection = -1.0f;
			}
		}
	}
	RotToDest(m_vecPos2 * fDirection, Arrived);
}

void func_door_rotating::Trigger(void)
{
	if (GetMaster() == FALSE) {
		return;
	}

	if (m_flNextAction > time) {
		return;
	}
	m_flNextAction = time + m_flWait;

	if ((m_iState == STATE_UP) || (m_iState == STATE_RAISED)) {
		Back();
		return;
	}

	Away();

	if (m_flDelay) {
#ifdef GS_DEVELOPER
		print(sprintf("func_door_rotating: Delayed trigger of `%s`\n", m_strTarget));
#endif
		CBaseTrigger::UseTargets_Delay(m_flDelay);
	} else {
#ifdef GS_DEVELOPER
		print(sprintf("func_door_rotating: Normal trigger of `%s`\n", m_strTarget));
#endif
		CBaseTrigger::UseTargets();
	}
}

void func_door_rotating::Use(void)
{
	eActivator.gflags &= ~GF_USE_RELEASED;
	Trigger();
}

void func_door_rotating::Touch(void)
{
	if (spawnflags & SF_ROT_USE) {
		return;
	}

	if (m_iLocked) {
		return;
	}

	if (other.movetype == MOVETYPE_WALK) {
		eActivator = other;
		Trigger();
	}
	touch = __NULL__;
}

void func_door_rotating::Blocked(void)
{
	if (m_iDamage) {
		Damage_Apply(other, this, m_iDamage, other.origin, FALSE);
	}

	if (m_flWait >= 0) {
		if (m_iState == STATE_DOWN) {
			Away();
		} else {
			Back();
		}
	}
}

void func_door_rotating::SetMovementDirection(void)
{
	if (spawnflags & SF_ROT_ZAXIS) {
		m_vecMoveDir = [0,0,1];
	} else if (spawnflags & SF_ROT_XAXIS) {
		m_vecMoveDir = [1,0,0];
	} else {
		m_vecMoveDir = [0,1,0];
	}

	if (spawnflags & SF_ROT_BACKWARDS) {
		m_vecMoveDir *= 1;
	}
}

void func_door_rotating::RotToDest_End(void)
{
	angles = m_vecDest;
	avelocity = [0,0,0];
	nextthink = -1;
	m_pMove();
}

void func_door_rotating::RotToDest(vector vDestAngle, void() func)
{
	vector vecAngleDifference;
	float flTravelLength, flTravelTime;

	if (!m_flSpeed) {
		print("^1func_door_rotating^7: No speed defined for moving entity!");
		func_door_rotating::Respawn();
		return;
	}

	vecAngleDifference = (vDestAngle - angles);
	flTravelLength = vlen(vecAngleDifference);
	flTravelTime = (flTravelLength / m_flSpeed);
	avelocity = (vecAngleDifference * (1 / flTravelTime));
	m_vecDest = vDestAngle;
	m_pMove = func;
	think = RotToDest_End;
	nextthink = (ltime + flTravelTime);
}

void func_door_rotating::Respawn(void)
{
	func_door_rotating::SetMovementDirection();

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}
	if (!m_flLip) {
		m_flLip = 90;
	}
	if (!m_flDelay) {
		m_flDelay = 4;
	}
	if (!m_flDistance) {
		m_flDistance = 90;
	}
	
	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	setorigin(this, m_oldOrigin);
	setmodel(this, m_oldModel);
	think = __NULL__;
	nextthink = -1;
	m_pMove = 0;
	avelocity = [0,0,0];

	blocked = Blocked;

	if (spawnflags & SF_ROT_USE) {
		touch = __NULL__;
		PlayerUse = Use;
	} else {
		touch = Touch;
		PlayerUse = __NULL__;
	}

	m_iState = STATE_LOWERED;
	m_vecPos1 = m_oldAngle;
	m_vecPos2 = m_oldAngle + m_vecMoveDir * m_flDistance;

	if (spawnflags & SF_ROT_OPEN) {
		vector vTemp = m_vecPos2;
		m_vecPos2 = m_vecPos1;
		m_vecPos1 = vTemp;
		m_vecMoveDir = m_vecMoveDir * -1;
	}

	if (spawnflags & SF_ROT_PASSABLE) {
		solid = SOLID_NOT;
	}

	if (m_strTargetName) {
		m_iLocked = TRUE;
	}

	angles = m_vecPos1;
}

void func_door_rotating::func_door_rotating(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "speed":
			m_flSpeed = stof(argv(i+1));
			break;
		case "lip":
			m_flLip = stof(argv(i+1));
			break;
		case "movesnd":
			m_iMoveSnd = stoi(argv(i+1));
			break;
		case "stopsnd":
			m_iStopSnd = stoi(argv(i+1));
			break;
		case "distance":
			m_flDistance = stof(argv(i+1));
			break;
		case "delay":
			m_flDelay = stof(argv(i+1));
			break;
		case "dmg":
			m_iDamage = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}

	func_door_rotating::Precache();
	CBaseEntity::CBaseEntity();
	func_door_rotating::Respawn();
}
