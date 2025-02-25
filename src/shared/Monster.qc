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
ncMonster::ncMonster(void)
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
	m_usesNav = true;
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
	m_defMelee = __NULL__;
	m_defSpecial1 = __NULL__;
	m_iNumProjectiles = 1i;
	m_flProjectileDelay = 0.0f;
	m_flProjectileSpread = 0.0f;
	m_flAttackCone = 0.0f;
	m_flAttackAccuracy = 1.0f;
	m_flMeleeRange = -1;
	m_fireFromHead = false;

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
	m_flyOffset = 0.0f;

	m_outputOnDamaged =
	m_outputOnDeath =
	m_outputOnHalfHealth =
	m_outputOnHearPlayer =
	m_outputOnGreetPlayer =
	m_outputOnFoundEnemy =
	m_outputOnLostEnemy =
	m_outputOnLostEnemyLOS =
	m_outputOnFoundPlayer =
	m_outputOnLostPlayer =
	m_outputOnLostPlayerLOS =
	m_outputOnDamagedByPlayer = __NULL__;
#endif
}

void
ncMonster::DebugDraw(void)
{
#ifdef SERVER

	super::DebugDraw();
#if 0
	if not (autocvar(sv_printStateFromNPC, 0) == num_for_edict(this)) {
		return;
	}

	string aiString = sprintf("State: %S\nSchedule: %S\n", m_mindset, m_activeSchedule.classname);
	
	print(aiString);
#endif
#endif
}

vector
ncMonster::GetHeadAngles(void)
{
	return (GetAngles() + [0, m_flHeadYaw, 0]);
}

#ifdef SERVER
int
ncMonster::GetTriggerCondition(void)
{
	return m_iTriggerCondition;
}

void
ncMonster::TriggerTargets(void)
{
	for (entity f = world; (f = find(f, ::targetname, m_strTriggerTarget));) {
		ncTrigger trigger = (ncTrigger)f;

		if (trigger.Trigger != __NULL__) {
			trigger.Trigger(this, TRIG_TOGGLE);
		}
	}
}

void
ncMonster::Save(float handle)
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
ncMonster::Restore(string strKey, string strValue)
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
ncMonster::AnimIdle(void)
{
	return GetDefAct("idle");
}

int
ncMonster::AnimWalk(void)
{
	return GetDefAct("walk");
}

int
ncMonster::AnimRun(void)
{
	float runAnim = GetDefAct("run");
	return (runAnim == -1) ? AnimWalk() : runAnim;
}

void
ncMonster::AnimPlay(float seq)
{
	SetFrame(seq);
	m_flAnimTime = GetTime() + frameduration(modelindex, seq);
}

void
ncMonster::AnimationRewind(void)
{
	frame1time = 0.0f;
}

bool
ncMonster::InForcedAnimation(void)
{
	return (m_flAnimTime > time) ? true : false;
}

void
ncMonster::Sound(string msg)
{
	sound(this, CHAN_VOICE, msg, 1.0, ATTN_NORM);
}

void
ncMonster::Gib(int damage, vector dir)
{
	string breakModel = GetPropData(PROPINFO_BREAKMODEL);
	vector vecDir = vectorToAngles(GetOrigin() - dir);
	SetState(MONSTER_DEAD);
	MakeInvulnerable();

	if (STRING_SET(breakModel)) {
		BreakModel_Spawn(absmin, absmax, dir, damage * 2.5f, vlen(size) / 10, breakModel);
	}

	Disappear();
}

void
ncMonster::FallNoise(void)
{
}

void
ncMonster::IdleNoise(void)
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
ncMonster::AlertNoise(void)
{
	if (m_bGagged == true) {
		return;
	}

	MessageSchedule("AlertSound");
}

bool
ncMonster::IsFriend(int al)
{
	/* neutrals are always friendly */
	if (m_iAlliance == MAL_NEUTRAL) {
		return (true);
	}

	if (m_iAlliance == MAL_ROGUE) {
		return (false);
	} else if (al == m_iAlliance) {
		return (true);
	}

	return (false);
}

/* The maximum distance to which we should attempt an attack */
float
ncMonster::MeleeMaxDistance(void)
{
	return m_flMeleeRange;
}

/* Whether or not we should attempt a melee attack */
bool
ncMonster::MeleeCondition(void)
{
	return (vlen(origin - m_eEnemy.origin) < MeleeMaxDistance()) ? true : false;
}

float
ncMonster::SeeFOV(void)
{
	return 90;
}

void
ncMonster::AlertNearby(void)
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

		//ncMonsterLog("Alert! %s get %s", w.classname, m_eEnemy.classname);
		ncMonster f = (ncMonster)w;

		/* we shouldn't override this when they already got a target */
		if (f.m_eEnemy != __NULL__)
			continue;

		f.m_eEnemy = m_eEnemy;
		f._Alerted();
	}
}

void
ncMonster::AlertNearbyToSchedule(string scheduleType)
{

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

		//ncMonsterLog("Alert! %s get %s", w.classname, m_eEnemy.classname);
		ncMonster f = (ncMonster)w;

		/* we shouldn't override this when they already got a target */
		if (f.m_eEnemy != __NULL__)
			continue;

		f.m_eEnemy = m_eEnemy;
		f._Alerted();
		f.m_mindset = scheduleType;
	}
}

/* returns TRUE if 'enemy' should be considered a valid target for killing */
bool
ncMonster::IsValidEnemy(entity enny)
{
// 	printf("A\n");

	if (enny == __NULL__)
		return false;

// 	printf("B\n");

	/* dead enny should not be considered valid */
	if ((enny.solid == SOLID_CORPSE) || (enny.health <= 0))
		return false;

// 	printf("C\n");

	/* such monster should ignore players */
	if ((enny.flags & FL_CLIENT) && HasSpawnFlags(MSF_IGNOREPLAYER))
		return false;

// 	printf("D\n");

	/* monsters ignore enny who uses notarget cheat, useful for development */
	if (enny.flags & FL_NOTARGET)
		return false;

// 	printf("E\n");

	/* if they're our friend... ignore */
	if (IsFriend(enny.m_iAlliance))
		return false;

// 	printf("F\n");

	/* prevent from shooting non-sentient stuff */
	if (!(enny.flags & (FL_MONSTER | FL_CLIENT)))
		return false;

// 	printf("G\n");


	return true;
}

bool
ncMonster::IsOnRoute(void)
{
	return (m_iNodes || m_pathTarget) && (GetState() == MONSTER_IDLE || GetState() == MONSTER_ALERT) ? true : false;
}

static bool
ncMonster_TraceAgainsTarget(ncMonster monster, ncEntity target)
{
	traceline(monster.GetEyePos(), target.GetOrigin(), MOVE_NORMAL, monster);

	/* we have line of sight with the player */
	if (trace_fraction == 1.0f || trace_ent == target) {
		return true;
	}

	return false;
}

void
ncMonster::SeenPlayer(ncActor theActor)
{
}

void
ncMonster::SeenEnemy(ncActor theActor)
{
}

void
ncMonster::SeenFriend(ncActor theActor)
{
}

void
ncMonster::SeeThink(void)
{
	/* Prisoners are not meant to react to things they're seeing. */
	if (HasSpawnFlags(MSF_PRISONER) == true) {
		return;
	}

	if (m_eLookAt) {
		vector vecDelta;
		vecDelta = normalize( (m_eLookAt.origin + (m_eLookAt.view_ofs * 0.5f)) - GetEyePos() );
		m_flHeadYaw = (vecDelta * anglesToRight(angles)) * -60;
// 		printf("head yaw: %f %v\n", m_flHeadYaw, vecDelta);

		/* this will make the actor 'aim" at the target */
		{
			vector tmp = vectorToAngles(anglesToForward(v_angle));
			subblendfrac = tmp[0] / 90;
			bonecontrol1 = lerp(bonecontrol1, m_flHeadYaw, frametime * 15.0f);	/* head turning */
		}	
	}

	if (m_flSeeTime > time)
		return;

	m_flSeeTime = time + 0.25f;

	/* a horde type monster always knows where the nearest player is */
	if (m_iFlags & MSF_HORDE) {
		if (!m_eEnemy || m_iNodes < 1i) {
			m_eEnemy = ncMonster_FindClosestPlayer(this);

			if (m_eEnemy) {
				RouteToPositionDenyFlags(m_eEnemy.origin, LF_JUMP | LF_CROUCH | LF_HAZARDOUS | LF_AIM);
			}
		}

		return;
	}

	if (m_eEnemy) {
		/* check if we should invalidate current enemy */
		if (m_eEnemy.health <= 0) {
			m_mindset = "";
			MessageSchedule("DeadEnemy");
			m_eEnemy = __NULL__;
		} else if (IsValidEnemy(m_eEnemy)) {
			/* only update 1/4th of a second */
			if (m_flSeeTime > time)
				return;

			m_flSeeTime = time + 0.25f;
			m_eLookAt = m_eEnemy;

			/* see if we can trace our target, if yes, update our timestamp */
			if (ncMonster_TraceAgainsTarget(this, (ncEntity) m_eEnemy) == true) {
				m_flTrackingTime = time;
			}

			/* if we haven't gotten a trace in 5 seconds, give up. */
			if ((m_flTrackingTime + 5.0) > time) {
				m_mindset = "";
				if (isPlayer(m_eEnemy)) {
					UseOutput(m_eEnemy, m_outputOnLostPlayerLOS);
				} else {
					UseOutput(m_eEnemy, m_outputOnLostEnemyLOS);
				}

				MessageSchedule("OccludedEnemy");
				m_eEnemy = __NULL__;
			}
		} else {
			/* enemy is not valid anymore, reset it, clear route and search for new enemy */
			RouteClear();

			RouteToPosition(m_eEnemy.origin + (anglesToForward(angles) * -64));
			m_flSequenceSpeed = GetWalkSpeed();

			if (isPlayer(m_eEnemy)) {
				UseOutput(m_eEnemy, m_outputOnLostPlayer);
			} else {
				UseOutput(m_eEnemy, m_outputOnLostEnemy);
			}

			SetState(MONSTER_ALERT);
			m_eEnemy = __NULL__;
			m_eLookAt = __NULL__;
			m_flSeeTime = 0;
			MessageSchedule("LostEnemy");
		}
	}

	/* iterate through all players, monsters. */
	for (entity w = world; (w = findfloat(w, ::_isActor, 1));) {
		if (w.takedamage == DAMAGE_NO)
			continue;

		/* first, is the potential enemy in our field of view? */
		vector v = normalize(w.origin - GetEyePos());
		float flDot = v * anglesToForward(angles);

		if (flDot < SeeFOV()/180)
			continue;

		/* we have line of sight with the entity */
		if (ncMonster_TraceAgainsTarget(this, (ncEntity)w) == true) {
			/* check if 'w' could be a valid enemy */
			if (IsValidEnemy(w) == true) {
				if (m_eEnemy != w) {
					SeenEnemy((ncActor)w);
					m_eEnemy = m_eLookAt = w;
					MessageSchedule("NewEnemy");
					m_flTrackingTime = time;
					_Alerted();
					AlertNearby();

					if (isPlayer(w)) {
						UseOutput(m_eEnemy, m_outputOnFoundPlayer);
					} else {
						UseOutput(m_eEnemy, m_outputOnFoundEnemy);
					}
				}
			} else if (isPlayer(w)) {
				SeenPlayer((ncActor)w);

				if (m_bMetPlayer == false) {
					MessageSchedule("SeenPlayer");
					UseOutput(w, m_outputOnGreetPlayer);
				}

				m_bMetPlayer = true;
			} else if (IsFriend(w.m_iAlliance)) {
				SeenFriend((ncActor)w);
			}
		}
	}
}

float
ncMonster::GetWalkSpeed(void)
{
	return m_flWalkSpeed;
}

float
ncMonster::GetChaseSpeed(void)
{
	return m_flRunSpeed;
}

float
ncMonster::GetRunSpeed(void)
{
	return m_flRunSpeed;
}

bool
ncMonster::ShouldTurn(void)
{
	return (ideal_yaw != angles[1]) ? (true) : (false);
}

float
ncMonster::GetYawSpeed(void)
{
	if (GetState() == MONSTER_AIMING)
		return 128;

	return 90;
}

void
ncMonster::_LerpTurnToYaw(float turnYaw)
{
#if 0
	input_angles[1] = v_angle[1] = angles[1] = turnYaw;
#else
	vector oldAngle = angles;
	vector angleDelta;
	float oldYaw = angles[1];
	float yawDiff = 0.0f;

	if (IsThinking()) {
		input_angles[1] = v_angle[1] = angles[1] = turnYaw;
	}

	yaw_speed = GetYawSpeed() * (frametime * 5);
	ideal_yaw = turnYaw;
	changeyaw();
	angleDelta = angleDifference(oldAngle, angles);
	
	input_angles[1] = v_angle[1] = angles[1];

	///printf("yawDiff: %f\n", angleDelta[1]);

	if (fabs(angleDelta[1]) > 1.0f) {
		/* wasn't turning before */
		if (m_bTurning == false) {
			AnimationRewind();

			if (yawDiff < 0) {
				AnimPlay(GetDefAct("turnRight"));
			} else {
				AnimPlay(GetDefAct("turnLeft"));
			}
		}

		m_bTurning = true;
		input_movevalues = g_vec_null;
	} else {
		m_bTurning = false;
	}
#endif
}

void
ncMonster::_LerpTurnToPos(vector turnPos)
{
	vector vecWishAngle = vectorToAngles(turnPos - origin);
	_LerpTurnToYaw(vecWishAngle[1]);
}

void
ncMonster::AttackThink(void)
{
	if (InScriptedSequence()) {
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
		m_bCanAttack = false;
	} else {
		m_bCanAttack = true;
		/* make sure we remember the last known position. */
		m_vecLKPos = m_eEnemy.origin;
		vector wishAngles = vectorToAngles(m_vecLKPos - origin);
		ideal_yaw = wishAngles[1];
	}

	/* the state may have switched */
	if (m_flAttackThink > time) {
		return;
	}

	if (m_bCanAttack == true) {
		if (MeleeCondition() == TRUE) {
			MessageSchedule("CanMeleeAttack1");
		} else {
			MessageSchedule("CanRangedAttack1");
		}
	}

	m_flAttackThink = time + 0.25f;
}

int
ncMonster::AttackMelee(void)
{
#if 1
	float actMelee1 = GetDefAct("meleeAttack1");
	float actMelee2 = GetDefAct("meleeAttack2");

	if (STRING_SET(m_defMelee))
		return (false);

	_m_flMeleeDelay = GetSubDefFloat(m_defMelee, "delay");
	_m_flMeleeAttempts = GetSubDefFloat(m_defMelee, "attempts");

	//print(sprintf("Melee attack %S with delay %f and %d attempts\n", m_defMelee, _m_flMeleeDelay, _m_flMeleeAttempts));

	static void
	AttackMelee_AttackFlail(void)
	{
		ncActor targetEnt;
	
		if (distance(origin, m_eEnemy.origin) > m_flMeleeRange) {
			return (false);
		}

		float meleeWait = GetSubDefFloat(m_defMelee, "wait");
		traceline(origin, m_eEnemy.origin, FALSE, this);

		if (trace_fraction >= 1.0 || trace_ent.takedamage == DAMAGE_NO) {
			StartSoundDef(m_sndMeleeAttackMiss, CHAN_WEAPON, true);
			return (false);
		}

		targetEnt = (ncActor)trace_ent;

		ncDict damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", GetSubDefString(m_defMelee, "damage"));
		targetEnt.Damage(this, this, damageDecl, 1.0, vectorNormalize(angles), trace_endpos);
		remove(damageDecl);

		StartSoundDef(m_sndMeleeAttackHit, CHAN_WEAPON, true);

		_m_flMeleeAttempts--;

		if (_m_flMeleeAttempts > 0)
			ScheduleThink(AttackMelee_AttackFlail, _m_flMeleeDelay + meleeWait);
	}

	AnimationRewind();

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

void
ncMonster::PerformAttack(string attackDef)
{
	if (!m_fireFromHead) {
		ncAttack_SpawnDef(attackDef, this);
	} else {
		ncAttack_SpawnDefAtPosition(attackDef, this, GetEyePos(), GetHeadAngles());
	}
}

int
ncMonster::AttackRanged(void)
{
	static void AttackRanged_Throw(void)
	{
		self.nadeCookingTime = time;

		for (int i = 0; i < m_iNumProjectiles; i++) {

		}
	}
	static void AttackRanged_RangedSpecial(void)
	{
		self.nadeCookingTime = time;
		ncMonsterLog("AttackRanged_RangedSpecial: %S", m_defRanged2);
		PerformAttack(m_defRanged2);
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
			ncMonsterLog("throwAnyway: true!");
		}

	/* special always first if possible */
	if (throwAnyway == false && inRanged1Range && trace_ent == m_eEnemy) {
		float rangedDly = 0.0f;
		float rangedMin = 0.0f;
		float rangedMax = 0.0f;
		float burstCount = 0;
		float burstDelay = 0.0;
		float actRanged = GetDefAct("rangeAttack1");
		float burstTime = 0.0f;

		if (STRING_SET(m_defRanged1)) {
			rangedDly = GetSubDefFloat(m_defRanged1, "delay");
			rangedMin = GetSubDefFloat(m_defRanged1, "delay_min");
			rangedMax = GetSubDefFloat(m_defRanged1, "delay_max");
			burstCount = GetSubDefFloat(m_defRanged1, "burst");
			burstDelay = GetSubDefFloat(m_defRanged1, "burst_delay");
		} else {
			rangedDly = frameduration(modelindex, actRanged);
		}

		if (rangedDly <= 0.0) {
			rangedDly = random(rangedMin, rangedMax);
		}

		/* can't shoot anything ranged anymore, need to reload. */
		if (m_flReloadCount)
		if (_m_flReloadTracker > m_flReloadCount) {
			float startAmmo = 0;
			float actReload = GetDefAct("reload");

			/* out of ammo, cannot reload */
			if (m_flReserveAmmo == 0) {
				//ncMonsterLog("Out of ammo!");
				return 0;
			}

			/* do we not have unlimited ammo? */
			if (m_flReserveAmmo != -1) {
				m_flReserveAmmo -= m_flReloadCount;
				ncMonsterLog("Reserve ammo: %d", m_flReserveAmmo);

				/* oh no, we're below 0 in terms of ammo. */
				if (m_flReserveAmmo < 0) {
					startAmmo = -m_flReserveAmmo;
					m_flReserveAmmo = 0; /* we're fully emptied now */
				}
			}

			ncMonsterLog("Starting at %d bullets", startAmmo);
			_m_flReloadTracker = startAmmo;
			AnimPlay(actReload);
			StartSoundDef(m_sndReload, CHAN_WEAPON, true);
			_m_bShouldThrow = false;

			if (m_flReloadDelay) {
				m_flAttackThink = time + m_flReloadDelay;
				ncMonsterLog("Reloading, delay %f seconds", m_flReloadDelay);
			} else {
				float actDuration = frameduration(modelindex, actReload);
				m_flAttackThink = time + actDuration;
				ncMonsterLog("Reloading, act delays it by %f seconds", actDuration);
			}

			return 1;
		}

		AnimationRewind();
		AnimPlay(actRanged);

		/* if we have no spawnclass, it must be a hitscan weapon */
		if (STRING_SET(m_defRanged1)) {
			if (EntityDef_HasSpawnClass(m_defRanged1)) {
				PerformAttack(m_defRanged1);
				ncMonsterLog("Firing ranged def %S", m_defRanged1);
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
			ncMonsterLog("Primary ranged attack, delay %f seconds (burst %d)", rangedDly, burstTime);
		} else {
			float actAttackTime = frameduration(modelindex, actRanged);
			m_flAttackThink = time + actAttackTime + burstTime;
			ncMonsterLog("Primary ranged attack, act delays it by %f seconds (burst %f)", actAttackTime, burstTime);
		}

		return 1;
	} else if (throwAnyway == false && inRanged2Range && trace_ent == m_eEnemy) {
		float actRangedSpecial = GetDefAct("rangeAttack2");
		AnimationRewind();
		AnimPlay(actRangedSpecial);
		ScheduleThink(AttackRanged_RangedSpecial, 0.0f);
		m_flAttackThink = time + frameduration(modelindex, actRangedSpecial);
		return 1;
	} else if (inSpecial1Range) {
		AnimationRewind();
		AnimPlay(GetDefAct("specialAttack1"));
		ScheduleThink(AttackRanged_Throw, m_flProjectileDelay);

		if (_m_bShouldThrow)
			m_flAttackThink = time + 1.0f;
		else
			m_flAttackThink = time + 2.5f;

		return 1;
	} else if (inSpecial2Range) {
		AnimationRewind();
		AnimPlay(GetDefAct("specialAttack2"));
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
ncMonster::AttackDraw(void)
{
	float actDraw = GetDefAct("arm");
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
ncMonster::AttackHolster(void)
{
	float actHolster = GetDefAct("disarm");
	AnimPlay(actHolster);
	m_flAttackThink = time + frameduration(modelindex, actHolster);
}

void
ncMonster::ScriptedSequenceEnded(void)
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
		ncEntity findKT = (ncEntity)find(world, ::targetname, m_strSequenceKillTarget);

		if (findKT) {
			ncMonsterLog("Killing %S", m_strSequenceKillTarget);
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
	m_flAnimTime = 0.0f;
	m_flStopTime = 0.0f;
	RouteClear();

	/* trigger when required */
	if (STRING_SET(to_trigger)) {
		ncMonsterLog("Sequence over (hidden: %i, triggering: %S)", m_iSequenceRemove, to_trigger);

		for (entity f = world; (f = find(f, ::targetname, to_trigger));) {
			ncEntity trigger = (ncEntity)f;
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
ncMonster::ScriptedSequenceEnded_Moved(void)
{
	vector new_origin;
	new_origin = gettaginfo(this, 1);
	ncMonsterLog("Moved to %v", new_origin);
	SetOrigin(new_origin);

	if (GetMovetype() != MOVETYPE_FLY) {
		DropToFloor();
	}

	ScriptedSequenceEnded();
}

void
ncMonster::ScriptedSequenceEnded_Dead(void)
{
	vector new_origin;

	new_origin = gettaginfo(this, 1);
	ncMonsterLog("Moved to %v", new_origin);
	SetOrigin(new_origin);

	if (GetMovetype() != MOVETYPE_FLY) {
		DropToFloor();
	}

	RemoveFlags(FL_MONSTER);
	SetSolid(SOLID_CORPSE);
	SetState(MONSTER_DEAD);
	ScriptedSequenceEnded();
}

void
ncMonster::RouteEnded(void)
{
	m_flAnimTime = 0.0f;
	ClearVelocity();
	AnimationUpdate();

	super::RouteEnded();

	if (GetSequenceState() != SEQUENCESTATE_ACTIVE)
		return;

	/* mark that we've ended a sequence, if we're in one and que anim */
	if (m_flSequenceEnd) {
		float duration = frameduration(modelindex, m_flSequenceEnd);
		m_iSequenceState = SEQUENCESTATE_ENDING;
		think = (m_iSequenceFlags & SSFL_NOSCRIPTMOVE) ? ScriptedSequenceEnded : ScriptedSequenceEnded_Moved;
		nextthink = time + duration;
		ncMonsterLog("%s overriding anim for %f seconds (modelindex %d, frame %d)", \
			this.targetname, duration, modelindex, m_flSequenceEnd);
	} else {
		/* we still need to trigger targets */
		think = (m_iSequenceFlags & SSFL_NOSCRIPTMOVE) ? ScriptedSequenceEnded : ScriptedSequenceEnded_Moved;
		nextthink = time;
		ncMonsterLog("%s has no anim, finished sequence", \
			this.targetname);
	}
}

void
ncMonster::WalkRoute(void)
{
	float zDifference = 0.0f;
	float distToEnemy = 0.0f;
	vector wishAngle = input_angles;
	bool followRoute = false;
	bool followEnemy = false;
	bool stopMovement = false;
	input_movevalues = g_vec_null;

	if (m_flStopTime > GetTime() || m_bTurning) {
		input_movevalues = g_vec_null;

		if (movetype == MOVETYPE_FLY) {
			input_movevalues[2] = ((m_eEnemy.origin[2] + m_flyOffset) - origin[2]);
			input_movevalues[2] += sin(time) * 32.0f;
		}

		/* yaw interpolation */
		_LerpTurnToYaw(ideal_yaw);
		return;
	}

	if (m_iNodes > 0i) {
		wishAngle = GetRouteDirection();
		ideal_yaw = wishAngle[1];

		if (m_flSequenceSpeed <= 0.0f) {
			if (m_eEnemy)
				m_flSequenceSpeed = GetChaseSpeed();
			else
				m_flSequenceSpeed = GetWalkSpeed();
		}

		input_movevalues = GetRouteMovevalues() * m_flSequenceSpeed;

		//printf("Move values: %v\n", input_movevalues);

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

	} else {
		if (movetype == MOVETYPE_FLY) {
			input_movevalues[2] = ((m_eEnemy.origin[2] + m_flyOffset) - origin[2]);
			input_movevalues[2] += sin(time) * 32.0f;
		}
			return;
	}

	if (movetype == MOVETYPE_FLY) {
		input_movevalues[2] = ((m_eEnemy.origin[2] + m_flyOffset) - origin[2]);
		input_movevalues[2] += sin(time) * 32.0f;
	}
}

void
ncMonster::AnimationUpdate(void)
{
	int fr = 0;
	int act = 0;

	if (GetState() == MONSTER_DEAD) {
		return;
	}

	if (GetState() == MONSTER_AIMING) {
		return;
	}

	if (m_bTurning) {
		return;
	}

	float spvel = length(velocity);
	float midspeed = GetWalkSpeed() + ((GetRunSpeed() -  GetWalkSpeed()) * 0.5f);

	if (m_flStopTime > GetTime()) {
		spvel = 0.0f;
	}

	if (spvel < 5) {
		if (m_actIdle == -1) {
			m_actIdle = AnimIdle();
		}

		fr = m_actIdle;

		if (m_iMoveState != MOVESTATE_IDLE)
			m_flAnimTime = 0.0f;

		if (fr == -1) {
			act = GetDefAct("idle");
		}


		m_iMoveState = MOVESTATE_IDLE;
	} else if (spvel < midspeed) {
		fr = AnimWalk();

		if (m_iMoveState != MOVESTATE_WALK) {
				m_flAnimTime = 0.0f;
		}

		if (fr == -1) {
			act = GetDefAct("walk");
		}

		m_iMoveState = MOVESTATE_WALK;
	} else {
		fr = AnimRun();

		if (m_iMoveState != MOVESTATE_RUN) {
			m_flAnimTime = 0.0f;
		}

		if (fr == -1) {
			act = GetDefAct("run");
		}

		m_iMoveState = MOVESTATE_RUN;
	}

	if (InForcedAnimation() == true) {
		return;
	}

	if (fr == -1) {
		AnimPlay(act);
	} else {
		SetFrame(fr);
	}
}

/* for an ncMonster, health doesn't matter that much, as we could be a corpse */
bool
ncMonster::IsAlive(void)
{
	if (GetState() == MONSTER_DEAD)
		return false;

	return true;
}

void
ncMonster::StateChanged(monsterState_t oldState, monsterState_t newState)
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
ncMonster::SetState(monsterState_t newState)
{
	if (newState == m_iMState) {
		return;
	}

	m_iOldMState = m_iMState;
	m_iMState = newState;
	StateChanged(m_iOldMState, m_iMState);
}

monsterState_t
ncMonster::GetState(void)
{
	return m_iMState;
}

int
ncMonster::GetSequenceState(void)
{
	return m_iSequenceState;
}

bool
ncMonster::InScriptedSequence(void)
{
	return (GetSequenceState() == SEQUENCESTATE_NONE) ? false : true;
}

void
ncMonster::RunAI(void)
{
	if (GetMovetype() == MOVETYPE_NONE) {
		return;
	}

	if (InScriptedSequence() == false) {
		ThinkSchedules();
	}

	SeeThink();
	AttackThink();
}

void
ncMonster::Physics(void)
{
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;
	input_timelength = frametime;
	input_angles = angles;
	m_bTurning = false;

	if (autocvar_ai_enable == false) {
		HandleThink();
		return;
	}

	/* check if we're supposed to be awake */
	if (m_pvsSleep == false) {
		if (SharesPVSWithPlayer() == false) {
			HandleThink();
			return;
		}

		m_pvsSleep = true;
		EntLog("Unfreezing entity, in discovered PVS");
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
		HandleThink();
		return;
	}

	/* HACK!!! */
	if (!IsAlive()) {
		processmodelevents(modelindex, frame, m_flBaseTime,
			frame1time, HandleAnimEvent);
		HandleThink();
		return;
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

	if (ShouldTurn()) {
		_LerpTurnToYaw(ideal_yaw);
	}

	/* we're ending a scripted sequence, so play its animation */
	if (GetSequenceState() == SEQUENCESTATE_ENDING) {
		_LerpTurnToYaw(m_vecSequenceAngle[1]);

		if (m_bTurning == false)
			SetFrame(m_flSequenceEnd);
	} else {
		/* if still alive... */
		if (IsAlive()) {
			RunAI();
			AnimationUpdate();
		}

		/* FIXME: suppress movement when playing an animation outside
		   a scripted sequence */
		if (m_usesNav) {
			CheckRouteProgression();
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
	HandleThink();
}

void
ncMonster::Touch(entity eToucher)
{
	/* leap test, are we no longer on the ground? */
	if (m_flLeapDamage && m_bLeapAttacked == false)
	if (HasFlags(FL_ONGROUND) == false) {
		if (eToucher.takedamage != DAMAGE_NO) {
			ncSurfacePropEntity toucher = (ncSurfacePropEntity)eToucher;
			ncDict damageDecl = spawn(ncDict);
			damageDecl.AddKey("damage", ftos(m_flLeapDamage));
			toucher.Damage(this, owner, damageDecl, 1.0, vectorNormalize(angles), trace_endpos);
			remove(damageDecl);
			m_bLeapAttacked = true;
		}
	}

	if (movetype != MOVETYPE_WALK) {
		return;
	}

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
ncMonster::HasBeenHit(void)
{
	/* to be filled in by the sub-class */
}

void
ncMonster::RouteClear(void)
{
	if (m_activeSchedule && m_activeSchedule.ProgressOnMovement()) {
		m_activeSchedule.m_bProgressOnMovement = false;
		m_activeSchedule.Advance();
	}

	super::RouteClear();
}

void
ncMonster::Pain(entity inflictor, entity attacker, int damage, vector dir,  vector absImpactPos, int hitBody)
{
	float actSmallFlinch = GetDefAct("smallFlinch");
	float actBigFlinch = GetDefAct("bigFlinch");
	float actTwitch = GetDefAct("twitch");
	float actPain = -1;
	float baseHealth = GetSpawnFloat("health");
	float halfHealth = (baseHealth / 2);
	float oldHealth = GetHealth() + damage; /* FIXME: unreliable, damage points may have affected armor. */

	/* dead things tell nuthin */
	if (IsAlive() == false) {
		return;
	}

	if (attacker.classname == "player") {
		if (STRING_SET(m_outputOnDamagedByPlayer)) {
			UseOutput(attacker, m_outputOnDamagedByPlayer);
		}
	} else {
		if (STRING_SET(m_outputOnDamaged)) {
			UseOutput(attacker, m_outputOnDamaged);
		}
	}

	MessageSchedule("Damage");

	if (GetHealth() <= halfHealth) {
		MessageSchedule("HeavyDamage");
	} else {
		MessageSchedule("LightDamage");
	}

	if (GetHealth() <= halfHealth && oldHealth > halfHealth) {
		if (IsFriend(attacker.m_iAlliance) == true) {
			m_iAlliance = MAL_ROGUE;
		}

		UseOutput(attacker, m_outputOnHalfHealth);
	}

	if (IsFriend(attacker.m_iAlliance) == true) {
		return;
	}

	/* if don't have an enemy, set one; else make it random */
	if (!m_eEnemy || (random() < 0.5)) {
		m_eEnemy = m_eLookAt = attacker;
		MessageSchedule("NewEnemy");
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

	switch (hitBody) {
	case BODY_HEAD:
		actPain = GetDefAct("flinchHead");
		break;
	case BODY_CHEST:
		actPain = GetDefAct("flinchChest");
		break;
	case BODY_STOMACH:
		actPain = GetDefAct("flinchStomach");
		break;
	case BODY_ARMLEFT:
		actPain = GetDefAct("flinchLeftArm");
		break;
	case BODY_ARMRIGHT:
		actPain = GetDefAct("flinchRightArm");
		break;
	case BODY_LEGLEFT:
		actPain = GetDefAct("flinchLeftLeg");
		break;
	case BODY_LEGRIGHT:
		actPain = GetDefAct("flinchRightLeg");
		break;
	}

	/* fallback in case we do not have specialized flinches */
	if (actPain == -1) {
		/* for big damage pain anim, we need to take at least 1/3rd of health */
		if (actBigFlinch >= 0 && damage > (baseHealth / 3))
			actPain = actBigFlinch;
		else if (actSmallFlinch >= 0)
			actPain = actSmallFlinch;
		else if (actTwitch >= 0)
			actPain = actTwitch;
	}

	if (actPain == -1) {
		return;
	}

	AnimPlay(actPain);

	StartSoundDef(m_sndPain, CHAN_VOICE, true);
	HasBeenHit();
}

void
ncMonster::HasBeenKilled(void)
{
	/* to be filled in by the sub-class */
}

void
ncMonster::HasBeenGibbed(void)
{
	/* to be filled in by the sub-class */
}

void
ncMonster::HasBeenAlerted(void)
{
	/* to be filled in by the sub-class */
}

void
ncMonster::_Alerted(void)
{
	HasBeenAlerted();
}

void
ncMonster::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	float actViolent = GetDefAct("dieViolent");
	float actForward = GetDefAct("dieForward");
	float actBackward = GetDefAct("dieBackward");
	float actSimple = GetDefAct("dieSimple");
	float actBackshot = GetDefAct("dieBackshot");
	float actDeath = -1;


	/* we were already dead before, so gib */
	if (GetState() == MONSTER_DEAD) {
		HasBeenGibbed();
		Gib(damage, dir);
		return;
	}

	m_iFlags = 0x0;
	CancelSchedule();

	switch (hitBody) {
	case BODY_HEAD:
		actDeath = GetDefAct("dieHeadshot");
		break;
	case BODY_CHEST:
		actDeath = GetDefAct("dieChestshot");
		break;
	case BODY_STOMACH:
		actDeath = GetDefAct("dieGutshot");
		break;
	}

	if (actDeath < 0) {
		if (actViolent >= 0 && GetHealth() < -25) { /* lots of damage */
			actDeath = (actViolent);
		} else if (actBackshot >= 0 && IsFacingPosition(absImpactPos) == false) {
			actDeath = (actBackshot);
		} else if (actForward >= 0 && IsFacingPosition(absImpactPos) == false) {
			actDeath = (actForward);
		} else if (actBackward >= 0 && IsFacingPosition(absImpactPos) == true) {
			actDeath = (actBackward);
		} else {
			actDeath = actSimple;
		}
	} else {
		actDeath = actSimple;
	}

	AnimPlay(actDeath);

	if (autocvar(g_forceRagdolls, 0) || GetDefBool("ragdoll") == true) {
		BodyQue_Spawn((ncActor)this, frame);
		Disappear();
		SetState(MONSTER_DEAD);
	} else {
		/* if we make more than 50 damage, gib immediately */
		if (GetHealth() < -50) {
			HasBeenGibbed();
			Gib(damage, dir);
			return;
		}

		/* set the monster up for getting gibbed */
		SetSolid(SOLID_CORPSE);
		SetHealth(50 + GetHealth());
		SetState(MONSTER_DEAD);
	}

	StartSoundDef(m_sndDeath, CHAN_VOICE, true);
	UseOutput(attacker, m_outputOnDeath);
	HasBeenKilled();
	g_grMode.NPCDeath(this, (ncActor)inflictor, (ncActor)attacker);

	/* make sure we're not causing any more obituaries */
	RemoveFlags(FL_MONSTER);

	if (GetMovetype() == MOVETYPE_FLY) {
		AddVelocity([0,0,128]);
		//SetSize([-8,-8,-8], [8,8,16]);
		SetMovetype(MOVETYPE_BOUNCE);
		customphysics = __NULL__;
	} else if (GetMovetype() != MOVETYPE_NONE) {
		SetMovetype(MOVETYPE_TOSS);
	}

	/* monsters trigger their targets when dead */
	if (GetTriggerCondition() == MTRIG_DEATH) {
		TriggerTargets();
	}
}

#if 0
void
ncMonster::Hide(void)
{
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	customphysics = __NULL__;
}
#endif

void
ncMonster::Spawned(void)
{
	if (!HasSpawnFlags(MSF_MULTIPLAYER)) {
		if (CreatedByMap() == true && g_grMode.MonstersSpawn() == FALSE) {
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

	flags = FL_MONSTER;

	CREATE_OUTPUT(m_outputOnDamaged)
	CREATE_OUTPUT(m_outputOnDeath)
	CREATE_OUTPUT(m_outputOnHalfHealth)
	CREATE_OUTPUT(m_outputOnHearPlayer)
	CREATE_OUTPUT(m_outputOnFoundEnemy)
	CREATE_OUTPUT(m_outputOnLostEnemy)
	CREATE_OUTPUT(m_outputOnLostEnemyLOS)
	CREATE_OUTPUT(m_outputOnFoundPlayer)
	CREATE_OUTPUT(m_outputOnLostPlayer)
	CREATE_OUTPUT(m_outputOnLostPlayerLOS)
	CREATE_OUTPUT(m_outputOnDamagedByPlayer)
	CREATE_OUTPUT(m_outputOnGreetPlayer)
}

void
ncMonster::Respawn(void)
{
	super::Respawn();

	m_bMetPlayer = false;
	m_activeSchedule = __NULL__;
	m_mindset = "";
	RestoreAngles();
	v_angle = fixAngle(GetAngles());
	m_vecSequenceAngle = GetAngles();
	MakeVulnerable();
	EnableAimAssist();
	SetState(MONSTER_IDLE);
	SetHealth(GetSpawnFloat("health"));
	m_eEnemy = __NULL__;
	m_iFlags = 0x0;
	m_flyOffset = GetSpawnFloat("fly_offset");
	m_flAnimTime = 0.0f;
	EnableBleeding();
	SetSize(GetSpawnVector("mins"), GetSpawnVector("maxs"));
	SetSkin(GetSpawnFloat("skin"));
	customphysics = Physics;
	SetSolid(SOLID_SLIDEBOX);
	AnimPlay(AnimIdle());
	ClearVelocity();
	RouteClear();

	SetEyePos([0, 0, m_flEyeHeight]);
	SetOrigin(GetSpawnVector("origin"));

	if (GetSpawnBool("flying"))
		SetMovetype(MOVETYPE_FLY);
	else if (GetSpawnBool("static"))
		SetMovetype(MOVETYPE_NONE);
	else {
		SetMovetype(MOVETYPE_WALK);
		DropToFloor();
		SetOriginUnstick(origin);
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
	} else {
		SetState(MONSTER_IDLE);
	}

	if (HasSpawnFlags(MSF_GAG)) {
		m_bGagged = true;
	} else {
		m_bGagged = false;
	}

	targetname = GetSpawnString("targetname");

	/* automatically start */
	if (STRING_SET(targetname)) {
		if (HasTriggerTarget() == true) {
			ScheduleThink(_ChaseAfterSpawn, 0.0f);
		}
	}
}

void
ncMonster::Input( entity entityActivator, string inputName, string dataField )
{
	switch (inputName) {
	case "Sleep":
		customphysics = __NULL__;
		ReleaseThink();
		break;
	case "Wake":
		customphysics = Physics;
		break;
	case "HordeOn":
		m_iFlags |= MSF_HORDE;
		m_eEnemy = ncMonster_FindClosestPlayer(this);

		if (m_eEnemy) {
			m_flSequenceSpeed = 300.0f;
			RouteToPosition(m_eEnemy.origin);
		}

		/* clear their chase path */
		ChasePath("");

		break;
	case "HordeOff":
		m_iFlags &= ~MSF_HORDE;
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
	case "Wait":
		float waitTime = stof(dataField);
		m_flStopTime = GetTime() + waitTime;

		if (m_activeSchedule) {
			m_activeSchedule.AdvanceLater(waitTime);
		}
		break;
	case "WaitRandom":
		float maxRandomTime = stof(dataField);
		float randomTime;

		/* if not specified... make something up */
		if (waitTime > 0.0f) {
			randomTime = random(0.0f, maxRandomTime);
		} else {
			randomTime = random(0.0f, 1.0f);
		}

		m_flStopTime = GetTime() + randomTime;

		if (m_activeSchedule) {
			m_activeSchedule.AdvanceLater(randomTime);
		}
		break;
	case "WaitIndefinitely":
		m_flStopTime = (60 * 60) * 24; /* 24 hours is enough... */

		if (m_activeSchedule) {
			m_activeSchedule.AdvanceLater(m_flStopTime);
		}

		m_flStopTime += GetTime();
		break;
	case "PlayActivity":
		if (STRING_SET(dataField)) {
			AnimPlay(GetDefAct(dataField));

			if (m_activeSchedule) {
				m_activeSchedule.AdvanceLater(frameduration(modelindex, frame));
			}
		}
		break;
	case "PlaySequence":
		if (STRING_SET(dataField)) {
			AnimationRewind();
			ClearVelocity();
			m_flSequenceSpeed = 0.0f;
			AnimPlay(frameforname(modelindex, dataField));

			if (m_activeSchedule) {
				m_activeSchedule.AdvanceLater(frameduration(modelindex, frame));
			}

		} else {
			NSError("'PlaySequence' without animation sequence, blame %S (%d)", entityActivator.classname, num_for_edict(entityActivator));
		}
		break;
	case "FindCoverFromEnemy":
		vector coverPos = ncNavInfo::FindCoverFromEnemy(this);

		if (vlen(coverPos) > 0.0f) {
			RouteToPosition(coverPos);
		} else {
			CancelSchedule();
		}
		break;
	case "SetSequenceMovementSpeed":
		m_flSequenceSpeed = stof(dataField);
		break;
	case "SetDesiredSchedule":
		m_mindset = dataField;
		break;
	case "AlertNearbyToSchedule":
		m_mindset = dataField;
		AlertNearbyToSchedule(dataField);
		break;
	case "WalkToTarget":
		m_flSequenceSpeed = GetWalkSpeed();
		RouteToPosition(m_activeSchedule.GetTarget().origin);
		break;
	case "RunToTarget":
		m_flSequenceSpeed = GetRunSpeed();
		RouteToPosition(m_activeSchedule.GetTarget().origin);
		break;
	case "CrouchToTarget":
		m_flSequenceSpeed = GetDefFloat("speed_crouch");
		RouteToPosition(m_activeSchedule.GetTarget().origin);
		break;
	case "ProneToTarget":
		m_flSequenceSpeed = GetDefFloat("speed_prone");
		RouteToPosition(m_activeSchedule.GetTarget().origin);
		break;
	case "WaitForMovement":
		if (m_iNodes > 0i && m_activeSchedule) {
			m_activeSchedule.m_bProgressOnMovement = true;
			m_activeSchedule.ReleaseThink();
		}
		break;
	case "SetFailSchedule":
		if (m_activeSchedule) {
			m_activeSchedule.SetFailSchedule(dataField);
		}
		break;
	case "Remember":
		printf("Rembering %S\n", dataField);
		/* TODO: add it to a decl */
		break;
	case "WaitPVS":
		m_pvsSleep = true;
		break;
	case "StopMovement":
		ClearVelocity();
		ideal_yaw = angles[1];
		break;
	case "TurnLeft":
		ideal_yaw += stof(dataField);
		break;
	case "TurnRight":
		ideal_yaw -= stof(dataField);
		break;
	case "TurnToIdealPosition":
		ideal_yaw = random(-179,180);
		break;
	case "TurnToEnemy":
		vector turnTo = vectoangles(m_eEnemy.origin - origin);
		ideal_yaw = turnTo[1];
		break;
	case "AttackMelee1":
		AnimationRewind();
		AnimPlay(GetDefAct("meleeAttack1"));
		break;
	case "AttackMelee2":
		AnimationRewind();
		AnimPlay(GetDefAct("meleeAttack2"));
		break;
	case "AttackRanged1":
		AnimationRewind();
		AnimPlay(GetDefAct("rangeAttack1"));
		break;
	case "AttackRanged2":
		AnimationRewind();
		AnimPlay(GetDefAct("rangeAttack2"));
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
ncMonster::Trigger(entity act, triggermode_t state)
{
	m_eEnemy = __NULL__;
	RouteClear();
	ChasePath(GetTriggerTarget());
	m_flSequenceSpeed = m_flWalkSpeed;
}

void
ncMonster::_ChaseAfterSpawn(void)
{
	Trigger(this, TRIG_TOGGLE);
}

void
ncMonster::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "OnDamaged":
		m_outputOnDamaged = PrepareOutput(m_outputOnDamaged, strValue);
		break;
	case "OnDeath":
		m_outputOnDeath = PrepareOutput(m_outputOnDeath, strValue);
		break;
	case "OnHalfHealth":
		m_outputOnHalfHealth = PrepareOutput(m_outputOnHalfHealth, strValue);
		break;
	case "OnHearPlayer":
		m_outputOnHearPlayer = PrepareOutput(m_outputOnHearPlayer, strValue);
		break;
	case "OnFoundEnemy":
		m_outputOnFoundEnemy = PrepareOutput(m_outputOnFoundEnemy, strValue);
		break;
	case "OnLostEnemy":
		m_outputOnLostEnemy = PrepareOutput(m_outputOnLostEnemy, strValue);
		break;
	case "OnLostEnemyLOS":
		m_outputOnLostEnemyLOS = PrepareOutput(m_outputOnLostEnemyLOS, strValue);
		break;
	case "OnFoundPlayer":
		m_outputOnFoundPlayer = PrepareOutput(m_outputOnFoundPlayer, strValue);
		break;
	case "OnLostPlayer":
		m_outputOnLostPlayer = PrepareOutput(m_outputOnLostPlayer, strValue);
		break;
	case "OnLostPlayerLOS":
		m_outputOnLostPlayerLOS = PrepareOutput(m_outputOnLostPlayerLOS, strValue);
		break;
	case "OnDamagedByPlayer":
		m_outputOnDamagedByPlayer = PrepareOutput(m_outputOnDamagedByPlayer, strValue);
		break;
	case "OnGreetPlayer":
		m_outputOnGreetPlayer = PrepareOutput(m_outputOnGreetPlayer, strValue);
		break;
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
	case "fly_offset":
		m_flyOffset = ReadFloat(strValue);
		break;
	case "use_nav":
		m_usesNav = ReadBool(strValue);
		break;
	case "fireFromHead":
		m_fireFromHead = ReadBool(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
ncMonster::EvaluateEntity(void)
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
ncMonster::SendEntity(entity ePEnt, float flChanged)
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
ncMonster::customphysics(void)
{
	/* Page intentionally left blank */
}

float
ncMonster::predraw(void)
{
	float render;
	render = super::predraw();
	_RenderDebugViewCone();
	return render;
}

/*
============
ncMonster::ReceiveEntity
============
*/
void
ncMonster::ReceiveEntity(float flNew, float flChanged)
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
ncMonster::_RenderDebugViewCone(void)
{
	vector v;
	float flDot;
	vector testOrg;

	if (health <= 0 || GetSolid() == SOLID_CORPSE) {
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
ncMonster_AlertEnemyAlliance(vector pos, float radius, int alliance)
{
	/* sometimes many alert-sounds happen at once... we don't really want that */
	if (g_monsteralert_timer > time) {
		return;
	}

#if 1
	if (autocvar_ai_debugAlerts)
		NSLog("AI alert from %v with radius %f and alliance %i", pos, radius, alliance);

	/* always check for the fastest-to-check attributes first here */
	for (entity w = world; (w = nextent(w));) {
		if (isAI(w) == false) {
			continue;
		}

		ncMonster f = (ncMonster)w;

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
		f.AlertNoise();
	}
#endif
	g_monsteralert_timer = time + 0.5f;
}

entity
ncMonster_FindClosestPlayer(entity target)
{
	ncMonster t = (ncMonster)target;
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
