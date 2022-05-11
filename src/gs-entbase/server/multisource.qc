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

/*QUAKED multisource (1 0 0) (-8 -8 -8) (8 8 8)
An AND-gate of sorts. Every entity that targets this must return a positive
state for it to trigger its target.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"globalstate" : env_global variable to track.
"delay" : Delay until we trigger our target.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class multisource:NSPointTrigger
{
	string m_strGlobalState;

	void(void) multisource;

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(void) Respawn;
	virtual int(void) QueryTargets;
	virtual int(void) GetValue;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
multisource::Save(float handle)
{
	SaveString(handle, "globalstate", m_strGlobalState);
	super::Save(handle);
}

void
multisource::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "globalstate":
		m_strGlobalState = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

int
multisource::GetValue(void)
{
	return QueryTargets();
}

int
multisource::QueryTargets(void)
{
	entity a;
	int out = TRUE;

	/* ENV_GLOBAL QUERY */
	if (m_strGlobalState)
		if (GetGlobalValue(m_strGlobalState) == 0)
			return FALSE;
		else
			return TRUE;

	/* normal triggers */
	for (a = world; (a = find(a, ::target, targetname));) {
		NSEntity tTemp = (NSEntity) a;
		if (cvar("developer") == 1) {
			dprint("[^1MULTISOURCE^7] ");
			dprint(tTemp.classname);
			if (tTemp.GetValue() == FALSE) {
				dprint(" is ^1OFF^7, name: ");
				out = FALSE;
			} else {
				dprint(" is ^2ON^7, name: ");
			}
			dprint(tTemp.target);
			dprint("\n");
		} else {
			/* exit out immediately as there's no point unless in-dev */
			if (tTemp.GetValue() == FALSE) {
				return (0);
			}
		}
	}

	return out;
}

void
multisource::Trigger(entity act, int unused)
{
	if (QueryTargets() == FALSE) {
		NSLog("[^1MULTISOURCE^7] %s is inactive.", targetname);
		m_iValue = FALSE;
		return;
	}

	NSLog("[^1MULTISOURCE^7] %s is now active.", targetname);
	m_iValue = TRUE;
	UseTargets(act, TRIG_TOGGLE, m_flDelay);
}

void
multisource::Respawn(void)
{
	m_iValue = FALSE;
}

void
multisource::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "globalstate":
		m_strGlobalState = strValue;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
multisource::multisource(void)
{
	m_strGlobalState = __NULL__;
	super::NSPointTrigger();
}
