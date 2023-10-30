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

/*!QUAKED multisource (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
An AND-gate of sorts. Every entity that targets this must return a positive
state for it to trigger its target.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "globalstate" : env_global variable to track.
- "delay" : Delay until we trigger our target.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
multisource:NSPointTrigger
{
public:
	void multisource(void);
	
	virtual void Respawn(void);
	virtual int QueryTargets(void);
	virtual int GetValue(entity);
	virtual void Trigger(entity, triggermode_t);

};

void
multisource::multisource(void)
{
}

void
multisource::Respawn(void)
{
	m_iValue = FALSE;
}

void
multisource::Trigger(entity act, triggermode_t unused)
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

int
multisource::GetValue(entity queryingEntity)
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
			if (tTemp.GetValue(this) == FALSE) {
				dprint(" is ^1OFF^7, name: ");
				out = FALSE;
			} else {
				dprint(" is ^2ON^7, name: ");
			}
			dprint(tTemp.target);
			dprint("\n");
		} else {
			/* exit out immediately as there's no point unless in-dev */
			if (tTemp.GetValue(this) == FALSE) {
				return (0);
			}
		}
	}

	return out;
}
