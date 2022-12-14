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

enumflags
{
	MF_WAITTILSEEN,
	MF_GAG,
	MF_MONSTERCLIP,
	MF_PRISONER,
	MF_UNUSED,
	MF_WAITFORSCRIPT,
	MF_PREDISASTER,
	MF_FADECORPSE
};

/*!QUAKED monster_furniture (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Decorative, does nothing yet.

# KEYS
- "targetname" : Name
- "angles" : Sets the pitch, yaw and roll angles of the model.
- "model" : Model file that will be displayed by the entity.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
monster_furniture:NSMonster
{
public:
	void monster_furniture(void);
	
	virtual void Respawn(void);

};

void
monster_furniture::monster_furniture(void)
{
	spawnflags |= MSF_MULTIPLAYER;
}

void
monster_furniture::Respawn(void)
{
	SetMovetype(MOVETYPE_NOCLIP);
	SetSolid(SOLID_NOT);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());
}

CLASSEXPORT(ts_model, monster_furniture)
