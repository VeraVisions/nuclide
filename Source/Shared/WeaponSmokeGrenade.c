/*
OpenCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

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

.int iMag_SMOKEGRENADE;

// Weapon Info
weaponinfo_t wptSMOKEGRENADE = { 
	WEAPON_SMOKEGRENADE, // Identifier
	SLOT_GRENADE,	// Slot
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
	1.0, 			// Attack-Delay
	1.0, 			// Reload-Delay
	iAmmo_9MM, 		// Caliber Pointer
	iMag_SMOKEGRENADE, 	// Clip Pointer
	1,				// Accuracy Divisor
	1.0,			// Accuracy Offset
	1.0,			// Max Inaccuracy
	7,				// Minimum Crosshair Distance
	3,				// Crosshair Movement Delta
	1.0,			// Armor penetration ratio
	ATYPE_GRENADE	// Animation Type
};

// Anim Table
enum {
	ANIM_SMOKEGRENADE_IDLE1,
	ANIM_SMOKEGRENADE_PULLPIN,
	ANIM_SMOKEGRENADE_THROW,
	ANIM_SMOKEGRENADE_DRAW,
};

void WeaponSMOKEGRENADE_Draw( void ) {
#ifdef SSQC
	BaseMelee_Draw();
#else
	View_PlayAnimation( ANIM_SMOKEGRENADE_DRAW );
#endif
}

void WeaponSMOKEGRENADE_PrimaryFire( void ) {
#ifdef SSQC
	Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
	Animation_ShootWeapon();
	self.fAttackFinished = time + wptSMOKEGRENADE.fAttackFinished;
#else
	View_PlayAnimation( ANIM_SMOKEGRENADE_PULLPIN );
#endif
}
