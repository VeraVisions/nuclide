/*
OpenCS Project
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

.int iMag_DEAGLE;

// Weapon Info
weaponinfo_t wptDEAGLE = { 
	WEAPON_DEAGLE, 		// Identifier
	SLOT_SECONDARY,		// Slot
	650, 				// Price
	CALIBER_50AE, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	7, 					// Clip/MagSize
	54, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.81, 				// Range Modifier
	TYPE_SEMI,			// Firing Type
	0.15, 				// Attack-Delay
	2.1, 				// Reload-Delay
	iAmmo_50AE, 		// Caliber Pointer
	iMag_DEAGLE, 		// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4,				// Max Inaccuracy
	8,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.5					// Armor penetration ratio
};

// Anim Table
enum {
	ANIM_DEAGLE_IDLE,
	ANIM_DEAGLE_SHOOT1,
	ANIM_DEAGLE_SHOOT2,
	ANIM_DEAGLE_SHOOT_EMPTY,
	ANIM_DEAGLE_RELOAD,
	ANIM_DEAGLE_DRAW
};

void WeaponDEAGLE_Draw( void ) {
	#ifdef SSQC
	OpenCSGunBase_Draw();
	#else
	View_PlayAnimation( ANIM_DEAGLE_DRAW );
	#endif
}

void WeaponDEAGLE_PrimaryFire( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/deagle-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/deagle-2.wav", 1, ATTN_NORM );
		}
	}
	#else
	if ( getstatf( STAT_CURRENT_MAG ) == 0 ) {
		View_PlayAnimation( ANIM_DEAGLE_SHOOT_EMPTY );
	} else {
		if ( random() <= 0.5 ) {
			View_PlayAnimation( ANIM_DEAGLE_SHOOT1 );
		} else {
			View_PlayAnimation( ANIM_DEAGLE_SHOOT2 );
		}
	}
	
	OpenCSGunBase_ShotMultiplierHandle( 1 );
	#endif
}

void WeaponDEAGLE_Reload( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_DEAGLE_RELOAD );
	Sound_Delayed( "weapons/de_clipout.wav", 1.0, 0.5 );
	Sound_Delayed( "weapons/de_clipin.wav", 1.0, 1.2 );
	#endif
}
