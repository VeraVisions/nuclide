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

/*QUAKED monster_alien_controller (0 0.8 0.8) (-16 -16 0) (16 16 72)

HALF-LIFE (1998) ENTITY

Alien Controller

*/

enum {
	CON_ATTACK,
	CON_ATTACK2,
	CON_THROW,
	CON_IDLE2,
	CON_BLOCK,
	CON_SHOOT,
	CON_FLINCH,
	CON_FLINCH2,
	CON_FALL,
	CON_FORWARD,
	CON_BACKWARD,
	CON_UP,
	CON_DOWN,
	CON_RIGHT,
	CON_LEFT,
	CON_IDLE,
	CON_UNUSED,
	CON_UNUSED2,
	CON_DIE
};

string con_sndattack[] = {
	"controller/con_attack1.wav",
	"controller/con_attack2.wav",
	"controller/con_attack3.wav"
};

string con_sndidle[] = {
	"controller/con_idle1.wav",
	"controller/con_idle2.wav",
	"controller/con_idle3.wav",
	"controller/con_idle4.wav",
	"controller/con_idle5.wav"
};

string con_sndpain[] = {
	"controller/con_pain1.wav",
	"controller/con_pain2.wav",
	"controller/con_pain3.wav"
};

string con_sndsee[] = {
	"controller/con_alert1.wav",
	"controller/con_alert2.wav",
	"controller/con_alert3.wav"
};

class monster_alien_controller:CBaseMonster
{
	float m_flIdleTime;
	float m_flPainTime;

	void() monster_alien_controller;

	virtual void(int) Pain;
	virtual void(int) Death;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_alien_controller::Pain(int iHitBody)
{
	CBaseMonster::Pain(iHitBody);

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,con_sndpain.length));
	Sound(con_sndpain[rand]);
	frame = CON_FLINCH + floor(random(0, 2));
	m_flPainTime = time + 0.25f;
}

void
monster_alien_controller::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		frame = CON_DIE;

		/* the sound */
		int rand = floor(random(0,con_sndpain.length));
		Sound(con_sndpain[rand]);
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void
monster_alien_controller::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + random(2,10);

	int rand = floor(random(0, con_sndidle.length));
	Sound(con_sndidle[rand]);
}

void
monster_alien_controller::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = CON_IDLE;
}

void
monster_alien_controller::monster_alien_controller(void)
{
	for (int i = 0; i < con_sndattack.length; i++) {
		precache_sound(con_sndattack[i]);
	}
	for (int i = 0; i < con_sndidle.length; i++) {
		precache_sound(con_sndidle[i]);
	}
	for (int i = 0; i < con_sndpain.length; i++) {
		precache_sound(con_sndpain[i]);
	}
	for (int i = 0; i < con_sndsee.length; i++) {
		precache_sound(con_sndsee[i]);
	}

	netname = "Alien Controller";
	model = "models/controller.mdl";
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseMonster::CBaseMonster();
}
