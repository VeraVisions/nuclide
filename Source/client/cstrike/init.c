/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
Client_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void Client_Init(float apilevel, string enginename, float engineversion)
{
	precache_model("sprites/fexplo.spr");
	precache_model("sprites/muzzleflash1.spr");
	
	precache_sound("common/wpn_hudon.wav");
	precache_sound("common/wpn_hudoff.wav");
	precache_sound("common/wpn_moveselect.wav");
	precache_sound("common/wpn_select.wav");
	precache_sound("player/pl_pain2.wav");

	precache_model("sprites/iplayerred.spr");
	precache_model("sprites/iplayerblue.spr");
	precache_model("sprites/iplayervip.spr");
	precache_model("sprites/ihostage.spr");
	
	precache_model("models/pshell.mdl");
	precache_model("models/rshell.mdl");
	precache_model("models/rshell_big.mdl");
	precache_model("models/shotgunshell.mdl");
	precache_pic( sprintf( "overviews/%s.bmp", mapname ) );

	PARTICLE_SMOKEGRENADE	= particleeffectnum("smokegren");

	Radio_InitSounds();
	
	CSQC_ConsoleCommand_Init();
	CSQC_VGUI_Init();
	Overview_Init();
	
	pSeat.iOverview = FALSE;
}

void CSQC_RendererRestarted(string sDescr)
{
	Overview_Init();
}
