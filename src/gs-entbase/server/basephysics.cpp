

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

	void() CBasePhysics;
	virtual void() Respawn;
	virtual void() touch;
	virtual void(entity, int, int) vPain;
};

void CBasePhysics::touch(void)
{
	makevectors(vectoangles(origin - other.origin));
	physics_addforce(this, v_forward * 128, other.origin);
	physics_enable(this, TRUE);
}

void CBasePhysics::vPain(entity eAttacker, int iType, int iDamage)
{
	iDamage *= 5;
	makevectors(vectoangles(origin - trace_endpos));
	physics_addforce(this, v_forward * iDamage, trace_endpos);
	health = 100000;
	physics_enable(this, TRUE);
}

void CBasePhysics::Respawn(void)
{
	movetype = MOVETYPE_PHYSICS;
	solid = SOLID_PHYSICS_BOX + m_iShape; // SOLID_PHYSICS_TRIMESH
	setmodel(this, m_oldModel);
	setorigin(this, m_oldOrigin);
	physics_enable(this, FALSE);
	takedamage = DAMAGE_YES;
	health = 100000;
}

void CBasePhysics::CBasePhysics(void)
{
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "physmodel":
			m_iShape = stoi(argv(i + 1));

			if ( m_iShape > PHYSM_CYLINDER ) {
				m_iShape = 0;
			}
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
 
