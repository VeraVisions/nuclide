/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class trigger_gravity:CBaseTrigger
{
	float m_flGravity;
	void() trigger_gravity;
	virtual void() touch;
};

void trigger_gravity::touch(void)
{
	other.gravity = m_flGravity;
}

/* TODO: Make this redundant */
void trigger_gravity::Respawn(void)
{
	solid = SOLID_TRIGGER;
#ifdef GS_DEVELOPER
	alpha = 0.5f;
#endif
}

void trigger_gravity::trigger_gravity(void)
{
	print(__fullspawndata);
	print("\n");

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "gravity":
			m_flGravity = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}
	trigger_gravity::Respawn();
	CBaseEntity::CBaseEntity();
	CBaseTrigger::InitBrushTrigger();
}
