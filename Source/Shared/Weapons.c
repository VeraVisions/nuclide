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
	{ WeaponSG552_Draw, WeaponSG552_PrimaryFire, WeaponSG552_SecondaryFire, WeaponSG552_Reload },
	{ WeaponM4A1_Draw, WeaponM4A1_PrimaryFire, WeaponM4A1_Secondary, WeaponM4A1_Reload },
	{ WeaponAUG_Draw, WeaponAUG_PrimaryFire, WeaponAUG_SecondaryFire, WeaponAUG_Reload },
	{ WeaponSCOUT_Draw, WeaponSCOUT_PrimaryFire, WeaponSCOUT_SecondaryFire, WeaponSCOUT_Reload },
	{ WeaponAWP_Draw, WeaponAWP_PrimaryFire, WeaponAWP_SecondaryFire, WeaponAWP_Reload },
	{ WeaponG3SG1_Draw, WeaponG3SG1_PrimaryFire, WeaponG3SG1_SecondaryFire, WeaponG3SG1_Reload },
	{ WeaponSG550_Draw, WeaponSG550_PrimaryFire, WeaponSG550_SecondaryFire, WeaponSG550_Reload },
	{ WeaponPARA_Draw, WeaponPARA_PrimaryFire, Temp_Nothing, WeaponPARA_Reload },
	{ WeaponC4BOMB_Draw, WeaponC4BOMB_PrimaryFire, Temp_Nothing, Temp_Nothing }
};

void Weapon_Draw( float fWeapon ) {
	if ( !fWeapon ) {
		return;
	}
	
	wpnFuncTable[ fWeapon ].vDraw();
	
	#ifdef SSQC
	// In case reloading logic is still going on
	self.think = Empty;
	
	self.viewzoom = 1.0;
	
	self.maxspeed = Player_GetMaxSpeed( fWeapon );
	self.fAttackFinished = time + 1.0;
	#endif
}

void Weapon_PrimaryAttack( float fWeapon ) {
	#ifdef SSQC
	if ( self.fAttackFinished > time ) {
		return;
	}
	if ( !( self.flags & FL_SEMI_TOGGLED ) )
		return;
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
void Weapon_Release( void ) {
	self.flags = self.flags | FL_SEMI_TOGGLED;
}

void Weapon_Switch( int iSlot ) {
	float fWeapon;
	
	if ( iSlot == SLOT_MELEE ) {
		fWeapon = self.fSlotMelee;
	} else if ( iSlot == SLOT_PRIMARY ) {
		fWeapon = self.fSlotPrimary;
	} else if ( iSlot == SLOT_SECONDARY ) {
		fWeapon = self.fSlotSecondary;
	} else if ( iSlot == SLOT_GRENADE ) {
		fWeapon = self.fSlotGrenade;
	}
	
	if ( !fWeapon || self.weapon == fWeapon ) {
		return;
	}
	
	self.weapon = fWeapon;
	Weapon_Draw( fWeapon );
}

void Weapon_UpdateCurrents( void ) {
	self.iCurrentMag = self.(wptTable[ self.weapon ].iMagfld);
	self.iCurrentCaliber = self.(wptTable[ self.weapon ].iCaliberfld);
}

// We get a weapon for the first time essentially
// TODO: Drop the current slot weapon upon buying a new one
void Weapon_AddItem( float fWeapon ) {
	
	// Add the gun to the appropriate slot
	if( wptTable[ fWeapon ].iSlot == SLOT_MELEE ) {
		self.fSlotMelee = fWeapon;
	} else if ( wptTable[ fWeapon ].iSlot == SLOT_SECONDARY ) {
		self.fSlotSecondary = fWeapon;
	} else if( wptTable[ fWeapon ].iSlot == SLOT_PRIMARY ) {
		self.fSlotPrimary = fWeapon;
	} else if ( wptTable[ fWeapon ].iSlot == SLOT_GRENADE ) {
		self.fSlotGrenade = fWeapon;
	}
	
	// Switch to it
	self.weapon = fWeapon;
	
	// Make sure we've got at least one full clip
	self.(wptTable[ self.weapon ].iMagfld) = wptTable[ fWeapon ].iMagSize;
}

void Weapon_GiveAmmo( float fWeapon, float fAmount ) {
	self.(wptTable[ self.weapon ].iCaliberfld ) += fAmount;
	Weapon_UpdateCurrents();
}

void Weapon_SwitchBest( void ) {
	if ( self.fSlotSecondary ) {
		Weapon_Switch( SLOT_SECONDARY );
	} else if ( self.fSlotPrimary ) {
		Weapon_Switch( SLOT_PRIMARY );
	} else {
		Weapon_Switch( SLOT_MELEE );
	}
}

void CSEv_PlayerBuyWeapon_f( float fWeapon ) {
	if ( Rules_BuyingPossible() == FALSE ) {
		return;
	}
	
	if ( ( self.fMoney - wptTable[ fWeapon ].iPrice ) >= 0 ) {
		Weapon_AddItem( fWeapon );
		
		// Automatically fill weapons with ammo when you buy them (for free) like in CS:S
		if ( autocvar_mp_fillweapons == 1 ) {
			if ( wptTable[ fWeapon ].iSlot == SLOT_PRIMARY ) {
				Ammo_BuyPrimary( TRUE );
			} else if ( wptTable[ fWeapon ].iSlot == SLOT_SECONDARY ) {
				Ammo_BuySecondary( TRUE );
			}
		}
		
		Weapon_Draw( fWeapon );
		Money_AddMoney( self, -wptTable[ fWeapon ].iPrice );
		
		sound( self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE );
	} else {
		centerprint( self, "You have insufficient funds!" );
	}
	
	self.fAttackFinished = time + 1.0;
}

void CSEv_PlayerSwitchWeapon_f( float fWeapon ) {
	if ( fWeapon != self.weapon ) {
		self.weapon = fWeapon;
		Weapon_Draw( fWeapon );
	}
	
	self.fAttackFinished = time + 1.0;
}
#endif
