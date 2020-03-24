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

/*QUAKED func_physbox (1 0 0) (-8 -8 -8) (8 8 8) ?
"targetname"    Name
"material"      Type of material the entity is made of. See func_breakable for full list.
Physics based brush entity
*/
/*class func_physbox:CBaseEntity
{
	int m_iShape;

	void() func_physbox;
	virtual void() Respawn;
	virtual void() touch;
};

void func_physbox::touch(void)
{
	//physics_addforce(this, other.velocity, other.origin);
}

void func_physbox::Respawn(void)
{
	movetype = MOVETYPE_PHYSICS;
	solid = SOLID_PHYSICS_BOX; // SOLID_PHYSICS_TRIMESH
	setmodel(this, m_oldModel);
	setorigin(this, m_oldOrigin);
	physics_enable(this, TRUE);
}

void prop_rope::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "material":
		//m_iMaterial = stof(argv(i + 1));
		break;
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}

void func_physbox::func_physbox(void)
{
	drawmask = MASK_ENGINE;
	Init();
}*/
