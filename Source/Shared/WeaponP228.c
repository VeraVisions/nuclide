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

.int iClip_P228;

// Weapon Info
weaponinfo_t wptP228 = { 
	WEAPON_P228, 		// Identifier
	SLOT_SECONDARY,
	600, 				// Price
	CALIBER_357SIG, 	// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	13, 				// Clip/MagSize
	40, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.8, 				// Range Modifier
	TYPE_SEMI,
	0.15, 				// Attack-Delay
	2.7, 				// Reload-Delay
	iAmmo_357SIG, 		// Caliber Pointer
	iClip_P228, 		// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4					// Max Inaccuracy
};

// Anim Table
enum {
	ANIM_P228_IDLE,
	ANIM_P228_SHOOT1,
	ANIM_P228_SHOOT2,
	ANIM_P228_SHOOT3,
	ANIM_P228_SHOOT_EMPTY,
	ANIM_P228_RELOAD,
	ANIM_P228_DRAW
};

void WeaponP228_Draw( void ) {
#ifdef SSQC
	OpenCSGunBase_Draw();
#else
	View_PlayAnimation( ANIM_P228_DRAW );
	Sound_Delayed( "weapons/p228_slidepull.wav", 1.0, 0.5 );
#endif
}

void WeaponP228_PrimaryFire( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		// Play Sound
		sound( self, CHAN_WEAPON, "weapons/p228-1.wav", 1, ATTN_NORM );
	}
#else
	if ( getstatf( STAT_CURRENT_CLIP ) == 0 ) {
		View_PlayAnimation( ANIM_P228_SHOOT_EMPTY );
	} else {
		
		int iRand = ceil( random() * 3 );
		
		if ( iRand == 1 ) {
			View_PlayAnimation( ANIM_P228_SHOOT1 );
		} else if ( iRand == 2 ) {
			View_PlayAnimation( ANIM_P228_SHOOT2 );
		} else {
			View_PlayAnimation( ANIM_P228_SHOOT3 );
		}
	}
#endif
}

void WeaponP228_Reload( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_P228_RELOAD );
	
	Sound_Delayed( "weapons/p228_clipout.wav", 1.0, 0.5 );
	Sound_Delayed( "weapons/p228_clipin.wav", 1.0, 1.5 );
	Sound_Delayed( "weapons/p228_sliderelease.wav", 1.0, 2.4 );
#endif
}
