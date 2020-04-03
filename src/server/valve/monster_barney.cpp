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

/*QUAKED monster_barney (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

Barney Calhoun

*/

enum {
	BA_IDLE1,
	BA_IDLE2,
	BA_IDLE3,
	BA_IDLE4,
	BA_WALK,
	BA_RUN,
	BA_SHOOT1,
	BA_SHOOT2,
	BA_DRAW,
	BA_HOLSTER,
	BA_RELOAD,
	BA_TURNLEFT,
	BA_TURNRIGHT,
	BA_FLINCH_LA,
	BA_FLINCH_RA,
	BA_FLINCH_LL,
	BA_FLINCH_RL,
	BA_FLINCH_SML
};

class monster_barney:CBaseNPC
{
	void() monster_barney;

	virtual void() Respawn;
	virtual void() PlayerUse;
	virtual void(int) Pain;
	virtual void(int) Death;
	virtual int() AnimIdle;
	virtual int() AnimWalk;
	virtual int() AnimRun;
};

int
monster_barney::AnimIdle(void)
{
	return BA_IDLE1;
}

int
monster_barney::AnimWalk(void)
{
	return BA_WALK;
}

int
monster_barney::AnimRun(void)
{
	return BA_RUN;
}

void
monster_barney::PlayerUse(void)
{
	if (spawnflags & MSF_PREDISASTER) {
		Sentence("!BA_POK");
		return;
	}

	CBaseNPC::PlayerUse();
}

void
monster_barney::Pain(int iHitBody)
{
	WarnAllies();

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Speak(this, "monster_barney.pain");

	frame = BA_FLINCH_LA + floor(random(0, 5));
	m_iFlags |= MONSTER_FEAR;
	m_flAnimTime = time + 0.25f;
}

void 
monster_barney::Death(int iHitBody)
{
	WarnAllies();

	Sound_Speak(this, "monster_barney.die");

	if (style != MONSTER_DEAD) {
		frame = 25 + floor(random(0, 6));
		style = MONSTER_DEAD;
	}

	/* now mark our state as 'dead' */
	CBaseNPC::Death(iHitBody);
}

void
monster_barney::Respawn(void)
{
	CBaseNPC::Respawn();
	m_iFlags |= MONSTER_CANFOLLOW;
}

void
monster_barney::monster_barney(void)
{
	Sound_Precache("monster_barney.die");
	Sound_Precache("monster_barney.pain");

	/* TODO
	 * BA_MAD - When player gets too naughty
	 * */
	m_talkAnswer = "!BA_ANSWER";
	m_talkAsk = "!BA_QUESTION";
	m_talkAllyShot = "!BA_SHOOT";
	m_talkGreet = "";
	m_talkIdle = "!BA_IDLE";
	m_talkHearing = "!BA_HEAR";
	m_talkSmelling = "!BA_SMELL";
	m_talkStare = "!BA_STARE";
	m_talkSurvived = "!BA_WOUND";
	m_talkWounded = "!BA_WOUND";

	m_talkPlayerAsk = "!BA_QUESTION";
	m_talkPlayerGreet = "!BA_HELLO";
	m_talkPlayerIdle = "!BA_IDLE";
	m_talkPlayerWounded1 = "!BA_CUREA";
	m_talkPlayerWounded2 = "!BA_CUREB";
	m_talkPlayerWounded3 = "!BA_CUREC";
	m_talkUnfollow = "!BA_WAIT";
	m_talkFollow = "!BA_OK";
	m_talkStopFollow = "!BA_STOP";

	model = "models/barney.mdl";
	netname = "Barney";
	base_health = Skill_GetValue("barney_health");
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseNPC::CBaseNPC();
}
