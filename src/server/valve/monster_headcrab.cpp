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

/*QUAKED monster_headcrab (0 0.8 0.8) (-16 -16 0) (16 16 36)

Headcrab

*/

enum {
	HCBA_IDLE1,
	HCBA_IDLE2,
	HCBA_IDLE3,
	HCBA_WALK,
	HCBA_RUN,
	HCBA_ANGRY,
	HCBA_FLINCH,
	HCBA_DEATH,
	HCBA_180_LEFT,
	HCBA_180_RIGHT,
	HCBA_JUMP,
	HCBA_JUMP_VARIATION1,
	HCBA_JUMP_VARIATION2,
	HCBA_YAW_ADJUSTMENT,
	HCBA_HEADCRABBED1,
	HCBA_HEADCRABBED2,
	HCBA_HEADIDLE,
	HCBA_CRASHIDLE,
	HCBA_CRASH,
	HCBA_STRUGGLEIDLE,
	HCBA_STRUGGLE
};

string hcb_sndattack[] = {
	"headcrab/hc_attack1.wav",
	"headcrab/hc_attack2.wav",
	"headcrab/hc_attack3.wav"
};

string hcb_snddie[] = {
	"headcrab/hc_die1.wav",
	"headcrab/hc_die2.wav"
};

string hcb_sndidle[] = {
	"headcrab/hc_idle1.wav",
	"headcrab/hc_idle2.wav",
	"headcrab/hc_idle3.wav",
	"headcrab/hc_idle4.wav",
	"headcrab/hc_idle5.wav"
};

string hcb_sndpain[] = {
	"headcrab/hc_pain1.wav",
	"headcrab/hc_pain2.wav",
	"headcrab/hc_pain3.wav"
};

string hcb_sndsee[] = {
	"headcrab/hc_alert1.wav",
	"headcrab/hc_alert2.wav"
};

class monster_headcrab:CBaseMonster
{
	float m_flIdleTime;
	float m_flPainTime;

	void() monster_headcrab;

	virtual void(int) Pain;
	virtual void(int) Death;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_headcrab::Pain(int iHitBody)
{
	CBaseMonster::Pain(iHitBody);

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,hcb_sndpain.length));
	Speak(hcb_sndpain[rand]);
	frame = HCBA_FLINCH;
	m_flPainTime = time + 0.25f;
}

void
monster_headcrab::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		frame = HCBA_DEATH;

		/* the sound */
		int rand = floor(random(0,hcb_sndpain.length));
		Speak(hcb_sndpain[rand]);
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void
monster_headcrab::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + 2.0f + random(0,5);

	int rand = floor(random(0, hcb_sndidle.length));
	Speak(hcb_sndidle[rand]);
}

void
monster_headcrab::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = HCBA_IDLE1;
}

void
monster_headcrab::monster_headcrab(void)
{
	for (int i = 0; i < hcb_sndattack.length; i++) {
		precache_sound(hcb_sndattack[i]);
	}
	for (int i = 0; i < hcb_snddie.length; i++) {
		precache_sound(hcb_snddie[i]);
	}
	for (int i = 0; i < hcb_sndidle.length; i++) {
		precache_sound(hcb_sndidle[i]);
	}
	for (int i = 0; i < hcb_sndpain.length; i++) {
		precache_sound(hcb_sndpain[i]);
	}
	for (int i = 0; i < hcb_sndsee.length; i++) {
		precache_sound(hcb_sndsee[i]);
	}
	netname = "Headcrab";
	model = "models/headcrab.mdl";
	base_health = Skill_GetValue("headcrab_health");
	base_mins = [-16,-16,0];
	base_maxs = [16,16,36];
	CBaseMonster::CBaseMonster();
}
