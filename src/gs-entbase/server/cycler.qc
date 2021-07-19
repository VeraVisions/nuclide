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

/*QUAKED cycler (1 0 0) (-8 -8 -8) (8 8 8)
Animation cycler entity. For development purposes mainly.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"angles" : Sets the pitch, yaw and roll angles of the model.
"sequence" : Sets the animation the model should start in. 
"model" : Model file that will be displayed by the entity.

-------- NOTES --------
Upon damage, the cycler will switch between all available animation
sequences. This is really for test-maps and showroom entities.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class cycler:CBaseTrigger
{
	void(void) cycler;
	virtual void(void) Respawn;
	virtual void(void) Pain;
};

void
cycler::Pain(void)
{
	if (frame >= modelframecount(modelindex)) {
		frame = 0;
	} else {
		frame += 1;
	}
	health = 9999;
}

void
cycler::Respawn(void)
{
	CBaseEntity::Respawn();
	SetSolid(SOLID_BBOX);
	takedamage = DAMAGE_YES;
	health = 9999;
}

void
cycler::cycler(void)
{
	CBaseEntity::CBaseEntity();
}
