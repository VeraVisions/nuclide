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

.int iMag_P90;

// Weapon Info
weaponinfo_t wptP90 = { 
	WEAPON_P90, 		// Identifier
	SLOT_PRIMARY,		// Slot
	2350, 				// Price
	CALIBER_57MM, 		// Caliber ID
	0.98, 				// Max Player Speed
	1, 					// Bullets Per Shot
	50, 				// Clip/MagSize
	26, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.84, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.07, 				// Attack-Delay
	3.3, 				// Reload-Delay
	iAmmo_57MM, 		// Caliber Pointer
	iMag_P90, 			// Clip Pointer
	175,				// Accuracy Divisor
	0.45,				// Accuracy Offset
	1.0,				// Max Inaccuracy
	7,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.5,				// Armor penetration ratio
	ATYPE_MP5,			// Animation Type
	SHELL_RIFLE
};

// Anim Table
enum {
	ANIM_P90_IDLE,
	ANIM_P90_RELOAD,
	ANIM_P90_DRAW,
	ANIM_P90_SHOOT1,
	ANIM_P90_SHOOT2,
	ANIM_P90_SHOOT3
};

void WeaponP90_Draw( void ) {
#ifdef SSQC
	BaseGun_Draw();
#else
	View_PlayAnimation( ANIM_P90_DRAW );
#endif
}

void WeaponP90_PrimaryFire( void ) {
#ifdef SSQC
	if ( BaseGun_PrimaryFire() == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/p90-1.wav", 1, ATTN_NORM );
	}
#else
	int iRand = (int)floor( random( 1, 4 ) );
	
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_P90_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_P90_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_P90_SHOOT3 );
	}
	BaseGun_ShotMultiplierHandle( 1 );
#endif
}

void WeaponP90_Reload( void ) {
	#ifdef SSQC
	if ( BaseGun_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_P90_RELOAD );
	#endif
}
