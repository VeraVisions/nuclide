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

class CEnvSprite : CBaseTrigger
{
	void() CEnvSprite;
	virtual void() Trigger;
};

void CEnvSprite::Trigger(void)
{
	Respawn();
	if (spawnflags & ENVS_PLAYONCE) {
		
	}
}

void CEnvSprite::CEnvSprite(void)
{
	CBaseTrigger::CBaseTrigger();
	precache_model(m_oldModel);
	Respawn();
	
	if (!(spawnflags & ENVS_STARTON)) {
		Hide();
	}
}

CLASSEXPORT(env_sprite, CEnvSprite)
