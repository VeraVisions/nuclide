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

.int iClip_DEAGLE;

// Weapon Info
weaponinfo_t wptDEAGLE = { 
	WEAPON_DEAGLE, 		// Identifier
	SLOT_SECONDARY,
	3500, 				// Price
	CALIBER_50AE, 		// Caliber ID
	650, 				// Max Player Speed
	1, 					// Bullets Per Shot
	7, 					// Clip/MagSize
	54, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.81, 				// Range Modifier
	TYPE_SEMI,
	0.15, 				// Attack-Delay
	3.0, 				// Reload-Delay
	iAmmo_50AE, 		// Caliber Pointer
	iClip_DEAGLE 		// Clip Pointer
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
	#ifdef QWSSQC
	OpenCSGunBase_Draw();
	sound( self, CHAN_WEAPON, "weapons/de_deploy.wav", 1, ATTN_IDLE ); // TODO: Move to the client..
	#else
	View_PlayAnimation( ANIM_DEAGLE_DRAW );
	#endif
}

void WeaponDEAGLE_PrimaryFire( void ) {
	#ifdef QWSSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/deagle-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/deagle-2.wav", 1, ATTN_NORM );
		}
	}
	#else
	if ( getstatf( STAT_CURRENT_CLIP ) == 0 ) {
		View_PlayAnimation( ANIM_DEAGLE_SHOOT_EMPTY );
	} else {
		if ( random() <= 0.5 ) {
			View_PlayAnimation( ANIM_DEAGLE_SHOOT1 );
		} else {
			View_PlayAnimation( ANIM_DEAGLE_SHOOT2 );
		}
	}
	
	#endif
}

void WeaponDEAGLE_Reload( void ) {
	#ifdef QWSSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_DEAGLE_RELOAD );
	#endif
}
