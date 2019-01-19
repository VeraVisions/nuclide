/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
CSQC_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void CSQC_Init(float apilevel, string enginename, float engineversion) {
	pSeat = &seats[0];
	precache_model(HUD_NUMFILE);
	
	precache_model("sprites/top_left.spr");
	precache_model("sprites/top.spr");
	precache_model("sprites/top_right.spr");
	precache_model("sprites/left.spr");
	precache_model("sprites/right.spr");
	precache_model("sprites/bottom_left.spr");
	precache_model("sprites/bottom.spr");
	precache_model("sprites/bottom_right.spr");
	
	precache_model("sprites/sniper_scope.spr");
	precache_model("sprites/fexplo.spr");
	precache_model("sprites/muzzleflash1.spr");
	precache_model("sprites/radar640.spr");
	precache_model("sprites/640hud1.spr");
	precache_model("sprites/640hud16.spr");
	
	precache_model("sprites/640hud2.spr");
	precache_model("sprites/640hud10.spr");
	precache_model("sprites/640hud12.spr");
	precache_model("sprites/640hud14.spr");
	precache_model("sprites/640hud3.spr");
	precache_model("sprites/640hud5.spr");
	precache_model("sprites/640_pain.spr");
	precache_model("sprites/crosshairs.spr");
	
	precache_sound("common/wpn_hudon.wav");
	precache_sound("common/wpn_hudoff.wav");
	precache_sound("common/wpn_moveselect.wav");
	precache_sound("common/wpn_select.wav");
	
	precache_sound("debris/bustglass1.wav");
	precache_sound("debris/bustglass2.wav");
	precache_sound("debris/bustglass3.wav");
	precache_sound("debris/bustcrate1.wav");
	precache_sound("debris/bustcrate2.wav");
	precache_sound("debris/bustcrate3.wav");
	precache_sound("debris/bustmetal1.wav");
	precache_sound("debris/bustmetal2.wav");
	precache_sound("debris/bustflesh1.wav");
	precache_sound("debris/bustflesh2.wav");
	precache_sound("debris/bustconcrete1.wav");
	precache_sound("debris/bustconcrete2.wav");
	precache_sound("debris/bustceiling.wav");
	precache_sound("player/pl_pain2.wav");
	Sound_InitVOX();

	precache_model("sprites/iplayerred.spr");
	precache_model("sprites/iplayerblue.spr");
	precache_model("sprites/iplayervip.spr");
	precache_model("sprites/ihostage.spr");
	
	precache_model("models/pshell.mdl");
	precache_model("models/rshell.mdl");
	precache_model("models/rshell_big.mdl");
	precache_model("models/shotgunshell.mdl");
	
	precache_pic("gfx/vgui/icntlk_sv");
	precache_pic("gfx/vgui/icntlk_pl");
	precache_pic( sprintf( "overviews/%s.bmp", mapname ) );

	PARTICLE_SPARK 			= particleeffectnum("part_spark");
	PARTICLE_PIECES_BLACK 	= particleeffectnum("part_pieces_black");
	PARTICLE_SMOKE_GREY 	= particleeffectnum("part_smoke_grey");
	PARTICLE_SMOKE_BROWN 	= particleeffectnum("part_smoke_brown");
	PARTICLE_BLOOD 			= particleeffectnum("part_blood");
	DECAL_SHOT 				= particleeffectnum("decal_shot");
	DECAL_GLASS 			= particleeffectnum("decal_glass");
	PARTICLE_SMOKEGRENADE	= particleeffectnum("smokegren");
	
	FONT_16 = loadfont("16", "fonts/default", "16", -1);
	FONT_CON  = loadfont("font", "", "12", -1);
	
	SHADER_CULLED = shaderforname("mirror_cull");

	Radio_InitSounds();
	
	CSQC_ConsoleCommand_Init();
	CSQC_VGUI_Init();
	Overview_Init();
	Fade_Init();
	
	pSeat.iOverview = FALSE;
}

void CSQC_RendererRestarted( string sDescr ) {
	Overview_Init();
}

/*
=================
CSQC_WorldLoaded

Whenever the world is fully initialized...
=================
*/
void CSQC_WorldLoaded( void ) {
	
}

/*
=================
CSQC_Shutdown

Incase you need to free something
=================
*/
void CSQC_Shutdown( void ) {
	
}
