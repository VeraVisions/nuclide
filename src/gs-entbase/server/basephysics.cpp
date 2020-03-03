

enum {
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

	void() CBasePhysics;
	virtual void() Respawn;
	virtual void() touch;
	virtual void() TouchThink;
	virtual void(entity, int, int) vPain;
};

void CBasePhysics::TouchThink(void)
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

void CBasePhysics::touch(void)
{
#ifdef GS_BULLET_PHYSICS
	makevectors(vectoangles(origin - other.origin));
	physics_addforce(this, v_forward * 128, other.origin);
	physics_enable(this, TRUE);
#endif
}

void CBasePhysics::vPain(entity eAttacker, int iType, int iDamage)
{
#ifdef GS_BULLET_PHYSICS
	iDamage *= 5;
	makevectors(vectoangles(origin - trace_endpos));
	physics_addforce(this, v_forward * iDamage, trace_endpos);
	health = 100000;
	physics_enable(this, TRUE);
#endif
}

void CBasePhysics::Respawn(void)
{
#ifdef GS_BULLET_PHYSICS
	movetype = MOVETYPE_PHYSICS;
	solid = SOLID_PHYSICS_BOX + m_iShape; // SOLID_PHYSICS_TRIMESH
	setmodel(this, m_oldModel);
	setorigin(this, m_oldOrigin);
	physics_enable(this, FALSE);
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
	setmodel(this, m_oldModel);
	setorigin(this, m_oldOrigin);
#endif
	effects &= ~EF_NOSHADOW;
}

void CBasePhysics::CBasePhysics(void)
{
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
	m_flMass = 1.0f;

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "physmodel":
			m_iShape = stoi(argv(i + 1));

			if ( m_iShape > PHYSM_CYLINDER ) {
				m_iShape = 0;
			}
			break;
		case "massscale":
			m_flMass = stof(argv(i + 1));
			break;
		case "physdamagescale":
			break;
		case "material":
			m_iMaterial = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}
	CBasePhysics::Respawn();
}

CLASSEXPORT(prop_physics, CBasePhysics)
CLASSEXPORT(prop_physics_multiplayer, CBasePhysics)

CLASSEXPORT(func_physbox, CBasePhysics)
CLASSEXPORT(func_physbox_multiplayer, CBasePhysics)
 
