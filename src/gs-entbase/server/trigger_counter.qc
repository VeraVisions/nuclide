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

/*QUAKED trigger_counter (0 .5 .8) ? TRCNT_SILENT TRCNT_NOCLIENTS TRCNT_PUSHABLES
This entity counts the number of times it has been triggered and activates its
target when it reaches a specified number.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"count" : Number of times the entity has to be triggered.
"delay" : Delay in seconds until target is triggered.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

enumflags
{
    TRCNT_SILENT,
    TRCNT_NOCLIENTS,
    TRCNT_PUSHABLES
};

class trigger_counter:NSBrushTrigger
{
	int m_iCounted;
	int m_iMaxCount;

	void(void) trigger_counter;

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity) Touch;
	virtual void(entity,int) Trigger;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
trigger_counter::Save(float handle)
{
	SaveInt(handle, "counted", m_iCounted);
	SaveInt(handle, "maxcount", m_iMaxCount);
	super::Save(handle);
}

void
trigger_counter::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "counted":
		m_iCounted = ReadInt(strValue);
		break;
	case "maxcount":
		m_iMaxCount = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_counter::Touch(entity eToucher)
{
	Trigger(eToucher, TRIG_TOGGLE);
}

void
trigger_counter::Trigger(entity act, int state)
{
	if (act.classname == "func_pushable" && !HasSpawnFlags(TRCNT_PUSHABLES))
		return;
	if (HasSpawnFlags(TRCNT_NOCLIENTS) && act.flags & FL_CLIENT)
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
	SetSolid(SOLID_TRIGGER);

#ifdef GS_RENDERFX
	//SetRenderMode(RM_TRIGGER);
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
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_counter::trigger_counter(void)
{
	m_iCounted = 0;
	m_iMaxCount = 0;
}
