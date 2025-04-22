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

#define GLOBAL_SETSPAWN 1

/*! \brief Server-Entity: Global Variable Controller */
/*!QUAKED env_global (1 .5 0) (-8 -8 -8) (8 8 8) GLOBAL_SETSPAWN
# OVERVIEW
Persistent storage for variables that carry over level changes.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "globalstate" : The variable name in which we hold information in.
- "initialstate" : Initial mode: 0 = off, 1 = on, 2 = dead
- "triggermode" : Mode when triggered: 0 = off, 1 = on, 2 = dead

# SPAWNFLAGS
- GLOBAL_SETSPAWN (1) : Without this set, it'll only modify existing variables.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
env_global:ncPointTrigger
{	
public:
	void env_global(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void SpawnKey(string, string);
	virtual void Spawned(void);
	virtual void Trigger(entity, triggermode_t);

	nonvirtual void SetGlobal(string, globalstate_t);

private:
	int m_iTriggerMode;
	int m_iInitialState;
};

void
env_global::env_global(void)
{
	m_globalState = __NULL__;
	m_iTriggerMode = 0;
	m_iInitialState = 0;
}

void
env_global::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iTriggerMode", m_iTriggerMode);
	SaveInt(handle, "m_iInitialState", m_iInitialState);
}

void
env_global::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_iTriggerMode":
		m_iTriggerMode = ReadInt(setValue);
		break;
	case "m_iInitialState":
		m_iInitialState = ReadInt(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_global::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "triggermode":
		m_iTriggerMode = stoi(setValue);
		break;
	case "initialstate":
		m_iInitialState = stoi(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
env_global::Spawned(void)
{
	super::Spawned();

	if (!m_globalState) {
		objerror("env_global: No globalstate name given! Aborting\n");
	}

	if (HasSpawnFlags(GLOBAL_SETSPAWN)) {
		SetGlobal(m_globalState, m_iInitialState);
	}
}

void
env_global::Trigger(entity act, triggermode_t state)
{
	globalstate_t iOldValue = GetGlobalValue(m_globalState);
	globalstate_t newValue = 0;
	
	switch(m_iTriggerMode) {
	case 0:
		newValue = GLOBAL_OFF;
		break;
	case 1:
		newValue = GLOBAL_ON;
		break;
	case 2:
		newValue = GLOBAL_DEAD;
		break;
	default:
		if (iOldValue == GLOBAL_ON) {
			newValue = GLOBAL_OFF;
		} else if (iOldValue == GLOBAL_OFF) {
			newValue = GLOBAL_ON;
		} else {
			newValue = iOldValue;
		}
	}

	SetGlobal(m_globalState, newValue);
}

void
env_global::SetGlobal(string strName, globalstate_t newValue)
{
	switch (newValue) {
	case GLOBAL_ON:
		ncSessionManager::SetGlobal(strName, "1");
		break;
	case GLOBAL_OFF:
		ncSessionManager::SetGlobal(strName, "0");
		break;
	case GLOBAL_DEAD:
	default:
		ncSessionManager::SetGlobal(strName, "");
	}
}
