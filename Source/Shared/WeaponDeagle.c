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
