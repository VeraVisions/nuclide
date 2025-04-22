/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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

/*! \brief Server-Entity: Rotating Door */
/*!QUAKED func_door_rotating (0 .5 .8) ? SF_ROT_OPEN SF_ROT_BACKWARDS x SF_ROT_PASSABLE SF_ROT_ONEWAY SF_ROT_TOGGLE SF_ROT_ZAXIS SF_ROT_XAXIS SF_ROT_USE SF_ROT_NOMONSTERS
# OVERVIEW
Rotating brush door entity. It's basically the same as func_door, it just does
not move on any axis, it tilts along a pivot point defined by an origin brush.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "speed" : Speed at which the door turns.
- "snd_open" : Sound shader to play for when the door opens.
- "snd_close" : Sound shader to play for when the door closes.
- "snd_stop" : Sound shader to play for when the door stops rotating.
- "movesnd" : Legacy integer value pointing to a predefined move sound.
- "stopsnd" : Legacy integer value pointing to a predefined stop sound.
- "distance" : The degrees which the door will turn.
- "dmg" : The damage inflicted upon objects blocking the way of the door.
- "wait" : Time that has to pass for the door to automatically close.
- "netname" : Target to trigger when the door closes back up.

# SPAWNFLAGS
- SF_ROT_OPEN (1) : Door is in the open position by default.
- SF_ROT_BACKWARDS (2) : Flip the direction of a one-way door.
- SF_ROT_PASSABLE (8) : Door has no collision model to speak of.
- SF_ROT_ONEWAY (16) : Door will only open one-way as opposed to both ways.
- SF_ROT_TOGGLE (32) : Door will have to be triggered by something to open/close.
- SF_ROT_ZAXIS (64) : Door will tilt along the Z axis.
- SF_ROT_XAXIS (128) : Door will tilt on the X axis.
- SF_ROT_USE (256) : Player has to press the 'use' key to interact with it.
- SF_ROT_NOMONSTERS (512) : Monsters cannot open this door.

# NOTES
Please include an origin brush so that a pivot point will be defined.

# TRIVIA
This entity was introduced in Quake II (1997).

@ingroup serverentity
@ingroup brushentity
*/
class
func_door_rotating:ncMoverEntity
{
public:
	void func_door_rotating(void);

	/* overrides */
	virtual void Spawned(void);
	virtual void SpawnKey(string,string);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Use(void);
	virtual void Touch(entity);
	virtual void Blocked(entity);
	virtual void Respawn(void);
	virtual void MoverStartsMoving(void);
	virtual void MoverFinishesMoving(void);

	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);

#ifdef GS_PHYSICS
	nonvirtual void Unhinge(void);
#endif

private:
	string targetClose;
	string m_strSndStop;
	string m_strSndOpen;
	string m_strSndClose;
	string m_strLockedSfx;
	float m_flSoundWait;
	float m_flDistance;
	float m_flSpeed;
	float m_flNextAction;
	float m_flWait;
	float m_flDelay;
	int m_iDamage;
	bool m_bLocked;
	bool m_bCanTouch;
	vector m_vecTurnDir;
	float m_flNextTrigger;
	float m_preventTouch;
};

void
func_door_rotating::func_door_rotating(void)
{
	targetClose = __NULL__;
	m_strSndStop = __NULL__;
	m_strSndOpen = __NULL__;
	m_strSndClose = __NULL__;
	m_strLockedSfx = __NULL__;
	m_flSoundWait = 0.0f;
	m_iDamage = 0i;
	m_bLocked = false;
	m_flDistance = 0.0f;
	m_flSpeed = 100.0f;
	m_flNextAction = 0.0f;
	m_flWait = -1;
	m_flDelay = 4.0f;
	m_bCanTouch = false;
	m_vecTurnDir = g_vec_null;
}

void
func_door_rotating::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "targetClose", targetClose);
	SaveString(handle, "m_strSndStop", m_strSndStop);
	SaveString(handle, "m_strSndOpen", m_strSndOpen);
	SaveString(handle, "m_strSndClose", m_strSndClose);
	SaveString(handle, "m_strLockedSfx", m_strLockedSfx);
	SaveFloat(handle, "m_flSoundWait", m_flSoundWait);
	SaveFloat(handle, "m_flDistance", m_flDistance);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flNextAction", m_flNextAction);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveInt(handle, "m_iDamage", m_iDamage);
	SaveBool(handle, "m_bLocked", m_bLocked);
	SaveBool(handle, "m_bCanTouch", m_bCanTouch);
	SaveVector(handle, "m_vecTurnDir", m_vecTurnDir);
}

void
func_door_rotating::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "targetClose":
		targetClose = ReadString(setValue);
		break;
	case "m_strSndStop":
		m_strSndStop = ReadString(setValue);
		break;
	case "m_strSndOpen":
		m_strSndOpen = ReadString(setValue);
		break;
	case "m_strSndClose":
		m_strSndClose = ReadString(setValue);
		break;
	case "m_strLockedSfx":
		m_strLockedSfx = ReadString(setValue);
		break;
	case "m_flSoundWait":
		m_flSoundWait = ReadFloat(setValue);
		break;
	case "m_flDistance":
		m_flDistance = ReadFloat(setValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(setValue);
		break;
	case "m_flNextAction":
		m_flNextAction = ReadFloat(setValue);
		break;
	case "m_flWait":
		m_flWait = ReadFloat(setValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(setValue);
		break;
	case "m_iDamage":
		m_iDamage = ReadInt(setValue);
		break;
	case "m_bLocked":
		m_bLocked = ReadBool(setValue);
		break;
	case "m_bCanTouch":
		m_bCanTouch = ReadBool(setValue);
		break;
	case "m_vecTurnDir":
		m_vecTurnDir = ReadVector(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_door_rotating::Spawned(void)
{
	super::Spawned();

	precache.Sound(m_strSndOpen);
	precache.Sound(m_strSndClose);
	precache.Sound(m_strSndStop);
	precache.Sound(m_strLockedSfx);
}

void
func_door_rotating::Respawn(void)
{
	super::Respawn();

#ifdef GS_PHYSICS
	MakeVulnerable();
	SetHealth(100);
	Death = func_door_rotating::Unhinge;
#endif

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	ClearVelocity();
	ReleaseThink();

	if (HasSpawnFlags(SF_ROT_USE) || HasSpawnFlags(SF_ROT_TOGGLE)) {
		m_bCanTouch = false;
	} else {
		m_bCanTouch = true;
	}

	/* this is a terrible hack */
	if (m_flWait == 0) {
		m_flWait = 0.01f;
	}

	if (HasSpawnFlags(SF_ROT_USE)) {
		PlayerUse = Use;
	} else {
		PlayerUse = __NULL__;
	}

	if (HasSpawnFlags(SF_ROT_ZAXIS)) {
		m_vecTurnDir = [0,0,-1];
	} else if (HasSpawnFlags(SF_ROT_XAXIS)) {
		m_vecTurnDir = [-1,0,0];
	} else {
		m_vecTurnDir = [0,1,0];
	}

	float distanceFloat = GetSpawnFloat("distance");

	if (HasSpawnFlags(2)) {
		m_vecTurnDir[0] *= -1.0f;
	} 

	SetMoverRotation1(GetSpawnVector("angles"));
	SetMoverRotation2(GetDirectionalRotation(m_vecTurnDir, distanceFloat));
	ClearAngles();

	if (HasSpawnFlags(SF_ROT_OPEN)) {
		vector vTemp = GetMoverRotation2();
		SetMoverRotation2(GetMoverRotation1());
		SetMoverRotation1(vTemp);
	}

	if (HasSpawnFlags(SF_ROT_PASSABLE)) {
		SetSolid(SOLID_NOT);
	}

	if (HasTargetname() || m_flDistance == 0.0) {
		if (m_flDistance == 0.0 || m_strLockedSfx != __NULL__) {
			m_bLocked = true;
		} else {
			m_bLocked = false;
		}
	}

	SetAngles(GetMoverRotation1());
}

void
func_door_rotating::SpawnKey(string strKey, string setValue)
{
	int x = 0;
	switch (strKey) {
	case "speed":
		m_flSpeed = stof(setValue);
		break;
	case "snd_open":
		m_strSndOpen = setValue;
		break;
	case "snd_close":
		m_strSndClose = setValue;
		break;
	case "noise1":
		m_strSndOpen = m_strSndClose = setValue;
		break;
	case "snd_stop":
	case "noise2":
		m_strSndStop = setValue;
		break;
	/* GoldSrc compat */
	case "movesnd":
		x = stoi(setValue); /* sanitize */
		m_strSndOpen = m_strSndClose = sprintf("func_door_rotating.move_%i", x);
		break;
	case "stopsnd":
		x = stoi(setValue); /* sanitize */
		m_strSndStop = sprintf("func_door_rotating.stop_%i", x);
		break;
	case "distance":
		m_flDistance = stof(setValue);
		break;
	case "dmg":
		m_iDamage = stoi(setValue);
		break;
	case "wait":
		m_flWait = stof(setValue);
		break;
	case "netname":
		targetClose = setValue;
		break;
	case "locked_sound":
		x = stoi(setValue);  /* sanitize */

		if (x == 0i)
			break;

		m_strLockedSfx = sprintf("func_button.hlsfx_%i", x+1i);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

#ifdef GS_PHYSICS
void
func_door_rotating::Unhinge(void)
{
	MakeInvulnerable();
	ReleaseThink();
	m_bCanTouch = false;
	SetSolid(SOLID_PHYSICS_BOX);
	SetMovetype(MOVETYPE_PHYSICS);
	physics_enable(this, true);
}
#endif

void
func_door_rotating::MoverFinishesMoving(void)
{
	static void RotateBack(void) {
		RotateToPosition(GetMoverRotation1(), m_flSpeed);
	}

	if (GetMoverState() == MOVER_POS1) {
		if (m_strSndStop) {
			StartSoundDef(m_strSndStop, CHAN_VOICE, true);
		} else {
			StartSound("common/null.wav", CHAN_VOICE, 0, true);
		}

		if (targetClose)
		for (entity f = world; (f = find(f, ::targetname, targetClose));) {
			ncEntity trigger = (ncEntity)f;
			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(this, TRIG_TOGGLE);
			}
		}
	} else if (GetMoverState() == MOVER_POS2) {
		if (m_strSndStop) {
			StartSoundDef(m_strSndStop, CHAN_VOICE, true);
		} else {
			StartSound("common/null.wav", CHAN_VOICE, 0, true);
		}

		if ((m_flWait < 0.0f) || HasSpawnFlags(SF_ROT_TOGGLE) == true)
			return;

		ScheduleThink(RotateBack, m_flWait);
	}
}

void
func_door_rotating::MoverStartsMoving(void)
{
	if (GetMoverState() == MOVER_2TO1) {
		if (!HasSpawnFlags(SF_DOOR_SILENT)) {
			if (m_strSndClose) {
				StartSoundDef(m_strSndClose, CHAN_VOICE, true);
			} else {
				StartSound("common/null.wav", CHAN_VOICE, 0, true);
			}
		}
	} else if (GetMoverState() == MOVER_1TO2) {
		if (!HasSpawnFlags(SF_DOOR_SILENT)) {
			if (m_strSndOpen) {
				StartSoundDef(m_strSndOpen, CHAN_VOICE, true);
			} else {
				StartSound("common/null.wav", CHAN_VOICE, 0, true);
			}
		}
	}
}


void
func_door_rotating::Input(entity act, string inputName, string dataString)
{
	switch (inputName) {
		case "Open":
			Trigger(act, TRIG_ON);
			break;
		case "Close":
			Trigger(act, TRIG_OFF);
			break;
		default:
			super::Input(act, inputName, dataString);
	}
}

void
func_door_rotating::Trigger(entity act, triggermode_t state)
{
	/* Note: Unlike func_door, this does respect the locked state in Trigger() */
	if (m_bLocked || !GetMaster(act)) {
		return;
	}

	if ((GetMoverState() == MOVER_1TO2) || (GetMoverState() == MOVER_2TO1)) {
		return;
	}

	if (m_flNextTrigger > time) {
		if (HasSpawnFlags(SF_ROT_TOGGLE) == false) {
			return;
		}
	}
	m_flNextTrigger = time + m_flWait;

	eActivator = (ncEntity)act;

	/* this door can swing both ways */
	if (!HasSpawnFlags(SF_ROT_ONEWAY)) {
		/* One way doors only work on the Y axis */
		if (!HasSpawnFlags(SF_ROT_ZAXIS) || HasSpawnFlags(SF_ROT_XAXIS)) {
			float flDirection = 1.0;
			/* get the door facing dir */
			vector door_dir = vectoangles(WorldSpaceCenter() - origin);
			makevectors(door_dir);
			float flDir = dotproduct(origin - act.origin, v_right);

			if (flDir > 0) {
				flDirection = -1.0f;
			}

			SetMoverRotation2(GetDirectionalRotation(m_vecTurnDir, m_flDistance * flDirection));
		}
	}

	if (state == TRIG_TOGGLE) {
		if ((GetMoverState() == MOVER_1TO2) || (GetMoverState() == MOVER_POS2)) {
			RotateToPosition(GetMoverRotation1(), m_flSpeed);
			return;
		} else {
			RotateToPosition(GetMoverRotation2(), m_flSpeed);
		}
	} else if (state == TRIG_OFF) {
		RotateToPosition(GetMoverRotation1(), m_flSpeed);
	} else if (state == TRIG_ON) {
		RotateToPosition(GetMoverRotation2(), m_flSpeed);
	}

	UseTargets(act, TRIG_TOGGLE, m_flDelay);
}

void
func_door_rotating::Use(void)
{
	eActivator.RemoveVFlags(VFL_USE_RELEASED);
	Trigger(eActivator, TRIG_TOGGLE);
}

void
func_door_rotating::Touch(entity eToucher)
{
	if (m_preventTouch > GetTime()) {
		return;
	}

	/* locked sound plays only when touched. still need another check in Trigger()
	   to see if it's locked in case it gets trigger targeted */
	if (m_bLocked || !GetMaster(eToucher)) {
		/* only bother playing the locked sound when the door is closed. */
		if (GetMoverState() == MOVER_POS1) {
			if (m_flSoundWait < time) {
				StartSoundDef(m_strLockedSfx, CHAN_VOICE, true);
			}

			m_flSoundWait = time + 0.3f;
		}
		return;
	}

	if (m_bCanTouch == false) {
		return;
	}

	if (eToucher.movetype == MOVETYPE_WALK) {
		Trigger(eToucher, TRIG_TOGGLE);
	}
}

void
func_door_rotating::Blocked(entity eBlocker)
{
	if (m_iDamage) {
		ncSurfacePropEntity toAttack = (ncSurfacePropEntity) eBlocker;
		vector center = WorldSpaceCenter();
		vector dmgDir = dirFromTarget(center, eBlocker.origin);
		ncDict damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", itos(m_iDamage));
		m_preventTouch = GetTime() + 0.5f;
		toAttack.Damage(this, eBlocker, damageDecl, 1.0f, dmgDir, eBlocker.origin);
		remove(damageDecl);
	}

	if (m_flWait >= 0) {
		RotateToReverse(m_flSpeed);
	}
}
