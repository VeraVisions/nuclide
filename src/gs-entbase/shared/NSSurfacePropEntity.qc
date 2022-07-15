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
NSSurfacePropEntity::Spawned(void)
{
	super::Spawned();

#ifdef SERVER
	/* tokenization complete, now we can load propdata */
	SurfaceDataFinish();
	PropDataFinish();

	/* Input/Output system */
	if (m_strOnBreak)
		m_strOnBreak = CreateOutput(m_strOnBreak);
#endif
}

/* networking */
#ifdef SERVER

#if INDEV
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
} nettype_e;

typedef struct
{
	.variant field;
	.variant field_net;
	int changedflag;
	__variant defaultvalue;
	nettype_e type;
} netinfo_t;

const netinfo_t n_NSSurfacePropEntity[] =
{
	{origin[0], NSEntity::origin_net[0], SRFENT_CHANGED_ORIGIN, 0, NETFIELD_COORD},
	{origin[1], NSEntity::origin_net[1], SRFENT_CHANGED_ORIGIN, 0, NETFIELD_COORD},
	{origin[2], NSEntity::origin_net[2], SRFENT_CHANGED_ORIGIN, 0, NETFIELD_COORD},
	{angles[0], NSEntity::angles_net[0], SRFENT_CHANGED_ANGLES, 0, NETFIELD_ANGLE},
	{angles[1], NSEntity::angles_net[1], SRFENT_CHANGED_ANGLES, 0, NETFIELD_ANGLE},
	{angles[2], NSEntity::angles_net[2], SRFENT_CHANGED_ANGLES, 0, NETFIELD_ANGLE},
	{modelindex, NSEntity::modelindex_net, SRFENT_CHANGED_MODELINDEX, 0, NETFIELD_SHORT},
	{solid, NSEntity::solid_net, SRFENT_CHANGED_SOLID, 0, NETFIELD_BYTE},
	{movetype, NSEntity::movetype_net, SRFENT_CHANGED_MOVETYPE, 0, NETFIELD_BYTE},
	{flags, NSEntity::flags_net, SRFENT_CHANGED_FLAGS, 0, NETFIELD_FLOAT},
	{size[0], NSEntity::size_net[0], SRFENT_CHANGED_SIZE, 0, NETFIELD_SHORT},
	{size[1], NSEntity::size_net[1], SRFENT_CHANGED_SIZE, 0, NETFIELD_SHORT},
	{size[2], NSEntity::size_net[2], SRFENT_CHANGED_SIZE, 0, NETFIELD_SHORT},
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
		if (this.(n_NSSurfacePropEntity[i].field) != this.(n_NSSurfacePropEntity[i].field_net))
			SetSendFlags(n_NSSurfacePropEntity[i].changedflag);

		this.(n_NSSurfacePropEntity[i].field_net) = this.(n_NSSurfacePropEntity[i].field);
	}
}
#endif

void
NSSurfacePropEntity::EvaluateEntity(void)
{
	EVALUATE_FIELD(origin, SRFENT_CHANGED_ORIGIN)
	EVALUATE_FIELD(angles, SRFENT_CHANGED_ANGLES)
	EVALUATE_FIELD(modelindex, SRFENT_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, SRFENT_CHANGED_SOLID)
	EVALUATE_FIELD(movetype, SRFENT_CHANGED_FLAGS)
	EVALUATE_FIELD(flags, SRFENT_CHANGED_FLAGS)
	EVALUATE_FIELD(size, SRFENT_CHANGED_SIZE)
	EVALUATE_FIELD(frame, SRFENT_CHANGED_FRAME)
	EVALUATE_FIELD(skin, SRFENT_CHANGED_SKIN)
	EVALUATE_FIELD(effects, SRFENT_CHANGED_EFFECTS)
	EVALUATE_FIELD(m_iBody, SRFENT_CHANGED_BODY)
	EVALUATE_FIELD(scale, SRFENT_CHANGED_SCALE)
	EVALUATE_FIELD(velocity, SRFENT_CHANGED_VELOCITY)
	EVALUATE_FIELD(m_iRenderMode, SRFENT_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_iRenderFX, SRFENT_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_vecRenderColor, SRFENT_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flRenderAmt, SRFENT_CHANGED_RENDERAMT)
	EVALUATE_FIELD(m_flBoneControl1, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl2, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl3, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl4, SRFENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl5, SRFENT_CHANGED_CONTROLLER)
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

	//print(sprintf("%s %x\n", classname, fChanged));

#if 0
	/* newly popped into the PVS, sadly this is the only hacky way to check
	 * for this right now. convince the engine maintainer to make this more sensible */
	if (fChanged == 0xFFFFFF) {
		/* check for defaults. if these are predictable fields, don't even bother
		 * networking them! you're just wasting bandwidth. */
		if (frame == 0)
			fChanged &= ~SRFENT_CHANGED_FRAME;
		if (skin == 0)
			fChanged &= ~SRFENT_CHANGED_SKIN;
		if (effects == 0)
			fChanged &= ~SRFENT_CHANGED_EFFECTS;
		if (m_iBody == 0)
			fChanged &= ~SRFENT_CHANGED_BODY;
		if (scale == 0.0 || scale == 1.0)
			fChanged &= ~SRFENT_CHANGED_SCALE;
		if (origin == [0,0,0])
			fChanged &= ~SRFENT_CHANGED_ORIGIN;
		if (angles == [0,0,0])
			fChanged &= ~SRFENT_CHANGED_ANGLES;
		if (velocity == [0,0,0])
			fChanged &= ~SRFENT_CHANGED_VELOCITY;
		if (mins == [0,0,0] && maxs == [0,0,0])
			fChanged &= ~SRFENT_CHANGED_SIZE;
		if (solid == SOLID_NOT)
			fChanged &= ~SRFENT_CHANGED_SOLID;
		if (movetype == MOVETYPE_NONE)
			fChanged &= ~SRFENT_CHANGED_MOVETYPE;
		if (m_iRenderMode == RM_NORMAL)
			fChanged &= ~SRFENT_CHANGED_RENDERMODE;
	}
#endif

	/* don't network triggers unless provoked */
	/*if (cvar("developer") == 0 && m_iRenderMode == RM_TRIGGER)
		return (0);*/

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & SRFENT_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	if (fChanged & SRFENT_CHANGED_ANGLES) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
	}
	if (fChanged & SRFENT_CHANGED_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
		WriteByte(MSG_ENTITY, colormap);
	}
	if (fChanged & SRFENT_CHANGED_SOLID) {
		WriteByte(MSG_ENTITY, solid);
	}
	if (fChanged & SRFENT_CHANGED_MOVETYPE) {
		WriteByte(MSG_ENTITY, movetype);
	}
	if (fChanged & SRFENT_CHANGED_FLAGS) {
		WriteFloat(MSG_ENTITY, flags);
	}
	if (fChanged & SRFENT_CHANGED_SIZE) {
		WriteCoord(MSG_ENTITY, mins[0]);
		WriteCoord(MSG_ENTITY, mins[1]);
		WriteCoord(MSG_ENTITY, mins[2]);
		WriteCoord(MSG_ENTITY, maxs[0]);
		WriteCoord(MSG_ENTITY, maxs[1]);
		WriteCoord(MSG_ENTITY, maxs[2]);
	}
	if (fChanged & SRFENT_CHANGED_FRAME) {
		WriteByte(MSG_ENTITY, frame);
		WriteByte(MSG_ENTITY, frame1time);
	}
	if (fChanged & SRFENT_CHANGED_SKIN) {
		WriteByte(MSG_ENTITY, skin + 128);
	}
	if (fChanged & SRFENT_CHANGED_EFFECTS) {
		WriteFloat(MSG_ENTITY, effects);
	}
	if (fChanged & SRFENT_CHANGED_BODY) {
		WriteByte(MSG_ENTITY, m_iBody);
	}
	if (fChanged & SRFENT_CHANGED_SCALE) {
		WriteFloat(MSG_ENTITY, scale);
	}
	if (fChanged & SRFENT_CHANGED_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

	if (fChanged & SRFENT_CHANGED_RENDERMODE) {
		WriteByte(MSG_ENTITY, m_iRenderMode);
		WriteByte(MSG_ENTITY, m_iRenderFX);
	}

	if (fChanged & SRFENT_CHANGED_RENDERCOLOR) {
		WriteFloat(MSG_ENTITY, m_vecRenderColor[0]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[1]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[2]);
		WriteFloat(MSG_ENTITY, glowmod[0]);
		WriteFloat(MSG_ENTITY, glowmod[1]);
		WriteFloat(MSG_ENTITY, glowmod[2]);
	}
	if (fChanged & SRFENT_CHANGED_RENDERAMT) {
		WriteFloat(MSG_ENTITY, m_flRenderAmt);
	}
	if (fChanged & SRFENT_CHANGED_CONTROLLER) {
		WriteShort(MSG_ENTITY, m_flBoneControl1 * 32767 / 360);
		WriteShort(MSG_ENTITY, m_flBoneControl2 * 32767 / 360);
		WriteShort(MSG_ENTITY, m_flBoneControl3 * 32767 / 360);
		WriteShort(MSG_ENTITY, m_flBoneControl4 * 32767 / 360);
		WriteShort(MSG_ENTITY, m_flBoneControl5 * 32767 / 360);
	}

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
	if (flChanged & SRFENT_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}
	if (flChanged & SRFENT_CHANGED_ANGLES) {
		angles[0] = readshort() / (32767 / 360);
		angles[1] = readshort() / (32767 / 360);
		angles[2] = readshort() / (32767 / 360);
	}
	if (flChanged & SRFENT_CHANGED_MODELINDEX) {
		setmodelindex(this, readshort());
		colormap = readbyte();
	}
	if (flChanged & SRFENT_CHANGED_SOLID) {
		solid = readbyte();
	}
	if (flChanged & SRFENT_CHANGED_MOVETYPE) {
		movetype = readbyte();

		if (movetype == MOVETYPE_PHYSICS) {
			movetype = MOVETYPE_NONE;
		}
	}
	if (flChanged & SRFENT_CHANGED_FLAGS) {
		flags = readfloat();
	}
	if (flChanged & SRFENT_CHANGED_SIZE) {
		mins[0] = readcoord();
		mins[1] = readcoord();
		mins[2] = readcoord();
		maxs[0] = readcoord();
		maxs[1] = readcoord();
		maxs[2] = readcoord();
	}
	if (flChanged & SRFENT_CHANGED_FRAME) {
		frame = readbyte();
		frame1time =
		frame2time = readbyte();
	}
	if (flChanged & SRFENT_CHANGED_SKIN) {
		skin = readbyte() - 128;
	}
	if (flChanged & SRFENT_CHANGED_EFFECTS) {
		effects = readfloat();
	}
	if (flChanged & SRFENT_CHANGED_BODY) {
		m_iBody = readbyte();
		setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_iBody, m_iBody));
	}
	if (flChanged & SRFENT_CHANGED_SCALE) {
		scale = readfloat();
	}
	if (flChanged & SRFENT_CHANGED_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

	if (flChanged & SRFENT_CHANGED_RENDERMODE) {
		m_iRenderMode = readbyte();
		m_iRenderFX = readbyte();
	}
	if (flChanged & SRFENT_CHANGED_RENDERCOLOR) {
		m_vecRenderColor[0] = readfloat();
		m_vecRenderColor[1] = readfloat();
		m_vecRenderColor[2] = readfloat();
		glowmod[0] = readfloat();
		glowmod[1] = readfloat();
		glowmod[2] = readfloat();
	}
	if (flChanged & SRFENT_CHANGED_RENDERAMT) {
		m_flRenderAmt = readfloat();
	}
	if (flChanged & SRFENT_CHANGED_CONTROLLER) {
		m_flBoneControl1 = readshort() / (32767 / 360);
		m_flBoneControl2 = readshort() / (32767 / 360);
		m_flBoneControl3 = readshort() / (32767 / 360);
		m_flBoneControl4 = readshort() / (32767 / 360);
		m_flBoneControl5 = readshort() / (32767 / 360);
	}

	if (modelindex) {
		drawmask = MASK_ENGINE;
	} else {
		drawmask = 0;
	}

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & SRFENT_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);

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
	SaveFloat(handle, "m_eBurner", num_for_edict(m_eBurner));
	SaveInt(handle, "m_iBurnWeapon", m_iBurnWeapon);
	SaveFloat(handle,"m_flBurnTime", m_flBurnTime);
	SaveFloat(handle, "m_flBurnNext", m_flBurnNext);
	SaveString(handle, "m_strOnBreak", m_strOnBreak);
	SaveFloat(handle, "health", health);
	SaveFloat(handle, "m_oldHealth", m_oldHealth);
	SaveInt(handle, "m_iMaterial", m_iMaterial);
	SaveInt(handle, "m_iPropData", m_iPropData);

	super::Save(handle);
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
	case "health":
		health = ReadFloat(strValue);
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
		Hide();
	} else {
		Hide();
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
NSSurfacePropEntity::SurfaceDataFinish(void)
{
	SurfData_SetStage(m_strSurfData);

	if (m_strSurfData)
		m_iMaterial = SurfData_Finish();
	else
		m_iMaterial = -1;
}
void
NSSurfacePropEntity::PropDataFinish(void)
{
	PropData_SetStage(m_strPropData);

	if (m_strPropData)
		m_iPropData = PropData_Finish();
	else
		m_iPropData = -1;
}
#else
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

void
NSSurfacePropEntity::NSSurfacePropEntity(void)
{
#ifdef SERVER
	m_iPropData = -1;
	m_iMaterial = -1;
	max_health = 100;
	m_strOnBreak = __NULL__;
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
