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

/*QUAKED func_brush (0 .5 .8) ?
Combination of func_illusionary, func_wall, func_wall_toggle.
When triggered, it'll become invisible and lose its collision.

-------- KEYS --------
"targetname"        Name

"Solidity"          Mode for choosing solidity:
                    0 - Toggle
                    1 - Never solid
                    2 - Always Solid
"StartDisabled"     Will make it spawn invisible and without collision.
"solidbsp"          Type of collision model to choose
"excludednpc"       Name of the NPC classname that will not collide with this
                    entity
"invert_exclusion"  Set to 1 if you want the 'excludednpc' key to act inverted

-------- NOTES --------
The main thing func_brush is concerned with is appearance, if it's toggled on
it will always become visible, when toggled off it'll always be invisible.
Collision however depends on the setting of the "Solidity" key.

-------- HISTORY --------
This entity was introduced in Half-Life 2 (2004).
*/

class func_brush:CBaseTrigger
{
	int m_iSolidity;
	int m_iStartOff;

	void(void) func_brush;

	virtual void(entity,int) Trigger;
	virtual void(string,string) SpawnKey;
	virtual void(void) Respawn;
};

void
func_brush::Trigger(entity act, int state)
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
		SetModel(m_oldModel);
		break;
	default:
		if (modelindex != 0)
			SetModelindex(0);
		else
			SetModel(m_oldModel);
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
	}
}

void
func_brush::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);

	/* make sure solid and so on are set */
	if (m_iStartOff) {
		Trigger(this, TRIG_OFF);
	} else {
		Trigger(this, TRIG_ON);
	}
}

void
func_brush::func_brush(void)
{
	CBaseTrigger::CBaseTrigger();
	Respawn();
}
