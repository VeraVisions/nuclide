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

class
logic_timer:NSPointTrigger
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
	bool m_bStartDisabled;
	bool m_bOscillator;

	string m_strOnTimer;
	string m_strOnTimerHigh;
	string m_strOnTimerLow;
	bool m_bEnabled;
	entity m_eActivator;
};

void
logic_timer::logic_timer(void)
{
	m_bUseRandomTime = false;
	m_flRandMins = 0.0f;
	m_flRandMaxs = 1.0f;
	m_flRefireTime = 0.0;
	m_bStartDisabled = false;
	m_bOscillator = false;
	m_bEnabled = true;
	m_eActivator = this;
	m_strOnTimer = m_strOnTimerHigh = m_strOnTimerLow = __NULL__;
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
	case "StartDisabled":
		m_bStartDisabled = ReadBool(setValue);
		break;
	/* I/O related */
	case "OnTimer":
		m_strOnTimer = PrepareOutput(m_strOnTimer, setValue);
		break;
	case "OnTimerHigh":
		m_strOnTimerHigh = PrepareOutput(m_strOnTimerHigh, setValue);
		break;
	case "OnTimerLow":
		m_strOnTimerLow = PrepareOutput(m_strOnTimerLow, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
logic_timer::Spawned(void)
{
	super::Spawned();

	if (m_strOnTimer)
		m_strOnTimer = CreateOutput(m_strOnTimer);
	if (m_strOnTimerHigh)
		m_strOnTimerHigh = CreateOutput(m_strOnTimerHigh);
	if (m_strOnTimerLow)
		m_strOnTimerLow = CreateOutput(m_strOnTimerLow);
}

void
logic_timer::Respawn(void)
{
	InitPointTrigger();

	if (m_bStartDisabled) {
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
	SaveBool(handle, "m_bStartDisabled", m_bStartDisabled);
	SaveString(handle, "m_strOnTimer", m_strOnTimer);
	SaveString(handle, "m_strOnTimerHigh", m_strOnTimerHigh);
	SaveString(handle, "m_strOnTimerLow", m_strOnTimerLow);
	SaveBool(handle, "m_bOscillator", m_bOscillator);
	SaveBool(handle, "m_bEnabled", m_bEnabled);
	SaveEntity(handle, "m_eActivator", m_eActivator);
}

void
logic_timer::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_bUseRandomTime":
		m_bUseRandomTime = ReadBool(strValue);
		break;
	case "m_flRandMins":
		m_flRandMins = ReadFloat(strValue);
		break;
	case "m_flRandMaxs":
		m_flRandMaxs = ReadFloat(strValue);
		break;
	case "m_flRefireTime":
		m_flRefireTime = ReadFloat(strValue);
		break;
	case "m_bStartDisabled":
		m_bStartDisabled = ReadBool(strValue);
		break;
	case "m_strOnTimer":
		m_strOnTimer = ReadString(strValue);
		break;
	case "m_strOnTimerHigh":
		m_strOnTimerHigh = ReadString(strValue);
		break;
	case "m_strOnTimerLow":
		m_strOnTimerLow = ReadString(strValue);
		break;
	case "m_bOscillator":
		m_bOscillator = ReadBool(strValue);
		break;
	case "m_bEnabled":
		m_bEnabled = ReadBool(strValue);
		break;
	case "m_eActivator":
		m_eActivator = ReadEntity(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
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
		if (m_bEnabled == false)
			return;

		TimerSetup();
		break;
	case "FireTimer": /* force fire */
		if (m_bEnabled == false)
			return;

		m_eActivator = activatorEntity;
		TimerEvent();
		break;
	case "Enable":
		m_bEnabled = true;
		TimerSetup(); /* reset timer */
		break;
	case "Disable":
		m_bEnabled = false;
		break;
	case "Toggle":
		m_bEnabled = (m_bEnabled) ? false : true;

		if (m_bEnabled)
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
			NSEntWarning("AddToTimer when inactive!");
		break;
	case "SubtractFromTimer":
		if (nextthink <= 0.0)
			nextthink -= stof(dataField);
		else
			NSEntWarning("SubtractFromTimer when inactive!");

		break;
	default:
		super::Input(activatorEntity, inputName, dataField);
	}
}

void
logic_timer::TimerSetup(void)
{
	float delay;

	if (m_bEnabled == false) {
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
	if (m_bEnabled == false) {
		ReleaseThink();
		return;
	}

	//error(m_strOnTimer);
	if (HasSpawnFlags(LOGICTIMER_OSCILLATOR)) {
		UseOutput(m_eActivator, (m_bOscillator) ? m_strOnTimerHigh : m_strOnTimerLow);
		m_bOscillator = (m_bOscillator) ? false : true;
		//print("FIRING %S OSCILLATING %S", m_strOnTimerHigh, m_strOnTimerLow));
	} else {
		UseOutput(m_eActivator, m_strOnTimer);
		//print("FIRING %S", m_strOnTimer));
	}

	TimerSetup(); /* repeat */
}