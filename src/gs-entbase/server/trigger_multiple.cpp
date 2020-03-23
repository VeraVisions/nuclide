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

/*QUAKED trigger_multiple (0 .5 .8) ? TM_MONSTERS TM_NOCLIENTS TM_PUSHABLES
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"delay"         Delay until target is triggered.
"wait"          Time until this entity can trigger again

A trigger volume which works more than once. 

None of the spawnflags are implemented yet.
*/

// TODO: These are missing
enumflags
{
	TM_MONSTERS,
	TM_NOCLIENTS,
	TM_PUSHABLES
};

class trigger_multiple:CBaseTrigger
{
	float m_flDelay;
	float m_flWait;
	void() trigger_multiple;
	virtual void() touch;
	virtual void() Respawn;
};

void trigger_multiple::touch(void)
{
	eActivator = other;

	if (Rules_IsTeamPlay() == TRUE) {
		if (m_iTeam > 0 && eActivator.team != m_iTeam + 1) {
			return;
		}
	}

	if (other.movetype != MOVETYPE_WALK) {
		return;
	}

	if (m_flDelay > 0) {
		UseTargets_Delay(m_flDelay);
	} else {
		UseTargets();
	}
	
	/* This is effectively a trigger_once...*/
	if (m_flWait != -1) {
		think = Respawn;
		nextthink = time + m_flWait;
	}
	solid = SOLID_NOT;
	
#ifdef GS_DEVELOPER
	alpha = 0.001f;
#endif
}

/* TODO: Make this redundant */
void trigger_multiple::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void trigger_multiple::trigger_multiple(void)
{
	CBaseEntity::CBaseEntity();

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "delay":
			m_flDelay = stof(argv(i+1));
			break;
		case "wait":
			m_flWait = stof(argv(i+1));
			break;
		default:
			break;
		}
	}
	InitBrushTrigger();
}
