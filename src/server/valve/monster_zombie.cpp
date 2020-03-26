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

/*QUAKED monster_zombie (0 0.8 0.8) (-16 -16 0) (16 16 72)

Zombie

*/

enum {
	ZOMA_IDLE,
	ZOMA_TURNLEFT,
	ZOMA_TURNRIGHT,
	ZOMA_FLINCHSM,
	ZOMA_FLINCH,
	ZOMA_FLINCHBIG,
	ZOMA_RISE,
	ZOMA_FALLING,
	ZOMA_ATTACK1,
	ZOMA_ATTACK2,
	ZOMA_WALK,
	ZOMA_FLINCHLA,
	ZOMA_FLINCHRA,
	ZOMA_FLINCHLEFT,
	ZOMA_FLINCHRIGHT,
	ZOMA_DIEHS,
	ZOMA_DIEHS2,
	ZOMA_DIE,
	ZOMA_DIEBACK,
	ZOMA_DIEFORWARD,
	ZOMA_PAUSE,
	ZOMA_WALLBUST,
	ZOMA_WALLKICK,
	ZOMA_WINDOWBUST,
	ZOMA_SODA,
	ZOMA_SLIDEIDLE,
	ZOMA_SLIDE,
	ZOMA_VENTIDLE,
	ZOMA_VENT,
	ZOMA_DEADIDLE,
	ZOMA_DEAD,
	ZOMA_FREAKDIE,
	ZOMA_FREAK,
	ZOMA_EATTABLE,
	ZOMA_EAT,
	ZOMA_EATSTAND,
	ZOMA_DOORIP,
	ZOMA_PULLSCI,
	ZOMA_EAT2,
	ZOMA_EAT2STAND,
	ZOMA_VENT2IDLE,
	ZOMA_VENT2,
	ZOMA_HAUL,
	ZOMA_RISESNACK
};

string zom_sndattack[] = {
	"zombie/zo_attack1.wav",
	"zombie/zo_attack2.wav"
};

string zom_sndclaw[] = {
	"zombie/claw_strike1.wav",
	"zombie/claw_strike2.wav",
	"zombie/claw_strike3.wav"
};

string zom_sndclawmiss[] = {
	"zombie/claw_miss1.wav",
	"zombie/claw_miss2.wav"
};

string zom_sndidle[] = {
	"zombie/zo_idle1.wav",
	"zombie/zo_idle2.wav",
	"zombie/zo_idle3.wav",
	"zombie/zo_idle4.wav"
};

string zom_sndpain[] = {
	"zombie/zo_pain1.wav",
	"zombie/zo_pain2.wav"
};

string zom_sndsee[] = {
	"zombie/zo_alert10.wav",
	"zombie/zo_alert20.wav",
	"zombie/zo_alert30.wav"
};

class monster_zombie:CBaseMonster
{
	float m_flIdleTime;
	float m_flPainTime;

	void() monster_zombie;

	virtual void(int) Pain;
	virtual void(int) Death;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_zombie::Pain(int iHitBody)
{
	CBaseMonster::Pain(iHitBody);

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,zom_sndpain.length));
	Sound(zom_sndpain[rand]);
	frame = ZOMA_FLINCH + floor(random(0, 2));
	m_flPainTime = time + 0.25f;
}

void
monster_zombie::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		/* headshots == different animation */
		if (iHitBody == BODY_HEAD) {
			if (random() < 0.5) {
				frame = ZOMA_DIEHS;
			} else {
				frame = ZOMA_DIEHS2;
			}
		} else {
			frame = ZOMA_DIE + floor(random(0, 3));
		}

		/* the sound */
		int rand = floor(random(0,zom_sndpain.length));
		Sound(zom_sndpain[rand]);
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void
monster_zombie::IdleNoise(void)
{
	/* don't make noise if we're dead (corpse) */
	if (style == MONSTER_DEAD) {
		return;
	}

	if (m_flIdleTime > time) {
		return;
	}
	m_flIdleTime = time + 2.0f + random(0,5);

	int rand = floor(random(0, zom_sndidle.length));
	Sound(zom_sndidle[rand]);
}

void
monster_zombie::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = ZOMA_IDLE;
}

void
monster_zombie::monster_zombie(void)
{
	for (int i = 0; i < zom_sndattack.length; i++) {
		precache_sound(zom_sndattack[i]);
	}
	for (int i = 0; i < zom_sndclaw.length; i++) {
		precache_sound(zom_sndclaw[i]);
	}
	for (int i = 0; i < zom_sndclawmiss.length; i++) {
		precache_sound(zom_sndclawmiss[i]);
	}
	for (int i = 0; i < zom_sndidle.length; i++) {
		precache_sound(zom_sndidle[i]);
	}
	for (int i = 0; i < zom_sndpain.length; i++) {
		precache_sound(zom_sndpain[i]);
	}
	for (int i = 0; i < zom_sndsee.length; i++) {
		precache_sound(zom_sndsee[i]);
	}

	netname = "Zombie";
	model = "models/zombie.mdl";
	base_health = 50;
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseMonster::CBaseMonster();
}
