/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

/*! \brief Server-Entity: Map Start Trigger */
/*!QUAKED trigger_auto (.5 .5 .5) (-8 -8 -8) (8 8 8) TA_USEONCE
# OVERVIEW
Will automatically trigger its target when the level has spawned.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "delay" : Time in seconds until it triggers its target.

# SPAWNFLAGS
- TA_USEONCE (1) : Remove itself from the level permanently when activated.

# NOTES
When a trigger_auto is removed via TA_USEONCE it won't survive match respawns.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/

class
trigger_auto:ncPointTrigger
{
public:
	void trigger_auto(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void RestoreComplete(void);
	
	nonvirtual void Processing(void);

private:
	triggermode_t m_iTriggerState;
	float m_flDelay;
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
	SaveFloat(handle, "m_iTriggerState", m_iTriggerState);
	SaveFloat(handle, "m_flDelay", m_flDelay);
}

void
trigger_auto::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_iTriggerState":
		m_iTriggerState = ReadFloat(setValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
trigger_auto::RestoreComplete(void)
{
	//ScheduleThink(Processing, 0.0f);
}

void
trigger_auto::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "triggerstate":
		m_iTriggerState = stof(setValue);
		break;
	case "delay":
		m_flDelay = stof(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
trigger_auto::Spawned(void)
{
	super::Spawned();

	/* needs to be set here, as game invoked respawns
	   generally should not affect trigger_auto */
	SetValue(1);
}

void
trigger_auto::Respawn(void)
{
	InitPointTrigger();

	if (GetValue(this) == 1) {
		return;
	}

	/* deliberately add a bit more time in case we're first in the ent-lump
		also we'll only do this in multiplayer games. SP games will call
	    trigger_auto_trigger() for when one player has fully joined */
	if (cvar("sv_playerslots") > 1) {
		ScheduleThink(Processing, 0.25f);
	}
}

void
trigger_auto::Processing(void)
{
	if (STRING_SET(m_globalState)) {
		if (GetGlobalValue(m_globalState) == 0) {
			return;
		}
	}

	UseTargets(this, m_iTriggerState, m_flDelay);
	//print(sprintf("%S %d %f %f\n", target, m_iTriggerState, m_flDelay, time));

	if (HasSpawnFlags(1)) {
		EntLog("Trigger instructed to destroy itself.");
		SetValue(0);
	}
}

void
trigger_auto_trigger(void)
{
	static bool called = false;
	trigger_auto loop;

	/* don't do it more than once */
	if (called) {
		return;
	}

	for (loop = __NULL__; (loop = (trigger_auto)find(loop, ::classname, "trigger_auto"));) {
		loop.ScheduleThink(trigger_auto::Processing, 0.25f);
	}

	called = true;
}
