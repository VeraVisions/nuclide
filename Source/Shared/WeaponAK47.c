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

.int iMag_AK47;

// Weapon Info
weaponinfo_t wptAK47 = { 
	WEAPON_AK47, 		// Identifier
	SLOT_PRIMARY,		// Slot
	2500, 				// Price
	CALIBER_762MM, 		// Caliber ID
	0.88, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	36, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.98, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.0955, 			// Attack-Delay
	2.4, 				// Reload-Delay
	iAmmo_762MM, 		// Caliber Pointer
	iMag_AK47, 			// Clip Pointer
	200,				// Accuracy Divisor
	0.35,				// Accuracy Offset
	1.25,				// Max Inaccuracy
	4,					// Minimum Crosshair Distance
	4,					// Crosshair Movement Delta
	1.55,				// Armor penetration ratio
	ATYPE_AK47,			// Animation Type
	SHELL_RIFLE
};

// Anim Table
enum {
	ANIM_AK47_IDLE,
	ANIM_AK47_RELOAD,
	ANIM_AK47_DRAW,
	ANIM_AK47_SHOOT1,
	ANIM_AK47_SHOOT2,
	ANIM_AK47_SHOOT3
};

void WeaponAK47_Draw( void ) {
	#ifdef SSQC
	BaseGun_Draw();
	#else
	View_PlayAnimation( ANIM_AK47_DRAW );
	#endif
}

void WeaponAK47_PrimaryFire( void ) {
	#ifdef SSQC
	if ( BaseGun_PrimaryFire() == TRUE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/ak47-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/ak47-2.wav", 1, ATTN_NORM );
		}
	}
	#else
	int iRand = (int)floor( random( 1, 4 ) );
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_AK47_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_AK47_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_AK47_SHOOT3 );
	}
	
	BaseGun_ShotMultiplierHandle( 1 );
	#endif
}

void WeaponAK47_Reload( void ) {
	#ifdef SSQC
	if ( BaseGun_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_AK47_RELOAD );
	#endif
}
