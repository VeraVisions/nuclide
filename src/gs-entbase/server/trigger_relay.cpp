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

/*QUAKED trigger_relay (0 .5 .8) ? TRLY_ONCE
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"delay"         Delay til the target is triggered.
"triggerstate"  Desired state of the triggered entity.

This is an inbetween trigger that forces a desired output state
instead of toggling e.g. a door open.

When the spawnflag TRLY_ONCE is set, the trigger_relay will be removed upon
triggering its targets.
*/

enumflags
{
	TRLY_ONCE,
};

class trigger_relay:CBaseTrigger
{
	int m_iTriggerState;
	int m_iEnabled;

	void(void) trigger_relay;
	virtual void(int) Trigger;
	virtual void(void) Respawn;
};

void
trigger_relay::Trigger(int state)
{
	if (m_iEnabled == FALSE)
		return;
	if (spawnflags & TRLY_ONCE)
		m_iEnabled = FALSE;

	if (m_flDelay > 0) {
		CBaseTrigger::UseTargets_Delay(m_iTriggerState, m_flDelay);
	} else {
		CBaseTrigger::UseTargets(m_iTriggerState);
	}
}

void
trigger_relay::Respawn(void)
{
	m_iEnabled = TRUE;
}

void
trigger_relay::trigger_relay(void)
{
	CBaseTrigger::CBaseTrigger();

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "delay":
			m_flDelay = stof(argv(i+1));
			break;
		case "triggerstate":
			m_iTriggerState = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}
}
