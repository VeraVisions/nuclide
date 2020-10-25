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
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"delay"         Delay until target is triggered.

A trigger volume which works only once.

None of the spawnflags are implemented yet.

Trivia:
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

	void(void) trigger_once;

	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
trigger_once::touch(void)
{
	if (!(spawnflags & TO_MONSTERS) && other.spawnflags & FL_MONSTER)
		return;
	if (spawnflags & TO_NOCLIENTS && other.spawnflags & FL_CLIENT)
		return;
	if (GetMaster() == FALSE)
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
	SetRenderMode(RM_TRIGGER);
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
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
		break;
	}
}

void
trigger_once::trigger_once(void)
{
	CBaseTrigger::CBaseTrigger();

	if (m_strOnStartTouch)
		m_strOnStartTouch = CreateOutput(m_strOnStartTouch);
}
