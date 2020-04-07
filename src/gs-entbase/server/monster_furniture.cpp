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

/*QUAKED monster_furniture (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"angles"        Sets the pitch, yaw and roll angles of the model.
"model"         Model file that will be displayed by the entity.

Decorative, does nothing yet.
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

class monster_furniture : CBaseEntity
{
	void() monster_furniture;
	//virtual void() Respawn;
};

void monster_furniture :: monster_furniture ( void )
{
	precache_model( model );
	setmodel( this, model );
	CBaseEntity::CBaseEntity();
	
#if 1
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;
	//self.avelocity = '0 90 0 ';
	//self.modelflags = MF_ROTATE;
#endif
}

CLASSEXPORT(ts_model, monster_furniture)
