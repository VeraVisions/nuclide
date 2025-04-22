/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

enumflags
{
	FTW_STARTHIDDEN
};

/*! \brief Server-Entity: Prototype func_brush */
/*!QUAKED func_wall_toggle (0 .5 .8) ? FTW_STARTHIDDEN
# OVERVIEW
Brush that can be hidden and reappear when triggered.

# KEYS
- "targetname" : Name

# SPAWNFLAGS
- FTW_STARTHIDDEN (1) : Start invisible upon spawning.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
func_wall_toggle:ncRenderableEntity
{
public:
	void func_wall_toggle(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity,string,string);

private:
	int m_oldmodelindex;
	int m_iVisible;
};

void
func_wall_toggle::func_wall_toggle(void)
{
	m_oldmodelindex = 0i;
	m_iVisible = 0i;
}

void
func_wall_toggle::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_oldmodelindex", m_oldmodelindex);
	SaveInt(handle, "m_iVisible", m_iVisible);
}

void
func_wall_toggle::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_oldmodelindex":
		m_oldmodelindex = ReadInt(setValue);
		break;
	case "m_iVisible":
		m_iVisible = ReadInt(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_wall_toggle::Respawn(void)
{
	super::Respawn();

	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	ClearAngles();

	m_iVisible = 1;
	m_oldmodelindex = modelindex;

	if (HasSpawnFlags(FTW_STARTHIDDEN)) {
		Trigger(this, TRIG_OFF);
	}
}

void
func_wall_toggle::Trigger(entity act, triggermode_t state)
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
		SetModel(GetSpawnString("model"));
	} else {
		SetSolid(SOLID_NOT);
		SetModelindex(0);
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
		super::Input(eAct, strInput, strData);
	}
}
