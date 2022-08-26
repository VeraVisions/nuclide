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

/*QUAKED trigger_auto (1 0 0) (-8 -8 -8) (8 8 8) TA_USEONCE
Will automatically trigger its target when the level has spawned.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"delay" : Time in seconds until it triggers its target.

-------- SPAWNFLAGS --------
TA_USEONCE : Remove itself from the level permanently when activated.

-------- NOTES --------
When a trigger_auto is removed via TA_USEONCE it won't survive match respawns.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class
trigger_auto:NSPointTrigger
{
	int m_iTriggerState;
	float m_flDelay;

	void(void) trigger_auto;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(string, string) SpawnKey;
	virtual void(void) Respawn;
	virtual void(void) RestoreComplete;

	virtual void(void) Processing;
};

void
trigger_auto::trigger_auto(void)
{
	/* default is always toggle */
	m_iTriggerState = TRIG_TOGGLE;
	m_flDelay = 0.0f;
}

void
trigger_auto::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iTriggerState", m_iTriggerState);
	SaveFloat(handle, "m_flDelay", m_flDelay);
}

void
trigger_auto::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iTriggerState":
		m_iTriggerState = ReadInt(strValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_auto::RestoreComplete(void)
{
	ScheduleThink(Processing, 0.25f);
}

void
trigger_auto::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "triggerstate":
		m_iTriggerState = stoi(strValue);
		break;
	case "delay":
		m_flDelay = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_auto::Respawn(void)
{
	InitPointTrigger();

	/* deliberately add a bit more time in case we're first in the ent-lump */
	ScheduleThink(Processing, 0.25f);
}

void
trigger_auto::Processing(void)
{
	if (m_strGlobalState)
		if (GetGlobalValue(m_strGlobalState) == 0)
			return;

	UseTargets(this, m_iTriggerState, m_flDelay);
	print(sprintf("%S %i %f\n", target, m_iTriggerState, m_flDelay));

	if (HasSpawnFlags(1)) {
		NSLog("^2trigger_auto::^3Processing^7: %s triggerer removed self",  target);
		remove(this);
	}
}
