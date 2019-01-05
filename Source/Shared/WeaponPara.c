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

.int iMag_PARA;

// Weapon Info
weaponinfo_t wptPARA = { 
	WEAPON_PARA, 		// Identifier
	SLOT_PRIMARY,		// Slot
	5750, 				// Price
	CALIBER_556MMBOX, 	// Caliber ID
	0.88, 				// Max Player Speed
	1, 					// Bullets Per Shot
	100, 				// Clip/MagSize
	35, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.97, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.1, 				// Attack-Delay
	3.0, 				// Reload-Delay
	iAmmo_556MMBOX, 	// Caliber Pointer
	iMag_PARA, 			// Clip Pointer
	175,				// Accuracy Divisor
	0.4,				// Accuracy Offset
	0.9,				// Max Inaccuracy
	6,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.6,				// Armor penetration ratio
	ATYPE_PARA,			// Animation Type
	SHELL_RIFLEBIG
};

// Anim Table
enum {
	ANIM_PARA_IDLE,
	ANIM_PARA_SHOOT1,
	ANIM_PARA_SHOOT2,
	ANIM_PARA_RELOAD,
	ANIM_PARA_DRAW
};

void WeaponPARA_Draw( void ) {
#ifdef SSQC
	BaseGun_Draw();
#else
	View_PlayAnimation( ANIM_PARA_DRAW );
#endif
}

void WeaponPARA_PrimaryFire( void ) {
#ifdef SSQC
	if ( BaseGun_PrimaryFire() == TRUE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/m249-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/m249-2.wav", 1, ATTN_NORM );
		}
	}
#else
	if ( random() <= 0.5 ) {
		View_PlayAnimation( ANIM_PARA_SHOOT1 );
	} else {
		View_PlayAnimation( ANIM_PARA_SHOOT2 );
	}
	BaseGun_ShotMultiplierHandle( 1 );
#endif
}

void WeaponPARA_Reload( void ) {
#ifdef SSQC
	if ( BaseGun_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_PARA_RELOAD );
#endif
}
