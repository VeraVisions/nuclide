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

/*QUAKED game_counter (0 .5 .8) (-8 -8 -8) (8 8 8) GMCNT_REMOVE GMCNT_RESET
This entity counts the number of times it has been triggered and activates its
target when it reaches a specified number.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"master" : Master entity (optional)
"killtarget" : Target to kill when triggered.
"health" : Number of times the entity has to be triggered.
"frags" : Starting value of this game_counter.

-------- SPAWNFLAGS --------
GMCNT_REMOVE : Remove permanently once it fired its target.
GMCNT_RESET : Reset internal counter to starting value once it fired its target.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	GMCNT_REMOVE,
	GMCNT_RESET
};

class game_counter:NSPointTrigger
{
	int m_iStartCount;
	int m_iCounted;
	int m_iMaxCount;

	void(void) game_counter;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity,int) Trigger;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;

	virtual int(void) GetCount;
	virtual void(int) SetCount;
};

void
game_counter::SetCount(int value)
{
	m_iCounted = value;
}

int
game_counter::GetCount(void)
{
	return m_iCounted;
}

void
game_counter::Save(float handle)
{
	SaveInt(handle, "counted", m_iCounted);
	SaveInt(handle, "maxcount", m_iMaxCount);
	SaveInt(handle, "startcount", m_iStartCount);
	super::Save(handle);
}

void
game_counter::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "counted":
		m_iCounted = ReadInt(strValue);
		break;
	case "maxcount":
		m_iMaxCount = ReadInt(strValue);
		break;
	case "startcount":
		m_iStartCount = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
game_counter::Trigger(entity act, int state)
{
	if (GetMaster() == FALSE)
		return;

	m_iCounted++;

	if (m_iCounted < m_iMaxCount)
		return;

	if (spawnflags & GMCNT_REMOVE)
		Destroy();
	else if (spawnflags & GMCNT_RESET)
		Respawn();
	else
		m_iValue = 1;

	UseTargets(act, TRIG_TOGGLE, m_flDelay);
}

void
game_counter::Respawn(void)
{
	m_iValue = 0;
	m_iCounted = m_iStartCount;
	InitPointTrigger();
}

void
game_counter::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "health":
		m_iMaxCount = stoi(strValue);
		break;
	case "frags":
		m_iStartCount = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
game_counter::game_counter(void)
{
	m_iStartCount = 0;
	super::NSPointTrigger();
}
