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

.int iMag_AUG;

// Weapon Info
weaponinfo_t wptAUG = { 
	WEAPON_AUG, 		// Identifier
	SLOT_PRIMARY,		// Slot
	3500, 				// Price
	CALIBER_762MM, 		// Caliber ID
	0.96, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	32, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.96, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.09, 				// Attack-Delay
	3.3, 				// Reload-Delay
	iAmmo_762MM, 		// Caliber Pointer
	iMag_AUG, 			// Clip Pointer
	215,				// Accuracy Divisor
	0.3,				// Accuracy Offset
	1.0,				// Max Inaccuracy
	3,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.4					// Armor penetration ratio
};

// Anim Table
enum {
	ANIM_AUG_IDLE,
	ANIM_AUG_RELOAD,
	ANIM_AUG_DRAW,
	ANIM_AUG_SHOOT1,
	ANIM_AUG_SHOOT2,
	ANIM_AUG_SHOOT3
};

void WeaponAUG_Draw( void ) {
#ifdef SSQC
	OpenCSGunBase_Draw();
#else
	View_PlayAnimation( ANIM_AUG_DRAW );
	Sound_Delayed( "weapons/aug_boltpull.wav", 1.0, 0.5 );
#endif
}

void WeaponAUG_PrimaryFire( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/aug-1.wav", 1, ATTN_NORM );
	}
#else
	int iRand = (int)floor( random( 1, 4 ) );
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_AUG_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_AUG_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_AUG_SHOOT3 );
	}
	
	OpenCSGunBase_ShotMultiplierHandle( 1 );
#endif
}

void WeaponAUG_SecondaryFire( void ) {
#ifdef SSQC
	if ( self.viewzoom != 1.0 ) {
		self.viewzoom = 1.0;
	} else {
		self.viewzoom = 0.6;
	}
	
	self.fAttackFinished = time + 0.5;
#endif
}

void WeaponAUG_Reload( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_AUG_RELOAD );
	
	Sound_Delayed( "weapons/aug_boltpull.wav", 1.0, 0.5 );
	Sound_Delayed( "weapons/aug_clipout.wav", 1.0, 1.3 );
	Sound_Delayed( "weapons/aug_clipin.wav", 1.0, 2.2 );
	Sound_Delayed( "weapons/aug_boltslap.wav", 1.0, 2.8 );
#endif
}
