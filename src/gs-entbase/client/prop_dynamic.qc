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

/*QUAKED prop_dynamic (0 0.2 1) (-8 -8 -8) (8 8 8) SF_BASIC_COL
"model"       Model file that will be displayed by the entity.
"modelscale"  Scale modifier of the model. Default is '1'.
"angles"      Sets the pitch, yaw and roll angles of the model.
"_cs"         Toggles if the prop casts a shadow or not.

Client-side decorative model entity.

Trivia:
This entity was introduced in Half-Life 2 (2004).
*/

/*QUAKED prop_static (0 0.2 1) (-8 -8 -8) (8 8 8) SF_BASIC_COL
"model"           Model file that will be displayed by the entity.
"modelscale"      Scale modifier of the model. Default is '1'.
"modelscale_vec"  Scale modifier, but in vector format
"angles"          Sets the pitch, yaw and roll angles of the model.
"_cs"             Toggles if the prop casts a shadow or not.
"_ls"             Lightmap scale multiplier for the resulting surfaces.
"_sn"             Shading angle related to lightmap phong shading.
"_remap"          Force the model surfaces to use a specified material.

Decorative model entity that gets baked into the level file.
After compilation, the source model is no longer required and the
resulting entity is removed.

Trivia:
This entity was introduced in Half-Life 2 (2004).
*/

class prop_dynamic:CBaseEntity
{
	void(void) prop_dynamic;

	virtual void(void) Init;
	virtual void(string, string) SpawnKey;
	virtual float(void) predraw;
};

void
prop_dynamic::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "modelscale":
			scale = stof(strKey);
			break;
		case "angle":
			angles[1] = stof(strKey);
			break;
		case "avelocity":
			avelocity = stov(strKey);
			break;
		default:
			CBaseEntity::SpawnKey(strField, strKey);
	}
}
float
prop_dynamic::predraw(void)
{
	angles += avelocity * frametime;
	return CBaseEntity::predraw();
}

void
prop_dynamic::Init(void)
{
	CBaseEntity::Init();

	precache_model(model);
	setmodel(this, model);
	setorigin(this, origin);
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
	setsize(this, mins * scale, maxs * scale);
	drawmask = MASK_ENGINE;

	if (vlen(avelocity) == 0)
		MakeStatic();
}

void
prop_dynamic::prop_dynamic(void)
{
	scale = 1.0f;
	Init();
}

CLASSEXPORT(prop_static, prop_dynamic)
