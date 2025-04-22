/*
 * Copyright (c) 2023 Vera Visions LLC.
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
	LOGICTIMER_OSCILLATOR
};

/*! \brief Server-Entity: Timer Trigger */
/*!QUAKED logic_timer (1 0 0) (-8 -8 -8) (8 8 8) OSCILLATOR
# OVERVIEW
Will trigger its outputs at fixed/random intervals, much like the entity random_trigger.

# KEYS
- "targetname" : Name
- "UseRandomTime" : Boolean value that determines whether it's random, or fixed.
- "LowerRandomBound" : The lower limit of a random trigger timer.
- "UpperRandomBound" : The upper limit of a random trigger timer.
- "RefireTime" : Fixed time in seconds. Only when UseRandomTime is set to 0.
- "StartDisabled" : Boolean value that determines whether we should not start triggering at level start.

# INPUTS
- "Enable" - Enable the timer logic.
- "Disable" - Disable the timer logic.
- "Toggle" - Toggle between Enable/Disable.
- "ResetTimer" - Resets the timer, and starts it.
- "FireTimer" - Forcefully triggers the OnTimer outputs.
- "RefireTime" - Sets a new firing time from the data field.
- "LowerRandomBound" - Sets the lower limit of a random trigger timer from the data field.
- "UpperRandomBound" - Sets the upper limit of a random trigger timer from the data field.
- "AddToTimer" - Adds the number of seconds from the data field to the current timer.
- "SubtractFromTimer" - Removes the number of seconds from the data field to the current timer.

# OUTPUTS
- "OnTimer" : Triggered when the map is loaded for any reason.  
- "OnTimerHigh" : Triggered only when a new game starts on this level.  
- "OnTimerLow" : Triggered when the map is loaded via save game.  

# SPAWNFLAGS
- OSCILLATOR (1) : Instead of triggering the OnTimer output, will flip-flip between OnTimerHigh and OnTimerLow.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
logic_timer:ncPointTrigger
{
public:
	void logic_timer(void);
	virtual void Spawned(void);
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);

	nonvirtual void TimerEvent(void);
	nonvirtual void TimerSetup(void);

private:
	bool m_bUseRandomTime;
	float m_flRandMins;
	float m_flRandMaxs;
	float m_flRefireTime;
	bool m_bOscillator;

	string m_outputOnTimer;
	string m_outputOnTimerHigh;
	string m_outputOnTimerLow;
	entity m_eActivator;
};

void
logic_timer::logic_timer(void)
{
	m_bUseRandomTime = false;
	m_flRandMins = 0.0f;
	m_flRandMaxs = 1.0f;
	m_flRefireTime = 0.0;
	m_bOscillator = false;
	m_eActivator = this;
	m_outputOnTimer = m_outputOnTimerHigh = m_outputOnTimerLow = __NULL__;
}

void
logic_timer::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "UseRandomTime":
		m_bUseRandomTime = ReadBool(setValue);
		break;
	case "LowerRandomBound":
		m_flRandMins = ReadFloat(setValue);
		break;
	case "UpperRandomBound":
		m_flRandMaxs = ReadFloat(setValue);
		break;
	case "RefireTime":
		m_flRefireTime = ReadFloat(setValue);
		break;
	/* I/O related */
	case "OnTimer":
		m_outputOnTimer = PrepareOutput(m_outputOnTimer, setValue);
		break;
	case "OnTimerHigh":
		m_outputOnTimerHigh = PrepareOutput(m_outputOnTimerHigh, setValue);
		break;
	case "OnTimerLow":
		m_outputOnTimerLow = PrepareOutput(m_outputOnTimerLow, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
logic_timer::Spawned(void)
{
	super::Spawned();

	if (m_outputOnTimer)
		m_outputOnTimer = CreateOutput(m_outputOnTimer);
	if (m_outputOnTimerHigh)
		m_outputOnTimerHigh = CreateOutput(m_outputOnTimerHigh);
	if (m_outputOnTimerLow)
		m_outputOnTimerLow = CreateOutput(m_outputOnTimerLow);
}

void
logic_timer::Respawn(void)
{
	InitPointTrigger();

	if (TriggerEnabled()) {
		nextthink = 0.0f;
		think = __NULL__;
	} else {
		TimerSetup();
	}
}

void
logic_timer::Save(float handle)
{
	super::Save(handle);

	SaveBool(handle, "m_bUseRandomTime", m_bUseRandomTime);
	SaveFloat(handle, "m_flRandMins", m_flRandMins);
	SaveFloat(handle, "m_flRandMaxs", m_flRandMaxs);
	SaveFloat(handle, "m_flRefireTime", m_flRefireTime);
	SaveString(handle, "m_outputOnTimer", m_outputOnTimer);
	SaveString(handle, "m_outputOnTimerHigh", m_outputOnTimerHigh);
	SaveString(handle, "m_outputOnTimerLow", m_outputOnTimerLow);
	SaveBool(handle, "m_bOscillator", m_bOscillator);
	SaveEntity(handle, "m_eActivator", m_eActivator);
}

void
logic_timer::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_bUseRandomTime":
		m_bUseRandomTime = ReadBool(setValue);
		break;
	case "m_flRandMins":
		m_flRandMins = ReadFloat(setValue);
		break;
	case "m_flRandMaxs":
		m_flRandMaxs = ReadFloat(setValue);
		break;
	case "m_flRefireTime":
		m_flRefireTime = ReadFloat(setValue);
		break;
	case "m_outputOnTimer":
		m_outputOnTimer = ReadString(setValue);
		break;
	case "m_outputOnTimerHigh":
		m_outputOnTimerHigh = ReadString(setValue);
		break;
	case "m_outputOnTimerLow":
		m_outputOnTimerLow = ReadString(setValue);
		break;
	case "m_bOscillator":
		m_bOscillator = ReadBool(setValue);
		break;
	case "m_eActivator":
		m_eActivator = ReadEntity(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
logic_timer::Input(entity activatorEntity, string inputName, string dataField)
{
	switch (inputName) {
	case "RefireTime":
		m_flRefireTime = stof(dataField);
		break;
	case "ResetTimer":
		if (TriggerEnabled() == false)
			return;

		TimerSetup();
		break;
	case "FireTimer": /* force fire */
		if (TriggerEnabled() == false)
			return;

		m_eActivator = activatorEntity;
		TimerEvent();
		break;
	case "Enable":
		EnableTrigger();
		TimerSetup(); /* reset timer */
		break;
	case "Toggle":
		ToggleTrigger();

		if (TriggerEnabled())
			TimerSetup();
		break;
	case "LowerRandomBound":
		m_flRandMins = stof(dataField);
		break;
	case "UpperRandomBound":
		m_flRandMaxs = stof(dataField);
		break;
	case "AddToTimer":
		if (nextthink <= 0.0)
			nextthink += stof(dataField);
		else
			EntWarning("AddToTimer when inactive!");
		break;
	case "SubtractFromTimer":
		if (nextthink <= 0.0)
			nextthink -= stof(dataField);
		else
			EntWarning("SubtractFromTimer when inactive!");

		break;
	default:
		super::Input(activatorEntity, inputName, dataField);
	}
}

void
logic_timer::TimerSetup(void)
{
	float delay;

	if (TriggerEnabled() == false) {
		ReleaseThink();
		return;
	}

	if (m_bUseRandomTime) {
		delay = random(m_flRandMins, m_flRandMaxs);
	} else {
		delay = m_flRefireTime;
	}

	/* just in case? */
	if (delay == 0.0) {
		delay = 0.1f;
	}


	//error(sprintf("TIMER WILL GO OFF IN %f SECONDS!\n", time+delay));
	nextthink = time + delay;
	think = TimerEvent;
}

void
logic_timer::TimerEvent(void)
{
	if (TriggerEnabled() == false) {
		ReleaseThink();
		return;
	}

	//error(m_outputOnTimer);
	if (HasSpawnFlags(LOGICTIMER_OSCILLATOR)) {
		UseOutput(m_eActivator, (m_bOscillator) ? m_outputOnTimerHigh : m_outputOnTimerLow);
		m_bOscillator = (m_bOscillator) ? false : true;
		//print("FIRING %S OSCILLATING %S", m_outputOnTimerHigh, m_outputOnTimerLow));
	} else {
		UseOutput(m_eActivator, m_outputOnTimer);
		//print("FIRING %S", m_outputOnTimer));
	}

	TimerSetup(); /* repeat */
}