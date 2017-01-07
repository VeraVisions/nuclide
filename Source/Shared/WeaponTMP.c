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

.int iMag_TMP;

// Weapon Info
weaponinfo_t wptTMP = { 
	WEAPON_TMP, 		// Identifier
	SLOT_PRIMARY,		// Slot
	1250, 				// Price
	CALIBER_9MM, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	26, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.84, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.07, 				// Attack-Delay
	2.1, 				// Reload-Delay
	iAmmo_9MM, 			// Caliber Pointer
	iMag_TMP, 			// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4,				// Max Inaccuracy
	7,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.0					// Armor penetration ratio
};

// Anim Table
enum {
	ANIM_TMP_IDLE,
	ANIM_TMP_RELOAD,
	ANIM_TMP_DRAW,
	ANIM_TMP_SHOOT1,
	ANIM_TMP_SHOOT2,
	ANIM_TMP_SHOOT3
};

void WeaponTMP_Draw( void ) {
#ifdef SSQC
	OpenCSGunBase_Draw();
#else
	View_PlayAnimation( ANIM_TMP_DRAW );
#endif
}

void WeaponTMP_PrimaryFire( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/tmp-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/tmp-2.wav", 1, ATTN_NORM );
		}
	}
#else
	int iRand = (int)floor( random( 1, 4 ) );
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_TMP_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_TMP_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_TMP_SHOOT3 );
	}
	
	OpenCSGunBase_ShotMultiplierHandle( 1 );
#endif
}

void WeaponTMP_Reload( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_TMP_RELOAD );
	
	Sound_Delayed( "weapons/mac10_clipout.wav", 1.0, 0.6 );
	Sound_Delayed( "weapons/mac10_clipin.wav", 1.0, 1.6 );
#endif
}
