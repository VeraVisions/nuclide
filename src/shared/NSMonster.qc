/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

void
NSMonster::NSMonster(void)
{
#ifdef SERVER
	if (!HasSpawnFlags(MSF_MULTIPLAYER))
	if (g_grMode.MonstersSpawn() == FALSE) {
		remove(this);
		return;
	}
#endif
}

#ifdef SERVER
int
NSMonster::GetTriggerCondition(void)
{
	return m_iTriggerCondition;
}

void
NSMonster::TriggerTargets(void)
{
	for (entity f = world; (f = find(f, ::targetname, m_strTriggerTarget));) {
		NSTrigger trigger = (NSTrigger)f;
		if (trigger.Trigger != __NULL__) {
			trigger.Trigger(this, TRIG_TOGGLE);
		}
	}
}

void
NSMonster::Save(float handle)
{
	super::Save(handle);

	SaveEntity(handle, "m_eEnemy", m_eEnemy);
	SaveEntity(handle, "m_ssLast", m_ssLast);
	SaveFloat(handle, "base_health", base_health);
	SaveFloat(handle, "m_flAttackThink", m_flAttackThink);
	SaveFloat(handle, "m_flBaseTime", m_flBaseTime);
	SaveFloat(handle, "m_flPitch", m_flPitch);
	SaveFloat(handle, "m_flSequenceEnd", m_flSequenceEnd);
	SaveFloat(handle, "m_flSequenceSpeed", m_flSequenceSpeed);
	SaveInt(handle, "m_iFlags", m_iFlags);
	SaveInt(handle, "m_iSequenceFlags", m_iSequenceFlags);
	SaveInt(handle, "m_iSequenceRemove", m_iSequenceRemove);
	SaveInt(handle, "m_iSequenceState", m_iSequenceState);
	SaveInt(handle, "m_iTriggerCondition", m_iTriggerCondition);
	SaveFloat(handle, "m_iMState", m_iMState);
	SaveFloat(handle, "m_iOldMState", m_iOldMState);
	SaveFloat(handle, "m_iMoveState", m_iMoveState);
	SaveString(handle, "m_strRouteEnded", m_strRouteEnded);
	SaveString(handle, "m_strTriggerTarget", m_strTriggerTarget);
	SaveVector(handle, "base_maxs", base_maxs);
	SaveVector(handle, "base_mins", base_mins);
	SaveVector(handle, "m_vecLKPos", m_vecLKPos);
	SaveVector(handle, "m_vecSequenceAngle", m_vecSequenceAngle);
	SaveFloat(handle, "m_flSeeTime", m_flSeeTime);
	SaveFloat(handle, "m_flAnimTime", m_flAnimTime);
}

void
NSMonster::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_eEnemy":
		m_eEnemy = ReadEntity(strValue);
		break;
	case "m_ssLast":
		m_ssLast = ReadEntity(strValue);
		break;
	case "base_health":
		base_health = ReadFloat(strValue);
		break;
	case "m_flAttackThink":
		m_flAttackThink = ReadFloat(strValue);
		break;
	case "m_flBaseTime":
		m_flBaseTime = ReadFloat(strValue);
		break;
	case "m_flPitch":
		m_flPitch = ReadFloat(strValue);
		break;
	case "m_flSequenceEnd":
		m_flSequenceEnd = ReadFloat(strValue);
		break;
	case "m_flSequenceSpeed":
		m_flSequenceSpeed = ReadFloat(strValue);
		break;
	case "m_iFlags":
		m_iFlags = ReadInt(strValue);
		break;
	case "m_iSequenceFlags":
		m_iSequenceFlags = ReadInt(strValue);
		break;
	case "m_iSequenceRemove":
		m_iSequenceRemove = ReadInt(strValue);
		break;
	case "m_iSequenceState":
		m_iSequenceState = ReadInt(strValue);
		break;
	case "m_iTriggerCondition":
		m_iTriggerCondition = ReadInt(strValue);
		break;
	case "m_iMState":
		m_iMState = ReadFloat(strValue);
		break;
	case "m_iOldMState":
		m_iOldMState = ReadFloat(strValue);
		break;
	case "m_iMoveState":
		m_iMoveState = ReadFloat(strValue);
		break;
	case "m_strRouteEnded":
		m_strRouteEnded = ReadString(strValue);
		break;
	case "m_strTriggerTarget":
		m_strTriggerTarget = ReadString(strValue);
		break;
	case "base_maxs":
		base_maxs = ReadVector(strValue);
		break;
	case "base_mins":
		base_mins = ReadVector(strValue);
		break;
	case "m_vecLKPos":
		m_vecLKPos = ReadVector(strValue);
		break;
	case "m_vecSequenceAngle":
		m_vecSequenceAngle = ReadVector(strValue);
		break;
	case "m_flSeeTime":
		m_flSeeTime = ReadFloat(strValue);
		break;
	case "m_flAnimTime":
		m_flAnimTime = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

int
NSMonster::AnimIdle(void)
{
	return -1;
}

int
NSMonster::AnimWalk(void)
{
	return -1;
}

int
NSMonster::AnimRun(void)
{
	return -1;
}

void
NSMonster::AnimPlay(float seq)
{
	/* forces a client-side update */
	SetSendFlags(MONFL_CHANGED_FRAME);

	SetFrame(seq);
	m_flAnimTime = time + frameduration(modelindex, frame);
}

bool
NSMonster::InAnimation(void)
{
	return (m_flAnimTime > time) ? true : false;
}

void
NSMonster::Sound(string msg)
{
	sound(this, CHAN_VOICE, msg, 1.0, ATTN_NORM);
}

void
NSMonster::Gib(void)
{
	SetTakedamage(DAMAGE_NO);
	FX_GibHuman(origin, vectoangles(origin - g_dmg_eAttacker.origin), g_dmg_iDamage * 2.0f);
	Hide();
}

void
NSMonster::FallNoise(void)
{
}

void
NSMonster::IdleNoise(void)
{
}

bool
NSMonster::IsFriend(int al)
{
	if (m_iAlliance == MAL_ROGUE)
		return (false);
	else if (al == m_iAlliance)
		return (true);

	return (false);
}

/* The maximum distance to which we should attempt an attack */
float
NSMonster::MeleeMaxDistance(void)
{
	return 96;
}

/* Whether or not we should attempt a melee attack */
bool
NSMonster::MeleeCondition(void)
{
	return (vlen(origin - m_eEnemy.origin) < MeleeMaxDistance()) ? true : false;
}

float
NSMonster::SeeFOV(void)
{
	return 90;
}

void
NSMonster::AlertNearby(void)
{
	if (m_eEnemy == __NULL__)
		return;

	for (entity w = world; (w = findfloat(w, ::takedamage, DAMAGE_YES));) {
		if (!IsFriend(w.m_iAlliance))
			continue;

		/* only bother if within 512 unit radius */
		if (vlen(origin - w.origin) > 512)
			continue;

		//NSLog("Alert! %s get %s", w.classname, m_eEnemy.classname);
		NSMonster f = (NSMonster)w;

		/* we shouldn't override this when they already got a target */
		if (f.m_eEnemy != __NULL__)
			continue;

		f.m_eEnemy = m_eEnemy;
	}
}

/* returns TRUE if 'enemy' should be considered a valid target for killing */
bool
NSMonster::IsValidEnemy(entity enemy)
{
	if (enemy == __NULL__)
		return FALSE;
	/* dead enemy should not be considered valid */
	if (enemy.solid == SOLID_CORPSE || enemy.health <= 0)
		return FALSE;
	/* such monster should ignore players */
	if ((enemy.flags & FL_CLIENT) && HasSpawnFlags(MSF_IGNOREPLAYER))
		return FALSE;
	/* monsters ignore enemy who uses notarget cheat, useful for development */
	if (enemy.flags & FL_NOTARGET)
		return FALSE;
	/* if they're our friend... ignore */
	if (IsFriend(enemy.m_iAlliance))
		return FALSE;
	/* prevent from shooting non-sentient stuff */
	if (!(enemy.flags & (FL_MONSTER | FL_CLIENT)))
		return FALSE;

	return TRUE;
}

void
NSMonster::SeeThink(void)
{
	if (m_eEnemy) {
		/* check if we should invalidate current enemy */
		if (IsValidEnemy(m_eEnemy))
			return;

		/* enemy is not valid anymore, reset it, clear route and search for new enemy */
		SetState(MONSTER_ALERT);
		m_eEnemy = __NULL__;
		RouteClear();
		m_flSeeTime = 0;
	}

	if (m_flSeeTime > time)
		return;

	m_flSeeTime = time + 0.25f;

	/* a horse type monster always knows where the nearest player is */
	if (m_iFlags & MSF_HORDE) {
		m_eEnemy = NSMonster_FindClosestPlayer(this);

		if (m_eEnemy)
			RouteToPosition(m_eEnemy.origin);
		return;
	}

	for (entity w = world; (w = findfloat(w, ::takedamage, DAMAGE_YES));) {
		/* check if 'w' could be a valid enemy */
		if (!IsValidEnemy(w))
			continue;

		/* first, is the potential enemy in our field of view? */
		makevectors(v_angle);
		vector v = normalize(w.origin - origin);
		float flDot = v * v_forward;

		if (flDot < SeeFOV()/180)
			continue;

		traceline(origin, w.origin, MOVE_EVERYTHING, this);

		/* we have line of sight with the player */
		if (trace_fraction == 1.0f || trace_ent == w) {
			if (m_eEnemy != w) {
				m_eEnemy = w;
				AlertNearby();
			}

			return;
		}
	}
}

float
NSMonster::GetWalkSpeed(void)
{
	return 64;
}

float
NSMonster::GetChaseSpeed(void)
{
	return 240;
}


float
NSMonster::GetRunSpeed(void)
{
	return 140;
}

void
NSMonster::AttackThink(void)
{
	if (InSequence())
		return;

	if (m_flAttackThink > time)
		return;

	if (!m_eEnemy)
		return;

	/* do we have a clear shot? */
	other = world;
	traceline(origin, m_eEnemy.origin, MOVE_OTHERONLY, this);

	/* something is blocking us */
	if (trace_fraction < 1.0f) {
		SetState(MONSTER_ALERT);

		/* FIXME: This is unreliable, but unlikely that a player ever is here */
		if (m_vecLKPos != [0,0,0]) {
			RouteClear();
			RouteToPosition(m_vecLKPos);
			m_flSequenceSpeed = 140;
			m_vecLKPos = [0,0,0];
		}
	} else {
		SetState(MONSTER_AIMING);

		/* make sure we remember the last known position. */
		m_vecLKPos = m_eEnemy.origin;
	}

	/* the state may have switched */
	if (m_flAttackThink > time)
		return;

	if (GetState() == MONSTER_AIMING) {
		int m;
		if (MeleeCondition() == TRUE)
			m = AttackMelee();
		else {
			m = AttackRanged();

			/* if we don't have the desired attack mode, walk */
			if (m == FALSE)
				SetState(MONSTER_CHASING);	

		}
	}
}

int
NSMonster::AttackMelee(void)
{
	m_flAttackThink = time + 0.5f;
	return (0);
}

int
NSMonster::AttackRanged(void)
{
	m_flAttackThink = time + 0.5f;
	return (0);
}

void
NSMonster::AttackDraw(void)
{
	NSLog("^1%s::AttackDraw: Not defined!", classname);
	m_flAttackThink = time + 0.5f;
}

void
NSMonster::AttackHolster(void)
{
	NSLog("^1%s::AttackHolster: Not defined!", classname);
	m_flAttackThink = time + 0.5f;
}

void
NSMonster::FreeState(void)
{
	string to_trigger;
	m_flSequenceEnd = 0;
	m_iSequenceState = SEQUENCESTATE_NONE;
	m_iSequenceFlags = 0;

	if (m_ssLast) {
		scripted_sequence seq = (scripted_sequence)m_ssLast;
		seq.m_iValue = TRUE;
	}

	/* we're clearing m_strRouteEnded early, because m_strRouteEnded
	   might change when .Trigger is executed. It could be another scripted
	   sequence triggering another sequence. Hence the caching */
	to_trigger = m_strRouteEnded;
	m_strRouteEnded = __NULL__;
	m_ssLast = __NULL__;
		
	/* trigger when required */
	if (to_trigger) {
		for (entity f = world; (f = find(f, ::targetname, to_trigger));) {
			NSEntity trigger = (NSEntity)f;
			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(this, TRIG_TOGGLE);
			}
		}
	}

	if (m_iSequenceRemove) {
		Hide();
	}
	NSLog("^2%s::^3FreeState^7: (%i, %S)", classname, m_iSequenceRemove, to_trigger);
}

void
NSMonster::FreeStateMoved(void)
{
	vector new_origin;
	new_origin = gettaginfo(this, 1);
	NSLog("^2%s::^3FreeStateMoved^7: moved to %v", classname, new_origin);
	SetOrigin(new_origin);
	DropToFloor();
	FreeState();
}

void
NSMonster::RouteEnded(void)
{
	super::RouteEnded();

	if (GetSequenceState() != SEQUENCESTATE_ACTIVE)
		return;

	/* mark that we've ended a sequence, if we're in one and que anim */
	if (m_flSequenceEnd) {
		float duration = frameduration(modelindex, m_flSequenceEnd);
		m_iSequenceState = SEQUENCESTATE_ENDING;
		think = (m_iSequenceFlags & SSFL_NOSCRIPTMOVE) ? FreeState : FreeStateMoved;
		nextthink = time + duration;
		NSLog("^2%s::^3CheckRoute^7: %s overriding anim for %f seconds (modelindex %d, frame %d)", \
			classname, this.targetname, duration, modelindex, m_flSequenceEnd);
	} else {
		/* we still need to trigger targets */
		think = (m_iSequenceFlags & SSFL_NOSCRIPTMOVE) ? FreeState : FreeStateMoved;
		nextthink = time;
		NSLog("^2%s::^3CheckRoute^7: %s has no anim, finished sequence", \
			classname, this.targetname);
	}
}

void
NSMonster::WalkRoute(void)
{
	/* we're busy shooting at something, don't walk */
	if (GetState() == MONSTER_AIMING && m_eEnemy) {
		input_angles = vectoangles(m_eEnemy.origin - origin);
		input_angles[0] = input_angles[2] = 0;
	} else if (m_iNodes && (GetState() == MONSTER_IDLE || GetState() == MONSTER_ALERT)) {
		input_angles = GetRouteDirection();
		input_angles[0] = input_angles[2] = 0;
		input_movevalues = GetRouteMovevalues() * m_flSequenceSpeed;
	} else if (GetState() == MONSTER_CHASING && m_eEnemy) {
		/* we've got 'em in our sights, just need to walk closer */
		input_angles = vectoangles(m_eEnemy.origin - origin);
		input_angles[0] = input_angles[2] = 0;
		input_movevalues = [GetChaseSpeed(), 0, 0];
	} else
		return;

	/* yaw interpolation */
	{
	vector new_ang;
	vector old_ang;
	vector tmp;
	makevectors(input_angles);
	new_ang = v_forward;
	makevectors(angles);
	old_ang = v_forward;

	tmp[0] = Math_Lerp(old_ang[0], new_ang[0], frametime * 5);
	tmp[1] = Math_Lerp(old_ang[1], new_ang[1], frametime * 5);
	tmp[2] = Math_Lerp(old_ang[2], new_ang[2], frametime * 5);
	input_angles = vectoangles(tmp);
	input_angles[0] = input_angles[2] = 0;
	}
}

void
NSMonster::AnimationUpdate(void)
{
	int fr = 0;
	int act = 0;

	if (GetState() == MONSTER_DEAD)
		return;

	float spvel = vlen(velocity);
	float midspeed = GetWalkSpeed() + ((GetRunSpeed() -  GetWalkSpeed()) * 0.5f);

	if (spvel < 5) {
		fr = AnimIdle();

		if (m_iMoveState != MOVESTATE_IDLE)
			m_flAnimTime = 0.0f;

		if (fr == -1)
			act = (frameforaction(modelindex, ACT_IDLE));


		m_iMoveState = MOVESTATE_IDLE;
	} else if (spvel < midspeed) {
		fr = AnimWalk();

		if (m_iMoveState != MOVESTATE_WALK)
				m_flAnimTime = 0.0f;

		if (fr == -1)
			act = (frameforaction(modelindex, ACT_WALK));
		

		m_iMoveState = MOVESTATE_WALK;
	} else {
		fr = AnimRun();

		if (m_iMoveState != MOVESTATE_RUN)
			m_flAnimTime = 0.0f;

		if (fr == -1)
			act = (frameforaction(modelindex, ACT_RUN));

		m_iMoveState = MOVESTATE_RUN;
	}

	if (m_flAnimTime > 0.0f) {
		return;
	}

	if (fr == -1)
		AnimPlay(act);
	else
		SetFrame(fr);
}

/* for an NSMonster, health doesn't matter that much, as we could be a corpse */
bool
NSMonster::IsAlive(void)
{
	if (GetState() == MONSTER_DEAD)
		return false;

	return true;
}

void
NSMonster::StateChanged(monsterState_e oldState, monsterState_e newState)
{
	NSLog("^2%s::^3StateChanged^7: state changed from %d to %d", \
		classname, oldState, newState);
}

void
NSMonster::SetState(monsterState_e newState)
{
	if (newState == m_iMState)
		return;

	m_iOldMState = m_iMState;
	m_iMState = newState;
	StateChanged(m_iOldMState, m_iMState);
}

monsterState_e
NSMonster::GetState(void)
{
	return m_iMState;
}

int
NSMonster::GetSequenceState(void)
{
	return m_iSequenceState;
}

bool
NSMonster::InSequence(void)
{
	return (GetSequenceState() == SEQUENCESTATE_NONE) ? false : true;
}

void
NSMonster::RunAI(void)
{
	SeeThink();
	AttackThink();
}

void PMoveCustom_RunPlayerPhysics(entity target);
void PMoveCustom_RunCrouchPhysics(entity target);
void
NSMonster::Physics(void)
{
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;
	input_timelength = frametime;
	input_angles = angles;

	/* when stuck in a sequence, forget enemies, combat stance */
	if (GetSequenceState() != SEQUENCESTATE_NONE) {
		m_eEnemy = __NULL__;
		SetState(MONSTER_IDLE);
	}

	/* we're ending a scripted sequence, so play its animation */
	if (GetSequenceState() == SEQUENCESTATE_ENDING) {
		angles[1] = input_angles[1] = m_vecSequenceAngle[1];
		SetFrame(m_flSequenceEnd);
	} else {
		/* if still alive... */
		if (IsAlive()) {
			/* only run AI functions when not in a scripted sequence */
			if (InSequence() == false) {
				RunAI();
			}

			AnimationUpdate();
		}

		/* suppress movement when playing an animation outside
		   a scripted sequence */
		if (InAnimation() == true && InSequence() == false) {
			input_movevalues = [0,0,0];
		} else {
			CheckRoute();
			WalkRoute();
		}

		hitcontentsmaski = CONTENTBITS_MONSTER;

		if (CanCrouch())
			PMoveCustom_RunCrouchPhysics(this);
		else
			PMoveCustom_RunPlayerPhysics(this);

		SetOrigin(origin);
	}

	if (!(GetFlags() & FL_ONGROUND) && velocity[2] < -415) {
		if (!(m_iFlags & MSF_FALLING)) {
			FallNoise();
		}

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

	m_flBaseTime = frame1time;
	frame1time += frametime;

	processmodelevents(modelindex, frame, m_flBaseTime,
		frame1time, Game_ServerModelEvent);
}

void
NSMonster::Touch(entity eToucher)
{
	if (movetype != MOVETYPE_WALK)
		return;

	if (eToucher.movetype == MOVETYPE_WALK) {
		if (eToucher.absmin[2] < origin[2])
			velocity = normalize(eToucher.origin - origin) * -128;
	}
}

void
NSMonster::Pain(void)
{
	/* dead things tell nuthin */
	if (IsAlive() == false)
		return;

	if (GetHealth() <= (base_health / 2)) {
		if (IsFriend(g_dmg_eAttacker.m_iAlliance) == true)
			m_iAlliance = MAL_ROGUE;
	}

	if (IsFriend(g_dmg_eAttacker.m_iAlliance) == true)
		return;

	/* if don't have an enemy, set one; else make it random */
	if (!m_eEnemy || (random() < 0.5))
		m_eEnemy = g_dmg_eAttacker;

	/* an alert monster will take a while to calm back down */
	SetState(MONSTER_ALERT);

	/* alert all nearby friendlies */
	AlertNearby();
}

void
NSMonster::Death(void)
{
	/* we were already dead before, so gib */
	if (GetState() == MONSTER_DEAD) {
		Gib();
		return;
	}

	m_iFlags = 0x0;

	/* if we make more than 50 damage, gib immediately */
	if (GetHealth() < -50) {
		Gib();
		return;
	}

	/* make sure we're not causing any more obituaries */
	RemoveFlags(FL_MONSTER);

	/* set the monster up for getting gibbed */
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_CORPSE);
	SetHealth(50 + GetHealth());
	SetState(MONSTER_DEAD);

	/* monsters trigger their targets when dead */
	if (GetTriggerCondition() == MTRIG_DEATH)
		TriggerTargets();
}

void
NSMonster::Hide(void)
{
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	customphysics = __NULL__;
}

void
NSMonster::Respawn(void)
{
	v_angle = GetSpawnAngles();
	v_angle[0] = Math_FixDelta(v_angle[0]);
	v_angle[1] = Math_FixDelta(v_angle[1]);
	v_angle[2] = Math_FixDelta(v_angle[2]);

	AddFlags(FL_MONSTER);
	SetTakedamage(DAMAGE_YES);
	SetVelocity([0,0,0]);
	SetState(MONSTER_IDLE);
	SetHealth(base_health);
	m_eEnemy = __NULL__;
	m_iFlags = 0x0;
	iBleeds = TRUE;
	customphysics = Physics;

	SetAngles(v_angle);
	SetSolid(SOLID_SLIDEBOX);
	SetMovetype(MOVETYPE_WALK);
	SetModel(GetSpawnModel());
	SetSize(base_mins, base_maxs);
	SetOrigin(GetSpawnOrigin());

	DropToFloor();
}

void
NSMonster::SpawnKey(string strKey, string strValue)
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
		NSSurfacePropEntity::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSMonster::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, MONFL_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, MONFL_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, MONFL_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, MONFL_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, MONFL_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, MONFL_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, MONFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, MONFL_CHANGED_SOLID)
	EVALUATE_FIELD(movetype, MONFL_CHANGED_FLAGS)
	EVALUATE_FIELD(flags, MONFL_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, MONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, MONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, MONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, MONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, MONFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, MONFL_CHANGED_SIZE)
	EVALUATE_FIELD(frame, MONFL_CHANGED_FRAME)
	EVALUATE_FIELD(skin, MONFL_CHANGED_SKIN)
	EVALUATE_FIELD(effects, MONFL_CHANGED_EFFECTS)
	EVALUATE_FIELD(m_iBody, MONFL_CHANGED_BODY)
	EVALUATE_FIELD(scale, MONFL_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, MONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, MONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, MONFL_CHANGED_VELOCITY)
	EVALUATE_FIELD(m_iRenderMode, MONFL_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_iRenderFX, MONFL_CHANGED_RENDERMODE)
	EVALUATE_VECTOR(m_vecRenderColor, 0, MONFL_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, MONFL_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, MONFL_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flRenderAmt, MONFL_CHANGED_RENDERAMT)
}

/* Make sure StartFrame calls this */
float
NSMonster::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_MONSTER);

	/* don't network triggers unless provoked */
	/*if (cvar("developer") == 0 && m_iRenderMode == RM_TRIGGER)
		return (0);*/

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], MONFL_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], MONFL_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], MONFL_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], MONFL_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], MONFL_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], MONFL_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, MONFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, MONFL_CHANGED_SOLID)
	SENDENTITY_BYTE(movetype, MONFL_CHANGED_FLAGS)
	SENDENTITY_INT(flags, MONFL_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], MONFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], MONFL_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, MONFL_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, MONFL_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, MONFL_CHANGED_EFFECTS)
	SENDENTITY_BYTE(m_iBody, MONFL_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, MONFL_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], MONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], MONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], MONFL_CHANGED_VELOCITY)
	SENDENTITY_BYTE(m_iRenderMode, MONFL_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, MONFL_CHANGED_RENDERMODE)
	SENDENTITY_ANGLE(m_vecRenderColor[0], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_vecRenderColor[1], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_vecRenderColor[2], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_flRenderAmt, MONFL_CHANGED_RENDERAMT)

	return (1);
}
#else

void
NSMonster::customphysics(void)
{
	/* Page intentionally left blank */
}

float
NSMonster::predraw(void)
{
	float render;

	render = super::predraw();

	/* are we inside of an interpolation? */
	if (frame != frame2) {
		/* we're done lerping */
		if (lerpfrac <= 0.0f)
			frame2 = frame;

		lerpfrac -= frametime * 4.0f;
	} else {
		/* make sure we're set up for next lerp */
		lerpfrac = 1.0f;
		frame2time = frame1time;
	}

	return render;
}

/*
============
NSMonster::ReceiveEntity
============
*/
void
NSMonster::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], MONFL_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], MONFL_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], MONFL_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], MONFL_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], MONFL_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], MONFL_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, MONFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, MONFL_CHANGED_SOLID)
	READENTITY_BYTE(movetype, MONFL_CHANGED_FLAGS)
	READENTITY_INT(flags, MONFL_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], MONFL_CHANGED_SIZE)
	READENTITY_COORD(mins[1], MONFL_CHANGED_SIZE)
	READENTITY_COORD(mins[2], MONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], MONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], MONFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], MONFL_CHANGED_SIZE)
	READENTITY_BYTE(frame, MONFL_CHANGED_FRAME)
	READENTITY_FLOAT(skin, MONFL_CHANGED_SKIN)
	READENTITY_FLOAT(effects, MONFL_CHANGED_EFFECTS)
	READENTITY_BYTE(m_iBody, MONFL_CHANGED_BODY)
	READENTITY_FLOAT(scale, MONFL_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], MONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], MONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], MONFL_CHANGED_VELOCITY)
	READENTITY_BYTE(m_iRenderMode, MONFL_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, MONFL_CHANGED_RENDERMODE)
	READENTITY_ANGLE(m_vecRenderColor[0], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_vecRenderColor[1], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_vecRenderColor[2], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_flRenderAmt, MONFL_CHANGED_RENDERAMT)

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & MONFL_CHANGED_FRAME)
		frame1time = 0.0f;
	if (flChanged & MONFL_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);
	if (flChanged & MONFL_CHANGED_BODY)
		setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_iBody, m_iBody));

	setorigin(this, origin);
}
#endif

#ifdef CLIENT
void
NSMonster_ReadEntity(bool new)
{
	NSMonster me = (NSMonster)self;
	if (new) {
		spawnfunc_NSMonster();
	}
	me.ReceiveEntity(new, readfloat());
}
#else

var float g_monsteralert_timer;
void
NSMonster_AlertEnemyAlliance(vector pos, float radius, int alliance)
{
	/* sometimes many alert-sounds happen at once... we don't really want that */
	if (g_monsteralert_timer > time)
		return;

	for (entity w = world; (w = findfloat(w, ::takedamage, DAMAGE_YES));) {
		/* out of radius */
		if (vlen(pos - w.origin) > radius)
			continue;

		/* only target monsters */
		if (!(w.flags & FL_MONSTER))
			continue;

		NSMonster f = (NSMonster)w;

		/* they already got a target of some kind */
		if (f.m_eEnemy)
			continue;

		/* if they're our friend... ignore*/
		if (f.IsFriend(alliance))
			continue;

		/* if the monster is dead... ignore */
		if (f.health <= 0)
			continue;

		/* we've heard a noise. investigate the location */
		f.RouteClear();
		f.RouteToPosition(pos);
		f.m_flSequenceSpeed = 140;
	}

	g_monsteralert_timer = time + 0.5f;
}

entity NSMonster_FindClosestPlayer(entity target) {
	NSMonster t = (NSMonster)target;
	entity best = world;
	float bestdist;
	float dist;

	bestdist = 9999999;

	for (entity e = world; (e = find(e, classname, "player"));) {
		/* hack: don't ever return dead players. they're invisible. */
		if (!t.IsValidEnemy(e))
			continue;

		dist = vlen(target.origin - e.origin);

		if (dist < bestdist) {
			bestdist = dist;
			best = e;
		}
	}

	return best;
}
#endif
