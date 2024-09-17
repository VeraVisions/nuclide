/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

var float autocvar_ai_walkSpeed = 150;
var float autocvar_ai_runSpeed = 320;

void
NSMonster::NSMonster(void)
{
#ifdef SERVER
	m_ssLast = __NULL__;
	oldnet_velocity = g_vec_null;
	m_flPitch = 1.0f;
	m_iFlags = 0i;
	m_strRouteEnded = __NULL__;
	m_iSequenceRemove = 0i;
	m_iSequenceState = 0i;
	m_flSequenceEnd = 0.0f;
	m_flSequenceSpeed = 0.0f;
	m_vecSequenceAngle = g_vec_null;
	m_iSequenceFlags = 0i;
	m_strSequenceKillTarget = __NULL__;
	m_iMoveState = 0i;
	m_iTriggerCondition = 0i;
	m_strTriggerTarget = __NULL__;
	m_flBaseTime = 0.0f;
	m_eEnemy = __NULL__;
	m_flAttackThink = 0.0f;
	m_iMState = 0i;
	m_iOldMState = 0i;
	m_vecLKPos = g_vec_null;
	m_flSeeTime = 0.0f;
	m_flAnimTime = 0.0f;
	m_flTrackingTime = 0.0f;
	m_actIdle = -1;
	m_flIdleNext = 0.0f;
	m_flEyeHeight = 64.0f;

	m_sndSight = __NULL__;
	m_sndIdle = __NULL__;
	m_flIdleMin = 5.0f;
	m_flIdleMax = 10.0f;
	m_sndFootstep = __NULL__;
	m_sndChatter = __NULL__;
	m_sndChatterCombat = __NULL__;
	m_sndPain = __NULL__;
	m_sndMeleeAttack = __NULL__;
	m_sndMeleeAttackHit = __NULL__;
	m_sndMeleeAttackMiss = __NULL__;
	m_sndDeath = __NULL__;
	m_sndThud = __NULL__;
	m_defMelee = __NULL__;
	m_defSpecial1 = __NULL__;
	m_iNumProjectiles = 1i;
	m_flProjectileDelay = 0.0f;
	m_flProjectileSpread = 0.0f;
	m_flAttackCone = 0.0f;
	m_flAttackAccuracy = 1.0f;
	m_flMeleeRange = -1;

	m_defRanged1 = __NULL__;
	m_defRanged2 = __NULL__;

	/* invalidate all ranges. */
	m_flRanged1Range =
	m_flRanged2Range =
	m_flSpecial1Range =
	m_flSpecial2Range = -1.0f;

	m_flReserveAmmo = -1; /* unlimited */

	m_bWeaponStartsDrawn = true;

	m_flWalkSpeed = autocvar_ai_walkSpeed;
	m_flRunSpeed = autocvar_ai_runSpeed;
	m_flLeapDamage = 0;
	m_bLeapAttacked = false;
	maxspeed = 1024;
	m_bGagged = false;
	m_flSkin = 0;
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

	SaveFloat(handle, "m_flHeadYaw", m_flHeadYaw);
	SaveFloat(handle, "frame1time", frame1time);
	SaveFloat(handle, "subblendfrac", subblendfrac);
	SaveFloat(handle, "bonecontrol1", bonecontrol1);
	SaveEntity(handle, "m_eLookAt", m_eLookAt);
	SaveEntity(handle, "m_ssLast", m_ssLast);
	SaveFloat(handle, "m_flPitch", m_flPitch);
	SaveInt(handle, "m_iFlags", m_iFlags);
	SaveString(handle, "m_strRouteEnded", m_strRouteEnded);
	SaveInt(handle, "m_iSequenceRemove", m_iSequenceRemove);
	SaveInt(handle, "m_iSequenceState", m_iSequenceState);
	SaveFloat(handle, "m_flSequenceEnd", m_flSequenceEnd);
	SaveFloat(handle, "m_flSequenceSpeed", m_flSequenceSpeed);
	SaveVector(handle, "m_vecSequenceAngle", m_vecSequenceAngle);
	SaveInt(handle, "m_iSequenceFlags", m_iSequenceFlags);
	SaveString(handle, "m_strSequenceKillTarget", m_strSequenceKillTarget);
	SaveFloat(handle, "m_iMoveState", m_iMoveState);
	SaveInt(handle, "m_iTriggerCondition", m_iTriggerCondition);
	SaveString(handle, "m_strTriggerTarget", m_strTriggerTarget);
	SaveFloat(handle, "m_flBaseTime", m_flBaseTime);
	SaveEntity(handle, "m_eEnemy", m_eEnemy);
	SaveFloat(handle, "m_flAttackThink", m_flAttackThink);
	SaveFloat(handle, "m_iMState", m_iMState);
	SaveFloat(handle, "m_iOldMState", m_iOldMState);
	SaveVector(handle, "m_vecLKPos", m_vecLKPos);
	SaveFloat(handle, "m_flSeeTime", m_flSeeTime);
	SaveFloat(handle, "m_flAnimTime", m_flAnimTime);
	SaveFloat(handle, "m_flTrackingTime", m_flTrackingTime);
	SaveVector(handle, "view_ofs", view_ofs);
	SaveFloat(handle, "m_actIdle", m_actIdle);
	SaveBool(handle, "m_bTurning", m_bTurning);
	SaveFloat(handle, "m_flIdleNext", m_flIdleNext);
	SaveFloat(handle, "_m_flMeleeAttempts", _m_flMeleeAttempts);
	SaveFloat(handle, "_m_flMeleeDelay", _m_flMeleeDelay);
	SaveFloat(handle, "_m_flBurstCount", _m_flBurstCount);
	SaveBool(handle, "_m_bShouldThrow", _m_bShouldThrow);
	SaveFloat(handle, "_m_flReloadTracker", _m_flReloadTracker);
	SaveBool(handle, "m_bWeaponDrawn", m_bWeaponDrawn);
	SaveFloat(handle, "m_flEyeHeight", m_flEyeHeight);
	SaveString(handle, "m_sndSight", m_sndSight);
	SaveString(handle, "m_sndIdle", m_sndIdle);
	SaveFloat(handle, "m_flIdleMin", m_flIdleMin);
	SaveFloat(handle, "m_flIdleMax", m_flIdleMax);
	SaveString(handle, "m_sndFootstep", m_sndFootstep);
	SaveString(handle, "m_sndChatter", m_sndChatter);
	SaveString(handle, "m_sndChatterCombat", m_sndChatterCombat);
	SaveString(handle, "m_sndPain", m_sndPain);
	SaveString(handle, "m_sndMeleeAttack", m_sndMeleeAttack);
	SaveString(handle, "m_sndMeleeAttackHit", m_sndMeleeAttackHit);
	SaveString(handle, "m_sndMeleeAttackMiss", m_sndMeleeAttackMiss);
	SaveString(handle, "m_sndDeath", m_sndDeath);
	SaveString(handle, "m_sndThud", m_sndThud);
	SaveString(handle, "m_defSpecial1", m_defSpecial1);
	SaveFloat(handle, "m_flSpecial1Range", m_flSpecial1Range);
	SaveString(handle, "m_defSpecial2", m_defSpecial2);
	SaveFloat(handle, "m_flSpecial2Range", m_flSpecial2Range);
	SaveString(handle, "m_defRanged1", m_defRanged1);
	SaveFloat(handle, "m_flRanged1Range", m_flRanged1Range);
	SaveString(handle, "m_defRanged2", m_defRanged2);
	SaveFloat(handle, "m_flRanged2Range", m_flRanged2Range);
	SaveInt(handle, "m_iNumProjectiles", m_iNumProjectiles);
	SaveFloat(handle, "m_flProjectileDelay", m_flProjectileDelay);
	SaveFloat(handle, "m_flProjectileSpread", m_flProjectileSpread);
	SaveFloat(handle, "m_flAttackCone", m_flAttackCone);
	SaveFloat(handle, "m_flAttackAccuracy", m_flAttackAccuracy);
	SaveString(handle, "m_defMelee", m_defMelee);
	SaveFloat(handle, "m_flMeleeRange", m_flMeleeRange);
	SaveString(handle, "m_sndRangedAttack", m_sndRangedAttack);
	SaveFloat(handle, "m_flReloadCount", m_flReloadCount);
	SaveFloat(handle, "m_flReloadDelay", m_flReloadDelay);
	SaveString(handle, "m_sndReload", m_sndReload);
	SaveFloat(handle, "m_flReserveAmmo", m_flReserveAmmo);
	SaveString(handle, "m_sndRangedAttack2", m_sndRangedAttack2);
	SaveBool(handle, "m_bWeaponStartsDrawn", m_bWeaponStartsDrawn);
	SaveString(handle, "m_strBodyOnDraw", m_strBodyOnDraw);
	SaveFloat(handle, "m_flWalkSpeed", m_flWalkSpeed);
	SaveFloat(handle, "m_flRunSpeed", m_flRunSpeed);
	SaveFloat(handle, "m_flLeapDamage", m_flLeapDamage);
	SaveBool(handle, "m_bLeapAttacked", m_bLeapAttacked);
}

void
NSMonster::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flHeadYaw":
		m_flHeadYaw = ReadFloat(strValue);
		break;
	case "frame1time":
		frame1time = ReadFloat(strValue);
		break;
	case "subblendfrac":
		subblendfrac = ReadFloat(strValue);
		break;
	case "bonecontrol1":
		bonecontrol1 = ReadFloat(strValue);
		break;
	case "m_eLookAt":
		m_eLookAt = ReadEntity(strValue);
		break;
	case "m_ssLast":
		m_ssLast = ReadEntity(strValue);
		break;
	case "m_flPitch":
		m_flPitch = ReadFloat(strValue);
		break;
	case "m_iFlags":
		m_iFlags = ReadInt(strValue);
		break;
	case "m_strRouteEnded":
		m_strRouteEnded = ReadString(strValue);
		break;
	case "m_iSequenceRemove":
		m_iSequenceRemove = ReadInt(strValue);
		break;
	case "m_iSequenceState":
		m_iSequenceState = ReadInt(strValue);
		break;
	case "m_flSequenceEnd":
		m_flSequenceEnd = ReadFloat(strValue);
		break;
	case "m_flSequenceSpeed":
		m_flSequenceSpeed = ReadFloat(strValue);
		break;
	case "m_vecSequenceAngle":
		m_vecSequenceAngle = ReadVector(strValue);
		break;
	case "m_iSequenceFlags":
		m_iSequenceFlags = ReadInt(strValue);
		break;
	case "m_strSequenceKillTarget":
		m_strSequenceKillTarget = ReadString(strValue);
		break;
	case "m_iMoveState":
		m_iMoveState = ReadFloat(strValue);
		break;
	case "m_iTriggerCondition":
		m_iTriggerCondition = ReadInt(strValue);
		break;
	case "m_strTriggerTarget":
		m_strTriggerTarget = ReadString(strValue);
		break;
	case "m_flBaseTime":
		m_flBaseTime = ReadFloat(strValue);
		break;
	case "m_eEnemy":
		m_eEnemy = ReadEntity(strValue);
		break;
	case "m_flAttackThink":
		m_flAttackThink = ReadFloat(strValue);
		break;
	case "m_iMState":
		m_iMState = ReadFloat(strValue);
		break;
	case "m_iOldMState":
		m_iOldMState = ReadFloat(strValue);
		break;
	case "m_vecLKPos":
		m_vecLKPos = ReadVector(strValue);
		break;
	case "m_flSeeTime":
		m_flSeeTime = ReadFloat(strValue);
		break;
	case "m_flAnimTime":
		m_flAnimTime = ReadFloat(strValue);
		break;
	case "m_flTrackingTime":
		m_flTrackingTime = ReadFloat(strValue);
		break;
	case "view_ofs":
		view_ofs = ReadVector(strValue);
		break;
	case "m_actIdle":
		m_actIdle = ReadFloat(strValue);
		break;
	case "m_bTurning":
		m_bTurning = ReadBool(strValue);
		break;
	case "m_flIdleNext":
		m_flIdleNext = ReadFloat(strValue);
		break;
	case "_m_flMeleeAttempts":
		_m_flMeleeAttempts = ReadFloat(strValue);
		break;
	case "_m_flMeleeDelay":
		_m_flMeleeDelay = ReadFloat(strValue);
		break;
	case "_m_flBurstCount":
		_m_flBurstCount = ReadFloat(strValue);
		break;
	case "_m_bShouldThrow":
		_m_bShouldThrow = ReadBool(strValue);
		break;
	case "_m_flReloadTracker":
		_m_flReloadTracker = ReadFloat(strValue);
		break;
	case "m_bWeaponDrawn":
		m_bWeaponDrawn = ReadBool(strValue);
		break;
	case "m_flEyeHeight":
		m_flEyeHeight = ReadFloat(strValue);
		break;
	case "m_sndSight":
		m_sndSight = ReadString(strValue);
		break;
	case "m_sndIdle":
		m_sndIdle = ReadString(strValue);
		break;
	case "m_flIdleMin":
		m_flIdleMin = ReadFloat(strValue);
		break;
	case "m_flIdleMax":
		m_flIdleMax = ReadFloat(strValue);
		break;
	case "m_sndFootstep":
		m_sndFootstep = ReadString(strValue);
		break;
	case "m_sndChatter":
		m_sndChatter = ReadString(strValue);
		break;
	case "m_sndChatterCombat":
		m_sndChatterCombat = ReadString(strValue);
		break;
	case "m_sndPain":
		m_sndPain = ReadString(strValue);
		break;
	case "m_sndMeleeAttack":
		m_sndMeleeAttack = ReadString(strValue);
		break;
	case "m_sndMeleeAttackHit":
		m_sndMeleeAttackHit = ReadString(strValue);
		break;
	case "m_sndMeleeAttackMiss":
		m_sndMeleeAttackMiss = ReadString(strValue);
		break;
	case "m_sndDeath":
		m_sndDeath = ReadString(strValue);
		break;
	case "m_sndThud":
		m_sndThud = ReadString(strValue);
		break;
	case "m_defSpecial1":
		m_defSpecial1 = ReadString(strValue);
		break;
	case "m_flSpecial1Range":
		m_flSpecial1Range = ReadFloat(strValue);
		break;
	case "m_defSpecial2":
		m_defSpecial2 = ReadString(strValue);
		break;
	case "m_flSpecial2Range":
		m_flSpecial2Range = ReadFloat(strValue);
		break;
	case "m_defRanged1":
		m_defRanged1 = ReadString(strValue);
		break;
	case "m_flRanged1Range":
		m_flRanged1Range = ReadFloat(strValue);
		break;
	case "m_defRanged2":
		m_defRanged2 = ReadString(strValue);
		break;
	case "m_flRanged2Range":
		m_flRanged2Range = ReadFloat(strValue);
		break;
	case "m_iNumProjectiles":
		m_iNumProjectiles = ReadInt(strValue);
		break;
	case "m_flProjectileDelay":
		m_flProjectileDelay = ReadFloat(strValue);
		break;
	case "m_flProjectileSpread":
		m_flProjectileSpread = ReadFloat(strValue);
		break;
	case "m_flAttackCone":
		m_flAttackCone = ReadFloat(strValue);
		break;
	case "m_flAttackAccuracy":
		m_flAttackAccuracy = ReadFloat(strValue);
		break;
	case "m_defMelee":
		m_defMelee = ReadString(strValue);
		break;
	case "m_flMeleeRange":
		m_flMeleeRange = ReadFloat(strValue);
		break;
	case "m_sndRangedAttack":
		m_sndRangedAttack = ReadString(strValue);
		break;
	case "m_flReloadCount":
		m_flReloadCount = ReadFloat(strValue);
		break;
	case "m_flReloadDelay":
		m_flReloadDelay = ReadFloat(strValue);
		break;
	case "m_sndReload":
		m_sndReload = ReadString(strValue);
		break;
	case "m_flReserveAmmo":
		m_flReserveAmmo = ReadFloat(strValue);
		break;
	case "m_sndRangedAttack2":
		m_sndRangedAttack2 = ReadString(strValue);
		break;
	case "m_bWeaponStartsDrawn":
		m_bWeaponStartsDrawn = ReadBool(strValue);
		break;
	case "m_strBodyOnDraw":
		m_strBodyOnDraw = ReadString(strValue);
		break;
	case "m_flWalkSpeed":
		m_flWalkSpeed = ReadFloat(strValue);
		break;
	case "m_flRunSpeed":
		m_flRunSpeed = ReadFloat(strValue);
		break;
	case "m_flLeapDamage":
		m_flLeapDamage = ReadFloat(strValue);
		break;
	case "m_bLeapAttacked":
		m_bLeapAttacked = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

int
NSMonster::AnimIdle(void)
{
	return GetAct("idle");
}

int
NSMonster::AnimWalk(void)
{
	return GetAct("walk");
}

int
NSMonster::AnimRun(void)
{
	float runAnim = GetAct("run");
	return (runAnim == -1) ? AnimWalk() : runAnim;
}

void
NSMonster::AnimPlay(float seq)
{
	SetFrame(seq);
	m_flAnimTime = time + frameduration(modelindex, seq);
}

void
NSMonster::AnimReset(void)
{
	frame1time = 0.0f;
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
	vector vecDir = vectorToAngles(GetOrigin() - g_dmg_vecLocation);
	SetState(MONSTER_DEAD);
	MakeInvulnerable();

	string breakModel = GetPropData(PROPINFO_BREAKMODEL);
	BreakModel_Spawn(absmin, absmax, vecDir, g_dmg_iDamage * 2.5f, vlen(size) / 10, breakModel);
	Disappear();
}

void
NSMonster::FallNoise(void)
{
}

void
NSMonster::IdleNoise(void)
{
	if (m_bGagged == true) {
		return;
	}
	if (m_flIdleNext > time) {
		return;
	}

	StartSoundDef(m_sndIdle, CHAN_VOICE, true);
	m_flIdleNext = time + random(m_flIdleMin, m_flIdleMax);
}

void
NSMonster::AlertNoise(void)
{
	if (m_bGagged == true) {
		return;
	}

	StartSoundDef(m_sndSight, CHAN_VOICE, true);
}

bool
NSMonster::IsFriend(int al)
{
	/* neutrals are always friendly */
	if (m_iAlliance == MAL_NEUTRAL)
		return (true);
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
	return m_flMeleeRange;
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

	/* iterate over all living things. */
	for (entity w = world; (w = nextent(w));) {
		if (w.takedamage == DAMAGE_NO)
			continue;

		if (w.classname != classname)
			continue;

		if (!IsFriend(w.m_iAlliance))
			continue;

		/* only bother if within 512 unit radius */
		if (vlen(origin - w.origin) > 512)
			continue;

		//NSMonsterLog("Alert! %s get %s", w.classname, m_eEnemy.classname);
		NSMonster f = (NSMonster)w;

		/* we shouldn't override this when they already got a target */
		if (f.m_eEnemy != __NULL__)
			continue;

		f.m_eEnemy = m_eEnemy;
		f._Alerted();
	}
}

/* returns TRUE if 'enemy' should be considered a valid target for killing */
bool
NSMonster::IsValidEnemy(entity enny)
{
	if (enny == __NULL__)
		return false;
	/* dead enny should not be considered valid */
	if ((enny.solid == SOLID_CORPSE) || (enny.health <= 0))
		return false;
	/* such monster should ignore players */
	if ((enny.flags & FL_CLIENT) && HasSpawnFlags(MSF_IGNOREPLAYER))
		return false;
	/* monsters ignore enny who uses notarget cheat, useful for development */
	if (enny.flags & FL_NOTARGET)
		return false;
	/* if they're our friend... ignore */
	if (IsFriend(enny.m_iAlliance))
		return false;
	/* prevent from shooting non-sentient stuff */
	if (!(enny.flags & (FL_MONSTER | FL_CLIENT)))
		return false;

	return true;
}

bool
NSMonster::IsOnRoute(void)
{
	return (m_iNodes || m_pathTarget) && (GetState() == MONSTER_IDLE || GetState() == MONSTER_ALERT) ? true : false;
}

static bool
NSMonster_TraceAgainsTarget(NSMonster monster, NSEntity target)
{
	traceline(monster.GetEyePos(), target.GetOrigin(), MOVE_NORMAL, monster);

	/* we have line of sight with the player */
	if (trace_fraction == 1.0f || trace_ent == target) {
		return true;
	}

	return false;
}

void
NSMonster::SeeThink(void)
{
	if (HasSpawnFlags(MSF_PRISONER) == true) {
		return;
	}

	if (m_eLookAt) {
		vector vecDelta;
		vecDelta = normalize( (m_eLookAt.origin + m_eLookAt.view_ofs) - GetEyePos() );
		m_flHeadYaw = (vecDelta * anglesToRight(angles)) * -60;
		//print(sprintf("head yaw: %f %v\n", m_flHeadYaw, vecDelta));

		/* this will make the actor 'aim" at the target */
		{
			vector tmp = vectorToAngles(anglesToForward(v_angle));
			subblendfrac = tmp[0] / 90;
			bonecontrol1 = lerp(bonecontrol1, m_flHeadYaw, frametime * 15.0f);	/* head turning */
		}	
	}

	if (m_flAttackThink < time)
	if (m_eEnemy) {
		/* check if we should invalidate current enemy */
		if (IsValidEnemy(m_eEnemy)) {
			/* only update 1/4th of a second */
			if (m_flSeeTime > time)
				return;

			m_flSeeTime = time + 0.25f;
			m_eLookAt = m_eEnemy;

			/* see if we can trace our target, if yes, update our timestamp */
			if (NSMonster_TraceAgainsTarget(this, (NSEntity) m_eEnemy) == true) {
				m_flTrackingTime = time;
			}

			/* if we haven't gotten a trace in 5 seconds, give up. */
			if ((m_flTrackingTime + 5.0) > time)
				return;
		}

		/* enemy is not valid anymore, reset it, clear route and search for new enemy */
		RouteClear();

		RouteToPosition(m_eEnemy.origin + (anglesToForward(angles) * -64));
		m_flSequenceSpeed = GetWalkSpeed();

		SetState(MONSTER_ALERT);
		m_eEnemy = __NULL__;
		m_eLookAt = __NULL__;
		m_flSeeTime = 0;
	}

	if (m_flSeeTime > time)
		return;

	m_flSeeTime = time + 0.25f;

	/* a horde type monster always knows where the nearest player is */
	if (m_iFlags & MSF_HORDE) {
		m_eEnemy = NSMonster_FindClosestPlayer(this);

		if (m_eEnemy) {
			RouteToPosition(m_eEnemy.origin);
		}

		return;
	}

	/* iterate through all players, monsters. */
	for (entity w = world; (w = nextent(w));) {
		if (w.takedamage == DAMAGE_NO)
			continue;

		/* check if 'w' could be a valid enemy */
		if (IsValidEnemy(w) == false)
			continue;

		/* first, is the potential enemy in our field of view? */
		vector v = normalize(w.origin - GetEyePos());
		float flDot = v * anglesToForward(angles);

		if (flDot < SeeFOV()/180)
			continue;

		/* we have line of sight with the player */
		if (NSMonster_TraceAgainsTarget(this, (NSEntity)w) == true) {
			if (m_eEnemy != w) {
				m_eEnemy = w;
				m_flTrackingTime = time;
				_Alerted();
				AlertNearby();
			}
			return;
		}
	}
}

float
NSMonster::GetWalkSpeed(void)
{
	return m_flWalkSpeed;
}

float
NSMonster::GetChaseSpeed(void)
{
	return m_flRunSpeed;
}

float
NSMonster::GetRunSpeed(void)
{
	return m_flRunSpeed;
}

float
NSMonster::GetYawSpeed(void)
{
	if (GetState() == MONSTER_AIMING)
		return 128;

	return 90;
}

void
NSMonster::_LerpTurnToYaw(vector turnYaw)
{
	vector oldAngle = angles;
	vector angleDelta;
	float oldYaw = angles[1];
	float yawDiff = 0.0f;
	yaw_speed = GetYawSpeed() * (frametime * 5);
	ideal_yaw = turnYaw[1];
	changeyaw();
	angleDelta = angleDifference(oldAngle, angles);
	
	input_angles[1] = v_angle[1] = angles[1];

	///printf("yawDiff: %f\n", angleDelta[1]);

	if (fabs(angleDelta[1]) > 1.0f) {
		/* wasn't turning before */
		if (m_bTurning == false) {

			if (yawDiff < 0) {
				AnimPlay(GetAct("turnRight"));
			} else {
				AnimPlay(GetAct("turnLeft"));
			}
		}

		m_bTurning = true;
	}
}

void
NSMonster::_LerpTurnToPos(vector turnPos)
{
	vector vecWishAngle = vectorToAngles(turnPos - origin);
	_LerpTurnToYaw(vecWishAngle);
}


void
NSMonster::_LerpTurnToEnemy(void)
{
	vector enemyEyePos;
	vector dirAim;

	if (!m_eEnemy)
		return;

	/* only continue if we're in one of the three states. */
	if (GetState() != MONSTER_AIMING)
		if (GetState() != MONSTER_CHASING)
			if (GetState() != MONSTER_FOLLOWING)
				return;

	_LerpTurnToPos(m_eEnemy.origin);

	enemyEyePos = (m_eEnemy.origin + m_eEnemy.view_ofs);

	dirAim = vectorToAngles(enemyEyePos - GetEyePos());
	v_angle[0] = dirAim[0];
}

void
NSMonster::AttackThink(void)
{
	if (InSequence()) {
		return;
	}

	if (m_flAttackThink > time) {
		return;
	}

	if (!m_eEnemy) {
		return;
	}

	/* do we have a clear shot? */
	other = world;
	traceline(GetEyePos(), m_eEnemy.origin, MOVE_OTHERONLY, this);

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
	if (m_flAttackThink > time) {
		return;
	}

	if (GetState() == MONSTER_AIMING) {
		int m;

		_LerpTurnToEnemy();

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
#if 0
	float actMelee1 = GetAct("meleeAttack1");
	float actMelee2 = GetAct("meleeAttack2");

	if (!m_defMelee)
		return (false);

	_m_flMeleeDelay = Skill_GetDefValue(EntityDef_GetKeyValue(m_defMelee, "delay"));
	_m_flMeleeAttempts = Skill_GetDefValue(EntityDef_GetKeyValue(m_defMelee, "attempts"));

	//print(sprintf("Melee attack %S with delay %f and %d attempts\n", m_defMelee, _m_flMeleeDelay, _m_flMeleeAttempts));

	static void
	AttackMelee_AttackFlail(void)
	{
		float meleeDmg = Skill_GetDefValue(EntityDef_GetKeyValue(m_defMelee, "damage"));
		float meleeWait = Skill_GetDefValue(EntityDef_GetKeyValue(m_defMelee, "wait"));
		traceline(origin, m_eEnemy.origin, FALSE, this);
	
		if (trace_fraction >= 1.0 || trace_ent.takedamage == DAMAGE_NO) {
			StartSoundDef(m_sndMeleeAttackMiss, CHAN_WEAPON, true);
			return (false);
		}

		Damage_Apply(trace_ent, this, meleeDmg, 0, 0);
		StartSoundDef(m_sndMeleeAttackHit, CHAN_WEAPON, true);

		_m_flMeleeAttempts--;

		if (_m_flMeleeAttempts > 0)
			ScheduleThink(AttackMelee_AttackFlail, _m_flMeleeDelay + meleeWait);
	}

	AnimReset();

	if (random() < 0.5 || actMelee2 == -1)
		AnimPlay(actMelee1);
	else
		AnimPlay(actMelee2);

	m_flAttackThink = m_flAnimTime;
	StartSoundDef(m_sndMeleeAttack, CHAN_WEAPON, true);

	/* functional */
	ScheduleThink(AttackMelee_AttackFlail, _m_flMeleeDelay);
#endif 
	return (true);
}

int
NSMonster::AttackRanged(void)
{
	static void AttackRanged_Throw(void)
	{
		for (int i = 0; i < m_iNumProjectiles; i++)
			NSAttack_SpawnDef(m_defSpecial1, this);
	}
	static void AttackRanged_RangedSpecial(void)
	{
		NSMonsterLog("AttackRanged_RangedSpecial: %S", m_defRanged2);
		NSAttack_SpawnDef(m_defRanged2, this);
	}

	float distToEnemy = distance(m_eEnemy.origin, GetOrigin());

	bool inSpecial1Range = (distToEnemy < m_flSpecial1Range && m_flSpecial1Range != -1.0) ? true : false;
	bool inSpecial2Range = (distToEnemy < m_flSpecial2Range && m_flSpecial2Range != -1.0) ? true : false;
	bool inRanged1Range = (distToEnemy < m_flRanged1Range && m_flRanged1Range != -1.0) ? true : false;
	bool inRanged2Range = (distToEnemy < m_flRanged2Range && m_flRanged2Range != -1.0) ? true : false;
	bool throwAnyway = false;

	traceline(GetEyePos(), m_eEnemy.origin, MOVE_NORMAL, this);

	if (_m_bShouldThrow == false && inSpecial1Range && m_flReloadCount)
		if (_m_flReloadTracker > m_flReloadCount) {
			throwAnyway = true;
			_m_bShouldThrow = true;
			NSMonsterLog("throwAnyway: true!");
		}

	/* special always first if possible */
	if (throwAnyway == false && inRanged1Range && trace_ent == m_eEnemy) {
		float rangedDmg = GetSubDefFloat(m_defRanged1, "damage");
		float rangedDly = GetSubDefFloat(m_defRanged1, "delay");
		float rangedMin = GetSubDefFloat(m_defRanged1, "delay_min");
		float rangedMax = GetSubDefFloat(m_defRanged1, "delay_max");
		float burstCount = GetSubDefFloat(m_defRanged1, "burst");
		float burstDelay = GetSubDefFloat(m_defRanged1, "burst_delay");
		float actRanged = GetAct("rangeAttack1");
		float burstTime = 0.0f;

		if (rangedDly <= 0.0) {
			rangedDly = random(rangedMin, rangedMax);
		}

		/* can't shoot anything ranged anymore, need to reload. */
		if (m_flReloadCount)
		if (_m_flReloadTracker > m_flReloadCount) {
			float startAmmo = 0;
			float actReload = GetAct("reload");

			/* out of ammo, cannot reload */
			if (m_flReserveAmmo == 0) {
				//NSMonsterLog("Out of ammo!");
				return 0;
			}

			/* do we not have unlimited ammo? */
			if (m_flReserveAmmo != -1) {
				m_flReserveAmmo -= m_flReloadCount;
				NSMonsterLog("Reserve ammo: %d", m_flReserveAmmo);

				/* oh no, we're below 0 in terms of ammo. */
				if (m_flReserveAmmo < 0) {
					startAmmo = -m_flReserveAmmo;
					m_flReserveAmmo = 0; /* we're fully emptied now */
				}
			}

			NSMonsterLog("Starting at %d bullets", startAmmo);
			_m_flReloadTracker = startAmmo;
			AnimPlay(actReload);
			StartSoundDef(m_sndReload, CHAN_WEAPON, true);
			_m_bShouldThrow = false;

			if (m_flReloadDelay) {
				m_flAttackThink = time + m_flReloadDelay;
				NSMonsterLog("Reloading, delay %f seconds", m_flReloadDelay);
			} else {
				float actDuration = frameduration(modelindex, actReload);
				m_flAttackThink = time + actDuration;
				NSMonsterLog("Reloading, act delays it by %f seconds", actDuration);
			}

			return 1;
		}

		AnimReset();
		AnimPlay(actRanged);

		/* if we have no spawnclass, it must be a hitscan weapon */
		if (STRING_SET(m_defRanged1)) {
			if (EntityDef_HasSpawnClass(m_defRanged1)) {
				NSAttack_SpawnDef(m_defRanged1, this);
				NSMonsterLog("Firing ranged def %S", m_defRanged1);
			}
		}

		StartSoundDef(m_sndRangedAttack, CHAN_WEAPON, true);
		_m_flBurstCount++;
		_m_flReloadTracker++;

		if (burstCount)
		if (_m_flBurstCount >= burstCount) {
			_m_flBurstCount = 0;
			burstTime = burstDelay;
		}

		if (rangedDly) {
			m_flAttackThink = time + rangedDly + burstTime;
			NSMonsterLog("Primary ranged attack, delay %f seconds (burst %d)", rangedDly, burstTime);
		} else {
			float actAttackTime = frameduration(modelindex, actRanged);
			m_flAttackThink = time + actAttackTime + burstTime;
			NSMonsterLog("Primary ranged attack, act delays it by %f seconds (burst %f)", actAttackTime, burstTime);
		}

		return 1;
	} else if (throwAnyway == false && inRanged2Range && trace_ent == m_eEnemy) {
		float actRangedSpecial = GetAct("rangeAttack2");
		AnimReset();
		AnimPlay(actRangedSpecial);
		ScheduleThink(AttackRanged_RangedSpecial, 0.0f);
		m_flAttackThink = time + frameduration(modelindex, actRangedSpecial);
		return 1;
	} else if (inSpecial1Range) {
		AnimReset();
		AnimPlay(GetAct("specialAttack1"));
		ScheduleThink(AttackRanged_Throw, m_flProjectileDelay);

		if (_m_bShouldThrow)
			m_flAttackThink = time + 1.0f;
		else
			m_flAttackThink = time + 2.5f;

		return 1;
	} else if (inSpecial2Range) {
		AnimReset();
		AnimPlay(GetAct("specialAttack2"));
		ScheduleThink(AttackRanged_Throw, m_flProjectileDelay);

		if (_m_bShouldThrow)
			m_flAttackThink = time + 1.0f;
		else
			m_flAttackThink = time + 2.5f;

		return 1;
	}

	m_flAttackThink = time + 0.5f;
	return (0);
}

void
NSMonster::AttackDraw(void)
{
	float actDraw = GetAct("arm");
	AnimPlay(actDraw);
	m_flAttackThink = time + frameduration(modelindex, actDraw);

	if (STRING_SET(m_strBodyOnDraw)) {
		int t = tokenizebyseparator(m_strBodyOnDraw, ":");

		if (t == 1) {
			SetBodyInGroup(0, stoi(argv(0)));
		} else if (t == 2) {
			SetBodyInGroup(stoi(argv(0)), stoi(argv(1)));
		}
	}
}

void
NSMonster::AttackHolster(void)
{
	float actHolster = GetAct("disarm");
	AnimPlay(actHolster);
	m_flAttackThink = time + frameduration(modelindex, actHolster);
}

void
NSMonster::FreeState(void)
{
	string to_trigger;
	m_flSequenceEnd = 0;
	m_iSequenceState = SEQUENCESTATE_NONE;
	m_iSequenceFlags = 0;

	/* scripted_sequence killtarget:
	   We want to call this first. you may wonder why.
	   Because a monster may call a scripted_sequence here
	   which THEN sets its killtarget to be monster that triggers
	   the scripted_sequence.
	   If that happens, the monster will then killtarget itself right after. */ 
	if (STRING_SET(m_strSequenceKillTarget)) {
		NSEntity findKT = (NSEntity)find(world, ::targetname, m_strSequenceKillTarget);

		if (findKT) {
			NSMonsterLog("Killing %S", m_strSequenceKillTarget);
			findKT.Destroy();
			findKT.targetname = "";
		} else {
			EntError("Unable to find %S for removal", m_strSequenceKillTarget);
		}

		m_strSequenceKillTarget = __NULL__;
	}

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
	if (STRING_SET(to_trigger)) {
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

	NSMonsterLog("Sequence over (hidden: %i, triggering: %S)", m_iSequenceRemove, to_trigger);
}

void
NSMonster::FreeStateMoved(void)
{
	vector new_origin;
	new_origin = gettaginfo(this, 1);
	NSMonsterLog("Moved to %v", new_origin);
	SetOrigin(new_origin);
	DropToFloor();
	FreeState();
}

void
NSMonster::FreeStateDead(void)
{
	vector new_origin;

	new_origin = gettaginfo(this, 1);
	NSMonsterLog("Moved to %v", new_origin);
	SetOrigin(new_origin);
	DropToFloor();

	RemoveFlags(FL_MONSTER);
	SetSolid(SOLID_CORPSE);
	SetState(MONSTER_DEAD);
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
		NSMonsterLog("%s overriding anim for %f seconds (modelindex %d, frame %d)", \
			this.targetname, duration, modelindex, m_flSequenceEnd);
	} else {
		/* we still need to trigger targets */
		think = (m_iSequenceFlags & SSFL_NOSCRIPTMOVE) ? FreeState : FreeStateMoved;
		nextthink = time;
		NSMonsterLog("%s has no anim, finished sequence", \
			this.targetname);
	}
}

void
NSMonster::WalkRoute(void)
{
	vector wishAngle = input_angles;

	/* we're busy shooting at something, don't walk */
	if (GetState() == MONSTER_AIMING && m_eEnemy) {
		wishAngle = vectorToAngles(m_eEnemy.origin - origin);
		wishAngle[0] = wishAngle[2] = 0;
	} else if (IsOnRoute()) {
		wishAngle = GetRouteDirection();
		wishAngle[0] = wishAngle[2] = 0;
		input_movevalues = GetRouteMovevalues() * m_flSequenceSpeed;

		/* is something in our way? */
		tracebox(origin, [-16, -16, -16], [16, 16, 16], origin + anglesToForward(wishAngle) * 256, MOVE_NORMAL, this);

		/* indeed it is */
		if (trace_fraction < 1.0f) {
			vector testOrg = origin + (anglesToRight(wishAngle) * 32) + anglesToForward(wishAngle) * 128;
			testOrg[2] += mins[2] + 18.0f; /* test at feet level */

			traceline(origin, testOrg, MOVE_NORMAL, this);

			/* is space free to the right? */
			if (trace_fraction == 1.0) {
				input_movevalues[1] = m_flSequenceSpeed * 0.25f;
			} else {

				testOrg = origin - (anglesToRight(wishAngle) * 32) + anglesToForward(wishAngle) * 128;
				testOrg[2] += mins[2] + 18.0f; /* test at feet level */

				traceline(origin, testOrg, MOVE_NORMAL, this);

				/* is space free to the left? */
				if (trace_fraction == 1.0)
					input_movevalues[1] = -m_flSequenceSpeed * 0.25f;
			}
		}
	} else if (GetState() == MONSTER_CHASING && m_eEnemy) {
		/* we've got 'em in our sights, just need to walk closer */
		wishAngle = vectorToAngles(m_eEnemy.origin - origin);
		wishAngle[0] = wishAngle[2] = 0;
		input_movevalues = [GetChaseSpeed(), 0, 0];
	} else
		return;

	/* yaw interpolation */
	_LerpTurnToYaw(wishAngle);
}

void
NSMonster::AnimationUpdate(void)
{
	int fr = 0;
	int act = 0;

	if (GetState() == MONSTER_DEAD)
		return;

	if (GetState() == MONSTER_AIMING)
		return;

	if (m_bTurning)
		return;

	float spvel = vlen(velocity);
	float midspeed = GetWalkSpeed() + ((GetRunSpeed() -  GetWalkSpeed()) * 0.5f);

	if (spvel < 5) {
		if (m_actIdle == -1)
			m_actIdle = AnimIdle();

		fr = m_actIdle;

		if (m_iMoveState != MOVESTATE_IDLE)
			m_flAnimTime = 0.0f;

		if (fr == -1)
			act = GetAct("idle");


		m_iMoveState = MOVESTATE_IDLE;
	} else if (spvel < midspeed) {
		fr = AnimWalk();

		if (m_iMoveState != MOVESTATE_WALK)
				m_flAnimTime = 0.0f;

		if (fr == -1)
			act = GetAct("walk");
		

		m_iMoveState = MOVESTATE_WALK;
	} else {
		fr = AnimRun();

		if (m_iMoveState != MOVESTATE_RUN)
			m_flAnimTime = 0.0f;

		if (fr == -1)
			act = GetAct("run");

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
NSMonster::StateChanged(monsterState_t oldState, monsterState_t newState)
{
	switch (newState) {
	case MONSTER_AIMING:
		/* we're coming from an alerted/raised state to pointing a gun. */
		if (oldState == MONSTER_ALERT) {
			/* only draw if it wasn't already drawn */
			if (m_bWeaponDrawn == false) {
				AttackDraw();
				m_bWeaponDrawn = true;
			}
		}
		break;
	case MONSTER_ALERT:
		if (oldState == MONSTER_AIMING) {
			/* only holster if it wasn't in the initial state either */
			if (m_bWeaponStartsDrawn == false) {
				AttackHolster();
				m_bWeaponDrawn = false;
			}
		}
		break;
	}
}

void
NSMonster::SetState(monsterState_t newState)
{
	if (newState == m_iMState)
		return;

	m_iOldMState = m_iMState;
	m_iMState = newState;
	StateChanged(m_iOldMState, m_iMState);
}

monsterState_t
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
	IdleNoise();
	SeeThink();
	AttackThink();
}

void
NSMonster::Physics(void)
{
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;
	input_timelength = frametime;
	input_angles = angles;
	m_bTurning = false;

	if (autocvar_ai_enable == false) {
		return;
	}

	/* HACK!!! */
	if (!IsAlive()) {
		return;
	}

	/* editors like Hammer like putting 'sequence' into spawndata
	   of monsters. so only ever force the animation when flagged as dead */
	if (_m_bStartDead && m_flForceSequence) {
		if (m_iSequenceState != SEQUENCESTATE_IDLE) {
			SetFrame(m_flForceSequence);
		}
		m_flAnimTime = time + 999.0f;
		frame = m_flForceSequence;
		m_iSequenceState = SEQUENCESTATE_IDLE;
	}

	/* unset the leap attack */
	if (m_bLeapAttacked == true && HasFlags(FL_ONGROUND) == true) {
		m_bLeapAttacked = false;
	}

	/* when stuck in a sequence, forget enemies, combat stance */
	if (GetSequenceState() != SEQUENCESTATE_NONE) {
		m_eEnemy = __NULL__;
		SetState(MONSTER_IDLE);
	}

	/* we're ending a scripted sequence, so play its animation */
	if (GetSequenceState() == SEQUENCESTATE_ENDING) {
		_LerpTurnToYaw(m_vecSequenceAngle);

		if (m_bTurning == false)
			SetFrame(m_flSequenceEnd);
	} else {
		/* if still alive... */
		if (IsAlive()) {
			/* only run AI functions when not in a scripted sequence */
			if (InSequence() == false) {
				RunAI();
			}

			_LerpTurnToEnemy();
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

		/* don't move while turning. */
		if (m_bTurning == true) {
			input_movevalues = [0,0,0];
		}

		/* complete the move */
		Physics_Run();
	}

	if (!(GetFlags() & FL_ONGROUND) && velocity[2] < -415) {
		if (!(m_iFlags & MSF_FALLING)) {
			FallNoise();
		}

		m_iFlags |= MSF_FALLING;
	} else {
		m_iFlags &= ~MSF_FALLING;
	}

	processmodelevents(modelindex, frame, m_flBaseTime,
		frame1time, HandleAnimEvent);

	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
}

void
NSMonster::Touch(entity eToucher)
{
	/* leap test, are we no longer on the ground? */
	if (m_flLeapDamage && m_bLeapAttacked == false)
	if (HasFlags(FL_ONGROUND) == false) {
		if (eToucher.takedamage != DAMAGE_NO) {
			NSSurfacePropEntity toucher = (NSSurfacePropEntity)eToucher;
			NSDict damageDecl = spawn(NSDict);
			damageDecl.AddKey("damage", ftos(m_flLeapDamage));
			toucher.Damage(this, owner, damageDecl, 1.0, vectorNormalize(angles), trace_endpos);
			remove(damageDecl);
			m_bLeapAttacked = true;
		}
	}

	if (movetype != MOVETYPE_WALK)
		return;

	if (autocvar(pm_pushMonsters, 0))
	if (eToucher.movetype == MOVETYPE_WALK) {
		if (eToucher.absmin[2] < origin[2]) {
			float bestYaw = 0.0f;
			float best_fraction = 0.0f;
			vector bestPos = g_vec_null;

			for (float yaw = angles[1]; yaw < (angles[1] + 360.0f); yaw += 1.0f) {
				tracebox(origin, mins, maxs, origin + (anglesToForward([0, yaw, 0]) * 128.0f), FALSE, this);

				if (trace_startsolid) {
					bestYaw = random(0, 360);
					break;
				}

				if (trace_fraction > best_fraction) {
					best_fraction = trace_fraction;
					bestYaw = yaw;
					bestPos = trace_endpos;
				}
			}

			RouteToPosition(bestPos);
			m_flSequenceSpeed = GetWalkSpeed();
		}
	}
}

void
NSMonster::HasBeenHit(void)
{
	/* to be filled in by the sub-class */
}

void
NSMonster::Pain(entity inflictor, entity attacker, int damage, vector dir, int location)
{
	float actSmallFlinch = GetAct("smallFlinch");
	float actBigFlinch = GetAct("bigFlinch");
	float actTwitch = GetAct("twitch");
	float actPain = -1;
	float baseHealth = GetSpawnFloat("health");

	/* dead things tell nuthin */
	if (IsAlive() == false) {
		return;
	}

	if (GetHealth() <= (baseHealth / 2)) {
		if (IsFriend(attacker.m_iAlliance) == true) {
			m_iAlliance = MAL_ROGUE;
		}
	}

	if (IsFriend(attacker.m_iAlliance) == true) {
		return;
	}

	/* if don't have an enemy, set one; else make it random */
	if (!m_eEnemy || (random() < 0.5)) {
		m_eEnemy = attacker;
	}

	/* an alert monster will take a while to calm back down */
	if (GetState() != MONSTER_ALERT) {
		if (GetState() != MONSTER_FOLLOWING) {
			if (GetState() != MONSTER_CHASING) {
				SetState(MONSTER_ALERT);
			}
		}
	}

	/* alert all nearby friendlies */
	AlertNearby();

	switch (location) {
	case BODY_HEAD:
		actPain = GetAct("flinchHead");
		break;
	case BODY_CHEST:
		actPain = GetAct("flinchChest");
		break;
	case BODY_STOMACH:
		actPain = GetAct("flinchStomach");
		break;
	case BODY_ARMLEFT:
		actPain = GetAct("flinchLeftArm");
		break;
	case BODY_ARMRIGHT:
		actPain = GetAct("flinchRightArm");
		break;
	case BODY_LEGLEFT:
		actPain = GetAct("flinchLeftLeg");
		break;
	case BODY_LEGRIGHT:
		actPain = GetAct("flinchRightLeg");
		break;
	}

	/* fallback in case we do not have specialized flinches */
	if (actPain == -1) {
		/* for big damage pain anim, we need to take at least 1/3rd of health */
		if (actBigFlinch >= 0 && damage > (baseHealth / 3))
			actPain = actBigFlinch;
		else if (actSmallFlinch >= 0)
			actPain = actSmallFlinch;
	}

	AnimPlay(actPain);
	StartSoundDef(m_sndPain, CHAN_VOICE, true);
	HasBeenHit();
}

void
NSMonster::HasBeenKilled(void)
{
	/* to be filled in by the sub-class */
}

void
NSMonster::HasBeenGibbed(void)
{
	/* to be filled in by the sub-class */
}

void
NSMonster::HasBeenAlerted(void)
{
	/* to be filled in by the sub-class */
}

void
NSMonster::_Alerted(void)
{
	HasBeenAlerted();
}

void
NSMonster::Death(entity inflictor, entity attacker, int damage, vector dir, int location)
{
	static void Death_Thud(void)
	{
		StartSoundDef(m_sndThud, CHAN_BODY, true);
	}

	float actViolent = GetAct("dieViolent");
	float actForward = GetAct("dieForward");
	float actBackward = GetAct("dieBackward");
	float actSimple = GetAct("dieSimple");
	float actBackshot = GetAct("dieBackshot");

	float actDeath = -1;

	/* we were already dead before, so gib */
	if (GetState() == MONSTER_DEAD) {
		HasBeenGibbed();
		Gib();
		return;
	}

	m_iFlags = 0x0;

	/* if we make more than 50 damage, gib immediately */
	if (GetHealth() < -50) {
		HasBeenGibbed();
		Gib();
		return;
	}

	switch (g_dmg_iHitBody) {
	case BODY_HEAD:
		actDeath = GetAct("dieHeadshot");
		break;
	case BODY_CHEST:
		actDeath = GetAct("dieChestshot");
		break;
	case BODY_STOMACH:
		actDeath = GetAct("dieGutshot");
		break;
	}

	if (actDeath == -1) {
		if (actViolent >= 0 && GetHealth() < -15) /* lots of damage */
			AnimPlay(actViolent);
		else if (actBackshot >= 0 && IsFacingPosition(g_dmg_vecLocation) == false)
			AnimPlay(actBackshot);
		else if (actForward >= 0 && IsFacingPosition(g_dmg_vecLocation) == false)
			AnimPlay(actForward);
		else if (actBackward >= 0 && IsFacingPosition(g_dmg_vecLocation) == true)
			AnimPlay(actBackward);
		else
			AnimPlay(actSimple);
	} else {
		AnimPlay(actDeath);
	}

	StartSoundDef(m_sndDeath, CHAN_VOICE, true);
	HasBeenKilled();

	/* make sure we're not causing any more obituaries */
	RemoveFlags(FL_MONSTER);

	/* set the monster up for getting gibbed */
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_CORPSE);
	SetHealth(50 + GetHealth());
	SetState(MONSTER_DEAD);

	/* monsters trigger their targets when dead */
	if (GetTriggerCondition() == MTRIG_DEATH) {
		TriggerTargets();
	}

	/* play thud sound */
	ScheduleThink(Death_Thud, frameduration(modelindex, frame) * 0.5f);
}

#if 0
void
NSMonster::Hide(void)
{
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	customphysics = __NULL__;
}
#endif

void
NSMonster::Spawned(void)
{
	if (!HasSpawnFlags(MSF_MULTIPLAYER)) {
		if (g_grMode.MonstersSpawn() == FALSE) {
			ReleaseThink();
			Destroy();
			return;
		}
	}

	super::Spawned();

	/* necessary so we can attribute deaths properly. */
	if (!owner) {
		owner = this;
	}
}

void
NSMonster::Respawn(void)
{
	/* we need to delay the DropToFloor() by at least a frame.
	   otherwise they may just fall through an entity (func_wall, func_train etc.)
	   that came after this entity in the lump. */
	static void AdjustSpawnPos(void) {
		RestoreAngles();
		m_vecSequenceAngle = GetAngles();
		SetOrigin(GetSpawnVector("origin"));
		DropToFloor();
		SetOriginUnstick(origin);
	}

	super::Respawn();

	RestoreAngles();
	v_angle = fixAngle(GetAngles());
	flags = FL_MONSTER;
	MakeVulnerable();
	EnableAimAssist();
	SetState(MONSTER_IDLE);
	SetHealth(GetSpawnFloat("health"));
	m_eEnemy = __NULL__;
	m_iFlags = 0x0;
	EnableBleeding();
	customphysics = Physics;
	SetSolid(SOLID_SLIDEBOX);
	SetMovetype(MOVETYPE_WALK);
	SetSize(GetSpawnVector("mins"), GetSpawnVector("maxs"));
	SetEyePos([0, 0, m_flEyeHeight]);
	SetSkin(m_flSkin);

	if (CreatedByMap() == true) {
		ScheduleThink(AdjustSpawnPos, 0.0f);
	}

	if (HasSpawnFlags(MSF_MONSTERCLIP)) {
		hitcontentsmaski = CONTENTBITS_BOXSOLID | CONTENTBIT_MONSTERCLIP;
	} else {
		hitcontentsmaski = CONTENTBITS_BOXSOLID;
	}

	if (m_bWeaponStartsDrawn) {
		m_bWeaponDrawn = true;
	} else {
		m_bWeaponDrawn = false;
	}

	/* start dead (corpse) */
	if (_m_bStartDead) {
		RemoveFlags(FL_MONSTER);
		SetMovetype(MOVETYPE_NONE);
		SetSolid(SOLID_CORPSE);
		SetHealth(GetSpawnFloat("health"));
		SetState(MONSTER_DEAD);
		SetFrame(_m_flFrame);
	}

	if (HasSpawnFlags(MSF_GAG)) {
		m_bGagged = true;
	} else {
		m_bGagged = false;
	}

	/* automatically start */
	if (STRING_SET(targetname)) {
		if (HasTriggerTarget() == true) {
			ScheduleThink(_ChaseAfterSpawn, 0.0f);
		}
	}
}

void
NSMonster::Input( entity entityActivator, string inputName, string dataField )
{
	switch (inputName) {
	case "Sleep":
		customphysics = __NULL__;
		ReleaseThink();
		break;
	case "Wake":
		customphysics = Physics;
		break;
	case "StartScripting":
		m_iSequenceState = SEQUENCESTATE_IDLE;
		break;
	case "GagEnable":
		m_bGagged = true;
		break;
	case "GagDisable":
		m_bGagged = false;
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
NSMonster::Trigger(entity act, triggermode_t state)
{
	ChasePath(GetTriggerTarget());
	m_flSequenceSpeed = m_flWalkSpeed;
}

void
NSMonster::_ChaseAfterSpawn(void)
{
	Trigger(this, TRIG_TOGGLE);
}

void
NSMonster::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	/* The legacy GoldSrc trigger condition system */
	case "TriggerCondition":
		m_iTriggerCondition = ReadInt(strValue);
		break;
	case "TriggerTarget":
		m_strTriggerTarget = ReadString(strValue);
		break;
	/* entityDef related */
	case "netname":	/* used for obituaries and debug info */
		netname = ReadString(strValue);
		break;
	case "eye_height":
		m_flEyeHeight = ReadFloat(strValue);
		break;
	case "snd_sight":
		m_sndSight = ReadString(strValue);
		break;
	case "snd_idle":
		m_sndIdle = ReadString(strValue);
		break;
	case "idle_min": /* used for idle sound timer */
		m_flIdleMin = ReadFloat(strValue);
		break;
	case "idle_max": /* ditto */
		m_flIdleMax = ReadFloat(strValue);
		break;
	case "snd_footstep":
		m_sndFootstep = ReadString(strValue);
		break;
	case "snd_chatter":
		m_sndChatter = ReadString(strValue);
		break;
	case "snd_chatter_combat":
		m_sndChatterCombat = ReadString(strValue);
		break;
	case "snd_pain":
		m_sndPain = ReadString(strValue);
		break;
	case "snd_death":
		m_sndDeath = ReadString(strValue);
		break;
	case "snd_thud":
		m_sndThud = ReadString(strValue);
		break;
	case "def_melee":	/* melee attack information */
	case "def_attack_melee":
		m_defMelee = ReadString(strValue);
		break;
	case "attack_melee_range":
	case "melee_range":  /* Doom 3 compat */
		m_flMeleeRange = ReadFloat(strValue);
		break;
	case "snd_melee_attack":
		m_sndMeleeAttack = ReadString(strValue);
		break;
	case "snd_melee_attack_hit":
		m_sndMeleeAttackHit = ReadString(strValue);
		break;
	case "snd_melee_attack_miss":
		m_sndMeleeAttackMiss = ReadString(strValue);
		break;
	case "def_attack_ranged": /* primary ranged attack */
	case "def_attack_ranged_1":
		m_defRanged1 = ReadString(strValue);
		break;
	case "attack_ranged1_range":
	case "attack_ranged_range":
	case "ranged_range":
		m_flRanged1Range = ReadFloat(strValue);
		break;
	case "def_attack_ranged_2": /* special ranged attack */
		m_defRanged2 = ReadString(strValue);
		break;
	case "attack_ranged2_range":
	case "ranged2_range":
		m_flRanged2Range = ReadFloat(strValue);
		break;
	case "snd_ranged_attack":
		m_sndRangedAttack = ReadString(strValue);
		break;
	case "reload_count": /* how many ranged attacks until reload */
		m_flReloadCount = ReadFloat(strValue);
		break;
	case "reload_delay": /* time between reloads */
		m_flReloadDelay = ReadFloat(strValue);
		break;
	case "snd_reload":
		m_sndReload = ReadString(strValue);
		break;
	case "reserve_ammo":
		m_flReserveAmmo = ReadFloat(strValue);
		break;
	case "def_attack_special":
	case "def_attack_special_1":
		m_defSpecial1 = ReadString(strValue);
		break;
	case "attack_special1_range":
	case "attack_special_range":
	case "special1_range":
		m_flSpecial1Range = ReadFloat(strValue);
		break;
	case "def_attack_special_2": /* projectile */
		m_defSpecial2 = ReadString(strValue);
		break;
	case "attack_special2_range":
	case "special2_range":
		m_flSpecial2Range = ReadFloat(strValue);
		break;
	case "num_projectiles":
		m_iNumProjectiles = ReadInt(strValue);
		break;
	case "projectile_spread":
		m_flProjectileSpread = ReadFloat(strValue);
		break;
	case "projectile_delay":
		m_flProjectileDelay = ReadFloat(strValue);
		break;
	case "attack_cone":
		m_flAttackCone = ReadFloat(strValue);
		break;
	case "attack_accuracy": /* affects ranged accuracy */
		m_flAttackAccuracy = ReadFloat(strValue);
		break;
	case "weapon_drawn":
		m_bWeaponStartsDrawn = ReadBool(strValue);
		break;
	case "body_on_draw":
		m_strBodyOnDraw = ReadString(strValue);
		break;
	case "speed_walk":
		m_flWalkSpeed = ReadFloat(strValue);
		break;
	case "speed_run":
		m_flRunSpeed = ReadFloat(strValue);
		break;
	case "team":
		m_iAlliance = ReadInt(strValue);
		break;
	case "leap_damage":
		m_flLeapDamage = ReadFloat(strValue);
		break;
	/* simple tweaks */
	case "dead":
		_m_bStartDead = ReadBool(strValue);
		break;
	case "frame":
		_m_flFrame = ReadFloat(strValue);
		break;
	case "skin":
		m_flSkin = ReadFloat(strValue);
		break;
	case "sequence":
		m_flForceSequence = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
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
	EVALUATE_VECTOR(v_angle, 0, MONFL_CHANGED_ANGLES_X)
	EVALUATE_FIELD(modelindex, MONFL_CHANGED_MODELINDEX)
	EVALUATE_VECTOR(view_ofs, 2, MONFL_CHANGED_MODELINDEX)
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
	EVALUATE_FIELD(skin, MONFL_CHANGED_SKINHEALTH)
	EVALUATE_FIELD(health, MONFL_CHANGED_SKINHEALTH)
	EVALUATE_FIELD(effects, MONFL_CHANGED_EFFECTS)
	EVALUATE_FIELD(m_iBody, MONFL_CHANGED_BODY)
	EVALUATE_FIELD(scale, MONFL_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 0, MONFL_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 1, MONFL_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 2, MONFL_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, MONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, MONFL_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, MONFL_CHANGED_VELOCITY)
	EVALUATE_FIELD(m_iRenderMode, MONFL_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_iRenderFX, MONFL_CHANGED_RENDERMODE)
	EVALUATE_VECTOR(m_vecRenderColor, 0, MONFL_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, MONFL_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, MONFL_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flRenderAmt, MONFL_CHANGED_RENDERAMT)
	EVALUATE_FIELD(bonecontrol1, MONFL_CHANGED_HEADYAW)
	EVALUATE_FIELD(subblendfrac, MONFL_CHANGED_HEADYAW)
	EVALUATE_FIELD(frame1time, MONFL_CHANGED_HEADYAW)
}

/* Make sure StartFrame calls this */
float
NSMonster::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex) {
		return (0);
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (0);
	}

	WriteByte(MSG_ENTITY, ENT_MONSTER);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], MONFL_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], MONFL_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], MONFL_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], MONFL_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], MONFL_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], MONFL_CHANGED_ANGLES_Z)
	SENDENTITY_ANGLE(v_angle[0], MONFL_CHANGED_ANGLES_X)
	SENDENTITY_SHORT(modelindex, MONFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(view_ofs[2], MONFL_CHANGED_MODELINDEX)
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
	SENDENTITY_FLOAT(skin, MONFL_CHANGED_SKINHEALTH)
	SENDENTITY_FLOAT(health, MONFL_CHANGED_SKINHEALTH)
	SENDENTITY_FLOAT(effects, MONFL_CHANGED_EFFECTS)
	SENDENTITY_SHORT(m_iBody, MONFL_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, MONFL_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[0], MONFL_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[1], MONFL_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[2], MONFL_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], MONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], MONFL_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], MONFL_CHANGED_VELOCITY)
	SENDENTITY_BYTE(m_iRenderMode, MONFL_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, MONFL_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_vecRenderColor[0], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_vecRenderColor[1], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_vecRenderColor[2], MONFL_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_flRenderAmt, MONFL_CHANGED_RENDERAMT)
	SENDENTITY_FLOAT(bonecontrol1, MONFL_CHANGED_HEADYAW)
	SENDENTITY_FLOAT(subblendfrac, MONFL_CHANGED_HEADYAW)
	SENDENTITY_FLOAT(frame1time, MONFL_CHANGED_HEADYAW)

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
	_RenderDebugViewCone();
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
	READENTITY_ANGLE(v_angle[0], MONFL_CHANGED_ANGLES_X)
	READENTITY_SHORT(modelindex, MONFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(view_ofs[2], MONFL_CHANGED_MODELINDEX)
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
	READENTITY_FLOAT(skin, MONFL_CHANGED_SKINHEALTH)
	READENTITY_FLOAT(health, MONFL_CHANGED_SKINHEALTH)
	READENTITY_FLOAT(effects, MONFL_CHANGED_EFFECTS)
	READENTITY_SHORT(m_iBody, MONFL_CHANGED_BODY)
	READENTITY_FLOAT(scale, MONFL_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[0], MONFL_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[1], MONFL_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[2], MONFL_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], MONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], MONFL_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], MONFL_CHANGED_VELOCITY)
	READENTITY_BYTE(m_iRenderMode, MONFL_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, MONFL_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_vecRenderColor[0], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_vecRenderColor[1], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_vecRenderColor[2], MONFL_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_flRenderAmt, MONFL_CHANGED_RENDERAMT)
	READENTITY_FLOAT(bonecontrol1, MONFL_CHANGED_HEADYAW)
	READENTITY_FLOAT(subblendfrac, MONFL_CHANGED_HEADYAW)
	READENTITY_FLOAT(frame1time, MONFL_CHANGED_HEADYAW)

	if (scale == 0.0) {
		scale = 1.0f;
	}

	if (flChanged & MONFL_CHANGED_SIZE) {
		setsize(this, mins * scale, maxs * scale);
	}

	if (flChanged & MONFL_CHANGED_BODY) {
		_UpdateGeomset();
	}

	if (flChanged & MONFL_CHANGED_MODELINDEX) {
		_UpdateBoneCount();
	}
}

void
NSMonster::_RenderDebugViewCone(void)
{
	vector v;
	float flDot;
	vector testOrg;

	if (health <= 0 || GetSolid(SOLID_CORPSE)) {
		return;
	}

	if (autocvar(r_showViewCone, 0) == 0) {
		return;
	}

	testOrg = pSeat->m_ePlayer.origin;
	v = normalize(testOrg - GetEyePos());
	flDot = v * anglesToForward(angles);

	/* not inside our FoV at all */
	if (flDot < 90.0f/180) {
		drawcone(GetEyePos(), angles, 16, 60, 90, [0.25,0,0], 0.25f);
		return;
	}

	traceline(GetEyePos(), testOrg, MOVE_EVERYTHING, this);

	/* we have line of sight with the client */
	if (trace_fraction == 1.0f || trace_ent == pSeat->m_ePlayer) {
		drawcone(GetEyePos(), angles, 16, 60, 90, [1,0,0], 0.75f);
	} else { /* in FoV, no line of sight */
		drawcone(GetEyePos(), angles, 16, 60, 90, [1,1,1], 0.25f);
	}
}
#endif

#ifdef SERVER
var bool autocvar_ai_debugAlerts = false;

var float g_monsteralert_timer;
void
NSMonster_AlertEnemyAlliance(vector pos, float radius, int alliance)
{
	/* sometimes many alert-sounds happen at once... we don't really want that */
	if (g_monsteralert_timer > time) {
		return;
	}

	if (autocvar_ai_debugAlerts)
		NSLog("AI alert from %v with radius %f and alliance %i", pos, radius, alliance);

	/* always check for the fastest-to-check attributes first here */
	for (entity w = world; (w = nextent(w));) {
		if (isAI(w) == false) {
			continue;
		}

		NSMonster f = (NSMonster)w;

		/* they already got a target of some kind */
		if (f.m_eEnemy) {
			if (autocvar_ai_debugAlerts)
				NSLog("\t%S already has a target", w.classname);
			continue;
		}

		/* if they're our friend... ignore*/
		if (f.IsFriend(alliance)) {
			if (autocvar_ai_debugAlerts)
				NSLog("\t%S is friend of alliance %i", w.classname, alliance);
			continue;
		}

		/* if the monster is dead... ignore */
		if (f.IsAlive() == false) {
			if (autocvar_ai_debugAlerts)
				NSLog("\t%S is dead, cannot be alerted", w.classname);
			continue;
		}

		/* expensive, out of radius */
		if (distance(pos, w.origin) > radius) {
			continue;
		}

		if (autocvar_ai_debugAlerts) {
			NSLog("\twe're alerting %S to go to %v", w.classname, pos);
		}

		/* we've heard a noise. investigate the location */
		f.RouteClear();
		f.RouteToPosition(pos);
		f.m_flSequenceSpeed = f.GetWalkSpeed();
		f.AlertNoise();
	}

	g_monsteralert_timer = time + 0.5f;
}

entity
NSMonster_FindClosestPlayer(entity target)
{
	NSMonster t = (NSMonster)target;
	entity best = world;
	float bestdist;
	float dist;

	bestdist = 9999999;

	for (entity e = world; (e = find(e, classname, "player"));) {
		/* hack: don't ever return dead players. they're invisible. */
		if (t.IsValidEnemy(e) == false) {
			continue;
		}

		dist = distance(target.origin, e.origin);

		if (dist < bestdist) {
			bestdist = dist;
			best = e;
		}
	}

	return best;
}
#endif
