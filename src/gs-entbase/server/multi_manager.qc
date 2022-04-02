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

/*QUAKED multi_manager (1 0 0) (-8 -8 -8) (8 8 8) MM_MULTITHREADED
Triggers a maximum of 16 user defined entities with additonal timers.
Add a target's name as an entity key, with the value set to the time in seconds
that'll pass before the entity will be triggered.

-------- KEYS --------
"targetname" : Name

-------- SPAWNFLAGS --------
MM_MULTITHREADED : Allow the multi_manager to be triggered again before it has
finished triggering it's previous list of entities.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

#define MM_MULTITHREADED 1

class multi_manager_sub:NSPointTrigger
{
	entity m_eActivator;
	int m_iValue;
	float m_flUntilTriggered;

	void(void) multi_manager_sub;

	/* overrides */
	virtual void(float) Save;
	virtual void(string,string) Restore;
};

void
multi_manager_sub::Save(float handle)
{
	SaveInt(handle, "m_iValue", m_iValue);
	SaveFloat(handle, "m_eActivator", num_for_edict(m_eActivator));
	SaveFloat(handle, "m_flUntilTriggered", m_flUntilTriggered);
	super::Save(handle);
}

void
multi_manager_sub::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iValue":
		m_iValue = ReadInt(strValue);
		break;
	case "m_eActivator":
		float num = ReadFloat(strValue);

		if (num)
			m_eActivator = edict_num(num);
		break;
	case "m_flUntilTriggered":
		m_flUntilTriggered = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
multi_manager_sub::multi_manager_sub(void)
{
	super::NSPointTrigger();
}

class multi_manager:NSPointTrigger
{
	multi_manager_sub m_eTriggers[16];
	string m_strBuffer;
	int m_iBusy;
	int m_iValue;

	/* overrides */
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
	virtual void(float) Save;
	virtual void(string,string) Restore;
};

void
multi_manager::Save(float handle)
{
	SaveString(handle, "m_strBuffer", m_strBuffer);
	SaveInt(handle, "m_iBusy", m_iBusy);
	SaveInt(handle, "m_iValue", m_iValue);
	SaveFloat(handle, "m_eTriggers_0", num_for_edict(m_eTriggers[0]));
	SaveFloat(handle, "m_eTriggers_1", num_for_edict(m_eTriggers[1]));
	SaveFloat(handle, "m_eTriggers_2", num_for_edict(m_eTriggers[2]));
	SaveFloat(handle, "m_eTriggers_3", num_for_edict(m_eTriggers[3]));
	SaveFloat(handle, "m_eTriggers_4", num_for_edict(m_eTriggers[4]));
	SaveFloat(handle, "m_eTriggers_5", num_for_edict(m_eTriggers[5]));
	SaveFloat(handle, "m_eTriggers_6", num_for_edict(m_eTriggers[6]));
	SaveFloat(handle, "m_eTriggers_7", num_for_edict(m_eTriggers[7]));
	SaveFloat(handle, "m_eTriggers_8", num_for_edict(m_eTriggers[8]));
	SaveFloat(handle, "m_eTriggers_9", num_for_edict(m_eTriggers[9]));
	SaveFloat(handle, "m_eTriggers_10", num_for_edict(m_eTriggers[10]));
	SaveFloat(handle, "m_eTriggers_11", num_for_edict(m_eTriggers[11]));
	SaveFloat(handle, "m_eTriggers_12", num_for_edict(m_eTriggers[12]));
	SaveFloat(handle, "m_eTriggers_13", num_for_edict(m_eTriggers[13]));
	SaveFloat(handle, "m_eTriggers_14", num_for_edict(m_eTriggers[14]));
	SaveFloat(handle, "m_eTriggers_15", num_for_edict(m_eTriggers[15]));
	super::Save(handle);
}

void
multi_manager::Restore(string strKey, string strValue)
{
switch (strKey) {
	case "m_strBuffer":
		m_strBuffer = strValue;
		break;
	case "m_iBusy":
		m_iBusy = stoi(strValue);
		break;
	case "m_iValue":
		m_iValue = stoi(strValue);
		break;
	case "m_eTriggers_0":
		m_eTriggers[0] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_1":
		m_eTriggers[1] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_2":
		m_eTriggers[2] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_3":
		m_eTriggers[3] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_4":
		m_eTriggers[4] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_5":
		m_eTriggers[5] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_6":
		m_eTriggers[6] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_7":
		m_eTriggers[7] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_8":
		m_eTriggers[8] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_9":
		m_eTriggers[9] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_10":
		m_eTriggers[10] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_11":
		m_eTriggers[11] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_12":
		m_eTriggers[12] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_13":
		m_eTriggers[13] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_14":
		m_eTriggers[14] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	case "m_eTriggers_15":
		m_eTriggers[15] = (multi_manager_sub)edict_num(stof(strValue));
		break;
	default:
		super::Restore(strKey, strValue);
	}
}


void
multi_manager::Trigger(entity act, int state)
{
	static void mm_enttrigger (void) {
		multi_manager_sub wow = (multi_manager_sub)self;
		
		entity eFind = find(world, ::targetname, wow.target);

		dprint(sprintf("^2%s::^3Trigger^7: %s (%s)\n", 
			this.classname, wow.target, eFind.classname));

		UseTargets(wow.m_eActivator, TRIG_TOGGLE, 0.0f);
	}

	if (GetMaster() == FALSE)
		return;

	m_iValue = TRUE;

	/* If not multi-threaded, we have to watch out 'til all triggers are done. */
	if (!HasSpawnFlags(MM_MULTITHREADED)) {
		for (int i = 0; i < 16; i++) {
			if (m_eTriggers[i].nextthink > time) {
				return;
			}
		}
	}

	/* time to trigger our sub triggers */
	for (int i = 0; i < 16; i++) {
		if (!m_eTriggers[i].target)
			continue;

		m_eTriggers[i].think = mm_enttrigger;
		m_eTriggers[i].nextthink = time + m_eTriggers[i].m_flUntilTriggered;
		m_eTriggers[i].m_iValue = TRUE;
		m_eTriggers[i].m_eActivator = act;
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
multi_manager::multi_manager(void)
{
	int iFields;
	int b;
	m_strBuffer = "";

	super::NSPointTrigger();

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

		// HACK: Avoid infinite loops
		if (targetname != argv(i)) {
			m_eTriggers[b].target = argv(i);
			m_eTriggers[b].m_oldstrTarget = argv(i);
			m_eTriggers[b].m_flUntilTriggered = stof(argv(i+1));
			b++;
		}
	}
}
