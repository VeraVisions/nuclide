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

/*QUAKED monster_barnacle (0 0.8 0.8) (-16 -16 -36) (16 16 0)

Barnacle

*/

enum {
	BCL_IDLE,
	BCL_IDLE2,
	BCL_IDLE3,
	BCL_FLINCH,
	BCL_ATTACK,
	BCL_CHEW,
	BCL_DIE
};

/* bcl_alert2 is played when the barnacle is pulling up an ent
 * bcl_bite3 is played when an entity is in it's mouth, bcl_tongue1 unused?
 */

string bcl_sndchew[] = {
	"barnacle/bcl_chew1.wav",
	"barnacle/bcl_chew2.wav",
	"barnacle/bcl_chew3.wav"
};

string bcl_snddie[] = {
	"barnacle/bcl_die1.wav",
	"barnacle/bcl_die3.wav"
};

class monster_barnacle:CBaseMonster
{

	void() monster_barnacle;

	virtual void(int) Death;
	virtual void(void) Respawn;
};

void
monster_barnacle::Death(int iHitBody)
{
	/* if we're already dead (corpse) don't change animations */
	if (style != MONSTER_DEAD) {
		frame = BCL_DIE;

		/* the sound */
		int rand = floor(random(0,bcl_snddie.length));
		Sound(bcl_snddie[rand]);
	}

	/* set the functional differences */
	CBaseMonster::Death(iHitBody);
}

void
monster_barnacle::Respawn(void)
{
	CBaseMonster::Respawn();
	frame = BCL_IDLE;
}

void monster_barnacle::monster_barnacle(void)
{
	for (int i = 0; i < bcl_sndchew.length; i++) {
		precache_sound(bcl_sndchew[i]);
	}
	for (int i = 0; i < bcl_snddie.length; i++) {
		precache_sound(bcl_snddie[i]);
	}

	netname = "Barnacle";
	model = "models/barnacle.mdl";
	base_health = Skill_GetValue("barnacle_health");
	base_mins = [-16,-16,-36];
	base_maxs = [16,16,0];
	CBaseMonster::CBaseMonster();
}
