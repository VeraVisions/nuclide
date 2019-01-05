/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

/* https://twhl.info/wiki/page/cycler_sprite_(Half-Life) */

enumflags
{
	ENVS_STARTON,
	ENVS_PLAYONCE
};

class cycler_sprite:CBaseEntity
{
	void() cycler_sprite;
};

void cycler_sprite::cycler_sprite(void)
{
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
	Respawn();
}
