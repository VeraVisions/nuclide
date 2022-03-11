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

/*QUAKED trigger_relay (0 .5 .8) ? TRLY_ONCE
This is an inbetween trigger that forces a desired output state
instead of toggling e.g. a door open.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"delay" : Delay til the target is triggered.
"triggerstate" : Desired state of the triggered entity.

-------- SPAWNFLAGS --------
TRLY_ONCE : Will be removed upon triggering its targets.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

enumflags
{
	TRLY_ONCE,
};

class trigger_relay:NSPointTrigger
{
	int m_iTriggerState;
	int m_iEnabled;

	void(void) trigger_relay;

	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
trigger_relay::Save(float handle)
{
	SaveInt(handle, "trigger_state", m_iTriggerState);
	SaveInt(handle, "enabled", m_iEnabled);
	super::Save(handle);
}

void
trigger_relay::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "trigger_state":
		m_iTriggerState = ReadInt(strValue);
		break;
	case "enabled":
		m_iEnabled = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_relay::Trigger(entity act, int state)
{
	if (m_iEnabled == FALSE)
		return;
	if (spawnflags & TRLY_ONCE)
		m_iEnabled = FALSE;

	UseTargets(act, m_iTriggerState, m_flDelay);
}

void
trigger_relay::Respawn(void)
{
	m_iEnabled = TRUE;
}

void
trigger_relay::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "triggerstate":
		m_iTriggerState = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_relay::trigger_relay(void)
{
	super::NSPointTrigger();
}
