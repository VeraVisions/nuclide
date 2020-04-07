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

/*
=================
CSQC_Ent_Update

Called whenever an entity is sent manually via .SendFlags and so on
=================
*/
void CSQC_Ent_Update(float new)
{
	float t;
	t = readbyte();

	switch (t) {
	case ENT_ENTITY:
		CBaseEntity me = (CBaseEntity)self;
		if (new) {
			spawnfunc_CBaseEntity();
		}
		me.ReadEntity(readfloat());
		break;
	case ENT_PLAYER:
		Player_ReadEntity(new);
		break;
	case ENT_SPRITE:
		env_sprite spr = (env_sprite)self;
		if (new) {
			spawnfunc_env_sprite();
		}
		spr.ReadEntity(readfloat());
		break;
		break;
	case ENT_SPRAY:
		Spray_Parse();
		break;
	case ENT_DECAL:
		Decal_Parse();
		break;
	case ENT_AMBIENTSOUND:
		Sound_ParseLoopingEntity(self, new);
		break;
	case ENT_ENVLASER:
		env_laser l = (env_laser)self;
		if (new) {
			spawnfunc_env_laser();
		}
		l.ReadEntity(readfloat());
		break;
	default:
		if (Game_Entity_Update(t, new) == FALSE) {
			error("Unknown entity type update received.\n");
		}
	}
}
