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

/*QUAKED trigger_counter (0 .5 .8) ? TRCNT_SILENT TRCNT_NOCLIENTS TRCNT_PUSHABLES
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"delay"         Delay until target is triggered.

This entity counts the number of times it is triggered and activates its
target when it reaches a specified number.
*/

enumflags
{
    TRCNT_SILENT,
    TRCNT_NOCLIENTS,
    TRCNT_PUSHABLES
};

class trigger_counter:CBaseTrigger
{
	int m_iCounted;
	int m_iMaxCount;

	void(void) trigger_counter;

	virtual void(void) touch;
	virtual void(entity,int) Trigger;
	virtual void(void) Respawn;
};

void
trigger_counter::touch(void)
{
	Trigger(other, TRIG_TOGGLE);
}

void
trigger_counter::Trigger(entity act, int state)
{
	if (act.classname == "func_pushable" && !(spawnflags & TRCNT_PUSHABLES))
		return;
	if (spawnflags & TRCNT_NOCLIENTS && act.spawnflags & FL_CLIENT)
		return;
	if (GetMaster() == FALSE)
		return;

	m_iCounted++;

	print("^2trigger_counter::^3Trigger^7: " \
	       "Incremented '%s' by 1 (%i/%i)\n", \
	       m_strTargetName, m_iCounted, m_iMaxCount);

	if (m_iCounted < m_iMaxCount)
		return;

	solid = SOLID_NOT; /* make inactive */
	m_iValue = 1;

	if (m_flDelay > 0) {
		CBaseTrigger::UseTargets_Delay(act, TRIG_TOGGLE, m_flDelay);
	} else {
		CBaseTrigger::UseTargets(act, TRIG_TOGGLE);
	}
}

void
trigger_counter::Respawn(void)
{
	m_iValue = 0;
	m_iCounted = 0;
	solid = SOLID_TRIGGER;
	SetRenderMode(RM_TRIGGER);
	InitBrushTrigger();
}

void
trigger_counter::trigger_counter(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "count":
			m_iMaxCount = stoi(argv(i+1));
			break;
		case "delay":
			m_flDelay = stof(argv(i+1));
			break;
		default:
			break;
		}
	}

	CBaseTrigger::CBaseTrigger();
}
