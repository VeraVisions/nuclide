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

#define MM_MULTITHREADED 1

static class
multi_manager_sub:ncPointTrigger
{
public:
	void multi_manager_sub(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	nonvirtual void ActivateSub(void);

private:
	entity m_lastActivator;
	float m_flUntilTriggered;
};

void
multi_manager_sub::multi_manager_sub(void)
{
	m_lastActivator = __NULL__;
	m_flUntilTriggered = 0.0f;
}

void
multi_manager_sub::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "m_lastActivator", m_lastActivator);
	SaveFloat(handle, "m_flUntilTriggered", m_flUntilTriggered);
}

void
multi_manager_sub::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_lastActivator":
		m_lastActivator = ReadEntity(setValue);
		break;
	case "m_flUntilTriggered":
		m_flUntilTriggered = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
multi_manager_sub::ActivateSub(void)
{
	SetValue(1i);
	UseTargets(m_lastActivator, TRIG_TOGGLE, 0.0f);
}

/*! \brief Server-Entity: Triggers Up To 16 Different Targets */
/*!QUAKED multi_manager (1 0 0) (-8 -8 -8) (8 8 8) MM_MULTITHREADED
# OVERVIEW
Triggers a maximum of 16 user defined entities with additonal timers.
Add a target's name as an entity key, with the value set to the time in seconds
that'll pass before the entity will be triggered.

# KEYS
- "targetname" : Name

# SPAWNFLAGS
- MM_MULTITHREADED (1) : Allow the multi_manager to be triggered again before it has
finished triggering it's previous list of entities.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
multi_manager:ncPointTrigger
{
private:
	multi_manager_sub m_subTriggers[16];
	string m_triggerBuffer;

public:
	void multi_manager(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
};

void
multi_manager::multi_manager(void)
{
	for (int i = 0; i < 16; i++)
		m_subTriggers[i] = __NULL__;

	m_triggerBuffer = __NULL__;
}

void
multi_manager::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_triggerBuffer", m_triggerBuffer);
	SaveEntity(handle, "m_subTriggers_0", m_subTriggers[0]);
	SaveEntity(handle, "m_subTriggers_1", m_subTriggers[1]);
	SaveEntity(handle, "m_subTriggers_2", m_subTriggers[2]);
	SaveEntity(handle, "m_subTriggers_3", m_subTriggers[3]);
	SaveEntity(handle, "m_subTriggers_4", m_subTriggers[4]);
	SaveEntity(handle, "m_subTriggers_5", m_subTriggers[5]);
	SaveEntity(handle, "m_subTriggers_6", m_subTriggers[6]);
	SaveEntity(handle, "m_subTriggers_7", m_subTriggers[7]);
	SaveEntity(handle, "m_subTriggers_8", m_subTriggers[8]);
	SaveEntity(handle, "m_subTriggers_9", m_subTriggers[9]);
	SaveEntity(handle, "m_subTriggers_10", m_subTriggers[10]);
	SaveEntity(handle, "m_subTriggers_11", m_subTriggers[11]);
	SaveEntity(handle, "m_subTriggers_12", m_subTriggers[12]);
	SaveEntity(handle, "m_subTriggers_13", m_subTriggers[13]);
	SaveEntity(handle, "m_subTriggers_14", m_subTriggers[14]);
	SaveEntity(handle, "m_subTriggers_15", m_subTriggers[15]);
}

void
multi_manager::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_triggerBuffer":
		m_triggerBuffer = ReadString(setValue);
		break;
	case "m_subTriggers_0":
		m_subTriggers[0] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_1":
		m_subTriggers[1] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_2":
		m_subTriggers[2] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_3":
		m_subTriggers[3] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_4":
		m_subTriggers[4] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_5":
		m_subTriggers[5] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_6":
		m_subTriggers[6] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_7":
		m_subTriggers[7] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_8":
		m_subTriggers[8] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_9":
		m_subTriggers[9] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_10":
		m_subTriggers[10] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_11":
		m_subTriggers[11] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_12":
		m_subTriggers[12] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_13":
		m_subTriggers[13] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_14":
		m_subTriggers[14] = (multi_manager_sub)ReadEntity(setValue);
		break;
	case "m_subTriggers_15":
		m_subTriggers[15] = (multi_manager_sub)ReadEntity(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
multi_manager::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "{":
	case "}":
	case "classname":
	case "origin":
	case "targetname":
	case "spawnflags":
	case "angle":
	case "angles":
	case "target":
	case "spawnflags":
		super::SpawnKey(strKey, setValue);
		break;
	default:
		if (substring(strKey, strlen(strKey) - 3,  1) == "#") {
			m_triggerBuffer = sprintf("%s%s %s ",
							m_triggerBuffer,
							substring(strKey,
							0, strlen(strKey) - 3),
							setValue);
		} else if (substring(strKey, strlen(strKey) - 2,  1) == "#") {
			m_triggerBuffer = sprintf("%s%s %s ",
							m_triggerBuffer,
							substring(strKey,
							0, strlen(strKey) - 2),
							setValue);
		} else {
			m_triggerBuffer = sprintf("%s%s %s ", m_triggerBuffer, strKey, setValue);
		}
	}
}

void
multi_manager::Spawned(void)
{
	int iFields;
	int b;

	super::Spawned();

	for (b = 0; b < 16; b++) {
		m_subTriggers[b] = spawn(multi_manager_sub);
		m_subTriggers[b].Spawn();
	}

	/* set up our triggers */
	b = 0;
	iFields = tokenizebyseparator(m_triggerBuffer, " ");
	for (int i = 0; i < iFields; i+=2) {
		if (b >= 16) {
			break;
		}

		if (!argv(i))
			break;

		/* avoid infinite-loops, only when MULTITHREADED flag is NOT set */
		if ((!HasSpawnFlags(MM_MULTITHREADED) && targetname == argv(i)))
			continue;

		m_subTriggers[b].SetTriggerTarget(argv(i));
		m_subTriggers[b].target = argv(i);
		m_subTriggers[b].m_flUntilTriggered = stof(argv(i+1));
		b++;
	}
}

void
multi_manager::Respawn(void)
{
	InitPointTrigger();

	SetValue(0i);

	/* Mark them inactive */
	for (int b = 0; b < 16; b++) {
		m_subTriggers[b].SetValue(0i);
	}
}

void
multi_manager::Trigger(entity act, triggermode_t state)
{
	if (GetMaster(act) == FALSE)
		return;

	SetValue(1i);

	/* If not multi-threaded, we have to watch out 'til all triggers are done. */
	if (!HasSpawnFlags(MM_MULTITHREADED)) {
		for (int i = 0; i < 16; i++) {
			if (m_subTriggers[i].IsThinking() == true) {
				return;
			}
		}
	}

	/* time to trigger our sub triggers */
	for (int i = 0; i < 16; i++) {
		if (m_subTriggers[i].HasTriggerTarget() == false)
			continue;

		m_subTriggers[i].SetValue(0i);
		m_subTriggers[i].m_lastActivator = act;
		m_subTriggers[i].ScheduleThink(multi_manager_sub::ActivateSub, m_subTriggers[i].m_flUntilTriggered);
	}
}
