/*
FreeCS Project
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

.int iMag_XM1014;

#ifdef SSQC
.int iMode_XM1014;
#else
int iWeaponMode_XM1014;
#endif

// Weapon Info
weaponinfo_t wptXM1014 = { 
	WEAPON_XM1014, 		// Identifier
	SLOT_PRIMARY,		// Slot
	3000, 				// Price
	CALIBER_BUCKSHOT, 	// Caliber ID
	0.96, 				// Max Player Speed
	6, 					// Bullets Per Shot
	7, 					// Clip/MagSize
	22, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	3000, 				// Bullet Range
	0.7, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.25, 				// Attack-Delay
	3.0, 				// Reload-Delay
	iAmmo_BUCKSHOT, 	// Caliber Pointer
	iMag_XM1014, 		// Clip Pointer
	200,				// Accuracy Divisor
	0.35,				// Accuracy Offset
	1.25,				// Max Inaccuracy
	9,					// Minimum Crosshair Distance
	4,					// Crosshair Movement Delta
	1.0,				// Armor penetration ratio
	ATYPE_SHOTGUN		// Animation Type
};

// Anim Table
enum {
	ANIM_XM1014_IDLE,
	ANIM_XM1014_SHOOT1,
	ANIM_XM1014_SHOOT2,
	ANIM_XM1014_INSERT,
	ANIM_XM1014_RELOAD_END,
	ANIM_XM1014_RELOAD_START,
	ANIM_XM1014_DRAW
};

void WeaponXM1014_Draw( void ) {
	#ifdef SSQC
	BaseGun_Draw();
	#else
	View_PlayAnimation( ANIM_XM1014_DRAW );
	#endif
}

void WeaponXM1014_ReloadNULL( void ) { }

void WeaponXM1014_PrimaryFire( void ) {
#ifdef SSQC
	if ( self.iMode_XM1014 == TRUE ) {
		self.iMode_XM1014 = 0;
		Client_SendEvent( self, EV_WEAPON_RELOAD );
		self.think = WeaponXM1014_ReloadNULL;
		self.fAttackFinished = time + 0.5;
		return;
	}
	
	if ( BaseGun_PrimaryFire() == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/xm1014-1.wav", 1, ATTN_NORM );
	}
#else
	if ( random() <= 0.5 ) {
		View_PlayAnimation( ANIM_XM1014_SHOOT1 );
	} else {
		View_PlayAnimation( ANIM_XM1014_SHOOT2 );
	}
	
	BaseGun_ShotMultiplierHandle( 1 );
#endif
}

void WeaponXM1014_Reload( void);
void WeaponXM1014_Secondary( void ) {
#ifdef SSQC
	// If it's full or no ammo is left...
	if ( (self.(wptXM1014.iMagfld) == wptXM1014.iMagSize) || ( self.(wptXM1014.iCaliberfld) <= 0 ) ) {
		self.iMode_XM1014 = 0;
		Client_SendEvent( self, EV_WEAPON_RELOAD );
		self.think = WeaponXM1014_ReloadNULL;
		self.fAttackFinished = time + 0.5;
		return;
	}
	
	self.(wptXM1014.iMagfld) += 1;
	self.(wptXM1014.iCaliberfld) -= 1;
	
	Client_SendEvent( self, EV_WEAPON_SECONDARYATTACK );
	
	self.think = WeaponXM1014_Secondary;
	self.nextthink = time + 0.5;
#else
	View_PlayAnimation( ANIM_XM1014_INSERT );
#endif
}

void WeaponXM1014_Reload( void ) {
#ifdef SSQC
	// Can we reload the gun even if we wanted to?
	if ( ( self.(wptXM1014.iMagfld) != wptXM1014.iMagSize ) && ( self.(wptXM1014.iCaliberfld) > 0 ) ) {
		self.iMode_XM1014 = 1 - self.iMode_XM1014;
			
		if ( self.iMode_XM1014 == TRUE ) {
			self.think = WeaponXM1014_Secondary;
			self.nextthink = time + 0.8;
		} else {
			self.think = WeaponXM1014_ReloadNULL;
		}
			
		Client_SendEvent( self, EV_WEAPON_RELOAD );
		self.fAttackFinished = time + 0.5;
	}
#else
	iWeaponMode_XM1014 = 1 - iWeaponMode_XM1014;
	
	if ( iWeaponMode_XM1014 == TRUE ) {
		View_PlayAnimation( ANIM_XM1014_RELOAD_START );
	} else {
		View_PlayAnimation( ANIM_XM1014_RELOAD_END );
	}
#endif
}
