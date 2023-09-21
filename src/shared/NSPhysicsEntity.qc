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

//#define ODE_MODE 1

void
NSPhysicsEntity::NSPhysicsEntity(void)
{
	mass = 1.0f;
	m_flInertiaScale = 1.0f;

	m_iEnabled = 0i;
	m_iShape = PHYSM_BOX;
	m_iMaterial = 0i;
	m_iFlags = 0i;

#ifdef ODE_MODE
	cvar_set("physics_ode_iterationsperframe", "1");
	cvar_set("physics_ode_movelimit", "0.1");
#else
	cvar_set("physics_bullet_maxiterationsperframe", "10");
	cvar_set("physics_bullet_framerate", "60");
#endif
}

#ifdef SERVER
void
NSPhysicsEntity::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iEnabled", m_iEnabled);
	SaveInt(handle, "m_iShape", m_iShape);
	SaveInt(handle, "m_iMaterial", m_iMaterial);
	SaveInt(handle, "m_iFlags", m_iFlags);
	SaveFloat(handle, "m_flInertiaScale", m_flInertiaScale);
}

void
NSPhysicsEntity::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iEnabled":
		m_iEnabled = ReadInt(strValue);
		break;
	case "m_iShape":
		m_iShape = ReadInt(strValue);
		break;
	case "m_iMaterial":
		m_iMaterial = ReadInt(strValue);
		break;
	case "m_iFlags":
		m_iFlags = ReadInt(strValue);
		break;
	case "m_flInertiaScale":
		m_flInertiaScale = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}
#endif

#ifdef CLIENT
bool physics_supported(void)
{
	return true;
}
#endif

/* all the documented phys vars...*/
.float geomtype;
.float friction;
.float erp;
.float jointtype;
.float mass;
.float bouncefactor;
.float bouncestop;

#ifdef SERVER
void
NSPhysicsEntity::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, RDENT_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, RDENT_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, RDENT_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, RDENT_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, RDENT_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, RDENT_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, RDENT_CHANGED_MODELINDEX)
	EVALUATE_FIELD(colormap, RDENT_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, RDENT_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(movetype, RDENT_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(flags, RDENT_CHANGED_FLAGS)
	EVALUATE_FIELD(modelflags, RDENT_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, RDENT_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, RDENT_CHANGED_SIZE)
	EVALUATE_FIELD(frame, RDENT_CHANGED_FRAME)
	EVALUATE_FIELD(frame1time, RDENT_CHANGED_FRAME)
	EVALUATE_FIELD(skin, RDENT_CHANGED_SKIN)
	EVALUATE_FIELD(effects, RDENT_CHANGED_EFFECTS)
	EVALUATE_FIELD(m_iBody, RDENT_CHANGED_BODY)
	EVALUATE_FIELD(scale, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 0, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 1, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(m_vecAxialScale, 2, RDENT_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, RDENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, RDENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, RDENT_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, RDENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, RDENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, RDENT_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_iRenderMode, RDENT_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_iRenderFX, RDENT_CHANGED_RENDERMODE)
	EVALUATE_VECTOR(m_vecRenderColor, 0, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 0, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 1, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 2, RDENT_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flRenderAmt, RDENT_CHANGED_RENDERAMT)
	EVALUATE_FIELD(m_flBoneControl1, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl2, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl3, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl4, RDENT_CHANGED_CONTROLLER)
	EVALUATE_FIELD(m_flBoneControl5, RDENT_CHANGED_CONTROLLER)
}

float
NSPhysicsEntity::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_PHYSICS);

	/* optimisation */
	{
		/* we'll never network these if we aren't moving. */
		if (movetype == MOVETYPE_NONE) {
			flChanged &= ~RDENT_CHANGED_VELOCITY;
			flChanged &= ~RDENT_CHANGED_ANGULARVELOCITY;
		}

		/* no rendermode means no extra fields */
		if (m_iRenderMode == RM_NORMAL && m_iRenderFX == RFX_NORMAL) {
			flChanged &= ~RDENT_CHANGED_RENDERMODE;
			//flChanged &= ~RDENT_CHANGED_RENDERCOLOR; /* glowmod needs this */
			flChanged &= ~RDENT_CHANGED_RENDERAMT;
		}

		if (m_bIsBrush == true) {
			flChanged &= ~RDENT_CHANGED_FLAGS;
			flChanged &= ~RDENT_CHANGED_BODY;
			flChanged &= ~RDENT_CHANGED_SCALE;
			flChanged &= ~RDENT_CHANGED_CONTROLLER;
		}
	}

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], RDENT_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], RDENT_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], RDENT_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], RDENT_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], RDENT_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], RDENT_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, RDENT_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(colormap, RDENT_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, RDENT_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_BYTE(movetype, RDENT_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_INT(flags, RDENT_CHANGED_FLAGS)
	SENDENTITY_INT(modelflags, RDENT_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], RDENT_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], RDENT_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, RDENT_CHANGED_FRAME)
	SENDENTITY_FLOAT(frame1time, RDENT_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, RDENT_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, RDENT_CHANGED_EFFECTS)
	SENDENTITY_SHORT(m_iBody, RDENT_CHANGED_BODY)
	SENDENTITY_FLOAT(scale, RDENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[0], RDENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[1], RDENT_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_vecAxialScale[2], RDENT_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], RDENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], RDENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], RDENT_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], RDENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], RDENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], RDENT_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_iRenderMode, RDENT_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, RDENT_CHANGED_RENDERMODE)
	SENDENTITY_COLOR(m_vecRenderColor[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_vecRenderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	SENDENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_COLOR(m_flRenderAmt, RDENT_CHANGED_RENDERAMT)
	SENDENTITY_ANGLE(m_flBoneControl1, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl2, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl3, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl4, RDENT_CHANGED_CONTROLLER)
	SENDENTITY_ANGLE(m_flBoneControl5, RDENT_CHANGED_CONTROLLER)

	return (1);
}
#else

/*
============
NSPhysicsEntity::ReceiveEntity
============
*/
void
NSPhysicsEntity::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], RDENT_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], RDENT_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], RDENT_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], RDENT_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], RDENT_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], RDENT_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, RDENT_CHANGED_MODELINDEX)
	READENTITY_BYTE(colormap, RDENT_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, RDENT_CHANGED_SOLIDMOVETYPE)
	READENTITY_BYTE(movetype, RDENT_CHANGED_SOLIDMOVETYPE)
	READENTITY_INT(flags, RDENT_CHANGED_FLAGS)
	READENTITY_INT(modelflags, RDENT_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], RDENT_CHANGED_SIZE)
	READENTITY_COORD(mins[1], RDENT_CHANGED_SIZE)
	READENTITY_COORD(mins[2], RDENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], RDENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], RDENT_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], RDENT_CHANGED_SIZE)
	READENTITY_BYTE(frame, RDENT_CHANGED_FRAME)
	READENTITY_FLOAT(frame1time, RDENT_CHANGED_FRAME)
	READENTITY_FLOAT(skin, RDENT_CHANGED_SKIN)
	READENTITY_FLOAT(effects, RDENT_CHANGED_EFFECTS)
	READENTITY_SHORT(m_iBody, RDENT_CHANGED_BODY)
	READENTITY_FLOAT(scale, RDENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[0], RDENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[1], RDENT_CHANGED_SCALE)
	READENTITY_FLOAT(m_vecAxialScale[2], RDENT_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], RDENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], RDENT_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], RDENT_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], RDENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], RDENT_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], RDENT_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_iRenderMode, RDENT_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, RDENT_CHANGED_RENDERMODE)
	READENTITY_COLOR(m_vecRenderColor[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_vecRenderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	READENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_COLOR(m_flRenderAmt, RDENT_CHANGED_RENDERAMT)
	READENTITY_ANGLE(m_flBoneControl1, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl2, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl3, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl4, RDENT_CHANGED_CONTROLLER)
	READENTITY_ANGLE(m_flBoneControl5, RDENT_CHANGED_CONTROLLER)

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & RDENT_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);
	if (flChanged & RDENT_CHANGED_BODY)
		_UpdateGeomset();

	movetype = MOVETYPE_NONE;
}
#endif


void
NSPhysicsEntity::PhysicsEnable(void)
{
	if (physics_supported() == TRUE) {
		SetMovetype(MOVETYPE_PHYSICS);
		SetSolid(SOLID_PHYSICS_BOX + m_iShape);
		physics_enable(this, TRUE);
	} else {
		SetMovetype(MOVETYPE_BOUNCE);
		SetSolid(SOLID_CORPSE);
	}
	m_iEnabled = TRUE;
}

void
NSPhysicsEntity::PhysicsDisable(void)
{
	if (physics_supported() == TRUE) {
		physics_enable(this, FALSE);
		SetMovetype(MOVETYPE_NONE);
	} else {
		SetMovetype(MOVETYPE_NONE);
		SetSolid(SOLID_BBOX);
	}
	m_iEnabled = FALSE;
}

void
NSPhysicsEntity::SetMass(float val)
{
	mass = val;
}
float
NSPhysicsEntity::GetMass(void)
{
	return mass;
}

void
NSPhysicsEntity::SetFriction(float val)
{
	friction = val;
}
float
NSPhysicsEntity::GetFriction(void)
{
	return friction;
}

void
NSPhysicsEntity::SetBounceFactor(float val)
{
	bouncefactor = val;
}
float
NSPhysicsEntity::GetBounceFactor(void)
{
	return bouncefactor;
}

void
NSPhysicsEntity::SetBounceStop(float val)
{
	bouncestop = val;
}
float
NSPhysicsEntity::GetBounceStop(void)
{
	return bouncestop;
}

void
NSPhysicsEntity::SetInertia(float val)
{
	m_flInertiaScale = val;
}
float
NSPhysicsEntity::GetInertia(void)
{
	return m_flInertiaScale;
}

float
NSPhysicsEntity::CalculateImpactDamage(int iDamage, int dmgType)
{
	int filter = 0i;

	/* if we're any of these dmg types, we don't transfer any kinetic energy */
	filter |= (dmgType & DMG_BURN);
	filter |= (dmgType & DMG_ELECTRO);
	filter |= (dmgType & DMG_SOUND);
	filter |= (dmgType & DMG_ENERGYBEAM);
	filter |= (dmgType & DMG_DROWN);
	filter |= (dmgType & DMG_POISON);
	filter |= (dmgType & DMG_RADIATION);
	filter |= (dmgType & DMG_ACID);
	filter |= (dmgType & DMG_ACID);
	filter |= (dmgType & DMG_SLOWFREEZE);

	if (filter == 0i)
		return (float)iDamage * 100;
	else
		return 0.0f;
}

void
NSPhysicsEntity::ApplyForceCenter(vector vecForce)
{
	if (physics_supported() == TRUE) {
		physics_addforce(this, vecForce, [0,0,0]);
	} else {
		velocity = vecForce;
	}

	/* make sure touch think is called */
	nextthink = time;
}

void
NSPhysicsEntity::ApplyForceOffset(vector vecForce, vector vecOffset)
{
	if (physics_supported() == TRUE) {
		physics_addforce(this, vecForce, vecOffset);
	} else {
		velocity = vecForce;
	}

	/* make sure touch think is called */
	nextthink = time;
}

void
NSPhysicsEntity::ApplyTorqueCenter(vector vecTorque)
{
	if (physics_supported() == TRUE)
		physics_addtorque(this, vecTorque * m_flInertiaScale);
	else {
		avelocity = vecTorque;
		velocity = vecTorque;
		velocity[2] = 96;
	}

	/* make sure touch think is called */
	nextthink = time;
}

void
NSPhysicsEntity::_TouchThink(void)
{
	if (!m_iEnabled) {
		return;
	}

	if (physics_supported() == FALSE) {
	/* let players collide */
	dimension_solid = 255;
	dimension_hit = 255;

	tracebox(origin, mins, maxs, origin, FALSE, this);

	/* stuck */
	if (trace_startsolid) {
		if (trace_ent.flags & FL_CLIENT) {
			if (trace_ent.absmin[2] < absmax[2]) {
				PhysicsEnable();
				makevectors(vectoangles(origin - trace_ent.origin));
				ApplyTorqueCenter(v_forward * 240);
			} else {
				PhysicsDisable();
				velocity = [0,0,0];
			}
		}
	}
	}

	/* If we barely move, disable the physics simulator */
	if (vlen(velocity) <= 1) {
		if (m_iEnabled) {
			PhysicsDisable();
			velocity = [0,0,0];
			avelocity = [0,0,0];
		}

		if (physics_supported() == FALSE) {
			vector wantangle;
			vector newangle;
			wantangle[0] = (int)((angles[0] + 45) / 90) * 90;
			wantangle[1] = angles[1];
			wantangle[2] = (int)((angles[2] + 45) / 90) * 90;

			makevectors(angles);
			angles = v_forward;
			makevectors(wantangle);
			newangle[0] = Math_Lerp(angles[0], v_forward[0], frametime * 5.0f);
			newangle[1] = Math_Lerp(angles[1], v_forward[1], frametime * 5.0f);
			newangle[2] = Math_Lerp(angles[2], v_forward[2], frametime * 5.0f);
			angles = vectoangles(newangle);
		}
	}

	if (physics_supported() == FALSE) {
		/* don't let players collide */
		dimension_solid = 1;
		dimension_hit = 1;
	}

	/* continue testing next frame */
	nextthink = time;
	effects &= ~EF_NOSHADOW;
}

#ifdef SERVER
void
NSPhysicsEntity::Pain(void)
{
	float force;

	if (m_iFlags & BPHY_NODMGPUSH)
		return;

	PhysicsEnable();

	makevectors(vectoangles(origin - trace_endpos));
	force = CalculateImpactDamage(g_dmg_iDamage, g_dmg_iFlags);

	if (force > 0.0f)
		ApplyForceOffset(v_forward * force, origin - trace_endpos);

	/* if we don't have prop data, don't consider death */
	if (HasPropData() == false)
		health = 10000;

	/* make sure touch think is called */
	nextthink = time;
}

void
NSPhysicsEntity::Death(void)
{
	Pain();
	super::Death();

	if (takedamage != DAMAGE_YES) {
		takedamage = (DAMAGE_YES);
	}
	health = 1000;

	/* make sure touch think is called */
	nextthink = time;
}
#endif

void
NSPhysicsEntity::Respawn(void)
{
	SetMovetype(MOVETYPE_PHYSICS);
	SetSolid(SOLID_PHYSICS_BOX + m_iShape);
	SetModel(GetSpawnModel());

#ifdef SERVER
	SetTakedamage(DAMAGE_YES);
#endif

#ifndef ODE_MODE
	PhysicsDisable();
	SetFriction(4.0f);
	SetBounceFactor(0.05f);
	SetMass(1.0f);
#else
	PhysicsDisable();
	SetMass(1.0f);
	SetFriction(1.0f);
	SetBounceFactor(0.1f);
	geomtype = GEOMTYPE_TRIMESH;
#endif

	SetOrigin(GetSpawnOrigin());

	if (physics_supported() == FALSE) {
		/* don't let players collide */
		dimension_solid = 1;
		dimension_hit = 1;
	}

	think = _TouchThink;
	nextthink = time + 0.1f;

	effects &= ~EF_NOSHADOW;

#ifdef SERVER
	if (HasPropData()) {
		health = GetPropData(PROPINFO_HEALTH);
	} else {
		health = 100000;
	}
#endif
}

void
NSPhysicsEntity::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "physmodel":
		m_iShape = stoi(strValue);
		if (m_iShape > PHYSM_CYLINDER)
			m_iShape = 0;
		break;
	case "massscale":
		mass = stof(strValue);
		break;
	case "inertiascale":
		m_flInertiaScale = stof(strValue);
		break;
	case "physdamagescale":
		break;
	case "material":
		m_iMaterial = stof(strValue);
		break;
	case "nodamageforces":
		if (strValue == "1")
			m_iFlags |= BPHY_NODMGPUSH;
		break;
	case "Damagetype":
		if (strValue == "1")
			m_iFlags |= BPHY_SHARP;
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}