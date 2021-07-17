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

class multi_manager_sub:CBaseTrigger
{
	entity m_eActivator;
	int m_iValue;
	float m_flUntilTriggered;
};

class multi_manager:CBaseTrigger
{
	multi_manager_sub m_eTriggers[16];
	string m_strBuffer;
	int m_iBusy;
	int m_iValue;

	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};


void
multi_manager::Trigger(entity act, int state)
{
	static void mm_enttrigger (void) {
		multi_manager_sub wow = (multi_manager_sub)self;
		
		entity eFind = find(world, ::targetname, wow.target);

		dprint(sprintf("^2%s::^3Trigger^7: %s (%s)\n", 
			this.classname, wow.target, eFind.classname));

		CBaseTrigger::UseTargets(wow.m_eActivator, TRIG_TOGGLE, 0.0f);
	}

	if (GetMaster() == FALSE)
		return;

	m_iValue = TRUE;

	/* If not multi-threaded, we have to watch out 'til all triggers are done. */
	if (!(spawnflags & MM_MULTITHREADED)) {
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

	CBaseTrigger::CBaseTrigger();
	print(sprintf("multitrigger: %s\n", m_strBuffer));

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
			print(sprintf("Created multitrigger: %s %d\n", m_eTriggers[b].target, m_eTriggers[b].m_flUntilTriggered));
			b++;
		}
	}
}
