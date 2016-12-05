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

.int iClip_PARA;

// Weapon Info
weaponinfo_t wptPARA = { 
	WEAPON_PARA, 		// Identifier
	SLOT_PRIMARY,
	5750, 				// Price
	CALIBER_556MMBOX, 	// Caliber ID
	0.88, 				// Max Player Speed
	1, 					// Bullets Per Shot
	100, 				// Clip/MagSize
	35, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.97, 				// Range Modifier
	TYPE_AUTO,
	0.08, 				// Attack-Delay
	3.0, 				// Reload-Delay
	iAmmo_556MMBOX, 	// Caliber Pointer
	iClip_PARA, 	// Clip Pointer
	175,				// Accuracy Divisor
	0.4,				// Accuracy Offset
	0.9				// Max Inaccuracy
};

// Anim Table
enum {
	ANIM_PARA_IDLE,
	ANIM_PARA_SHOOT1,
	ANIM_PARA_SHOOT2,
	ANIM_PARA_RELOAD,
	ANIM_PARA_DRAW
};

void WeaponPARA_Draw( void ) {
#ifdef SSQC
	OpenCSGunBase_Draw();
#else
	View_PlayAnimation( ANIM_PARA_DRAW );
#endif
}

void WeaponPARA_PrimaryFire( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/m249-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/m249-2.wav", 1, ATTN_NORM );
		}
	}
#else
	if ( random() <= 0.5 ) {
		View_PlayAnimation( ANIM_PARA_SHOOT1 );
	} else {
		View_PlayAnimation( ANIM_PARA_SHOOT2 );
	}
#endif
}

void WeaponPARA_Reload( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_PARA_RELOAD );
	
	//sound( self, CHAN_WEAPON, "weapons/m249_chain.wav", 1, ATTN_IDLE ); // TODO: Move to the client...
	Sound_Delayed( "weapons/m249_coverup.wav", 1.0, 0.75 );
	Sound_Delayed( "weapons/m249_boxout.wav", 1.0, 1.6 );
	Sound_Delayed( "weapons/m249_boxin.wav", 1.0, 2.5 );
	Sound_Delayed( "weapons/m249_chain.wav", 1.0, 3.0 );
	Sound_Delayed( "weapons/m249_coverdown.wav", 1.0, 3.9 );
#endif
}
