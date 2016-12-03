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

.int iClip_SCOUT;

// Weapon Info
weaponinfo_t wptSCOUT = { 
	WEAPON_SCOUT, 		// Identifier
	SLOT_PRIMARY,
	2750, 				// Price
	CALIBER_762MM, 		// Caliber ID
	240, 				// Max Player Speed
	1, 					// Bullets Per Shot
	10, 				// Clip/MagSize
	75, 				// Damage Per Bullet
	3, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.98, 				// Range Modifier
	TYPE_AUTO,
	1.25, 				// Attack-Delay
	2.0, 				// Reload-Delay
	iAmmo_762MM, 		// Caliber Pointer
	iClip_SCOUT, 	// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4					// Max Inaccuracy
};

// Anim Table
enum {
	ANIM_SCOUT_IDLE,
	ANIM_SCOUT_SHOOT1,
	ANIM_SCOUT_SHOOT2,
	ANIM_SCOUT_RELOAD,
	ANIM_SCOUT_DRAW
};

void WeaponSCOUT_Draw( void ) {
#ifdef SSQC
	OpenCSGunBase_Draw();
#else
	View_PlayAnimation( ANIM_SCOUT_DRAW );
#endif
}

void WeaponSCOUT_PrimaryFire( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		// Play Sound
		sound( self, CHAN_WEAPON, "weapons/scout_fire-1.wav", 1, ATTN_NORM );
	}
#else
	if ( random() <= 0.5 ) {
		View_PlayAnimation( ANIM_SCOUT_SHOOT1 );
	} else {
		View_PlayAnimation( ANIM_SCOUT_SHOOT2 );
	}
	
	Sound_Delayed( "weapons/scout_bolt.wav", 1.0, 0.5 );
#endif
}

void WeaponSCOUT_Reload( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_SCOUT_RELOAD );
	
	Sound_Delayed( "weapons/scout_clipout.wav", 1.0, 0.75 );
	Sound_Delayed( "weapons/scout_clipin.wav", 1.0, 1.25 ); 
	
#endif
}
