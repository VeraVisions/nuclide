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

.int iMag_USP45;

#ifdef SSQC
.int iMode_USP45;
#else
int iWeaponMode_USP45;
#endif

// Weapon Info
weaponinfo_t wptUSP45 = { 
	WEAPON_USP45, 		// Identifier
	SLOT_SECONDARY,		// Slot
	500, 				// Price
	CALIBER_45ACP, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	12, 				// Clip/MagSize
	34, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.79, 				// Range Modifier
	TYPE_SEMI,			// Firing Type
	0.15, 				// Attack-Delay
	2.5, 				// Reload-Delay
	iAmmo_45ACP, 		// Caliber Pointer
	iMag_USP45, 		// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4,				// Max Inaccuracy
	8,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.0,				// Armor penetration ratio
	ATYPE_ONEHAND,		// Animation Type
	SHELL_PISTOL
};

enum {
	ANIM_USP45_IDLE,
	ANIM_USP45_SILENCER_SHOOT1,
	ANIM_USP45_SILENCER_SHOOT2,
	ANIM_USP45_SILENCER_SHOOT3,
	ANIM_USP45_SILENCER_SHOOTLAST,
	ANIM_USP45_SILENCER_RELOAD,
	ANIM_USP45_SILENCER_DRAW,
	ANIM_USP45_SILENCER_ADD,
	ANIM_USP45_IDLE2,
	ANIM_USP45_SHOOT1,
	ANIM_USP45_SHOOT2,
	ANIM_USP45_SHOOT3,
	ANIM_USP45_SHOOTLAST,
	ANIM_USP45_RELOAD,
	ANIM_USP45_DRAW,
	ANIM_USP45_SILENCER_REMOVE
};

void WeaponUSP45_Draw( void ) {
#ifdef SSQC
	BaseGun_Draw();
#else
	if ( iWeaponMode_USP45 == TRUE ) {
		View_PlayAnimation( ANIM_USP45_SILENCER_DRAW );
	} else {
		View_PlayAnimation( ANIM_USP45_DRAW );
	}
#endif
}

void WeaponUSP45_PrimaryFire( void ) {
#ifdef SSQC
	if ( BaseGun_PrimaryFire() == TRUE ) {
		if ( self.iMode_USP45 == TRUE ) {
			if ( random() <= 0.5 ) {
				sound( self, CHAN_WEAPON, "weapons/usp1.wav", 1, ATTN_NORM );
			} else {
				sound( self, CHAN_WEAPON, "weapons/usp2.wav", 1, ATTN_NORM );
			}
		} else {
			sound( self, CHAN_WEAPON, "weapons/usp_unsil-1.wav", 1, ATTN_NORM );
		}
	}
#else
	if ( getstatf( STAT_CURRENT_MAG ) == 0 ) {
		if ( iWeaponMode_USP45 == TRUE ) {
			View_PlayAnimation( ANIM_USP45_SILENCER_SHOOTLAST );
		} else {
			View_PlayAnimation( ANIM_USP45_SHOOTLAST );
		}
	} else {
		int iRand = (int)floor( random( 1, 4 ) );
		
		if ( iRand == 1 ) {
			if ( iWeaponMode_USP45 == TRUE ) {
				View_PlayAnimation( ANIM_USP45_SILENCER_SHOOT1 );
			} else {
				View_PlayAnimation( ANIM_USP45_SHOOT1 );
			}
		} else if ( iRand == 2 ) {
			if ( iWeaponMode_USP45 == TRUE ) {
				View_PlayAnimation( ANIM_USP45_SILENCER_SHOOT2 );
			} else {
				View_PlayAnimation( ANIM_USP45_SHOOT2 );
			}
		} else {
			if ( iWeaponMode_USP45 == TRUE ) {
				View_PlayAnimation( ANIM_USP45_SILENCER_SHOOT3 );
			} else {
				View_PlayAnimation( ANIM_USP45_SHOOT3 );
			}
		}
	}
	
	BaseGun_ShotMultiplierHandle( 1 );
#endif
}

void WeaponUSP45_Secondary( void ) {
#ifdef SSQC
	// Just switch the modes quickly
	self.iMode_USP45 = 1 - self.iMode_USP45;
	self.fAttackFinished = time + 3.0;
	
	// Tell the client that we switched modes, too
	Client_SendEvent( self, EV_WEAPON_SECONDARYATTACK );
#else 
	iWeaponMode_USP45 = 1 - iWeaponMode_USP45;
	
	if ( iWeaponMode_USP45 == TRUE ) {
		View_PlayAnimation( ANIM_USP45_SILENCER_ADD );
	} else {
		View_PlayAnimation( ANIM_USP45_SILENCER_REMOVE );
	}
#endif
}

void WeaponUSP45_Reload( void ) {
#ifdef SSQC
	if ( BaseGun_Reload() == TRUE ) {

	}
#else
	if ( iWeaponMode_USP45 == TRUE ) {
		View_PlayAnimation( ANIM_USP45_SILENCER_RELOAD );
	} else {
		View_PlayAnimation( ANIM_USP45_RELOAD );
	}
#endif
}
