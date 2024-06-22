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

/*! \brief Server-Entity: Dynamic Brush Model */
/*!QUAKED func_brush (0 .5 .8) ?
# OVERVIEW
Combination of func_illusionary, func_wall, func_wall_toggle.
When triggered, it'll become invisible and lose its collision.

# KEYS
- "targetname" : Name
- "Solidity" : Mode for choosing solidity. 0 : Toggle, 1 : Never, 2 : Always.
- "StartDisabled" : Will make it spawn invisible.
- "solidbsp" : Type of collision model to choose. 0 : Per-Poly, 1 : BSP file.
- "excludednpc" : Name of the NPC classname that will not collide with this entity
- "invert_exclusion" : Set to 1 if you want the 'excludednpc' key to act inverted

# NOTES
The main thing func_brush is concerned with is appearance.
When you trigger it on/off, it'll be made visible/invisible.
Collision however depends on the setting of the "Solidity" key.
If "Solidity" is toggle, the collision will ne enabled/disabled depending
on whether or not the entity is visible/invisible.
By default it's visible and has collision.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup server
@ingroup brushentity
*/
class
func_brush:NSRenderableEntity
{
public:
	void func_brush(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void SpawnKey(string,string);

private:
	int m_iSolidity;
	int m_iStartOff;
};

void
func_brush::func_brush(void)
{
	m_iSolidity = 0i;
	m_iStartOff = 0i;
}

void
func_brush::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iSolidity", m_iSolidity);
	SaveInt(handle, "m_iStartOff", m_iStartOff);
}

void
func_brush::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iSolidity":
		m_iSolidity = ReadInt(strValue);
		break;
	case "m_iStartOff":
		m_iStartOff = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_brush::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "Solidity":
		m_iSolidity = stoi(strValue);
		break;
	case "StartDisabled":
		m_iStartOff = stoi(strValue);
		break;
	/* TODO: implement these */
	case "solidbsp":
		break;
	case "excludednpc":
		break;
	case "invert_exclusion":
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_brush::Respawn(void)
{
	super::Respawn();

	SetMovetype(MOVETYPE_PUSH);

	/* make sure solid and so on are set */
	if (m_iStartOff) {
		Trigger(this, TRIG_OFF);
	} else {
		Trigger(this, TRIG_ON);
	}
}

void
func_brush::Trigger(entity act, triggermode_t state)
{
	/* collision */
	switch (m_iSolidity) {
	case 1:
		SetSolid(SOLID_NOT);
		break;
	case 2:
		SetSolid(SOLID_BSP);
		break;
	default:
		switch (state) {
		case TRIG_OFF:
			SetSolid(SOLID_NOT);
			break;
		case TRIG_ON:
			SetSolid(SOLID_BSP);
			break;
		default:
			SetSolid(modelindex != 0 ? SOLID_NOT : SOLID_BSP);
		}
	}

	/* visual */
	switch (state) {
	case TRIG_OFF:
		SetModelindex(0);
		break;
	case TRIG_ON:
		SetModel(GetSpawnString("model"));
		break;
	default:
		if (modelindex != 0)
			SetModelindex(0);
		else
			SetModel(GetSpawnString("model"));
	}
}
