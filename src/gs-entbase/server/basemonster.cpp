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

typedef struct
{
	vector m_vecDest;
	int m_iFlags;
} nodeslist_t;

/* movement states */
enum
{
	MONSTER_IDLE,
	MONSTER_FOLLOWING,
	MONSTER_CHASING,
	MONSTER_AIMING,
	MONSTER_DEAD,
	MONSTER_GIBBED
};

/* scripted sequence states */
enum
{
	SEQUENCESTATE_NONE,
	SEQUENCESTATE_IDLE,
	SEQUENCESTATE_ACTIVE,
	SEQUENCESTATE_ENDING
};

/* monster flags */
enumflags
{
	MSF_WAITTILLSEEN,
	MSF_GAG,
	MSF_MONSTERCLIP,
	MSF_RESERVED1,
	MSF_PRISONER,
	MSF_RESERVED2,
	MSF_RESERVED3,
	MSF_WAITFORSCRIPT,
	MSF_PREDISASTER,
	MSF_FADECORPSE,
	MSF_MULTIPLAYER
};

/* alliance state */
enum
{
	MAL_FRIEND, /* friendly towards the player */
	MAL_ENEMY,  /* unfriendly towards the player */
	MAL_ALIEN,  /* unfriendly towards anyone but themselves */
	MAL_ROGUE   /* no allies, not even amongst themselves */
};

.int m_iAlliance;

class CBaseMonster:CBaseEntity
{
	vector oldnet_velocity;
	float m_flPitch;
	int m_iFlags;
	vector base_mins;
	vector base_maxs;
	int base_health;

	/* sequences */
	string m_strRouteEnded;
	int m_iSequenceRemove;
	int m_iSequenceState;
	float m_flSequenceEnd;
	float m_flSequenceSpeed;
	vector m_vecSequenceAngle;
	vector m_vecTurnAngle;

	/* model events */
	float m_flBaseTime;

	/* attack/alliance system */
	entity m_eEnemy;
	float m_flFOV;
	float m_flAttackThink;
	int m_iMState;
	vector m_vecLKPos; /* last-known pos */

	/* pathfinding */
	int m_iNodes;
	int m_iCurNode;
	nodeslist_t *m_pRoute;
	vector m_vecLastNode;

	void(void) CBaseMonster;
	virtual void(void) touch;
	virtual void(void) Hide;
	virtual void(void) Respawn;
	virtual void(void) PlayerUse;
	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) Physics;
	virtual void(void) IdleNoise;
	virtual void(void) Gib;
	virtual void(string) Sound;
	virtual void(float, int, string) ModelEvent;

	/* see/hear subsystem */
	float m_flSeeTime;
	virtual void(void) SeeThink;
	virtual float(void) SeeFOV;

	/* attack system */
	virtual void(void) AttackDraw;
	virtual void(void) AttackHolster;
	virtual void(void) AttackThink;
	virtual int(void) AttackMelee;
	virtual int(void) AttackRanged;

	/* sequences */
	virtual void(void) FreeState;
	virtual void(void) FreeStateMoved;
	virtual void(void) ClearRoute;
	virtual void(void) CheckRoute;
	virtual void(void) WalkRoute;
	virtual void(vector) NewRoute;

	/* animation cycles */
	float m_flAnimTime;
	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;
	virtual void(float) AnimPlay;
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

void
CBaseMonster::AnimPlay(float seq)
{
	/* forces a client-side update */
	SendFlags |= BASEFL_CHANGED_FRAME;

	SetFrame(seq);
	m_flAnimTime = time + frameduration(modelindex, frame);
}

void
CBaseMonster::Sound(string msg)
{
	sound(this, CHAN_VOICE, msg, 1.0, ATTN_NORM);
}

void
CBaseMonster::Gib(void)
{
	takedamage = DAMAGE_NO;
	FX_GibHuman(this.origin);
	Hide();
}

void
CBaseMonster::IdleNoise(void)
{

}

int
CBaseMonster::IsFriend(int al)
{

	if (m_iAlliance == MAL_ROGUE)
		return FALSE;
	else if (al == m_iAlliance)
		return TRUE;

	return FALSE;
}


float
CBaseMonster::SeeFOV(void)
{
	return 90;
}

void
CBaseMonster::SeeThink(void)
{
	if (m_eEnemy)
		return;

	if (m_flSeeTime > time)
		return;

	m_flSeeTime = time + 0.25f;

	for (entity w = world; (w = findfloat(w, ::takedamage, DAMAGE_YES));) {
		if (IsFriend(w.m_iAlliance))
			continue;

		if (w.health <= 0)
			continue;

		/* first, is the potential enemy in our field of view? */
		makevectors(v_angle);
		vector v = normalize(w.origin - origin);
		float flDot = v * v_forward;

		if (flDot < SeeFOV()/180)
			continue;

		other = world;
		traceline(origin, w.origin, MOVE_OTHERONLY, this);

		if (trace_fraction == 1.0f) {
			m_eEnemy = w;
			return;
		}
	}
}
void
CBaseMonster::AttackThink(void)
{
	if (m_flAttackThink > time) {
		return;
	}

	/* reset */
	if (m_eEnemy.solid == SOLID_CORPSE || (m_eEnemy && m_eEnemy.health <= 0)) {
		m_eEnemy = __NULL__;
		ClearRoute();
	}

	/* do we have a clear shot? */
	other = world;
	traceline(origin, m_eEnemy.origin, MOVE_OTHERONLY, this);

	/* something is blocking us */
	if (trace_fraction < 1.0f) {
		m_iMState = MONSTER_IDLE;

		/* FIXME: This is unreliable, but unlikely that a player ever is here */
		if (m_vecLKPos != [0,0,0]) {
			ClearRoute();
			NewRoute(m_vecLKPos);
			m_flSequenceSpeed = 140;
			m_vecLKPos = [0,0,0];
		}
	} else {
		m_iMState = MONSTER_AIMING;

		/* make sure we remember the last known position. */
		m_vecLKPos = m_eEnemy.origin;
	}

	if (m_iMState == MONSTER_AIMING) {
		int m;
		if (vlen(origin - m_eEnemy.origin) < 96)
			m = AttackMelee();
		else {
			m = AttackRanged();

			/* if we don't have the desired attack mode, walk */
			if (m == FALSE)
				m_iMState = MONSTER_CHASING;	

		}
	}
}

int
CBaseMonster::AttackMelee(void)
{
	m_flAttackThink = time + 0.5f;
	return FALSE;
}

int
CBaseMonster::AttackRanged(void)
{
	m_flAttackThink = time + 0.5f;
	return FALSE;
}

void
CBaseMonster::AttackDraw(void)
{
	dprint(sprintf("^1%s::AttackDraw: Not defined!\n", classname));
	m_flAttackThink = time + 0.5f;
}

void
CBaseMonster::AttackHolster(void)
{
	dprint(sprintf("^1%s::AttackHolster: Not defined!\n", classname));
	m_flAttackThink = time + 0.5f;
}

void
CBaseMonster::ClearRoute(void)
{
	if (m_iNodes) {
		m_iNodes = 0;
		memfree(m_pRoute);
	}
}

void
CBaseMonster::FreeState(void)
{
	string to_trigger;
	m_flSequenceEnd = 0;
	m_iSequenceState = SEQUENCESTATE_NONE;

	/* we're clearing m_strRouteEnded early, because m_strRouteEnded
	   might change when .Trigger is executed. It could be another scripted
	   sequence triggering another sequence. Hence the caching */
	to_trigger = m_strRouteEnded;
	m_strRouteEnded = __NULL__;
		
	/* trigger when required */
	if (to_trigger) {
		for (entity f = world; (f = find(f, ::targetname, to_trigger));) {
			CBaseTrigger trigger = (CBaseTrigger)f;
			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(this, TRIG_TOGGLE);
			}
		}
	}

	if (m_iSequenceRemove) {
		Hide();
	}
}

void
CBaseMonster::FreeStateMoved(void)
{
	vector new_origin;
	new_origin = gettaginfo(this, 0);
	SetOrigin(new_origin);
	FreeState();
}

void
CBaseMonster::CheckRoute(void)
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
		evenpos = m_pRoute[m_iCurNode].m_vecDest;
		evenpos[2] = origin[2];
	}

	flDist = floor(vlen(evenpos - origin));

	if (flDist < 8) {
		dprint(sprintf("^2CBaseMonster::^3CheckRoute^7: %s reached node\n", this.targetname));
		m_iCurNode--;
		velocity = [0,0,0]; /* clamp friction */
	}

	if (m_iCurNode < -1) {
		ClearRoute();
		dprint(sprintf("^2CBaseMonster::^3CheckRoute^7: %s reached end\n", this.targetname));

		/* mark that we've ended a sequence, if we're in one and que anim */
		if (m_iSequenceState == SEQUENCESTATE_ACTIVE) {
			if (m_flSequenceEnd) {
				float duration = frameduration(modelindex, m_flSequenceEnd);
				m_iSequenceState = SEQUENCESTATE_ENDING;
				think = FreeState;
				nextthink = time + duration;
				dprint(sprintf("^2CBaseMonster::^3CheckRoute^7: %s overriding anim for %f seconds (modelindex %d, frame %d)\n", this.targetname, duration, modelindex, m_flSequenceEnd));
			} else {
				/* we still need to trigger targets */
				think = FreeState;
				nextthink = time;
				dprint(sprintf("^2CBaseMonster::^3CheckRoute^7: %s has no anim, finished sequence.\n", this.targetname));
			}
		}
	}

	/*if (flDist == m_flLastDist) {
		m_flNodeGiveup += frametime;
	} else {
		m_flNodeGiveup = bound(0, m_flNodeGiveup - frametime, 1.0);
	}

	m_flLastDist = flDist;

	if (m_flNodeGiveup >= 1.0f) {
		print(sprintf("CBaseMonster::CheckNode: %s gave up route\n",
			this.netname));
		ClearRoute();
	}*/
}

void
CBaseMonster::WalkRoute(void)
{
	vector endangles;

	/* we're busy shooting at something, don't walk */
	if (m_iMState == MONSTER_AIMING) {
		endangles = vectoangles(m_eEnemy.origin - origin);

		/* TODO: lerp */
		m_vecTurnAngle[1] = endangles[1];
	} else if (m_iNodes && m_iMState == MONSTER_IDLE) {
		/* we're on our last node */
		if (m_iCurNode < 0) {
			endangles = vectoangles(m_vecLastNode - origin);
		} else {
			endangles = vectoangles(m_pRoute[m_iCurNode].m_vecDest - origin);
		}
		m_vecTurnAngle[1] = endangles[1];
		input_movevalues = [m_flSequenceSpeed, 0, 0];
	} else if (m_iMState == MONSTER_CHASING) {
		/* we've got 'em in our sights, just need to walk closer */
		endangles = vectoangles(m_eEnemy.origin - origin);
		input_movevalues = [140, 0, 0];
		m_vecTurnAngle[1] = endangles[1];
	} else {
		return;
	}

	/* functional */
	input_angles[1] = v_angle[1] = m_vecTurnAngle[1];

	/* cosmetic */
	vector new_ang;
	vector old_ang;
	vector tmp;
	makevectors(m_vecTurnAngle);
	new_ang = v_forward;
	makevectors(angles);
	old_ang = v_forward;	

	tmp[0] = Math_Lerp(old_ang[0], new_ang[0], frametime * 5);
	tmp[1] = Math_Lerp(old_ang[1], new_ang[1], frametime * 5);
	tmp[2] = Math_Lerp(old_ang[2], new_ang[2], frametime * 5);
	angles = vectoangles(tmp);
}

void
CBaseMonster::NewRoute(vector destination)
{
	/* engine calls this upon successfully creating a route */
	static void NewRoute_RouteCB(entity ent, vector dest, int numnodes, nodeslist_t *nodelist)
	{
		CBaseMonster p = (CBaseMonster)ent;
		p.m_iNodes = numnodes;
		p.m_iCurNode = numnodes - 1;
		p.m_pRoute = nodelist;

		tracebox(p.origin, p.mins, p.maxs, dest, MOVE_NORMAL, this);

		/* can we walk directly to our target destination? */
		if (trace_fraction == 1.0) {
			dprint("^2CBaseMonster::^3NewRoute^7: " \
				"Walking directly to last node\n");
			p.m_iCurNode = -1;
		} else {
			/* run through all nodes, mark the closest direct path possible */
			for (int i = 0; i < p.m_iNodes; i++) {
				vector vecDest = p.m_pRoute[i].m_vecDest;
				tracebox(p.origin, p.mins, p.maxs, vecDest, TRUE, p);

				if (trace_fraction == 1.0) {
					p.m_iCurNode = i;
					break;
				}
			}
		}
	}

	ClearRoute();

	if (!m_iNodes) {
		route_calculate(this, destination, 0, NewRoute_RouteCB);
		m_vecLastNode = destination;
	}
}

void
CBaseMonster::ModelEvent(float fTimeStamp, int iCode, string sData)
{
	switch (iCode) {
	case 1003:
		for (entity f = world; (f = find(f, ::targetname, sData));) {
			CBaseTrigger trigger = (CBaseTrigger)f;
			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(this, TRIG_TOGGLE);
				dprint(sprintf("^2%s^7::^3ModelEvent^7: " \
					"Calling trigger '%s'\n",
					classname, sData));
			}
		}
		break;
	/* things handled on the client-side */
	case 1004:
		break;
	default:
		dprint(sprintf("^3[SERVER]^7 Unknown model-event code " \
			"%i with data %s\n", iCode, sData));
		break;
	}
}

void
CBaseMonster::Physics(void)
{
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;
	input_angles = v_angle;
	input_timelength = frametime;

	/* override whatever we did above with this */
	if (m_iSequenceState == SEQUENCESTATE_ENDING) {
		input_angles = v_angle = angles = m_vecSequenceAngle;
		SetFrame(m_flSequenceEnd);
	} else if (movetype == MOVETYPE_WALK) {
		SeeThink();
		AttackThink();
		CheckRoute();
		WalkRoute();
		runstandardplayerphysics(this);
		SetOrigin(origin);
		IdleNoise();

		if (style != MONSTER_DEAD) {
			if (m_flAnimTime > time) {
				input_movevalues = [0,0,0];
			} else {
				float spvel = vlen(velocity);

				if (spvel < 5) {
					SetFrame(AnimIdle());
				} else if (spvel <= 140) {
					SetFrame(AnimWalk());
				} else if (spvel <= 240) {
					SetFrame(AnimRun());
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

	frame1time += frametime;
}

void
CBaseMonster::touch(void)
{
	if (movetype != MOVETYPE_WALK) {
		return;
	}

	if (other.movetype == MOVETYPE_WALK) {
		velocity = normalize(other.origin - origin) * -128;
	}
}

void
CBaseMonster::PlayerUse(void)
{

}

void
CBaseMonster::Pain(void)
{
	if (!m_eEnemy)
		m_eEnemy = g_dmg_eAttacker;
}

void
CBaseMonster::Death(void)
{
	/* we were already dead before, so gib */
	if (style == MONSTER_DEAD) {
		Gib();
		return;
	}

	m_iFlags = 0x0;

	/* if we make more than 50 damage, gib immediately */
	if (health < -50) {
		Gib();
		return;
	}

	/* make sure we're not causing any more obituaries */
	flags &= ~FL_MONSTER;
	m_iFlags = 0x0;

	/* gibbing action */
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_CORPSE);
	health = 50 + health; 
	style = MONSTER_DEAD;
}

void
CBaseMonster::Hide(void)
{
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	customphysics = __NULL__;
}

void
CBaseMonster::Respawn(void)
{
	v_angle[0] = Math_FixDelta(m_oldAngle[0]);
	v_angle[1] = Math_FixDelta(m_oldAngle[1]);
	v_angle[2] = Math_FixDelta(m_oldAngle[2]);
	flags |= FL_MONSTER;
	takedamage = DAMAGE_YES;
	iBleeds = TRUE;
	customphysics = Physics;
	velocity = [0,0,0];
	m_iFlags = 0x0;
	SendFlags = 0xff;
	style = MONSTER_IDLE;
	health = base_health;
	m_eEnemy = __NULL__;

	SetAngles(v_angle);
	SetSolid(SOLID_SLIDEBOX);
	SetMovetype(MOVETYPE_WALK);
	SetModel(m_oldModel);
	SetSize(base_mins, base_maxs);
	SetOrigin(m_oldOrigin);

	droptofloor();
}

void
CBaseMonster::CBaseMonster(void)
{
	/* FIXME: Put this somewhere else? */
	if (!(spawnflags & MSF_MULTIPLAYER))
	if (!(cvar("coop") == 1 || cvar("sv_playerslots") == 1)) {
		remove(this);
		return;
	}

	CBaseEntity::CBaseEntity();

	/* give us a 65 degree view cone */
	m_flFOV = 1.0 / 65;
}
