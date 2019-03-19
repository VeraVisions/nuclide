/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* https://twhl.info/wiki/page/cycler_sprite_(Half-Life) */

class cycler_sprite:CBaseTrigger
{
	void() cycler_sprite;
};

void cycler_sprite::cycler_sprite(void)
{
	CBaseEntity::CBaseEntity();
	CBaseEntity::Respawn();
}
