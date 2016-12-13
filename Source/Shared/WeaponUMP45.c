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

.int iMag_UMP45;

// Weapon Info
weaponinfo_t wptUMP45 = { 
	WEAPON_UMP45, 		// Identifier
	SLOT_PRIMARY,		// Slot
	1700, 				// Price
	CALIBER_45ACP, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	25, 				// Clip/MagSize
	30, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.82, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.105, 				// Attack-Delay
	3.5, 				// Reload-Delay
	iAmmo_45ACP, 		// Caliber Pointer
	iMag_UMP45, 		// Clip Pointer
	210,				// Accuracy Divisor
	0.5,				// Accuracy Offset
	1,					// Max Inaccuracy
	6,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.0					// Armor penetration ratio
};

// Anim Table
enum {
	ANIM_UMP45_IDLE,
	ANIM_UMP45_RELOAD,
	ANIM_UMP45_DRAW,
	ANIM_UMP45_SHOOT1,
	ANIM_UMP45_SHOOT2,
	ANIM_UMP45_SHOOT3
};

void WeaponUMP45_Draw( void ) {
#ifdef SSQC
	OpenCSGunBase_Draw();
	//sound( self, CHAN_WEAPON, "weapons/ump45_boltslap.wav", 1, ATTN_IDLE ); // TODO: Move to the client...?
#else
	View_PlayAnimation( ANIM_UMP45_DRAW );
#endif
}

void WeaponUMP45_PrimaryFire( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM );
	}
#else
	int iRand = (int)floor( random( 1, 4 ) );
	
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_UMP45_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_UMP45_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_UMP45_SHOOT3 );
	}
	
	OpenCSGunBase_ShotMultiplierHandle( 1 );
#endif
}

void WeaponUMP45_Reload( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_UMP45_RELOAD );
	Sound_Delayed( "weapons/ump45_clipout.wav", 1.0, 0.7 );
	Sound_Delayed( "weapons/ump45_clipin.wav", 1.0, 1.8 );
	Sound_Delayed( "weapons/ump45_boltslap.wav", 1.0, 2.7 );
	#endif
}
