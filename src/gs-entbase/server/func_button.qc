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
	FRAME_OFF,
	FRAME_ON
};

/*! \brief Server-Entity: Moving Button */
/*!QUAKED func_button (0 .5 .8) ? SF_BTT_NOMOVE x x x x SF_BTT_TOGGLE SF_BTT_SPARKS x SF_BTT_TOUCH_ONLY
# OVERVIEW
A brush entity which can be used either by touching, interaction (via a games'
use-key/button or other targetting methods.
It will then travel, similar to a door to a specified direction.
Once it's fully pushed in, it'll trigger its targets, then return back to its
original position.

# KEYS
- "targetname" :  Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "speed" : Movement speed of the door in game-units per second.
- "lip" : How many units remain visible when fully pushed in.
- "snd_pressed" : The sound shader name to play when pressed down.
- "snd_unpressed" : The sound shader name to play when the button becomes raised.
- "wait" : Time to wait in seconds before the button becomes raised.
- "delay" : Delay until the Target gets triggered.
- "sounds" : Obsolete legacy key for HL/Q1 style buttons to decide which sounds to play.
- "health" : Amount of damage this button takes before it triggers. Will reset.

# OUTPUTS
- "OnDamaged" : Fired when the button is damaged.
- "OnPressed" : Fired when the button is pressed.
- "OnUseLocked" : Fired when the button is used while locked.
- "OnIn" : Fired when the button reaches the in/pressed position.
- "OnOut" : Fired when the button reaches the out/released position.

# SPAWNFLAGS
- SF_BTT_NOMOVE (1) : Don't move when it's activated.
- SF_BTT_TOGGLE (32) : Don't move back to the raised state automatically.
- SF_BTT_SPARKS (64) : Spawn decorative sparks when used.
- SF_BTT_TOUCH_ONLY (256) : Disable 'use' key/button. Only collision will activate it.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup serverentity
@ingroup brushentity
*/
class
func_button:ncMoverEntity
{
public:
	void func_button(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void Blocked(entity);
	virtual void Trigger(entity, triggermode_t);
	nonvirtual void DeathTrigger(entity, entity, int, vector, vector, int);
	virtual void PlayerUse(void);

	virtual void MoverStartsMoving(void);
	virtual void MoverFinishesMoving(void);

private:
	moverState_t m_moverState;
	float m_flSpeed;
	float m_flLip;
	float m_flNextTrigger;
	float m_flWait;
	float m_flDelay;
	string m_strSndPressed;
	string m_strSndUnpressed;
	bool m_bCanTouch;

	/* input/output */
	string m_outputOnPressed;
	string m_outputOnDamaged;
	string m_outputOnUseLocked;
	string m_outputOnIn;
	string m_outputOnOut;
};

void
func_button::func_button(void)
{
	m_flSpeed = 0.0f;
	m_flLip = 0.0f;
	m_flNextTrigger = 0.0f;
	m_flWait = 4.0f;
	m_flDelay = 0.0f;
	m_strSndPressed = __NULL__;
	m_strSndUnpressed = __NULL__;
	m_bCanTouch = true;
	m_outputOnPressed = __NULL__;
	m_outputOnDamaged = __NULL__;
	m_outputOnUseLocked = __NULL__;
	m_outputOnIn = __NULL__;
	m_outputOnOut = __NULL__;
}

void
func_button::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flLip", m_flLip);
	SaveFloat(handle, "m_flNextTrigger", m_flNextTrigger);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveString(handle, "m_strSndPressed", m_strSndPressed);
	SaveString(handle, "m_strSndUnpressed", m_strSndUnpressed);
	SaveString(handle, "m_outputOnPressed", m_outputOnPressed);
	SaveString(handle, "m_outputOnDamaged", m_outputOnDamaged);
	SaveString(handle, "m_outputOnUseLocked", m_outputOnUseLocked);
	SaveString(handle, "m_outputOnIn", m_outputOnIn);
	SaveString(handle, "m_outputOnOut", m_outputOnOut);
	SaveBool(handle, "m_bCanTouch", m_bCanTouch);
}

void
func_button::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flSpeed":
		m_flSpeed = ReadFloat(setValue);
		break;
	case "m_flLip":
		m_flLip = ReadFloat(setValue);
		break;
	case "m_flNextTrigger":
		m_flNextTrigger = ReadFloat(setValue);
		break;
	case "m_flWait":
		m_flWait = ReadFloat(setValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(setValue);
		break;
	case "m_strSndPressed":
		m_strSndPressed = ReadString(setValue);
		break;
	case "m_strSndUnpressed":
		m_strSndUnpressed = ReadString(setValue);
		break;
	case "m_outputOnPressed":
		m_outputOnPressed = ReadString(setValue);
		break;
	case "m_outputOnDamaged":
		m_outputOnDamaged = ReadString(setValue);
		break;
	case "m_outputOnUseLocked":
		m_outputOnUseLocked = ReadString(setValue);
		break;
	case "m_outputOnIn":
		m_outputOnIn = ReadString(setValue);
		break;
	case "m_outputOnOut":
		m_outputOnOut = ReadString(setValue);
		break;
	case "m_bCanTouch":
		m_bCanTouch = ReadBool(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_button::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "message":
		message = setValue;
		break;
	case "speed":
		m_flSpeed = stof(setValue);
		break;
	case "lip":
		m_flLip = stof(setValue);
		break;
	case "snd_pressed":
		m_strSndPressed = setValue;
		break;
	case "snd_unpressed":
		m_strSndUnpressed = setValue;
		break;
	case "wait":
		m_flWait = stof(setValue);
		break;
	/* input/output */
	case "OnPressed":
		m_outputOnPressed = PrepareOutput(m_outputOnPressed, setValue);
		break;
	case "OnDamaged":
		m_outputOnDamaged = PrepareOutput(m_outputOnDamaged, setValue);
		break;
	case "OnUseLocked":
		m_outputOnUseLocked = PrepareOutput(m_outputOnUseLocked, setValue);
		break;
	case "OnIn":
		m_outputOnIn = PrepareOutput(m_outputOnIn, setValue);
		break;
	case "OnOut":
		m_outputOnOut = PrepareOutput(m_outputOnOut, setValue);
		break;
	/* compatibility */
	case "sounds":
		m_strSndPressed = sprintf("func_button.hlsfx_%i", stoi(setValue) + 1i);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
func_button::Spawned(void)
{
	super::Spawned();

	/* sounds */
	precache.Sound(m_strSndPressed);
	precache.Sound(m_strSndUnpressed);

	/* input/output */
	if (STRING_SET(m_outputOnPressed))
		m_outputOnPressed = CreateOutput(m_outputOnPressed);
	if (STRING_SET(m_outputOnDamaged))
		m_outputOnDamaged = CreateOutput(m_outputOnDamaged);
	if (STRING_SET(m_outputOnUseLocked))
		m_outputOnUseLocked = CreateOutput(m_outputOnUseLocked);
	if (STRING_SET(m_outputOnIn))
		m_outputOnIn = CreateOutput(m_outputOnIn);
	if (STRING_SET(m_outputOnOut))
		m_outputOnOut = CreateOutput(m_outputOnOut);
}

void
func_button::Respawn(void)
{
	super::Respawn();

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);

	ClearVelocity();
	ReleaseThink();
	SetHealth(GetSpawnFloat("health"));

	RestoreAngles();
	SetMoverPosition1(GetOrigin());
	SetMoverPosition2(GetDirectionalPosition(GetAngles(), m_flLip));
	ClearAngles();

	if (GetHealth() > 0) {
		MakeVulnerable();
		Death = DeathTrigger;
	}

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}

	if (!m_flLip) {
		m_flLip = 4.0f;
	}

	if (HasSpawnFlags(SF_BTT_NOMOVE)) {
		SetMoverPosition2(GetMoverPosition1());
	}

	if (HasSpawnFlags(SF_BTT_TOUCH_ONLY) == true) {
		m_bCanTouch = true;
	} else {
		m_bCanTouch = false;
	}

	SetValue(0i);
}

void
func_button::MoverFinishesMoving(void)
{
	static void MoveBack(void) {
		MoveToPosition(GetMoverPosition1(), m_flSpeed);
	}

	/* let's reset our button's health and mark it as shootable */
	SetHealth(GetSpawnFloat("health"));

	if (GetHealth() > 0) {
		MakeVulnerable();
	}

	if (GetMoverState() == MOVER_POS1) {
		UseOutput(this, m_outputOnOut);
		SetFrame(FRAME_OFF);
	} else if (GetMoverState() == MOVER_POS2) {
		UseOutput(this, m_outputOnIn);
		ScheduleThink(MoveBack, m_flWait);
	}

	m_bCanTouch = true;
}

void
func_button::MoverStartsMoving(void)
{
	m_bCanTouch = false;

	if (GetMoverState() == MOVER_1TO2) {
		SetValue(1i);
		SetFrame(FRAME_ON);
	} else if (GetMoverState() == MOVER_2TO1) {
		SetValue(0i);

		if (m_strSndUnpressed) {
			StartSoundDef(m_strSndUnpressed, CHAN_VOICE, true);
		}
	}
}

/* TODO: Handle state */
void
func_button::Trigger(entity act, triggermode_t state)
{
	if (GetMaster(act) == false) {
		UseOutput(act, m_outputOnUseLocked);
		return;
	}

	if (m_flNextTrigger > time) {
		return;
	}

	m_flNextTrigger = time + m_flWait;
	
	if ((m_moverState == MOVER_1TO2) || (m_moverState == MOVER_POS2)){
		if (m_flWait != -1) {
			MoveToPosition(GetMoverPosition1(), m_flSpeed);
		}
		return;
	}

	if (m_strSndPressed) {
		StartSoundDef(m_strSndPressed, CHAN_VOICE, true);
	}

	MoveToPosition(GetMoverPosition2(), m_flSpeed);
	UseOutput(act, m_outputOnPressed);
	UseTargets(act, TRIG_TOGGLE, m_flDelay);

	if (message) {
		env_message_single(act, message);
	}

	SetHealth(GetSpawnFloat("health"));
}

void
func_button::DeathTrigger(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	MakeInvulnerable();
	Trigger(attacker, TRIG_TOGGLE);
}

void
func_button::Touch(entity eToucher)
{
	if (m_bCanTouch == false) {
		return;
	}

	if (is.Player(eToucher)) {
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
		MoveToReverse(m_flSpeed);
	}
}
