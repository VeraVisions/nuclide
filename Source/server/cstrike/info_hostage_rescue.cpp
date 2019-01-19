/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void info_hostage_rescue(void)
{
	spawnfunc_func_hostage_rescue();
}

/*
=================
Game_CreateRescueZones

Called by StartFrame if we somehow got no rescue zones
=================
*/
void Game_CreateRescueZones(void)
{
	entity a;

	for (a = world; (a = find(a, classname, "info_player_start"));) {
		func_hostage_rescue zone = spawn(func_hostage_rescue);
		setorigin(zone, a.origin);
	}
}
