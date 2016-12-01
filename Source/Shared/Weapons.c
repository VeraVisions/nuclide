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

void Temp_Nothing( void ) { }

weaponfunc_t wpnFuncTable[ CS_WEAPON_COUNT ] = {
	{ Temp_Nothing, Temp_Nothing, Temp_Nothing, Temp_Nothing },
	{ Temp_Nothing, Temp_Nothing, Temp_Nothing, Temp_Nothing },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, WeaponUSP45_Secondary, WeaponUSP45_Reload },
	{ WeaponGLOCK18_Draw, WeaponGLOCK18_PrimaryFire, WeaponGLOCK18_Secondary, WeaponGLOCK18_Reload },
	{ WeaponDEAGLE_Draw, WeaponDEAGLE_PrimaryFire, Temp_Nothing, WeaponDEAGLE_Reload },
	{ WeaponP228_Draw, WeaponP228_PrimaryFire, Temp_Nothing, WeaponP228_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponFIVESEVEN_Draw, WeaponFIVESEVEN_PrimaryFire, Temp_Nothing, WeaponFIVESEVEN_Reload },
	{ WeaponM3_Draw, WeaponM3_PrimaryFire, Temp_Nothing, WeaponM3_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponAK47_Draw, WeaponAK47_PrimaryFire, Temp_Nothing, WeaponAK47_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, Temp_Nothing, WeaponUSP45_Reload }
};

void Weapon_Draw( float fWeapon ) {
	wpnFuncTable[ fWeapon ].vDraw();
}

void Weapon_PrimaryAttack( float fWeapon ) {
	#ifdef QWSSQC
	if ( self.fAttackFinished > time ) {
		return;
	}
	#endif
	
	wpnFuncTable[ fWeapon ].vPrimary();
}

void Weapon_SecondaryAttack( float fWeapon ) {
	#ifdef QWSSQC
	if ( self.fAttackFinished > time ) {
		return;
	}
	#endif
	
	wpnFuncTable[ fWeapon ].vSecondary();
}

void Weapon_Reload( float fWeapon ) {
	#ifdef QWSSQC
	if ( self.fAttackFinished > time ) {
		return;
	}
	#endif
	
	wpnFuncTable[ fWeapon ].vReload();
}

#ifdef QWSSQC

void Weapon_UpdateCurrents( void ) {
	self.iCurrentClip = self.(wptTable[ self.weapon ].iClipfld);
	self.iCurrentCaliber = self.(wptTable[ self.weapon ].iCaliberfld);
}

// We get a weapon for the first time essentially
void Weapon_AddItem( float fWeapon ) {
	
	// Add the gun to the appropriate slot
	if( wptTable[ fWeapon ].iSlot == SLOT_MELEE ) {
		self.iSlotMelee = fWeapon;
	} else if ( wptTable[ fWeapon ].iSlot == SLOT_SECONDARY ) {
		self.iSlotSecondary = fWeapon;
	} else if( wptTable[ fWeapon ].iSlot == SLOT_PRIMARY ) {
		self.iSlotPrimary = fWeapon;
	} else if ( wptTable[ fWeapon ].iSlot == SLOT_GRENADE ) {
		self.iSlotGrenade = fWeapon;
	}
	
	// Switch to it
	self.weapon = fWeapon;
	
	// Make sure we've got at least one full clip
	self.(wptTable[ self.weapon ].iClipfld) = wptTable[ fWeapon ].iClipSize;
	
	Weapon_UpdateCurrents();
	
	Weapon_Draw( fWeapon );
}

void Weapon_GiveAmmo( float fWeapon, float fAmount ) {
	self.(wptTable[ self.weapon ].iCaliberfld ) += fAmount;
	Weapon_UpdateCurrents();
}

void CSEv_GamePlayerBuy_f( float fWeapon ) {
	Weapon_AddItem( fWeapon );
	self.fMoney -= wptTable[ fWeapon ].iPrice;
	self.fAttackFinished = time + 1.0;
}

#endif
