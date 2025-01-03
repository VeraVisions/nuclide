/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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
ncProjectile::ncProjectile(void)
{
#ifdef SERVER
	m_iProjectileAnimEnd = 0i;
	m_iProjectileAnimStart = 0i;
	m_flProjectileFramerate = 0.1f; /* default to 10 hz */

	/* defAPI */
	m_defDamage = __NULL__;
	m_defSplashDamage = __NULL__;
	m_vecLaunchVelocity = g_vec_null;
	m_flThrust = 0.0f;
	m_flThrustStart = 0.0f;
	m_flThrustEnd = 0.0f;
	m_flFrictionLinear = 0.0f;
	m_flBounce = 0.0f;
	m_flMass = 0.0f;
	m_flGravity = 0.0f;
	m_flFuse = 0.0f;
	m_bDetonateOnFuse = false;
	m_bDetonateOnDeath = false;
	m_bDetonateOnWorld = false;
	m_bDetonateOnActor = false;
	m_bImpactEffect = false;
	m_bImpactGib = false;
	m_matDetonate = __NULL__;
	m_flDecalSize = 0.0f;
	m_partSmokeFly = __NULL__;
	m_partFXPath = __NULL__;
	m_partModelDetonate = __NULL__;
	m_partSmokeDetonate = __NULL__;
	m_partSmokeBounce = __NULL__;
	m_partSmokeFuse = __NULL__;
	m_iDebrisCount = 0i;
	m_bDebrisStick = false;
	m_vecDebrisOffset = g_vec_null;
	m_vecDetonateOffset = g_vec_null;
	m_vecDamageOffset = g_vec_null;
	m_vecImpactPos = g_vec_null;
	m_vecLightColor = g_vec_null;
	m_flLightRadius = 0.0f;
	m_flLightOffset = 0.0f;
	m_vecExplodeLightColor = g_vec_null;
	m_fExplodelLightRadius = 0.0f;
	m_fExplodelLightFadetime = 0.0f;
	m_sndFly = __NULL__;
	m_sndExplode = __NULL__;
	m_sndBounce = __NULL__;
	m_vecSpawnMins = g_vec_null;
	m_vecSpawnMaxs = g_vec_null;
	m_flSpawnFrame = 0;
	m_vecSpawnOrigin = g_vec_null;

	/* ETQW-additions */
	m_bIsBullet = false;
	m_iShots = 1i;
	m_vecSpread = [0.0, 0.0, 0.0];
	m_strDecalGroup = __NULL__;
	m_flRange = 8192.0f;


	/* Nuclide additions */
	m_bStickToWorld = false;
	m_bStickToActor = false;
	m_bThrustHoming = false;
	m_bInheritVelocity = false;
	m_noFX = false;
#endif
}

#ifdef SERVER
void
ncProjectile::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "def_damage": /* direct damage, upon touch */
		m_defDamage = ReadString(strValue);
		break;
	case "def_splash_damage": /* direct damage, upon touch */
		m_defSplashDamage = ReadString(strValue);
		break;
	case "velocity":
		m_vecLaunchVelocity = ReadVector(strValue);
		break;
	case "health": /* amount of dmg the projectile can take */
		health = ReadFloat(strValue);
		break;
	case "model":
		model = ReadString(strValue);
		break;
	case "velocity":
		velocity = ReadVector(strValue);
		break;
	case "angular_velocity": /* sets avelocity */
		avelocity = ReadVector(strValue);
		break;
	case "thrust": /* rate of acceeleration */
		m_flThrust = ReadFloat(strValue);
		break;
	case "thrust_start": /* when to begin accel */
		m_flThrustStart = ReadFloat(strValue);
		break;
	case "thrust_end": /* when to stop accel */
		m_flThrustEnd = ReadFloat(strValue);
		break;
	case "linear_friction": /* air friction */
		m_flFrictionLinear = ReadFloat(strValue);
		break;
	case "bounce": /* bounce multiplier */
		m_flBounce = ReadFloat(strValue);
		break;
	case "mass":
		m_flMass = ReadFloat(strValue);
		break;
	case "gravity": /* 0 means no gravity */
		m_flGravity = ReadFloat(strValue);
		break;
	case "fuse": /* fuse time in seconds */
		m_flFuse = ReadFloat(strValue);
		break;
	case "detonate_on_fuse": /* should it detonate when fuse runs out? */
		m_bDetonateOnFuse = ReadBool(strValue);
		break;
	case "detonate_on_death": /* should it detonate when it gets damaged enough? */
		m_bDetonateOnDeath = ReadBool(strValue);
		break;
	case "detonate_on_world": /* should it detonate when touching world? */
		m_bDetonateOnWorld = ReadBool(strValue);
		break;
	case "detonate_on_actor": /* should it detonate when touching a monster/player */
		m_bDetonateOnActor = ReadBool(strValue);
		break;
	case "impact_damage_effect": /* blood splats? */
		m_bImpactEffect = ReadBool(strValue);
		break;
	case "impact_gib": /* gibs */
		m_bImpactGib = ReadBool(strValue);
		break;
	case "decal_detonate":
	case "mtr_detonate":
		m_matDetonate = ReadString(strValue);
		break;
	case "decal_size":
		m_flDecalSize = ReadFloat(strValue);
		break;
	case "smoke_fly":
		m_partSmokeFly = ReadString(strValue);
		break;
	case "fx_path":
		m_partFXPath = ReadString(strValue);
		break;
	case "model_detonate":
		m_partModelDetonate = ReadString(strValue);
		break;
	case "smoke_detonate":
		m_partSmokeDetonate = ReadString(strValue);
		break;
	case "smoke_bounce":
		m_partSmokeBounce = ReadString(strValue);
		break;
	case "smoke_fuse":
		m_partSmokeFuse = ReadString(strValue);
		break;
	case "debris_count":
		m_iDebrisCount = ReadInt(strValue);
		break;
	case "debris_stick":
		m_bDebrisStick = ReadBool(strValue);
		break;
	case "debris_offset":
		m_vecDebrisOffset = ReadVector(strValue);
		break;
	case "detonate_offset":
		m_vecDetonateOffset = ReadVector(strValue);
		break;
	case "damage_offset":
		m_vecDamageOffset = ReadVector(strValue);
		break;
	case "projectile_debris":
		m_defProjectileDebris = ReadString(strValue);
		break;
	/*case "def_debris":
		break;
	case "def_shrapnel":
		break;
	case "mtr_light_shader":
		break;*/
	case "light_color":
		m_vecLightColor = ReadVector(strValue);
		break;
	case "light_radius":
		m_flLightRadius = ReadFloat(strValue);
		break;
	case "light_offset":
		m_flLightOffset = ReadFloat(strValue);
		break;
	/*case "mtr_explode_light_shader":
		break;*/
	case "explode_light_color":
		m_vecExplodeLightColor = ReadVector(strValue);
		break;
	case "explode_light_radius":
		m_fExplodelLightRadius = ReadFloat(strValue);
		break;
	case "explode_light_fadetime":
		m_fExplodelLightFadetime = ReadFloat(strValue);
		break;
	case "snd_fly":
		m_sndFly = ReadString(strValue);
		break;
	case "snd_explode":
		m_sndExplode = ReadString(strValue);
		break;
	case "snd_bounce":
		m_sndBounce = ReadString(strValue);
		break;
	/* ETQW-additions */
	case "is_bullet":
		m_bIsBullet = ReadBool(strValue);
		break;
	case "hitscans":
		m_iShots = ReadInt(strValue);
		break;
	case "spread":
		m_vecSpread = ReadVector(strValue);
		break;
	case "spread_x":
		m_vecSpread[0] = ReadFloat(strValue);
		break;
	case "spread_y":
		m_vecSpread[1] = ReadFloat(strValue);
		break;
	case "decal_impact":
		m_strDecalGroup = ReadString(strValue);
		break;
	case "range":
		m_flRange = ReadFloat(strValue);
		break;
	/* Nuclide additions */
	case "stick_to_world":
		m_bStickToWorld = ReadBool(strValue);
		break;
	case "stick_to_actor":
		m_bStickToActor = ReadBool(strValue);
		break;
	case "mins":
		m_vecSpawnMins = ReadVector(strValue);
		break;
	case "maxs":
		m_vecSpawnMaxs = ReadVector(strValue);
		break;
	case "thrust_homing":
		m_bThrustHoming = ReadBool(strValue);
		break;
	case "frame":
		m_flSpawnFrame = ReadFloat(strValue);
		break;
	case "inherit_velocity":
		m_bInheritVelocity = ReadBool(strValue);
		break;
	case "offset":
		m_vecSpawnOrigin = ReadVector(strValue);
		break;
	case "damage":
		m_flDamage = ReadFloat(strValue);
		break;
	case "thrown":
		m_bThrown = ReadBool(strValue);
		break;
	case "reflects":
		m_bReflect = ReadBool(strValue);
		break;
	case "trackEnemy":
		m_bTrackEnemy = ReadBool(strValue);
		break;
	case "trackJitter":
		m_trackJitter = ReadVector(strValue);
		break;
	case "trackDelay":
		m_trackDelay = ReadFloat(strValue);
		break;
	case "def_planeImpact":
		m_defPlaneImpact = ReadString(strValue);
		break;
	case "noFX":
		m_noFX = ReadBool(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
ncProjectile::Save(float handle)
{
	super::Save(handle);

	SaveInt(handle, "m_iProjectileAnimEnd", m_iProjectileAnimEnd);
	SaveInt(handle, "m_iProjectileAnimStart", m_iProjectileAnimStart);
	SaveFloat(handle, "m_flProjectileFramerate", m_flProjectileFramerate);
	SaveFloat(handle, "m_flDmgMultiplier", m_flDmgMultiplier);
	SaveString(handle, "m_defDamage", m_defDamage);
	SaveString(handle, "m_defSplashDamage", m_defSplashDamage);
	SaveVector(handle, "m_vecLaunchVelocity", m_vecLaunchVelocity);
	SaveFloat(handle, "m_flThrust", m_flThrust);
	SaveFloat(handle, "m_flThrustStart", m_flThrustStart);
	SaveFloat(handle, "m_flThrustEnd", m_flThrustEnd);
	SaveFloat(handle, "m_flFrictionLinear", m_flFrictionLinear);
	SaveFloat(handle, "m_flBounce", m_flBounce);
	SaveFloat(handle, "m_flMass", m_flMass);
	SaveFloat(handle, "m_flGravity", m_flGravity);
	SaveFloat(handle, "m_flFuse", m_flFuse);
	SaveBool(handle, "m_bDetonateOnFuse", m_bDetonateOnFuse);
	SaveBool(handle, "m_bDetonateOnDeath", m_bDetonateOnDeath);
	SaveBool(handle, "m_bDetonateOnWorld", m_bDetonateOnWorld);
	SaveBool(handle, "m_bDetonateOnActor", m_bDetonateOnActor);
	SaveBool(handle, "m_bImpactEffect", m_bImpactEffect);
	SaveBool(handle, "m_bImpactGib", m_bImpactGib);
	SaveString(handle, "m_matDetonate", m_matDetonate);
	SaveFloat(handle, "m_flDecalSize", m_flDecalSize);
	SaveString(handle, "m_partSmokeFly", m_partSmokeFly);
	SaveString(handle, "m_partFXPath", m_partFXPath);
	SaveString(handle, "m_partModelDetonate", m_partModelDetonate);
	SaveString(handle, "m_partSmokeDetonate", m_partSmokeDetonate);
	SaveString(handle, "m_partSmokeBounce", m_partSmokeBounce); 
	SaveString(handle, "m_partSmokeFuse", m_partSmokeFuse);
	SaveString(handle, "m_defProjectileDebris", m_defProjectileDebris);
	SaveInt(handle, "m_iDebrisCount", m_iDebrisCount);
	SaveVector(handle, "m_vecLightColor", m_vecLightColor);
	SaveFloat(handle, "m_flLightRadius", m_flLightRadius);
	SaveFloat(handle, "m_flLightOffset", m_flLightOffset);
	SaveVector(handle, "m_vecExplodeLightColor", m_vecExplodeLightColor);
	SaveFloat(handle, "m_fExplodelLightRadius", m_fExplodelLightRadius);
	SaveFloat(handle, "m_fExplodelLightFadetime", m_fExplodelLightFadetime);
	SaveString(handle, "m_sndFly", m_sndFly);
	SaveString(handle, "m_sndExplode", m_sndExplode);
	SaveString(handle, "m_sndBounce", m_sndBounce);
	SaveBool(handle, "m_bIsBullet", m_bIsBullet);
	SaveBool(handle, "m_bStickToWorld", m_bStickToWorld);
	SaveBool(handle, "m_bStickToActor", m_bStickToActor);
	SaveVector(handle, "m_vecSpawnMins", m_vecSpawnMins);
	SaveVector(handle, "m_vecSpawnMaxs", m_vecSpawnMaxs);
	SaveBool(handle, "m_bThrustHoming", m_bThrustHoming);
	SaveEntity(handle, "m_thrustHandler", m_thrustHandler);
	SaveFloat(handle, "m_flSpawnFrame", m_flSpawnFrame);
	SaveBool(handle, "m_bInheritVelocity", m_bInheritVelocity);
	SaveBool(handle, "m_bThrown", m_bThrown);
}

void
ncProjectile::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iProjectileAnimEnd":
		m_iProjectileAnimEnd = ReadInt(strValue);
		break;
	case "m_iProjectileAnimStart":
		m_iProjectileAnimStart = ReadInt(strValue);
		break;
	case "m_flProjectileFramerate":
		m_flProjectileFramerate = ReadFloat(strValue);
		break;
	case "m_flDmgMultiplier":
		m_flDmgMultiplier = ReadFloat(strValue);
		break;
	case "m_defDamage":
		m_defDamage = ReadString(strValue);
		break;
	case "m_defSplashDamage":
		m_defSplashDamage = ReadString(strValue);
		break;
	case "m_vecLaunchVelocity":
		m_vecLaunchVelocity = ReadVector(strValue);
		break;
	case "m_flThrust":
		m_flThrust = ReadFloat(strValue);
		break;
	case "m_flThrustStart":
		m_flThrustStart = ReadFloat(strValue);
		break;
	case "m_flThrustEnd":
		m_flThrustEnd = ReadFloat(strValue);
		break;
	case "m_flFrictionLinear":
		m_flFrictionLinear = ReadFloat(strValue);
		break;
	case "m_flBounce":
		m_flBounce = ReadFloat(strValue);
		break;
	case "m_flMass":
		m_flMass = ReadFloat(strValue);
		break;
	case "m_flGravity":
		m_flGravity = ReadFloat(strValue);
		break;
	case "m_flFuse":
		m_flFuse = ReadFloat(strValue);
		break;
	case "m_bDetonateOnFuse":
		m_bDetonateOnFuse = ReadBool(strValue);
		break;
	case "m_bDetonateOnDeath":
		m_bDetonateOnDeath = ReadBool(strValue);
		break;
	case "m_bDetonateOnWorld":
		m_bDetonateOnWorld = ReadBool(strValue);
		break;
	case "m_bDetonateOnActor":
		m_bDetonateOnActor = ReadBool(strValue);
		break;
	case "m_bImpactEffect":
		m_bImpactEffect = ReadBool(strValue);
		break;
	case "m_bImpactGib":
		m_bImpactGib = ReadBool(strValue);
		break;
	case "m_matDetonate":
		m_matDetonate = ReadString(strValue);
		break;
	case "m_flDecalSize":
		m_flDecalSize = ReadFloat(strValue);
		break;
	case "m_partSmokeFly":
		m_partSmokeFly = ReadString(strValue);
		break;
	case "m_partFXPath":
		m_partFXPath = ReadString(strValue);
		break;
	case "m_partModelDetonate":
		m_partModelDetonate = ReadString(strValue);
		break;
	case "m_partSmokeDetonate":
		m_partSmokeDetonate = ReadString(strValue);
		break;
	case "m_partSmokeBounce":
		m_partSmokeBounce = ReadString(strValue);
		break; 
	case "m_partSmokeFuse":
		m_partSmokeFuse = ReadString(strValue);
		break;
	case "m_defProjectileDebris":
		m_defProjectileDebris = ReadString(strValue);
		break;
	case "m_iDebrisCount":
		m_iDebrisCount = ReadInt(strValue);
		break;
	case "m_vecLightColor":
		m_vecLightColor = ReadVector(strValue);
		break;
	case "m_flLightRadius":
		m_flLightRadius = ReadFloat(strValue);
		break;
	case "m_flLightOffset":
		m_flLightOffset = ReadFloat(strValue);
		break;
	case "m_vecExplodeLightColor":
		m_vecExplodeLightColor = ReadVector(strValue);
		break;
	case "m_fExplodelLightRadius":
		m_fExplodelLightRadius = ReadFloat(strValue);
		break;
	case "m_fExplodelLightFadetime":
		m_fExplodelLightFadetime = ReadFloat(strValue);
		break;
	case "m_sndFly":
		m_sndFly = ReadString(strValue);
		break;
	case "m_sndExplode":
		m_sndExplode = ReadString(strValue);
		break;
	case "m_sndBounce":
		m_sndBounce = ReadString(strValue);
		break;
	case "m_bIsBullet":
		m_bIsBullet = ReadBool(strValue);
		break;
	case "m_bStickToWorld":
		m_bStickToWorld = ReadBool(strValue);
		break;
	case "m_bStickToActor":
		m_bStickToActor = ReadBool(strValue);
		break;
	case "m_vecSpawnMins":
		m_vecSpawnMins = ReadVector(strValue);
		break;
	case "m_vecSpawnMaxs":
		m_vecSpawnMaxs = ReadVector(strValue);
		break;
	case "m_bThrustHoming":
		m_bThrustHoming = ReadBool(strValue);
		break;
	case "m_thrustHandler":
		m_thrustHandler = (ncTimer)ReadEntity(strValue);
		break;
	case "m_flSpawnFrame":
		m_flSpawnFrame = ReadFloat(strValue);
		break;
	case "m_bInheritVelocity":
		m_bInheritVelocity = ReadBool(strValue);
		break;
	case "m_bThrown":
		m_bThrown = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

void
ncProjectile::Trigger(entity theActivator, triggermode_t theMode)
{
	_Explode(this);
}

void
ncProjectile::Spawned(void)
{
	super::Spawned();

	SetMovetype(MOVETYPE_FLYMISSILE);
	SetSolid(SOLID_BBOX);
	SetSize(m_vecSpawnMins, m_vecSpawnMaxs);
}

void
ncProjectile::Touch(entity eToucher)
{
	m_vecImpactPos = trace_endpos;

	if (eToucher == world && m_bReflect) {
		vector currentAngle = GetAngles();
		currentAngle[0] *= -1;
		vector currentVelocity = anglesToForward(currentAngle);
		SetMovetype(MOVETYPE_FLYMISSILE);
		SetVelocity(reflect(currentVelocity, trace_plane_normal) * m_vecLaunchVelocity[0]);
		SetAngles(vectoangles(GetVelocity()));
		SetOrigin(GetOrigin() + (anglesToForward(GetAngles() * 2.0f)));
		StartSoundDef(m_sndBounce, CHAN_BODY, true);
		return;
	}

	if (eToucher.takedamage != DAMAGE_NO) {
		m_hitLocation = m_vecImpactPos;
		m_eMultiTarget = eToucher;
		m_iMultiValue = GetSubDefInt(m_defDamage, "damage");
		_ApplyDamage();
	}

	if (m_bDetonateOnWorld) {
		if (eToucher == world || eToucher.takedamage == DAMAGE_NO) {
			_Explode(eToucher);
			return;
		}
	}
	if (m_bDetonateOnActor) {
		if (eToucher.takedamage != DAMAGE_NO) {
			_Explode(eToucher);
			return;
		}
	}

	if (m_bStickToWorld && eToucher == world) {
		SetMovetype(MOVETYPE_NONE);
	} else if (m_bStickToActor && eToucher.takedamage != DAMAGE_NO) {
		SetMovetype(MOVETYPE_NONE);
	}

	if (m_partSmokeBounce)
		pointparticles(particleeffectnum(m_partSmokeBounce), origin, velocity, 1);

	StartSoundDef(m_sndBounce, CHAN_BODY, true);
}

void
ncProjectile::Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	/* do nothing. */
}

void
ncProjectile::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	if (m_bDetonateOnDeath) {
		_Explode(this);
		return;
	}

	/* whatever else comes otherwise? */
	Destroy();
}

void
ncProjectile::SetLightColor(vector newColor)
{
	m_vecLightColor = newColor;
}

void
ncProjectile::SetLightRadius(float newRadius)
{
	m_flLightRadius = newRadius;
}

void
ncProjectile::SetWeaponOwner(ncWeapon weaponOwner)
{
	m_weaponOwner = weaponOwner;
}

ncWeapon
ncProjectile::GetWeaponOwner(void)
{
	return (m_weaponOwner);
}

void
ncProjectile::EnableDetonateOnFuse(bool enabled)
{
	m_bDetonateOnFuse = enabled;
}

void
ncProjectile::EnableDetonateOnDeath(bool enabled)
{
	m_bDetonateOnDeath = enabled;
}

void
ncProjectile::EnableDetonateOnWorld(bool enabled)
{
	m_bDetonateOnWorld = enabled;
}

void
ncProjectile::EnableDetonateOnActor(bool enabled)
{
	m_bDetonateOnActor = enabled;
}

void
ncProjectile::EnableStickToWorld(bool enabled)
{
	m_bStickToWorld = enabled;
}

void
ncProjectile::EnableStickToActor(bool enabled)
{
	m_bStickToActor = enabled;
}

void
ncProjectile::EnableThrustHoming(bool enabled)
{
	m_bThrustHoming = enabled;
}

void
ncProjectile::EnableInheritVelocity(bool enabled)
{
	m_bInheritVelocity = enabled;
}

void
ncProjectile::SetImpact(void(entity a,entity b) func)
{
	m_pImpact = func;
	Spawned();
}

void
ncProjectile::_AnimateThink(void)
{
	SetFrame(frame + 1);

	if (frame > (float)m_iProjectileAnimEnd) {
		SetFrame(m_iProjectileAnimStart);
	}

	ScheduleThink(_AnimateThink, m_flProjectileFramerate);
}

void
ncProjectile::_AnimateThinkDead(void)
{
	SetFrame(frame + 1);

	if (frame > (float)m_iProjectileAnimEnd) {
		Destroy();
		return;
	}

	ScheduleThink(_AnimateThinkDead, m_flProjectileFramerate);
}

void
ncProjectile::Animate(int startframe, int endframe, float framerate)
{
	m_iProjectileAnimStart = startframe;
	m_iProjectileAnimEnd = endframe;
	m_flProjectileFramerate = framerate;
	SetFrame(startframe);
	ScheduleThink(_AnimateThink, m_flProjectileFramerate);
}

void
ncProjectile::AnimateOnce(int startframe, int endframe, float framerate)
{
	m_iProjectileAnimStart = startframe;
	m_iProjectileAnimEnd = endframe;
	m_flProjectileFramerate = framerate;
	SetFrame(startframe);
	ScheduleThink(_AnimateThinkDead, m_flProjectileFramerate);
}

void
ncProjectile::_FuseEnded(void)
{
	if (m_bDetonateOnFuse) {
		_Explode(this);
		return;
	}

	if (m_partSmokeFuse) {
		pointparticles(particleeffectnum(m_partSmokeFuse), origin, velocity, 1);
	}

	Destroy();
}

void
ncProjectile::HasExploded(void)
{

}

void
ncProjectile::_Explode(entity explodedOn)
{
	vector newAngles, aimFwd, aimRgt, aimUp;
	vector debrisPos;
	vector damagePos;
	vector detonatePos;
	vector debrisOffset = g_vec_null;
	vector detonateOffset = g_vec_null;
	vector damageOffset = g_vec_null;
	vector debrisAngle = GetAngles();

	if (length(trace_plane_normal) == 0) {
		newAngles = vectorToAngles(GetVelocity());
	} else {
		newAngles = vectorToAngles(trace_plane_normal);
	}

	aimFwd = anglesToForward(newAngles);
	aimRgt = anglesToRight(newAngles);
	aimUp = anglesToUp(newAngles);

	debrisOffset = (aimFwd * m_vecDebrisOffset[0]);
	debrisOffset += (aimRgt * m_vecDebrisOffset[1]);
	debrisOffset += (aimUp * m_vecDebrisOffset[2]);

	detonateOffset = (aimFwd * m_vecDetonateOffset[0]);
	detonateOffset += (aimRgt * m_vecDetonateOffset[1]);
	detonateOffset += (aimUp * m_vecDetonateOffset[2]);

	damageOffset = (aimFwd * m_vecDamageOffset[0]);
	damageOffset += (aimRgt * m_vecDamageOffset[1]);
	damageOffset += (aimUp * m_vecDamageOffset[2]);

	debrisPos = m_vecImpactPos + debrisOffset;
	detonatePos = m_vecImpactPos + detonateOffset;
	damagePos = m_vecImpactPos + damageOffset;

	if (m_fExplodelLightRadius > 0.0f) {
		te_customflash(detonatePos, m_fExplodelLightRadius, m_fExplodelLightFadetime, m_vecExplodeLightColor);
	}

	if (STRING_SET(m_matDetonate)) {
		DecalGroups_Place(m_matDetonate, m_vecImpactPos);
	}

	if (STRING_SET(m_partModelDetonate)) {
		pointparticles(particleeffectnum(m_partModelDetonate), detonatePos, trace_plane_normal, 1);
	}

	if (STRING_SET(m_defSplashDamage)) {
		float flDamage = GetSubDefFloat(m_defSplashDamage, "damage");
		float flMinDamage = GetSubDefFloat(m_defSplashDamage, "damage_min");
		float flRadius = GetSubDefFloat(m_defSplashDamage, "radius");
		float flPushForce = 0.0f;

		if (m_flDmgMultiplier >= 0.0) {
			flDamage *= m_flDmgMultiplier;
		}

		combat.RadiusDamage(damagePos, flRadius, (int)flMinDamage, (int)flDamage, owner, m_defSplashDamage);
	}

	/* another def that'll be spawned when this one detonates */
	if (STRING_SET(m_defProjectileDebris) && !explodedOn && explodedOn != this) {
		float movementAmount = 360.0f / (float)m_iDebrisCount;

		for (int i = 0; i < m_iDebrisCount; i++) {
			ncProjectile_SpawnDefAtPosition(m_defProjectileDebris, (ncActor)owner, debrisPos, debrisAngle);
			debrisAngle[1] += movementAmount;
		}
	}

	if (STRING_SET(m_defPlaneImpact)) {
		vector portalAngle;
		vector coPlanar;
		makevectors(GetAngles());
		coPlanar = v_forward -(v_forward * trace_plane_normal) * trace_plane_normal;

		/* quick fix */
		if (trace_plane_normal[2] == 0) {
			coPlanar = '0 0 1';
		}

		portalAngle = vectoangles(trace_plane_normal, coPlanar);
#if 1
		prop_portal_spawn(trace_endpos, portalAngle, owner, m_defPlaneImpact == "portal_red" ? true : false);
#else
		ncEntity rocket = EntityDef_NewClassname(m_defPlaneImpact);
		rocket.SetOrigin(trace_endpos);
		rocket.SetAngles(portalAngle);
		rocket.owner = this;
		rocket.Spawn();
#endif
	}

	HasExploded();
	StartSoundDef(m_sndExplode, CHAN_VOICE, true);
	Destroy();
}

void
ncProjectile::_LaunchHitscan(vector startPos, vector launchDir, float dmgMultiplier)
{
	vector vecDir;

	m_eMultiTarget = __NULL__;
	m_iMultiValue = 0;

	if (STRING_SET(m_defDamage)) {
		m_flDamage = GetSubDefFloat(m_defDamage, "damage");
	}

	while (m_iShots > 0) {
		vecDir = anglesToForward(launchDir);
		vecDir += random(-1,1) * m_vecSpread[0] * anglesToRight(launchDir);
		vecDir += random(-1,1) * m_vecSpread[1] * anglesToUp(launchDir);
		_FireSingle(startPos, vecDir, m_flDamage, m_flRange);
		m_iShots--;
	}

	if (m_eMultiTarget) {
		angles = launchDir;
		_ApplyDamage();
	}
	Destroy();
}

void
ncProjectile::_ApplyDamage(void)
{
	/* may not be defined yet */
	if (m_eMultiTarget == __NULL__) {
		return;
	}

	/* the location _could_ be more accurate... */
	if (m_eMultiTarget.CanBleed() == true) {
		ncSurfacePropEntity targetEnt = (ncSurfacePropEntity)m_eMultiTarget;

		if (targetEnt.HasSurfaceData()) {
			SurfData_ImpactOfType(targetEnt.m_iMaterial, m_hitLocation, trace_plane_normal);
		}
	}

	trace_surface_id = m_iMultiBody;
	ncDict damageDecl; 

	if (STRING_SET(m_defDamage)) {
		int declID = EntityDef_IDFromName(m_defDamage);
		damageDecl = ncDict::InitWithSpawnData(EntityDef_GetSpawnData(declID));
	} else {
		damageDecl = spawn(ncDict);
	}

	string weaponName = GetWeaponOwner().classname;

	damageDecl.AddKey("hitbody", itos(trace_surface_id));
	damageDecl.AddKey("damage", itos(m_iMultiValue));

	if (STRING_SET(weaponName)) {
		damageDecl.AddKey("weapon", GetWeaponOwner().classname);
	}

	string pushString = GetSubDefString(m_defDamage, "push");
	float pushForce = 0.0f;

	if (STRING_SET(pushString)) {
		pushForce = stof(pushString);
	} else {
		pushForce = (float)m_iMultiValue * 25.0f;
	}

	damageDecl.AddKey("push", ftos(pushForce));
	damageDecl.AddKey("location", vtos(m_hitLocation));
	vector dmgDir = anglesToForward(angles);
	m_eMultiTarget.Damage(this, owner, damageDecl, m_flDmgMultiplier, vectorNormalize(angles), m_hitLocation);
	remove(damageDecl);

	m_eMultiTarget = __NULL__;
	m_iMultiValue = 0;
	m_iMultiBody = 0;
}

void
ncProjectile::_FireSingle(vector vecPos, vector vecAngles, float flDamage, float flRange)
{
	vector range;
	vector planeNormal;
	bool skipFX = m_noFX;

	if (flRange <= 0) {
		return;
	}

	if (flDamage < 1) {
		return;
	}

	#warning TODO: add bubble trail when underwater

	range = (vecAngles * m_flRange);
	owner.dimension_solid = 255;
	owner.dimension_hit = 255;

	/* make sure we can gib corpses */
	int oldhitcontents = owner.hitcontentsmaski;
	owner.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE | CONTENTBIT_WATER | CONTENTBIT_SLIME | CONTENTBIT_LAVA | CONTENTBIT_PROJECTILE;
	traceline(vecPos, vecPos + range, MOVE_LAGGED | MOVE_HITMODEL, owner);
	owner.hitcontentsmaski = oldhitcontents;
	planeNormal = trace_plane_normal;
	m_hitLocation = trace_endpos;

	flRange -= distance(vecPos, m_hitLocation);

	owner.dimension_solid = 254;
	owner.dimension_hit = 254;

	m_iMultiBody |= trace_surface_id;

	if (STRING_SET(m_partFXPath)) {
		trailparticles(particleeffectnum(m_partFXPath), world, vecPos, trace_endpos);
	}

	if (trace_fraction >= 1.0f) {
		return;
	}

	/* water impact */
	if (trace_endcontentsi & CONTENTBIT_WATER) {
		SurfData_ImpactOfNamedType("water", m_hitLocation, planeNormal);
		_FireSingle(m_hitLocation + ((vecAngles) * 2), vecAngles, flDamage / 2, flRange);
		skipFX = true;
	} else if (trace_endcontentsi & CONTENTBIT_SLIME) {
		SurfData_ImpactOfNamedType("slime", m_hitLocation, planeNormal);
		_FireSingle(m_hitLocation + ((vecAngles) * 2), vecAngles, flDamage / 2, flRange);
		skipFX = true;
	} else if (trace_endcontentsi & CONTENTBIT_LAVA) {
		SurfData_ImpactOfNamedType("lava", m_hitLocation, planeNormal);
		_FireSingle(m_hitLocation + ((vecAngles) * 2), vecAngles, flDamage / 2, flRange);
		skipFX = true;
	}

	if (trace_ent.takedamage != DAMAGE_NO && trace_ent.iBleeds) {
		Sound_Play(trace_ent, CHAN_BODY, "damage_bullet.hit");

		/* only headshots count in HL */
		if (trace_surface_id == BODY_HEAD)
			flDamage *= 3;
	}

#ifdef WASTES
	TWPlayer pl1 = (TWPlayer)owner;
	if (pl1.m_iWillpowerValue > 0) {
		FX_Crit(m_hitLocation, vectoangles(m_hitLocation - pl1.origin), 0);
	}
#endif

	/* impact per bullet */
	if (m_bDetonateOnWorld == true && trace_ent.iBleeds == 0 && skipFX == false) {
		StartSoundDef(m_sndExplode, CHAN_VOICE, true);
	
		if (m_strDecalGroup)
			DecalGroups_Place(m_strDecalGroup, m_hitLocation + (vecAngles * -2));

		SurfData_Impact(trace_ent, m_hitLocation, planeNormal);
	}

	/* combine them into one single Damage_Apply call later */
	if (trace_ent.takedamage != DAMAGE_NO) {
		if (trace_ent != m_eMultiTarget) {
			angles = vecAngles;
			_ApplyDamage();
			m_eMultiTarget = (ncSurfacePropEntity)trace_ent;
			m_iMultiValue = flDamage;
		} else {
			m_iMultiValue += flDamage;
		}
	}
}

void
ncProjectile::_ThrustThink(void)
{
	vector currentVelocity;
	float currentSpeed;
	float newSpeed;
	vector newVelocity;

	currentVelocity = GetVelocity();
	currentSpeed = vlen(currentVelocity);
	newSpeed = (currentSpeed + (m_flThrust * frametime));

	/* homing mode */
	if (m_bThrustHoming) {
		vector ownerPos;
		vector endPos;
		ncSurfacePropEntity projectileOwner = (ncSurfacePropEntity)GetOwner();
		ownerPos = projectileOwner.GetEyePos();
		makevectors(projectileOwner.GetViewAngle());
		endPos = ownerPos + (v_forward * 4096.0f);
		traceline(ownerPos, endPos, MOVE_NORMAL, projectileOwner);
		SetAngles(vectoangles(trace_endpos - GetOrigin()));
	} else if (m_bTrackEnemy) {

		if (m_trackDelayTime > time) {
			ncMonster monOwner = (ncMonster)owner;
			vector angleToTarget = vectoangles(monOwner.m_eEnemy.origin - GetOrigin());
			angleToTarget[0] += random(-m_trackJitter[0],m_trackJitter[0]);
			angleToTarget[1] += random(-m_trackJitter[1],m_trackJitter[1]);
			angleToTarget[2] += random(-m_trackJitter[2],m_trackJitter[2]);
			SetAngles(angleToTarget);
		}

		m_trackDelayTime = time + m_trackDelay;
	}

	makevectors(GetAngles());
	newVelocity = v_forward * (newSpeed);

	/* prevent thrusting early */
	if ((m_flThrustStart > 0) && GetSpawnAge() < m_flThrustStart) {
		return;
	}

	/* stop thrusting when we reach the end time */
	if ((m_flThrustEnd > 0) && (GetSpawnAge() > m_flThrustEnd)) {
		m_thrustHandler.Destroy(); /* invalidate */
		return;
	}

	SetVelocity(newVelocity);
}

void
ncProjectile::OnRemoveEntity(void)
{
}

void
ncProjectile::Launch(vector startPos, vector launchDir, float fuseOffset, float powerMultiplier, float dmgMultiplier)
{
	vector moveVel = g_vec_null;
	vector projPos = g_vec_null;
	SetAngles(launchDir);
	SetSize(m_vecSpawnMins, m_vecSpawnMaxs);

	if (dmgMultiplier <= 0.0) {
		dmgMultiplier = 1.0f;
	}

	if (powerMultiplier <= 0.0) {
		powerMultiplier = 1.0f;
	}

	m_flDmgMultiplier = dmgMultiplier;

	/* convert absolute vel from def into relative */
	moveVel = (m_vecLaunchVelocity[0] * powerMultiplier) * anglesToForward(launchDir);
	moveVel += (m_vecLaunchVelocity[1] * powerMultiplier) * anglesToRight(launchDir);
	moveVel += (m_vecLaunchVelocity[2] * powerMultiplier) * anglesToUp(launchDir);

	projPos = startPos;
	projPos += v_forward * m_vecSpawnOrigin[0];
	projPos += v_right * m_vecSpawnOrigin[1];
	projPos += v_up * m_vecSpawnOrigin[2];

	/* prevent from spawning in-walls */
	traceline(startPos, projPos, MOVE_NORMAL, owner);
	startPos = trace_endpos;
	SetOrigin(startPos);

	if (m_bIsBullet) {
		_LaunchHitscan(startPos, launchDir, dmgMultiplier);
		return;
	}

	if (m_bInheritVelocity == true) {
		moveVel += owner.velocity;
	}

	if (m_bThrown) {
		vector throwDirection;
		float throwingStrength;

		throwDirection = launchDir;
		throwDirection[0] = -10.0f; /* always aim a bit up */

		/* diminish when aiming up */
		if (launchDir[0] < 0) {
			throwDirection[0] += (launchDir[0] * 0.9f);
		} else { /* increase when aiming down */
			throwDirection[0] += (launchDir[0] * 1.1f);
		}

		throwingStrength = bound(0, (90 - throwDirection[0]) * 5.0f, 1000);
		moveVel = (v_forward * throwingStrength) + owner.velocity;
	}

	/* fire slower underwater */
	if (pointcontents(startPos) == CONTENT_WATER) {
		SetVelocity(moveVel / 10);
	} else {
		SetVelocity(moveVel);
	}

	SetAngularVelocity(avelocity);
	SetHealth(health);
	SetSolid(SOLID_BBOX);
	//SetRenderMode(RM_ADDITIVE);

	if (m_flBounce > 0) {
		SetMovetype(MOVETYPE_BOUNCE);
	} else {
		SetMovetype(MOVETYPE_FLYMISSILE);
	}

	if (STRING_SET(m_partSmokeFly)) {
		traileffectnum = particleeffectnum(m_partSmokeFly);
	}

	if (GetHealth() > 0) {
		MakeVulnerable();
	} else {
		MakeInvulnerable();
	}

	if (m_flFuse > 0.0f) {
		/* quit early */
		if ((m_flFuse - fuseOffset)<= 0.0f) {
			m_vecImpactPos = startPos;
			_Explode(owner);
			return;
		}

		ScheduleThink(_FuseEnded, m_flFuse - fuseOffset);
	}

	if (m_flThrust != 0 || m_bTrackEnemy == true) {
		m_thrustHandler = ncTimer::TemporaryTimer(this, _ThrustThink, 0.0, true);
	}

	string startFrame = GetSpawnString("animStartFrame");

	if (STRING_SET(startFrame)) {
		int iStartFrame = stoi(startFrame);
		int iEndFrame = GetSpawnInt("animEndFrame");
		float flFrameRate = (1 / GetSpawnFloat("animFrameRate"));
		bool animEndRemoves = GetSpawnInt("animEndRemoves");

		SetFrame((float)iStartFrame);
		
		if (animEndRemoves) {
			AnimateOnce(iStartFrame, iEndFrame, flFrameRate);
		} else {
			Animate(iStartFrame, iEndFrame, flFrameRate);
		}
	} else {
		SetFrame(m_flSpawnFrame);
	}

	SetGravity(m_flGravity);
	StartSoundDef(m_sndFly, CHAN_BODY, true);
	SendFlags = (-1);
	//SendEntity = 0; /* HACK: remove this once Spike fixes CSQC-set traileffectnum etc. */
}

void
ncProjectile::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, PROJ_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, PROJ_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, PROJ_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, PROJ_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, PROJ_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, PROJ_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, PROJ_CHANGED_MODELINDEX)
	EVALUATE_FIELD(frame, PROJ_CHANGED_MODELINDEX)
	EVALUATE_FIELD(traileffectnum, PROJ_CHANGED_MODELINDEX)
	EVALUATE_FIELD(m_iRenderMode, PROJ_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_iRenderFX, PROJ_CHANGED_RENDERMODE)
	EVALUATE_VECTOR(m_vecRenderColor, 0, PROJ_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, PROJ_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, PROJ_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flRenderAmt, PROJ_CHANGED_RENDERAMT)
	EVALUATE_VECTOR(m_vecLightColor, 0, PROJ_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecLightColor, 1, PROJ_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecLightColor, 2, PROJ_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flLightRadius, PROJ_CHANGED_RENDERAMT)
}

/* Make sure StartFrame calls this */
float
ncProjectile::SendEntity(entity ePEnt, float flChanged)
{
	if (m_bIsBullet == true) {
		return (false);
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (false);
	}

	WriteByte(MSG_ENTITY, ENT_ENTITYPROJECTILE);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], PROJ_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], PROJ_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], PROJ_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], PROJ_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], PROJ_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], PROJ_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, PROJ_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(frame, PROJ_CHANGED_MODELINDEX)
	SENDENTITY_FLOAT(traileffectnum, PROJ_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(m_iRenderMode, PROJ_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, PROJ_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_vecRenderColor[0], PROJ_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_vecRenderColor[1], PROJ_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_vecRenderColor[2], PROJ_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_flRenderAmt, PROJ_CHANGED_RENDERAMT)
	SENDENTITY_COLOR(m_vecLightColor[0], PROJ_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecLightColor[1], PROJ_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecLightColor[2], PROJ_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(m_flLightRadius, PROJ_CHANGED_RENDERAMT)

	return (1);
}
#endif

.float emiteffectnum;
#ifdef CLIENT
void
ncProjectile::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], PROJ_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], PROJ_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], PROJ_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], PROJ_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], PROJ_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], PROJ_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, PROJ_CHANGED_MODELINDEX)
	READENTITY_BYTE(frame, PROJ_CHANGED_MODELINDEX)
	READENTITY_FLOAT(traileffectnum, PROJ_CHANGED_MODELINDEX)
	READENTITY_BYTE(m_iRenderMode, PROJ_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, PROJ_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_vecRenderColor[0], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_vecRenderColor[1], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_vecRenderColor[2], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_flRenderAmt, PROJ_CHANGED_RENDERAMT)
	READENTITY_COLOR(m_vecLightColor[0], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecLightColor[1], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecLightColor[2], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(m_flLightRadius, PROJ_CHANGED_RENDERAMT)
	setmodelindex(this, modelindex);
	drawmask = MASK_ENGINE;
}

void
ncProjectile::postdraw(void)
{
#if 1
	if (m_flLightRadius > 0.0) {
		env_sun_lensflare(origin, 1.0f, m_vecLightColor, false);
	}
#endif
}

float
ncProjectile::predraw(void)
{
	if (m_flLightRadius > 0.0f) {
		dynamiclight_add(origin, m_flLightRadius, m_vecLightColor);
	}

	if (traileffectnum) {
		if (oldorigin != g_vec_null)
			trailparticles(traileffectnum, this, oldorigin, origin);
	}
	oldorigin = origin;
	
	return ncRenderableEntity::predraw();
}
#endif

#ifdef SERVER
ncProjectile
ncProjectile_SpawnDef(string entityDef, ncActor theOwner)
{
	entity oldself = self;

	ncProjectile rocket = spawn(ncProjectile);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.SetWeaponOwner(theOwner.m_activeWeapon);
	rocket.Launch(theOwner.GetEyePos(), theOwner.GetViewAngle(), 0.0f, 0.0f, 0.0f);
	return rocket;
}

ncProjectile
ncProjectile_SpawnDefAtPosition(string entityDef, ncActor theOwner, vector vecOrigin, vector vecAngles)
{
	entity oldself = self;
	ncProjectile rocket = spawn(ncProjectile);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.SetWeaponOwner(theOwner.m_activeWeapon);
	rocket.Launch(vecOrigin, vecAngles, 0.0f, 0.0f, 0.0f);
	return rocket;
}

ncProjectile
ncProjectile_SpawnDefAttachment(string entityDef, ncActor theOwner, int attachmentID)
{
	entity oldself = self;
	float skeletonIndex = skel_create(theOwner.modelindex);
	vector attachmentPos =  gettaginfo(theOwner, skel_get_numbones(skeletonIndex) + attachmentID);
	skel_delete(skeletonIndex);

	ncProjectile rocket = spawn(ncProjectile);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.SetWeaponOwner(theOwner.m_activeWeapon);
	rocket.Launch(attachmentPos, theOwner.GetViewAngle(), 0.0f, 0.0f, 0.0f);
	return rocket;
}
#endif
