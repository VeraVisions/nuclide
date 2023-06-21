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
	m_bDetonateOnFuse = 0.0f;
	m_bDetonateOnDeath = 0.0f;
	m_bDetonateOnWorld = 0.0f;
	m_bDetonateOnActor = 0.0f;
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
	m_vecLightColor = g_vec_null;
	m_flLightRadius = 0.0f;
	m_flLightOffset = 0.0f;
	m_vecExplodeLightColor = g_vec_null;
	m_fExplodelLightRadius = 0.0f;
	m_fExplodelLightFadetime = 0.0f;
	m_sndFly = __NULL__;
	m_sndExplode = __NULL__;
	m_sndBounce = __NULL__;

	/* ETQW-additions */
	m_bIsBullet = false;
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
		m_oldModel = model;
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
	case "explode_light_radus":
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
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
NSProjectile::Spawned(void)
{
	super::Spawned();

	SetMovetype(MOVETYPE_FLYMISSILE);
	SetRenderColor([1,1,1]);
	SetRenderAmt(1.0);
	SetSolid(SOLID_BBOX);
	SetRenderAmt(1.0f);
	SetRenderColor([1.0,1.0,1.0]);
	SetSize([0,0,0], [0,0,0]);
}

void
NSProjectile::Touch(entity eToucher)
{
	if (m_defDamage)
	if (eToucher.takedamage != DAMAGE_NO) {
		float damageVal;
		float baseDamage = Skill_GetDefValue(EntityDef_GetKeyValue(m_defDamage, "damage"));
		float randomDamage = Skill_GetDefValue(EntityDef_GetKeyValue(m_defDamage, "damage_random"));
		damageVal = (baseDamage + randomDamage);

		if (m_flDmgMultiplier >= 0.0)
			damageVal *= m_flDmgMultiplier;

		Damage_Apply(eToucher, owner, damageVal, WEAPON_NONE, DMG_BLUNT);
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

	if (m_partSmokeBounce)
		pointparticles(particleeffectnum(m_partSmokeBounce), origin, velocity, 1);

	StartSoundDef(m_sndBounce, CHAN_BODY, true);
}

void
NSProjectile::Pain(void)
{
	/* do nothing. */
}

void
NSProjectile::Death(void)
{
	if (m_bDetonateOnDeath) {
		_Explode();
		return;
	}

	/* whatever else comes otherwise? */
	Destroy();
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

	if (m_partSmokeFuse)
		pointparticles(particleeffectnum(m_partSmokeFuse), origin, velocity, 1);

	Destroy();
}
void
NSProjectile::_Explode(void)
{
	makevectors(vectoangles(velocity));
	vector explodePos = origin - (v_forward * 32);

	if (m_partModelDetonate)
		pointparticles(particleeffectnum(m_partModelDetonate), explodePos, velocity, 1);

	//print(sprintf("%S\n", m_defSplashDamage));
	if (m_defSplashDamage) {
		float flDamage = Skill_GetDefValue(EntityDef_GetKeyValue(m_defSplashDamage, "damage"));
		float flRadius = Skill_GetDefValue(EntityDef_GetKeyValue(m_defSplashDamage, "radius"));

		if (m_flDmgMultiplier >= 0.0)
			flDamage *= m_flDmgMultiplier;

		//print(sprintf("Damage: %d; Radius: %d\n", flDamage, flRadius));
		Damage_Radius(origin, owner, flDamage, flRadius, TRUE, WEAPON_NONE);
	}

	StartSoundDef(m_sndExplode, CHAN_VOICE, true);
	Destroy();
}

void
NSProjectile::_LaunchHitscan(vector startPos, vector launchDir, float dmgMultiplier)
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

	SetOrigin(startPos);
	SetAngles(launchDir);
	SetModel(m_oldModel);

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

	/* fire slower underwater */
	if (pointcontents(startPos) == CONTENT_WATER) {
		SetVelocity(moveVel / 10);
	} else {
		SetVelocity(moveVel);
	}

	SetAngularVelocity(avelocity);
	SetHealth(health);
	SetSolid(SOLID_BBOX);

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
		ScheduleThink(_FuseEnded, m_flFuse + fuseOffset);
	}

	StartSoundDef(m_sndFly, CHAN_BODY, true);
	SendFlags = (-1);
	SendEntity = 0; /* HACK: remove this once Spike fixes CSQC-set traileffectnum etc. */
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
	EVALUATE_FIELD(traileffectnum, PROJ_CHANGED_MODELINDEX)
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
	SENDENTITY_FLOAT(traileffectnum, PROJ_CHANGED_MODELINDEX)

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
	READENTITY_FLOAT(traileffectnum, PROJ_CHANGED_MODELINDEX)
	setmodelindex(this, modelindex);
	setorigin(this, origin);
}
#endif

#ifdef CLIENT
void
NSProjectile_ReadEntity(bool new)
{
	float fl;

	NSProjectile rend = (NSProjectile)self;
	if (new) {
		spawnfunc_NSProjectile();
	}

	fl = readfloat();
	rend.ReceiveEntity(new, fl);
}
#endif

#ifdef SERVER
void
NSProjectile_SpawnDef(string entityDef, NSEntity theOwner)
{
	entity oldself = self;
	NSProjectile rocket = spawn(NSProjectile);
	rocket.owner = theOwner;
	self = rocket;
	EntityDef_SpawnClassname(entityDef);
	self = oldself;
	rocket.Launch(theOwner.GetOrigin() + theOwner.view_ofs, theOwner.GetAngles(), 0.0f, 0.0f, 0.0f);
}
void
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
	rocket.Launch(attachmentPos, theOwner.GetAngles(), 0.0f, 0.0f, 0.0f);
}
#endif