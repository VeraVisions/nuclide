/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
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
	0.15, 			// Attack-Delay
	1.0, 			// Reload-Delay
	iAmmo_9MM, 		// Caliber Pointer
	iMag_GLOCK18, 	// Clip Pointer
	1,				// Accuracy Divisor
	1.0,			// Accuracy Offset
	1.0,			// Max Inaccuracy
	7,				// Minimum Crosshair Distance
	3,				// Crosshair Movement Delta
	1.7				// Armor penetration ratio
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
	Client_SendEvent( self, EV_WEAPON_DRAW );
	self.iCurrentMag = 0;
	self.iCurrentCaliber = 0;
#else
	View_PlayAnimation( ANIM_KNIFE_DRAW );
#endif
}

void WeaponKNIFE_PrimaryFire( void ) {
#ifdef SSQC
	Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
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
	Client_SendEvent( self, EV_WEAPON_SECONDARYATTACK );
	self.fAttackFinished = time + wptKNIFE.fAttackFinished;
#else
	View_PlayAnimation( ANIM_KNIFE_STAB );
#endif
}
