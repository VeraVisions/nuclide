/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

/* https://twhl.info/wiki/page/env_sprite_(Half-Life) */

enumflags
{
	ENVS_STARTON,
	ENVS_PLAYONCE
};

class env_sprite : CBaseTrigger
{
	void() env_sprite;
	virtual void() Trigger;
};

void env_sprite::Trigger(void)
{
	Respawn();
	if (spawnflags & ENVS_PLAYONCE) {
		
	}
}

void env_sprite::env_sprite(void)
{
	CBaseTrigger::CBaseTrigger();
	precache_model(m_oldModel);
	Respawn();
	
	if (!(spawnflags & ENVS_STARTON)) {
		Hide();
	}
}
