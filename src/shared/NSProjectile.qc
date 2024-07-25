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
NSProjectile::NSProjectile(void)
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
	m_partModelDetonate = __NULL__;
	m_partSmokeDetonate = __NULL__;
	m_partSmokeBounce = __NULL__;
	m_partSmokeFuse = __NULL__;
	m_iDebrisCount = 0i;
	m_bDebrisStick = false;
	m_vecDebrisOffset = g_vec_null;
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
	m_flRange = 4096.0f;


	/* Nuclide additions */
	m_bStickToWorld = false;
	m_bStickToActor = false;
	m_bThrustHoming = false;
	m_bInheritVelocity = false;
#endif
}

#ifdef SERVER
void
NSProjectile::SpawnKey(string strKey, string strValue)
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
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSProjectile::Save(float handle)
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
}

void
NSProjectile::Restore(string strKey, string strValue)
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
		m_thrustHandler = (NSTimer)ReadEntity(strValue);
		break;
	case "m_flSpawnFrame":
		m_flSpawnFrame = ReadFloat(strValue);
		break;
	case "m_bInheritVelocity":
		m_bInheritVelocity = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

void
NSProjectile::Trigger(entity theActivator, triggermode_t theMode)
{
	_Explode();
}

void
NSProjectile::Spawned(void)
{
	super::Spawned();

	SetMovetype(MOVETYPE_FLYMISSILE);
	SetSolid(SOLID_BBOX);
	SetSize(m_vecSpawnMins, m_vecSpawnMaxs);
}

void
NSProjectile::Touch(entity eToucher)
{
	m_vecImpactPos = trace_endpos;

	if (eToucher.takedamage != DAMAGE_NO) {
		NSSurfacePropEntity toucher = (NSSurfacePropEntity)eToucher;
		NSDict damageDecl = spawn(NSDict);
		damageDecl.AddKey("damage", GetSubDefString(m_defDamage, "damage"));
		toucher.Damage(this, owner, damageDecl, m_flDmgMultiplier, vectorNormalize(angles), trace_endpos);
		remove(damageDecl);
	}

	if (m_bDetonateOnWorld) {
		if (eToucher == world || eToucher.takedamage == DAMAGE_NO) {
			_Explode();
			return;
		}
	}
	if (m_bDetonateOnActor) {
		if (eToucher.takedamage != DAMAGE_NO) {
			_Explode();
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
NSProjectile::Pain(entity inflictor, entity attacker, int damage, vector dir, int location)
{
	/* do nothing. */
}

void
NSProjectile::Death(entity inflictor, entity attacker, int damage, vector dir, int location)
{
	if (m_bDetonateOnDeath) {
		_Explode();
		return;
	}

	/* whatever else comes otherwise? */
	Destroy();
}

void
NSProjectile::SetLightColor(vector newColor)
{
	m_vecLightColor = newColor;
}

void
NSProjectile::SetLightRadius(float newRadius)
{
	m_flLightRadius = newRadius;
}

void
NSProjectile::EnableDetonateOnFuse(bool enabled)
{
	m_bDetonateOnFuse = enabled;
}

void
NSProjectile::EnableDetonateOnDeath(bool enabled)
{
	m_bDetonateOnDeath = enabled;
}

void
NSProjectile::EnableDetonateOnWorld(bool enabled)
{
	m_bDetonateOnWorld = enabled;
}

void
NSProjectile::EnableDetonateOnActor(bool enabled)
{
	m_bDetonateOnActor = enabled;
}

void
NSProjectile::EnableStickToWorld(bool enabled)
{
	m_bStickToWorld = enabled;
}

void
NSProjectile::EnableStickToActor(bool enabled)
{
	m_bStickToActor = enabled;
}

void
NSProjectile::EnableThrustHoming(bool enabled)
{
	m_bThrustHoming = enabled;
}

void
NSProjectile::EnableInheritVelocity(bool enabled)
{
	m_bInheritVelocity = enabled;
}

void
NSProjectile::SetImpact(void(entity a,entity b) func)
{
	m_pImpact = func;
	Spawned();
}

void
NSProjectile::_AnimateThink(void)
{
	SetFrame(frame + 1);

	if (frame > (float)m_iProjectileAnimEnd)
		SetFrame(m_iProjectileAnimStart);

	think = _AnimateThink;
	nextthink = time + m_flProjectileFramerate;
}

void
NSProjectile::_AnimateThinkDead(void)
{
	SetFrame(frame + 1);

	if (frame > (float)m_iProjectileAnimEnd) {
		Destroy();
		return;
	}

	think = _AnimateThinkDead;
	nextthink = time + m_flProjectileFramerate;
}

void
NSProjectile::Animate(int startframe, int endframe, float framerate)
{
	m_iProjectileAnimStart = startframe;
	m_iProjectileAnimEnd = endframe;
	m_flProjectileFramerate = framerate;
	frame = startframe;
	think = _AnimateThink;
	nextthink = time + m_flProjectileFramerate;
}

void
NSProjectile::AnimateOnce(int startframe, int endframe, float framerate)
{
	m_iProjectileAnimStart = startframe;
	m_iProjectileAnimEnd = endframe;
	m_flProjectileFramerate = framerate;
	frame = startframe;
	think = _AnimateThinkDead;
	nextthink = time + m_flProjectileFramerate;
}

void
NSProjectile::_FuseEnded(void)
{
	if (m_bDetonateOnFuse) {
		_Explode();
		return;
	}

	if (m_partSmokeFuse) {
		pointparticles(particleeffectnum(m_partSmokeFuse), origin, velocity, 1);
	}


	Destroy();
}

void
NSProjectile::_Explode(void)
{
	vector newAngles, aimFwd, aimRgt, aimUp;
	vector debrisPos;
	vector debrisOffset = g_vec_null;
	vector explodePos = g_vec_null;
	vector debrisAngle = GetAngles();

	newAngles = vectorToAngles(GetVelocity());
	aimFwd = anglesToForward(newAngles);
	aimRgt = anglesToRight(newAngles);
	aimUp = anglesToUp(newAngles);

	debrisOffset = (aimFwd * m_vecDebrisOffset[0]);
	debrisOffset += (aimRgt * m_vecDebrisOffset[1]);
	debrisOffset += (aimUp * m_vecDebrisOffset[2]);

	if (m_bDebrisStick) {
		debrisPos = m_vecImpactPos + debrisOffset;
		explodePos = m_vecImpactPos;
	} else {
		debrisPos = explodePos + debrisOffset;
		explodePos = origin - (aimFwd * 32);
	}

	if (m_matDetonate) {
		DecalGroups_Place(m_matDetonate, origin);
	}

	if (m_partModelDetonate)
		pointparticles(particleeffectnum(m_partModelDetonate), explodePos, trace_plane_normal, 1);

	//print(sprintf("%S\n", m_defSplashDamage));
	if (m_defSplashDamage) {
		float flDamage = GetSubDefFloat(m_defSplashDamage, "damage");
		float flRadius = GetSubDefFloat(m_defSplashDamage, "radius");

		if (m_flDmgMultiplier >= 0.0)
			flDamage *= m_flDmgMultiplier;

		//print(sprintf("Damage: %d; Radius: %d\n", flDamage, flRadius));
		//Damage_Radius(origin, owner, flDamage, flRadius, TRUE, 0);
		radiusDamage(origin, flRadius, 0i, (int)flDamage, owner);
	}

	/* another def that'll be spawned when this one detonates */
	if (m_defProjectileDebris) {
		float movementAmount = 360.0f / (float)m_iDebrisCount;

		for (int i = 0; i < m_iDebrisCount; i++) {
			NSProjectile_SpawnDefAtPosition(m_defProjectileDebris, (NSEntity)owner, debrisPos, debrisAngle);
			debrisAngle[1] += movementAmount;
		}
	}

	StartSoundDef(m_sndExplode, CHAN_VOICE, true);
	Destroy();
}

void
NSProjectile::_LaunchHitscan(vector startPos, vector launchDir, float dmgMultiplier)
{
	vector vecDir;
	vector ownerAngle;
	vector ownerDir;

	m_eMultiTarget = __NULL__;
	m_iMultiValue = 0;

	ownerAngle = anglesToForward(launchDir);
	ownerDir = aim(owner, 100000);

	while (m_iShots > 0) {
		/* use cached value */
		v_forward = ownerAngle;

		if (owner.flags & FL_CLIENT) {
			vecDir = ownerDir;
		} else {
			vecDir = v_forward;
		}

		vecDir += random(-1,1) * m_vecSpread[0] * v_right;
		vecDir += random(-1,1) * m_vecSpread[1] * v_up;

		_FireSingle(startPos, vecDir, m_flDamage, m_flRange);
		m_iShots--;
	}

	if (m_eMultiTarget) {
		_ApplyDamage();
	}
}

void
NSProjectile::_ApplyDamage(void)
{
	/* may not be defined yet */
	if (m_eMultiTarget == __NULL__)
		return;

	/* the location _could_ be more accurate... */
	if (m_eMultiTarget.CanBleed() == true) {
		FX_Blood(trace_endpos, m_eMultiTarget.GetBloodColor());
	}

	trace_surface_id = m_iMultiBody;
	g_dmg_vecLocation = trace_endpos;
	NSDict damageDecl = spawn(NSDict);
	damageDecl.AddKey("damage", itos(m_iMultiValue));
	vector dmgDir = dirFromTarget(GetOrigin(), m_eMultiTarget.origin);

	entityDamage(m_eMultiTarget, owner, owner, damageDecl.GetDeclBody(), classname, GetOrigin(), dmgDir, trace_endpos);
	remove(damageDecl);

	m_eMultiTarget = __NULL__;
	m_iMultiValue = 0;
	m_iMultiBody = 0;
}


void
NSProjectile::_FireSingle(vector vecPos, vector vecAngles, float flDamage, float flRange)
{
	vector range;
	vector planeNormal;
	vector endPos;

	if (flRange <= 0)
		return;

	if (flDamage < 1)
		return;

	range = (vecAngles * 8196);

	owner.dimension_solid = 255;
	owner.dimension_hit = 255;

	/* make sure we can gib corpses */
	int oldhitcontents = owner.hitcontentsmaski;
	owner.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE | CONTENTBIT_WATER | CONTENTBIT_SLIME | CONTENTBIT_LAVA | CONTENTBIT_PROJECTILE;
	traceline(vecPos, vecPos + range, MOVE_LAGGED | MOVE_HITMODEL, owner);
	owner.hitcontentsmaski = oldhitcontents;
	planeNormal = trace_plane_normal;
	endPos = trace_endpos;

	flRange -= trace_plane_dist;

	owner.dimension_solid = 254;
	owner.dimension_hit = 254;

	m_iMultiBody |= trace_surface_id;

	if (trace_fraction >= 1.0f)
		return;

	/* water impact */
	if (trace_endcontentsi & CONTENTBIT_WATER) {
		SurfData_ImpactOfNamedType("water", endPos, planeNormal);
		_FireSingle(endPos + (v_forward * 2), vecAngles, flDamage / 2, flRange);
	} else if (trace_endcontentsi & CONTENTBIT_SLIME) {
		SurfData_ImpactOfNamedType("slime", endPos, planeNormal);
		_FireSingle(endPos + (v_forward * 2), vecAngles, flDamage / 2, flRange);
	} else if (trace_endcontentsi & CONTENTBIT_LAVA) {
		SurfData_ImpactOfNamedType("lama", endPos, planeNormal);
		_FireSingle(endPos + (v_forward * 2), vecAngles, flDamage / 2, flRange);
	}

	if (trace_ent.takedamage != DAMAGE_NO && trace_ent.iBleeds) {
		Sound_Play(trace_ent, CHAN_BODY, "damage_bullet.hit");

#ifdef CSTRIKE
		NSClientPlayer pl = (NSClientPlayer)trace_ent;
		/* modify the damage based on the location */
		switch (trace_surface_id) {
		case BODY_HEAD:
			/* the helmet is one power house */
			if (pl.g_items & ITEM_HELMET) {
				flDamage = 0;
				Sound_Play(trace_ent, CHAN_BODY, "player.headshotarmor");
				pl.g_items &= ~ITEM_HELMET;
				return;
			} else {
				flDamage *= 4;
				Sound_Play(trace_ent, CHAN_BODY, "player.headshot");
			}
			break;
		case BODY_STOMACH:
			flDamage *= 0.9;
			if (pl.armor > 0)
				Sound_Play(trace_ent, CHAN_BODY, "player.hitarmor");
			break;
		case BODY_LEGLEFT:
		case BODY_LEGRIGHT:
			flDamage *= 0.4;
			break;
		}
#else
		/* only headshots count in HL */
		if (trace_surface_id == BODY_HEAD)
			flDamage *= 3;
#endif
	}

#ifdef WASTES
	TWPlayer pl1 = (TWPlayer)self;
	if (pl1.m_iWillpowerValue > 0) {
		FX_Crit(endPos, vectoangles(endPos - pl1.origin), 0);
	}
#endif

	/* impact per bullet */
	if (m_bDetonateOnWorld == true && trace_ent.iBleeds == 0) {
		if (m_strDecalGroup)
			DecalGroups_Place(m_strDecalGroup, endPos + (vecAngles * -2));

		SurfData_Impact(trace_ent, endPos, planeNormal);
	}

	/* combine them into one single Damage_Apply call later */
	if (trace_ent.takedamage != DAMAGE_NO) {
		if (trace_ent != m_eMultiTarget) {
			trace_endpos = endPos;
			_ApplyDamage();
			m_eMultiTarget = (NSSurfacePropEntity)trace_ent;
			m_iMultiValue = flDamage;
		} else {
			m_iMultiValue += flDamage;
		}
	}
}

void
NSProjectile::_ThrustThink(void)
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
		NSSurfacePropEntity projectileOwner = (NSSurfacePropEntity)GetOwner();
		ownerPos = projectileOwner.GetEyePos();
		makevectors(projectileOwner.GetViewAngle());
		endPos = ownerPos + (v_forward * 4096.0f);
		traceline(ownerPos, endPos, MOVE_NORMAL, projectileOwner);
		SetAngles(vectoangles(trace_endpos - GetOrigin()));
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
NSProjectile::OnRemoveEntity(void)
{
}

void
NSProjectile::Launch(vector startPos, vector launchDir, float fuseOffset, float powerMultiplier, float dmgMultiplier)
{
	vector moveVel = g_vec_null;

	if (m_bIsBullet) {
		_LaunchHitscan(startPos, launchDir, dmgMultiplier);
		return;
	}

	SetAngles(launchDir);
	SetSize(m_vecSpawnMins, m_vecSpawnMaxs);

	if (dmgMultiplier <= 0.0)
		dmgMultiplier = 1.0f;

	if (powerMultiplier <= 0.0)
		powerMultiplier = 1.0f;

	m_flDmgMultiplier = dmgMultiplier;

	/* convert absolute vel from def into relative */
	makevectors(launchDir);
	moveVel = (m_vecLaunchVelocity[0] * powerMultiplier) * v_forward;
	moveVel += (m_vecLaunchVelocity[1] * powerMultiplier) * v_right;
	moveVel += (m_vecLaunchVelocity[2] * powerMultiplier) * v_up;

	startPos += v_forward * m_vecSpawnOrigin[0];
	startPos += v_right * m_vecSpawnOrigin[1];
	startPos += v_up * m_vecSpawnOrigin[2];
	SetOrigin(startPos);

	if (m_bInheritVelocity == true)
		moveVel += owner.velocity;

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

	if (m_partSmokeFly) {
		traileffectnum = particleeffectnum(m_partSmokeFly);
	}

	if (GetHealth() > 0) {
		SetTakedamage(DAMAGE_YES);
	} else {
		SetTakedamage(DAMAGE_NO);
	}

	if (m_flFuse > 0) {
		ScheduleThink(_FuseEnded, m_flFuse - fuseOffset);
	}

	if (m_flThrust != 0) {
		m_thrustHandler = NSTimer::TemporaryTimer(this, _ThrustThink, 0.0, true);
	}

	SetFrame(m_flSpawnFrame);
	SetGravity(m_flGravity);
	StartSoundDef(m_sndFly, CHAN_BODY, true);
	SendFlags = (-1);
	//SendEntity = 0; /* HACK: remove this once Spike fixes CSQC-set traileffectnum etc. */
}

void
NSProjectile::EvaluateEntity(void)
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
NSProjectile::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

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
	SENDENTITY_COLOR(m_vecRenderColor[0], PROJ_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[1], PROJ_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[2], PROJ_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_flRenderAmt, PROJ_CHANGED_RENDERAMT)
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
NSProjectile::ReceiveEntity(float flNew, float flChanged)
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
	READENTITY_COLOR(m_vecRenderColor[0], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[1], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[2], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_flRenderAmt, PROJ_CHANGED_RENDERAMT)
	READENTITY_COLOR(m_vecLightColor[0], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecLightColor[1], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecLightColor[2], PROJ_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(m_flLightRadius, PROJ_CHANGED_RENDERAMT)
	setmodelindex(this, modelindex);
	drawmask = MASK_ENGINE;
}

float
NSProjectile::predraw(void)
{
	if (m_flLightRadius > 0.0f) {
		dynamiclight_add(origin, m_flLightRadius, m_vecLightColor);
	}

	return super::predraw();
}
#endif

#ifdef SERVER
NSProjectile
NSProjectile_SpawnDef(string entityDef, NSEntity theOwner)
{
	entity oldself = self;

	NSProjectile rocket = spawn(NSProjectile);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;

	rocket.Launch(theOwner.GetEyePos(), theOwner.GetViewAngle(), 0.0f, 0.0f, 0.0f);
	return rocket;
}

NSProjectile
NSProjectile_SpawnDefAtPosition(string entityDef, NSEntity theOwner, vector vecOrigin, vector vecAngles)
{
	entity oldself = self;
	NSProjectile rocket = spawn(NSProjectile);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.Launch(vecOrigin, vecAngles, 0.0f, 0.0f, 0.0f);
	return rocket;
}

NSProjectile
NSProjectile_SpawnDefAttachment(string entityDef, NSEntity theOwner, int attachmentID)
{
	entity oldself = self;
	float skeletonIndex = skel_create(theOwner.modelindex);
	vector attachmentPos =  gettaginfo(theOwner, skel_get_numbones(skeletonIndex) + attachmentID);
	skel_delete(skeletonIndex);

	NSProjectile rocket = spawn(NSProjectile);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.Launch(attachmentPos, theOwner.GetViewAngle(), 0.0f, 0.0f, 0.0f);
	return rocket;
}
#endif
