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

/*QUAKED monster_gargantua (0 0.8 0.8) (-32 -32 0) (32 32 128)

Gargantua

*/

enum {
	GARG_IDLE,
	GARG_IDLE2,
	GARG_IDLE3,
	GARG_IDLE4,
	GARG_WALK,
	GARG_RUN,
	GARG_SHOOT,
	GARG_SHOOT2,
	GARG_ATTACK,
	GARG_STOMP,
	GARG_LEFT,
	GARG_RIGHT,
	GARG_FLINCH,
	GARG_FLINCH2,
	GARG_DIE,
	GARG_BITEHEAD,
	GARG_THROW,
	GARG_SMASH,
	GARG_ROLLCAR,
	GARG_KICKCAR,
	GARG_PUSHCAR,
	GARG_BUST
};

/* Flame thrower sounds
 * gar_flameoff1
 * gar_flameon1
 * gar_flamerun1 */

/* similar to bullsquid, groans during and after attacks */

string garg_sndattack[] = {
	"garg/gar_attack1.wav",
	"garg/gar_attack2.wav",
	"garg/gar_attack3.wav"
};

string garg_sndalert[] = {
	"garg/gar_alert1.wav",
	"garg/gar_alert2.wav",
	"garg/gar_alert3.wav"
};

string garg_snddie[] = {
	"garg/gar_die1.wav",
	"garg/gar_die2.wav"
};

string garg_sndidle[] = {
	"garg/gar_idle1.wav",
	"garg/gar_idle2.wav",
	"garg/gar_idle3.wav",
	"garg/gar_idle4.wav",
	"garg/gar_idle5.wav",
	"garg/gar_breathe1.wav",
	"garg/gar_breathe2.wav",
	"garg/gar_breathe3.wav"
};

/* has unique foot step sounds */
string garg_sndstep[] = {
	"garg/gar_step1.wav",
	"garg/gar_step2.wav"
};

string garg_sndpain[] = {
	"garg/gar_pain1.wav",
	"garg/gar_pain2.wav",
	"garg/gar_pain3.wav"
};


class monster_gargantua:CBaseMonster
{
	float m_flIdleTime;
	float m_flPainTime;

	void() monster_gargantua;

	virtual void(int) Death;
	virtual void(int) Pain;
	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_gargantua::IdleNoise(void)
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

	int rand = floor(random(0, garg_sndidle.length));
	Sound(garg_sndidle[rand]);
}

void
monster_gargantua::Pain(int iHitBody)
{
	CBaseMonster::Pain(iHitBody);

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,garg_sndpain.length));
	Sound(garg_sndpain[rand]);
	frame = (random() < 0.5) ? GARG_FLINCH : GARG_FLINCH2;
	m_flPainTime = time + 0.25f;
}

void
monster_gargantua::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {

	frame = GARG_DIE;

		/* the sound */
		int rand = floor(random(0,garg_snddie.length));
		Sound(garg_snddie[rand]);
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void
monster_gargantua::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = GARG_IDLE;
	/* takes damage from explosives only
	 * takedamage = DAMAGE_NO; */
	iBleeds = FALSE;
}

void monster_gargantua::monster_gargantua(void)
{
	for (int i = 0; i <garg_sndalert.length; i++) {
		precache_sound(garg_sndattack[i]);
	}
	for (int i = 0; i <garg_sndattack.length; i++) {
		precache_sound(garg_sndattack[i]);
	}
	for (int i = 0; i < garg_snddie.length; i++) {
		precache_sound(garg_snddie[i]);
	}
	for (int i = 0; i < garg_sndidle.length; i++) {
		precache_sound(garg_sndidle[i]);
	}
	for (int i = 0; i < garg_sndpain.length; i++) {
		precache_sound(garg_sndpain[i]);
	}
	for (int i = 0; i < garg_sndstep.length; i++) {
		precache_sound(garg_sndstep[i]);
	}
	
	netname = "Gargantua";
	model = "models/garg.mdl";
	base_health = Skill_GetValue("gargantua_health");
	base_mins = [-32,-32,0];
	base_maxs = [32,32,128];
	CBaseMonster::CBaseMonster();
}
