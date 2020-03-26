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

/*QUAKED monster_gargantua (0 0.8 0.8) (-32 -32 0) (32 32 128)

Gargantua

*/

enum {
	GARG_IDLE,
	GARG_IDLE2,
	GARG_IDLE3,
	GARG_IDLE4,
	GARG_WALK,
	GARG_RUN,
	GARG_SHOOT,
	GARG_SHOOT2,
	GARG_ATTACK,
	GARG_STOMP,
	GARG_LEFT,
	GARG_RIGHT,
	GARG_FLINCH,
	GARG_FLINCH2,
	GARG_DIE,
	GARG_BITEHEAD,
	GARG_THROW,
	GARG_SMASH,
	GARG_ROLLCAR,
	GARG_KICKCAR,
	GARG_PUSHCAR,
	GARG_BUST
};

class monster_gargantua:CBaseMonster
{
	void() monster_gargantua;
};

void monster_gargantua::monster_gargantua(void)
{
	netname = "Gargantua";
	model = "models/garg.mdl";
	base_mins = [-32,-32,0];
	base_maxs = [32,32,128];
	CBaseMonster::CBaseMonster();
}
