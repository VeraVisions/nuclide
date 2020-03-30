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

/*QUAKED monster_recruit (0 0.8 0.8) (-16 -16 0) (16 16 72)

Recruit

Opposing Force Boot-Camp Training

*/

enum {
	RECRUIT_IDLE,
	RECRUIT_WALK,
	RECRUIT_RUN,
	RECRUIT_TURNLEFT,
	RECRUIT_TURNRIGHT,
	RECRUIT_PUSHUPS,
	RECRUIT_JUMPINJACK,
	RECRUIT_SALUTE
};

class monster_recruit:CBaseNPC
{
	void() monster_recruit;
	virtual void() Respawn;
	virtual int() AnimIdle;
	virtual int() AnimWalk;
	virtual int() AnimRun;
};

int
monster_recruit::AnimIdle(void)
{
	return RECRUIT_IDLE;
}

int
monster_recruit::AnimWalk(void)
{
	return RECRUIT_WALK;
}

int
monster_recruit::AnimRun(void)
{
	return RECRUIT_RUN;
}

void
monster_recruit::Respawn(void)
{
	CBaseNPC::Respawn();
	takedamage = DAMAGE_NO;
	iBleeds = FALSE;
}

void
monster_recruit::monster_recruit(void)
{
	netname = "Recruit";
	model = "models/recruit.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseNPC::CBaseNPC();
}
