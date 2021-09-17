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

int
CBaseMonster::AnimIdle(void)
{
	return (0);
}

int
CBaseMonster::AnimWalk(void)
{
	return (0);
}

int
CBaseMonster::AnimRun(void)
{
	return (0);
}

void
CBaseMonster::AnimPlay(float seq)
{
	/* forces a client-side update */
	SetSendFlags(BASEFL_CHANGED_FRAME);

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
CBaseMonster::FallNoise(void)
{
}

void
CBaseMonster::IdleNoise(void)
{
}

int
CBaseMonster::IsFriend(int al)
{

	if (m_iAlliance == MAL_ROGUE)
		return (0);
	else if (al == m_iAlliance)
		return (1);

	return (0);
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

		if ((w.flags & FL_CLIENT) && (spawnflags & MSF_IGNOREPLAYER))
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
	if (m_iSequenceState != SEQUENCESTATE_NONE)
		return;

	if (m_flAttackThink > time)
		return;

	if (!m_eEnemy)
		return;

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
	return (0);
}

int
CBaseMonster::AttackRanged(void)
{
	m_flAttackThink = time + 0.5f;
	return (0);
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

	if (!m_iNodes)
		return;

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
		dprint(sprintf("^2CBaseMonster::^3CheckRoute^7: " \
			"%s reached node\n", this.targetname));
		m_iCurNode--;
		velocity = [0,0,0]; /* clamp friction */

		/* we've still traveling and from this node we may be able to walk
		 * directly to our end-destination */
		if (m_iCurNode > -1) {
			tracebox(origin, mins, maxs, m_vecLastNode, MOVE_NORMAL, this);

			/* can we walk directly to our target destination? */
			if (trace_fraction == 1.0) {
				dprint("^2CBaseMonster::^3CheckRoute^7: " \
					"Walking directly to last node\n");
				m_iCurNode = -1;
			}
		}
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
		input_movevalues = [m_flChaseSpeed, 0, 0];
		m_vecTurnAngle[1] = endangles[1];
	} else
		return;

	/* functional */
	input_angles[1] = v_angle[1] = m_vecTurnAngle[1];

#if 1
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
#endif
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

		//traceline(p.origin, dest, MOVE_NORMAL, this);
		tracebox(p.origin, p.mins, p.maxs, dest, MOVE_NORMAL, this);

		/* can we walk directly to our target destination? */
		if (trace_fraction == 1.0) {
			dprint("^2CBaseMonster::^3NewRoute^7: " \
				"Walking directly to last node\n");
			p.m_iCurNode = -1;
		} else {
			dprint("^2CBaseMonster::^3NewRoute^7: " \
				"Path obstructed, calculating route\n");

			/* run through all nodes, mark the closest direct path possible */
			for (int i = 0; i < p.m_iNodes; i++) {
				vector vecDest = p.m_pRoute[i].m_vecDest;
				tracebox(p.origin, p.mins, p.maxs, vecDest, TRUE, p);
				//traceline(p.origin, vecDest, MOVE_NORMAL, this);

				if (trace_fraction == 1.0) {
					p.m_iCurNode = i;
					break;
				}
			}
		}
	}

	if (!g_nodes_present)
		return;

	ClearRoute();

	if (!m_iNodes) {
		route_calculate(this, destination, 0, NewRoute_RouteCB);
		m_vecLastNode = destination;
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
		if (m_iSequenceState == SEQUENCESTATE_NONE) {
			SeeThink();
			AttackThink();
		}

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

	if (!(flags & FL_ONGROUND) && velocity[2] < -415) {
		if (!(m_iFlags & MSF_FALLING))
			FallNoise();

		m_iFlags |= MSF_FALLING;
	} else {
		m_iFlags &= ~MSF_FALLING;
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
	if (movetype != MOVETYPE_WALK)
		return;

	if (other.movetype == MOVETYPE_WALK) {
		if (other.absmin[2] < origin[2])
			velocity = normalize(other.origin - origin) * -128;
	}
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
	v_angle = GetSpawnAngles();
	v_angle[0] = Math_FixDelta(v_angle[0]);
	v_angle[1] = Math_FixDelta(v_angle[1]);
	v_angle[2] = Math_FixDelta(v_angle[2]);
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
	SetModel(GetSpawnModel());
	SetSize(base_mins, base_maxs);
	SetOrigin(GetSpawnOrigin());

	droptofloor();
}

void
CBaseMonster::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	/* The legacy GoldSrc trigger condition system */
	case "TriggerCondition":
		m_iTriggerCondition = stoi(strValue);
		break;
	case "TriggerTarget":
		m_strTriggerTarget = strValue;
		break;
	default:
		CBaseEntity::SpawnKey(strKey, strValue);
		break;
	}
}

/* Make sure StartFrame calls this */
float
CBaseMonster::SendEntity(entity ePEnt, float fChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_MONSTER);

	/* newly popped into the PVS, sadly this is the only hacky way to check
	 * for this right now. convince the engine maintainer to make this more sensible */
	if (fChanged == 0xFFFFFF) {
		/* check for defaults. if these are predictable fields, don't even bother
		 * networking them! you're just wasting bandwidth. */
		if (frame == 0)
			fChanged &= ~BASEFL_CHANGED_FRAME;
		if (skin == 0)
			fChanged &= ~BASEFL_CHANGED_SKIN;
		if (effects == 0)
			fChanged &= ~BASEFL_CHANGED_EFFECTS;
		if (m_iBody == 0)
			fChanged &= ~BASEFL_CHANGED_BODY;
		if (scale == 0.0 || scale == 1.0)
			fChanged &= ~BASEFL_CHANGED_SCALE;
		if (origin == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_ORIGIN;
		if (angles == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_ANGLES;
		if (velocity == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_VELOCITY;
		if (mins == [0,0,0] && maxs == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_SIZE;
		if (solid == SOLID_NOT)
			fChanged &= ~BASEFL_CHANGED_SOLID;
		if (movetype == MOVETYPE_NONE)
			fChanged &= ~BASEFL_CHANGED_MOVETYPE;
#ifdef GS_RENDERFX
		if (m_iRenderMode == RM_NORMAL)
			fChanged &= ~BASEFL_CHANGED_RENDERMODE;
#endif
	}

	/* don't network triggers unless provoked */
	/*if (cvar("developer") == 0 && m_iRenderMode == RM_TRIGGER)
		return (0);*/

#ifdef GS_RENDERFX
	/* let's not waste networking power on certain render-modes where they would
	 * not apply anyway. this seems sensible enough. */
	if (m_iRenderMode == RM_NORMAL || m_iRenderMode == RM_TRIGGER) {
		fChanged &= ~BASEFL_CHANGED_RENDERCOLOR;
		fChanged &= ~BASEFL_CHANGED_RENDERAMT;
	}
#endif

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & BASEFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	if (fChanged & BASEFL_CHANGED_ANGLES) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
	}
	if (fChanged & BASEFL_CHANGED_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
	}
	if (fChanged & BASEFL_CHANGED_SOLID) {
		WriteByte(MSG_ENTITY, solid);
	}
	if (fChanged & BASEFL_CHANGED_MOVETYPE) {
		WriteByte(MSG_ENTITY, movetype);
	}
	if (fChanged & BASEFL_CHANGED_SIZE) {
		WriteCoord(MSG_ENTITY, mins[0]);
		WriteCoord(MSG_ENTITY, mins[1]);
		WriteCoord(MSG_ENTITY, mins[2]);
		WriteCoord(MSG_ENTITY, maxs[0]);
		WriteCoord(MSG_ENTITY, maxs[1]);
		WriteCoord(MSG_ENTITY, maxs[2]);
	}
	if (fChanged & BASEFL_CHANGED_FRAME) {
		WriteByte(MSG_ENTITY, frame);
	}
	if (fChanged & BASEFL_CHANGED_SKIN) {
		WriteByte(MSG_ENTITY, skin + 128);
	}
	if (fChanged & BASEFL_CHANGED_EFFECTS) {
		WriteFloat(MSG_ENTITY, effects);
	}
	if (fChanged & BASEFL_CHANGED_BODY) {
		WriteByte(MSG_ENTITY, m_iBody);
	}
	if (fChanged & BASEFL_CHANGED_SCALE) {
		WriteFloat(MSG_ENTITY, scale);
	}
	if (fChanged & BASEFL_CHANGED_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

#ifdef GS_RENDERFX
	if (fChanged & BASEFL_CHANGED_RENDERFX) {
		WriteByte(MSG_ENTITY, m_iRenderFX);
	}
	if (fChanged & BASEFL_CHANGED_RENDERMODE) {
		WriteByte(MSG_ENTITY, m_iRenderMode);
	}

	if (fChanged & BASEFL_CHANGED_RENDERCOLOR) {
		WriteFloat(MSG_ENTITY, m_vecRenderColor[0]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[1]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[2]);
	}
	if (fChanged & BASEFL_CHANGED_RENDERAMT) {
		WriteFloat(MSG_ENTITY, m_flRenderAmt);
	}
#else
	if (fChanged & BASEFL_CHANGED_ALPHA) {
		WriteFloat(MSG_ENTITY, alpha);
	}
#endif

	return (1);
}

void
CBaseMonster::CBaseMonster(void)
{
	if (!(spawnflags & MSF_MULTIPLAYER))
	if (g_grMode.MonstersSpawn() == FALSE) {
		remove(this);
		return;
	}

	CBaseEntity::CBaseEntity();

	/* give us a 65 degree view cone */
	m_flFOV = 1.0 / 65;
	m_flChaseSpeed = 140;
}
