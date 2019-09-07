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

/*QUAKED env_render (1 0 0) (-8 -8 -8) (8 8 8) SF_NORENDERFX SF_NORENDERAMT SF_NORENDERMODE SF_NORENDERCOLOR
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"rendermode"    Render-Mode the target changes to
"renderamt"     Render-Alpha the target changes to
"rendercolor"   Render-Color the target changes to

Changes the visual appearance of a target.
*/

enumflags {
	SF_NORENDERFX,
	SF_NORENDERAMT,
	SF_NORENDERMODE,
	SF_NORENDERCOLOR
};

class env_render:CBaseTrigger
{
	virtual void() Trigger;
};

void env_render::Trigger(void)
{
	for (entity eFind = world; 
		(eFind = find(eFind, CBaseTrigger::m_strTargetName, m_strTarget));) {
		CBaseEntity trigger = (CBaseEntity) eFind;
		if (!(spawnflags & SF_NORENDERMODE)) {
			trigger.m_rendermode = m_rendermode;
		}
		if (!(spawnflags & SF_NORENDERCOLOR)) {
			trigger.m_rendercolor = m_rendercolor;
		}
		if (!(spawnflags & SF_NORENDERAMT)) {
			trigger.m_renderamt = m_renderamt;
		}
		trigger.RendermodeUpdate();
	}
}

