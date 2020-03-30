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

/* the growls are used in combination with the bite sounds
 * for close range attacks
 */

string bull_sndattack[] = {
	"bullchicken/bc_attackgrowl1.wav",
	"bullchicken/bc_attackgrowl2.wav",
	"bullchicken/bc_attackgrowl3.wav"
};

string bull_sndattackbite[] = {
	"bullchicken/bc_bite1.wav",
	"bullchicken/bc_bite2.wav",
	"bullchicken/bc_bite3.wav"
};

string bull_sndattackshoot[] = {
	"bullchicken/bc_attack1.wav",
	"bullchicken/bc_attack2.wav",
	"bullchicken/bc_attack3.wav"
};

string bull_snddie[] = {
	"bullchicken/bc_die1.wav",
	"bullchicken/bc_die2.wav",
	"bullchicken/bc_die3.wav"
};

string bull_sndidle[] = {
	"bullchicken/bc_idle1.wav",
	"bullchicken/bc_idle2.wav",
	"bullchicken/bc_idle3.wav",
	"bullchicken/bc_idle4.wav",
	"bullchicken/bc_idle5.wav"
};

string bull_sndpain[] = {
	"bullchicken/bc_pain1.wav",
	"bullchicken/bc_pain2.wav",
	"bullchicken/bc_pain3.wav",
	"bullchicken/bc_pain4.wav"
};


class monster_bullchicken:CBaseMonster
{
	float m_flIdleTime;

	void() monster_bullchicken;

	virtual void(int) Death;
	virtual void(int) Pain;
	virtual void() IdleNoise;
	virtual int() AnimIdle;
	virtual int() AnimWalk;
	virtual int() AnimRun;
};

int
monster_bullchicken::AnimIdle(void)
{
	return BULL_IDLE;
}

int
monster_bullchicken::AnimWalk(void)
{
	return BULL_WALK;
}

int
monster_bullchicken::AnimRun(void)
{
	return BULL_RUN;
}

void
monster_bullchicken::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	/* timing needs to adjusted as sounds conflict */
	m_flIdleTime = time + 2.0f + random(0,5);

	int rand = floor(random(0, bull_sndidle.length));
	Sound(bull_sndidle[rand]);
}

void
monster_bullchicken::Pain(int iHitBody)
{
	CBaseMonster::Pain(iHitBody);

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,bull_sndpain.length));
	Sound(bull_sndpain[rand]);
	frame = (random() < 0.5) ? BULL_FLINCH : BULL_FLINCH2;
	m_flAnimTime = time + 0.25f;
}

void
monster_bullchicken::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {

	/* two different animations */
	frame = (random() < 0.5) ? BULL_DIE : BULL_DIE2;

		/* the sound */
		int rand = floor(random(0,bull_snddie.length));
		Sound(bull_snddie[rand]);
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void monster_bullchicken::monster_bullchicken(void)
{
	for (int i = 0; i <bull_sndattack.length; i++) {
		precache_sound(bull_sndattack[i]);
	}
	for (int i = 0; i <bull_sndattackbite.length; i++) {
		precache_sound(bull_sndattackbite[i]);
	}
	for (int i = 0; i <bull_sndattackshoot.length; i++) {
		precache_sound(bull_sndattackshoot[i]);
	}
	for (int i = 0; i < bull_snddie.length; i++) {
		precache_sound(bull_snddie[i]);
	}
	for (int i = 0; i < bull_sndidle.length; i++) {
		precache_sound(bull_sndidle[i]);
	}
	for (int i = 0; i < bull_sndpain.length; i++) {
		precache_sound(bull_sndpain[i]);
	}

	netname = "Bullsquid";
	model = "models/bullsquid.mdl";
	base_health = Skill_GetValue("bullsquid_health");
	base_mins = [-32,-32,0];
	base_maxs = [32,32,64];
	CBaseMonster::CBaseMonster();
}
