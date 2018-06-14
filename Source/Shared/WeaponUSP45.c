/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
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
