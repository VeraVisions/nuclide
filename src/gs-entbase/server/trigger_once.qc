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

/*QUAKED trigger_once (0 .5 .8) ? TO_MONSTERS TO_NOCLIENTS TO_PUSHABLES
A trigger volume which works only once.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"delay" : Delay until target is triggered.

-------- SPAWNFLAGS --------
TO_MONSTERS : Allow NPCs to activate this entity.
TO_NOCLIENTS : Don't allow players to activate this entity.
TO_PUSHABLES : Allow func_pushables to trigger this entity.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

// TODO: These are missing
enumflags
{
	TO_MONSTERS,
	TO_NOCLIENTS,
	TO_PUSHABLES
};

class trigger_once:CBaseTrigger
{
	string m_strOnStartTouch;
	string m_strOnTrigger;

	void(void) trigger_once;

	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
trigger_once::touch(void)
{
	if (GetMaster() == FALSE)
		return;
	if (spawnflags & TO_NOCLIENTS && other.flags & FL_CLIENT)
		return;
	if (!(spawnflags & TO_MONSTERS) && other.flags & FL_MONSTER)
		return;
	if (!(spawnflags & TO_PUSHABLES) && other.classname == "func_pushable")
		return;

	solid = SOLID_NOT; /* make inactive */
	m_iValue = 1;

	if (!target) {
		UseOutput(other, m_strOnStartTouch);
		return;
	}

	UseTargets(other, TRIG_TOGGLE, m_flDelay);
}

void
trigger_once::Respawn(void)
{
	m_iValue = 0;
	solid = SOLID_TRIGGER;

#ifdef GS_RENDERFX
	SetRenderMode(RM_TRIGGER);
#endif

	InitBrushTrigger();
}

void
trigger_once::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "OnStartTouch":
		strValue = strreplace(",", ",_", strValue);
		m_strOnStartTouch = strcat(m_strOnStartTouch, ",_", strValue);
		break;
	case "OnTrigger":
		strValue = strreplace(",", ",_", strValue);
		m_strOnTrigger = strcat(m_strOnTrigger, ",_", strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
		break;
	}
}

void
trigger_once::trigger_once(void)
{
	CBaseTrigger::CBaseTrigger();

	if (m_strOnTrigger)
		m_strOnTrigger = CreateOutput(m_strOnTrigger);

	if (m_strOnStartTouch)
		m_strOnStartTouch = CreateOutput(m_strOnStartTouch);
}
