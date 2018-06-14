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

.int iMag_MAC10;

// Weapon Info
weaponinfo_t wptMAC10 = { 
	WEAPON_MAC10, 		// Identifier
	SLOT_PRIMARY,		// Slot
	1400, 				// Price
	CALIBER_45ACP, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	29, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.82, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.075, 				// Attack-Delay
	3.2, 				// Reload-Delay
	iAmmo_45ACP, 		// Caliber Pointer
	iMag_MAC10, 		// Clip Pointer
	200,				// Accuracy Divisor
	0.6,				// Accuracy Offset
	1.65,				// Max Inaccuracy
	9,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	0.95,				// Armor penetration ratio
	ATYPE_MP5,			// Animation Type
	SHELL_PISTOL
};

// Anim Table
enum {
	ANIM_MAC10_IDLE,
	ANIM_MAC10_RELOAD,
	ANIM_MAC10_DRAW,
	ANIM_MAC10_SHOOT1,
	ANIM_MAC10_SHOOT2,
	ANIM_MAC10_SHOOT3
};

void WeaponMAC10_Draw( void ) {
#ifdef SSQC
	BaseGun_Draw();
#else
	View_PlayAnimation( ANIM_MAC10_DRAW );
#endif
}

void WeaponMAC10_PrimaryFire( void ) {
#ifdef SSQC
	if ( BaseGun_PrimaryFire() == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/mac10-1.wav", 1, ATTN_NORM );
	}
#else
	int iRand = (int)floor( random( 1, 4 ) );
	
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_MAC10_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_MAC10_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_MAC10_SHOOT3 );
	}
	BaseGun_ShotMultiplierHandle( 1 );
#endif
}

void WeaponMAC10_Reload( void ) {
#ifdef SSQC
	if ( BaseGun_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_MAC10_RELOAD );
#endif
}
