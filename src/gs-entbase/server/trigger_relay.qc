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
	TRLY_ONCE,
};

/*!QUAKED trigger_relay (.5 .5 .5) ? TRLY_ONCE
# OVERVIEW
This is an in-between trigger that forces a desired output state
instead of toggling e.g. a door open.

# KEYS
- "targetname" : Name
- "target" : Target to trigger.
- "triggerstate" : Desired state of the triggered entity.
- "delay" : Delay til the target is triggered, in seconds.
- "killtarget" : Target to remove when triggered.

# SPAWNFLAGS
- TRLY_ONCE (1) : When set, this entity will be removed upon triggering its targets.

# NOTES
The `triggerstate` key can be one of three things:
- 0: Off
- 1: On
- 2: Toggle

Where 'off' will close entities like func_door, and 'on' will open them.

# TRIVIA
This entity was introduced in Quake (1996).
*/
class
trigger_relay:NSPointTrigger
{
public:
	void trigger_relay(void);

	virtual void Trigger(entity,triggermode_t);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);

	virtual void Save(float);
	virtual void Restore(string,string);

private:
	triggermode_t m_iTriggerState;
	int m_iEnabled;
};

void
trigger_relay::trigger_relay(void)
{
	m_iTriggerState = 0;
	m_iEnabled = 0;
}

void
trigger_relay::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_iTriggerState", m_iTriggerState);
	SaveInt(handle, "m_iEnabled", m_iEnabled);
}

void
trigger_relay::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iTriggerState":
		m_iTriggerState = ReadFloat(strValue);
		break;
	case "m_iEnabled":
		m_iEnabled = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_relay::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "triggerstate":
		m_iTriggerState = ReadInt(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_relay::Respawn(void)
{
	m_iEnabled = TRUE;
	m_iValue = FALSE;
}

void
trigger_relay::Trigger(entity act, triggermode_t state)
{
	if (m_iEnabled == FALSE) {
		NSLog("trigger_relay (%s) has already been triggered", targetname);
		return;
	}

	if (HasSpawnFlags(TRLY_ONCE)) {
		m_iEnabled = FALSE;
	}

	m_iValue = TRUE;
	NSLog("trigger_relay (%s) will trigger %s with state %d", targetname, target, m_iTriggerState);
	UseTargets(act, m_iTriggerState, m_flDelay);
}
