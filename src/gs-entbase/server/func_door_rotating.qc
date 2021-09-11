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

/*QUAKED func_door_rotating (0 .5 .8) ? SF_ROT_OPEN SF_ROT_BACKWARDS x SF_ROT_PASSABLE SF_ROT_ONEWAY SF_ROT_TOGGLE SF_ROT_ZAXIS SF_ROT_XAXIS SF_ROT_USE SF_ROT_NOMONSTERS
Rotating brush door entity. It's basically the same as func_door, it just does
not move on any axis, it tilts along a pivot point defined by an origin brush.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"speed" : Speed at which the door turns.
"snd_open" : Sound shader to play for when the door opens.
"snd_close" : Sound shader to play for when the door closes.
"snd_stop" : Sound shader to play for when the door stops rotating.
"movesnd" : Legacy integer value pointing to a predefined move sound.
"stopsnd" : Legacy integer value pointing to a predefined stop sound.
"distance" : The degrees which the door will turn.
"dmg" : The damage inflicted upon objects blocking the way of the door.
"wait" : Time that has to pass for the door to automatically close.
"netname" : Target to trigger when the door closes back up.

-------- SPAWNFLAGS --------
SF_ROT_OPEN : Door is in the open position by default.
SF_ROT_BACKWARDS : Flip the direction of a one-way door.
SF_ROT_PASSABLE : Door has no collision model to speak of.
SF_ROT_ONEWAY : Door will only open one-way as opposed to both ways.
SF_ROT_TOGGLE : Door will have to be triggered by something to open/close.
SF_ROT_ZAXIS : Door will tilt along the Z axis.
SF_ROT_XAXIS : Door will tilt on the X axis.
SF_ROT_USE : Player has to press the 'use' key to interact with it.
SF_ROT_NOMONSTERS : Monsters cannot open this door.

-------- NOTES --------
Please include an origin brush so that a pivot point will be defined.

-------- TRIVIA --------
This entity was introduced in Quake II (1997).
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
	string targetClose;
	string m_strSndStop;

	string m_strSndOpen;
	string m_strSndClose;
	string m_strLockedSfx;
	float m_flSoundWait;

	int m_iDamage;
	int m_iLocked;
	float m_flDistance;
	float m_flSpeed;
	/*float m_flLip;*/
	float m_iState;
	float m_flNextAction;
	float m_flWait;
	float m_flDelay;
	vector m_vecDest;
	vector m_vecPos1;
	vector m_vecPos2;
	vector m_vecMoveDir;
	
	void(void) func_door_rotating;
	virtual void(void) Respawn;
	virtual void(void) Arrived;
	virtual void(void) Returned;
	virtual void(void) Back;
	virtual void(void) Away;
	virtual void(entity, int) Trigger;
	virtual void(void) Use;
	virtual void(void) Touch;
	virtual void(void) Blocked;
	virtual void(void) SetMovementDirection;
	virtual void(vector angle, void(void) func) RotToDest;
	virtual void(string, string) SpawnKey;

#ifdef GS_PHYSICS
	virtual void(void) Unhinge;
#endif
};

#ifdef GS_PHYSICS
void func_door_rotating::Unhinge(void)
{
	takedamage = DAMAGE_NO;
	touch = think = __NULL__;
	SetSolid(SOLID_PHYSICS_BOX);
	SetMovetype(MOVETYPE_PHYSICS);
	physics_enable(this, TRUE);
}
#endif

void func_door_rotating::Arrived(void)
{
	SetAngles(m_vecDest);
	avelocity = [0,0,0];
	nextthink = 0.0f;

	m_iState = STATE_RAISED;

	if (m_strSndStop) {
		Sound_Play(this, CHAN_VOICE, m_strSndStop);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);
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
	SetAngles(m_vecDest);
	avelocity = [0,0,0];
	nextthink = 0.0f;

	if (!(spawnflags & SF_ROT_USE)) {
		touch = Touch;
	}

	if (m_strSndStop) {
		Sound_Play(this, CHAN_VOICE, m_strSndStop);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);
	}

	if (targetClose)
	for (entity f = world; (f = find(f, ::targetname, targetClose));) {
		CBaseTrigger trigger = (CBaseTrigger)f;
		if (trigger.Trigger != __NULL__) {
			trigger.Trigger(this, TRIG_TOGGLE);
		}
	}
    
	m_iState = STATE_LOWERED;

	setorigin(this, origin);
	openportal(this, AREAPORTAL_CLOSED);
}

void func_door_rotating::Back(void)
{
	if (!(spawnflags & SF_DOOR_SILENT)) {
		
		if (m_strSndClose) {
			Sound_Play(this, CHAN_VOICE, m_strSndClose);
		} else {
			sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);
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
		if (m_strSndOpen) {
			Sound_Play(this, CHAN_VOICE, m_strSndOpen);
		} else {
			sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);
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

	setorigin(this, origin);
	openportal(this, AREAPORTAL_OPEN);
}

void func_door_rotating::Trigger(entity act, int state)
{
	if (GetMaster() == FALSE) {
		return;
	}
	if (m_flNextAction > time) {
		return;
	}

	m_flNextAction = time + m_flWait;
	eActivator = act;

	if (state == TRIG_TOGGLE) {
		if ((m_iState == STATE_UP) || (m_iState == STATE_RAISED)) {
			Back();
			return;
		} else {
			Away();
		}
	} else if (state == TRIG_OFF) {
		Back();
	} else if (state == TRIG_ON) {
		Away();
	}

	UseTargets(act, TRIG_TOGGLE, m_flDelay);
}

void func_door_rotating::Use(void)
{
	eActivator.flags &= ~FL_USE_RELEASED;
	Trigger(eActivator, TRIG_TOGGLE);
}

void func_door_rotating::Touch(void)
{
	if (m_iLocked || !GetMaster()) {
		if (m_flSoundWait < time)
			Sound_Play(this, CHAN_VOICE, m_strLockedSfx);

		m_flSoundWait = time + 0.3f;
		return;
	}

	if (spawnflags & SF_ROT_USE) {
		return;
	}

	if ((m_iState == STATE_UP) || (m_iState == STATE_DOWN))
		return;

	if (other.movetype == MOVETYPE_WALK) {
		Trigger(other, TRIG_TOGGLE);
	}
}

void func_door_rotating::Blocked(void)
{
	if (m_iDamage) {
		Damage_Apply(other, this, m_iDamage, 0, DMG_CRUSH);
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
}

void func_door_rotating::RotToDest(vector vDestAngle, void(void) func)
{
	vector vecAngleDifference;
	float flTravelLength, flTravelTime;

	if (!m_flSpeed) {
		dprint(sprintf("^1func_door_rotating::^3RotToDest^7: No speed defined for %s!", targetname));
		func_door_rotating::Respawn();
		return;
	}

	vecAngleDifference = (vDestAngle - angles);
	flTravelLength = vlen(vecAngleDifference);
	flTravelTime = (flTravelLength / m_flSpeed);

	/* Avoid NAN hack */
	if (flTravelTime <= 0.0f) {
		func();
		nextthink = 0.0f;
	} else {
		avelocity = (vecAngleDifference * (1 / flTravelTime));
		m_vecDest = vDestAngle;
		think = func;
		nextthink = (ltime + flTravelTime);
	}
}

void func_door_rotating::Respawn(void)
{
	func_door_rotating::SetMovementDirection();

#ifdef GS_PHYSICS
	takedamage = DAMAGE_YES;
	health = 100;
	Death = func_door_rotating::Unhinge;
#endif

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	think = __NULL__;
	nextthink = 0.0f;
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

	if (spawnflags & SF_ROT_BACKWARDS) {
		m_vecPos2 = m_oldAngle + m_vecMoveDir * -m_flDistance;
	} else {
		m_vecPos2 = m_oldAngle + m_vecMoveDir * m_flDistance;
	}

	if (spawnflags & SF_ROT_OPEN) {
		vector vTemp = m_vecPos2;
		m_vecPos2 = m_vecPos1;
		m_vecPos1 = vTemp;
		m_vecMoveDir = m_vecMoveDir * -1;
		setorigin(this, origin);
		openportal(this, AREAPORTAL_OPEN);
	} else {
		setorigin(this, origin);
		openportal(this, AREAPORTAL_CLOSED);
	}

	if (spawnflags & SF_ROT_PASSABLE) {
		SetSolid(SOLID_NOT);
	}

	if (targetname) {
		m_iLocked = TRUE;
	}

	SetAngles(m_vecPos1);
}

void
func_door_rotating::SpawnKey(string strKey, string strValue)
{
	int x = 0;
	switch (strKey) {
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	/*case "lip":
		m_flLip = stof(strValue);
		break;*/
	case "snd_open":
		m_strSndOpen = strValue;
		break;
	case "snd_close":
		m_strSndClose = strValue;
		break;
	case "noise1":
		m_strSndOpen = m_strSndClose = strValue;
		break;
	case "snd_stop":
	case "noise2":
		m_strSndStop = strValue;
		break;
	/* GoldSrc compat */
	case "movesnd":
		x = stoi(strValue);
		m_strSndOpen = m_strSndClose = sprintf("func_door_rotating.move_%i", x);
		break;
	case "stopsnd":
		x = stoi(strValue);
		m_strSndStop = sprintf("func_door_rotating.stop_%i", x);
		break;
	case "distance":
		m_flDistance = stof(strValue);
		break;
	case "dmg":
		m_iDamage = stoi(strValue);
		break;
	case "wait":
		m_flWait = stof(strValue);
		break;
	case "netname":
		targetClose = strValue;
		break;
	case "locked_sound":
		x = stoi(strValue);
		m_strLockedSfx = sprintf("func_button.hlsfx_%i", x+1i);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void func_door_rotating::func_door_rotating(void)
{
	m_flSpeed = 100;
	m_flDelay = 4;
	m_flDistance = 90;

	CBaseTrigger::CBaseTrigger();

	if (m_strSndOpen)
		Sound_Precache(m_strSndOpen);
	if (m_strSndClose)
		Sound_Precache(m_strSndClose);
	if (m_strSndStop)
		Sound_Precache(m_strSndStop);
	if (m_strLockedSfx)
		Sound_Precache(m_strLockedSfx);
}
