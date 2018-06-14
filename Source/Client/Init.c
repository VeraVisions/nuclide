/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

/*
=================
CSQC_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void CSQC_Init(float apilevel, string enginename, float engineversion) {
	pSeat = &seats[0];
	precache_model( HUD_NUMFILE );
	
	precache_model( "sprites/top_left.spr" );
	precache_model( "sprites/top.spr" );
	precache_model( "sprites/top_right.spr" );
	precache_model( "sprites/left.spr" );
	precache_model( "sprites/right.spr" );
	precache_model( "sprites/bottom_left.spr" );
	precache_model( "sprites/bottom.spr" );
	precache_model( "sprites/bottom_right.spr" );
	
	precache_model( "sprites/sniper_scope.spr" );
	precache_model( "sprites/fexplo.spr" );
	precache_model( "sprites/muzzleflash1.spr" );
	precache_model( "sprites/radar640.spr" );
	precache_model( "sprites/640hud1.spr" );
	precache_model( "sprites/640hud16.spr" );
	
	precache_model( "sprites/640hud2.spr" );
	precache_model( "sprites/640hud10.spr" );
	precache_model( "sprites/640hud12.spr" );
	precache_model( "sprites/640hud14.spr" );
	precache_model( "sprites/640hud3.spr" );
	
	precache_sound( "common/wpn_hudon.wav" );
	precache_sound( "common/wpn_hudoff.wav" );
	precache_sound( "common/wpn_moveselect.wav" );
	precache_sound( "common/wpn_select.wav" );
	
	precache_sound( "debris/bustglass1.wav" );
	precache_sound( "debris/bustglass2.wav" );
	precache_sound( "debris/bustglass3.wav" );
	precache_sound( "debris/bustcrate1.wav" );
	precache_sound( "debris/bustcrate2.wav" );
	precache_sound( "debris/bustcrate3.wav" );
	precache_sound( "debris/bustmetal1.wav" );
	precache_sound( "debris/bustmetal2.wav" );
	precache_sound( "debris/bustflesh1.wav" );
	precache_sound( "debris/bustflesh2.wav" );
	precache_sound( "debris/bustconcrete1.wav" );
	precache_sound( "debris/bustconcrete2.wav" );
	precache_sound( "debris/bustceiling.wav" );
	precache_model( "sprites/iplayerred.spr" );
	precache_model( "sprites/iplayerblue.spr" );
	precache_model( "sprites/iplayervip.spr" );
	precache_model( "sprites/ihostage.spr" );
	
	precache_model( "models/pshell.mdl" );
	precache_model( "models/rshell.mdl" );
	precache_model( "models/rshell_big.mdl" );
	precache_model( "models/shotgunshell.mdl" );
	
	precache_pic( "gfx/vgui/icntlk_sv" );
	precache_pic( sprintf( "overviews/%s.bmp", mapname ) );
	
	precache_pic( "logos/lambda.bmp" );
	precache_pic( "logos/doug.bmp" );
	
	for ( int i = 0; i < ( CS_WEAPON_COUNT - 1 ); i++ ) {
		precache_model( sViewModels[ i ] );
	}

	PARTICLE_SPARK 			= particleeffectnum( "part_spark" );
	PARTICLE_PIECES_BLACK 	= particleeffectnum( "part_pieces_black" );
	PARTICLE_SMOKE_GREY 	= particleeffectnum( "part_smoke_grey" );
	PARTICLE_SMOKE_BROWN 	= particleeffectnum( "part_smoke_brown" );
	PARTICLE_BLOOD 			= particleeffectnum( "part_blood" );
	DECAL_SHOT 				= particleeffectnum( "decal_shot" );
	DECAL_GLASS 			= particleeffectnum( "decal_glass" );
	PARTICLE_SMOKEGRENADE	= particleeffectnum( "smokegren" );
	
	FONT_16 = loadfont( "16", "fonts/default", "16", -1 );
	FONT_CON  = loadfont( "font", "", "12", -1 );
	
	SHADER_CULLED = shaderforname( "mirror_cull" );

	Radio_InitSounds();
	
	CSQC_ConsoleCommand_Init();
	CSQC_VGUI_Init();
	Overview_Init();
	
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
