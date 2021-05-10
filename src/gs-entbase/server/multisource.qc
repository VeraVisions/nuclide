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

/*QUAKED multisource (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"delay"         Delay until we trigger our target

STUB!

Trivia:
This entity was introduced in Half-Life (1998).
*/

class multisource:CBaseTrigger
{
	void(void) multisource;

	virtual void(void) Respawn;
	virtual int(void) QueryTargets;
	virtual void(entity, int) Trigger;
};

int
multisource::QueryTargets(void)
{
	entity a;
	int out = TRUE;

	/* normal triggers */
	for (a = world; (a = find(a, ::target, targetname));) {
		CBaseTrigger tTemp = (CBaseTrigger) a;
		if (cvar("developer") == 1) {
			dprint("[^1MULTISOURCE^7] ");
			dprint(tTemp.classname);
			if (tTemp.GetValue() == FALSE) {
				dprint(" is ^1OFF^7, name: ");
				out = FALSE;
			} else {
				dprint(" is ^2ON^7, name: ");
			}
			dprint(tTemp.targetname);
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
		dprint(sprintf("[^1MULTISOURCE^7] %s is inactive.\n", targetname));
		m_iValue = FALSE;
		return;
	}

	dprint(sprintf("[^1MULTISOURCE^7] %s is now active.\n", targetname));
	m_iValue = TRUE;
	UseTargets(act, TRIG_TOGGLE, m_flDelay);
}

void
multisource::Respawn(void)
{
	m_iValue = FALSE;
}

void
multisource::multisource(void)
{
	CBaseTrigger::CBaseTrigger();
}
