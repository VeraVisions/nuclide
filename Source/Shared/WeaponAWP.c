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
