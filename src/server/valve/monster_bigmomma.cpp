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

/*QUAKED monster_bigmomma (0 0.8 0.8) (-95 -95 0) (95 95 190)

Gonarch

*/

enum {
	GON_IDLE,
	GON_IDLE2,
	GON_WALK,
	GON_RUN,
	GON_DIE,
	GON_CLAW,
	GON_CLAW2,
	GON_CLAW3,
	GON_SPAWN,
	GON_SHOOT,
	GON_FLINCH,
	GON_DEFEND,
	GON_JUMP,
	GON_ANGRY,
	GON_ANGRY2,
	GON_ANGRY3,
	GON_BREAKWALL,
	GON_FALL,
	GON_FALL2,
	GON_FALLDIE
};

/* the attack sounds are for when she spits? */
string gon_sndattack[] = {
	"gonarch/gon_attack1.wav",
	"gonarch/gon_attack2.wav",
	"gonarch/gon_attack3.wav"
};

/* mourns the death of her children */
string gon_sndchild[] = {
	"gonarch/gon_childdie1.wav",
	"gonarch/gon_childdie2.wav",
	"gonarch/gon_childdie3.wav"
};

string gon_snddie[] = {
	"gonarch/gon_die1.wav",
	"gonarch/gon_die2.wav",
	"gonarch/gon_die3.wav"
};

string gon_sndidle[] = {
	"gonarch/gon_sack1.wav",
	"gonarch/gon_sack2.wav",
	"gonarch/gon_sack3.wav"
};

string gon_sndpain[] = {
	"gonarch/gon_pain2.wav",
	"gonarch/gon_pain3.wav",
	"gonarch/gon_pain4.wav",
	"gonarch/gon_pain5.wav"
};

string gon_sndsee[] = {
	"gonarch/gon_alert1.wav",
	"gonarch/gon_alert2.wav",
	"gonarch/gon_alert3.wav"
};

/* has unique foot step sounds */
string gon_sndstep[] = {
	"gonarch/gon_step1.wav",
	"gonarch/gon_step2.wav",
	"gonarch/gon_step3.wav"
};

class monster_bigmomma:CBaseMonster
{
	float m_flIdleTime;

	void() monster_bigmomma;

	virtual void(int) Death;
	virtual void(int) Pain;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_bigmomma::IdleNoise(void)
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

	int rand = floor(random(0, gon_sndidle.length));
	Sound(gon_sndidle[rand]);
}

void
monster_bigmomma::Pain(int iHitBody)
{
	CBaseMonster::Pain(iHitBody);

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,gon_sndpain.length));
	Sound(gon_sndpain[rand]);
	frame = GON_FLINCH;
	m_flAnimTime = time + 0.25f;
}

void
monster_bigmomma::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		frame = GON_DIE;
		Sound("gonarch/gon_die1.wav");
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void
monster_bigmomma::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = GON_IDLE;
}

void monster_bigmomma::monster_bigmomma(void)
{
	for (int i = 0; i <gon_sndattack.length; i++) {
		precache_sound(gon_sndattack[i]);
	}
	for (int i = 0; i <gon_sndchild.length; i++) {
		precache_sound(gon_sndchild[i]);
	}
	for (int i = 0; i < gon_sndidle.length; i++) {
		precache_sound(gon_sndidle[i]);
	}
	for (int i = 0; i < gon_sndpain.length; i++) {
		precache_sound(gon_sndpain[i]);
	}
	for (int i = 0; i <gon_sndsee.length; i++) {
		precache_sound(gon_sndsee[i]);
	}
	for (int i = 0; i <gon_sndstep.length; i++) {
		precache_sound(gon_sndstep[i]);
	}

	precache_sound("gonarch/gon_die1.wav");

	netname = "Gonarch";
	model = "models/big_mom.mdl";
	/* health is based on factor, for it's not killable until last stage */
	base_health = Skill_GetValue("bigmomma_health_factor") * 300;
	base_mins = [-95,-95,0];
	base_maxs = [95,95,190];
	CBaseMonster::CBaseMonster();
}
