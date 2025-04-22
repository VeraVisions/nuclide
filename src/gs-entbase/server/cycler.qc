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

/*! \brief Server-Entity: Debug Model Animation Cycler */
/*!QUAKED cycler (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Model animation cycler entity. For development purposes mainly.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "angles" : Sets the pitch, yaw and roll angles of the model.
- "sequence" : Sets the animation the model should start in. 
- "model" : Model file that will be displayed by the entity.

# NOTES
Upon damage, the cycler will switch between all available animation
sequences. This is really for test-maps and showroom entities.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
cycler:ncSurfacePropEntity
{
public:
	void cycler(void);
	
	virtual void Respawn(void);
	virtual void Pain(entity, entity, int, vector, vector, int);
};

void
cycler::cycler(void)
{
}

void
cycler::Respawn(void)
{
	super::Respawn();

	SetSolid(SOLID_BBOX);
	MakeVulnerable();
	EnableAimAssist();
	SetHealth(9999);

	if (serverkeyfloat("*bspversion") == BSPVER_HL) {
		SetSize(VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
	} else {
		SetSize(GetModelMins(), GetModelMaxs());
	}
}

void
cycler::Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	if (frame >= modelframecount(modelindex)) {
		SetFrame(0);
	} else {
		SetFrame(GetFrame() + 1);
	}

	SetHealth(9999);
}
