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
ncSurfacePropEntity::ncSurfacePropEntity(void)
{
	m_flBurnNext = 0.0f;
#ifdef SERVER
	max_health = 100;
	max_armor = 100;
	m_iPropData = -1i;
	m_iMaterial = -1i;
	m_strOnBreak = __NULL__;
	m_eBurner= __NULL__;
	m_iBurnWeapon = 0i;
	m_flBurnTime = 0.0f;
	m_flBurnDmgTime = 0.0f;
	m_oldHealth = 0;
	m_strSurfData = __NULL__;
	m_strPropData = __NULL__;
	m_vecBloodColor = [0.5f, 0.0f, 0.0f];
#endif
}

void
ncSurfacePropEntity::Spawned(void)
{
	super::Spawned();

#ifdef SERVER
	/* tokenization complete, now we can load propdata */
	_SurfaceDataFinish();
	_PropDataFinish();

	/* Input/Output system */
	if (m_strOnBreak)
		m_strOnBreak = CreateOutput(m_strOnBreak);
#endif
}

bool
ncSurfacePropEntity::IsOnFire(void)
{
	return (effects & EF_ONFIRE) ? true : false;
}

/* networking */
#ifdef SERVER
void
ncSurfacePropEntity::SetBloodColor(vector newColor)
{
	m_vecBloodColor = newColor;
}

vector
ncSurfacePropEntity::GetBloodColor(void)
{
	return (m_vecBloodColor);
}

bool
ncSurfacePropEntity::IsAlive(void)
{
	return (health > 0) ? true : false;
}

bool
ncSurfacePropEntity::IsVulnerable(void)
{
	return (m_bTakesDamage);
}

void
ncSurfacePropEntity::EnableBleeding(void)
{
	iBleeds = true;
}

void
ncSurfacePropEntity::DisableBleeding(void)
{
	iBleeds = false;
}

void
ncSurfacePropEntity::EnableAimAssist(void)
{
	m_bAutoAim = true;
	_UpdateTakedamage();
}

void
ncSurfacePropEntity::DisableAimAssist(void)
{
	m_bAutoAim = false;
	_UpdateTakedamage();
}

void
ncSurfacePropEntity::MakeVulnerable(void)
{
	m_bTakesDamage = true;
	_UpdateTakedamage();
}

void
ncSurfacePropEntity::MakeInvulnerable(void)
{
	m_bTakesDamage = false;
	_UpdateTakedamage();
}

void
ncSurfacePropEntity::_UpdateTakedamage(void)
{
	if (!m_bTakesDamage) {
		takedamage = DAMAGE_NO;
	} else {
		if (m_bAutoAim) {
			takedamage = DAMAGE_AIM;
		} else {
			takedamage = DAMAGE_YES;
		}
	}
}

bool
ncSurfacePropEntity::CanBleed(void)
{
	return (iBleeds);
}

void
ncSurfacePropEntity::SetHealth(float new_health)
{
	if (max_health > 0)
		health = min(new_health, max_health);
	else
		health = new_health;
}

void
ncSurfacePropEntity::SetMaxHealth(float new_health)
{
	max_health = new_health;
	health =  min(health, max_health);
}

void
ncSurfacePropEntity::SetMaxArmor(float new_armor)
{
	max_armor = new_armor;
	armor =  min(armor, max_armor);
}

float
ncSurfacePropEntity::GetHealth(void)
{
	return (health);
}

float
ncSurfacePropEntity::GetMaxHealth(void)
{
	return (max_health);
}

float
ncSurfacePropEntity::GetMaxArmor(void)
{
	return (max_armor);
}

float
ncSurfacePropEntity::GetSpawnHealth(void)
{
	return (m_oldHealth);
}

void
ncSurfacePropEntity::SetArmor(float new_armor)
{
	armor = new_armor;
}

float
ncSurfacePropEntity::GetArmor(void)
{
	return (armor);
}

void
ncSurfacePropEntity::ParentUpdate(void)
{
	/* TODO: Move out */
	if (IsOnFire()) {
		if (m_flBurnNext < GetTime()) {
			if (GetTime() > m_flBurnTime) {
				Extinguish();
			}

			health -= 5;

			if (health <= 0) {
				Death(m_eBurner, m_eBurner, 5i, g_vec_null, origin, 0i);
			} else {
				Pain(m_eBurner, m_eBurner, 5i, g_vec_null, origin, 0i);
			}

			m_flBurnNext = GetTime() + 0.5f;
		}
	}

	super::ParentUpdate();
}

void
ncSurfacePropEntity::Damage(entity inflictor, entity attacker, ncDict damageDecl, float damageScale, vector dmgDir, vector hitLocation)
{
	if (IsVulnerable() == false) {
		return;
	}

	string damageString = ReadString(damageDecl.GetString("damage"));

#if 0
	float randomDamage = GetSubDefFloat(m_defDamage, "damage_random");
	damageVal = (baseDamage + randomDamage);
#endif

	float damagePoints = (float)rint(stof(damageString) * damageScale);
	ncSurfacePropEntity ourAttacker = (ncSurfacePropEntity)attacker;

	EntLog("applying %d damage by %s", damagePoints, attacker.classname);

	/* notify them */
	if (isSentient(attacker)) {
		ourAttacker.DamageFeedback(this, inflictor, damagePoints);
	}

	if (GetMovetype() == MOVETYPE_PHYSICS) {
		ncPhysicsEntity meSelf = (ncPhysicsEntity)this;
		float pushForce = damageDecl.GetFloat("push");

		if (pushForce > 0.0f) {
			meSelf.ApplyForceOffset(dmgDir * pushForce, hitLocation);
		}
	}

	if (damagePoints != 0) {
		health = rint(health - damagePoints);

		if (health <= 0) {
			/* apply knockback, but only on death */
			float knockBack = damageDecl.GetFloat("knockback");
			if (knockBack >= 0) {
				AddVelocity(dmgDir * knockBack);
			}

			Death(inflictor, attacker, (int)damagePoints, dmgDir, hitLocation, damageDecl.GetInteger("hitbody"));
		} else if (damagePoints > 0) {
			Pain(inflictor, attacker, (int)damagePoints, dmgDir, hitLocation, damageDecl.GetInteger("hitbody"));
		}
	}
}

/* Burning, fire, flames, etc. */
void
ncSurfacePropEntity::Ignite(entity attacker, float flLifetime, int iWeapon)
{
	effects |= EF_ONFIRE;
	m_eBurner = attacker;
	m_iBurnWeapon = iWeapon;
	m_flBurnTime = GetTime() + flLifetime;

	if (m_flBurnDmgTime < time) {
		ncDict damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", "5");
		damageDecl.AddKey("noArmor", "1");
		damageDecl.AddKey("type", "burn");
		Damage(m_eBurner, m_eBurner, damageDecl, 1.0f, g_vec_null, origin);
		remove(damageDecl);
		m_flBurnDmgTime = time + 0.25f;
	}
}

bool
ncSurfacePropEntity::CanBeDamaged(vector damageOrigin, vector hitLocation)
{
	vector testCenter = WorldSpaceCenter();

	traceline(hitLocation, testCenter, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	traceline(hitLocation, testCenter + [15.0f, 15.0f, 0.0f], MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	traceline(hitLocation, testCenter + [-15.0f, -15.0f, 0.0f], MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	traceline(hitLocation, testCenter + [-15.0f, 15.0f, 0.0f], MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	traceline(hitLocation, testCenter + [15.0f, -15.0f, 0.0f], MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (true);
	}

	return (false);
}

void
ncSurfacePropEntity::Extinguish(void)
{
	effects &= ~EF_ONFIRE;
	m_eBurner = __NULL__;
	m_iBurnWeapon =
	m_flBurnTime = 0;
}

void
ncSurfacePropEntity::Respawn(void)
{
	float sh = GetSpawnFloat("health");

	super::Respawn();

	/* only use spawndata's health if we aren't overriding it */
	if (HasPropData() != false && sh <= 0) {
		SetHealth((float)GetPropData(PROPINFO_HEALTH));
	} else {
		SetHealth(sh);
	}

	if (GetHealth() > 0) {
		MakeVulnerable();
	} else {
		MakeInvulnerable();
	}

	string surfDataOverride = GetSpawnString("surfdata");

	if (STRING_SET(surfDataOverride)) {
		SetSurfaceData(surfDataOverride);
	}
}

void
ncSurfacePropEntity::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flBurnNext", m_flBurnNext);
	SaveFloat(handle, "armor", armor);
	SaveFloat(handle, "health", health);
	SaveFloat(handle, "m_eBurner", num_for_edict(m_eBurner));
	SaveInt(handle, "m_iBurnWeapon", m_iBurnWeapon);
	SaveFloat(handle,"m_flBurnTime", m_flBurnTime);
	SaveFloat(handle, "m_flBurnDmgTime", m_flBurnDmgTime);
	SaveString(handle, "m_strOnBreak", m_strOnBreak);
	SaveFloat(handle, "m_oldHealth", m_oldHealth);
	SaveVector(handle, "m_vecBloodColor", m_vecBloodColor);
	SaveInt(handle, "m_iMaterial", m_iMaterial);
	SaveInt(handle, "m_iPropData", m_iPropData);
	SaveFloat(handle, "m_flDeathTime", m_flDeathTime);
}

void
ncSurfacePropEntity::Restore(string keyName, string savedValue)
{
	switch (keyName) {
	case "m_flBurnNext":
		m_flBurnNext = ReadFloat(savedValue);
		break;
	case "armor":
		armor = ReadFloat(savedValue);
		break;
	case "health":
		health = ReadFloat(savedValue);
		break;
	case "m_eBurner":
		m_eBurner = edict_num(ReadFloat(savedValue));
		break;
	case "m_iBurnWeapon":
		m_iBurnWeapon = ReadInt(savedValue);
		break;
	case "m_flBurnTime":
		m_flBurnTime = ReadFloat(savedValue);
		break;
	case "m_flBurnDmgTime":
		m_flBurnDmgTime = ReadFloat(savedValue);
		break;
	case "m_strOnBreak":
		m_strOnBreak = ReadString(savedValue);
		break;
	case "m_oldHealth":
		m_oldHealth = ReadFloat(savedValue);
		break;
	case "m_vecBloodColor":
		m_vecBloodColor = ReadVector(savedValue);
		break;
	case "m_iMaterial":
		m_iMaterial = ReadInt(savedValue);
		break;
	case "m_iPropData":
		m_iPropData = ReadInt(savedValue);
		break;
	case "m_flDeathTime":
		m_flDeathTime = ReadFloat(savedValue);
		break;
	default:
		super::Restore(keyName, savedValue);
	}
}

void
ncSurfacePropEntity::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "Ignite":
		Ignite(entityActivator, 5000, 0);
		break;
	case "IgniteLifetime":
		float lifeTime = stof(dataField);
		Ignite(entityActivator, lifeTime, 0);
		break;
	case "Extinguish":
		Extinguish();
		break;
	case "Damage":
		ncDict damageDecl = spawn(ncDict);
		float damagePoints = stof(dataField);
		damageDecl.AddKey("damage", dataField);
		Damage(this, this, damageDecl, 1.0, g_vec_null, GetOrigin());
		remove(damageDecl);
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
ncSurfacePropEntity::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "bleed":
		bool query = ReadBool(setValue);

		if (query)
			EnableBleeding();
		else
			DisableBleeding();

	case "health":
		max_health = health = ReadFloat(setValue);
		m_oldHealth = health;
		break;
	case "propdata":
		m_strPropData = ReadString(setValue);
		break;
	case "surfdata":
	case "materialdata":
		m_strSurfData = ReadString(setValue);
		break;
	/* entityDef */
	case "blood_color":
		m_vecBloodColor = ReadVector(setValue);
		break;
	/* Input/Output system */
	case "OnBreak":
		m_strOnBreak = PrepareOutput(m_strOnBreak, ReadString(setValue));
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}


void
ncSurfacePropEntity::Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	/* implemented in sub-class */
}

void
ncSurfacePropEntity::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	if (takedamage == DAMAGE_NO) {
		return;
	}

	/* FIXME: reliably call this with the right attacker inside BreakModel? */
	UseOutput(attacker, m_strOnBreak);
	BreakModel(damage, dir, hitBody);
}

void
ncSurfacePropEntity::DamageFeedback(entity theVictim, entity theInflictor, int desiredDamage)
{
	/* implemented in sub-class */
}

void
ncSurfacePropEntity::BreakModel(int damage, vector dir, int location)
{
	m_flDeathTime = time;

	MakeInvulnerable();

	if (HasPropData() == false) {
		return;
	}

	if (GetPropData(PROPINFO_SKIN) != 0) {
		SetSkin(GetPropData(PROPINFO_SKIN));
	} else if (GetPropData(PROPINFO_BREAKMODEL) != __NULL__) {
		string gibeffect = GetPropData(PROPINFO_BREAKMODEL);
		int breakcount = GetPropData(PROPINFO_BREAKCOUNT);
		float speedValue = length(GetVelocity());

		/* if we have enough momentum of our own, use that instead. */
		if (speedValue > damage)
			BreakModel_Entity(this, normalize(GetVelocity()), speedValue * 0.5f); /* absorb some power */
		else
			BreakModel_Entity(this, dir, damage);
		
		string sndBreak = GetSurfaceData(SURFDATA_SND_BREAK);
		Sound_PlayAt(GetOrigin(), sndBreak);
		Disappear();
	} else {
		Disappear();
	}

	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);

	/* handle explosions */
	float flExplodeMag, flExplodeRad;
	flExplodeMag = GetPropData(PROPINFO_EXPLOSIVE_DMG);
	flExplodeRad = GetPropData(PROPINFO_EXPLOSIVE_RADIUS);

	if (flExplodeMag) {
		if (!flExplodeRad) {
			flExplodeRad = flExplodeMag * 2.5f;
		}

		pointparticles(particleeffectnum("fx_explosion.main"), origin, angles, 1);
		combat.RadiusDamage(origin, flExplodeRad, 0i, (int)flExplodeMag, this, "");
	}
}
float
ncSurfacePropEntity::TimeSinceDeath(void)
{
	if (IsAlive()) {
		return (-1.0f);
	}

	return (time - m_flDeathTime);
}

void
ncSurfacePropEntity::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, SRFENT_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, SRFENT_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, SRFENT_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, SRFENT_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, SRFENT_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, SRFENT_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, SRFENT_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(flags, SRFENT_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, SRFENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, SRFENT_CHANGED_SIZE)
	EVALUATE_FIELD(frame, SRFENT_CHANGED_FRAME)
	EVALUATE_FIELD(skin, SRFENT_CHANGED_SKIN)
	EVALUATE_FIELD(effects, SRFENT_CHANGED_EFFECTS)
	EVALUATE_FIELD(m_iBody, SRFENT_CHANGED_BODY)
	EVALUATE_FIELD(scale, SRFENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 0, SRFENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 1, SRFENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 2, SRFENT_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, SRFENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, SRFENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, SRFENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, SRFENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, SRFENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, SRFENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_iRenderMode, SRFENT_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_iRenderFX, SRFENT_CHANGED_RENDERMODE)
	EVALUATE_VECTOR(m_vecRenderColor, 0, SRFENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, SRFENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, SRFENT_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flRenderAmt, SRFENT_CHANGED_RENDERAMT)
	EVALUATE_FIELD(m_flBoneControl1, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl2, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl3, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl4, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl5, SRFENT_CHANGED_CONTROLLER)
}

/* Make sure StartFrame calls this */
float
ncSurfacePropEntity::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_SURFPROP);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], SRFENT_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], SRFENT_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], SRFENT_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], SRFENT_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], SRFENT_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], SRFENT_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, SRFENT_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_BYTE(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_INT(flags, SRFENT_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], SRFENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], SRFENT_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, SRFENT_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, SRFENT_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, SRFENT_CHANGED_EFFECTS)
	SENDENTITY_SHORT(m_iBody, SRFENT_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[0], SRFENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[1], SRFENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[2], SRFENT_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_iRenderMode, SRFENT_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, SRFENT_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_vecRenderColor[0], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_vecRenderColor[1], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_vecRenderColor[2], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_flRenderAmt, SRFENT_CHANGED_RENDERAMT)
	SENDENTITY_ANGLE(m_flBoneControl1, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl2, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl3, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl4, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl5, SRFENT_CHANGED_CONTROLLER)

	return (1);
}

#else
/*
============
ncSurfacePropEntity::ReceiveEntity
============
*/
void
ncSurfacePropEntity::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], SRFENT_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], SRFENT_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], SRFENT_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], SRFENT_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], SRFENT_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], SRFENT_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, SRFENT_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
	READENTITY_BYTE(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
	READENTITY_INT(flags, SRFENT_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(mins[1], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(mins[2], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], SRFENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], SRFENT_CHANGED_SIZE)
	READENTITY_BYTE(frame, SRFENT_CHANGED_FRAME)
	READENTITY_FLOAT(skin, SRFENT_CHANGED_SKIN)
	READENTITY_FLOAT(effects, SRFENT_CHANGED_EFFECTS)
	READENTITY_SHORT(m_iBody, SRFENT_CHANGED_BODY)
	READENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[0], SRFENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[1], SRFENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[2], SRFENT_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_iRenderMode, SRFENT_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, SRFENT_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_vecRenderColor[0], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_vecRenderColor[1], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_vecRenderColor[2], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_flRenderAmt, SRFENT_CHANGED_RENDERAMT)
	READENTITY_ANGLE(m_flBoneControl1, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl2, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl3, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl4, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl5, SRFENT_CHANGED_CONTROLLER)

	/* this shall never be valid. use Hide() */
	if (scale == 0.0f) {
		scale = 1.0f;
	}

	/* other post-eval operations happen here */
	if (flChanged & SRFENT_CHANGED_SIZE) {
		setsize(this, mins * scale, maxs * scale);
	}

	if (flChanged & SRFENT_CHANGED_BODY) {
		setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_iBody, m_iBody));
	}
}

void
ncSurfacePropEntity::RenderFire(void)
{
	if (IsOnFire() == true) {
		vector randomOrg;

		if (m_flBurnNext < time) {
			randomOrg[0] = absmin[0] + ( random() * ( absmax[0] - absmin[0] ) );
			randomOrg[1] = absmin[1] + ( random() * ( absmax[1] - absmin[1] ) );
			randomOrg[2] = absmin[2] + ( random() * ( absmax[2] - absmin[2] ) );
			pointparticles(PART_BURNING, randomOrg, g_vec_null, 1);
			m_flBurnNext = time + 0.1f;
		}
	}
}

float
ncSurfacePropEntity::predraw(void)
{
	float oldEffects = effects;

	if (modelindex != 0) {
		RenderFire();
	}

	float returnValue = super::predraw();

	effects = oldEffects;
	return returnValue;
}

void
ncSurfacePropEntity_ReadEntity(bool isNew)
{
	float networkFlags;
	ncSurfacePropEntity rendEnt = (ncSurfacePropEntity)self;

	if (isNew) {
		spawnfunc_ncSurfacePropEntity();
	}

	networkFlags = readfloat();
	rendEnt.ReceiveEntity(isNew, networkFlags);
}
#endif

void
ncSurfacePropEntity::SetSurfaceData(string type)
{
	m_strSurfData = type;
	_SurfaceDataFinish();
}

void
ncSurfacePropEntity::SetPropData(string type)
{
	m_strPropData = type;
	_PropDataFinish();
}

bool
ncSurfacePropEntity::HasPropData(void)
{
	return (m_iPropData != -1) ? true : false;
}

__variant
ncSurfacePropEntity::GetPropData(int type)
{
	return Prop_GetInfo(m_iPropData, type);
}

bool
ncSurfacePropEntity::HasSurfaceData(void)
{
	return (m_iMaterial != -1) ? true : false;
}

__variant
ncSurfacePropEntity::GetSurfaceData(int type)
{
	return SurfData_GetInfo(m_iMaterial, type);
}

void
ncSurfacePropEntity::_SurfaceDataFinish(void)
{
	SurfData_SetStage(m_strSurfData);

	if (STRING_SET(m_strSurfData)) {
		m_iMaterial = SurfData_Finish();
	} else {
		m_iMaterial = -1i;
	}
}

void
ncSurfacePropEntity::_PropDataFinish(void)
{
	PropData_SetStage(m_strPropData);

	if (STRING_SET(m_strPropData)) {
		m_iPropData = PropData_Finish();
	} else {
		m_iPropData = -1i;
	}

	/* no surfdata? maybe the propdata has got one set. */
	if (m_iMaterial == -1i && m_iPropData != -1i) {
		string propDataSurf = GetPropData(PROPINFO_SURFACEPROP);

		if (STRING_SET(propDataSurf)) {
			SetSurfaceData(propDataSurf);
		}
	}
}

void
ncSurfacePropEntity::SetModel(string newModel)
{
	ncRenderableEntity::SetModel(newModel);

	if (IsBrush() == false)
	if (STRING_SET(model) && HasPropData() == false) {
		m_iPropData = PropData_ForModel(model);
		m_strPropData = model;
		_PropDataFinish();
	}
}
