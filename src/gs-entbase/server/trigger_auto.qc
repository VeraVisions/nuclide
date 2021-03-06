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

class trigger_auto:CBaseTrigger
{
	int m_iTriggerState;
	float m_flDelay;

	void(void) trigger_auto;
	virtual void(void) Processing;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
trigger_auto::Processing(void)
{
	UseTargets(this, m_iTriggerState, m_flDelay);

	if (spawnflags & 1) {
		dprint(sprintf("^2trigger_auto::^3think^7: %s triggerer removed self\n",  target));
		remove(this);
	}
}

void
trigger_auto::Respawn(void)
{
	think = Processing;
	nextthink = time + 0.2f;
}

void
trigger_auto::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "triggerstate":
		m_iTriggerState = stoi(strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
trigger_auto::trigger_auto(void)
{
	/* default is always toggle */
	m_iTriggerState = TRIG_TOGGLE;

	CBaseTrigger::CBaseTrigger();
}
