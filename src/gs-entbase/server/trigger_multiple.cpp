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
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"delay"         Delay until target is triggered.
"wait"          Time until this entity can trigger again

A trigger volume which works more than once. 

None of the spawnflags are implemented yet.

Trivia:
This entity was introduced in Quake (1996).
*/

enumflags
{
	TM_MONSTERS,
	TM_NOCLIENTS,
	TM_PUSHABLES
};

class trigger_multiple:CBaseTrigger
{
	float m_flWait;
	string m_strOnStartTouch;

	void(void) trigger_multiple;
	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
trigger_multiple::touch(void)
{
	if (GetMaster() == FALSE)
		return;

	if (spawnflags & TM_NOCLIENTS && other.flags & FL_CLIENT)
		return;
	if (!(spawnflags & TM_MONSTERS) && other.flags & FL_MONSTER)
		return;
	if (!(spawnflags & TM_PUSHABLES) && other.classname = "func_pushable")
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
	solid = SOLID_NOT;
}

void
trigger_multiple::Respawn(void)
{
	InitBrushTrigger();
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
		strValue = strreplace(",", ",_", strValue);
		m_strOnStartTouch = strcat(m_strOnStartTouch, ",_", strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
trigger_multiple::trigger_multiple(void)
{
	CBaseTrigger::CBaseTrigger();

	if (m_strOnStartTouch)
		m_strOnStartTouch = CreateOutput(m_strOnStartTouch);
}
