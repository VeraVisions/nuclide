/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Game_StartFrame(void)
{
	
}

float Game_ConsoleCmd(string cmd)
{
	return FALSE;
}

void Game_Worldspawn(void)
{
	precache_model("models/player.mdl");
	Weapons_Init();
	SHData_Parse(mapname);
}
