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

/*QUAKED prop_physics (0 0 0.8) (-16 -16 -16) (16 16 16)
Physics model

-------- KEYS --------
"targetname"    Name

-------- TRIVIA --------
This entity was introduced in Half-Life 2 (2004).
*/

class prop_physics:CBasePhysics
{
	void(void) prop_physics;
	virtual void(string, string) SpawnKey;
};

void
prop_physics::Respawn(void)
{
	CBasePhysics::Respawn();
}

void
prop_physics::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	default:
		CBasePhysics::SpawnKey(strKey, strValue);
	}
}

void
prop_physics::prop_physics(void)
{
	CBasePhysics::CBasePhysics();
}
