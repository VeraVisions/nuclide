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

.int iMag_SG552;

// Weapon Info
weaponinfo_t wptSG552 = { 
	WEAPON_SG552, 		// Identifier
	SLOT_PRIMARY,		// Slot
	3500, 				// Price
	CALIBER_556MM, 		// Caliber ID
	0.94, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	33, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.955, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.09, 				// Attack-Delay
	3.2, 				// Reload-Delay
	iAmmo_556MM, 		// Caliber Pointer
	iMag_SG552, 		// Clip Pointer
	220,				// Accuracy Divisor
	0.3,				// Accuracy Offset
	1.0,				// Max Inaccuracy
	5,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.4					// Armor penetration ratio
};

// Anim Table
enum {
	ANIM_SG552_IDLE,
	ANIM_SG552_RELOAD,
	ANIM_SG552_DRAW,
	ANIM_SG552_SHOOT1,
	ANIM_SG552_SHOOT2,
	ANIM_SG552_SHOOT3
};

void WeaponSG552_Draw( void ) {
	#ifdef SSQC
	OpenCSGunBase_Draw();
	#else
	View_PlayAnimation( ANIM_SG552_DRAW );
	Sound_Delayed( "weapons/sg552_boltpull.wav", 1.0, 0.5 );
	#endif
}

void WeaponSG552_PrimaryFire( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/sg552-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/sg552-2.wav", 1, ATTN_NORM );
		}
	}
	#else
	int iRand = (int)floor( random( 1, 4 ) );
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_SG552_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_SG552_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_SG552_SHOOT3 );
	}
	
	OpenCSGunBase_ShotMultiplierHandle( 1 );
	#endif
}

void WeaponSG552_SecondaryFire( void ) {
#ifdef SSQC
	if ( self.viewzoom != 1.0 ) {
		self.viewzoom = 1.0;
	} else {
		self.viewzoom = 0.6;
	}
	
	self.fAttackFinished = time + 0.5;
#endif
}

void WeaponSG552_Reload( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_SG552_RELOAD );
	Sound_Delayed( "weapons/sg552_clipout.wav", 1.0, 0.7 );
	Sound_Delayed( "weapons/sg552_clipin.wav", 1.0, 1.7 );
	Sound_Delayed( "weapons/sg552_boltpull.wav", 1.0, 2.4 );
	#endif
}
