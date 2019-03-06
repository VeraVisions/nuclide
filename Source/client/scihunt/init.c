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
	precache_model("sprites/640hud1.spr");
	precache_model("sprites/640hud2.spr");
	precache_model("sprites/640hud3.spr");
	precache_model("sprites/640hud4.spr");
	precache_model("sprites/640hud5.spr");
	precache_model("sprites/640hud6.spr");
	precache_model("sprites/chainsaw.spr");
	precache_model("sprites/hammer.spr");
	precache_model("sprites/w_cannon.spr");
}
