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

enum
{
	PHYSM_BOX,
	PHYSM_SPHERE,
	PHYSM_CAPSULE,
	PHYSM_TRIMESH,
	PHYSM_CYLINDER
};

class CBasePhysics:CBaseEntity
{
	int m_iShape;
	int m_iMaterial;
	float m_flMass;

	void(void) CBasePhysics;
	virtual void(void) Respawn;
	virtual void(void) touch;
	virtual void(void) TouchThink;
	virtual void(void) Pain;
	virtual void(string, string) SpawnKey;
};

void
CBasePhysics::TouchThink(void)
{
#ifdef GS_BULLET_PHYSICS
	/* let players collide */
	dimension_solid = 255;
	dimension_hit = 255;

	tracebox(origin, mins, maxs, origin, FALSE, this);

	/* stuck */
	if (trace_startsolid) {
		if (trace_ent.flags & FL_CLIENT) {
			physics_enable(this, TRUE);
			makevectors(vectoangles(origin - trace_ent.origin));
			velocity = v_forward * 256;
		}
	}

	/* If we barely move, disable the physics simulator */
	if (vlen(velocity) <= 1) {
		physics_enable(this, FALSE);
	}

	/* don't let players collide */
	dimension_solid = 1;
	dimension_hit = 1;

	/* continue testing next frame */
	nextthink = time;
	effects &= ~EF_NOSHADOW;
#endif
}

void
CBasePhysics::touch(void)
{
#ifdef GS_BULLET_PHYSICS
	makevectors(vectoangles(origin - other.origin));
	physics_addforce(this, v_forward, other.origin);
	physics_enable(this, TRUE);
#endif
}

void
CBasePhysics::Pain(void)
{
#ifdef GS_BULLET_PHYSICS
	makevectors(vectoangles(origin - trace_endpos));
	physics_addforce(this, v_forward * 20, trace_endpos);
	health = 100000;
	physics_enable(this, TRUE);
#endif
}

void
CBasePhysics::Respawn(void)
{
#ifdef GS_BULLET_PHYSICS
	movetype = MOVETYPE_PHYSICS;
	solid = SOLID_PHYSICS_BOX + m_iShape;
	geomtype = GEOMTYPE_BOX;
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	physics_enable(this, TRUE);
	takedamage = DAMAGE_YES;
	health = 100000;
	mass = m_flMass;

	/* don't let players collide */
	dimension_solid = 1;
	dimension_hit = 1;

	think = TouchThink;
	nextthink = time + 0.1f;
#else
	movetype = MOVETYPE_NONE;
	solid = SOLID_BBOX;
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
#endif
	effects &= ~EF_NOSHADOW;
}

void
CBasePhysics::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "physmodel":
		m_iShape = stoi(strValue);

		if (m_iShape > PHYSM_CYLINDER) {
			m_iShape = 0;
		}
		break;
	case "massscale":
		m_flMass = stof(strValue);
		break;
	case "physdamagescale":
		break;
	case "material":
		m_iMaterial = stof(strValue);
		break;
	default:
		CBaseEntity::SpawnKey(strKey, strValue);
		break;
	}
}

void
CBasePhysics::CBasePhysics(void)
{
	CBaseEntity::CBaseEntity();
	m_flMass = 1.0f;
}
