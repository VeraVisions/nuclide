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

/*QUAKED monster_drillsergeant (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

Drill Sergeant
...from the Opposing Force Boot-Camp Training

*/

enum
{
	DRILL_IDLE1,
	DRILL_IDLE2,
	DRILL_IDLE3,
	DRILL_WALK,
	DRILL_RUN,
	DRILL_TURNLEFT,
	DRILL_TURNRIGHT,
	DRILL_FLINCH,
	DRILL_DIESIMPLE,
	DRILL_DIEBACKWARD,
	DRILL_DIEFORWARD,
	DRILL_DEADONSIDE,
	DRILL_DEADONSTOMACH,
	DRILL_HANDSONHIPS,
	DRILL_POINT1,
	DRILL_POINT2,
	DRILL_BARK,
	DRILL_YELLHARD,
	DRILL_BARKHARD,
	DRILL_WHISTLE,
	DRILL_BINOCULARS
};

class monster_drillsergeant:CBaseNPC
{
	void() monster_drillsergeant;
	virtual void() Respawn;
	virtual int() AnimIdle;
	virtual int() AnimWalk;
	virtual int() AnimRun;
};

int
monster_drillsergeant::AnimIdle(void)
{
	return DRILL_IDLE1;
}

int
monster_drillsergeant::AnimWalk(void)
{
	return DRILL_WALK;
}

int
monster_drillsergeant::AnimRun(void)
{
	return DRILL_RUN;
}

void
monster_drillsergeant::Respawn(void)
{
	CBaseNPC::Respawn();
	takedamage = DAMAGE_NO;
	iBleeds = FALSE;
}

void
monster_drillsergeant::monster_drillsergeant(void)
{
	netname = "Drill Sergeant";
	model = "models/drill.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseNPC::CBaseNPC();
}
