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

/*QUAKED func_physbox_multiplayer (0 .5 .8) ?
"targetname"    Name

Physics brush (server) - same for all player on server
*/

/*QUAKED func_physbox (0 .5 .8) ?
"targetname"    Name

Physics brush (client)
*/

class func_physbox:CBaseEntity
{
	int m_iShape;

	void(void) func_physbox;
	virtual void(void) Respawn;
	virtual void(void) touch;
	virtual void(string, string) SpawnKey;
};

void func_physbox::touch(void)
{
	//physics_addforce(this, other.velocity, other.origin);
}

void func_physbox::Respawn(void)
{
	SetMovetype(MOVETYPE_PHYSICS);
	SetSolid(SOLID_PHYSICS_BOX); // SOLID_PHYSICS_TRIMESH
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	physics_enable(this, TRUE);
}

void
func_physbox::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "material":
		//m_iMaterial = stof(strValue);
		break;
	default:
		CBaseEntity::SpawnKey(strKey, strValue);
	}
}

void func_physbox::func_physbox(void)
{
	if (!model) {
		remove(this);
		return;
	}

	CBaseEntity::CBaseEntity();

}

CLASSEXPORT(func_physbox, func_physbox)
CLASSEXPORT(func_physbox_multiplayer, func_physbox)
