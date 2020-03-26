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

/*QUAKED monster_babycrab (0 0.8 0.8) (-16 -16 0) (16 16 36)

Baby Headcrab

*/

enum {
	BHC_IDLE,
	BHC_IDLE2,
	BHC_IDLE3,
	BHC_WALK,
	BHC_RUN,
	BHC_ANGRY,
	BHC_FLINCH,
	BHC_DIEBACK,
	BHC_LEFT,
	BHC_RIGHT,
	BHC_JUMP,
	BHC_JUMP2,
	BHC_JUMP3
};

class monster_babycrab:monster_headcrab
{
	void() monster_babycrab;
	virtual void(void) Respawn;
};

void
monster_babycrab::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = BHC_IDLE;
}

void
monster_babycrab::monster_babycrab(void)
{
	for (int i = 0; i < hc_sndattack.length; i++) {
		precache_sound(hc_sndattack[i]);
	}
	for (int i = 0; i < hc_snddie.length; i++) {
		precache_sound(hc_snddie[i]);
	}
	for (int i = 0; i < hc_sndidle.length; i++) {
		precache_sound(hc_sndidle[i]);
	}
	for (int i = 0; i < hc_sndpain.length; i++) {
		precache_sound(hc_sndpain[i]);
	}
	for (int i = 0; i < hc_sndsee.length; i++) {
		precache_sound(hc_sndsee[i]);
	}

	netname = "Baby Headcrab";
	model = "models/baby_headcrab.mdl";
	base_health = Skill_GetValue ("headcrab_health") /4;
	base_mins = [-16,-16,0];
	base_maxs = [16,16,36];
	CBaseMonster::CBaseMonster();
}
