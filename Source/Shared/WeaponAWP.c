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

.int iClip_AWP;

// Weapon Info
weaponinfo_t wptAWP = { 
	WEAPON_AWP, 		// Identifier
	SLOT_PRIMARY,
	4750, 				// Price
	CALIBER_338MAG, 	// Caliber ID
	210, 				// Max Player Speed
	1, 					// Bullets Per Shot
	10, 				// Clip/MagSize
	115, 				// Damage Per Bullet
	3, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.99, 				// Range Modifier
	TYPE_AUTO,
	1.2, 				// Attack-Delay
	2.9, 				// Reload-Delay
	iAmmo_338MAG, 		// Caliber Pointer
	iClip_AWP 		// Clip Pointer
};

// Anim Table
enum {
	ANIM_AWP_IDLE,
	ANIM_AWP_SHOOT1,
	ANIM_AWP_SHOOT2,
	ANIM_AWP_SHOOT3,
	ANIM_AWP_RELOAD,
	ANIM_AWP_DRAW
};

void WeaponAWP_Draw( void ) {
	#ifdef QWSSQC
	OpenCSGunBase_Draw();
	sound( self, CHAN_WEAPON, "weapons/awp_deploy.wav", 1, ATTN_IDLE ); // TODO: Move to the client...?
	#else
	View_PlayAnimation( ANIM_AWP_DRAW );
	#endif
}

void WeaponAWP_PrimaryFire( void ) {
	#ifdef QWSSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		// Play Sound
		sound( self, CHAN_WEAPON, "weapons/awp1.wav", 1, ATTN_NORM );
	}
	#else
	int iRand = ceil( random() * 3 );
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_AWP_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_AWP_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_AWP_SHOOT3 );
	}
	#endif
}

void WeaponAWP_Reload( void ) {
	#ifdef QWSSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_AWP_RELOAD );
	#endif
}
