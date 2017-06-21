/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

/*
=================
CSQC_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void CSQC_Init(float apilevel, string enginename, float engineversion) {
	precache_model( HUD_NUMFILE );
	
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

	Radio_InitSounds();
	
	CSQC_ConsoleCommand_Init();
	CSQC_VGUI_Init();
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
