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

/*QUAKED monster_bullchicken (0 0.8 0.8) (-32 -32 0) (32 32 64)

Bullsquid

*/

enum {
	BULL_WALK,
	BULL_RUN,
	BULL_SURPIRSE,
	BULL_FLINCH,
	BULL_FLINCH2,
	BULL_LEFT,
	BULL_RIGHT,
	BULL_IDLE,
	BULL_WHIP,
	BULL_BITE,
	BULL_RANGE,
	BULL_LOOK,
	BULL_SEECRAB,
	BULL_EAT,
	BULL_INSPECT,
	BULL_SNIFF,
	BULL_DIE,
	BULL_DIE2,
	BULL_JUMP,
	BULL_DRAGIDLE,
	BULL_DRAG,
	BULL_SCARE,
	BULL_FALLIDLE,
	BULL_FALL
};

class monster_bullchicken:CBaseMonster
{
	void() monster_bullchicken;
};

void monster_bullchicken::monster_bullchicken(void)
{
	netname = "Bullsquid";
	model = "models/bullsquid.mdl";
	base_mins = [-32,-32,0];
	base_maxs = [32,32,64];
	CBaseMonster::CBaseMonster();
}
