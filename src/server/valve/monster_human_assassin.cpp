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

/*QUAKED monster_human_assassin (0 0.8 0.8) (-16 -16 0) (16 16 72)

Black Ops - Assassin

*/

enum {
	HAS_IDLE,
	HAS_IDLE3,
	HAS_IDLE2,
	HAS_RUN,
	HAS_WALK,
	HAS_SHOOT,
	HAS_NADETHROW,
	HAS_KICK,
	HAS_KICK2,
	HAS_DIERUN,
	HAS_DIEBACK,
	HAS_DIE,
	HAS_JUMP,
	HAS_UP,
	HAS_UNUSED,
	HAS_ATTACKDOWN,
	HAS_LAND
};

class monster_human_assassin:CBaseMonster
{
	float m_flIdleTime;

	void() monster_human_assassin;

	virtual void(int) Death;
	virtual void(void) Respawn;
};

void
monster_human_assassin::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		frame = HAS_DIE + floor(random(0, 3));
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void
monster_human_assassin::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = HAS_IDLE;
}

void 
monster_human_assassin::monster_human_assassin(void)
{
	netname = "Assassin";
	model = "models/hassassin.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseMonster::CBaseMonster();
}
