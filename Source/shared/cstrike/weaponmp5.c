/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

.int iMag_MP5;

// Weapon Info
weaponinfo_t wptMP5 = { 
	WEAPON_MP5, 		// Identifier
	SLOT_PRIMARY,		// Slot
	1500, 				// Price
	CALIBER_9MM, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	26, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.84, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.08, 				// Attack-Delay
	2.6, 				// Reload-Delay
	iAmmo_9MM, 			// Caliber Pointer
	iMag_MP5, 			// Clip Pointer
	220,				// Accuracy Divisor
	0.45,				// Accuracy Offset
	0.75,				// Max Inaccuracy
	6,					// Minimum Crosshair Distance
	2,					// Crosshair Movement Delta
	1.0,				// Armor penetration ratio
	ATYPE_MP5,			// Animation Type
	SHELL_PISTOL
};

// Anim Table
enum {
	ANIM_MP5_IDLE,
	ANIM_MP5_RELOAD,
	ANIM_MP5_DRAW,
	ANIM_MP5_SHOOT1,
	ANIM_MP5_SHOOT2,
	ANIM_MP5_SHOOT3
};

void WeaponMP5_Draw( void ) {
#ifdef SSQC
	BaseGun_Draw();
#else
	View_PlayAnimation( ANIM_MP5_DRAW );
#endif
}

void WeaponMP5_PrimaryFire( void ) {
#ifdef SSQC
	if ( BaseGun_PrimaryFire() == TRUE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/mp5-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/mp5-2.wav", 1, ATTN_NORM );
		}
	}
#else
	int iRand = (int)floor( random( 1, 4 ) );
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_MP5_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_MP5_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_MP5_SHOOT3 );
	}
	BaseGun_ShotMultiplierHandle( 1 );
#endif
}

void WeaponMP5_Reload( void ) {
#ifdef SSQC
	if ( BaseGun_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_MP5_RELOAD );
#endif
}
