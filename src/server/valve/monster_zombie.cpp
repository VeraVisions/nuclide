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
	ZO_IDLE,
	ZO_TURNLEFT,
	ZO_TURNRIGHT,
	ZO_FLINCHSM,
	ZO_FLINCH,
	ZO_FLINCHBIG,
	ZO_RISE,
	ZO_FALLING,
	ZO_ATTACK1,
	ZO_ATTACK2,
	ZO_WALK,
	ZO_FLINCHLA,
	ZO_FLINCHRA,
	ZO_FLINCHLEFT,
	ZO_FLINCHRIGHT,
	ZO_DIEHS,
	ZO_DIEHS2,
	ZO_DIE,
	ZO_DIE2,
	ZO_DIE3,
	ZO_PAUSE,
	ZO_WALLBUST,
	ZO_WALLKICK,
	ZO_WINDOWBUST,
	ZO_SODA,
	ZO_SLIDEIDLE,
	ZO_SLIDE,
	ZO_VENTIDLE,
	ZO_VENT,
	ZO_DEADIDLE,
	ZO_DEAD,
	ZO_FREAKDIE,
	ZO_FREAK,
	ZO_EATTABLE,
	ZO_EAT,
	ZO_EATSTAND,
	ZO_DOORIP,
	ZO_PULLSCI,
	ZO_EAT2,
	ZO_EAT2STAND,
	ZO_VENT2IDLE,
	ZO_VENT2,
	ZO_HAUL,
	ZO_RISESNACK
};

string zo_sndattack[] = {
	"zombie/zo_attack1.wav",
	"zombie/zo_attack2.wav"
};

string zo_sndclaw[] = {
	"zombie/claw_strike1.wav",
	"zombie/claw_strike2.wav",
	"zombie/claw_strike3.wav"
};

string zo_sndclawmiss[] = {
	"zombie/claw_miss1.wav",
	"zombie/claw_miss2.wav"
};

string zo_sndidle[] = {
	"zombie/zo_idle1.wav",
	"zombie/zo_idle2.wav",
	"zombie/zo_idle3.wav",
	"zombie/zo_idle4.wav"
};

string zo_sndpain[] = {
	"zombie/zo_pain1.wav",
	"zombie/zo_pain2.wav"
};

string zo_sndsee[] = {
	"zombie/zo_alert10.wav",
	"zombie/zo_alert20.wav",
	"zombie/zo_alert30.wav"
};

class monster_zombie:CBaseMonster
{
	float m_flIdleTime;

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

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,zo_sndpain.length));
	Sound(zo_sndpain[rand]);
	frame = ZO_FLINCH + floor(random(0, 2));
	m_flAnimTime = time + 0.25f;
}

void
monster_zombie::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		/* headshots == different animation */
		if (iHitBody == BODY_HEAD) {
			if (random() < 0.5) {
				frame = ZO_DIEHS;
			} else {
				frame = ZO_DIEHS2;
			}
		} else {
			 frame = ZO_DIE + floor(random(0, 3));
		}

		/* the sound */
		int rand = floor(random(0,zo_sndpain.length));
		Sound(zo_sndpain[rand]);
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

	int rand = floor(random(0, zo_sndidle.length));
	Sound(zo_sndidle[rand]);
}

void
monster_zombie::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = ZO_IDLE;
}

void
monster_zombie::monster_zombie(void)
{
	for (int i = 0; i < zo_sndattack.length; i++) {
		precache_sound(zo_sndattack[i]);
	}
	for (int i = 0; i < zo_sndclaw.length; i++) {
		precache_sound(zo_sndclaw[i]);
	}
	for (int i = 0; i < zo_sndclawmiss.length; i++) {
		precache_sound(zo_sndclawmiss[i]);
	}
	for (int i = 0; i < zo_sndidle.length; i++) {
		precache_sound(zo_sndidle[i]);
	}
	for (int i = 0; i < zo_sndpain.length; i++) {
		precache_sound(zo_sndpain[i]);
	}
	for (int i = 0; i < zo_sndsee.length; i++) {
		precache_sound(zo_sndsee[i]);
	}

	netname = "Zombie";
	model = "models/zombie.mdl";
	base_health = Skill_GetValue("zombie_health");
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseMonster::CBaseMonster();
}
