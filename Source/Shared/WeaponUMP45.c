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

.int iMag_UMP45;

// Weapon Info
weaponinfo_t wptUMP45 = { 
	WEAPON_UMP45, 		// Identifier
	SLOT_PRIMARY,		// Slot
	1700, 				// Price
	CALIBER_45ACP, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	25, 				// Clip/MagSize
	30, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.82, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.105, 				// Attack-Delay
	3.5, 				// Reload-Delay
	iAmmo_45ACP, 		// Caliber Pointer
	iMag_UMP45, 		// Clip Pointer
	210,				// Accuracy Divisor
	0.5,				// Accuracy Offset
	1,					// Max Inaccuracy
	6,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.0,				// Armor penetration ratio
	ATYPE_MP5,			// Animation Type
	SHELL_RIFLE
};

// Anim Table
enum {
	ANIM_UMP45_IDLE,
	ANIM_UMP45_RELOAD,
	ANIM_UMP45_DRAW,
	ANIM_UMP45_SHOOT1,
	ANIM_UMP45_SHOOT2,
	ANIM_UMP45_SHOOT3
};

void WeaponUMP45_Draw( void ) {
#ifdef SSQC
	BaseGun_Draw();
	//sound( self, CHAN_WEAPON, "weapons/ump45_boltslap.wav", 1, ATTN_IDLE ); // TODO: Move to the client...?
#else
	View_PlayAnimation( ANIM_UMP45_DRAW );
#endif
}

void WeaponUMP45_PrimaryFire( void ) {
#ifdef SSQC
	if ( BaseGun_PrimaryFire() == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM );
	}
#else
	int iRand = (int)floor( random( 1, 4 ) );
	
	if ( iRand == 1 ) {
		View_PlayAnimation( ANIM_UMP45_SHOOT1 );
	} else if ( iRand == 2 ) {
		View_PlayAnimation( ANIM_UMP45_SHOOT2 );
	} else {
		View_PlayAnimation( ANIM_UMP45_SHOOT3 );
	}
	
	BaseGun_ShotMultiplierHandle( 1 );
#endif
}

void WeaponUMP45_Reload( void ) {
	#ifdef SSQC
	if ( BaseGun_Reload() == TRUE ) {
		// Play Sound
	}
	#else
	View_PlayAnimation( ANIM_UMP45_RELOAD );
	#endif
}
