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

/*!QUAKED game_counter_set (0 .5 .8) (-8 -8 -8) (8 8 8) GMCNTS_REMOVE
# OVERVIEW
When triggered, it'll change the internal counter of its target (a game_counter)
to the specified value within.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "master" : Master entity (optional)
- "frags" : New value of the target game_counter.

# SPAWNFLAGS
- GMCNT_REMOVE (1) : Remove permanently once it fired its target.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
enumflags
{
	GMCNTS_REMOVE,
};

class
game_counter_set:NSPointTrigger
{
public:
	void game_counter_set(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);

private:
	int m_iCount;
};

void
game_counter_set::game_counter_set(void)
{
	m_iCount = 0i;
}

void
game_counter_set::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iCount", m_iCount);
}

void
game_counter_set::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iCount":
		m_iCount = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
game_counter_set::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "frags":
		m_iCount = ReadInt(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
game_counter_set::Respawn(void)
{
	InitPointTrigger();
}

void
game_counter_set::Trigger(entity act, triggermode_t state)
{
	if (GetMaster(act) == FALSE)
		return;

	EntLog("%s's manipulating %s to be %i", targetname, target, m_iCount);

	/* apply the value to all the relevant game_counter entities */
	for (entity f = world; (f = find(f, ::targetname, target));) {
		game_counter targ;

		/* just to be safe */
		if (f.classname != "game_counter")
			continue;
		
		targ = (game_counter)f;
		targ.SetCount(m_iCount);
	}

	if (HasSpawnFlags(GMCNTS_REMOVE))
		Destroy();
}
