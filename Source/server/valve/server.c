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
	precache_model("models/w_weaponbox.mdl");

	precache_sound("misc/null.wav");
	precache_sound("fvox/flatline.wav");
	
	/* TODO: Scan and precache models/player/.mdl */
	precache_model("models/player/barney/barney.mdl");
	precache_model("models/player/gman/gman.mdl");
	precache_model("models/player/gordon/gordon.mdl");
	precache_model("models/player/hgrunt/hgrunt.mdl");
	precache_model("models/player/scientist/scientist.mdl");
	precache_model("models/player/zombie/zombie.mdl");
	precache_model("models/player/helmet/helmet.mdl");
	precache_model("models/player/recon/recon.mdl");
    precache_model("models/player/robo/robo.mdl");	
	Weapons_Init();
}
