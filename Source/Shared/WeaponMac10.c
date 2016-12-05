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

.int iClip_MAC10;

// Weapon Info
weaponinfo_t wptMAC10 = { 
	WEAPON_MAC10, 		// Identifier
	SLOT_PRIMARY,
	1400, 				// Price
	CALIBER_45ACP, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	29, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.82, 				// Range Modifier
	TYPE_AUTO,
	0.075, 				// Attack-Delay
	3.2, 				// Reload-Delay
	iAmmo_45ACP, 		// Caliber Pointer
	iClip_MAC10, 		// Clip Pointer
	200,				// Accuracy Divisor
	0.6,				// Accuracy Offset
	1.65				// Max Inaccuracy
};

// Anim Table
enum {
	ANIM_MAC10_IDLE,
	ANIM_MAC10_RELOAD,
	ANIM_MAC10_DRAW,
	ANIM_MAC10_SHOOT1,
	ANIM_MAC10_SHOOT2,
	ANIM_MAC10_SHOOT3
};

void WeaponMAC10_Draw( void ) {
#ifdef SSQC
	OpenCSGunBase_Draw();
#else
	View_PlayAnimation( ANIM_MAC10_DRAW );
#endif
}

void WeaponMAC10_PrimaryFire( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/mac10-1.wav", 1, ATTN_NORM );
	}
#else
	int iRand = ceil( random() * 3 );
	
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_MAC10_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_MAC10_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_MAC10_SHOOT3 );
	}
#endif
}

void WeaponMAC10_Reload( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_MAC10_RELOAD );
	
	Sound_Delayed( "weapons/mac10_clipout.wav", 1.0, 0.6 );
	Sound_Delayed( "weapons/mac10_clipin.wav", 1.0, 1.6 );
	Sound_Delayed( "weapons/mac10_boltpull.wav", 1.0, 2.5 );
#endif
}
