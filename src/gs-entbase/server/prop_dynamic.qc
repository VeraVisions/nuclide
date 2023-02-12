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

#define PRPDYN_NONSOLID 256

/*!QUAKED prop_dynamic (0 0.2 1) (-8 -8 -8) (8 8 8) x x x x x x x x PRPDYN_NONSOLID
# OVERVIEW
Client-side decorative model entity.

# KEYS
- "model" : Model file that will be displayed by the entity.
- "modelscale" : Scale modifier of the model. Default is "1".
- "angles" : Sets the pitch, yaw and roll angles of the model.
- "_cs" : Toggles if the prop casts a shadow or not.
- "solid" : Specifies which collision model to use (0: Nonsolid; 2: BBox; 6: Per-poly)

# SPAWNFLAGS
- PRPDYN_NONSOLID (256) : Prop is non-solid.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
There are two ways of making a prop_dynamic non-solid.
*/
class
prop_dynamic:NSSurfacePropEntity
{
public:
	void prop_dynamic(void);
	
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
};

void
prop_dynamic::prop_dynamic(void)
{
}

void
prop_dynamic::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "frame":
	case "sequence":
		frame = stof(strValue);
		break;
	case "solid":
		float s = stof(strValue);

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
	}
}

void
prop_dynamic::Respawn(void)
{
	super::Respawn();
	SetModel(GetSpawnModel());

	if (HasSpawnFlags(PRPDYN_NONSOLID))
		SetSolid(SOLID_NOT);
}
