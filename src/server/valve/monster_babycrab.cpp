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

/*QUAKED monster_babycrab (0 0.8 0.8) (-16 -16 0) (16 16 36)

Baby Headcrab

*/

enum {
	BHCB_IDLE,
	BHCB_IDLE2,
	BHCB_IDLE3,
	BHCB_WALK,
	BHCB_RUN,
	BHCB_ANGRY,
	BHCB_FLINCH,
	BHCB_DIEBACK,
	BHCB_LEFT,
	BHCB_RIGHT,
	BHCB_JUMP,
	BHCB_JUMP2,
	BHCB_JUMP3
};

class monster_babycrab:CBaseMonster
{
	void() monster_babycrab;
};

void monster_babycrab::monster_babycrab(void)
{
	netname = "Baby Headcrab";
	model = "models/baby_headcrab.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,36];
	CBaseMonster::CBaseMonster();
}
