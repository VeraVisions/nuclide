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
