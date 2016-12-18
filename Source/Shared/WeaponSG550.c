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

.int iMag_SG550;

// Weapon Info
weaponinfo_t wptSG550 = { 
	WEAPON_SG550, 		// Identifier
	SLOT_PRIMARY,		// Slot
	4200, 				// Price
	CALIBER_556MM, 		// Caliber ID
	0.84, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	70, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.98, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.25, 				// Attack-Delay
	3.8, 				// Reload-Delay
	iAmmo_556MM, 		// Caliber Pointer
	iMag_SG550, 		// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4,				// Max Inaccuracy
	5,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.45				// Armor penetration ratio
};

// Anim Table
enum {
	ANIM_SG550_IDLE,
	ANIM_SG550_SHOOT1,
	ANIM_SG550_SHOOT2,
	ANIM_SG550_RELOAD,
	ANIM_SG550_DRAW,
};

void WeaponSG550_Draw( void ) {
	#ifdef SSQC
	OpenCSGunBase_Draw();
	#else
	View_PlayAnimation( ANIM_SG550_DRAW );
	#endif
}

void WeaponSG550_PrimaryFire( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/sg550-1.wav", 1, ATTN_NORM );
	}
	#else

	if ( random() <= 0.5 ) {
		View_PlayAnimation( ANIM_SG550_SHOOT1 );
	} else {
		View_PlayAnimation( ANIM_SG550_SHOOT2 );
	} 
	OpenCSGunBase_ShotMultiplierHandle( 1 );
	#endif
}

void WeaponSG550_SecondaryFire( void ) {
#ifdef SSQC
	if ( self.viewzoom == 1.0 ) {
		self.viewzoom = 0.45;
	} else if ( self.viewzoom == 0.45 ) {
		self.viewzoom = 0.15;
	} else {
		self.viewzoom = 1.0;
	}
	
	self.fAttackFinished = time + 0.5;
#endif
}

void WeaponSG550_Reload( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_SG550_RELOAD );
	Sound_Delayed( "weapons/sg550_clipout.wav", 1.0, 0.7 );
	Sound_Delayed( "weapons/sg550_clipin.wav", 1.0, 1.7 );
	Sound_Delayed( "weapons/sg550_boltpull.wav", 1.0, 2.9 );
	#endif
}
