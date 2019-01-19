/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

ammoinfo_t ammoTable[11] = {
	{ 0, 0, 0 },
	{ 7, 35, 40 }, //CALIBER_50AE
	{ 30, 90, 80 }, //CALIBER_762MM
	{ 30, 90, 60 }, //CALIBER_556MM
	{ 30, 200, 60 }, //CALIBER_556MMBOX
	{ 10, 30, 125 }, //CALIBER_338MAG
	{ 30, 150, 20 }, //CALIBER_9MM
	{ 8, 32, 65 }, //CALIBER_BUCKSHOT
	{ 12, 100, 25 }, //CALIBER_45ACP
	{ 13, 52, 50 }, //CALIBER_357SIG
	{ 50, 100, 50 } //CALIBER_57MM
};

/*
=================
Ammo_BuyPrimary

Buy ammo for the primary weapon you're equipped with
=================
*/
void Ammo_BuyPrimary(void) {
	if ( !self.fSlotPrimary ) {
		return;
	}

	int iRequiredAmmo = ( ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iMaxAmount - self.(wptTable[ self.fSlotPrimary ].iCaliberfld));
	float fNew = ceil( ( (float)iRequiredAmmo / (float)ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iSize ) );
	for ( int i = 0; i < fNew; i++ ) {
		if ( self.fMoney - ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iPrice < 0 ) {
			break;
		}
		Money_AddMoney( self, -ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iPrice );
		sound( self, CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_IDLE );
		self.(wptTable[ self.fSlotPrimary ].iCaliberfld) += ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iSize;

		if ( self.(wptTable[ self.fSlotPrimary ].iCaliberfld) > ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iMaxAmount ) {
			self.(wptTable[ self.fSlotPrimary ].iCaliberfld) = ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iMaxAmount;
		}
	}  
}

/*
=================
Ammo_BuySecondary

Buy ammo for the secondary weapon you're equipped with
=================
*/
void Ammo_BuySecondary(void) {	
	if ( !self.fSlotSecondary ) {
		return;
	}

	int iRequiredAmmo = ( ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iMaxAmount - self.(wptTable[ self.fSlotSecondary ].iCaliberfld));
	float fNew = ceil( ( (float)iRequiredAmmo / (float)ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iSize ) );
	
	for ( int i = 0; i < fNew; i++ ) {
		if ( self.fMoney - ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iPrice < 0 ) {
			break;
		}
		Money_AddMoney( self, -ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iPrice );
		sound( self, CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_IDLE );
		self.(wptTable[ self.fSlotSecondary ].iCaliberfld) += ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iSize;

		if ( self.(wptTable[ self.fSlotSecondary ].iCaliberfld) > ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iMaxAmount ) {
			self.(wptTable[ self.fSlotSecondary ].iCaliberfld) = ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iMaxAmount;
		}
	}  
}

void Ammo_AutoFill(float fWeapon)
{
	if (autocvar_fcs_fillweapons == FALSE) {
		return;
	}

	if (Weapon_AlreadyExists(fWeapon)) {
		self.(wptTable[fWeapon].iMagfld) = wptTable[fWeapon].iMagSize;
		self.(wptTable[fWeapon].iCaliberfld) = ammoTable[wptTable[fWeapon].iCaliber].iMaxAmount;
		Weapon_UpdateCurrents();
	}
}

void Ammo_Clear(void)
{
	// Clear all the ammo stuff
	for ( int i = 0; i < CS_WEAPON_COUNT; i++ ) {
		self.(wptTable[ i ].iMagfld) = 0;
		self.(wptTable[ i ].iCaliberfld) = 0;
	}

	self.fSlotMelee = 0;
	self.fSlotPrimary = 0;
	self.fSlotSecondary = 0;
	self.fSlotGrenade = 0;
	self.iEquipment = 0;
}

/*
=================
CSEv_GamePlayerBuyAmmo_f

Called from the client, checks if he can buy ammo and does if yes
=================
*/
void CSEv_GamePlayerBuyAmmo_f( float fType ) {
	if ( Rules_BuyingPossible() == FALSE ) {
		return;
	}
	
	if ( fType == 0 ) {
		Ammo_BuyPrimary();
	} else {
		Ammo_BuySecondary();
	}

	Weapon_UpdateCurrents();
}
