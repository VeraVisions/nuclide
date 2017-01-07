/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

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

void main( void ) {}
void SetNewParms( void ) {}
void SetChangeParms( void ) {}

void SV_PausedTic( float fDuration ) {

}

// Run every frame... by world?
void StartFrame( void ) {
	// We've got hostages, but no rescue zones, create some
	if ( !iRescueZones && iHostagesMax > 0 ) {
		Game_CreateRescueZones();
	}
		
	if ( iBuyZones == 0 ) {
		Game_CreateBuyZones();
	}

	// TODO: Optimise this
	if ( ( iAlivePlayers_T + iAlivePlayers_CT ) == 0 ) {
		int iInGamePlayers = 0;
		for ( entity eFind = world; ( eFind = find( eFind, classname, "player" ) ); ) {
			iInGamePlayers++;
		}
		
		if ( ( iInGamePlayers > 0 ) && ( fGameState != GAME_COMMENCING ) ) {
			Timer_Begin( 2, GAME_COMMENCING );
		} else if ( iInGamePlayers == 0 ) {
			fGameState = GAME_INACTIVE;
			fGameTime = 0;
		} else {
			Timer_Update(); // Timer that happens once players have started joining
		}
	} else {
		Timer_Update(); // Normal gameplay timer
	}
}

// The map... entity.
void worldspawn( void ) {
	// Let's load materials.txt because someone thought this was the best idea
	string sTemp;
	filestream fileMaterial = fopen( "sound/materials.txt", FILE_READ );
	hashMaterials = hash_createtab( 512, HASH_ADD );
	
	if ( fileMaterial >= 0 ) {
		while ( ( sTemp = fgets( fileMaterial ) ) ) {			
			// Tokenize and just parse this stuff in
			if ( tokenize_console( sTemp ) == 2 ) {
				hash_add( hashMaterials, strtolower( argv( 1 ) ), str2chr( argv( 0 ), 0 ) );
			}
		}
		fclose( fileMaterial );
	}
	
	precache_model( sCSPlayers[1] );
	precache_model( sCSPlayers[2] );
	precache_model( sCSPlayers[3] );
	precache_model( sCSPlayers[4] );
	precache_model( sCSPlayers[5] );
	precache_model( sCSPlayers[6] );
	precache_model( sCSPlayers[7] );
	precache_model( sCSPlayers[8] );
	precache_model( "models/player/vip/vip.mdl" );
	precache_model( "models/w_c4.mdl" );
	
	precache_sound( "hostage/hos1.wav" );
	precache_sound( "hostage/hos2.wav" );
	precache_sound( "hostage/hos3.wav" );
	precache_sound( "hostage/hos4.wav" );
	precache_sound( "hostage/hos5.wav" );
	
	precache_sound( "player/pl_pain2.wav" );
	precache_sound( "player/pl_pain4.wav" );
	precache_sound( "player/pl_pain5.wav" );
	precache_sound( "player/pl_pain6.wav" );
	precache_sound( "player/pl_pain7.wav" );
	
	precache_sound( "player/die1.wav" );
	precache_sound( "player/die2.wav" );
	precache_sound( "player/die3.wav" );
	
	precache_sound( "player/headshot1.wav" );
	precache_sound( "player/headshot2.wav" );
	precache_sound( "player/headshot3.wav" );
	
	precache_sound( "items/9mmclip1.wav" );
	precache_sound( "items/tr_kevlar.wav" );
	precache_sound( "items/gunpickup2.wav" );
	precache_sound( "common/wpn_select.wav" );
	precache_sound( "common/wpn_denyselect.wav" );
	
	precache_sound( "weapons/ak47-1.wav" );
	precache_sound( "weapons/ak47-2.wav" );
	precache_sound( "weapons/ak47_boltpull.wav" );
	precache_sound( "weapons/ak47_clipin.wav" );
	precache_sound( "weapons/ak47_clipout.wav" );
	precache_sound( "weapons/aug-1.wav" );
	precache_sound( "weapons/aug_boltpull.wav" );
	precache_sound( "weapons/aug_boltslap.wav" );
	precache_sound( "weapons/aug_clipin.wav" );
	precache_sound( "weapons/aug_clipout.wav" );
	precache_sound( "weapons/aug_forearm.wav" );
	precache_sound( "weapons/awp1.wav" );
	precache_sound( "weapons/awp_clipin.wav" );
	precache_sound( "weapons/awp_clipout.wav" );
	precache_sound( "weapons/awp_deploy.wav" );
	precache_sound( "weapons/boltdown.wav" );
	precache_sound( "weapons/boltpull1.wav" );
	precache_sound( "weapons/boltup.wav" );
	precache_sound( "weapons/c4_beep1.wav" );
	precache_sound( "weapons/c4_beep2.wav" );
	precache_sound( "weapons/c4_beep3.wav" );
	precache_sound( "weapons/c4_beep4.wav" );
	precache_sound( "weapons/c4_beep5.wav" );
	precache_sound( "weapons/c4_click.wav" );
	precache_sound( "weapons/c4_disarm.wav" );
	precache_sound( "weapons/c4_disarmed.wav" );
	precache_sound( "weapons/c4_explode1.wav" );
	precache_sound( "weapons/c4_plant.wav" );
	precache_sound( "weapons/clipin1.wav" );
	precache_sound( "weapons/clipout1.wav" );
	precache_sound( "weapons/de_clipin.wav" );
	precache_sound( "weapons/de_clipout.wav" );
	precache_sound( "weapons/de_deploy.wav" );
	precache_sound( "weapons/deagle-1.wav" );
	precache_sound( "weapons/deagle-2.wav" );
	precache_sound( "weapons/dryfire_pistol.wav" );
	precache_sound( "weapons/dryfire_rifle.wav" );
	precache_sound( "weapons/elite_clipout.wav" );
	precache_sound( "weapons/elite_deploy.wav" );
	precache_sound( "weapons/elite_fire.wav" );
	precache_sound( "weapons/elite_leftclipin.wav" );
	precache_sound( "weapons/elite_reloadstart.wav" );
	precache_sound( "weapons/elite_rightclipin.wav" );
	precache_sound( "weapons/elite_sliderelease.wav" );
	precache_sound( "weapons/elite_twirl.wav" );
	precache_sound( "weapons/fiveseven-1.wav" );
	precache_sound( "weapons/fiveseven_clipin.wav" );
	precache_sound( "weapons/fiveseven_clipout.wav" );
	precache_sound( "weapons/fiveseven_slidepull.wav" );
	precache_sound( "weapons/fiveseven_sliderelease.wav" );
	precache_sound( "weapons/flashbang-1.wav" );
	precache_sound( "weapons/flashbang-2.wav" );
	precache_sound( "weapons/g3sg1-1.wav" );
	precache_sound( "weapons/g3sg1_clipin.wav" );
	precache_sound( "weapons/g3sg1_clipout.wav" );
	precache_sound( "weapons/g3sg1_slide.wav" );
	precache_sound( "weapons/generic_reload.wav" );
	precache_sound( "weapons/generic_shot_reload.wav" );
	precache_sound( "weapons/glock18-1.wav" );
	precache_sound( "weapons/glock18-2.wav" );
	precache_sound( "weapons/grenade_hit1.wav" );
	precache_sound( "weapons/grenade_hit2.wav" );
	precache_sound( "weapons/grenade_hit3.wav" );
	precache_sound( "weapons/he_bounce-1.wav" );
	precache_sound( "weapons/headshot2.wav" );
	precache_sound( "weapons/hegrenade-1.wav" );
	precache_sound( "weapons/hegrenade-2.wav" );
	precache_sound( "weapons/knife_deploy1.wav" );
	precache_sound( "weapons/knife_hit1.wav" );
	precache_sound( "weapons/knife_hit2.wav" );
	precache_sound( "weapons/knife_hit3.wav" );
	precache_sound( "weapons/knife_hit4.wav" );
	precache_sound( "weapons/knife_hitwall1.wav" );
	precache_sound( "weapons/knife_slash1.wav" );
	precache_sound( "weapons/knife_slash2.wav" );
	precache_sound( "weapons/knife_stab.wav" );
	precache_sound( "weapons/m249-1.wav" );
	precache_sound( "weapons/m249-2.wav" );
	precache_sound( "weapons/m249_boxin.wav" );
	precache_sound( "weapons/m249_boxout.wav" );
	precache_sound( "weapons/m249_chain.wav" );
	precache_sound( "weapons/m249_coverdown.wav" );
	precache_sound( "weapons/m249_coverup.wav" );
	precache_sound( "weapons/m3-1.wav" );
	precache_sound( "weapons/m3_insertshell.wav" );
	precache_sound( "weapons/m3_pump.wav" );
	precache_sound( "weapons/m4a1-1.wav" );
	precache_sound( "weapons/m4a1_boltpull.wav" );
	precache_sound( "weapons/m4a1_clipin.wav" );
	precache_sound( "weapons/m4a1_clipout.wav" );
	precache_sound( "weapons/m4a1_deploy.wav" );
	precache_sound( "weapons/m4a1_silencer_off.wav" );
	precache_sound( "weapons/m4a1_silencer_on.wav" );
	precache_sound( "weapons/m4a1_unsil-1.wav" );
	precache_sound( "weapons/m4a1_unsil-2.wav" );
	precache_sound( "weapons/mac10-1.wav" );
	precache_sound( "weapons/mac10_boltpull.wav" );
	precache_sound( "weapons/mac10_clipin.wav" );
	precache_sound( "weapons/mac10_clipout.wav" );
	precache_sound( "weapons/mp5-1.wav" );
	precache_sound( "weapons/mp5-2.wav" );
	precache_sound( "weapons/mp5_clipin.wav" );
	precache_sound( "weapons/mp5_clipout.wav" );
	precache_sound( "weapons/mp5_slideback.wav" );
	precache_sound( "weapons/p228-1.wav" );
	precache_sound( "weapons/p228_clipin.wav" );
	precache_sound( "weapons/p228_clipout.wav" );
	precache_sound( "weapons/p228_slidepull.wav" );
	precache_sound( "weapons/p228_sliderelease.wav" );
	precache_sound( "weapons/p90-1.wav" );
	precache_sound( "weapons/p90_boltpull.wav" );
	precache_sound( "weapons/p90_clipin.wav" );
	precache_sound( "weapons/p90_clipout.wav" );
	precache_sound( "weapons/p90_cliprelease.wav" );
	precache_sound( "weapons/pinpull.wav" );
	precache_sound( "weapons/ric1.wav" );
	precache_sound( "weapons/ric2.wav" );
	precache_sound( "weapons/ric3.wav" );
	precache_sound( "weapons/ric4.wav" );
	precache_sound( "weapons/ric5.wav" );
	precache_sound( "weapons/ric_conc-1.wav" );
	precache_sound( "weapons/ric_conc-2.wav" );
	precache_sound( "weapons/ric_metal-1.wav" );
	precache_sound( "weapons/ric_metal-2.wav" );
	precache_sound( "weapons/scout_bolt.wav" );
	precache_sound( "weapons/scout_clipin.wav" );
	precache_sound( "weapons/scout_clipout.wav" );
	precache_sound( "weapons/scout_fire-1.wav" );
	precache_sound( "weapons/sg550-1.wav" );
	precache_sound( "weapons/sg550_boltpull.wav" );
	precache_sound( "weapons/sg550_clipin.wav" );
	precache_sound( "weapons/sg550_clipout.wav" );
	precache_sound( "weapons/sg552-1.wav" );
	precache_sound( "weapons/sg552-2.wav" );
	precache_sound( "weapons/sg552_boltpull.wav" );
	precache_sound( "weapons/sg552_clipin.wav" );
	precache_sound( "weapons/sg552_clipout.wav" );
	precache_sound( "weapons/sg_explode.wav" );
	precache_sound( "weapons/slideback1.wav" );
	precache_sound( "weapons/sliderelease1.wav" );
	precache_sound( "weapons/tmp-1.wav" );
	precache_sound( "weapons/tmp-2.wav" );
	precache_sound( "weapons/ump45-1.wav" );
	precache_sound( "weapons/ump45_boltslap.wav" );
	precache_sound( "weapons/ump45_clipin.wav" );
	precache_sound( "weapons/ump45_clipout.wav" );
	precache_sound( "weapons/usp1.wav" );
	precache_sound( "weapons/usp2.wav" );
	precache_sound( "weapons/usp_clipin.wav" );
	precache_sound( "weapons/usp_clipout.wav" );
	precache_sound( "weapons/usp_silencer_off.wav" );
	precache_sound( "weapons/usp_silencer_on.wav" );
	precache_sound( "weapons/usp_slideback.wav" );
	precache_sound( "weapons/usp_sliderelease.wav" );
	precache_sound( "weapons/usp_unsil-1.wav" );
	precache_sound( "weapons/xm1014-1.wav" );
	precache_sound( "weapons/zoom.wav" );
	
	precache_sound( "debris/glass1.wav" );
	precache_sound( "debris/glass2.wav" );
	precache_sound( "debris/glass3.wav" );
	precache_sound( "debris/wood1.wav" );
	precache_sound( "debris/wood2.wav" );
	precache_sound( "debris/wood3.wav" );
	precache_sound( "debris/metal1.wav" );
	precache_sound( "debris/metal2.wav" );
	precache_sound( "debris/metal3.wav" );
	precache_sound( "debris/flesh1.wav" );
	precache_sound( "debris/flesh2.wav" );
	precache_sound( "debris/flesh3.wav" );
	precache_sound( "debris/flesh4.wav" );
	precache_sound( "debris/flesh5.wav" );
	precache_sound( "debris/flesh6.wav" );
	precache_sound( "debris/flesh7.wav" );
	precache_sound( "debris/concrete1.wav" );
	precache_sound( "debris/concrete2.wav" );
	precache_sound( "debris/concrete3.wav" );
	precache_sound( "debris/bustglass1.wav" );
	precache_sound( "debris/bustglass2.wav" );
	precache_sound( "debris/bustwood1.wav" );
	precache_sound( "debris/bustwood2.wav" );
	precache_sound( "debris/bustmetal1.wav" );
	precache_sound( "debris/bustmetal2.wav" );
	precache_sound( "debris/bustflesh1.wav" );
	precache_sound( "debris/bustflesh2.wav" );
	precache_sound( "debris/bustconcrete1.wav" );
	precache_sound( "debris/bustconcrete2.wav" );
	precache_sound( "debris/bustconcrete3.wav" );
	precache_sound( "debris/bustceiling1.wav" );
	precache_sound( "debris/bustceiling2.wav" );
	precache_sound( "debris/bustceiling3.wav" );
	
	precache_sound( "player/pl_metal1.wav" );
	precache_sound( "player/pl_metal2.wav" );
	precache_sound( "player/pl_metal3.wav" );
	precache_sound( "player/pl_metal4.wav" );
	
	precache_sound( "player/pl_duct1.wav" );
	precache_sound( "player/pl_duct2.wav" );
	precache_sound( "player/pl_duct3.wav" );
	precache_sound( "player/pl_duct4.wav" );
	
	precache_sound( "player/pl_dirt1.wav" );
	precache_sound( "player/pl_dirt2.wav" );
	precache_sound( "player/pl_dirt3.wav" );
	precache_sound( "player/pl_dirt4.wav" );
	
	precache_sound( "player/pl_slosh1.wav" );
	precache_sound( "player/pl_slosh2.wav" );
	precache_sound( "player/pl_slosh3.wav" );
	precache_sound( "player/pl_slosh4.wav" );
	
	precache_sound( "player/pl_tile1.wav" );
	precache_sound( "player/pl_tile2.wav" );
	precache_sound( "player/pl_tile3.wav" );
	precache_sound( "player/pl_tile4.wav" );
	
	precache_sound( "player/pl_grate1.wav" );
	precache_sound( "player/pl_grate2.wav" );
	precache_sound( "player/pl_grate3.wav" );
	precache_sound( "player/pl_grate4.wav" );
	
	precache_sound( "player/pl_snow1.wav" );
	precache_sound( "player/pl_snow2.wav" );
	precache_sound( "player/pl_snow3.wav" );
	precache_sound( "player/pl_snow4.wav" );
	
	precache_sound( "player/pl_step1.wav" );
	precache_sound( "player/pl_step2.wav" );
	precache_sound( "player/pl_step3.wav" );
	precache_sound( "player/pl_step4.wav" );

	lightstyle( 0, "m" );
	lightstyle( 1, "mmnmmommommnonmmonqnmmo" );
	lightstyle( 2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba" );
	lightstyle( 3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg" );
	lightstyle( 4, "mamamamamama" );
	lightstyle( 5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj" );
	lightstyle( 6, "nmonqnmomnmomomno" );
	lightstyle( 7, "mmmaaaabcdefgmmmmaaaammmaamm" );
	lightstyle( 8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa" );
	lightstyle( 9, "aaaaaaaazzzzzzzz" );
	lightstyle( 10, "mmamammmmammamamaaamammma" );
	lightstyle( 11, "abcdefghijklmnopqrrqponmlkjihgfedcba" );

	// TODO: Merge these into a single field?
	clientstat( STAT_BUYZONE, EV_FLOAT, fInBuyZone );
	clientstat( STAT_HOSTAGEZONE, EV_FLOAT, fInHostageZone );
	clientstat( STAT_BOMBZONE, EV_FLOAT, fInBombZone );
	
	clientstat( 4, EV_FLOAT, armor );
	clientstat( STAT_MONEY, EV_FLOAT, fMoney );
	clientstat( STAT_SLOT_MELEE, EV_FLOAT, fSlotMelee );
	clientstat( STAT_SLOT_PRIMARY, EV_FLOAT, fSlotPrimary );
	clientstat( STAT_SLOT_SECONDARY, EV_FLOAT, fSlotSecondary );
	clientstat( STAT_SLOT_GRENADE, EV_FLOAT, fSlotGrenade );
	clientstat( STAT_EQUIPMENT, EV_INTEGER, iEquipment );
	clientstat( STAT_CURRENT_MAG, EV_INTEGER, iCurrentMag );
	clientstat( STAT_CURRENT_CALIBER, EV_INTEGER, iCurrentCaliber );
	clientstat( STAT_TEAM, EV_INTEGER, team );
	clientstat( STAT_PROGRESS, EV_FLOAT, fProgressBar );
	clientstat( STAT_FLAGS, EV_FLOAT, flags );
	pointerstat( STAT_GAMETIME, EV_FLOAT, &fGameTime );
	pointerstat( STAT_WON_T, EV_INTEGER, &iWon_T );
	pointerstat( STAT_WON_CT, EV_INTEGER, &iWon_CT );
}
