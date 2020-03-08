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

/*QUAKED func_wall_toggle (0 .5 .8) ? FTW_STARTHIDDEN
"targetname"    Name

Brush that can be hidden and reappear when triggered.

If FTW_STARTHIDDEN is set, it'll start hidden.
*/

enumflags
{
	FTW_STARTHIDDEN
};

class func_wall_toggle:CBaseTrigger
{
	int m_oldmodelindex;
	int m_iVisible;

	void() func_wall_toggle;
	virtual void() Respawn;
	virtual void() Trigger;
};

void func_wall_toggle::Trigger(void)
{
	m_iVisible = 1 - m_iVisible;

	if (m_iVisible) {
		modelindex = m_oldmodelindex;
		solid = SOLID_BSP;
	} else {
		modelindex = 0;
		solid = SOLID_NOT;
	}
}

void func_wall_toggle::Respawn(void)
{
	movetype = MOVETYPE_PUSH;
	solid = SOLID_BSP;
	setmodel(this, m_oldModel);
	setorigin(this, origin);
	m_iVisible = 1;
	m_oldmodelindex = modelindex;

	if (spawnflags & FTW_STARTHIDDEN) {
		Trigger();
	}
}

void func_wall_toggle::func_wall_toggle(void)
{
	precache_model(model);
	CBaseTrigger::CBaseTrigger();
}
