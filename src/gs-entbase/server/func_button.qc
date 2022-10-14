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

/*QUAKED func_button (0 .5 .8) ? SF_BTT_NOMOVE x x x x SF_BTT_TOGGLE SF_BTT_SPARKS x SF_BTT_TOUCH_ONLY
A brush entity which can be used either by touching, interaction (via a games'
use-key/button or other targetting methods.
It will then travel, similar to a door to a specified direction.
Once it's fully pushed in, it'll trigger its targets, then return back to its
original position.

-------- KEYS --------
"targetname" :  Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"speed" : Movement speed of the door in game-units per second.
"lip" : How many units remain visible when fully pushed in.
"snd_pressed" : The sound shader name to play when pressed down.
"snd_unpressed" : The sound shader name to play when the button becomes raised.
"wait" : Time to wait in seconds before the button becomes raised.
"delay" : Delay until the Target gets triggered.
"sounds" : Obsolete legacy key for HL/Q1 style buttons to decide which sounds to play.
"health" : Amount of damage this button takes before it triggers. Will reset.

-------- OUTPUTS --------
"OnDamaged" : Fired when the button is damaged.
"OnPressed" : Fired when the button is pressed.
"OnUseLocked" : Fired when the button is used while locked.
"OnIn" : Fired when the button reaches the in/pressed position.
"OnOut" : Fired when the button reaches the out/released position.

-------- SPAWNFLAGS --------
SF_BTT_NOMOVE : Don't move when it's activated.
SF_BTT_TOGGLE : Don't move back to the raised state automatically.
SF_BTT_SPARKS : Spawn decorative sparks when used.
SF_BTT_TOUCH_ONLY : Disable 'use' key/button. Only collision will activate it.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

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

class
func_button:NSSurfacePropEntity
{
	int m_iState;
	float m_flSpeed;
	float m_flLip;
	float m_flNextTrigger;
	float m_flWait;
	float m_flDelay;
	vector m_vecPos1;
	vector m_vecPos2;
	vector m_vecDest;
	vector m_vecMoveDir;
	string m_strSndPressed;
	string m_strSndUnpressed;

	bool m_bCanTouch;

	/* input/output */
	string m_strOnPressed;
	string m_strOnDamaged;
	string m_strOnUseLocked;
	string m_strOnIn;
	string m_strOnOut;

	void func_button(void);

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(string, string) SpawnKey;
	virtual void(void) Spawned;
	virtual void(void) Respawn;
	virtual void(void) Arrived;
	virtual void(void) Returned;
	virtual void(void) MoveBack;
	virtual void(void) MoveAway;
	virtual void(entity) Touch;
	virtual void(entity) Blocked;
	virtual void(entity, int) Trigger;
	virtual void(void) DeathTrigger;
	virtual void(void) PlayerUse;
	
	virtual void(void) SetMovementDirection;
	virtual void(vector, void(void)) MoveToDestination;
};

void
func_button::func_button(void)
{
	m_iState = 0i;
	m_flSpeed = 0.0f;
	m_flLip = 0.0f;
	m_flNextTrigger = 0.0f;
	m_flWait = 4.0f;
	m_flDelay = 0.0f;
	m_vecPos1 = [0.0f, 0.0f, 0.0f];
	m_vecPos2 = [0.0f, 0.0f, 0.0f];
	m_vecDest = [0.0f, 0.0f, 0.0f];
	m_vecMoveDir = [0.0f, 0.0f, 0.0f];
	m_strSndPressed = __NULL__;
	m_strSndUnpressed = __NULL__;
	m_bCanTouch = false;
	m_strOnPressed = __NULL__;
	m_strOnDamaged = __NULL__;
	m_strOnUseLocked = __NULL__;
	m_strOnIn = __NULL__;
	m_strOnOut = __NULL__;
}

void
func_button::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iState", m_iState);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flLip", m_flLip);
	SaveFloat(handle, "m_flNextTrigger", m_flNextTrigger);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveVector(handle, "m_vecPos1", m_vecPos1);
	SaveVector(handle, "m_vecPos2", m_vecPos2);
	SaveVector(handle, "m_vecDest", m_vecDest);
	SaveVector(handle, "m_vecMoveDir", m_vecMoveDir);
	SaveString(handle, "m_strSndPressed", m_strSndPressed);
	SaveString(handle, "m_strSndUnpressed", m_strSndUnpressed);
	SaveString(handle, "m_strOnPressed", m_strOnPressed);
	SaveString(handle, "m_strOnDamaged", m_strOnDamaged);
	SaveString(handle, "m_strOnUseLocked", m_strOnUseLocked);
	SaveString(handle, "m_strOnIn", m_strOnIn);
	SaveString(handle, "m_strOnOut", m_strOnOut);
	SaveBool(handle, "m_bCanTouch", m_bCanTouch);
}

void
func_button::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iState":
		m_iState = ReadInt(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flLip":
		m_flLip = ReadFloat(strValue);
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
	case "m_strSndPressed":
		m_strSndPressed = ReadString(strValue);
		break;
	case "m_strSndUnpressed":
		m_strSndUnpressed = ReadString(strValue);
		break;
	case "m_strOnPressed":
		m_strOnPressed = ReadString(strValue);
		break;
	case "m_strOnDamaged":
		m_strOnDamaged = ReadString(strValue);
		break;
	case "m_strOnUseLocked":
		m_strOnUseLocked = ReadString(strValue);
		break;
	case "m_strOnIn":
		m_strOnIn = ReadString(strValue);
		break;
	case "m_strOnOut":
		m_strOnOut = ReadString(strValue);
		break;
	case "m_bCanTouch":
		m_bCanTouch = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_button::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "message":
		message = strValue;
		break;
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "lip":
		m_flLip = stof(strValue);
		break;
	case "snd_pressed":
		m_strSndPressed = strValue;
		break;
	case "snd_unpressed":
		m_strSndUnpressed = strValue;
		break;
	case "wait":
		m_flWait = stof(strValue);
		break;
	/* input/output */
	case "OnPressed":
		m_strOnPressed = PrepareOutput(m_strOnPressed, strValue);
		break;
	case "OnDamaged":
		m_strOnDamaged = PrepareOutput(m_strOnDamaged, strValue);
		break;
	case "OnUseLocked":
		m_strOnUseLocked = PrepareOutput(m_strOnUseLocked, strValue);
		break;
	case "OnIn":
		m_strOnIn = PrepareOutput(m_strOnIn, strValue);
		break;
	case "OnOut":
		m_strOnOut = PrepareOutput(m_strOnOut, strValue);
		break;
	/* compatibility */
	case "sounds":
		m_strSndPressed = sprintf("func_button.hlsfx_%i", stoi(strValue) + 1i);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_button::Spawned(void)
{
	super::Spawned();

	/* sounds */
	Sound_Precache(m_strSndPressed);
	Sound_Precache(m_strSndUnpressed);

	/* input/output */
	if (m_strOnPressed)
		m_strOnPressed = CreateOutput(m_strOnPressed);
	if (m_strOnDamaged)
		m_strOnDamaged = CreateOutput(m_strOnDamaged);
	if (m_strOnUseLocked)
		m_strOnUseLocked = CreateOutput(m_strOnUseLocked);
	if (m_strOnIn)
		m_strOnIn = CreateOutput(m_strOnIn);
	if (m_strOnOut)
		m_strOnOut = CreateOutput(m_strOnOut);
}

void
func_button::Respawn(void)
{
	RestoreAngles();
	SetMovementDirection();
	ClearAngles();

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());

	ClearVelocity();
	ReleaseThink();
	SetHealth(GetSpawnHealth());

	if (health > 0) {
		takedamage = DAMAGE_YES;
		Death = DeathTrigger;
	}

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}

	m_vecPos1 = GetSpawnOrigin();

	if (HasSpawnFlags(SF_BTT_NOMOVE)) {
		m_vecPos2 = m_vecPos1;
	} else {
		m_vecPos2 = (m_vecPos1 + m_vecMoveDir * (fabs(m_vecMoveDir * size) - m_flLip));
	}

	m_iValue = 0;
	m_iState = STATE_LOWERED;
}

void
func_button::Arrived(void)
{
	SetOrigin(m_vecDest);
	ClearVelocity();
	ReleaseThink();
	m_bCanTouch = true;

	UseOutput(this, m_strOnIn);
	m_iState = STATE_RAISED;

	if (HasSpawnFlags(SF_BTT_TOGGLE) == true) {
		return;
	}
	
	if (m_flWait != -1) {
		ScheduleThink(MoveBack, m_flWait);
	}
}

void
func_button::Returned(void)
{
	UseOutput(this, m_strOnOut);
	SetOrigin(m_vecDest);
	ClearVelocity();
	ReleaseThink();
	SetFrame(FRAME_OFF);
	m_bCanTouch = true;
	m_iState = STATE_LOWERED;
}

void
func_button::MoveBack(void)
{
	m_bCanTouch = false;
	m_iState = STATE_DOWN;
	m_iValue = 0;

	if (m_strSndUnpressed) {
		Sound_Play(this, CHAN_VOICE, m_strSndUnpressed);
	}

	if (m_vecPos2 != m_vecPos1) {
		MoveToDestination (m_vecPos1, Returned);
	} else {
		Returned();
	}
}

void
func_button::MoveAway(void)
{
	if (m_iState == STATE_UP) {
		return;
	}

	m_bCanTouch = false;
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
void
func_button::Trigger(entity act, int state)
{
	if (GetMaster() == FALSE)
		return;

	UseOutput(act, m_strOnUseLocked);

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

	if (m_strSndPressed)
		Sound_Play(this, CHAN_VOICE, m_strSndPressed);

	MoveAway();

	UseOutput(act, m_strOnPressed);
	UseTargets(act, TRIG_TOGGLE, m_flDelay);

	if (message)
		env_message_single(act, message);

	SetHealth(GetSpawnHealth());
}

void
func_button::DeathTrigger(void)
{
	Trigger(g_dmg_eAttacker, TRIG_TOGGLE);
}

void
func_button::Touch(entity eToucher)
{
	if (HasSpawnFlags(SF_BTT_TOUCH_ONLY) == false) {
		return;
	}

	if (m_bCanTouch == false)
		return;

	if (eToucher.movetype == MOVETYPE_WALK) {
		Trigger(eToucher, TRIG_TOGGLE);
	}
}

void
func_button::PlayerUse(void)
{
	if (HasSpawnFlags(SF_BTT_TOUCH_ONLY)) {
		return;
	}
	Trigger(eActivator, TRIG_TOGGLE);
}

void
func_button::Blocked(entity eBlocker)
{
	if (m_flWait >= 0) {
		if (m_iState == STATE_DOWN) {
			MoveAway();
		} else {
			MoveBack();
		}
	}
}

void
func_button::SetMovementDirection(void)
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
func_button::MoveToDestination(vector vecDest, void(void) func)
{
	vector vecDifference;
	float flTravel, fTravelTime;

	if (!m_flSpeed) {
		objerror("No speed defined for moving entity! Will not divide by zero.");
	}

	m_vecDest = vecDest;

	if (vecDest == origin) {
		ClearVelocity();
		ScheduleThink(func, 0.0f);
		return;
	}

	vecDifference = (vecDest - origin);
	flTravel = vlen(vecDifference);
	fTravelTime = (flTravel / m_flSpeed);

	if (fTravelTime < 0.1) {
		ClearVelocity();
		ScheduleThink(func, 0.0f);
		return;
	}

	ScheduleThink(func, fTravelTime);
	SetVelocity(vecDifference * (1 / fTravelTime));
}
