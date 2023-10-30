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
*/
class
multi_manager_sub:NSPointTrigger
{
public:
	void multi_manager_sub(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);

private:
	entity m_eActivator;
	int m_iValue;
	float m_flUntilTriggered;
};

void
multi_manager_sub::multi_manager_sub(void)
{
	m_eActivator = __NULL__;
	m_iValue = 0i;
	m_flUntilTriggered = 0.0f;
}

void
multi_manager_sub::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iValue", m_iValue);
	SaveEntity(handle, "m_eActivator", m_eActivator);
	SaveFloat(handle, "m_flUntilTriggered", m_flUntilTriggered);
}

void
multi_manager_sub::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iValue":
		m_iValue = ReadInt(strValue);
		break;
	case "m_eActivator":
		m_eActivator = ReadEntity(strValue);
		break;
	case "m_flUntilTriggered":
		m_flUntilTriggered = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

class
multi_manager:NSPointTrigger
{
private:
	multi_manager_sub m_eTriggers[16];
	string m_strBuffer;
	int m_iBusy;
	int m_iValue;

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
		m_eTriggers[i] = __NULL__;

	m_strBuffer = __NULL__;
	m_iBusy =
	m_iValue = 0i;
}

void
multi_manager::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strBuffer", m_strBuffer);
	SaveInt(handle, "m_iBusy", m_iBusy);
	SaveInt(handle, "m_iValue", m_iValue);
	SaveEntity(handle, "m_eTriggers_0", m_eTriggers[0]);
	SaveEntity(handle, "m_eTriggers_1", m_eTriggers[1]);
	SaveEntity(handle, "m_eTriggers_2", m_eTriggers[2]);
	SaveEntity(handle, "m_eTriggers_3", m_eTriggers[3]);
	SaveEntity(handle, "m_eTriggers_4", m_eTriggers[4]);
	SaveEntity(handle, "m_eTriggers_5", m_eTriggers[5]);
	SaveEntity(handle, "m_eTriggers_6", m_eTriggers[6]);
	SaveEntity(handle, "m_eTriggers_7", m_eTriggers[7]);
	SaveEntity(handle, "m_eTriggers_8", m_eTriggers[8]);
	SaveEntity(handle, "m_eTriggers_9", m_eTriggers[9]);
	SaveEntity(handle, "m_eTriggers_10", m_eTriggers[10]);
	SaveEntity(handle, "m_eTriggers_11", m_eTriggers[11]);
	SaveEntity(handle, "m_eTriggers_12", m_eTriggers[12]);
	SaveEntity(handle, "m_eTriggers_13", m_eTriggers[13]);
	SaveEntity(handle, "m_eTriggers_14", m_eTriggers[14]);
	SaveEntity(handle, "m_eTriggers_15", m_eTriggers[15]);
}

void
multi_manager::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strBuffer":
		m_strBuffer = ReadString(strValue);
		break;
	case "m_iBusy":
		m_iBusy = ReadInt(strValue);
		break;
	case "m_iValue":
		m_iValue = ReadInt(strValue);
		break;
	case "m_eTriggers_0":
		m_eTriggers[0] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_1":
		m_eTriggers[1] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_2":
		m_eTriggers[2] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_3":
		m_eTriggers[3] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_4":
		m_eTriggers[4] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_5":
		m_eTriggers[5] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_6":
		m_eTriggers[6] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_7":
		m_eTriggers[7] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_8":
		m_eTriggers[8] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_9":
		m_eTriggers[9] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_10":
		m_eTriggers[10] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_11":
		m_eTriggers[11] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_12":
		m_eTriggers[12] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_13":
		m_eTriggers[13] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_14":
		m_eTriggers[14] = (multi_manager_sub)ReadEntity(strValue);
		break;
	case "m_eTriggers_15":
		m_eTriggers[15] = (multi_manager_sub)ReadEntity(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
multi_manager::SpawnKey(string strKey, string strValue)
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
		super::SpawnKey(strKey, strValue);
		break;
	default:
		if (substring(strKey, strlen(strKey) - 3,  1) == "#") {
			m_strBuffer = sprintf("%s%s %s ",
							m_strBuffer,
							substring(strKey,
							0, strlen(strKey) - 3),
							strValue);
		} else if (substring(strKey, strlen(strKey) - 2,  1) == "#") {
			m_strBuffer = sprintf("%s%s %s ",
							m_strBuffer,
							substring(strKey,
							0, strlen(strKey) - 2),
							strValue);
		} else {
			m_strBuffer = sprintf("%s%s %s ", m_strBuffer, strKey, strValue);
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
		m_eTriggers[b] = spawn(multi_manager_sub);
	}

	/* set up our triggers */
	b = 0;
	iFields = tokenizebyseparator(m_strBuffer, " ");
	for (int i = 0; i < iFields; i+=2) {
		if (b >= 16) {
			break;
		}

		if (!argv(i))
			break;

		/* avoid infinite-loops, only when MULTITHREADED flag is NOT set */
		if ((!HasSpawnFlags(MM_MULTITHREADED) && targetname == argv(i)))
			continue;

		m_eTriggers[b].SetTriggerTarget(argv(i));
		m_eTriggers[b].m_oldstrTarget = argv(i);
		m_eTriggers[b].m_flUntilTriggered = stof(argv(i+1));
		b++;
	}
}

void
multi_manager::Respawn(void)
{
	m_iValue = FALSE;

	/* Mark them inactive */
	for (int b = 0; b < 16; b++) {
		m_eTriggers[b].m_iValue = FALSE;
	}
}

void
multi_manager::Trigger(entity act, triggermode_t state)
{
	static void mm_enttrigger (void) {
		multi_manager_sub wow = (multi_manager_sub)self;
		
		entity eFind = find(world, ::targetname, wow.target);

		NSLog("^2%s::^3Trigger^7: %s (%s)", 
			this.classname, wow.target, eFind.classname);

		wow.m_iValue = TRUE;
		UseTargets(wow.m_eActivator, TRIG_TOGGLE, 0.0f);
	}

	if (GetMaster(act) == FALSE)
		return;

	m_iValue = TRUE;

	/* If not multi-threaded, we have to watch out 'til all triggers are done. */
	if (!HasSpawnFlags(MM_MULTITHREADED)) {
		for (int i = 0; i < 16; i++) {
			if (m_eTriggers[i].IsThinking() == true) {
				return;
			}
		}
	}

	/* time to trigger our sub triggers */
	for (int i = 0; i < 16; i++) {
		if (m_eTriggers[i].HasTriggerTarget() == false)
			continue;

		m_eTriggers[i].m_iValue = FALSE;
		m_eTriggers[i].m_eActivator = act;
		m_eTriggers[i].ScheduleThink(mm_enttrigger, m_eTriggers[i].m_flUntilTriggered);
	}
}
