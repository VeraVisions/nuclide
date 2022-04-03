/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

class func_button:NSSurfacePropEntity
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

	/* input/output */
	string m_strOnPressed;
	string m_strOnDamaged;
	string m_strOnUseLocked;
	string m_strOnIn;
	string m_strOnOut;

	virtual void(void) Respawn;
	virtual void(void) Arrived;
	virtual void(void) Returned;
	virtual void(void) MoveBack;
	virtual void(void) MoveAway;
	virtual void(entity) Touch;
	virtual void(entity) Blocked;
	virtual void(entity, int) Trigger;
	virtual void(void) DeathTrigger;
	virtual void(void) Use;
	
	virtual void(void) SetMovementDirection;
	virtual void(vector, void(void)) MoveToDestination;
	virtual void(string, string) SpawnKey;
};

void
func_button::Save(float handle)
{
	SaveInt(handle, "state", m_iState);
	SaveFloat(handle, "speed", m_flSpeed);
	SaveFloat(handle, "lip", m_flLip);
	SaveFloat(handle, "next_trigger", m_flNextTrigger);
	SaveFloat(handle, "wait", m_flWait);
	SaveFloat(handle, "delay", m_flDelay);
	SaveVector(handle, "pos1", m_vecPos1);
	SaveVector(handle, "pos2", m_vecPos2);
	SaveVector(handle, "dest", m_vecDest);
	SaveVector(handle, "movedir", m_vecMoveDir);
	SaveString(handle, "snd_pressed", m_strSndPressed);
	SaveString(handle, "snd_unpressed", m_strSndUnpressed);
	SaveString(handle, "on_pressed", m_strOnPressed);
	SaveString(handle, "on_damaged", m_strOnDamaged);
	SaveString(handle, "on_uselocked", m_strOnUseLocked);
	SaveString(handle, "on_in", m_strOnIn);
	SaveString(handle, "on_out", m_strOnOut);

	super::Save(handle);
}

void
func_button::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "state":
		m_iState = ReadInt(strValue);
		break;
	case "speed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "lip":
		m_flLip = ReadFloat(strValue);
		break;
	case "next_trigger":
		m_flNextTrigger = ReadFloat(strValue);
		break;
	case "wait":
		m_flWait = ReadFloat(strValue);
		break;
	case "delay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "pos1":
		m_vecPos1 = ReadVector(strValue);
		break;
	case "pos2":
		m_vecPos2 = ReadVector(strValue);
		break;
	case "dest":
		m_vecDest = ReadVector(strValue);
		break;
	case "movedir":
		m_vecMoveDir = ReadVector(strValue);
		break;
	case "snd_pressed":
		m_strSndPressed = ReadString(strValue);
		break;
	case "snd_unpressed":
		m_strSndUnpressed = ReadString(strValue);
		break;
	case "on_pressed":
		m_strOnPressed = ReadString(strValue);
		break;
	case "on_damaged":
		m_strOnDamaged = ReadString(strValue);
		break;
	case "on_uselocked":
		m_strOnUseLocked = ReadString(strValue);
		break;
	case "on_in":
		m_strOnIn = ReadString(strValue);
		break;
	case "on_out":
		m_strOnOut = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_button::Arrived(void)
{
	SetOrigin(m_vecDest);
	velocity = [0,0,0];
	nextthink = 0;

	UseOutput(this, m_strOnIn);
	m_iState = STATE_RAISED;
	
	if (HasSpawnFlags(SF_BTT_TOUCH_ONLY)) {
		touch = Touch;
	} else {
		touch = __NULL__;
	}

	if (HasSpawnFlags(SF_BTT_TOGGLE)) {
		return;
	}
	
	if (m_flWait != -1) {
		think = MoveBack;
		nextthink = (ltime + m_flWait);
	}
}

void
func_button::Returned(void)
{
	UseOutput(this, m_strOnOut);
	SetOrigin(m_vecDest);
	velocity = [0,0,0];
	nextthink = 0;

	if (HasSpawnFlags(SF_BTT_TOUCH_ONLY)) {
		touch = Touch;
	}
    
	m_iState = STATE_LOWERED;
	SetFrame(FRAME_OFF);
}

void
func_button::MoveBack(void)
{
	touch = __NULL__;
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
	health = GetSpawnHealth();
}

void
func_button::DeathTrigger(void)
{
	Trigger(g_dmg_eAttacker, TRIG_TOGGLE);
}

void
func_button::Touch(entity eToucher)
{
	if (!HasSpawnFlags(SF_BTT_TOUCH_ONLY)) {
		return;
	}

	if (eToucher.movetype == MOVETYPE_WALK) {
		Trigger(eToucher, TRIG_TOGGLE);
	}
}

void
func_button::Use(void)
{
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
	think = func;

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

	velocity = [0,0,0];
	nextthink = -1;
	health = GetSpawnHealth();

	if (health > 0) {
		takedamage = DAMAGE_YES;
		Death = DeathTrigger;
	}

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}

	if (HasSpawnFlags(SF_BTT_TOUCH_ONLY)) {
		PlayerUse = __NULL__;
	} else {
		PlayerUse = Use;
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
func_button::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
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
func_button::func_button(void)
{
	m_flWait = 4.0f;

	super::NSSurfacePropEntity();

	/* sounds */
	Sound_Precache(m_strSndPressed);
	Sound_Precache(m_strSndUnpressed);

	/* input/output */
	m_strOnPressed = CreateOutput(m_strOnPressed);
	m_strOnDamaged = CreateOutput(m_strOnDamaged);
	m_strOnUseLocked = CreateOutput(m_strOnUseLocked);
	m_strOnIn = CreateOutput(m_strOnIn);
	m_strOnOut = CreateOutput(m_strOnOut);
}
