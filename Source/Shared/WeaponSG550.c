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

.int iClip_SG550;

// Weapon Info
weaponinfo_t wptSG550 = { 
	WEAPON_SG550, 		// Identifier
	SLOT_PRIMARY,
	4200, 				// Price
	CALIBER_556MM, 		// Caliber ID
	210, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	70, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.98, 				// Range Modifier
	TYPE_AUTO,
	0.25, 				// Attack-Delay
	3.8, 				// Reload-Delay
	iAmmo_556MM, 		// Caliber Pointer
	iClip_SG550, 		// Clip Pointer
	-1,					// Accuracy Divisor
	0,					// Accuracy Offset
	0					// Max Inaccuracy
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
	sound( self, CHAN_WEAPON, "weapons/sg550_boltpull.wav", 1, ATTN_IDLE ); // TODO: Move to the client...?
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
	#endif
}

void WeaponSG550_Reload( void ) {
	#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_SG550_RELOAD );
	#endif
}
