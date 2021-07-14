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
This entity counts the number of times it is triggered and activates its
target when it reaches a specified number.

-------- KEYS --------
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"count"         Number of times the entity has to be triggered.
"delay"         Delay in seconds until target is triggered.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
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
	virtual void(string, string) SpawnKey;
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

	dprint("^2trigger_counter::^3Trigger^7: " \
	       "Incremented '%s' by 1 (%i/%i)\n", \
	       targetname, m_iCounted, m_iMaxCount);

	if (m_iCounted < m_iMaxCount)
		return;

	SetSolid(SOLID_NOT); /* make inactive */
	m_iValue = 1;

	UseTargets(act, TRIG_TOGGLE, m_flDelay);
}

void
trigger_counter::Respawn(void)
{
	m_iValue = 0;
	m_iCounted = 0;
	solid = SOLID_TRIGGER;

#ifdef GS_RENDERFX
	SetRenderMode(RM_TRIGGER);
#endif

	InitBrushTrigger();
}

void
trigger_counter::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "count":
		m_iMaxCount = stoi(strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
trigger_counter::trigger_counter(void)
{
	CBaseTrigger::CBaseTrigger();
}
