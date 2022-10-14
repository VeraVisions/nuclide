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
NSPhysicsEntity::NSPhysicsEntity(void)
{
	mass = 1.0f;
	m_flInertiaScale = 1.0f;

	m_iEnabled = 0i;
	m_iShape = PHYSM_BOX;
	m_iMaterial = 0i;
	m_iFlags = 0i;

	cvar_set("physics_ode_iterationsperframe", "1");
	cvar_set("physics_ode_movelimit", "0.1");
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

#define ODE_MODE 1

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
#if 0
	origin[0] = rint(origin[0]);
	origin[1] = rint(origin[1]);
	origin[2] = rint(origin[2]);
	angles[0] = rint(angles[0]);
	angles[1] = rint(angles[1]);
	angles[2] = rint(angles[2]);
#endif

	if (origin_x != origin_net_x) {
		SetSendFlags(PHYENT_CHANGED_ORIGIN_X);
	}
	if (origin_y != origin_net_y) {
		SetSendFlags(PHYENT_CHANGED_ORIGIN_Y);
	}
	if (origin_z != origin_net_z) {
		SetSendFlags(PHYENT_CHANGED_ORIGIN_Z);
	}
	if (angles_x != angles_net_x) {
		SetSendFlags(PHYENT_CHANGED_ANGLES_X);
	}
	if (angles_y != angles_net_y) {
		SetSendFlags(PHYENT_CHANGED_ANGLES_Y);
	}
	if (angles_z != angles_net_z) {
		SetSendFlags(PHYENT_CHANGED_ANGLES_Z);
	}
	if (ATTR_CHANGED(modelindex)) {
		SetSendFlags(PHYENT_CHANGED_MODELINDEX);
	}
	if (ATTR_CHANGED(solid)) {
		SetSendFlags(PHYENT_CHANGED_SOLID);
	}
	if (ATTR_CHANGED(movetype)) {
		SetSendFlags(PHYENT_CHANGED_MOVETYPE);
	}
	if (ATTR_CHANGED(size)) {
		SetSendFlags(PHYENT_CHANGED_SIZE);
	}
	if (ATTR_CHANGED(frame)) {
		SetSendFlags(PHYENT_CHANGED_FRAME);
	}
	if (ATTR_CHANGED(skin)) {
		SetSendFlags(PHYENT_CHANGED_SKIN);
	}
	if (ATTR_CHANGED(effects)) {
		SetSendFlags(PHYENT_CHANGED_EFFECTS);
	}
	if (ATTR_CHANGED(m_iBody)) {
		SetSendFlags(PHYENT_CHANGED_BODY);
	}
	if (ATTR_CHANGED(scale)) {
		SetSendFlags(PHYENT_CHANGED_SCALE);
	}
	if (ATTR_CHANGED(velocity)) {
		SetSendFlags(PHYENT_CHANGED_VELOCITY);
	}

	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(modelindex);
	SAVE_STATE(solid);
	SAVE_STATE(movetype);
	SAVE_STATE(size);
	SAVE_STATE(frame);
	SAVE_STATE(skin);
	SAVE_STATE(effects);
	SAVE_STATE(m_iBody);
	SAVE_STATE(scale);
	SAVE_STATE(velocity);

	if (ATTR_CHANGED(m_iRenderMode)) {
		SetSendFlags(PHYENT_CHANGED_RENDERMODE);
	}
	if (ATTR_CHANGED(m_iRenderFX)) {
		SetSendFlags(PHYENT_CHANGED_RENDERMODE);
	}

	if (ATTR_CHANGED(m_vecRenderColor)) {
		SetSendFlags(PHYENT_CHANGED_RENDERCOLOR);
	}
	if (ATTR_CHANGED(m_flRenderAmt)) {
		SetSendFlags(PHYENT_CHANGED_RENDERAMT);
	}
}

float
NSPhysicsEntity::SendEntity(entity ePEnt, float fChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_PHYSICS);

	/* newly popped into the PVS, sadly this is the only hacky way to check
	 * for this right now. convince the engine maintainer to make this more sensible */
	if (fChanged == 0xFFFFFF) {
		/* check for defaults. if these are predictable fields, don't even bother
		 * networking them! you're just wasting bandwidth. */
		if (frame == 0)
			fChanged &= ~PHYENT_CHANGED_FRAME;
		if (skin == 0)
			fChanged &= ~PHYENT_CHANGED_SKIN;
		if (effects == 0)
			fChanged &= ~PHYENT_CHANGED_EFFECTS;
		if (m_iBody == 0)
			fChanged &= ~PHYENT_CHANGED_BODY;
		if (scale == 0.0 || scale == 1.0)
			fChanged &= ~PHYENT_CHANGED_SCALE;
		if (origin[0] == 0)
			fChanged &= ~PHYENT_CHANGED_ORIGIN_X;
		if (origin[1] == 0)
			fChanged &= ~PHYENT_CHANGED_ORIGIN_Y;
		if (origin[2] == 0)
			fChanged &= ~PHYENT_CHANGED_ORIGIN_Z;
		if (angles[0] == 0)
			fChanged &= ~PHYENT_CHANGED_ANGLES_X;
		if (angles[1] == 0)
			fChanged &= ~PHYENT_CHANGED_ANGLES_Y;
		if (angles[2] == 0)
			fChanged &= ~PHYENT_CHANGED_ANGLES_Z;
		if (velocity == [0,0,0])
			fChanged &= ~PHYENT_CHANGED_VELOCITY;
		if (mins == [0,0,0] && maxs == [0,0,0])
			fChanged &= ~PHYENT_CHANGED_SIZE;
		if (solid == SOLID_NOT)
			fChanged &= ~PHYENT_CHANGED_SOLID;
		if (movetype == MOVETYPE_NONE)
			fChanged &= ~PHYENT_CHANGED_MOVETYPE;
		if (m_iRenderMode == RM_NORMAL)
			fChanged &= ~PHYENT_CHANGED_RENDERMODE;
	}

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & PHYENT_CHANGED_ORIGIN_X) {
		WriteCoord(MSG_ENTITY, origin[0]);
	}
	if (fChanged & PHYENT_CHANGED_ORIGIN_Y) {
		WriteCoord(MSG_ENTITY, origin[1]);
	}
	if (fChanged & PHYENT_CHANGED_ORIGIN_Z) {
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (fChanged & PHYENT_CHANGED_ANGLES_X) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
	}
	if (fChanged & PHYENT_CHANGED_ANGLES_Y) {
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
	}
	if (fChanged & PHYENT_CHANGED_ANGLES_Z) {
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
	}
	if (fChanged & PHYENT_CHANGED_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
	}
	if (fChanged & PHYENT_CHANGED_SOLID) {
		WriteByte(MSG_ENTITY, solid);
	}
	if (fChanged & PHYENT_CHANGED_MOVETYPE) {
		WriteByte(MSG_ENTITY, movetype);
	}
	if (fChanged & PHYENT_CHANGED_SIZE) {
		WriteCoord(MSG_ENTITY, mins[0]);
		WriteCoord(MSG_ENTITY, mins[1]);
		WriteCoord(MSG_ENTITY, mins[2]);
		WriteCoord(MSG_ENTITY, maxs[0]);
		WriteCoord(MSG_ENTITY, maxs[1]);
		WriteCoord(MSG_ENTITY, maxs[2]);
	}
	if (fChanged & PHYENT_CHANGED_FRAME) {
		WriteByte(MSG_ENTITY, frame);
		WriteByte(MSG_ENTITY, frame1time);
	}
	if (fChanged & PHYENT_CHANGED_SKIN) {
		WriteByte(MSG_ENTITY, skin + 128);
	}
	if (fChanged & PHYENT_CHANGED_EFFECTS) {
		WriteFloat(MSG_ENTITY, effects);
	}
	if (fChanged & PHYENT_CHANGED_BODY) {
		WriteByte(MSG_ENTITY, m_iBody);
	}
	if (fChanged & PHYENT_CHANGED_SCALE) {
		WriteFloat(MSG_ENTITY, scale);
	}
	if (fChanged & PHYENT_CHANGED_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

	if (fChanged & PHYENT_CHANGED_RENDERMODE) {
		WriteByte(MSG_ENTITY, m_iRenderMode);
		WriteByte(MSG_ENTITY, m_iRenderFX);
	}

	if (fChanged & PHYENT_CHANGED_RENDERCOLOR) {
		WriteFloat(MSG_ENTITY, m_vecRenderColor[0]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[1]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[2]);
		WriteFloat(MSG_ENTITY, glowmod[0]);
		WriteFloat(MSG_ENTITY, glowmod[1]);
		WriteFloat(MSG_ENTITY, glowmod[2]);
	}
	if (fChanged & PHYENT_CHANGED_RENDERAMT) {
		WriteFloat(MSG_ENTITY, m_flRenderAmt);
	}

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
	if (flChanged & PHYENT_CHANGED_ORIGIN_X) {
		origin[0] = readcoord();
	}
	if (flChanged & PHYENT_CHANGED_ORIGIN_Y) {
		origin[1] = readcoord();
	}
	if (flChanged & PHYENT_CHANGED_ORIGIN_Z) {
		origin[2] = readcoord();
	}
	if (flChanged & PHYENT_CHANGED_ANGLES_X) {
		angles[0] = readshort() / (32767 / 360);
	}
	if (flChanged & PHYENT_CHANGED_ANGLES_Y) {
		angles[1] = readshort() / (32767 / 360);
	}
	if (flChanged & PHYENT_CHANGED_ANGLES_Z) {
		angles[2] = readshort() / (32767 / 360);
	}
	if (flChanged & PHYENT_CHANGED_MODELINDEX) {
		setmodelindex(this, readshort());
	}
	if (flChanged & PHYENT_CHANGED_SOLID) {
		solid = readbyte();
	}
	if (flChanged & PHYENT_CHANGED_MOVETYPE) {
		movetype = readbyte();

		if (movetype == MOVETYPE_PHYSICS) {
			movetype = MOVETYPE_NONE;
		}
	}
	if (flChanged & PHYENT_CHANGED_SIZE) {
		mins[0] = readcoord();
		mins[1] = readcoord();
		mins[2] = readcoord();
		maxs[0] = readcoord();
		maxs[1] = readcoord();
		maxs[2] = readcoord();
	}
	if (flChanged & PHYENT_CHANGED_FRAME) {
		frame = readbyte();
		frame1time =
		frame2time = readbyte();
	}
	if (flChanged & PHYENT_CHANGED_SKIN) {
		skin = readbyte() - 128;
	}
	if (flChanged & PHYENT_CHANGED_EFFECTS) {
		effects = readfloat();
	}
	if (flChanged & PHYENT_CHANGED_BODY) {
		m_iBody = readbyte();
		setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_iBody, m_iBody));
	}
	if (flChanged & PHYENT_CHANGED_SCALE) {
		scale = readfloat();
	}
	if (flChanged & PHYENT_CHANGED_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

	if (flChanged & PHYENT_CHANGED_RENDERMODE) {
		m_iRenderMode = readbyte();
		m_iRenderFX = readbyte();
	}
	if (flChanged & PHYENT_CHANGED_RENDERCOLOR) {
		m_vecRenderColor[0] = readfloat();
		m_vecRenderColor[1] = readfloat();
		m_vecRenderColor[2] = readfloat();
		glowmod[0] = readfloat();
		glowmod[1] = readfloat();
		glowmod[2] = readfloat();
	}
	if (flChanged & PHYENT_CHANGED_RENDERAMT) {
		m_flRenderAmt = readfloat();
	}

	if (modelindex) {
		drawmask = MASK_ENGINE;
	} else {
		drawmask = 0;
	}

	if (scale == 0.0)
		scale = 1.0f;

	if (flChanged & PHYENT_CHANGED_SIZE)
		setsize(this, mins * scale, maxs * scale);

	setorigin(this, origin);
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
	geomtype = GEOMTYPE_TRIMESH;

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

#ifdef CLIENT
void
NSPhysicsEntity_ReadEntity(bool new)
{
	float fl;
	NSPhysicsEntity rend = (NSPhysicsEntity)self;
	if (new) {
		spawnfunc_NSPhysicsEntity();
	}
	fl = readfloat();
	rend.ReceiveEntity(new, fl);

	//print(sprintf("physics ent update: %d %x %d %v\n", self.entnum, fl, self.origin, vlen(self.velocity)));
}
#endif
