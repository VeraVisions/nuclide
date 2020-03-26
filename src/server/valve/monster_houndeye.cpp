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

/*QUAKED monster_houndeye (0 0.8 0.8) (-16 -16 0) (16 16 36)

Houndeye

*/

enum {
	HE_IDLE,
	HE_IDLE2,
	HE_IDLE3,
	HE_RUN,
	HE_RUN2,
	HE_RUN3,
	HE_DIE,
	HE_DIE2,
	HE_DIE3,
	HE_DIE4,
	HE_ATTACK,
	HE_FLINCH,
	HE_FLINCH2,
	HE_DIE5,
	HE_WALKLIMP,
	HE_WALK2,
	HE_LEADERLOOK,
	HE_SLEEP,
	HE_GOTOSLEEP,
	HE_WAKE,
	HE_IDLEMAD,
	HE_IDLEMAD2,
	HE_IDLEMAD3,
	HE_INSPECT,
	HE_EAT,
	HE_LEFT,
	HE_RIGHT,
	HE_JUMPBACK,
	HE_WAKEFAST,
	HE_WHIMPER,
	HE_JUMPWINDOW
};

string he_sndattack[] = {
	"houndeye/he_attack1.wav",
	"houndeye/he_attack2.wav",
	"houndeye/he_attack3.wav"
};

string he_snddie[] = {
	"houndeye/he_die1.wav",
	"houndeye/he_die2.wav",
	"houndeye/he_die3.wav"
};

/* Not sure where the hunt sounds are actually used */
string he_sndidle[] = {
	"houndeye/he_hunt1.wav",
	"houndeye/he_hunt2.wav",
	"houndeye/he_hunt3.wav",
	"houndeye/he_hunt4.wav",
	"houndeye/he_idle1.wav",
	"houndeye/he_idle2.wav",
	"houndeye/he_idle3.wav",
	"houndeye/he_idle4.wav",
};

string he_sndpain[] = {
	"houndeye/he_pain1.wav",
	"houndeye/he_pain2.wav",
	"houndeye/he_pain3.wav",
	"houndeye/he_pain4.wav",
	"houndeye/he_pain5.wav"
};

string he_sndsee[] = {
	"houndeye/he_alert1.wav",
	"houndeye/he_alert2.wav",
	"houndeye/he_alert3.wav"
};

class monster_houndeye:CBaseMonster
{
	float m_flIdleTime;
	float m_flPainTime;

	void() monster_houndeye;

	virtual void(int) Pain;
	virtual void(int) Death;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_houndeye::Pain(int iHitBody)
{
	CBaseMonster::Pain(iHitBody);

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,he_sndpain.length));
	Sound(he_sndpain[rand]);
	frame = HE_FLINCH + floor(random(0, 2));
	m_flPainTime = time + 0.25f;
}

void
monster_houndeye::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		frame = HE_DIE + floor(random(0, 4));

		/* the sound */
		int rand = floor(random(0,he_snddie.length));
		Sound(he_snddie[rand]);
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void
monster_houndeye::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + 2.0f + random(0,5);

	int rand = floor(random(0, he_sndidle.length));
	Sound(he_sndidle[rand]);
}

void
monster_houndeye::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = HE_IDLE;
}

void
monster_houndeye::monster_houndeye(void)
{
	for (int i = 0; i < he_sndattack.length; i++) {
		precache_sound(he_sndattack[i]);
	}
	for (int i = 0; i < he_snddie.length; i++) {
		precache_sound(he_snddie[i]);
	}
	for (int i = 0; i < he_sndidle.length; i++) {
		precache_sound(he_sndidle[i]);
	}
	for (int i = 0; i < he_sndpain.length; i++) {
		precache_sound(he_sndpain[i]);
	}
	for (int i = 0; i < he_sndsee.length; i++) {
		precache_sound(he_sndsee[i]);
	}

	netname = "Houndeye";
	model = "models/houndeye.mdl";
	base_health = Skill_GetValue("houndeye_health");
	base_mins = [-16,-16,0];
	base_maxs = [16,16,36];
	CBaseMonster::CBaseMonster();
}
