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
	TENT_IDLEPIT,
	TENT_RISE,
	TENT_TOFLOOR1,
	TENT_IDLE,
	TENT_PISSED,
	TENT_SMALLRISE,
	TENT_WAVE,
	TENT_STRIKE,
	TENT_TAP,
	TENT_ROTATE,
	TENT_REAR,
	TENT_REARIDLE,
	TENT_TOLEV1,
	TENT_IDELLEV1,
	TENT_FIDGETLEV1,
	TENT_SNAPLEV1,
	TENT_STRIKELEV1,
	TENT_TAPLEV1,
	TENT_ROTATELEV1,
	TENT_REARLEV1,
	TENT_REARIDELLEV1,
	TENT_TOLEV2,
	TENT_IDLELEV2,
	TENT_FIDGETLEV2,
	TENT_SNAPLEV2,
	TENT_SWINGLEV2,
	TENT_TUTLEV2,
	TENT_STRIKELEV2,
	TENT_TAPLEV2,
	TENT_ROTATELEV2,
	TENT_REARLEV2,
	TENT_FREAKDIE,
	TENT_REARIDLE2,
	TENT_TOLEV3,
	TENT_IDLELEV3,
	TENT_FIDGETLEV3,
	TENT_SIDELEV3,
	TENT_SWIPELEV3,
	TENT_STRIKELEV3,
	TENT_TAPLEV3,
	TENT_ROTATELEV3,
	TENT_REARLEV3,
	TENT_REARIDLELEV3,
	TENT_DOORLEV1,
	TENT_ENGINELEV3,
	TENT_ENGINEIDLE,
	TENT_ENGINESWAY,
	TENT_ENGINESWAT,
	TENT_ENGINEBOB,
	TENT_ENGINEDEATH,
	TENT_ENGINEDEATH2,
	TENT_ENGINEDEATH3,
	TENT_GRABIDLE,
	TENT_GRAB
};

string tent_sndattack[] = {
	"tentacle/te_strike1.wav",
	"tentacle/te_strike2.wav"
};

string tent_snddeath[] = {
	"tentacle/te_death2.wav"
};

/* includes some cut sounds, might be interesting */
string tent_sndidle[] = {
	"tentacle/te_roar1.wav",
	"tentacle/te_roar2.wav",
	"tentacle/te_search1.wav",
	"tentacle/te_search2.wav",
	"tentacle/te_sing1.wav",
	"tentacle/te_sing2.wav"
};

/* cut sounds, listing here because why not */
string tent_sndsee[] = {
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
	m_flIdleTime = time + 2.0f + random(0,5);

	int rand = floor(random(0, tent_sndidle.length));
	Sound(tent_sndidle[rand]);
}

void
monster_tentacle::Respawn(void)
{
	CBaseMonster::Respawn();
	takedamage = DAMAGE_NO;
	iBleeds = FALSE;
	frame = TENT_IDLEPIT;
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
