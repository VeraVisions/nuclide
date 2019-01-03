/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags {
	ENVEXPLO_NODAMAGE,
	ENVEXPLO_REPEATABLE,
	ENVEXPLO_NOBALL,
	ENVEXPLO_NOSMOKE,
	ENVEXPLO_NODECAL,
	ENVEXPLO_NOSPARKS
};

class env_explosion:CBaseTrigger
{
	int m_iMagnitude;
	float m_flMaxDelay;

	void() env_explosion;
	virtual void() Trigger;
};

void env_explosion::env_explosion(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "iMagnitude":
			m_iMagnitude = stoi(argv(i + 1));
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
}

void env_explosion::Trigger(void)
{
	Effect_CreateExplosion(origin);

	if (!(spawnflags & ENVEXPLO_NODAMAGE)) {
		Damage_Radius(origin, this, 500, m_iMagnitude, TRUE);
	}
	// TODO: Respawn after round instead?
	if (!(spawnflags & ENVEXPLO_REPEATABLE)) {
		remove(this);
	}
}
