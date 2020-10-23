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
 
/*QUAKED light_environment (1 0 0) (-8 -8 -8) (8 8 8) ?

STUB!
*/

class light_environment:CBaseEntity
{
	void(void) light_environment;
	virtual void(void) Init;
	virtual void(void) Initialized;
	virtual void(string, string) SpawnKey;
};

void
light_environment::Init(void)
{
	CBaseEntity::Init();
	setorigin(this, origin);
	drawmask = MASK_ENGINE;
}

void
light_environment::Initialized(void)
{
	makevectors(g_vecSunDir);
	cvar_set("r_shadows_throwdirection", sprintf("%v", v_forward));
}

void
light_environment::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "pitch":
		g_vecSunDir[0] = stof(strKey);
		break;
	case "sunangle":
		g_vecSunDir[1] = stof(strKey);
		break;
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}

void
light_environment::light_environment(void)
{
	solid = SOLID_NOT;
	Init();
}
