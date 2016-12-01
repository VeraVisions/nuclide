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

.int iClip_G3SG1;

// Weapon Info
weaponinfo_t wptG3SG1 = { 
	WEAPON_G3SG1, 		// Identifier
	SLOT_PRIMARY,
	5000, 				// Price
	CALIBER_762MM, 		// Caliber ID
	210, 				// Max Player Speed
	1, 					// Bullets Per Shot
	20, 				// Clip/MagSize
	80, 				// Damage Per Bullet
	3, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.98, 				// Range Modifier
	TYPE_AUTO,
	0.15, 				// Attack-Delay
	3.0, 				// Reload-Delay
	iAmmo_762MM, 		// Caliber Pointer
	iClip_G3SG1 		// Clip Pointer
};

// Anim Table
enum {
	ANIM_G3SG1_IDLE,
	ANIM_G3SG1_SHOOT1,
	ANIM_G3SG1_SHOOT2,
	ANIM_G3SG1_RELOAD,
	ANIM_G3SG1_DRAW
};

void WeaponG3SG1_Draw( void ) {
	#ifdef QWSSQC
	OpenCSGunBase_Draw();
	sound( self, CHAN_WEAPON, "weapons/g3sg1_slide.wav", 1, ATTN_IDLE ); // TODO: Move to the client...?
	#else
	View_PlayAnimation( ANIM_G3SG1_DRAW );
	#endif
}

void WeaponG3SG1_PrimaryFire( void ) {
	#ifdef QWSSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		// Play Sound
		dprint("[DEBUG] FIRE!\n");
		sound( self, CHAN_WEAPON, "weapons/g3sg1-1.wav", 1, ATTN_NORM );
	}
	#else

	if ( random() <= 0.5 ) {
		View_PlayAnimation( ANIM_G3SG1_SHOOT1 );
	} else {
		View_PlayAnimation( ANIM_G3SG1_SHOOT2 );
	}
	#endif
}

void WeaponG3SG1_Reload( void ) {
	#ifdef QWSSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_G3SG1_RELOAD );
	#endif
}
