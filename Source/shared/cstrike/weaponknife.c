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
