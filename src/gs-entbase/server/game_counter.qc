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
	GMCNT_REMOVE,
	GMCNT_RESET
};

/*! \brief Server-Entity: Activation Count Based Trigger */
/*!QUAKED game_counter (0 .5 .8) (-8 -8 -8) (8 8 8) GMCNT_REMOVE GMCNT_RESET
# OVERVIEW
This entity counts the number of times it has been triggered and activates its
target when it reaches a specified number.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "master" : Master entity (optional)
- "killtarget" : Target to kill when triggered.
- "health" : Number of times the entity has to be triggered.
- "frags" : Starting value of this game_counter.

# SPAWNFLAGS
- GMCNT_REMOVE (1) : Remove permanently once it fired its target.
- GMCNT_RESET (2) : Reset internal counter to starting value once it fired its target.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
game_counter:ncPointTrigger
{
public:
	void game_counter(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	
	nonvirtual int GetCount(void);
	nonvirtual void SetCount(int);

private:
	int m_iStartCount;
	int m_iCounted;
	int m_iMaxCount;
};

void
game_counter::game_counter(void)
{
	m_iStartCount = 0i;
	m_iCounted = 0i;
	m_iMaxCount = 0i;
}

void
game_counter::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iCounted", m_iCounted);
	SaveInt(handle, "m_iMaxCount", m_iMaxCount);
	SaveInt(handle, "m_iStartCount", m_iStartCount);
}

void
game_counter::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_iCounted":
		m_iCounted = ReadInt(setValue);
		break;
	case "m_iMaxCount":
		m_iMaxCount = ReadInt(setValue);
		break;
	case "m_iStartCount":
		m_iStartCount = ReadInt(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
game_counter::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "health":
		m_iMaxCount = stoi(setValue);
		break;
	case "frags":
		m_iStartCount = stoi(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
game_counter::Respawn(void)
{
	SetValue(0i);
	m_iCounted = m_iStartCount;
	InitPointTrigger();
}

void
game_counter::SetCount(int value)
{
	EntLog("%s's count set to %i", targetname, value);
	m_iCounted = value;
}

int
game_counter::GetCount(void)
{
	return m_iCounted;
}

void
game_counter::Trigger(entity act, triggermode_t state)
{
	if (GetMaster(act) == FALSE)
		return;

	EntLog("%s's incremented by 1", targetname);
	m_iCounted++;

	if (m_iCounted < m_iMaxCount)
		return;

	EntLog("%s's triggering %s", targetname, target);
	//print(sprintf("%s %s %i %i\n", classname, targetname, m_iCounted, m_iMaxCount ));
	//error(sprintf("%s %i %i\n", act.classname, m_iCounted, m_iMaxCount ));
	UseTargets(act, TRIG_TOGGLE, GetTriggerDelay());

	if (HasSpawnFlags(GMCNT_REMOVE))
		Destroy();
	else if (HasSpawnFlags(GMCNT_RESET))
		Respawn();
	else
		SetValue(1i);

}
