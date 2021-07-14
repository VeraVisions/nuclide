/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED env_global (1 0 0) (-8 -8 -8) (8 8 8) GLOBAL_SETSPAWN
Somewhat persistent storage for variables that carry over level changes.

-------- KEYS --------
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"globalstate"   The variable name in which we hold information in.
"initialstate"  Initial mode: 0 = off, 1 = on, 2 = dead
"triggermode"   Mode when triggered: 0 = off, 1 = on, 2 = dead

-------- NOTES --------
Sets/kills a global variable that carries across levels.
Without GLOBAL_SETSPAWN set, it'll only modify existing
values when triggered.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

#define GLOBAL_SETSPAWN 1

enum
{
	GLOBAL_OFF,
	GLOBAL_ON,
	GLOBAL_DEAD
};

const string CENVGLOBAL_CVAR = "env_global_data";

class env_global:CBaseTrigger
{
	string m_strGlobalState;
	int m_iTriggerMode;
	int m_iInitialState;
	
	void(void) env_global;
	virtual void(int) Trigger;
	
	virtual int(string) GlobalPresent;
	virtual void(string, int) AddNewGlobal;
	virtual void(string, int) SetGlobal;
	virtual int(string) GetGlobal;
	virtual void(string, string) SpawnKey;
};

void
env_global::Trigger(int state)
{
	int iOldValue = GetGlobal(m_strGlobalState);
	int iNewValue = 0;
	
	switch(m_iTriggerMode) {
	case 0:
		iNewValue = GLOBAL_OFF;
		break;
	case 1:
		iNewValue = GLOBAL_ON;
		break;
	case 2:
		iNewValue = GLOBAL_DEAD;
		break;
	default:
		if (iOldValue == GLOBAL_ON) {
			iNewValue = GLOBAL_OFF;
		} else if (iOldValue == GLOBAL_OFF) {
			iNewValue = GLOBAL_ON;
		} else {
			iNewValue = iOldValue;
		}
	}

	if (GlobalPresent(m_strGlobalState)) {
		SetGlobal(m_strGlobalState, iNewValue);
	} else {
		AddNewGlobal(m_strGlobalState, iNewValue);
	}
}

int
env_global::GlobalPresent(string strName)
{
	for (int i = 1; i < (tokenize(cvar_string(CENVGLOBAL_CVAR)) - 1); i += 2) {
		if (argv(i) == strName) {
			return (1);
		}
	}
	return (0);
}

void
env_global::AddNewGlobal(string strName, int iValue)
{
	cvar_set(CENVGLOBAL_CVAR, sprintf("%s %s %i", cvar_string(CENVGLOBAL_CVAR), strName, iValue));
}

void
env_global::SetGlobal(string strName, int iValue) {
	string strNewData = "";
	for (int i = 1; i < (tokenize(cvar_string(CENVGLOBAL_CVAR)) - 1); i += 2) {
		if (argv(i) != strName) {
			strNewData = sprintf("%s %s %s", strNewData, argv(i), argv(i+1));
		}
	}
	cvar_set(CENVGLOBAL_CVAR, sprintf("%s %s %i", strNewData, strName, iValue));
}

int
env_global::GetGlobal(string strName)
{
	for (int i = 1; i < (tokenize(cvar_string(CENVGLOBAL_CVAR)) - 1); i += 2) {
		if (argv(i) == strName) {
			return stoi(argv(i+1));
		}
	}
	return (0);
}

void
env_global::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "globalstate":
		m_strGlobalState = strValue;
		break;
	case "triggermode":
		m_iTriggerMode = stoi(strValue);
		break;
	case "initialstate":
		m_iInitialState = stoi(strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
env_global::env_global(void)
{
	CBaseTrigger::CBaseTrigger();

	if (!m_strGlobalState) {
		objerror("env_global: No globalstate name given! Aborting\n");
	}

	if (spawnflags & GLOBAL_SETSPAWN) {
		if (!GlobalPresent(m_strGlobalState)) {
			AddNewGlobal(m_strGlobalState, m_iInitialState);
		}
	}
}
