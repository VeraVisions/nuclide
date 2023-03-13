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
*/
class
env_global:NSPointTrigger
{
	int m_iTriggerMode;
	int m_iInitialState;
	
public:
	void env_global(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void SpawnKey(string, string);
	virtual void Spawned(void);
	virtual void Trigger(entity, triggermode_t);
	
	virtual int GlobalPresent(string);
	virtual void AddNewGlobal(string, globalstate_t);
	virtual void SetGlobal(string, globalstate_t);

};

void
env_global::env_global(void)
{
	m_strGlobalState = __NULL__;
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
env_global::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iTriggerMode":
		m_iTriggerMode = ReadInt(strValue);
		break;
	case "m_iInitialState":
		m_iInitialState = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_global::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "triggermode":
		m_iTriggerMode = stoi(strValue);
		break;
	case "initialstate":
		m_iInitialState = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_global::Spawned(void)
{
	super::Spawned();

	if (!m_strGlobalState) {
		objerror("env_global: No globalstate name given! Aborting\n");
	}

	if (HasSpawnFlags(GLOBAL_SETSPAWN)) {
		if (!GlobalPresent(m_strGlobalState)) {
			AddNewGlobal(m_strGlobalState, m_iInitialState);
		}
	}
}

void
env_global::Trigger(entity act, triggermode_t state)
{
	globalstate_t iOldValue = GetGlobalValue(m_strGlobalState);
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

	if (GlobalPresent(m_strGlobalState)) {
		SetGlobal(m_strGlobalState, newValue);
	} else {
		AddNewGlobal(m_strGlobalState, newValue);
	}
}

int
env_global::GlobalPresent(string strName)
{
	for (int i = 0; i < (tokenize(cvar_string(CENVGLOBAL_CVAR))); i += 2) {
		if (argv(i) == strName) {
			return (1);
		}
	}
	return (0);
}

void
env_global::AddNewGlobal(string strName, globalstate_t newValue)
{
	print("AddNewGLobal\n");
	localcmd(sprintf("set %s \"%s %s %d\"\n", CENVGLOBAL_CVAR, cvar_string(CENVGLOBAL_CVAR), strName, newValue));
}

void
env_global::SetGlobal(string strName, globalstate_t newValue)
{
	string strNewData = "";
	print("SetGlobal\n");
	for (int i = 0; i < (tokenize(cvar_string(CENVGLOBAL_CVAR))); i += 2) {
		if (argv(i) != strName) {
			strNewData = sprintf("%s %s %s", strNewData, argv(i), argv(i+1));
		}
	}
	localcmd(sprintf("set %s \"%s %s %d\"\n", CENVGLOBAL_CVAR, strNewData, strName, newValue));
}
