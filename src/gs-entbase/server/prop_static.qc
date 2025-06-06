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

/*! \brief Server-Entity: Static Prop Model */
/*!QUAKED prop_static (1 0 0) (-8 -8 -8) (8 8 8) SF_BASIC_COL
# OVERVIEW
Decorative model entity that gets baked into the level file.

# KEYS
- "model" : Model file that will be displayed by the entity.
- "modelscale" : Scale modifier of the model. Default is "1".
- "modelscale_vec" : Scale modifier, but in vector format
- "angles" : Sets the pitch, yaw and roll angles of the model.
- "_cs" : Toggles if the prop casts a shadow or not.
- "_ls" : Lightmap scale multiplier for the resulting surfaces.
- "_sn" : Shading angle related to lightmap phong shading.
- "_remap" : Force the model surfaces to use a specified material.

# NOTES
After compilation, the source model is no longer required and the
resulting entity is removed. This ensures that models are rendered in the
same batch as the world. This makes sense for one giant unique model in
the map, but for multiple repetitive uses of the same model you'll actually
waste disk space and memory. Use wisely.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
prop_static:ncPhysicsEntity
{
public:
	void prop_static(void);
	
	virtual void Respawn(void);

};

void
prop_static::prop_static(void)
{
}

void
prop_static::Respawn(void)
{
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetMovetype(MOVETYPE_PHYSICS);
	SetSolid(SOLID_PHYSICS_BOX);
	geomtype = GEOMTYPE_TRIMESH;

	Sleep();
	MakeInvulnerable();
	touch = __NULL__;
}
