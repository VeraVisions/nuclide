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
	{ WeaponKNIFE_Draw, WeaponKNIFE_PrimaryFire, WeaponKNIFE_Secondary, Temp_Nothing },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, WeaponUSP45_Secondary, WeaponUSP45_Reload },
	{ WeaponGLOCK18_Draw, WeaponGLOCK18_PrimaryFire, WeaponGLOCK18_Secondary, WeaponGLOCK18_Reload },
	{ WeaponDEAGLE_Draw, WeaponDEAGLE_PrimaryFire, Temp_Nothing, WeaponDEAGLE_Reload },
	{ WeaponP228_Draw, WeaponP228_PrimaryFire, Temp_Nothing, WeaponP228_Reload },
	{ WeaponELITES_Draw, WeaponELITES_PrimaryFire, Temp_Nothing, WeaponELITES_Reload },
	{ WeaponFIVESEVEN_Draw, WeaponFIVESEVEN_PrimaryFire, Temp_Nothing, WeaponFIVESEVEN_Reload },
	#ifdef SSQC
	{ WeaponM3_Draw, WeaponM3_PrimaryFire,  Temp_Nothing, WeaponM3_Reload },
	{ WeaponXM1014_Draw, WeaponXM1014_PrimaryFire, Temp_Nothing, WeaponXM1014_Reload },
	#else 
	{ WeaponM3_Draw, WeaponM3_PrimaryFire,  WeaponM3_Secondary, WeaponM3_Reload },
	{ WeaponXM1014_Draw, WeaponXM1014_PrimaryFire, WeaponXM1014_Secondary, WeaponXM1014_Reload },
	#endif
	{ WeaponMP5_Draw, WeaponMP5_PrimaryFire, Temp_Nothing, WeaponMP5_Reload },
	{ WeaponP90_Draw, WeaponP90_PrimaryFire, Temp_Nothing, WeaponP90_Reload },
	{ WeaponUMP45_Draw, WeaponUMP45_PrimaryFire, Temp_Nothing, WeaponUMP45_Reload },
	{ WeaponMAC10_Draw, WeaponMAC10_PrimaryFire, Temp_Nothing, WeaponMAC10_Reload },
	{ WeaponTMP_Draw, WeaponTMP_PrimaryFire, Temp_Nothing, WeaponTMP_Reload },
	{ WeaponAK47_Draw, WeaponAK47_PrimaryFire, Temp_Nothing, WeaponAK47_Reload },
	{ WeaponSG552_Draw, WeaponSG552_PrimaryFire, Temp_Nothing, WeaponSG552_Reload },
	{ WeaponM4A1_Draw, WeaponM4A1_PrimaryFire, WeaponM4A1_Secondary, WeaponM4A1_Reload },
	{ WeaponAUG_Draw, WeaponAUG_PrimaryFire, Temp_Nothing, WeaponAUG_Reload },
	{ WeaponSCOUT_Draw, WeaponSCOUT_PrimaryFire, Temp_Nothing, WeaponSCOUT_Reload },
	{ WeaponAWP_Draw, WeaponAWP_PrimaryFire, Temp_Nothing, WeaponAWP_Reload },
	{ WeaponG3SG1_Draw, WeaponG3SG1_PrimaryFire, Temp_Nothing, WeaponG3SG1_Reload },
	{ WeaponSG550_Draw, WeaponSG550_PrimaryFire, Temp_Nothing, WeaponSG550_Reload },
	{ WeaponPARA_Draw, WeaponPARA_PrimaryFire, Temp_Nothing, WeaponPARA_Reload },
	{ WeaponC4BOMB_Draw, WeaponC4BOMB_PrimaryFire, Temp_Nothing, Temp_Nothing }
};

void Weapon_Draw( float fWeapon ) {
	if ( !fWeapon ) {
		return;
	}
	
	wpnFuncTable[ fWeapon ].vDraw();
	
	#ifdef SSQC
	self.maxspeed = Player_GetMaxSpeed( fWeapon );
	self.fAttackFinished = time + 1.0;
	#endif
}

void Weapon_PrimaryAttack( float fWeapon ) {
	#ifdef SSQC
	if ( self.fAttackFinished > time ) {
		return;
	}
	#endif
	
	wpnFuncTable[ fWeapon ].vPrimary();
}

void Weapon_SecondaryAttack( float fWeapon ) {
	#ifdef SSQC
	if ( self.fAttackFinished > time ) {
		return;
	}
	#endif
	
	wpnFuncTable[ fWeapon ].vSecondary();
}

void Weapon_Reload( float fWeapon ) {
	#ifdef SSQC
	if ( self.fAttackFinished > time ) {
		return;
	}
	#endif
	
	wpnFuncTable[ fWeapon ].vReload();
}

#ifdef SSQC

void Weapon_Switch( int iSlot ) {
	if ( self.fAttackFinished > time ) {
		return;
	}
	
	float fWeapon;
	
	if ( iSlot == SLOT_MELEE ) {
		fWeapon = self.iSlotMelee;
	} else if ( iSlot == SLOT_PRIMARY ) {
		fWeapon = self.iSlotPrimary;
	} else if ( iSlot == SLOT_SECONDARY ) {
		fWeapon = self.iSlotSecondary;
	} else if ( iSlot == SLOT_GRENADE ) {
		fWeapon = self.iSlotGrenade;
	}
	
	if ( !fWeapon || self.weapon == fWeapon ) {
		return;
	}
	
	self.weapon = fWeapon;
	Weapon_Draw( fWeapon );
}

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

void Weapon_SwitchBest( void ) {
	if ( self.iSlotSecondary ) {
		Weapon_Switch( SLOT_SECONDARY );
	} else if ( self.iSlotPrimary ) {
		Weapon_Switch( SLOT_PRIMARY );
	} else {
		Weapon_Switch( SLOT_MELEE );
	}
}

void CSEv_GamePlayerBuy_f( float fWeapon ) {
	if ( Rules_BuyingPossible() == FALSE ) {
		return;
	}
	
	Weapon_AddItem( fWeapon );

	self.fMoney -= wptTable[ fWeapon ].iPrice;
	self.fAttackFinished = time + 1.0;
}
#endif
