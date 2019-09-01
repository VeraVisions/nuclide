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

.int iMag_AWP;

// Weapon Info
weaponinfo_t wptAWP = { 
	WEAPON_AWP, 		// Identifier
	SLOT_PRIMARY,		// Slot
	4750, 				// Price
	CALIBER_338MAG, 	// Caliber ID
	0.84, 				// Max Player Speed
	1, 					// Bullets Per Shot
	10, 				// Clip/MagSize
	115, 				// Damage Per Bullet
	3, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.99, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	1.2, 				// Attack-Delay
	2.9, 				// Reload-Delay
	iAmmo_338MAG, 		// Caliber Pointer
	iMag_AWP, 			// Clip Pointer
	-1,					// Accuracy Divisor
	0,					// Accuracy Offset
	0,					// Max Inaccuracy	
	8,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.95,				// Armor penetration ratio
	ATYPE_CARBINE,		// Animation Type
	SHELL_RIFLEBIG
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
	#ifdef SSQC
	BaseGun_Draw();
	#else
	View_PlayAnimation( ANIM_AWP_DRAW );
	#endif
}

void WeaponAWP_PrimaryFire( void ) {
	#ifdef SSQC
	if ( BaseGun_PrimaryFire() == TRUE ) {
		// Play Sound
		sound( self, CHAN_WEAPON, "weapons/awp1.wav", 1, ATTN_NORM );
	}
	#else
	int iRand = (int)floor( random( 1, 4 ) );
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_AWP_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_AWP_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_AWP_SHOOT3 );
	}
	
	BaseGun_ShotMultiplierHandle( 1 );
	#endif
}

void WeaponAWP_SecondaryFire( void ) {
#ifdef SSQC
	if ( self.viewzoom == 1.0 ) {
		self.viewzoom = 0.45;
	} else if ( self.viewzoom == 0.45 ) {
		self.viewzoom = 0.1;
	} else {
		self.viewzoom = 1.0;
	}
	
	self.fAttackFinished = time + 0.5;
#endif
}

void WeaponAWP_Reload( void ) {
	#ifdef SSQC
	if ( BaseGun_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_AWP_RELOAD );
	#endif
}
