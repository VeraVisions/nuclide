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

enumflags
{
    TRCNT_SILENT,
    TRCNT_NOCLIENTS,
    TRCNT_PUSHABLES
};

/*! \brief Server-Entity: Activation Count Based Trigger */
/*!QUAKED trigger_counter (.5 .5 .5) ? TRCNT_SILENT TRCNT_NOCLIENTS TRCNT_PUSHABLES
# OVERVIEW
This entity counts the number of times it has been triggered and activates its
target when it reaches a specified number.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "count" : Number of times the entity has to be triggered.
- "delay" : Delay in seconds until target is triggered.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup serverentity
@ingroup brushentity
*/
class
trigger_counter:ncBrushTrigger
{
public:
	void trigger_counter(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Touch(entity);

private:
	int m_iCounted;
	int m_iMaxCount;
};

void
trigger_counter::trigger_counter(void)
{
	m_iCounted = 0;
	m_iMaxCount = 0;
}

void
trigger_counter::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iCounted", m_iCounted);
	SaveInt(handle, "m_iMaxCount", m_iMaxCount);
}

void
trigger_counter::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_iCounted":
		m_iCounted = ReadInt(setValue);
		break;
	case "m_iMaxCount":
		m_iMaxCount = ReadInt(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
trigger_counter::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "count":
		m_iMaxCount = stoi(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
trigger_counter::Respawn(void)
{
	InitBrushTrigger();
	SetValue(0i);
	m_iCounted = 0;
}

void
trigger_counter::Trigger(entity act, triggermode_t state)
{
	if (act.classname == "func_pushable" && !HasSpawnFlags(TRCNT_PUSHABLES))
		return;
	if (HasSpawnFlags(TRCNT_NOCLIENTS) && act.flags & FL_CLIENT)
		return;
	if (GetMaster(act) == FALSE)
		return;

	m_iCounted++;

	EntLog("Incremented '%s' by 1 (%i/%i)\n", targetname, m_iCounted, m_iMaxCount);

	if (m_iCounted < m_iMaxCount)
		return;

	SetSolid(SOLID_NOT); /* make inactive */
	SetValue(1i);

	UseTargets(act, TRIG_TOGGLE, GetTriggerDelay());
}

void
trigger_counter::Touch(entity eToucher)
{
	Trigger(eToucher, TRIG_TOGGLE);
}
