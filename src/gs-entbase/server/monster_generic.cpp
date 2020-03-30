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

/*QUAKED monster_generic (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"angles"        Sets the pitch, yaw and roll angles of the model.
"model"         Model file that will be displayed by the entity.

Decorative, does nothing yet.
*/

class monster_generic:CBaseNPC
{
	void() monster_generic;
	virtual void() Respawn;
};

void
monster_generic::Respawn(void)
{
	CBaseNPC::Respawn();
	takedamage = DAMAGE_NO;
	iBleeds = FALSE;
	solid = SOLID_NOT;
}

void
monster_generic::monster_generic(void)
{
	base_mins = VEC_HULL_MIN;
	base_maxs = VEC_HULL_MAX;
	CBaseNPC::CBaseNPC();
}
