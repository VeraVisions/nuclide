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

/*QUAKED scripted_sequence (1 0 0) (-8 -8 -8) (8 8 8) x x SSFL_REPEATABLE SSFL_LEAVECORPSE x SSFL_NOINTERRUPT SSFL_OVERRIDEAI SSFL_NOSCRIPTMOVE
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"m_iszEntity"   Entity targetname OR classname description to target
"m_iszPlay"     After the monster has moved to the action point, play this animation
"m_iszIdle"     Animation to play until the scripted_sequence is triggered
"m_flRadius"    Search radius for m_targetMonster if a classname is specified
"m_flRepeat"    Loop? Unused.
"m_fMoveTo"     How we move to perform m_iActionAnim

f_fMoveTo values:
    0 = Don't move or turn
    1 = Walk to the scripted_sequence
    2 = Run to the scripted_sequence
    3 = Unused/Not defined. Do not use this.
    4 = Warp to the location of the scripted_sequence and perform the animation.
    5 = Turn to the scripted_sequence's angle before performing the animation.

Allow a monster to be selected and given an action to perform.
This is done in the form of olaying an animation.
*/

/*
 * Scripted Sequences
 * ==================
 * Allow a monster to be selected and given an action to perform.
 * This is done in the form of an animation.
 */
 
 /* If enabled, the sequence can be triggered more than once. 
  * Otherwise the entity will be removed once the sequence is complete. */
 #define SSFL_REPEATABLE 4
 
 /* Seemingly unused. */
 #define SSFL_LEAVECORPSE 8
 
 /* If enabled, the sequence cannot be interrupted. 
  * The monster will ignore damage until the sequence is complete, 
  * as with the aiscripted_sequence entity. */
 #define SSFL_NOINTERRUPT 32
 
 /* Seemingly unused. */
 #define SSFL_OVERRIDEAI 64
 
 /* If enabled, when the sequence is completed, the monster will be placed back
  * where the Action Animation started. */
 #define SSFL_NOSCRIPTMOVE 128

/* m_iMove, how we move to perform m_iActionAnim */
enum {
    SS_NO, /* Don't move or turn */
    SS_WALK, /* Walk to the scripted_sequence */
    SS_RUN, /* Run to the scripted_sequence */
    SS_UNUSED,
    SS_INSTANTANEOUS, /* Warp to the location of the scripted_sequence and perform the animation. */
    SS_TURNTOFACE /* Turn to the scripted_sequence's angle before performing the animation. */
};

class scripted_sequence:CBaseTrigger
{
	/* Target name OR classname description */
	string m_strMonster;
	/* After the monster has moved to the action point, play this animation */
	string m_strActionAnim;
	/* Animation to play until the scripted_sequence is triggered */
	string m_strIdleAnim;
	/* Search radius for m_targetMonster if a classname is specified */
	float m_flSearchRadius;
	/* How we move to perform m_iActionAnim */
	int m_iMove;

	void() scripted_sequence;
	virtual void() Trigger;
	virtual void() Respawn;
};

void scripted_sequence::Trigger(void)
{
	CBaseMonster f;

	print(sprintf("^2scripted_sequence::Trigger^7: with spawnflags %d\n", spawnflags));
	if (m_iMove == SS_WALK) {
		f = (CBaseMonster)find(world, CBaseEntity::m_strTargetName, m_strMonster);
		if (f) {
			f.NewRoute(origin);
			f.style = MONSTER_INSEQUENCE;
			f.m_flSequenceSpeed = 64;
			f.m_strRouteEnded = m_strTarget;
		}
	} else if (m_iMove == SS_RUN) {
		f = (CBaseMonster)find(world, CBaseEntity::m_strTargetName, m_strMonster);
		if (f) {
			f.NewRoute(origin);
			f.style = MONSTER_INSEQUENCE;
			f.m_flSequenceSpeed = 256;
			f.m_strRouteEnded = m_strTarget;
		}
	}
}

void scripted_sequence::Respawn(void)
{
	
}

void scripted_sequence::scripted_sequence(void)
{
	int nfields = tokenize(__fullspawndata);
	for (int i = 1; i < (nfields-1); i += 2) {
		switch (argv(i)) {
		case "target":
			m_strTarget = argv(i+1);
			break;
		case "m_iszEntity":
			m_strMonster = argv(i+1);
			break;
		case "m_iszPlay":
			m_strActionAnim = argv(i+1);
			break;
		case "m_iszIdle":
			m_strIdleAnim = argv(i+1);
			break;
		case "m_flRadius":
			m_flSearchRadius = stof(argv(i+1));
			break;
		case "m_flRepeat":
			break;
		case "m_fMoveTo":
			m_iMove = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}
}
