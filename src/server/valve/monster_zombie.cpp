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

Monster.
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

enum {
	ZOMB_IDLE,
	ZOMB_WALK,
	ZOMB_DEAD
};

class monster_zombie:CBaseMonster
{
	float m_flScaredTime;
	float m_flScreamTime;
	float m_flPainTime;
	float m_flChangePath;
	float m_flTraceTime;
	float m_flPitch;
	int m_iFlags;

	void() monster_zombie;

	virtual void(int) vPain;
	virtual void(int) vDeath;
	virtual void(void) Respawn;
};

void monster_zombie::vPain(int iHitBody)
{
	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,sci_sndpain.length));
	Speak(sci_sndpain[rand]);
	frame = ZOMA_FLINCH + floor(random(0, 2));
	m_flPainTime = time + 0.25f;
}

void monster_zombie::vDeath(int iHitBody)
{
	think = Respawn;
	nextthink = time + 10.0f;

	SendFlags |= NPC_FRAME;
	m_iFlags = 0x0;

	if (health < -50) {
		Gib();
		return;
	}

	flags &= ~FL_MONSTER;
	movetype = MOVETYPE_NONE;
	solid = SOLID_CORPSE;

	if (style != ZOMB_DEAD) {
		frame = ZOMA_DIE + floor(random(0, 3));
		style = ZOMB_DEAD;
	}
}

void monster_zombie::Respawn(void)
{
	v_angle[0] = Math_FixDelta(m_oldAngle[0]);
	v_angle[1] = Math_FixDelta(m_oldAngle[1]);
	v_angle[2] = Math_FixDelta(m_oldAngle[2]);

	setorigin(this, m_oldOrigin);
	angles = v_angle;
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_WALK;
	setmodel(this, m_oldModel);
	setsize(this, VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
	takedamage = DAMAGE_YES;
	iBleeds = TRUE;
	customphysics = Physics;
	frame = ZOMA_IDLE;
	SendFlags |= NPC_FRAME;
	health = 50;
	velocity = [0,0,0];
	m_iFlags = 0x0;
	SendFlags = 0xff;
	style = ZOMB_IDLE;
	netname = "Zombie";
}

void monster_zombie::monster_zombie(void)
{
	model = "models/zombie.mdl";
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
	Respawn();
}
