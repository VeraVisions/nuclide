/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
CBasePhysics::PhysicsEnable(void)
{
	if (physics_supported() == TRUE)
		physics_enable(this, TRUE);
	else {
		print("^1CBasePhysics::PhysicsEnable: ");
		print("^7Physics simulator not enabled.\n");
		SetMovetype(MOVETYPE_BOUNCE);
		SetSolid(SOLID_NOT);
	}
	m_iEnabled = TRUE;
}

void
CBasePhysics::PhysicsDisable(void)
{
	if (physics_supported() == TRUE)
		physics_enable(this, FALSE);
	else {
		print("^1CBasePhysics::PhysicsDisable: ");
		print("^7Physics simulator not enabled.\n");
		SetMovetype(MOVETYPE_NONE);
		SetSolid(SOLID_NOT);
	}
	m_iEnabled = FALSE;
}

void
CBasePhysics::SetMass(float val)
{
	mass = val;
}
float
CBasePhysics::GetMass(void)
{
	return mass;
}

void
CBasePhysics::SetFriction(float val)
{
	friction = val;
}
float
CBasePhysics::GetFriction(void)
{
	return friction;
}

void
CBasePhysics::SetBounceFactor(float val)
{
	bouncefactor = val;
}
float
CBasePhysics::GetBounceFactor(void)
{
	return bouncefactor;
}

void
CBasePhysics::SetInertia(float val)
{
	m_flInertiaScale = val;
}
float
CBasePhysics::GetInertia(void)
{
	return m_flInertiaScale;
}

void
CBasePhysics::ApplyForceCenter(vector vecForce)
{
	if (physics_supported() == TRUE)
		physics_addforce(this, vecForce, [0,0,0]);
	else {
		print("^1CBasePhysics::ApplyForceCenter: ");
		print("^7Physics simulator not enabled.\n");
		velocity = vecForce;
	}
}

void
CBasePhysics::ApplyForceOffset(vector vecForce, vector vecOffset)
{
	if (physics_supported() == TRUE)
		physics_addforce(this, vecForce, vecOffset);
	else {
		print("^1CBasePhysics::ApplyForceOffset: ");
		print("^7Physics simulator not enabled.\n");
		velocity = vecForce;
	}
}

void
CBasePhysics::ApplyTorqueCenter(vector vecTorque)
{
	if (physics_supported() == TRUE)
		physics_addtorque(this, vecTorque * m_flInertiaScale);
	else {
		print("^1CBasePhysics::ApplyTorqueCenter: ");
		print("^7Physics simulator not enabled.\n");
		avelocity = vecTorque;
		velocity = vecTorque;
		velocity[2] = 96;
	}
}

void
CBasePhysics::TouchThink(void)
{
	/* let players collide */
	dimension_solid = 255;
	dimension_hit = 255;

	tracebox(origin, mins, maxs, origin, FALSE, this);

	/* stuck */
	if (trace_startsolid) {
		if (trace_ent.flags & FL_CLIENT) {
			PhysicsEnable();
			makevectors(vectoangles(origin - trace_ent.origin));
			ApplyTorqueCenter(v_forward * 240);
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

	/* don't let players collide */
	dimension_solid = 1;
	dimension_hit = 1;

	/* continue testing next frame */
	nextthink = time;
	effects &= ~EF_NOSHADOW;
}

void
CBasePhysics::touch(void)
{
	PhysicsEnable();
	makevectors(vectoangles(origin - other.origin));
	ApplyForceOffset(v_forward, origin - other.origin);
}

void
CBasePhysics::Pain(void)
{
	if (m_iFlags & BPHY_NODMGPUSH)
		return;

	PhysicsEnable();
	makevectors(vectoangles(origin - trace_endpos));
	ApplyForceOffset(v_forward * 20, origin - trace_endpos);
	health = 100000;
}

void
CBasePhysics::Respawn(void)
{
	SetMovetype(MOVETYPE_PHYSICS);
	SetSolid(SOLID_PHYSICS_BOX + m_iShape);
	SetModel(m_oldModel);
	geomtype = GEOMTYPE_BOX;
	takedamage = DAMAGE_YES;
	health = 100000;
	PhysicsDisable();
	SetFriction(2.0f);
	SetBounceFactor(0.25f);
	SetOrigin(m_oldOrigin);

	/* don't let players collide */
	dimension_solid = 1;
	dimension_hit = 1;

	think = TouchThink;
	nextthink = time + 0.1f;
	effects &= ~EF_NOSHADOW;
}

void
CBasePhysics::SpawnKey(string strKey, string strValue)
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
		CBaseEntity::SpawnKey(strKey, strValue);
		break;
	}
}

void
CBasePhysics::CBasePhysics(void)
{
	mass = 1.0f;
	m_flInertiaScale = 1.0f;

	CBaseEntity::CBaseEntity();
}
