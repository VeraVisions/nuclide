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
	MMF_STARTON,
	MMF_UNUSED1,
	MMF_NONTOGGLE,
	MMF_MONSTERCLIP
};

/*! \brief Server-Entity: Monster Spawner */
/*!QUAKED monstermaker (1 0 0) (-8 -8 -8) (8 8 8) MMF_STARTON x MMF_NONTOGGLE MMF_MONSTERCLIP
# OVERVIEW
The monster maker is the end-all solution to timed/controlled spawning of
monster entities.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "monstertype" : Type of monster to spawn, represents their entity classname.
- "monstercount" : Maximum amount of monsters you want spawned in total.
- "delay" : Delay between spawns in seconds.
- "child_name" : Applies this as a 'targetname' to spawned monsters.
- "child_alivemax" : Maximum amount of spawned monsters that are alive at a time.

# SPAWNFLAGS
- MMF_STARTON (1) : Start on automatically.
- MMF_NONTOGGLE (2) : Spawn only one monster with each trigger.
- MMF_MONSTERCLIP (4) : Spawned monsters will be blocked by func_monsterclip entities.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
monstermaker:ncPointTrigger
{
public:
	void monstermaker(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	
	nonvirtual void Spawner(void);
	nonvirtual void TurnOn(void);
	nonvirtual void TurnOff(void);

private:
	string m_strMonster;
	string m_strChildName;
	int m_iMonsterSpawned;
	int m_iTotalMonsters;
	int m_iMaxChildren;
	float m_flDelay;
};

void
monstermaker::monstermaker(void)
{
	m_strMonster = __NULL__;
	m_strChildName = __NULL__;
	m_iMonsterSpawned = 0i;
	m_iTotalMonsters = 0i;
	m_iMaxChildren = 0i;
	m_flDelay = 1.0f;
}

void
monstermaker::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strMonster", m_strMonster);
	SaveString(handle, "m_strChildName", m_strChildName);
	SaveInt(handle, "m_iMonsterSpawned", m_iMonsterSpawned);
	SaveInt(handle, "m_iTotalMonsters", m_iTotalMonsters);
	SaveInt(handle, "m_iMaxChildren", m_iMaxChildren);
	SaveFloat(handle, "m_flDelay", m_flDelay);
}

void
monstermaker::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_strMonster":
		m_strMonster = ReadString(setValue);
		break;
	case "m_strChildName":
		m_strChildName = ReadString(setValue);
		break;
	case "m_iMonsterSpawned":
		m_iMonsterSpawned = ReadInt(setValue);
		break;
	case "m_iTotalMonsters":
		m_iTotalMonsters = ReadInt(setValue);
		break;
	case "m_iMaxChildren":
		m_iMaxChildren = ReadInt(setValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
monstermaker::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "monstertype":
		m_strMonster = setValue;
		break;
	case "monstercount":
		m_iTotalMonsters = stoi(setValue);
		break;
	case "child_alivemax":
	case "m_imaxlivechildren":
		m_iMaxChildren = stoi(setValue);
		break;
	case "child_name":
	case "netname":
		m_strChildName = setValue;
		netname = __NULL__;
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
monstermaker::Respawn(void)
{
	InitPointTrigger();

	if (HasSpawnFlags(MMF_STARTON)) {
		TurnOn();
	} else {
		TurnOff();
	}

	m_iMonsterSpawned = 0;
}

void
monstermaker::TurnOff(void)
{
	ReleaseThink();
	SetValue(0i);
}

void
monstermaker::TurnOn(void)
{
	ScheduleThink(Spawner, 0.0f);
	SetValue(1i);
}

void
monstermaker::Spawner(void)
{
	int c = 0;

	/* look and count the buggers that are still around */
	for (entity l = world; (l = find(l, ::classname, m_strMonster));) {
		if (l.real_owner == this) {
			/* may be a corpse? */
			if (l.movetype == MOVETYPE_WALK) {
				c++;
			}
		}
	}

	/* too many alive at a time */
	if ((m_iMaxChildren > 0 && c >= m_iMaxChildren) || (m_flDelay <= 0 && c >= 1)) {
		ScheduleThink(Spawner, m_flDelay);
		return;
	}

	tracebox(origin, [-16,-16,-16], [16,16,16], origin, FALSE, this);

	if (trace_startsolid == TRUE) {
		ScheduleThink(Spawner, m_flDelay);
		return;
	}

	ncEntity unit = Entity_CreateClass(m_strMonster);

	if (!unit) {
		EntError("Cannot call spawnfunction for %s", m_strMonster);
		Destroy();
		return;
	}

	unit.real_owner = this;
	EntLog("Spawning %s", m_strMonster);
	unit.SetOrigin(GetOrigin());
	unit.SetAngles(GetAngles());
	unit.targetname = (m_strChildName);
	unit.ReleaseThink();

	m_iMonsterSpawned++;

	if (target) {
		UseTargets(this, TRIG_TOGGLE, 0.0f);
	}

	/* inherit the monsterclip flag */
	if (HasSpawnFlags(MMF_MONSTERCLIP)) {
		unit.spawnflags |= MSF_MONSTERCLIP;
	}

	/* shut off for good when we've spawned all we ever wanted */
	if ((m_iTotalMonsters > 0) && m_iMonsterSpawned >= m_iTotalMonsters) {
		ReleaseThink();
		return;
	}

	/* sometimes all we do is just spawn a single monster at a time */
	if (HasSpawnFlags(MMF_NONTOGGLE)) {
		TurnOff();
	} else {
		ScheduleThink(Spawner, m_flDelay);
	}
}

void
monstermaker::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		TurnOff();
		break;
	case TRIG_ON:
		TurnOn();
		break;
	default:
		if (GetValue(this))
			TurnOff();
		else
			TurnOn();
	}
}
