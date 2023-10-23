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

.float max_angular;

/* taken from VPhysics-Jolt */
const float InchesToMeters = 0.0254f;
const float MetersToInches = 1.0f / 0.0254f;


void
NSPhysicsEntity::NSPhysicsEntity(void)
{
	mass = 1.0f;
	isPhysics = true;
	m_flInertiaScale = 1.0f;

	m_iEnabled = 0i;
	m_iShape = PHYSM_BOX;
	m_iMaterial = 0i;
	m_iFlags = 0i;
	damp_linear = 1.0f;
	damp_angular = 1.0f;
	max_angular = -1.0f;
	m_flMass = 1.0f;


	cvar_set("physics_ode_quadtree_depth",					"5");
	cvar_set("physics_ode_contactsurfacelayer",				"0");
	cvar_set("physics_ode_worldquickstep",					"1");
	cvar_set("physics_ode_worldquickstep_iterations",		"20");
	cvar_set("physics_ode_contact_mu",						"1");
	cvar_set("physics_ode_contact_erp",						"0.96");
	cvar_set("physics_ode_contact_cfm",						"0.001");
	cvar_set("physics_ode_world_damping",					"1");
	cvar_set("physics_ode_world_damping_linear",				"-1");
	cvar_set("physics_ode_world_damping_linear_threshold",	"-1");
	cvar_set("physics_ode_world_damping_angular",			"-1");
	cvar_set("physics_ode_world_damping_angular_threshold",	"-1");
	cvar_set("physics_ode_world_erp",						"-1");
	cvar_set("physics_ode_world_cfm",						"-1");
	cvar_set("physics_ode_iterationsperframe",				"4");
	cvar_set("physics_ode_movelimit",						"0.5");
	cvar_set("physics_ode_spinlimit",						"10000");
	cvar_set("physics_ode_autodisable",						"1");
	cvar_set("physics_ode_autodisable_steps",				"10");
	cvar_set("physics_ode_autodisable_time",					"0.1");
	cvar_set("physics_ode_autodisable_threshold_linear",		"0.2");
	cvar_set("physics_ode_autodisable_threshold_angular",	"0.3");
	cvar_set("physics_ode_autodisable_threshold_samples",	"5");

#ifdef SERVER
	m_strOnDamaged = __NULL__;
#endif
}

#ifdef SERVER
void
NSPhysicsEntity::Spawned(void)
{
	super::Spawned();

	/* I/O */
	if (m_strOnDamaged)
		m_strOnDamaged = CreateOutput(m_strOnDamaged);
}

void
NSPhysicsEntity::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iEnabled", m_iEnabled);
	SaveInt(handle, "m_iShape", m_iShape);
	SaveInt(handle, "m_iMaterial", m_iMaterial);
	SaveInt(handle, "m_iFlags", m_iFlags);
	SaveFloat(handle, "m_flInertiaScale", m_flInertiaScale);
	SaveString(handle, "m_strOnDamaged", m_strOnDamaged);
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
	case "m_strOnDamaged":
		m_strOnDamaged = ReadString(strValue);
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
	EVALUATE_FIELD(m_flMass, RDENT_CHANGED_SOLIDMOVETYPE)
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

	/* physics specific flags */
	SENDENTITY_FLOAT(m_flMass, RDENT_CHANGED_SOLIDMOVETYPE)

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

	/* physics specific flags */
	READENTITY_FLOAT(m_flMass, RDENT_CHANGED_SOLIDMOVETYPE)

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & RDENT_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);
	if (flChanged & RDENT_CHANGED_BODY)
		_UpdateGeomset();

	movetype = MOVETYPE_NONE;
	_UpdateMass();
}

void
NSPhysicsEntity::postdraw(void)
{
	if not (autocvar_r_showPhysicsInfo)
		return;

	if not (PointMessage_Visible(WorldSpaceCenter(), g_view.GetCameraOrigin(), g_view.GetCameraAngle()))
		return;

	float massVolume = (size[0] * size[1] * size[2]);
	massVolume *= 0.0254f; /* from meters to inches */

	string renderString = sprintf("Mass: %.2f kg (%.2f ODE)\nEnergy: %f kj\nInertia:%d\nVolume: %.2f",
		GetMass(), mass, GetEnergy(), GetInertia(), massVolume);

	PointMessage_StringAtPos(WorldSpaceCenter(), renderString);
}
#endif

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
		return (float)iDamage * autocvar_phys_impactforcescale;
	else
		return 0.0f;
}

int
NSPhysicsEntity_Contents(vector org)
{
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = -1;
	traceline(org, org, MOVE_EVERYTHING, self);
	self.hitcontentsmaski = oldhitcontents;
	return trace_endcontentsi;
}

#ifdef SERVER
void
NSPhysicsEntity::Touch(entity eToucher)
{
	if (eToucher)
		if (eToucher.movetype)
			Wake();
}
#endif

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
				Wake();
				makevectors(vectoangles(trace_endpos - trace_ent.origin));
				ApplyTorqueCenter(v_forward * 240);
			} else {
				Sleep();
				velocity = [0,0,0];
			}
		}
	}
	}

#if 0
	if (m_flCheckTime < time) {
		bool should
		if (vlen(m_vecPrevAngles - angles) < 1) {
			avelocity = [0,0,0];
		}
		if (vlen(m_vecPrevOrigin - origin) < 1) {
			velocity = [0,0,0];
		}
		m_flCheckTime = time + 1.0f;
		m_vecPrevOrigin = origin;
		m_vecPrevAngles = angles;
	}

	/* If we barely move, disable the physics simulator */
	if (velocity == g_vec_null && avelocity == g_vec_null) {
		if (m_iEnabled) {
			NSPhysics_Log("%s is now sleeping.", classname);
			Sleep();
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
#endif

#if 0
	if (m_flBuoyancyRatio > 0.0)
	if (NSPhysicsEntity_Contents(origin) & CONTENTBIT_WATER) {
		makevectors([0,0,0]);
		velocity[2] += m_flBuoyancyRatio;
		print(sprintf("in water... applying %v\n", v_up * (GetMass() * m_flBuoyancyRatio)));
	}
#endif

	hitcontentsmaski &= ~CONTENTBITS_FLUID;

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
	vector forceDir;
	float force;

	if (m_strOnDamaged)
		UseOutput(this, m_strOnDamaged);

	if (m_iFlags & BPHY_NODMGPUSH)
		return;

	Wake();

	forceDir = normalize(GetOrigin() - g_dmg_vecLocation);
	force = CalculateImpactDamage(g_dmg_iDamage, g_dmg_iFlags);

	if (force > 0.0f)
		ApplyForceOffset(forceDir * force, g_dmg_vecLocation);

	/* HACK: */
	if (m_bInvincible) {
		health = 10000;
	}

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

	/* HACK: */
	if (m_bInvincible) {
		health = 10000;
	}

	/* make sure touch think is called */
	nextthink = time;
}
#endif

void
NSPhysicsEntity::Respawn(void)
{
	ClearVelocity();
	SetMovetype(MOVETYPE_PHYSICS);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());

#ifdef SERVER
	SetTakedamage(DAMAGE_YES);
#endif

	Sleep();
	SetMass(1.0f);
	SetFriction(1.0f);
	SetBuoyancyRatio(1.0f);
	bouncefactor = 0.9f;
	bouncestop = 0.1f / cvar("sv_gravity");

	bouncefactor = 0.0f;
	bouncestop = 0.0f;

	geomtype = GEOMTYPE_TRIMESH;
	friction = 1.0f;

	SetOrigin(GetSpawnOrigin());
	m_flBuoyancyRatio = 1.0f;

	SetDamping(1.0f, 1.0f);
	EnableGravity(true);

	hitcontentsmaski &= ~CONTENTBITS_FLUID;

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
		SetHealth(GetPropData(PROPINFO_HEALTH));
		SetMass(GetPropData(PROPINFO_MASS));
		SetDamping(GetPropData(PROPINFO_DAMPING_LINEAR), GetPropData(PROPINFO_DAMPING_ANGULAR));
		SetInertia(GetPropData(PROPINFO_INERTIA));
		SetSurfaceData(GetPropData(PROPINFO_SURFACEPROP));
	} else {
		health = 0;
	}

	/* no health set, either indistructible or too weak */
	if (health == 0) {
		/* it has no breakmodels set, therefore it cannot break. */
		if (GetPropData(PROPINFO_BREAKMODEL) == __NULL__) {
			m_bInvincible = true;
			health = 10000;
		} else {
			/* something like glass bottles, maybe. */
			health = 1.0f;
		}
	}
#endif
}

void
NSPhysicsEntity::SpawnKey(string strKey, string strValue)
{
	bool tempCheck = false;

	switch (strKey) {
	case "physmodel":
		m_iShape = ReadInt(strValue);
		if (m_iShape > PHYSM_CYLINDER)
			m_iShape = 0;
		break;
	case "massscale":
		mass = ReadFloat(strValue);
		break;
	case "inertiascale":
		m_flInertiaScale = ReadFloat(strValue);
		break;
	case "physdamagescale":
		break;
	case "material":
		m_iMaterial = ReadFloat(strValue);
		break;
	case "nodamageforces":
		tempCheck = ReadBool(strValue);

		if (tempCheck == true)
			m_iFlags |= BPHY_NODMGPUSH;
		break;
	case "Damagetype":
		tempCheck = ReadBool(strValue);

		if (tempCheck == true)
			m_iFlags |= BPHY_SHARP;
		break;
#ifdef SERVER
	case "OnDamaged":
		m_strOnDamaged = PrepareOutput(m_strOnDamaged, strValue);
		break;
#endif
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

/* GMod API starts here */

vector
NSPhysicsEntity::AlignAngles(vector from, vector to)
{
	NSEntWarning("Not implemented");
	return angles;
}

void
NSPhysicsEntity::ApplyForceCenter(vector vecForce)
{
	Wake();

	vecForce *= MetersToInches;

	if (physics_supported() == TRUE) {
		vector finalForce = vecForce;
		physics_addforce(this, finalForce, GetMassCenter());

		NSPhysics_Log("%s::ApplyForceCenter: %v (val: %v)",
			classname, finalForce, vecForce);
	} else {
		velocity += vecForce;
	}

	/* make sure touch think is called */
	nextthink = time;
}

void
NSPhysicsEntity::ApplyForceOffset(vector vecForce, vector vecOffset)
{
	Wake();

	vecForce *= MetersToInches;

	if (physics_supported() == TRUE) {
		vector finalForce = vecForce;
		physics_addforce(this, finalForce, vecOffset);

		NSPhysics_Log("%s::ApplyForceOffset: %v at pos %v (val: %v)",
			classname, finalForce, vecOffset, vecForce);

#ifdef ODE_MODE
		//velocity += vecForce;
#endif
	} else {
		velocity += vecForce;
	}

	/* make sure touch think is called */
	nextthink = time;
}

void
NSPhysicsEntity::ApplyTorqueCenter(vector vecTorque)
{
	Wake();

	if (physics_supported() == TRUE) {
		vector finalTorque = vecTorque * m_flInertiaScale;
		physics_addtorque(this, finalTorque);

		NSPhysics_Log("%s::ApplyTorqueCenter: %v (val: %v, scale: %f)",
			classname, finalTorque, vecTorque, m_flInertiaScale);
	} else {
		avelocity = vecTorque;
		velocity = vecTorque;
		velocity[2] = 96;
	}

	/* make sure touch think is called */
	nextthink = time;
}

void
NSPhysicsEntity::EnableDrag(bool setEnabled)
{
	NSEntWarning("Not implemented");
}

void
NSPhysicsEntity::EnableGravity(bool setEnabled)
{
	/* the engine checks if .gravity is < 0.01...) */
	gravity = setEnabled ? 1.0f : 0.005;
}

void
NSPhysicsEntity::EnableMotion(bool setEnabled)
{
	NSEntWarning("Not implemented");
}

float
NSPhysicsEntity::GetLinearDamping(void)
{
	return damp_linear;
}

float
NSPhysicsEntity::GetAngularDamping(void)
{
	return damp_angular;
}

float
NSPhysicsEntity::GetEnergy(void)
{
	float linearEnergy;
	float rotationalEnergy;

	linearEnergy = (0.5f * GetMass() * vlen(GetVelocity()));
	linearEnergy *= linearEnergy;

	rotationalEnergy = (0.5f * GetMass() * vlen(GetAngularVelocity()));
	rotationalEnergy *= rotationalEnergy;

	return (linearEnergy + rotationalEnergy) / (InchesToMeters * InchesToMeters);
}

float
NSPhysicsEntity::GetInertia(void)
{
	return m_flInertiaScale;
}

float
NSPhysicsEntity::GetInvInertia(void)
{
	return 1.0f / m_flInertiaScale;
}

float
NSPhysicsEntity::GetInvMass(void)
{
	return 1.0f / mass;
}

float
NSPhysicsEntity::GetMass(void)
{
	return m_flMass;
}

vector
NSPhysicsEntity::GetMassCenter(void)
{
	return WorldSpaceCenter();
}

float
NSPhysicsEntity::GetRotDamping(void)
{
	return 0.0f;
}

float
NSPhysicsEntity::GetSpeedDamping(void)
{
	return 0.0f;
}

float
NSPhysicsEntity::GetSurfaceArea(void)
{
	return vlen(size) / 4;
}

float
NSPhysicsEntity::GetVolume(void)
{
	return vlen(size);
}

bool
NSPhysicsEntity::IsAsleep(void)
{
	return false;
}

bool
NSPhysicsEntity::IsCollisionEnabled(void)
{
	return true;
}

bool
NSPhysicsEntity::IsDragEnabled(void)
{
	return true;
}

bool
NSPhysicsEntity::IsGravityEnabled(void)
{
	return (gravity < 0.01) ? false : true;
}

bool
NSPhysicsEntity::IsMotionEnabled(void)
{
	return true;
}

bool
NSPhysicsEntity::IsMoveable(void)
{
	return true;
}

bool
NSPhysicsEntity::IsPenetrating(void)
{
	return true;
}

void
NSPhysicsEntity::SetAngleDragCoefficient(float setValue)
{
	NSEntWarning("Not implemented");
}

void
NSPhysicsEntity::SetBuoyancyRatio(float setValue)
{
	m_flBuoyancyRatio = setValue;
}

void
NSPhysicsEntity::SetDamping(float linearDamp, float angleDamp)
{
	damp_linear = linearDamp;
	damp_angular = angleDamp;
}

void
NSPhysicsEntity::SetDragCoefficient(float dragValue)
{
	NSEntWarning("Not implemented");
}

void
NSPhysicsEntity::SetInertia(float val)
{
	m_flInertiaScale = val;
}

void
NSPhysicsEntity::_UpdateMass(void)
{
	/* in ODE, mass is relative. */
	float massVolume = (size[0] * size[1] * size[2]);
	massVolume *= 0.0254f; /* from inches to meters */

	mass = 1.0f;
	//mass = m_flMass / massVolume; /* really ODE's thing is density */
}

void
NSPhysicsEntity::_UpdateBuoyancy(void)
{
#if 0
	if ( m_flVolume != 0.0f )
	{
		float flVolume = max( m_flVolume, 5.0f ) * MeterstoInches * MeterstoInches * MeterstoInches;
		float flDensity = m_flMass / flVolume;
		m_flBuoyancyRatio = flDensity / m_flMaterialDensity;
	}
	else
	{
		m_flBuoyancyRatio = 1.0f;
	}
#endif
}

void
NSPhysicsEntity::SetMass(float val)
{
	m_flMass = val;
	_UpdateMass();
}

void
NSPhysicsEntity::Wake(void)
{
	if (physics_supported() == TRUE) {
		SetMovetype(MOVETYPE_PHYSICS);
		SetSolid(SOLID_BSP);
		physics_enable(this, TRUE);
	} else {
		SetMovetype(MOVETYPE_BOUNCE);
		SetSolid(SOLID_CORPSE);
	}
	m_iEnabled = TRUE;
}

void
NSPhysicsEntity::Sleep(void)
{
	if (physics_supported() == TRUE) {
		ClearVelocity();
		physics_enable(this, FALSE);
		SetMovetype(MOVETYPE_NONE);
	} else {
		SetMovetype(MOVETYPE_NONE);
		SetSolid(SOLID_BBOX);
	}
	m_iEnabled = FALSE;
}