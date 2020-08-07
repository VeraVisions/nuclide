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

/*QUAKED infodecal (1 0 0) (-2 -2 -2) (2 2 2)
"targetname" Name
"texture"    Name of the texture inside decals.wad it projects onto a surface.

This entity currently only works on BSP version 30 levels.
Projects a decals.wad texture onto the nearest surface.
It'll automatically figure out the surface based on distance.
The texture will be aligned along the surface texture normals.

If a targetname is supplied, it will have to be triggered by an entity in order
to appear. Afterwards it cannot be triggered again.

It will pick the nearest wall (currently checking a distance of 128 units,
which is probably overkill). No angle has to be supplied.
*/

class infodecal:CBaseTrigger
{
	string m_strTexture;

	void(void) infodecal;
	virtual void(int) Trigger;
	virtual void(void) Respawn;
};

/* TODO: Handle state? */
void
infodecal::Trigger(int state)
{
	decal new = spawn(decal);
	new.Place(origin, m_strTexture);
	remove(this);
}

void
infodecal::Respawn(void)
{
	/* this will be invisible by default */
	if (!m_strTargetName) {
		/* spawn automatically, remove self */
		Trigger(TRIG_TOGGLE);
	}
}

void
infodecal::infodecal(void)
{
	if (serverkeyfloat("*bspversion") != 30) {
		remove(self);
		return;
	}

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "material":
		case "texture":
			m_strTexture = strtolower(argv(i+1));
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
}
