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
	MF_WAITTILSEEN,
	MF_GAG,
	MF_MONSTERCLIP,
	MF_PRISONER,
	MF_UNUSED,
	MF_WAITFORSCRIPT,
	MF_PREDISASTER,
	MF_FADECORPSE
};

/*! \brief Server-Entity: Scripted Sequence Prop */
/*!QUAKED monster_furniture (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Used for props to be animated within a scripted sequence.

# KEYS
- "targetname" : Name
- "angles" : Sets the pitch, yaw and roll angles of the model.
- "model" : Model file that will be displayed by the entity.
- "solid" : 0 - None - 2 = bbox (defauLt), 6 = bsp/per-poly Collision.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
monster_furniture:ncMonster
{
public:
	void monster_furniture(void);
	
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);

};

void
monster_furniture::monster_furniture(void)
{
	spawnflags |= MSF_MULTIPLAYER;
	solid = SOLID_BBOX;
}

void
monster_furniture::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "solid":
		float s = ReadFloat(strValue);

		switch (s) {
		case 2:
			SetSolid(SOLID_BBOX);
			break;
		case 6:
			SetSolid(SOLID_BSP);
			break;
		default:
			SetSolid(SOLID_NOT);
		}
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
monster_furniture::Respawn(void)
{
	SetMovetype(MOVETYPE_NOCLIP);

	if (GetSolid() == SOLID_BBOX) {
		SetSize([-16, -16, 0], [16, 16, 72]);
	}
}
