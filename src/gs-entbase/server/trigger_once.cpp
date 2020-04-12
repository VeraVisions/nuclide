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
	float m_flDelay;
	void(void) trigger_once;

	virtual void(void) touch;
	virtual void(void) Respawn;
};

void
trigger_once::touch(void)
{
	eActivator = other;

	if (m_flDelay > 0) {
		CBaseTrigger::UseTargets_Delay(m_flDelay);
	} else {
		CBaseTrigger::UseTargets();
	}
	solid = SOLID_NOT;
}

void
trigger_once::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	m_iRenderMode = RM_SOLID;
	m_flRenderAmt = 0.25f;
#else
	m_iRenderMode = RM_SOLID;
	m_flRenderAmt = 0.0f;
#endif
}

void
trigger_once::trigger_once(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "delay":
			m_flDelay = stof(argv(i+1));
			break;
		default:
			break;
		}
	}

	CBaseTrigger::CBaseTrigger();
	InitBrushTrigger();
}
