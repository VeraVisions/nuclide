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

/*QUAKED func_wall_toggle (0 .5 .8) ? FTW_STARTHIDDEN
Brush that can be hidden and reappear when triggered.

-------- KEYS --------
"targetname" : Name

-------- SPAWNFLAGS --------
FTW_STARTHIDDEN : Start invisible upon spawning.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	FTW_STARTHIDDEN
};

class func_wall_toggle:CBaseTrigger
{
	int m_oldmodelindex;
	int m_iVisible;

	void(void) func_wall_toggle;
	virtual void(void) Respawn;
	virtual void(entity, int) Trigger;
	virtual void(entity, string, string) Input;
};

void
func_wall_toggle::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		m_iVisible = 0;
		break;
	case TRIG_ON:
		m_iVisible = 1;
		break;
	default:
		m_iVisible = 1 - m_iVisible;
	}

	if (m_iVisible) {
		SetSolid(SOLID_BSP);
		SetModelindex(m_oldmodelindex);
	} else {
		SetSolid(SOLID_NOT);
		SetModelindex(0);
	}
}

void
func_wall_toggle::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(origin);
	m_iVisible = 1;
	m_oldmodelindex = modelindex;

	if (spawnflags & FTW_STARTHIDDEN) {
		Trigger(this, TRIG_OFF);
	}
}

void
func_wall_toggle::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		CBaseTrigger::Input(eAct, strInput, strData);
	}
}

void
func_wall_toggle::func_wall_toggle(void)
{
	precache_model(model);
	CBaseTrigger::CBaseTrigger();
}
