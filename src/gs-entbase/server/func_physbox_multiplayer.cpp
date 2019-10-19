
class func_physbox:CBaseEntity
{
	int m_iShape;

	void() func_physbox;
	virtual void() Respawn;
	virtual void() touch;
};

void func_physbox::touch(void)
{
	//physics_addforce(this, other.velocity, other.origin);
}

void func_physbox::Respawn(void)
{
	movetype = MOVETYPE_PHYSICS;
	solid = SOLID_PHYSICS_BOX; // SOLID_PHYSICS_TRIMESH
	setmodel(this, m_oldModel);
	setorigin(this, m_oldOrigin);
	physics_enable(this, TRUE);
}

void func_physbox::func_physbox(void)
{
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
	func_physbox::Respawn();

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "material":
			//m_iMaterial = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}
}

CLASSEXPORT(func_physbox_multiplayer, func_physbox)
