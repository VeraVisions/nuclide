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

/* all the documented phys vars...*/
.float geomtype;
.float friction;
.float erp;
.float jointtype;
.float mass;
.float bouncefactor;
.float bouncestop;
.float max_angular;

/* taken from VPhysics-Jolt (with permission!) */
const float InchesToMeters = 0.0254f;
const float MetersToInches = 1.0f / 0.0254f;
const float MinimumImpactForce = 2.5;
const float MinimumScrapeSpeed = 100.0f;


#ifdef SERVER
var float LastImpactTime;
#endif

#ifdef PHYSICS_LIMIT_OPS
/* possible future optimisation */
//#define PHYSICS_LIMIT_OPS
const int g_physMaxDamageOperations = 32;
var int g_physDamageOperations = 0;
#endif

var bool autocvar_phys_lowspec = true;

bool
Physics_Simple(void)
{
	if (time < 5.0f) {
		return (true);
	}

	return (false);
}

void
ncPhysicsEntity::ncPhysicsEntity(void)
{
	mass = 1.0f;
	isPhysics = true;
	m_flInertiaScale = 1.0f;
	m_iEnabled = 0i;
	m_iShape = autocvar_phys_lowspec == false ? GEOMTYPE_TRIMESH : GEOMTYPE_BOX;
	m_iMaterial = 0i;
	m_iFlags = 0i;
	m_flMass = 1.0f;
	max_angular = 6500.0f;

#ifdef SERVER
	m_strOnDamaged = __NULL__;
#endif

	m_lastTouchTime = 0.0f;
}

void
ncPhysicsEntity::SetModel(string modelPath)
{
	super::SetModel(modelPath);

	float sizeLength = length(GetSize());

	//printf("Gib Size: %f\n", sizeLength);

	/* smaller/thinner models benefit from not being an expensive trimesh. */
	if (sizeLength < 32) {
		m_iShape = GEOMTYPE_BOX;
	} else {
		m_iShape = autocvar_phys_lowspec == false ? GEOMTYPE_TRIMESH : GEOMTYPE_BOX;
	}
}

#ifdef SERVER
void
ncPhysicsEntity::Spawned(void)
{
	super::Spawned();

	/* I/O */
	if (STRING_SET(m_strOnDamaged))
		m_strOnDamaged = CreateOutput(m_strOnDamaged);
}

void
ncPhysicsEntity::Save(float handle)
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
ncPhysicsEntity::Restore(string strKey, string strValue)
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


#ifdef SERVER
void
ncPhysicsEntity::EvaluateEntity(void)
{
	/* attempt at making of a less of a mess at spawn time */
	if (m_spawnPhysTime > GetTime()) {
// 		cvar_set("physics_ode_maxspeed", "100");
		friction = 400.0f;
		bouncefactor = -1;
		max_angular = 100;
		gravity = 100;
		velocity[0] = velocity[1] = 0;
		avelocity = g_vec_null;
		velocity[2] *= 0.5f;
	} else {
// 		cvar_set("physics_ode_maxspeed", "800");
		friction = 1.0f;
		bouncefactor = 0.0;
		max_angular = 6500.0f;
		gravity = 1;
	}

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
ncPhysicsEntity::SendEntity(entity ePEnt, float flChanged)
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
	SENDENTITY_BYTE(m_vecRenderColor[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_vecRenderColor[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_vecRenderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	SENDENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_flRenderAmt, RDENT_CHANGED_RENDERAMT)
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
ncPhysicsEntity::ReceiveEntity
============
*/
void
ncPhysicsEntity::ReceiveEntity(float flNew, float flChanged)
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
	READENTITY_BYTE(m_vecRenderColor[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_vecRenderColor[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_vecRenderColor[2], RDENT_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	READENTITY_FLOAT(glowmod[0], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[1], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[2], RDENT_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_flRenderAmt, RDENT_CHANGED_RENDERAMT)
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
ncPhysicsEntity::postdraw(void)
{
	super::postdraw();

	if not (autocvar_r_showPhysicsInfo)
		return;

	if not (PointMessage_Visible(WorldSpaceCenter(), g_view.GetCameraOrigin(), g_view.GetCameraAngle()))
		return;

	float massVolume = (size[0] * size[1] * size[2]);
	massVolume *= InchesToMeters; /* from meters to inches */

	string renderString = sprintf("Mass: %.2f kg (%.2f ODE)\nEnergy: %d kj\nInertia: %d\nVolume: %.2f",
		GetMass(), mass, GetEnergy() * (1.0 / 1024), GetInertia(), massVolume);

	PointMessage_FieldAtPos(WorldSpaceCenter(), renderString, 256);
}
#endif

void
ncPhysicsEntity::SetFriction(float val)
{
	friction = val;
}
float
ncPhysicsEntity::GetFriction(void)
{
	return friction;
}


float
ncPhysicsEntity::CalculateImpactDamage(int iDamage, int dmgType)
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
	filter |= (dmgType & DMG_SLOWFREEZE);

	if (filter == 0i)
		return (float)iDamage;
	else
		return 0.0f;
}

int
ncPhysicsEntity_Contents(entity target, vector org)
{
	target.hitcontentsmaski = -1;
	traceline(org, org, MOVE_EVERYTHING, target);
	target.hitcontentsmaski = CONTENTBITS_POINTSOLID;
	return trace_endcontentsi;
}

#ifdef SERVER
void
ncPhysicsEntity::Touch(entity eToucher)
{
	if (eToucher.solid == SOLID_TRIGGER)
		return;

	float timeDelta = time - m_lastTouchTime;
#if 1
	float impactForce = (GetEnergy()) * timeDelta;

	/* very, very large number. we pulled this one out of a hat (trial and error for what felt okay.)
	   for precision reasons, this is applied twice (we cannot have floats with that many decimal
	   places...) and we're also only multiplying the 2nd magic-number to try and preserve as much of
	   impactForce as possible. */
	impactForce *= 0.00001;
	impactForce *= (0.00001 * autocvar_phys_impactforcescale);
#else
	float impactForce = GetMass() * ((length(GetVelocity()) * InchesToMeters) * timeDelta);
#endif

	vector forward = normalize(GetVelocity());
	float scrapeDot = dotproduct(GetTouchNormal(), forward); /* < 0.9 == scraping across instead of facing towards plane */

	if (time != m_lastTouchTime) {
		/* scrape check */
		if (impactForce > MinimumImpactForce && scrapeDot < 0.5f) {
			if (fabs(avelocity[0]) > MinimumScrapeSpeed) {
				StartSoundDef(GetSurfaceData(SURFDATA_SND_ROLL), CHAN_BODY, true);
			} else {
				#warning TODO: differentiate between rough & smooth
				StartSoundDef(GetSurfaceData(SURFDATA_SND_SCRAPEROUGH), CHAN_BODY, true);
			}
			m_bFeedbackSounds = true;
		} else if (impactForce > MinimumImpactForce) {
			string newFXImpact = "";
			float materialID = GetSurfaceData(SURFDATA_MATERIAL);
			#warning TODO: Move this into typeinfo decl
			switch (materialID) {
	// 		case 'C':
	// 		case 'T':
	// 			newFXImpact = "impact.concrete";
	//			break;
	// 		case 'W':
	// 			newFXImpact = "impact.wood";
	// 			break;
	// 		case 'D':
	// 			newFXImpact = "impact.dirt";
	// 			break;
	// 		case 'N':
	// 			newFXImpact = "impact.sand";
	// 			break;
	// 		case 'A':
	// 			newFXImpact = "impact.alien";
	//			break;
			case 'M':
			case 'V':
				newFXImpact = "impact.metal";
				break;
	//		case 'C':
	// 			newFXImpact = "impact.computer";
	//			break;
	//		case 'F':
	// 			newFXImpact = "impact.flesh";
			default:
				newFXImpact = "impact.dust";
				break;
			}

			if (STRING_SET(newFXImpact)) {
				pointparticles(particleeffectnum(newFXImpact), GetTouchPosition(), GetTouchNormal(), 1);
			}

			#warning TODO: differentiate between rough & smooth
			StartSoundDef(GetSurfaceData(SURFDATA_SND_IMPACTHARD), CHAN_VOICE, true);
		} else if (m_bFeedbackSounds == true) {
			StopSound(CHAN_BODY, true);
			m_bFeedbackSounds = false;
		}
	}

	/* if we're being held by a player, don't do anything funny! */
	if (owner) {
		m_lastTouchTime = time;
		return;
	}

	if (GetHealth() <= 0) {
		m_lastTouchTime = time;
		return;
	}

	if (Physics_Simple() == true) {
		m_lastTouchTime = time;
		return;
	}

	/* ensure that on map spawn, things just fall to the ground without taking damage */
	if (impactForce > 0.0 && time != m_lastTouchTime) {
		//float opposingForce = length(eToucher.velocity) * 0.01;

		if (m_spawnPhysTime > GetTime()) {
			impactForce = 0.0f;
		}

		if (impactForce < 5.0f) {
			impactForce = 0.0f;
		} else {
			impactForce = floor(impactForce);
		#ifdef PHYSICS_LIMIT_OPS
			/* same frame as last impact? limit damage we can do per frame to avoid gib spawns */
			if (LastImpactTime == GetTime()) {
				g_physDamageOperations++;

				if (g_physDamageOperations > g_physMaxDamageOperations) {
					m_lastTouchTime = time;
					return;
				}
			} else {
				g_physDamageOperations = 0;
			}
		#endif

			/* HACK: If the toucher is standing on the entity, reduce damage done and kick them up. */
			if (eToucher.groundentity == this) {
#if 1
				impactForce = 0.0f;
#else
				/* when we stand on top of it, we have a certain weight and minimum damage requirement */
				if (impactForce < 20.0f) {
					impactForce = 0.0f;
				} else {
					/* get us unstuck */
					setorigin_safe(eToucher, eToucher.origin);
					eToucher.velocity[2] = (impactForce * 10.0f);
					impactForce *= 0.1f;
					velocity *= 0.25f;
				}
#endif
			}
		}

		ncDict damageDecl;
		if (eToucher && impactForce >= 1.0 && eToucher.takedamage != DAMAGE_NO) {
			ncSurfacePropEntity impactingEntity = (ncSurfacePropEntity)eToucher;
			damageDecl = spawn(ncDict);
			damageDecl.AddKey("damage", ftos(impactForce));
			damageDecl.AddKey("push", "0"); /* avoid physics recursion/amplification */
			impactingEntity.Damage(this, this, damageDecl, 1.0f, g_vec_null, GetOrigin());
			remove(damageDecl);
		} else {
			if (impactForce > GetHealth()) {
				damageDecl = spawn(ncDict);
				damageDecl.AddKey("damage", ftos(impactForce));
				damageDecl.AddKey("push", "0"); /* avoid physics recursion/amplification */
				Damage(eToucher, eToucher, damageDecl, 1.0f, g_vec_null, GetOrigin());
				remove(damageDecl);
				//printf("New health: %d, impact force: %d\n", health, impactForce);
			}
		}
	}

	/* we've gotten into contact with another entity */
	if (eToucher && impactForce > 5.0f) {
		/* it's probably able to push us out of the way. */
		if (eToucher.movetype) {
			Wake();
		}
	}

#if 0
	/* we're getting someone stuck or something */
	if (eToucher && eToucher.velocity[2] < 0.0) {
		eToucher.velocity[2] *= -1;
		ClearVelocity();
	}
#endif

	m_lastTouchTime = time;
	LastImpactTime = GetTime();
}
#endif

#if 0
void
ncPhysicsEntity::_TouchThink(void)
{
	if (IsAsleep() == true) {
		return;
	}

	if (physics_supported() == FALSE && GetSolid() != SOLID_CORPSE) {
		EnablePlayerCollision();

		tracebox(origin, mins, maxs, origin, FALSE, this);

		/* stuck */
		if (trace_startsolid) {
			if (trace_ent.flags & FL_CLIENT) {
				if (trace_ent.absmin[2] < absmax[2]) {
					vector dirVec = trace_endpos - trace_ent.origin;
					Wake();
					ApplyTorqueCenter(anglesToForward(vectorToAngles(dirVec)) * 240);
				} else {
					Sleep();
					velocity = [0,0,0];
				}
			}
		}
	}

#if 1
	if (m_flCheckTime < time) {
		if (lengthSquared(m_vecPrevAngles - angles) < 4) {
			avelocity = g_vec_null;
		}
		if (lengthSquared(m_vecPrevOrigin - origin) < 4) {
			velocity = g_vec_null;
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
			newangle = vectorLerp(anglesToForward(angles), anglesToForward(wantangle), frametime * 5.0f);
			angles = vectorToAngles(newangle);
		}
	}
#endif

#if 1
	if (m_flBuoyancyRatio > 0.0)
	if (ncPhysicsEntity_Contents(this, origin) & CONTENTBIT_WATER) {
		velocity[2] += m_flBuoyancyRatio * frametime;
	}
#endif

	if (physics_supported() == FALSE && GetSolid() != SOLID_CORPSE) {
		DisablePlayerCollision();
	}
}
#endif

#ifdef SERVER
void
ncPhysicsEntity::Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	if (modelindex == 0) {
		return;
	}

	if (m_strOnDamaged) {
		UseOutput(this, m_strOnDamaged);
	}

	if (m_iFlags & BPHY_NODMGPUSH) {
		return;
	}

	Wake();

	/* HACK: */
	if (m_bInvincible) {
		health = 10000;
	}
}

void
ncPhysicsEntity::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	if (modelindex == 0) {
		return;
	}

	if (m_bInvincible) {
		health = 10000;
		return;
	}

	Pain(inflictor, attacker, damage, dir, absImpactPos, hitBody);
	super::Death(inflictor, attacker, damage, dir, absImpactPos, hitBody);

	if (!modelindex) {
		geomtype = GEOMTYPE_NONE;
		SetMovetype(MOVETYPE_NONE);
		SetSolid(SOLID_NOT);
		ReleaseThink();
	}
}
#endif

void
ncPhysicsEntity::Respawn(void)
{
	super::Respawn();

	/* make turning on spawn difficult, see EvaluateEntity() */
	m_spawnPhysTime = GetTime() + 2.0f;
	max_angular = 0.1f;
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PHYSICS);
	ClearVelocity();
	Sleep();

#ifdef SERVER
	MakeVulnerable();
#endif

	SetMass(1.0f);
	SetFriction(1.0f);
	SetBuoyancyRatio(1.0f);

	geomtype = GEOMTYPE_BOX;
	friction = 1.0f;

	m_flBuoyancyRatio = 1.0f;

	SetDamping(0.0f, 0.0f);
	EnableGravity(true);

	hitcontentsmaski = CONTENTBITS_POINTSOLID;

	if (physics_supported() == FALSE && GetSolid() != SOLID_CORPSE) {
		DisablePlayerCollision();
	}

	Wake();

#ifdef SERVER
	if (HasPropData()) {
		SetMass(GetPropData(PROPINFO_MASS));
		SetDamping(GetPropData(PROPINFO_DAMPING_LINEAR), GetPropData(PROPINFO_DAMPING_ANGULAR));
		SetInertia(GetPropData(PROPINFO_INERTIA));
		SetSurfaceData(GetPropData(PROPINFO_SURFACEPROP));
	}


	if (HasPropData()) {
		SetHealth(GetPropData(PROPINFO_HEALTH));
	}

	/* no health set, either indistructible or too weak */
	if (health == 0) {
		/* it has no breakmodels set, therefore it cannot break. */
		if (GetPropData(PROPINFO_BREAKMODEL) == __NULL__) {
			m_bInvincible = true;
			health = 10000;
		} else {
			/* something like glass bottles, maybe. */
			health = 5;
			m_bInvincible = false;
		}
	}

	customphysics = PVSCheck;
#endif

}

#ifdef SERVER
void
ncPhysicsEntity::PVSCheck(void)
{
	/* check if we're supposed to be awake */
	if (m_pvsSleep == false) {
		if (SharesPVSWithPlayer() == false) {
			return;
		}

		m_pvsSleep = true;
		EntLog("Unfreezing entity, in discovered PVS");
	}

	customphysics = __NULL__;
}
#endif

void
ncPhysicsEntity::SpawnKey(string strKey, string strValue)
{
	bool tempCheck = false;

	switch (strKey) {
	case "physmodel":
		m_iShape = ReadInt(strValue);
		if (m_iShape > GEOMTYPE_CYLINDER)
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
ncPhysicsEntity::AlignAngles(vector from, vector to)
{
	EntWarning("Not implemented");
	return angles;
}

void
ncPhysicsEntity::ApplyForceCenter(vector vecForce)
{
	velocity = [0,0,1];
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
}

void
ncPhysicsEntity::ApplyForceOffset(vector vecForce, vector vecOffset)
{
	velocity = [0,0,1];
	Wake();

	vecForce *= MetersToInches;

	if (physics_supported() == TRUE) {
		vector finalForce = vecForce;
		physics_addforce(this, finalForce, vecOffset);

		NSPhysics_Log("%s::ApplyForceOffset: %v at pos %v (val: %v)",
			classname, finalForce, vecOffset, vecForce);
	} else {
		velocity += vecForce;
	}
}

void
ncPhysicsEntity::ApplyTorqueCenter(vector vecTorque)
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
}

void
ncPhysicsEntity::EnableDrag(bool setEnabled)
{
	EntWarning("Not implemented");
}

void
ncPhysicsEntity::EnableGravity(bool setEnabled)
{
	/* the engine checks if .gravity is < 0.01...) */
	gravity = setEnabled ? 1.0f : 0.005;
}

void
ncPhysicsEntity::EnableMotion(bool setEnabled)
{
	if (setEnabled) {
		Wake();
	} else {
		Sleep();
	}
}

float
ncPhysicsEntity::GetLinearDamping(void)
{
	return damp_linear;
}

float
ncPhysicsEntity::GetAngularDamping(void)
{
	return damp_angular;
}

float
ncPhysicsEntity::GetEnergy(void)
{
	/* should match JoltPhysicsObject::GetEnergy() */
	float linearEnergy;
	float rotationalEnergy;

	linearEnergy = (0.5f * GetMass() * length(GetVelocity()));
	linearEnergy *= linearEnergy;

	rotationalEnergy = (0.5f * GetMass() * length(GetAngularVelocity()));
	rotationalEnergy *= rotationalEnergy;

	return (linearEnergy + rotationalEnergy) / (InchesToMeters * InchesToMeters);
}

float
ncPhysicsEntity::GetInertia(void)
{
	return m_flInertiaScale;
}

float
ncPhysicsEntity::GetInvInertia(void)
{
	return 1.0f / m_flInertiaScale;
}

float
ncPhysicsEntity::GetInvMass(void)
{
	return 1.0f / mass;
}

float
ncPhysicsEntity::GetMass(void)
{
	return m_flMass;
}

vector
ncPhysicsEntity::GetMassCenter(void)
{
	return WorldSpaceCenter();
}

float
ncPhysicsEntity::GetRotDamping(void)
{
	return 0.0f;
}

float
ncPhysicsEntity::GetSpeedDamping(void)
{
	return 0.0f;
}

float
ncPhysicsEntity::GetSurfaceArea(void)
{
	return vlen(size) / 4;
}

float
ncPhysicsEntity::GetVolume(void)
{
	return vlen(size);
}

bool
ncPhysicsEntity::IsAsleep(void)
{
	return (m_iEnabled) ? (false) : (true);
}

bool
ncPhysicsEntity::IsCollisionEnabled(void)
{
	return true;
}

bool
ncPhysicsEntity::IsDragEnabled(void)
{
	return true;
}

bool
ncPhysicsEntity::IsGravityEnabled(void)
{
	return (gravity < 0.01) ? false : true;
}

bool
ncPhysicsEntity::IsMotionEnabled(void)
{
	return true;
}

bool
ncPhysicsEntity::IsMoveable(void)
{
	return true;
}

bool
ncPhysicsEntity::IsPenetrating(void)
{
	return true;
}

void
ncPhysicsEntity::SetAngleDragCoefficient(float setValue)
{
	EntWarning("Not implemented");
}

void
ncPhysicsEntity::SetBuoyancyRatio(float setValue)
{
	m_flBuoyancyRatio = setValue;
}

void
ncPhysicsEntity::SetDamping(float linearDamp, float angleDamp)
{
	damp_linear = linearDamp;
	damp_angular = angleDamp;
}

void
ncPhysicsEntity::SetDragCoefficient(float dragValue)
{
	EntWarning("Not implemented");
}

void
ncPhysicsEntity::SetInertia(float val)
{
	m_flInertiaScale = val;
}

void
ncPhysicsEntity::_UpdateMass(void)
{
	/* in ODE, mass is relative. */
	float massVolume = (size[0] * size[1] * size[2]);
	massVolume *= InchesToMeters; /* from inches to meters */

	mass = 1.0f;
	//mass = m_flMass / massVolume; /* really ODE's thing is density */
}

void
ncPhysicsEntity::_UpdateBuoyancy(void)
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
ncPhysicsEntity::SetMass(float val)
{
	m_flMass = val;
	_UpdateMass();
}

void
ncPhysicsEntity::Wake(void)
{
	if (!modelindex) {
		return;
	}

	if (physics_supported() == TRUE) {
		SetMovetype(MOVETYPE_PHYSICS);

		/* Don't need a lot of precision during this */
		if (Physics_Simple() == true) {
			geomtype = GEOMTYPE_BOX;
			friction = 10000.0f;
			//SetDamping(1.0f, 1.0f);
		} else {
			geomtype = m_iShape;
			friction = 1.0f;
			//SetDamping(0.0f, 0.0f);
		}

		physics_enable(this, TRUE);
	} else {
		SetMovetype(MOVETYPE_BOUNCE);
	}

	m_iEnabled = TRUE;
}

void
ncPhysicsEntity::Sleep(void)
{
	if (!modelindex) {
		return;
	}

	SetMovetype(MOVETYPE_NONE);


	if (physics_supported() == TRUE) {
		physics_enable(this, FALSE);
	}

	Relink();
	m_iEnabled = FALSE;
}
