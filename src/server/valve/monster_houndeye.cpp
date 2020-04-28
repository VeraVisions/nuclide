/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

HALF-LIFE (1998) ENTITY

Houndeye

*/

enum
{
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

class monster_houndeye:CBaseMonster
{
	float m_flIdleTime;

	void(void) monster_houndeye;

	virtual void(int) Pain;
	virtual void(int) Death;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_houndeye::Pain(int iHitBody)
{
	CBaseMonster::Pain(iHitBody);

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	Sound_Play(this, CHAN_VOICE, "monster_houndeye.pain");
	SetFrame(HE_FLINCH + floor(random(0, 2)));
	m_flAnimTime = time + 0.25f;
}

void
monster_houndeye::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		SetFrame(HE_DIE + floor(random(0, 4)));

		Sound_Play(this, CHAN_VOICE, "monster_houndeye.die");
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
	m_flIdleTime = time + random(2,10);

	Sound_Play(this, CHAN_VOICE, "monster_houndeye.idle");
}

void
monster_houndeye::Respawn(void)
{
	CBaseMonster::Respawn();
	SetFrame(HE_IDLE);
}

void
monster_houndeye::monster_houndeye(void)
{
	Sound_Precache("monster_houndeye.alert");
	Sound_Precache("monster_houndeye.attack");
	Sound_Precache("monster_houndeye.die");
	Sound_Precache("monster_houndeye.idle");
	Sound_Precache("monster_houndeye.pain");
	netname = "Houndeye";
	model = "models/houndeye.mdl";
	base_health = Skill_GetValue("houndeye_health");
	base_mins = [-16,-16,0];
	base_maxs = [16,16,36];
	CBaseMonster::CBaseMonster();
}
