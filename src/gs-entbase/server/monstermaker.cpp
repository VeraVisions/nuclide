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

/*QUAKED monstermaker (1 0 0) (-8 -8 -8) (8 8 8) MMF_STARTON x MMF_NONTOGGLE MMF_MONSTERCLIP
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

"monstertype"     Type of monster to spawn, represents their entity classname.
"monstercount"    Maximum amount of monsters you want spawned in total.
"delay"           Delay between spawns in seconds.
"child_name"      Applies this as a 'targetname' to spawned monsters.
"child_alivemax"  Maximum amount of spawned monsters that are alive at a time.

The monster maker is the end-all solution to timed/controlled spawning of
monster entities.

When MMF_STARTON is checked, it'll start on automatically.
When MMF_NONTOGGLE is checked, it'll spawn only one monster with each trigger
When MMF_MONSTERCLIP is checked, all spawned monsters will be blocked by
func_monsterclip entities.
*/

enumflags
{
	MMF_STARTON,
	MMF_UNUSED1,
	MMF_NONTOGGLE,
	MMF_MONSTERCLIP
};

class monstermaker:CBaseTrigger
{
	string m_strMonster;
	int m_iMonsterSpawned;
	int m_iTotalMonsters;
	float m_flDelay;
	int m_iMaxChildren;
	string m_strChildName;

	void(void) monstermaker;

	virtual void(void) Spawner;
	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual void(void) TurnOn;
	virtual void(void) TurnOff;
	virtual void(string, string) SpawnKey;
};

void
monstermaker::TurnOff(void)
{
	think = __NULL__;
	nextthink = 0;
	m_iValue = 0;
}

void
monstermaker::TurnOn(void)
{
	think = Spawner;
	nextthink = time + m_flDelay;
	m_iValue = 1;
}

void
monstermaker::Spawner(void)
{
	static void monstermaker_spawnunit(void) {
		/* these will get overwritten by the monster spawnfunction */
		vector neworg = self.origin;
		vector newang = self.angles;
		string tname = self.netname;

		/* become the classname assigned */
		CBaseMonster t = (CBaseMonster)self;
		callfunction(self.classname);

		/* apply the saved values back */
		t.origin = t.m_oldOrigin = neworg;
		t.angles = t.m_oldAngle = newang;
		t.targetname = tname;
		t.spawnflags |= MSF_MULTIPLAYER;

		/* spawn anew */
		t.Respawn();
	}

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
		nextthink = time + m_flDelay;
		return;
	}

	tracebox(origin, [-16,-16,-16], [16,16,16], origin, FALSE, this);

	if (trace_startsolid == TRUE) {
		nextthink = time + m_flDelay;
		return;
	}

	if (isfunction(strcat("spawnfunc_", m_strMonster))) {
		entity unit = spawn();
		unit.classname = strcat("spawnfunc_", m_strMonster);
		unit.netname = m_strChildName;
		unit.think = monstermaker_spawnunit;
		unit.nextthink = time + 0.1f;
		unit.real_owner = this;
		dprint(sprintf("^2monstermaker::^3Trigger^7: Spawning %s\n", m_strMonster));
		setorigin(unit, origin);
		unit.angles = angles;
		m_iMonsterSpawned++;

		if (target) {
			UseTargets(this, TRIG_TOGGLE, 0.0f);
		}

		/* inherit the monsterclip flag */
		if (spawnflags & MMF_MONSTERCLIP) {
			unit.spawnflags |= MSF_MONSTERCLIP;
		}
	} else {
		print(sprintf("^1monstermaker::^3Trigger^7: cannot call spawnfunction for %s\n", m_strMonster));
		remove(this);
		return;
	}

	/* shut off for good when we've spawned all we ever wanted */
	if ((m_iTotalMonsters > 0) && m_iMonsterSpawned >= m_iTotalMonsters) {
		think = __NULL__;
		return;
	}

	/* sometimes all we do is just spawn a single monster at a time */
	if (spawnflags & MMF_NONTOGGLE) {
		TurnOff();
	} else {
		nextthink = time + m_flDelay;
	}
}

void
monstermaker::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		TurnOff();
		break;
	case TRIG_ON:
		TurnOn();
		break;
	default:
		if (m_iValue)
			TurnOff();
		else
			TurnOn();
	}
}

void
monstermaker::Respawn(void)
{
	if (spawnflags & MMF_STARTON) {
		TurnOn();
	} else {
		TurnOff();
	}

	m_iMonsterSpawned = 0;
}

void
monstermaker::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "monstertype":
		m_strMonster = strValue;
		break;
	case "monstercount":
		m_iTotalMonsters = stoi(strValue);
		break;
	case "child_alivemax":
	case "m_imaxlivechildren":
		m_iMaxChildren = stoi(strValue);
		break;
	case "child_name":
	case "netname":
		m_strChildName = strValue;
		netname = __NULL__;
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
monstermaker::monstermaker(void)
{
	m_flDelay = 1.0f;
	CBaseTrigger::CBaseTrigger();
}
