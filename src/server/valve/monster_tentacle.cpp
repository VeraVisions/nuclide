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

/*QUAKED monster_tentacle (0 0.8 0.8) (-32 -32 0) (32 32 64)

Tentacle

*/

enum {
	TE_IDLEPIT,
	TE_RISE,
	TE_TOFLOOR1,
	TE_IDLE,
	TE_PISSED,
	TE_SMALLRISE,
	TE_WAVE,
	TE_STRIKE,
	TE_TAP,
	TE_ROTATE,
	TE_REAR,
	TE_REARIDLE,
	TE_TOLEV1,
	TE_IDELLEV1,
	TE_FIDGETLEV1,
	TE_SNAPLEV1,
	TE_STRIKELEV1,
	TE_TAPLEV1,
	TE_ROTATELEV1,
	TE_REARLEV1,
	TE_REARIDELLEV1,
	TE_TOLEV2,
	TE_IDLELEV2,
	TE_FIDGETLEV2,
	TE_SNAPLEV2,
	TE_SWINGLEV2,
	TE_TUTLEV2,
	TE_STRIKELEV2,
	TE_TAPLEV2,
	TE_ROTATELEV2,
	TE_REARLEV2,
	TE_FREAKDIE,
	TE_REARIDLE2,
	TE_TOLEV3,
	TE_IDLELEV3,
	TE_FIDGETLEV3,
	TE_SIDELEV3,
	TE_SWIPELEV3,
	TE_STRIKELEV3,
	TE_TAPLEV3,
	TE_ROTATELEV3,
	TE_REARLEV3,
	TE_REARIDLELEV3,
	TE_DOORLEV1,
	TE_ENGINELEV3,
	TE_ENGINEIDLE,
	TE_ENGINESWAY,
	TE_ENGINESWAT,
	TE_ENGINEBOB,
	TE_ENGINEDEATH,
	TE_ENGINEDEATH2,
	TE_ENGINEDEATH3,
	TE_GRABIDLE,
	TE_GRAB
};

string te_sndattack[] = {
	"tentacle/te_strike1.wav",
	"tentacle/te_strike2.wav"
};

string te_snddeath[] = {
	"tentacle/te_death2.wav"
};

/* includes some cut sounds, might be interesting */
string te_sndidle[] = {
	"tentacle/te_roar1.wav",
	"tentacle/te_roar2.wav",
	"tentacle/te_search1.wav",
	"tentacle/te_search2.wav",
	"tentacle/te_sing1.wav",
	"tentacle/te_sing2.wav"
};

/* cut sounds, listing here because why not */
string te_sndsee[] = {
	"tentacle/te_alert1.wav",
	"tentacle/te_alert2.wav"
};

class monster_tentacle:CBaseMonster
{
	float m_flIdleTime;

	void() monster_tentacle;

	virtual void(void) IdleNoise;
	virtual void(void) Respawn;
};

void
monster_tentacle::IdleNoise(void)
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

	int rand = floor(random(0, te_sndidle.length));
	Sound(te_sndidle[rand]);
}

void
monster_tentacle::Respawn(void)
{
	CBaseMonster::Respawn();
	/* not entirely true, takes damage then retreats and reheals */
	takedamage = DAMAGE_NO;
	iBleeds = FALSE;
	frame = TE_IDLE;
}

void
monster_tentacle::monster_tentacle(void)
{
	netname = "Tentacle";
	model = "models/tentacle2.mdl";
	base_mins = [-32,-32,0];
	base_maxs = [32,32,64];
	CBaseMonster::CBaseMonster();
}
