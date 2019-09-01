/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

.int iMag_DEAGLE;

// Weapon Info
weaponinfo_t wptDEAGLE = { 
	WEAPON_DEAGLE, 		// Identifier
	SLOT_SECONDARY,		// Slot
	650, 				// Price
	CALIBER_50AE, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	7, 					// Clip/MagSize
	54, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.81, 				// Range Modifier
	TYPE_SEMI,			// Firing Type
	0.15, 				// Attack-Delay
	2.1, 				// Reload-Delay
	iAmmo_50AE, 		// Caliber Pointer
	iMag_DEAGLE, 		// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4,				// Max Inaccuracy
	8,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.5,				// Armor penetration ratio
	ATYPE_ONEHAND,		// Animation Type
	SHELL_PISTOL
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
	#ifdef SSQC
	BaseGun_Draw();
	#else
	View_PlayAnimation( ANIM_DEAGLE_DRAW );
	#endif
}

void WeaponDEAGLE_PrimaryFire( void ) {
	#ifdef SSQC
	if ( BaseGun_PrimaryFire() == TRUE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/deagle-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/deagle-2.wav", 1, ATTN_NORM );
		}
	}
	#else
	if ( getstatf( STAT_CURRENT_MAG ) == 0 ) {
		View_PlayAnimation( ANIM_DEAGLE_SHOOT_EMPTY );
	} else {
		if ( random() <= 0.5 ) {
			View_PlayAnimation( ANIM_DEAGLE_SHOOT1 );
		} else {
			View_PlayAnimation( ANIM_DEAGLE_SHOOT2 );
		}
	}
	
	BaseGun_ShotMultiplierHandle( 1 );
	#endif
}

void WeaponDEAGLE_Reload( void ) {
	#ifdef SSQC
	if ( BaseGun_Reload() == TRUE ) {

	}
	#else
	View_PlayAnimation( ANIM_DEAGLE_RELOAD );
	#endif
}
