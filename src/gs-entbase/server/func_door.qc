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

enumflags {
	SF_MOV_OPEN,
	SF_MOV_RESERVED1,
	SF_MOV_RESERVED2, /* was UNLINK in Quake. Removed in HL */
	SF_MOV_PASSABLE,
	SF_MOV_RESERVED3,
	SF_MOV_TOGGLE,
	SF_MOV_RESERVED4,
	SF_MOV_RESERVED5,
	SF_MOV_USE
};

/*! \brief Server-Entity: Sliding Door */
/*!QUAKED func_door (0 .5 .8) ? SF_MOV_OPEN x SF_MOV_UNLINK SF_MOV_PASSABLE x SF_MOV_TOGGLE x x SF_MOV_USE
# OVERVIEW
This sliding door entity has the ability to slide forth and back on any
axis. It is often used for primitive elevators as well.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "speed" : Movement speed in game-units per second.
- "lip" : Sets how many units are still visible after a door moved.
- "delay" : Time until triggering target.
- "wait" : When to move back.
- "netname" : Target to trigger when door returns to its initial position.
- "dmg" : Damage to inflict upon anything blocking the way.
- "snd_open" : Sound shader to play for when the door opens.
- "snd_close" : Sound shader to play for when the door closes.
- "snd_stop" : Sound shader to play for when the door stops moving.
- "movesnd" : Legacy integer value pointing to a predefined move sound.
- "stopsnd" : Legacy integer value pointing to a predefined stop sound.
- "forceclosed": Will make sure the door will not bounce back when something is blocking it

# SPAWNFLAGS
- SF_MOV_OPEN (1) : Swaps the positions between raised and lowered state.
- SF_MOV_PASSABLE (8) : Don't test against any collision with this door.
- SF_MOV_TOGGLE (32) : Door cannot be opened by physical means, only by a trigger.
- SF_MOV_USE (256): Players can press the "use" button/key to activate this door.

# NOTES
The keys "movesnd" and "stopsnd" are obsolete. Their values point towards
the samples doors/doormoveX.wav and doors/doorstopX.wav respectively, where
X is the integer value set in "movesnd" and "stopsnd".

Previous documents referred to the SF_MOV_UNLINK (4) flag, which was a left-over from Quake.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup serverentity
@ingroup brushentity
*/
class
func_door:ncMoverEntity
{
public:
	void func_door(void);

	virtual void Spawned(void);

	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Blocked(entity);
	virtual void Touch(entity);
	virtual void PlayerUse(void);
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);

	virtual void MoverStartsMoving(void);
	virtual void MoverFinishesMoving(void);

	nonvirtual void EnableTouchActivation(void);
	nonvirtual void DisableTouchActivation(void);
	nonvirtual void Lock(void);
	nonvirtual void Unlock(void);

private:
	bool m_bCanTouch;
	bool m_bForceClosed;
	bool m_bLocked;
	float m_flDelay;
	float m_flLip;
	float m_flNextTrigger;
	float m_flSoundWait;
	float m_flSpeed;
	float m_flWait;
	float m_preventTouch;
	int m_iDamage;
	int m_waterType;
	string m_strFullyClosed;
	string m_strLockedSfx;
	string m_strSndClose;
	string m_strSndMove;
	string m_strSndOpen;
	string m_strSndStop;
	string m_strUnlockedSfx;
	string targetClose;
};


void
func_door::EnableTouchActivation(void)
{
	m_bCanTouch = true;
}

void
func_door::DisableTouchActivation(void)
{
	m_bCanTouch = false;
}

void
func_door::Lock(void)
{
	m_bLocked = true;
}

void
func_door::Unlock(void)
{
	m_bLocked = false;
}

void
func_door::func_door(void)
{
	m_flLip =
	m_flNextTrigger =
	m_flWait = -1; /* verified thorugh through test_door_locked.bsp */
	m_flDelay = 0.0f;

	m_iDamage = 0i;
	m_bLocked =
	m_bForceClosed = false;

	m_bCanTouch = false;
	m_flSoundWait = 0.0f;

	targetClose =
	m_strLockedSfx =
	m_strUnlockedSfx =

	m_strSndOpen =
	m_strSndClose =
	m_strSndMove =
	m_strSndStop = __NULL__;

	m_waterType = 0i;
	m_strFullyClosed = __NULL__;
}

void
func_door::Save(float handle)
{
	super::Save(handle);

	SaveBool(handle, "m_bCanTouch", m_bCanTouch);
	SaveBool(handle, "m_bForceClosed", m_bForceClosed);
	SaveBool(handle, "m_bLocked", m_bLocked);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveFloat(handle, "m_flLip", m_flLip);
	SaveFloat(handle, "m_flNextTrigger", m_flNextTrigger);
	SaveFloat(handle, "m_flSoundWait", m_flSoundWait);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveFloat(handle, "m_preventTouch", m_preventTouch);
	SaveInt(handle, "m_iDamage", m_iDamage);
	SaveInt(handle, "m_waterType", m_waterType);
	SaveString(handle, "m_strFullyClosed", m_strFullyClosed);
	SaveString(handle, "m_strLockedSfx", m_strLockedSfx);
	SaveString(handle, "m_strSndClose", m_strSndClose);
	SaveString(handle, "m_strSndMove", m_strSndMove);
	SaveString(handle, "m_strSndOpen", m_strSndOpen);
	SaveString(handle, "m_strSndStop", m_strSndStop);
	SaveString(handle, "m_strUnlockedSfx", m_strUnlockedSfx);
	SaveString(handle, "targetClose", targetClose);
}

void
func_door::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_bCanTouch":
		m_bCanTouch = ReadBool(setValue);
		break;
	case "m_bForceClosed":
		m_bForceClosed = ReadBool(setValue);
		break;
	case "m_bLocked":
		m_bLocked = ReadBool(setValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(setValue);
		break;
	case "m_flLip":
		m_flLip = ReadFloat(setValue);
		break;
	case "m_flNextTrigger":
		m_flNextTrigger = ReadFloat(setValue);
		break;
	case "m_flSoundWait":
		m_flSoundWait = ReadFloat(setValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(setValue);
		break;
	case "m_flWait":
		m_flWait = ReadFloat(setValue);
		break;
	case "m_preventTouch":
		m_preventTouch = ReadFloat(setValue);
		break;
	case "m_iDamage":
		m_iDamage = ReadInt(setValue);
		break;
	case "m_waterType":
		m_waterType = ReadInt(setValue);
		break;
	case "m_strFullyClosed":
		m_strFullyClosed = ReadString(setValue);
		break;
	case "m_strLockedSfx":
		m_strLockedSfx = ReadString(setValue);
		break;
	case "m_strSndClose":
		m_strSndClose = ReadString(setValue);
		break;
	case "m_strSndMove":
		m_strSndMove = ReadString(setValue);
		break;
	case "m_strSndOpen":
		m_strSndOpen = ReadString(setValue);
		break;
	case "m_strSndStop":
		m_strSndStop = ReadString(setValue);
		break;
	case "m_strUnlockedSfx":
		m_strUnlockedSfx = ReadString(setValue);
		break;
	case "targetClose":
		targetClose = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_door::SpawnKey(string strKey, string setValue)
{
	int x;

	switch (strKey) {
	case "skin":
		m_waterType = ReadInt(setValue);
		break;
	case "speed":
		m_flSpeed = ReadFloat(setValue);
		break;
	case "lip":
		m_flLip = ReadFloat(setValue);
		break;
	case "wait":
		m_flWait = ReadFloat(setValue);
		break;
	case "netname":
		targetClose = setValue;
		netname = __NULL__;
		break;
	case "dmg":
		m_iDamage = ReadInt(setValue);
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
	case "snd_move":
		m_strSndMove = setValue;
		break;
	case "forceclosed":
		m_bForceClosed = ReadInt(setValue);
		break;
	/* GoldSrc compat */
	case "movesnd":
		x = stoi(setValue);
		m_strSndOpen = m_strSndClose = sprintf("func_door.move_%i", x);
		break;
	case "stopsnd":
		x = stoi(setValue);
		m_strSndStop = sprintf("func_door.stop_%i", x);
		break;
	case "locked_sound":
		x = stoi(setValue);

		if (x == 0i)
			break;

		m_strLockedSfx = sprintf("func_button.hlsfx_%i", x+1i);
		break;
	case "unlocked_sound":
		x = stoi(setValue);

		if (x == 0i)
			break;

		m_strUnlockedSfx = sprintf("func_button.hlsfx_%i", x+1i);
		break;
	/* I/O */
	case "OnFullyClosed":
		m_strFullyClosed = PrepareOutput(m_strFullyClosed, setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
func_door::Spawned(void)
{
	super::Spawned();

	precache.Sound(m_strSndOpen);
	precache.Sound(m_strSndClose);
	precache.Sound(m_strSndStop);
	precache.Sound(m_strSndMove);

	/* GoldSrc compat */
	precache.Sound(m_strLockedSfx);
	precache.Sound(m_strUnlockedSfx);

	/* I/O */
	if (m_strFullyClosed)
		m_strFullyClosed = CreateOutput(m_strFullyClosed);
}

void
func_door::Respawn(void)
{
	super::Respawn();

	if (modelindex == 0) {
		Destroy();
		return;
	}

	/* this is a terrible hack */
	if (m_flWait == 0) {
		m_flWait = 0.01f;
	}

	if (HasSpawnFlags(SF_MOV_PASSABLE)) {
		SetSolid(SOLID_NOT);
	} else {
		SetSolid(SOLID_BSP);
	}

	SetMovetype(MOVETYPE_PUSH);
	AddFlags(FL_FINDABLE_NONSOLID);
	ReleaseThink();

	RestoreAngles();
	SetMoverPosition1(GetSpawnVector("origin"));
	SetMoverPosition2(GetDirectionalPosition(GetAngles(), m_flLip));
	ClearAngles();

	/* FIXME: Is this correct? */
	if (m_flWait == -1) {
		spawnflags |= SF_MOV_TOGGLE;
	}

	if (!m_flSpeed) {
		m_flSpeed = 100.0f;
	}

	if (!m_iDamage) {
		m_iDamage = 2;
	}

	SetValue(0i);

	if (HasSpawnFlags(SF_MOV_USE) || HasSpawnFlags(SF_MOV_TOGGLE)) {
		m_bCanTouch = false;
	} else {
		m_bCanTouch = true;
	}

	if (HasSpawnFlags(SF_MOV_OPEN)) {
		SetOrigin(GetMoverPosition2());
		SetMoverPosition2(GetMoverPosition1());
		SetMoverPosition1(GetOrigin());
		SetValue(1i);
		_PortalOpen();
	} else {
		_PortalClose();
	}

	if (HasTargetname()) {
		m_bCanTouch = false;

		if (STRING_SET(m_strLockedSfx)) {
			Lock();
		}
	}
}

void
func_door::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Lock":
		Lock();
		break;
	case "Unlock":
		Unlock();
		break;
	case "Open":
		Trigger(eAct, TRIG_ON);
		break;
	case "Close":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
func_door::PlayerUse(void)
{
	if (!HasSpawnFlags(SF_MOV_USE)) {
		return;
	}

	eActivator.RemoveVFlags(VFL_USE_RELEASED);
	Trigger(eActivator, TRIG_TOGGLE);
}

void
func_door::MoverFinishesMoving(void)
{
	static void MoveBack(void) {
		MoveToPosition(GetMoverPosition1(), m_flSpeed);
	}

	/* we arrived at our starting position within the map */
	if (GetMoverState() == MOVER_POS1) {
		if (STRING_SET(targetClose)) {
			for (entity f = world; (f = find(f, ::targetname, targetClose));) {
				ncEntity trigger = (ncEntity)f;

				if (trigger.Trigger != __NULL__) {
					trigger.Trigger(this, TRIG_TOGGLE);
				}
			}
		}

		if (STRING_SET(m_strSndStop)) {
			StartSoundDef(m_strSndStop, CHAN_VOICE, true);
		} else {
			StopSound(CHAN_VOICE, true);
		}

		if (STRING_SET(m_strSndMove)) {
			StopSound(CHAN_WEAPON, true);
		}

		if (STRING_SET(m_strFullyClosed)) {
			UseOutput(this, m_strFullyClosed);
		}

	} else if (GetMoverState() == MOVER_POS2) {
		if (STRING_SET(m_strSndStop)) {
			StartSoundDef(m_strSndStop, CHAN_VOICE, true);
		} else {
			StopSound(CHAN_VOICE, true);
		}

		if (STRING_SET(m_strSndMove)) {
			StopSound(CHAN_WEAPON, true);
		}

		if ((m_flWait < 0.0f) || HasSpawnFlags(SF_MOV_TOGGLE) == true) {
			return;
		}

		ScheduleThink(MoveBack, m_flWait);
	}
}

void
func_door::MoverStartsMoving(void)
{
	if (GetMoverState() == MOVER_1TO2) {
		if (STRING_SET(m_strSndOpen)) {
			StartSoundDef(m_strSndOpen, CHAN_VOICE, true);
		} else {
			StartSound("common/null.wav", CHAN_VOICE, 0, true);
		}

		if (STRING_SET(m_strSndMove)) {
			StartSoundDef(m_strSndMove, CHAN_WEAPON, true);
		}

		SetValue(1i);
	} else if (GetMoverState() == MOVER_2TO1) {
		if (STRING_SET(m_strSndClose)) {
			StartSoundDef(m_strSndClose, CHAN_VOICE, true);
		} else {
			StartSound("common/null.wav", CHAN_VOICE, 0, true);
		}

		if (STRING_SET(m_strSndMove)) {
			StartSoundDef(m_strSndMove, CHAN_WEAPON, true);
		}

		SetValue(0i);
	}
}

void
func_door::Trigger(entity act, triggermode_t triggerstate)
{
	/* Note: func_door, unlike func_door_rotating, does not respect locked here!
	   This inconsistency is in the original Half-Life as well! */
	if (!GetMaster(act)) {
		return;
	}

	if ((GetMoverState() == MOVER_1TO2) || (GetMoverState() == MOVER_2TO1)) {
		return;
	}

	if (m_flNextTrigger > time) {
		if (HasSpawnFlags(SF_MOV_TOGGLE) == false) {
			return;
		}
	}

	m_flNextTrigger = time + m_flWait;

	/* only trigger stuff once we are done moving */
	if ((GetMoverState() == MOVER_POS1) || (GetMoverState() == MOVER_POS2)) {
		UseTargets(act, TRIG_TOGGLE, m_flDelay);
	}

	if (triggerstate == TRIG_OFF) {
		MoveToPosition(GetMoverPosition1(), m_flSpeed);
	} else if (triggerstate == TRIG_ON) {
		MoveToPosition(GetMoverPosition2(), m_flSpeed);
	} else {
		MoveToReverse(m_flSpeed);
	}
}

void
func_door::Touch(entity eToucher)
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
		/* only trigger if we're not above the door. */
		if (eToucher.absmin[2] <= maxs[2] - 2) {
			Trigger(eToucher, TRIG_TOGGLE);
		}
	}
}

void
func_door::Blocked(entity eBlocker)
{
	if (m_iDamage != 0i) {
		ncSurfacePropEntity toAttack = (ncSurfacePropEntity) eBlocker;
		vector center = WorldSpaceCenter();
		vector dmgDir = dirFromTarget(center, eBlocker.origin);
		ncDict damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", itos(m_iDamage));
		toAttack.Damage(this, eBlocker, damageDecl, 1.0f, dmgDir, eBlocker.origin);
		remove(damageDecl);
		m_preventTouch = GetTime() + 0.5f;
	}

	if (m_bForceClosed == false) {
		if (m_flWait >= 0) {
			MoveToReverse(m_flSpeed);
		}
	}
}

void
func_water(void)
{
	func_door door;
	spawnfunc_func_door();
	door = (func_door)self;
	door.classname = "func_water";
	door.SetSolid(SOLID_BSP);

	if (door.m_waterType == -4) {
		door.SetSkin(CONTENT_SLIME);
	} else if (door.m_waterType == -5) {
		door.SetSkin(CONTENT_LAVA);
	} else {
		door.SetSkin(CONTENT_WATER);
	}

	door.effects |= EF_FULLBRIGHT;
	setorigin(door, door.origin); // relink. have to do this.
	door.geomtype = GEOMTYPE_NONE;
}
