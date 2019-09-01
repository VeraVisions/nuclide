/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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
	void() trigger_once;
	virtual void() touch;
	virtual void() Respawn;
};

void trigger_once::touch(void)
{
	eActivator = other;

	if (m_flDelay > 0) {
		CBaseTrigger::UseTargets_Delay(m_flDelay);
	} else {
		CBaseTrigger::UseTargets();
	}
	solid = SOLID_NOT;
#ifdef GS_DEVELOPER
	alpha = 0.001f;
#endif
}

/* TODO: Make this redundant */
void trigger_once::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void trigger_once::trigger_once(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "delay":
			m_flDelay = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}
	trigger_once::Respawn();
	CBaseEntity::CBaseEntity();
	CBaseTrigger::InitBrushTrigger();
}
