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

// Weapon Info
weaponinfo_t wptKNIFE = { 
	WEAPON_KNIFE, 	// Identifier
	SLOT_MELEE,		// Slot
	0, 				// Price
	0, 				// Caliber ID
	1.0, 			// Max Player Speed
	1, 				// Bullets Per Shot
	1, 				// Clip/MagSize
	50, 			// Damage Per Bullet
	1, 				// Penetration Multiplier
	64, 			// Bullet Range
	0.75, 			// Range Modifier
	TYPE_SEMI,		// Firing Type
	0.7, 			// Attack-Delay
	1.0, 			// Reload-Delay
	iNull, 			// Caliber Pointer
	iNull, 			// Clip Pointer
	1,				// Accuracy Divisor
	1.0,			// Accuracy Offset
	1.0,			// Max Inaccuracy
	7,				// Minimum Crosshair Distance
	3,				// Crosshair Movement Delta
	1.7,			// Armor penetration ratio
	ATYPE_KNIFE,	// Animation Type
	FALSE
};

// Anim Table
enum {
	ANIM_KNIFE_IDLE1,
	ANIM_KNIFE_SLASH1,
	ANIM_KNIFE_SLASH2,
	ANIM_KNIFE_DRAW,
	ANIM_KNIFE_STAB,
	ANIM_KNIFE_STAB_MISS,
	ANIM_KNIFE_MIDSLASH1,
	ANIM_KNIFE_MIDSLASH2
};

void WeaponKNIFE_Draw( void ) {
#ifdef SSQC
	BaseMelee_Draw();
#else
	View_PlayAnimation( ANIM_KNIFE_DRAW );
#endif
}

void WeaponKNIFE_PrimaryFire( void ) {
#ifdef SSQC

	Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
	
	if ( BaseMelee_Attack() == FALSE ) {
		if ( random() <= 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/knife_slash1.wav", 1, ATTN_IDLE );
		} else {
			sound( self, CHAN_WEAPON, "weapons/knife_slash2.wav", 1, ATTN_IDLE );
		} 
	}
	
	Animation_ShootWeapon( self );
	self.fAttackFinished = time + wptKNIFE.fAttackFinished;
#else
	if ( random() <= 0.5 ) {
		View_PlayAnimation( ANIM_KNIFE_SLASH1 );
	} else {
		View_PlayAnimation( ANIM_KNIFE_SLASH2 );
	}
#endif
}

void WeaponKNIFE_Secondary( void ) {
#ifdef SSQC
	BaseMelee_Attack();
	Client_SendEvent( self, EV_WEAPON_SECONDARYATTACK );
	self.fAttackFinished = time + wptKNIFE.fAttackFinished;
#else
	View_PlayAnimation( ANIM_KNIFE_STAB );
#endif
}
