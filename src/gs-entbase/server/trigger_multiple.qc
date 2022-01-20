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

/*QUAKED trigger_multiple (0 .5 .8) ? TM_MONSTERS TM_NOCLIENTS TM_PUSHABLES
A trigger volume which works more than once. 

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"delay" : Delay until target is triggered.
"wait" : Time until this entity can trigger again

-------- OUTPUTS ---------
"OnStartTouch": Triggered when something starts touching this volume
"OnEndTouchAll": Triggered when nothing touched the entity no more

-------- SPAWNFLAGS --------
TM_MONSTERS : Allow NPCs to activate this entity.
TM_NOCLIENTS : Don't allow players to activate this entity.
TM_PUSHABLES : Allow func_pushables to trigger this entity.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

enumflags
{
	TM_MONSTERS,
	TM_NOCLIENTS,
	TM_PUSHABLES
};

class trigger_multiple:NSBrushTrigger
{
	float m_flWait;
	entity m_eLastToucher;

	/* Input/Output */
	string m_strOnStartTouch;
	string m_strOnEndTouchAll;
	string m_strOnTrigger;

	void(void) trigger_multiple;

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;

	virtual void(void) EndTouchCheck;
};

void
trigger_multiple::EndTouchCheck(void)
{
	if (m_eLastToucher) {
		tracebox(origin, absmin, absmax, origin, MOVE_NORMAL, this);
		if (!(trace_ent.flags & FL_CLIENT)) {
			UseOutput(other, m_strOnEndTouchAll);
			m_eLastToucher = __NULL__;
		}
	}

	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
}

void
trigger_multiple::Save(float handle)
{
	SaveFloat(handle, "wait", m_flWait);
	SaveString(handle, "OnStartTouch", m_strOnStartTouch);
	SaveString(handle, "OnEndTouchAll", m_strOnEndTouchAll);
	SaveString(handle, "OnTrigger", m_strOnTrigger);
	super::Save(handle);
}

void
trigger_multiple::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "wait":
		m_flWait = ReadFloat(strValue);
		break;
	case "OnStartTouch":
		m_strOnStartTouch = ReadString(strValue);
		break;
	case "OnEndTouchAll":
		m_strOnEndTouchAll = ReadString(strValue);
		break;
	case "OnTrigger":
		m_strOnTrigger = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_multiple::touch(void)
{
	if (GetMaster() == FALSE)
		return;
	if (spawnflags & TM_NOCLIENTS && other.flags & FL_CLIENT)
		return;
	if (!(spawnflags & TM_MONSTERS) && other.flags & FL_MONSTER)
		return;
	if (!(spawnflags & TM_PUSHABLES) && other.classname == "func_pushable")
		return;

	if (Rules_IsTeamPlay() == TRUE) {
		if (m_iTeam > 0 && eActivator.team != m_iTeam + 1) {
			return;
		}
	}

	/* if the target key isn't used, assume we're using the new I/O system */
	if (!target)
		UseOutput(other, m_strOnStartTouch);
	else
		UseTargets(other, TRIG_TOGGLE, m_flDelay);

	/* This is effectively a trigger_once...*/
	if (m_flWait != -1) {
		think = Respawn;
		nextthink = time + m_flWait;
	}

	SetSolid(SOLID_NOT);
	m_eLastToucher = other;
}

void
trigger_multiple::Respawn(void)
{
	InitBrushTrigger();

	if (m_strOnEndTouchAll) {
		customphysics = EndTouchCheck;
	}
}

void
trigger_multiple::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "wait":
		m_flWait = stof(strValue);
		break;
	case "OnStartTouch":
	case "OnStartTouchAll":
		m_strOnStartTouch = PrepareOutput(m_strOnStartTouch, strValue);
		break;
	case "OnEndTouchAll":
		m_strOnEndTouchAll = PrepareOutput(m_strOnEndTouchAll, strValue);
		break;
	case "OnTrigger":
		m_strOnTrigger = PrepareOutput(m_strOnTrigger, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_multiple::trigger_multiple(void)
{
	super::NSBrushTrigger();

	if (m_strOnTrigger)
		m_strOnTrigger = CreateOutput(m_strOnTrigger);
	if (m_strOnStartTouch)
		m_strOnStartTouch = CreateOutput(m_strOnStartTouch);
	if (m_strOnEndTouchAll)
		m_strOnEndTouchAll = CreateOutput(m_strOnEndTouchAll);
}
