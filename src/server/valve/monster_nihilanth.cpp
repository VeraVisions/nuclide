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

/*QUAKED monster_nihilanth (0 0.8 0.8) (-192 -192 0) (192 192 384)

Nihilanth

*/

enum {
	NIH_IDLE,
	NIH_ATTACK,
	NIH_ATTACK2,
	NIH_THROW,
	NIH_BLOCK,
	NIH_RECHARGE,
	NIH_IDLEOPEN,
	NIH_ATTACKOPEN,
	NIH_ATTACKOPEN2,
	NIH_FLINCH,
	NIH_FLINCH2,
	NIH_FALL,
	NIH_DIE,
	NIH_FORWARD,
	NIH_BACK,
	NIH_UP,
	NIH_DOWN,
	NIH_RIGHT,
	NIH_LEFT,
	NIH_WALK2,
	NIH_SHOOT
};

class monster_nihilanth:CBaseMonster
{
	void() monster_nihilanth;
};

void monster_nihilanth::monster_nihilanth(void)
{
	netname = "Nihilanth";
	model = "models/nihilanth.mdl";
	base_health = Skill_GetValue("nihilanth_health");
	base_mins = [-192,-192,-32];
	base_maxs = [192,192,384];
	CBaseMonster::CBaseMonster();
}
