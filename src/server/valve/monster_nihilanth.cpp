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

/*QUAKED monster_nihilanth (0 0.8 0.8) (-192 -192 0) (192 192 384)

Nihilanth

*/

enum {
	NIL_IDLE,
	NIL_ATTACK,
	NIL_ATTACK2,
	NIL_THROW,
	NIL_BLOCK,
	NIL_RECHARGE,
	NIL_IDLEOPEN,
	NIL_ATTACKOPEN,
	NIL_ATTACKOPEN2,
	NIL_FLINCH,
	NIL_FLINCH2,
	NIL_FALL,
	NIL_DIE,
	NIL_FORWARD,
	NIL_BACK,
	NIL_UP,
	NIL_DOWN,
	NIL_RIGHT,
	NIL_LEFT,
	NIL_WALK2,
	NIL_SHOOT
};

/* other sounds
 * x_ballattack1 - the portal he casts
 * x_shoot1 - ?
 * x_teleattack1 - portal's move sound 
 * nih_die2 - used in map not code? */

/* these attack sounds are his growls */
string nil_sndattack[] = {
	"x/x_attack1.wav",
	"x/x_attack2.wav",
	"x/x_attack3.wav"
};

string nil_sndidle[] = {
	"x/x_laugh1.wav",
	"x/x_laugh2.wav"
};

string nil_sndpain[] = {
	"x/x_pain1.wav",
	"x/x_pain2.wav",
	"x/x_pain3.wav"
};

string nil_sndrecharge[] = {
	"x/x_recharge1.wav",
	"x/x_recharge2.wav",
	"x/x_recharge3.wav"
};

class monster_nihilanth:CBaseMonster
{
	float m_flIdleTime;

	void() monster_nihilanth;

	virtual void(int) Death;
	virtual void(int) Pain;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_nihilanth::IdleNoise(void)
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

	int rand = floor(random(0, nil_sndidle.length));
	Sound(nil_sndidle[rand]);
}

void
monster_nihilanth::Pain(int iHitBody)
{
	CBaseMonster::Pain(iHitBody);

	if (m_flAnimTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,nil_sndpain.length));
	Sound(nil_sndpain[rand]);

	frame = (random() < 0.5) ? NIL_FLINCH : NIL_FLINCH2;
	m_flAnimTime = time + 0.25f;
}

void
monster_nihilanth::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		frame = NIL_DIE;
		Sound("x/x_die1.wav");
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void
monster_nihilanth::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = NIL_IDLE;
}

void monster_nihilanth::monster_nihilanth(void)
{
	for (int i = 0; i <nil_sndattack.length; i++) {
		precache_sound(nil_sndattack[i]);
	}
	for (int i = 0; i < nil_sndidle.length; i++) {
		precache_sound(nil_sndidle[i]);
	}
	for (int i = 0; i < nil_sndpain.length; i++) {
		precache_sound(nil_sndpain[i]);
	}
	for (int i = 0; i < nil_sndrecharge.length; i++) {
		precache_sound(nil_sndrecharge[i]);
	}

	netname = "Nihilanth";
	model = "models/nihilanth.mdl";
	base_health = Skill_GetValue("nihilanth_health");
	base_mins = [-192,-192,-32];
	base_maxs = [192,192,384];
	CBaseMonster::CBaseMonster();
}
