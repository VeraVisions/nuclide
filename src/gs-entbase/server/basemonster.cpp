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


typedef struct
{
	vector dest;
	int linkflags;
} nodeslist_t;

/* Begin calculating a route. The callback function will be called once the
 * route has finished being calculated. The route must be memfreed once it is
 * no longer needed. The route must be followed in reverse order (ie: the
 * first node that must be reached is at index numnodes-1).
 * If no route is available then the callback will be called with no nodes. */
void(entity, vector, int, void(entity, vector, int, nodeslist_t *)) route_calculate = #0:route_calculate; 

enum {
	MONSTER_IDLE,
	MONSTER_WALK,
	MONSTER_RUN,
	MONSTER_DEAD
};

enum {
	SEQUENCESTATE_NONE,
	SEQUENCESTATE_ACTIVE,
	SEQUENCESTATE_ENDING
};

enumflags {
	MSF_WAITTILLSEEN,
	MSF_GAG,
	MSF_MONSTERCLIP,
	MSF_RESERVED1,
	MSF_PRISONER,
	MSF_RESERVED2,
	MSF_RESERVED3,
	MSF_WAITFORSCRIPT,
	MSF_PREDISASTER,
	MSF_FADECORPSE
};

class CBaseMonster:CBaseEntity
{
	vector oldnet_velocity;
	float m_flPitch;
	int m_iFlags;
	vector base_mins;
	vector base_maxs;
	int base_health;

	int m_iSequenceRemove;
	int m_iSequenceState;
	float m_flSequenceEnd;
	float m_flSequenceSpeed;
	vector m_vecSequenceAngle;

	/* pathfinding */
	int m_iNodes;
	int m_iCurNode;
	nodeslist_t *m_pRoute;
	vector m_vecLastNode;

	/* sequences */
	string m_strRouteEnded;

	void() CBaseMonster;

	virtual void() touch;
	virtual void() Hide;
	virtual void() Respawn;
	virtual void() PlayerUse;
	virtual void(int) Pain;
	virtual void(int) Death;
	virtual void() Physics;
	virtual void() IdleNoise;
	virtual void() Gib;
	virtual void(string) Sound;

	/* sequences */
	virtual void() FreeState;

	virtual void() ClearRoute;
	virtual void() CheckRoute;
	virtual void() WalkRoute;
	virtual void(vector) NewRoute;

	/* animation cycles */
	float m_flAnimTime;
	virtual int() AnimIdle;
	virtual int() AnimWalk;
	virtual int() AnimRun;
};

int
CBaseMonster::AnimIdle(void)
{
	return 0;
}

int
CBaseMonster::AnimWalk(void)
{
	return 0;
}

int
CBaseMonster::AnimRun(void)
{
	return 0;
}

void CBaseMonster::Sound(string msg)
{
	sound(this, CHAN_VOICE, msg, 1.0, ATTN_NORM);
}

void CBaseMonster::Gib(void)
{
	takedamage = DAMAGE_NO;
	Effect_GibHuman(this.origin);
	Hide();
}

void CBaseMonster::IdleNoise(void)
{

}

void CBaseMonster::ClearRoute(void)
{
	if (m_iNodes) {
		m_iNodes = 0;
		memfree(m_pRoute);
	}
}

void CBaseMonster::FreeState(void)
{
	m_flSequenceEnd = 0;
	m_iSequenceState = SEQUENCESTATE_NONE;

	/* trigger when required */
	if (m_strRouteEnded) {
		CBaseTrigger trigger = 0;
		trigger = (CBaseTrigger)find(trigger, CBaseTrigger::m_strTargetName, m_strRouteEnded);
		if (!trigger) {
			dprint(sprintf("^1CBaseMonster::FreeState^7: %s doesn't exist. Won't trigger\n", m_strRouteEnded));
		}

		if (trigger.Trigger != __NULL__) {
			dprint(sprintf("^2CBaseMonster::FreeState^7: %s triggered %f\n", m_strRouteEnded, time));
			trigger.Trigger();
		} else {
			dprint(sprintf("^1CBaseMonster::FreeState^7: %s not a valid trigger\n", m_strRouteEnded));
		}
	}

	if (m_iSequenceRemove) {
		Hide();
	}
}

void CBaseMonster::CheckRoute(void)
{
	float flDist;
	vector evenpos;

	if (!m_iNodes) {
		return;
	}

	/* level out position/node stuff */
	if (m_iCurNode < 0) {
		evenpos = m_vecLastNode;
		evenpos[2] = origin[2];
	} else {
		evenpos = m_pRoute[m_iCurNode].dest;
		evenpos[2] = origin[2];
	}

	flDist = floor( vlen( evenpos - origin ) );

	if ( flDist < 8 ) {
		dprint(sprintf("^2CBaseMonster::CheckRoute^7: %s reached node\n", this.m_strTargetName));
		m_iCurNode--;
		velocity = [0,0,0]; /* clamp friction */
	}
	
	if (m_iCurNode < -1) {
		ClearRoute();
		dprint(sprintf("^2CBaseMonster::CheckRoute^7: %s reached end\n", this.m_strTargetName));

		/* mark that we've ended a sequence, if we're in one and que anim */
		if (m_iSequenceState == SEQUENCESTATE_ACTIVE) {
			if (m_flSequenceEnd) {
				float duration = frameduration(modelindex, m_flSequenceEnd);
				m_iSequenceState = SEQUENCESTATE_ENDING;
				think = FreeState;
				nextthink = time + duration;
				dprint(sprintf("^2CBaseMonster::CheckRoute^7: %s overriding anim for %f seconds (modelindex %d, frame %d)\n", this.m_strTargetName, duration, modelindex, m_flSequenceEnd));
			} else {
				/* we still need to trigger targets */
				think = FreeState;
				nextthink = time;
				dprint(sprintf("^2CBaseMonster::CheckRoute^7: %s has no anim, finished sequence.\n", this.m_strTargetName));
			}
		}
	}

	/*if ( flDist == m_flLastDist ) {
		m_flNodeGiveup += frametime;
	} else {
		m_flNodeGiveup = bound( 0, m_flNodeGiveup - frametime, 1.0 );
	}

	m_flLastDist = flDist;

	if ( m_flNodeGiveup >= 1.0f ) {
		print(sprintf("CBaseMonster::CheckNode: %s gave up route\n",
			this.netname));
		ClearRoute();
	}*/
}

void CBaseMonster::WalkRoute(void)
{
	if (m_iNodes) {
		vector endangles;
		/* we're on our last node */
		if (m_iCurNode < 0) {
			endangles = vectoangles(m_vecLastNode - origin);
		} else {
			endangles = vectoangles(m_pRoute[m_iCurNode].dest - origin);
		}
		input_angles[1] = endangles[1];
		input_movevalues = [m_flSequenceSpeed, 0, 0];
	}
}

void CBaseMonster::NewRoute(vector destination)
{
	/* engine calls this upon successfully creating a route */
	static void NewRoute_RouteCB(entity ent, vector dest, int numnodes, nodeslist_t *nodelist)
	{
		CBaseMonster p = (CBaseMonster)ent;
		p.m_iNodes = numnodes;
		p.m_iCurNode = numnodes - 1;
		p.m_pRoute = nodelist;

		/* we can walk there directly */
		tracebox(p.origin, p.mins, p.maxs, dest, TRUE, this);
		if (trace_fraction == 1.0) {
			dprint("^2CBaseMonster::NewRoute^7: Walking directly to last node\n");
			p.m_iCurNode = -1;
		}
	}

	ClearRoute();

	if (!m_iNodes) {
		route_calculate(this, destination, 0, NewRoute_RouteCB);
		m_vecLastNode = destination;
	}
}

void CBaseMonster::Physics(void)
{
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;
	input_angles = angles = v_angle;
	input_timelength = frametime;

	/* override whatever we did above with this */
	if (m_iSequenceState == SEQUENCESTATE_ENDING) {
		input_angles = angles = v_angle = m_vecSequenceAngle;
		frame = m_flSequenceEnd;
	} else {
		movetype = MOVETYPE_WALK;
		CheckRoute();
		WalkRoute();
		runstandardplayerphysics(this);
		movetype = MOVETYPE_NONE;
		IdleNoise();

		if (style != MONSTER_DEAD) {
			if (m_flAnimTime > time) {
				input_movevalues = [0,0,0];
			} else {
				float spvel = vlen(velocity);

				if (spvel < 5) {
					frame = AnimIdle();
				} else if (spvel <= 140) {
					frame = AnimWalk();
				} else if (spvel <= 240) {
					frame = AnimRun();
				}
			}
		}
	}

	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
}

void CBaseMonster::touch(void)
{
	if (movetype != MOVETYPE_WALK) {
		return;
	}

	if (other.movetype == MOVETYPE_WALK) {
		velocity = normalize(other.origin - origin) * -128;
	}
}

void CBaseMonster::PlayerUse(void)
{

}

void CBaseMonster::Pain(int iHitBody)
{

}

void CBaseMonster::Death(int iHitBody)
{
	m_iFlags = 0x0;

	if (health < -50) {
		Gib();
		return;
	}

	/* make sure we're not causing any more obituaries */
	flags &= ~FL_MONSTER;

	/* gibbing action */
	movetype = MOVETYPE_NONE;
	solid = SOLID_CORPSE;
	style = MONSTER_DEAD;
}

void CBaseMonster::Hide(void)
{
	setmodel(this, "");
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
	customphysics = __NULL__;
}

void CBaseMonster::Respawn(void)
{
	v_angle[0] = Math_FixDelta(m_oldAngle[0]);
	v_angle[1] = Math_FixDelta(m_oldAngle[1]);
	v_angle[2] = Math_FixDelta(m_oldAngle[2]);
	flags |= FL_MONSTER;
	angles = v_angle;
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_WALK;
	takedamage = DAMAGE_YES;
	iBleeds = TRUE;
	customphysics = Physics;
	velocity = [0,0,0];
	m_iFlags = 0x0;
	SendFlags = 0xff;
	style = MONSTER_IDLE;
	health = base_health;
	setmodel(this, m_oldModel);
	setsize(this, base_mins, base_maxs);
	setorigin(this, m_oldOrigin);
}

void CBaseMonster::CBaseMonster(void)
{
	CBaseEntity::CBaseEntity();
}
