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
NSSurfacePropEntity::NSSurfacePropEntity(void)
{
	m_flBurnNext = 0.0f;
#ifdef SERVER
	m_iPropData = -1i;
	m_iMaterial = -1i;
	max_health = 100;
	m_strOnBreak = __NULL__;
	m_eBurner= __NULL__;
	m_iBurnWeapon = 0i;
	m_flBurnTime = 0.0f;
	m_flBurnDmgTime = 0.0f;
	m_oldHealth = 0;
	m_strSurfData = __NULL__;
	m_strPropData = __NULL__;
	m_vecBloodColor = [0.5, 0, 0];
#endif
}

vector
NSSurfacePropEntity::GetEyePos(void)
{
	if (HasFlags(FL_FAKESPEC)) {
		return (origin);
	}

	return (origin + view_ofs);
}

vector
NSSurfacePropEntity::GetViewAngle(void)
{
	return (v_angle);
}

void
NSSurfacePropEntity::SetEyePos(vector value)
{
	view_ofs = value;
}

void
NSSurfacePropEntity::Spawned(void)
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

/* networking */
#ifdef SERVER
void
NSSurfacePropEntity::SetBloodColor(vector newColor)
{
	m_vecBloodColor = newColor;
}

vector
NSSurfacePropEntity::GetBloodColor(void)
{
	return (m_vecBloodColor);
}

bool
NSSurfacePropEntity::IsAlive(void)
{
	return (health > 0) ? true : false;
}

void
NSSurfacePropEntity::SetCanBleed(bool bleedValue)
{
	iBleeds = bleedValue;
}

bool
NSSurfacePropEntity::CanBleed(void)
{
	return (iBleeds);
}

void
NSSurfacePropEntity::SetTakedamage(float type)
{
	takedamage = type;
}

void
NSSurfacePropEntity::SetHealth(float new_health)
{
	if (max_health > 0)
		health = min(new_health, max_health);
	else
		health = new_health;
}

void
NSSurfacePropEntity::SetMaxHealth(float new_health)
{
	max_health = new_health;
	health =  min(health, max_health);
}


float
NSSurfacePropEntity::GetHealth(void)
{
	return (health);
}
float
NSSurfacePropEntity::GetMaxHealth(void)
{
	return (max_health);
}
float
NSSurfacePropEntity::GetSpawnHealth(void)
{
	return (m_oldHealth);
}

void
NSSurfacePropEntity::SetArmor(float new_armor)
{
	armor = new_armor;
}
float
NSSurfacePropEntity::GetArmor(void)
{
	return (armor);
}

bool
NSSurfacePropEntity::HasPropData(void)
{
	return (m_iPropData != -1) ? true : false;
}

__variant
NSSurfacePropEntity::GetPropData(int type)
{
	return Prop_GetInfo(m_iPropData, type);
}

bool
NSSurfacePropEntity::HasSurfaceData(void)
{
	return (m_iMaterial != -1) ? true : false;
}

__variant
NSSurfacePropEntity::GetSurfaceData(int type)
{
	return SurfData_GetInfo(m_iMaterial, type);
}

void
NSSurfacePropEntity::ParentUpdate(void)
{
	/* TODO: Move out */
	if (flags & FL_ONFIRE) {
		if (m_flBurnNext < time) {
			if (time > m_flBurnTime) {
				flags &= ~FL_ONFIRE;
			}

			Damage_Apply(this, m_eBurner, 5, m_iBurnWeapon, DMG_BURN | DMG_SKIP_ARMOR);
			m_flBurnNext = time + 0.5f;
		}
	}

	NSRenderableEntity::ParentUpdate();
}

/* Burning, fire, flames, etc. */
void
NSSurfacePropEntity::Ignite(entity attacker, float flLifetime, int iWeapon)
{
	flags |= FL_ONFIRE;
	m_eBurner = attacker;
	m_iBurnWeapon = iWeapon;
	m_flBurnTime = time + flLifetime;

	if (m_flBurnDmgTime < time) {
		Damage_Apply(this, attacker, 5, iWeapon, DMG_BURN | DMG_SKIP_ARMOR);
		m_flBurnDmgTime = time + 0.25f;
	}
}

void
NSSurfacePropEntity::Extinguish(void)
{
	flags &= ~FL_ONFIRE;
	m_eBurner = __NULL__;
	m_iBurnWeapon =
	m_flBurnTime = 0;
}

bool
NSSurfacePropEntity::IsOnFire(void)
{
	return (flags & FL_ONFIRE) ? true : false;
}

void
NSSurfacePropEntity::Respawn(void)
{
	float sh = GetSpawnHealth();
	NSRenderableEntity::Respawn();

	/* only use spawndata's health if we aren't overriding it */
	if (HasPropData() != false && sh <= 0) {
		health = (float)GetPropData(PROPINFO_HEALTH);
	} else {
		health = sh;
	}

	if (health > 0)
		takedamage = DAMAGE_YES;
	else
		takedamage = DAMAGE_NO;
}

void
NSSurfacePropEntity::Save(float handle)
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
NSSurfacePropEntity::Restore(string keyName, string savedValue)
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
NSSurfacePropEntity::Input(entity entityActivator, string inputName, string dataField)
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
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
NSSurfacePropEntity::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
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
NSSurfacePropEntity::Pain(void)
{
	/* implemented in sub-class */
}

void
NSSurfacePropEntity::DamageFeedback(NSSurfacePropEntity theVictim, NSSurfacePropEntity theInflictor, int desiredDamage)
{
	/* implemented in sub-class */
}

void
NSSurfacePropEntity::Death(void)
{
	m_flDeathTime = time;

	UseOutput(g_dmg_eAttacker, m_strOnBreak);

	if (HasPropData() == false) {
		return;
	}

	if (GetPropData(PROPINFO_SKIN) != 0) {
		SetSkin(GetPropData(PROPINFO_SKIN));
	} else if (GetPropData(PROPINFO_BREAKMODEL) != __NULL__) {
		string gibeffect = GetPropData(PROPINFO_BREAKMODEL);
		int breakcount = GetPropData(PROPINFO_BREAKCOUNT);
		BreakModel_Entity(this, normalize(GetOrigin() - g_dmg_vecLocation), g_dmg_iDamage);
		//BreakModel_Spawn(absmin, absmax, [0,0,0], 100, breakcount, gibeffect);
		Disappear();
	} else {
		Disappear();
	}

	/* handle explosions */
	float flExplodeMag, flExplodeRad;
	flExplodeMag = GetPropData(PROPINFO_EXPLOSIVE_DMG);
	flExplodeRad = GetPropData(PROPINFO_EXPLOSIVE_RADIUS);

	if (flExplodeMag) {
		if (!flExplodeRad)
			flExplodeRad = flExplodeMag * 2.5f;

		pointparticles(particleeffectnum("fx_explosion.main"), origin, angles, 1);
		Damage_Radius(origin, this, flExplodeMag, flExplodeRad, TRUE, 0);
	}
}

void
NSSurfacePropEntity::SetSurfaceData(string type)
{
	m_strSurfData = type;
	_SurfaceDataFinish();
}

void
NSSurfacePropEntity::SetPropData(string type)
{
	m_strPropData = type;
	_PropDataFinish();
}

void
NSSurfacePropEntity::_SurfaceDataFinish(void)
{
	SurfData_SetStage(m_strSurfData);

	if (m_strSurfData)
		m_iMaterial = SurfData_Finish();
	else
		m_iMaterial = -1;
}

void
NSSurfacePropEntity::_PropDataFinish(void)
{
	PropData_SetStage(m_strPropData);

	if (m_strPropData)
		m_iPropData = PropData_Finish();
	else
		m_iPropData = -1;
}

float
NSSurfacePropEntity::TimeSinceDeath(void)
{
	if (IsAlive())
		return (-1);

	return (time - m_flDeathTime);
}

void
NSSurfacePropEntity::SetPainCallback(void(void) painFunc)
{
	Pain = painFunc;
}

void
NSSurfacePropEntity::SetDeathCallback(void(void) deathFunc)
{
	Death = deathFunc;
}

bool
NSSurfacePropEntity::CanBeDamaged(void)
{
	return (takedamage == DAMAGE_NO) ? false : true;
}

void
NSSurfacePropEntity::EvaluateEntity(void)
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
NSSurfacePropEntity::SendEntity(entity ePEnt, float flChanged)
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
	SENDENTITY_COLOR(m_vecRenderColor[0], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[1], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[2], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_flRenderAmt, SRFENT_CHANGED_RENDERAMT)
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
NSSurfacePropEntity::ReceiveEntity
============
*/
void
NSSurfacePropEntity::ReceiveEntity(float flNew, float flChanged)
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
	READENTITY_COLOR(m_vecRenderColor[0], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[1], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[2], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_flRenderAmt, SRFENT_CHANGED_RENDERAMT)
	READENTITY_ANGLE(m_flBoneControl1, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl2, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl3, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl4, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl5, SRFENT_CHANGED_CONTROLLER)

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & SRFENT_CHANGED_SIZE) {
		setsize(this, mins * scale, maxs * scale);
	}

	if (flChanged & SRFENT_CHANGED_BODY) {
		setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_iBody, m_iBody));
	}
}

void
NSSurfacePropEntity::RenderFire(void)
{
	if (flags & FL_ONFIRE) {
		vector someorg;

		if (m_flBurnNext < time) {
			someorg[0] = absmin[0] + ( random() * ( absmax[0] - absmin[0] ) );
			someorg[1] = absmin[1] + ( random() * ( absmax[1] - absmin[1] ) );
			someorg[2] = absmin[2] + ( random() * ( absmax[2] - absmin[2] ) );
			pointparticles(PART_BURNING, someorg, [0,0,0], 1);
			m_flBurnNext = time + 0.1f;
		}
	}
}
float
NSSurfacePropEntity::predraw(void)
{
	float returnValue = super::predraw();

	if (returnValue) {
		RenderFire();
	}

	return returnValue;
}

void
NSSurfacePropEntity_ReadEntity(bool isNew)
{
	float networkFlags;
	NSSurfacePropEntity rendEnt = (NSSurfacePropEntity)self;

	if (isNew) {
		spawnfunc_NSSurfacePropEntity();
	}

	networkFlags = readfloat();
	rendEnt.ReceiveEntity(isNew, networkFlags);
}
#endif

void
NSSurfacePropEntity::SetModel(string newModel)
{
	NSRenderableEntity::SetModel(newModel);

#ifdef SERVER
	if (model && HasPropData() == false) {
		m_iPropData = PropData_ForModel(model);
	}
#endif
}
