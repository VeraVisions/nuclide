/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

/* https://twhl.info/wiki/page/env_sprite_(Half-Life) */

enumflags {
	ENVS_STARTON,
	ENVS_PLAYONCE
};

class CEnvGlow : CBaseEntity
{
	void() CEnvGlow;
};

void CEnvGlow::CEnvGlow(void)
{
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
	Respawn();
}

CLASSEXPORT(env_glow, CEnvGlow)
