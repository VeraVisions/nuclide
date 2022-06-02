/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
Allow an actor to be selected and given an action to perform.
This is done in the form of playing an animation.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"m_iszEntity" : Entity targetname OR classname description to target
"m_iszPlay" : After the monster has moved to the action point, play this animation
"m_iszIdle" : Animation to play until the scripted_sequence is triggered
"m_flRadius" : Search radius for m_targetMonster if a classname is specified
"m_flRepeat" : Loop? Unused.
"m_fMoveTo" : How we move to perform m_iActionAnim

-------- SPAWNFLAGS --------
SSFL_REPEATABLE : Can trigger the sequence more than once.
SSFL_LEAVECORPSE : When the actor is done, they'll be frozen.
SSFL_NOINTERRUPT : Don't allow any interruption of the actor when in-sequence.
SSFL_OVERRIDEAI : Don't allow the actor to call think/sound functions while playing.

-------- NOTES --------
f_fMoveTo values:
    0 = Don't move or turn
    1 = Walk to the scripted_sequence
    2 = Run to the scripted_sequence
    3 = Unused/Not defined. Do not use this.
    4 = Warp to the location of the scripted_sequence and perform the animation.
    5 = Turn to the scripted_sequence's angle before performing the animation.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

float(float modidx, string framename) frameforname = #276;
float(float modidx, float framenum) frameduration = #277;
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
enum
{
    SS_NO, /* Don't move or turn */
    SS_WALK, /* Walk to the scripted_sequence */
    SS_RUN, /* Run to the scripted_sequence */
    SS_UNUSED,
    SS_INSTANTANEOUS, /* Warp to the location of the scripted_sequence and perform the animation. */
    SS_TURNTOFACE /* Turn to the scripted_sequence's angle before performing the animation. */
};

class scripted_sequence:NSPointTrigger
{
	int m_iEnabled;

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

	void(void) scripted_sequence;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
	
	virtual void(entity) RunOnEntity;
	virtual void(void) InitIdle;
	virtual void(entity) Touch;
};

void
scripted_sequence::Save(float handle)
{
	SaveInt(handle, "enabled", m_iEnabled);
	SaveString(handle, "monster", m_strMonster);
	SaveString(handle, "action_anim", m_strActionAnim);
	SaveString(handle, "idle_anim", m_strIdleAnim);
	SaveFloat(handle, "search_radius", m_flSearchRadius);
	SaveInt(handle, "move", m_iMove);
	super::Save(handle);
}

void
scripted_sequence::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "enabled":
		m_iEnabled = ReadInt(strValue);
		break;
	case "monster":
		m_strMonster = ReadString(strValue);
		break;
	case "action_anim":
		m_strActionAnim = ReadString(strValue);
		break;
	case "idle_anim":
		m_strIdleAnim = ReadString(strValue);
		break;
	case "search_radius":
		m_flSearchRadius = ReadFloat(strValue);
		break;
	case "move":
		m_iMove = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
scripted_sequence::RunOnEntity(entity targ)
{	
	NSMonster f;
	float duration;

	f = (NSMonster)targ;

	if (!m_iEnabled)
		return;

	/* aaaaand it's gone */
	if (!HasSpawnFlags(SSFL_REPEATABLE))
		m_iEnabled = FALSE;

	NSLog("\tName: %s", targetname);
	NSLog("\tTarget: %s", m_strMonster);
	NSLog("\tStarted: %f", time);

	/* if we're told an anim, we better have it... or else. */
	if (m_strActionAnim) {
		f.m_flSequenceEnd = frameforname(f.modelindex, m_strActionAnim);
		if (f.m_flSequenceEnd == -1) {
			print(sprintf("^1ERROR: Framegroup %s not found!\n", m_strActionAnim));
			return;
		}
	}

	/* entity to trigger after sequence ends */
	if (target) {
		NSLog("\tTrigger when finished: %s", target);
		f.m_strRouteEnded = target;
		f.m_ssLast = this;
		m_iValue = FALSE; /* will be marked as used once triggered */
	} else {
		/* make sure we're not about to trigger _anything_ */
		f.m_strRouteEnded = __NULL__;
		f.m_ssLast = __NULL__;
		/* mark us as having been used, for multisources. */
		m_iValue = TRUE;
	}


	/* mark the state */
	f.m_iSequenceState = SEQUENCESTATE_ACTIVE;

	/* seems to be active at all times? contrary to SS_TURNTOFACE existing? */
	f.m_vecSequenceAngle = angles;
	f.m_iSequenceFlags = spawnflags;

	if (m_iMove == SS_NO) {
		dprint("\tType: SS_NO\n");
	} else if (m_iMove == SS_WALK) {
		f.NewRoute(origin);
		f.m_flSequenceSpeed = f.GetWalkSpeed();
		dprint("\tType: SS_WALK\n");
		return;
	} else if (m_iMove == SS_RUN) {
		f.NewRoute(origin);
		f.m_flSequenceSpeed = f.GetRunSpeed();
		dprint("\tType: SS_RUN\n");
		return;
	} else if (m_iMove == SS_INSTANTANEOUS) {
		setorigin(f, this.origin);
		dprint("\tType: SS_INSTANTANEOUS\n");
	} else if (m_iMove == SS_TURNTOFACE) {
		dprint("\tType: SS_TURNTOFACE\n");
	}

	/* all the non-moving targets will do this at least */
	if (m_strActionAnim) {
		duration = frameduration(f.modelindex, f.m_flSequenceEnd);
		f.nextthink = time + duration;
		NSLog(
			"\tAnimation: %s Duration: %f seconds (modelindex %d, frame %d)\n",
			m_strActionAnim,
			duration,
			f.modelindex,
			f.m_flSequenceEnd
		);
	} else {
		f.nextthink = time;
		NSLog(
			"\t^1WARNING: %s skipping animation on script type %i\n",
			f.targetname,
			m_iMove
		);
	}

	f.m_iSequenceState = SEQUENCESTATE_ENDING;

	if (HasSpawnFlags(SSFL_NOSCRIPTMOVE))
		f.think = NSMonster::FreeState;
	else
		f.think = NSMonster::FreeStateMoved;

	NSLog("\tEnding: %f", f.nextthink);

	/* make sure we're forgetting about enemies and attack states in sequence */
	f.m_eEnemy = __NULL__;
	f.m_iMState = MONSTER_IDLE;
	
}

void
scripted_sequence::Trigger(entity act, int unused)
{
	NSMonster f;

	NSLog("^2scripted_sequence::^3Trigger^7: with spawnflags %d", spawnflags);
	f = (NSMonster)find(world, ::targetname, m_strMonster);

	/* target doesn't exist/hasn't spawned */
	if (!f) {
		for (entity c = world; (c = find(c, ::classname, m_strMonster));) {
			/* within radius */
			if (vlen(origin - c.origin) < m_flSearchRadius) {
				f = (NSMonster)c;
				break;
			}
		}

		/* cancel out. this trigger is not yet ready. */
		if (!f) {
			return;
		}
	}

	RunOnEntity((entity)f);
}

void
scripted_sequence::InitIdle(void)
{
	NSMonster f;

	NSLog("^2scripted_sequence::^3InitIdle^7: with spawnflags %d", spawnflags);
	f = (NSMonster)find(world, ::targetname, m_strMonster);

	/* target doesn't exist/hasn't spawned */
	if (!f) {
		/* time to look for a classname instead */
		for (entity c = world; (c = find(c, ::classname, m_strMonster));) {
			/* within radius */
			if (vlen(origin - c.origin) < m_flSearchRadius) {
				f = (NSMonster)c;
				break;
			}
		}

		/* cancel out. this trigger is broken. */
		if (!f) {
			NSLog("^1scripted_sequence::^3InitIdle^7: Unknown target %s", m_strMonster);
			return;
		}
	}
	
	setorigin(f, origin);
	f.m_flSequenceEnd = frameforname(f.modelindex, m_strIdleAnim);
	f.m_iSequenceState = SEQUENCESTATE_ENDING;
	f.m_vecSequenceAngle = angles;
}

void
scripted_sequence::Touch(entity eToucher)
{
	NSMonster f;

	if (eToucher.classname != m_strMonster)
		return;

	f = (NSMonster)eToucher;

	/* we already ARE on a sequence. */
	if (f.m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	RunOnEntity(eToucher);
}

void
scripted_sequence::Respawn(void)
{
	m_iEnabled = TRUE;
	target = m_oldstrTarget;
	
	if (m_flSearchRadius) {
		SetSolid(SOLID_TRIGGER);
		mins[0] = mins[1] = mins[2] = -(m_flSearchRadius/2);
		maxs[0] = maxs[1] = maxs[2] = (m_flSearchRadius/2);
		setsize(this, mins, maxs);
	} else {
		SetSolid(SOLID_NOT);
	}

	if (m_strIdleAnim) {
		think = InitIdle;
		nextthink = time + 0.1f;
	}
}

void
scripted_sequence::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iszEntity":
		m_strMonster = strValue;
		break;
	case "m_iszPlay":
		m_strActionAnim = strValue;
		break;
	case "m_iszIdle":
		m_strIdleAnim = strValue;
		break;
	case "m_flRadius":
		m_flSearchRadius = stof(strValue);
		break;
	case "m_flRepeat":
		/* TODO: */
		break;
	case "m_fMoveTo":
		m_iMove = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
scripted_sequence::scripted_sequence(void)
{
}

CLASSEXPORT(aiscripted_sequence, scripted_sequence)
