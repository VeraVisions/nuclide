/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

/*QUAKED func_door (0 .5 .8) ? SF_MOV_OPEN x SF_MOV_UNLINK SF_MOV_PASSABLE x SF_MOV_TOGGLE x x SF_MOV_USE
This sliding door entity has the ability to slide forth and back on any
axis. It is often used for primitive elevators as well.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"speed" : Movement speed in game-units per second.
"lip" : Sets how many units are still visible after a door moved.
"delay" : Time until triggering target.
"wait" : When to move back.
"netname" : Target to trigger when door returns to its initial position.
"dmg" : Damage to inflict upon anything blocking the way.
"snd_open" : Sound shader to play for when the door opens.
"snd_close" : Sound shader to play for when the door closes.
"snd_stop" : Sound shader to play for when the door stops moving.
"movesnd" : Legacy integer value pointing to a predefined move sound.
"stopsnd" : Legacy integer value pointing to a predefined stop sound.
"forceclosed": Will make sure the door will not bounce back when something is blocking it

-------- SPAWNFLAGS --------
SF_MOV_OPEN : Swaps the positions between raised and lowered state.
SF_MOV_UNLINK : Currently unimplemented.
SF_MOV_PASSABLE : Don't test against any collision with this door.
SF_MOV_TOGGLE : Door cannot be opened by physical means, only by a trigger.
SF_MOV_USE : Players can press the "use" button/key to activate this door.

-------- NOTES --------
The keys "movesnd" and "stopsnd" are obsolete. Their values point towards
the samples doors/doormoveX.wav and doors/doorstopX.wav respectively, where
X is the integer value set in "movesnd" and "stopsnd".

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

enumflags {
	SF_MOV_OPEN,
	SF_MOV_RESERVED1,
	SF_MOV_UNLINK, /* TODO: implement this */
	SF_MOV_PASSABLE,
	SF_MOV_RESERVED2,
	SF_MOV_TOGGLE,
	SF_MOV_RESERVED3,
	SF_MOV_RESERVED4,
	SF_MOV_USE
};

enum
{
	DOORSTATE_RAISED,
	DOORSTATE_LOWERED,
	DOORSTATE_UP,
	DOORSTATE_DOWN
};

class func_door:NSRenderableEntity
{
	string targetClose;
	vector m_vecPos1;
	vector m_vecPos2;
	vector m_vecDest;
	vector m_vecMoveDir;
	float m_flSpeed;
	float m_flLip;
	float m_iState;
	float m_flNextTrigger;
	float m_flWait;
	float m_flDelay;
	int m_iDamage;
	int m_iLocked;
	int m_iPortalState;
	int m_iForceClosed;
	bool m_iCanTouch;

	float m_flSoundWait;
	string m_strLockedSfx;
	string m_strUnlockedSfx;

	string m_strSndOpen;
	string m_strSndClose;
	string m_strSndMove;
	string m_strSndStop;

	void(void) func_door;

	virtual void(void) Spawned;

	virtual void(void) PortalOpen;
	virtual void(void) PortalClose;
	virtual void(void) SetMovementDirection;
	virtual void(vector, void(void) func) MoveToDestination;
	virtual void(void) MoveAway;
	virtual void(void) MoveBack;
	virtual void(void) Arrived;
	virtual void(void) Returned;
	virtual void(void) Respawn;
	virtual void(entity, int) Trigger;
	virtual void(entity) Blocked;
	virtual void(entity) Touch;
	virtual void(void) PlayerUse;
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(string, string) SpawnKey;
	virtual void(entity, string, string) Input;
};

void
func_door::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Open":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Close":
		Trigger(eAct, TRIG_ON);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
func_door::PortalOpen(void)
{
	if (m_iPortalState == 1)
		return;

	m_iPortalState = 1;
	setorigin(this, origin);
	openportal(this, AREAPORTAL_OPEN);
}

void
func_door::PortalClose(void)
{
	if (m_iPortalState == 0)
		return;

	m_iPortalState = 0;
	setorigin(this, origin);
	openportal(this, AREAPORTAL_CLOSED);
}

void
func_door::PlayerUse(void)
{
	if (!HasSpawnFlags(SF_MOV_USE))
		return;

	eActivator.flags &= ~FL_USE_RELEASED;
	Trigger(eActivator, TRIG_TOGGLE);
}

void
func_door::Arrived(void)
{
	SetOrigin(m_vecDest);
	velocity = [0,0,0];
	nextthink = 0.0f;

	m_iState = DOORSTATE_RAISED;

	if (m_strSndStop) {
		Sound_Play(this, CHAN_VOICE, m_strSndStop);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);
	}

	if (m_strSndMove)
		sound(this, CHAN_WEAPON, "common/null.wav", 1.0f, ATTN_NORM);

	if ((m_flWait < 0.0f) || HasSpawnFlags(SF_MOV_TOGGLE) == true)
		return;

	think = MoveBack;
	nextthink = (ltime + m_flWait);
}

void
func_door::Returned(void)
{
	SetOrigin(m_vecDest);
	velocity = [0,0,0];
	nextthink = 0.0f;

	if (targetClose)
	for (entity f = world; (f = find(f, ::targetname, targetClose));) {
		NSEntity trigger = (NSEntity)f;
		if (trigger.Trigger != __NULL__) {
			trigger.Trigger(this, TRIG_TOGGLE);
		}
	}

	if (m_strSndStop) {
		Sound_Play(this, CHAN_VOICE, m_strSndStop);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);
	}

	if (m_strSndMove)
		sound(this, CHAN_WEAPON, "common/null.wav", 1.0f, ATTN_NORM);

	m_iState = DOORSTATE_LOWERED;
	PortalClose();
}

void
func_door::MoveBack(void)
{
	if (m_strSndClose) {
		Sound_Play(this, CHAN_VOICE, m_strSndClose);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);
	}

	if (m_strSndMove)
		Sound_Play(this, CHAN_WEAPON, m_strSndMove);

	m_iValue = 0;
	m_iState = DOORSTATE_DOWN;
	MoveToDestination(m_vecPos1, Returned);
}

void
func_door::MoveAway(void)
{
	if (m_iState == DOORSTATE_UP) {
		return;
	}

	if (m_strSndOpen) {
		Sound_Play(this, CHAN_VOICE, m_strSndOpen);
	} else {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);
	}

	if (m_strSndMove)
		Sound_Play(this, CHAN_WEAPON, m_strSndMove);

	if (!HasSpawnFlags(SF_MOV_TOGGLE)) {
		if (m_iState == DOORSTATE_RAISED) {
			nextthink = (ltime + m_flWait);
			return;
		}
	}

	m_iValue = 1;
	m_iState = DOORSTATE_UP;
	MoveToDestination(m_vecPos2, Arrived);
	PortalOpen();
}

void
func_door::Trigger(entity act, int state)
{
	if (GetMaster() == 0)
		return;

	if (m_flNextTrigger > time) {
		if (!HasSpawnFlags(SF_MOV_TOGGLE)) {
			return;
		}
	}
	m_flNextTrigger = time + m_flWait;

	/* only trigger stuff once we are done moving */
	if ((m_iState == DOORSTATE_RAISED) || (m_iState == DOORSTATE_LOWERED)) {
		UseTargets(act, TRIG_TOGGLE, m_flDelay);
	}

	if (state == TRIG_OFF) {
		MoveBack();
	} else if (state == TRIG_ON) {
		MoveAway();
	} else {
		if ((m_iState == DOORSTATE_UP) || (m_iState == DOORSTATE_RAISED)){
			MoveBack();
		} else {
			MoveAway();
		}
	}
}

void
func_door::Touch(entity eToucher)
{
	if (m_iCanTouch == false)
		return;

	if (HasSpawnFlags(SF_MOV_USE))
		return;

	if (m_iLocked || !GetMaster()) {
		if (m_flSoundWait < time)
			Sound_Play(this, CHAN_VOICE, m_strLockedSfx);

		m_flSoundWait = time + 0.3f;
		return;
	}

	if (HasSpawnFlags(SF_MOV_TOGGLE)) {
		return;
	}

	if (eToucher.movetype == MOVETYPE_WALK) {
		if (eToucher.absmin[2] <= maxs[2] - 2) {
			Trigger(eToucher, TRIG_TOGGLE);
		}
	}
}

void
func_door::Blocked(entity eBlocker)
{
	if (m_iDamage) {
		Damage_Apply(eBlocker, this, m_iDamage, 0, DMG_CRUSH);
	}

	if (!m_iForceClosed)
	if (m_flWait >= 0) {
		if (m_iState == DOORSTATE_DOWN) {
			MoveAway();
		} else {
			MoveBack();
		}
	}
}

void
func_door::SetMovementDirection(void)
{
	if (GetSpawnAngles() == [0,-1,0]) {
		m_vecMoveDir = [0,0,1];
	} else if (GetSpawnAngles() == [0,-2,0]) {
		m_vecMoveDir = [0,0,-1];
	} else {
		makevectors(GetSpawnAngles());
		m_vecMoveDir = v_forward;
	}
}

void
func_door::MoveToDestination(vector vecDest, void(void) func)
{
	vector vecDifference;
	float flTravel;
	float fTravelTime;

	if (!m_flSpeed) {
		objerror("func_door: No speed defined!");
		return;
	}

	m_vecDest = vecDest;
	think = func;

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
	velocity = (vecDifference * (1.0f / fTravelTime));
}

void
func_door::Respawn(void)
{
	/* reset */
	m_vecPos1 = [0,0,0];
	m_vecPos2 = [0,0,0];
	m_vecDest = [0,0,0];
	m_vecMoveDir = [0,0,0];

	/* this is a terrible hack */
	if (m_flWait == 0)
		m_flWait = 0.01f;

	RestoreAngles();
	SetMovementDirection();
	ClearAngles();

	if (HasSpawnFlags(SF_MOV_PASSABLE))
		SetSolid(SOLID_NOT);
	else
		SetSolid(SOLID_BSP);

	SetMovetype(MOVETYPE_PUSH);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	flags |= FL_FINDABLE_NONSOLID;

	think = __NULL__;
	nextthink = 0.0f;

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

	m_iValue = 0;
	m_iState = DOORSTATE_LOWERED;
	m_vecPos1 = GetSpawnOrigin();
	m_vecPos2 = (m_vecPos1 + m_vecMoveDir * (fabs(m_vecMoveDir * size) - m_flLip));

	if (spawnflags & SF_MOV_USE)
		m_iCanTouch = false;
	else
		m_iCanTouch = true;

	if (HasSpawnFlags(SF_MOV_OPEN)) {
		SetOrigin(m_vecPos2);
		m_vecPos2 = m_vecPos1;
		m_vecPos1 = origin;
		m_iValue = 1;
		PortalOpen();
	} else {
		PortalClose();
	}

	if (targetname) {
		m_iLocked = TRUE;
	}
}

void
func_door::Save(float handle)
{
	SaveVector(handle, "m_vecPos1", m_vecPos1);
	SaveVector(handle, "m_vecPos2", m_vecPos2);
	SaveVector(handle, "m_vecDest", m_vecDest);
	SaveVector(handle, "m_vecMoveDir", m_vecMoveDir);

	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flLip", m_flLip);
	SaveFloat(handle, "m_iState", m_iState);
	SaveFloat(handle, "m_flNextTrigger", m_flNextTrigger);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveFloat(handle, "m_flSoundWait", m_flSoundWait);

	SaveInt(handle, "m_iDamage", m_iDamage);
	SaveInt(handle, "m_iLocked", m_iLocked);
	SaveInt(handle, "m_iPortalState", m_iPortalState);
	SaveInt(handle, "m_iForceClosed", m_iForceClosed);

	SaveString(handle, "m_strLockedSfx", m_strLockedSfx);
	SaveString(handle, "m_strUnlockedSfx", m_strUnlockedSfx);
	SaveString(handle, "m_strSndOpen", m_strSndOpen);
	SaveString(handle, "m_strSndClose", m_strSndClose);
	SaveString(handle, "m_strSndStop", m_strSndStop);
	SaveString(handle, "m_strSndMove", m_strSndMove);
	SaveString(handle, "targetClose", targetClose);

	super::Save(handle);
}

void
func_door::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_vecPos1":
		m_vecPos1 = ReadVector(strValue);
		break;
	case "m_vecPos2":
		m_vecPos2 = ReadVector(strValue);
		break;
	case "m_vecDest":
		m_vecDest = ReadVector(strValue);
		break;
	case "m_vecMoveDir":
		m_vecMoveDir = ReadVector(strValue);
		break;

	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flLip":
		m_flLip = ReadFloat(strValue);
		break;
	case "m_iState":
		m_iState = ReadFloat(strValue);
		break;
	case "m_flNextTrigger":
		m_flNextTrigger = ReadFloat(strValue);
		break;
	case "m_flWait":
		m_flWait = ReadFloat(strValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "m_flSoundWait":
		m_flSoundWait = ReadFloat(strValue);
		break;

	case "m_iDamage":
		m_iDamage = ReadInt(strValue);
		break;
	case "m_iLocked":
		m_iLocked = ReadInt(strValue);
		break;
	case "m_iPortalState":
		m_iPortalState = ReadInt(strValue);
		break;
	case "m_iForceClosed":
		m_iForceClosed = ReadInt(strValue);
		break;

	case "m_strLockedSfx":
		m_strLockedSfx = ReadString(strValue);
		break;
	case "m_strUnlockedSfx":
		m_strUnlockedSfx = ReadString(strValue);
		break;
	case "m_strSndOpen":
		m_strSndOpen = ReadString(strValue);
		break;
	case "m_strSndClose":
		m_strSndClose = ReadString(strValue);
		break;
	case "m_strSndStop":
		m_strSndStop = ReadString(strValue);
		break;
	case "m_strSndMove":
		m_strSndMove = ReadString(strValue);
		break;
	case "targetClose":
		targetClose = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_door::SpawnKey(string strKey, string strValue)
{
	int x;

	switch (strKey) {
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "lip":
		m_flLip = stof(strValue);
		break;
	case "wait":
		m_flWait = stof(strValue);
		break;
	case "netname":
		targetClose = strValue;
		netname = __NULL__;
		break;
	case "dmg":
		m_iDamage = stoi(strValue);
		break;
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
	case "snd_move":
		m_strSndMove = strValue;
		break;
	case "forceclosed":
		m_iForceClosed = stoi(strValue);
		break;
	/* GoldSrc compat */
	case "movesnd":
		x = stoi(strValue);
		m_strSndOpen = m_strSndClose = sprintf("func_door.move_%i", x);
		break;
	case "stopsnd":
		x = stoi(strValue);
		m_strSndStop = sprintf("func_door.stop_%i", x);
		break;
	case "locked_sound":
		x = stoi(strValue);
		m_strLockedSfx = sprintf("func_button.hlsfx_%i", x+1i);
		break;
	case "unlocked_sound":
		x = stoi(strValue);
		m_strUnlockedSfx = sprintf("func_button.hlsfx_%i", x+1i);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_door::Spawned(void)
{
	super::Spawned();

	if (m_strSndOpen)
		Sound_Precache(m_strSndOpen);
	if (m_strSndClose)
		Sound_Precache(m_strSndClose);
	if (m_strSndStop)
		Sound_Precache(m_strSndStop);
	if (m_strSndMove)
		Sound_Precache(m_strSndMove);

	/* GoldSrc compat */
	if (m_strLockedSfx)
		Sound_Precache(m_strLockedSfx);
	if (m_strUnlockedSfx)
		Sound_Precache(m_strUnlockedSfx);
}

void
func_door::func_door(void)
{
	m_vecPos1 =
	m_vecPos2 =
	m_vecDest =
	m_vecMoveDir = [0,0,0];

	m_flSpeed =
	m_flLip =
	m_iState =
	m_flNextTrigger =
	m_flWait =
	m_flDelay = 0.0f;

	m_iDamage =
	m_iLocked =
	m_iPortalState =
	m_iForceClosed = 0;

	m_iCanTouch = false;
	m_flSoundWait = 0.0f;

	targetClose =
	m_strLockedSfx =
	m_strUnlockedSfx =

	m_strSndOpen =
	m_strSndClose =
	m_strSndMove =
	m_strSndStop = __NULL__;
}

void
func_water(void)
{
	func_door door;
	spawnfunc_func_door();
	door = (func_door)self;
	door.classname = "func_water";
	door.SetSolid(SOLID_BSP);
	door.SetSkin(CONTENT_WATER);
	door.effects |= EF_FULLBRIGHT;
	setorigin(door, door.origin); // relink. have to do this.
}
