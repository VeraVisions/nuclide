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
	return origin + view_ofs;
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
	return m_vecBloodColor;
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
	return iBleeds;
}

#if 0
typedef enum
{
	NETFIELD_BYTE,
	NETFIELD_SHORT,
	NETFIELD_FLOAT,
	NETFIELD_INT,
	NETFIELD_COORD,
	NETFIELD_ANGLE,
	NETFIELD_ENTITY,
	NETFIELD_STRING
} nettype_t;

typedef struct
{
	.variant field;
	.variant field_net;
	int changedflag;
	__variant defaultvalue;
	nettype_e type;
} netinfo_t;

netinfo_t n_NSSurfacePropEntity[] =
{
	{origin[0], NSEntity::origin_net[0], SRFENT_CHANGED_ORIGIN_X, 0, NETFIELD_COORD},
	{origin[1], NSEntity::origin_net[1], SRFENT_CHANGED_ORIGIN_Y, 0, NETFIELD_COORD},
	{origin[2], NSEntity::origin_net[2], SRFENT_CHANGED_ORIGIN_Z, 0, NETFIELD_COORD},
	{angles[0], NSEntity::angles_net[0], SRFENT_CHANGED_ANGLES_X, 0, NETFIELD_ANGLE},
	{angles[1], NSEntity::angles_net[1], SRFENT_CHANGED_ANGLES_Y, 0, NETFIELD_ANGLE},
	{angles[2], NSEntity::angles_net[2], SRFENT_CHANGED_ANGLES_Z, 0, NETFIELD_ANGLE},
	{modelindex, NSEntity::modelindex_net, SRFENT_CHANGED_MODELINDEX, 0, NETFIELD_SHORT},
	{solid, NSEntity::solid_net, SRFENT_CHANGED_SOLID, 0, NETFIELD_BYTE},
	{movetype, NSEntity::movetype_net, SRFENT_CHANGED_MOVETYPE, 0, NETFIELD_BYTE},
	{flags, NSEntity::flags_net, SRFENT_CHANGED_FLAGS, 0, NETFIELD_FLOAT},
	{mins[0], NSEntity::mins_net[0], SRFENT_CHANGED_SIZE, 0, NETFIELD_SHORT},
	{mins[1], NSEntity::mins_net[1], SRFENT_CHANGED_SIZE, 0, NETFIELD_SHORT},
	{mins[2], NSEntity::mins_net[2], SRFENT_CHANGED_SIZE, 0, NETFIELD_SHORT},
	{maxs[0], NSEntity::maxs_net[0], SRFENT_CHANGED_SIZE, 0, NETFIELD_SHORT},
	{maxs[1], NSEntity::maxs_net[1], SRFENT_CHANGED_SIZE, 0, NETFIELD_SHORT},
	{maxs[2], NSEntity::maxs_net[2], SRFENT_CHANGED_SIZE, 0, NETFIELD_SHORT},
	{frame, NSRenderableEntity::frame_net, SRFENT_CHANGED_FRAME, 0, NETFIELD_SHORT},
	{skin, NSRenderableEntity::skin_net, SRFENT_CHANGED_SKIN, 0, NETFIELD_BYTE},
	{effects, NSRenderableEntity::effects_net, SRFENT_CHANGED_EFFECTS, 0, NETFIELD_SHORT},
	{NSRenderableEntity::m_iBody, NSRenderableEntity::m_iBody_net, SRFENT_CHANGED_BODY, 0, NETFIELD_BYTE},
	{scale, NSEntity::scale_net, SRFENT_CHANGED_SCALE, 0, NETFIELD_FLOAT},
	{velocity[0], NSEntity::velocity_net[0], SRFENT_CHANGED_VELOCITY, 0, NETFIELD_ANGLE},
	{velocity[1], NSEntity::velocity_net[1], SRFENT_CHANGED_VELOCITY, 0, NETFIELD_ANGLE},
	{velocity[2], NSEntity::velocity_net[2], SRFENT_CHANGED_VELOCITY, 0, NETFIELD_ANGLE},
	{NSRenderableEntity::m_iRenderMode, NSRenderableEntity::m_iRenderMode_net, SRFENT_CHANGED_RENDERMODE, 0, NETFIELD_BYTE},
	{NSRenderableEntity::m_iRenderFX, NSRenderableEntity::m_iRenderFX_net, SRFENT_CHANGED_RENDERMODE, 0, NETFIELD_BYTE},
};

void
NSSurfacePropEntity::EvaluateEntity(void)
{
	for (int i = 0; i < n_NSSurfacePropEntity.length; i++) {
		if (this.(n_NSSurfacePropEntity[i].field) != this.(n_NSSurfacePropEntity[i].field_net)) {
			SetSendFlags(n_NSSurfacePropEntity[i].changedflag);
			print(sprintf("uhh %i\n", i));
		}

		this.(n_NSSurfacePropEntity[i].field_net) = this.(n_NSSurfacePropEntity[i].field);
	}
}


/* Make sure StartFrame calls this */
float
NSSurfacePropEntity::SendEntity(entity ePEnt, float fChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_SURFPROP);

#if 0
	if (fChanged == 0xFFFFFF) {
		for (int i = 0; i < n_NSSurfacePropEntity.length; i++) {
			/* unflag everything that's the default value */
			if (this.(n_NSSurfacePropEntity[i].field) == this.(n_NSSurfacePropEntity[i].defaultvalue))
				fChanged &= ~n_NSSurfacePropEntity[i].changedflag;
		}
	}
#endif

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, fChanged);

	for (int i = 0; i < n_NSSurfacePropEntity.length; i++) {
		if (fChanged & n_NSSurfacePropEntity[i].changedflag) {
			switch (n_NSSurfacePropEntity[i].type) {
			case NETFIELD_BYTE:
				WriteByte(MSG_ENTITY, this.(n_NSSurfacePropEntity[i].field));
				break;
			case NETFIELD_SHORT:
				WriteShort(MSG_ENTITY, this.(n_NSSurfacePropEntity[i].field));
				break;
			case NETFIELD_FLOAT:
				WriteFloat(MSG_ENTITY, this.(n_NSSurfacePropEntity[i].field));
				break;
			case NETFIELD_INT:
				WriteInt(MSG_ENTITY, this.(n_NSSurfacePropEntity[i].field));
				break;
			case NETFIELD_COORD:
				WriteCoord(MSG_ENTITY, this.(n_NSSurfacePropEntity[i].field));
				break;
			case NETFIELD_ANGLE:
				WriteShort(MSG_ENTITY, this.(n_NSSurfacePropEntity[i].field) * 32767 / 360);
				break;
			case NETFIELD_ENTITY:
				WriteEntity(MSG_ENTITY, this.(n_NSSurfacePropEntity[i].field));
				break;
			case NETFIELD_STRING:
				WriteString(MSG_ENTITY, this.(n_NSSurfacePropEntity[i].field));
				break;
			}
		}
	}

	return (1);
}
#else

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
	SENDENTITY_BYTE(m_iBody, SRFENT_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_iRenderMode, SRFENT_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, SRFENT_CHANGED_RENDERMODE)
	SENDENTITY_ANGLE(m_vecRenderColor[0], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_vecRenderColor[1], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_vecRenderColor[2], SRFENT_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_flRenderAmt, SRFENT_CHANGED_RENDERAMT)
	SENDENTITY_ANGLE(m_flBoneControl1, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl2, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl3, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl4, SRFENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl5, SRFENT_CHANGED_CONTROLLER)

	return (1);
}
#endif

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
	READENTITY_BYTE(m_iBody, SRFENT_CHANGED_BODY)
	READENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_iRenderMode, SRFENT_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, SRFENT_CHANGED_RENDERMODE)
	READENTITY_ANGLE(m_vecRenderColor[0], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_vecRenderColor[1], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_vecRenderColor[2], SRFENT_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_flRenderAmt, SRFENT_CHANGED_RENDERAMT)
	READENTITY_ANGLE(m_flBoneControl1, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl2, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl3, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl4, SRFENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl5, SRFENT_CHANGED_CONTROLLER)

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & SRFENT_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);
	if (flChanged & SRFENT_CHANGED_BODY)
		setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_iBody, m_iBody));

	setorigin(this, origin);
}
#endif

#ifdef SERVER
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
	return health;
}
float
NSSurfacePropEntity::GetMaxHealth(void)
{
	return max_health;
}
float
NSSurfacePropEntity::GetSpawnHealth(void)
{
	return m_oldHealth;
}

void
NSSurfacePropEntity::SetArmor(float new_armor)
{
	armor = new_armor;
}
float
NSSurfacePropEntity::GetArmor(void)
{
	return armor;
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
	SaveFloat(handle, "m_eBurner", num_for_edict(m_eBurner));
	SaveInt(handle, "m_iBurnWeapon", m_iBurnWeapon);
	SaveFloat(handle,"m_flBurnTime", m_flBurnTime);
	SaveFloat(handle, "m_flBurnNext", m_flBurnNext);
	SaveString(handle, "m_strOnBreak", m_strOnBreak);
	SaveFloat(handle, "m_oldHealth", m_oldHealth);
	SaveInt(handle, "m_iMaterial", m_iMaterial);
	SaveInt(handle, "m_iPropData", m_iPropData);
}

void
NSSurfacePropEntity::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_eBurner":
		m_eBurner = edict_num(ReadFloat(strValue));
		break;
	case "m_iBurnWeapon":
		m_iBurnWeapon = ReadInt(strValue);
		break;
	case "m_flBurnTime":
		m_flBurnTime = ReadFloat(strValue);
		break;
	case "m_flBurnNext":
		m_flBurnNext = ReadFloat(strValue);
		break;
	case "m_strOnBreak":
		m_strOnBreak = ReadString(strValue);
		break;
	case "m_oldHealth":
		m_oldHealth = ReadFloat(strValue);
		break;
	case "m_iMaterial":
		m_iMaterial = ReadInt(strValue);
		break;
	case "m_iPropData":
		m_iPropData = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSSurfacePropEntity::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Ignite":
		Ignite(eAct, 5000, 0);
		break;
	case "IgniteLifetime":
		Ignite(eAct, stof(strData), 0);
		break;
	case "Extinguish":
		Extinguish();
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
NSSurfacePropEntity::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "health":
		max_health = health = stof(strValue);
		m_oldHealth = health;
		break;
	case "propdata":
		SetPropData(strValue);
		break;
	case "surfdata":
	case "materialdata":
		SetSurfaceData(strValue);
		break;
	/* entityDef */
	case "blood_color":
		m_vecBloodColor = ReadVector(strValue);
		break;
	/* Input/Output system */
#ifdef SERVER
	case "OnBreak":
		m_strOnBreak = PrepareOutput(m_strOnBreak, strValue);
		break;
#endif
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSSurfacePropEntity::Pain(void)
{
	
}

void
NSSurfacePropEntity::Death(void)
{
	m_flDeathTime = time;

	print(sprintf("%S", m_strOnBreak));
	print("\n");

	UseOutput(g_dmg_eAttacker, m_strOnBreak);

	if (HasPropData() == false)
		return;

	if (GetPropData(PROPINFO_SKIN) != 0) {
		SetSkin(GetPropData(PROPINFO_SKIN));
	} else if (GetPropData(PROPINFO_BREAKMODEL) != __NULL__) {
		string gibeffect = GetPropData(PROPINFO_BREAKMODEL);
		int breakcount = GetPropData(PROPINFO_BREAKCOUNT);
		BreakModel_Spawn(absmin, absmax, [0,0,0], 100, breakcount, gibeffect);
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

		FX_Explosion(origin);
		Damage_Radius(origin, this, flExplodeMag, flExplodeRad, TRUE, 0);
	}
}

void
NSSurfacePropEntity::SetSurfaceData(string type)
{
	m_strSurfData = type;
}
void
NSSurfacePropEntity::SetPropData(string type)
{
	m_strPropData = type;
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
		return -1;

	return time - m_flDeathTime;
}

#endif

#ifdef CLIENT
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
	RenderFire();
	return super::predraw();
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

#ifdef CLIENT
void
NSSurfacePropEntity_ReadEntity(bool new)
{
	float fl;
	NSSurfacePropEntity rend = (NSSurfacePropEntity)self;
	if (new) {
		spawnfunc_NSSurfacePropEntity();
	}
	fl = readfloat();
	rend.ReceiveEntity(new, fl);
}
#endif
