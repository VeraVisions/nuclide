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

.int iMag_FIVESEVEN;

// Weapon Info
weaponinfo_t wptFIVESEVEN = { 
	WEAPON_FIVESEVEN, 	// Identifier
	SLOT_SECONDARY,		// Slot
	750, 				// Price
	CALIBER_57MM, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	20, 				// Clip/MagSize
	25, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.885, 				// Range Modifier
	TYPE_SEMI,			// Firing Type
	0.15, 				// Attack-Delay
	3.1, 				// Reload-Delay
	iAmmo_57MM, 		// Caliber Pointer
	iMag_FIVESEVEN, 	// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4,				// Max Inaccuracy
	8,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.5					// Armor penetration ratio
};

// Anim Table
enum {
	ANIM_FIVESEVEN_IDLE,
	ANIM_FIVESEVEN_SHOOT1,
	ANIM_FIVESEVEN_SHOOT2,
	ANIM_FIVESEVEN_SHOOT_EMPTY,
	ANIM_FIVESEVEN_RELOAD,
	ANIM_FIVESEVEN_DRAW
};

void WeaponFIVESEVEN_Draw( void ) {
	#ifdef SSQC
	OpenCSGunBase_Draw();
	#else
	View_PlayAnimation( ANIM_FIVESEVEN_DRAW );
	Sound_Delayed( "weapons/fiveseven_slidepull.wav", 1.0, 0.5 );
	#endif
}

void WeaponFIVESEVEN_PrimaryFire( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		// Play Sound
		sound( self, CHAN_WEAPON, "weapons/fiveseven-1.wav", 1, ATTN_NORM );
	}
	#else
	if ( getstatf( STAT_CURRENT_MAG ) == 0 ) {
		View_PlayAnimation( ANIM_FIVESEVEN_SHOOT_EMPTY );
	} else {
		if ( random() <= 0.5 ) {
			View_PlayAnimation( ANIM_FIVESEVEN_SHOOT1 );
		} else {
			View_PlayAnimation( ANIM_FIVESEVEN_SHOOT2 );
		}
	}
	OpenCSGunBase_ShotMultiplierHandle( 1 );
	#endif
}

void WeaponFIVESEVEN_Reload( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_FIVESEVEN_RELOAD );
	
	Sound_Delayed( "weapons/p228_clipout.wav", 1.0, 0.5 );
	Sound_Delayed( "weapons/p228_clipin.wav", 1.0, 1.5 );
	Sound_Delayed( "weapons/p228_sliderelease.wav", 1.0, 2.4 );
	#endif
}
