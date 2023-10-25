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

#define MGF_NONSOLID 4

/*!QUAKED monster_generic (1 0 0) (-8 -8 -8) (8 8 8) x x MGF_NONSOLID
# OVERVIEW
A 'monster' that is able to bleed, speak and follow scripted sequences.

# KEYS
- "targetname" : Name
- "angles" : Sets the pitch, yaw and roll angles of the model.
- "model" : Model file that will be displayed by the entity.

# SPAWNFLAGS
- MGF_NONSOLID (4) : Don't test collision against this entity.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
monster_generic:NSTalkMonster
{
public:
	void monster_generic(void);
	
	virtual void Respawn(void);

};

void
monster_generic::monster_generic(void)
{
	/* hackhackhackhackack */
	if (model == "models/player.mdl" || model == "models/holo.mdl") {
		base_mins = VEC_HULL_MIN;
		base_maxs = VEC_HULL_MAX;
	} else {
		base_mins = [-16,-16,0];
		base_maxs = [16,16,72];
	}
	base_health = 100;
	m_iAlliance = MAL_NEUTRAL;

	spawnflags |= MSF_MULTIPLAYER;
}

void
monster_generic::Respawn(void)
{
	super::Respawn();
	SetSize(base_mins, base_maxs);

	if (HasSpawnFlags(MGF_NONSOLID)) {
		takedamage = DAMAGE_NO;
		SetSolid(SOLID_NOT);
		SetCanBleed(false);
	}
}
