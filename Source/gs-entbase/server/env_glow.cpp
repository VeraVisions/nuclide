/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* https://twhl.info/wiki/page/env_glow_(Half-Life) */

enumflags
{
	ENVS_STARTON,
	ENVS_PLAYONCE
};

class env_glow : CBaseEntity
{
	void() env_glow;
};

void env_glow::env_glow(void)
{
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
	Respawn();
}
