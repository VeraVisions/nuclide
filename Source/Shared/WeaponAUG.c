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

.int iClip_AUG;

// Weapon Info
weaponinfo_t wptAUG = { 
	WEAPON_AUG, 		// Identifier
	SLOT_PRIMARY,
	3500, 				// Price
	CALIBER_762MM, 		// Caliber ID
	221, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	32, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.96, 				// Range Modifier
	TYPE_AUTO,
	0.09, 				// Attack-Delay
	3.3, 				// Reload-Delay
	iAmmo_762MM, 		// Caliber Pointer
	iClip_AUG 		// Clip Pointer
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
	#ifdef QWSSQC
	OpenCSGunBase_Draw();
	sound( self, CHAN_WEAPON, "weapons/aug_boltpull.wav", 1, ATTN_IDLE ); // TODO: Move to the client...?
	#else
	View_PlayAnimation( ANIM_AUG_DRAW );
	#endif
}

void WeaponAUG_PrimaryFire( void ) {
	#ifdef QWSSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/aug-1.wav", 1, ATTN_NORM );
	}
	#else
	int iRand = ceil( random() * 3 );
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_AUG_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_AUG_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_AUG_SHOOT3 );
	}
	#endif
}

void WeaponAUG_Reload( void ) {
	#ifdef QWSSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_AUG_RELOAD );
	#endif
}
