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

void Ammo_BuyPrimary( void ) {
	if ( !self.iSlotPrimary ) {
		return;
	}

	int iRequiredAmmo = ( ammoTable[ wptTable[ self.iSlotPrimary ].iCaliber ].iMaxAmount - self.(wptTable[ self.iSlotPrimary ].iCaliberfld));
	float fNew = ceil( ( (float)iRequiredAmmo / (float)ammoTable[ wptTable[ self.iSlotPrimary ].iCaliber ].iSize ) );
	
	for ( int i = 0; i < fNew; i++ ) {
		self.(wptTable[ self.iSlotPrimary ].iCaliberfld) += ammoTable[ wptTable[ self.iSlotPrimary ].iCaliber ].iSize;
		self.fMoney -= ammoTable[ wptTable[ self.iSlotPrimary ].iCaliber ].iPrice;
		
		if ( self.(wptTable[ self.iSlotPrimary ].iCaliberfld) > ammoTable[ wptTable[ self.iSlotPrimary ].iCaliber ].iMaxAmount ) {
			self.(wptTable[ self.iSlotPrimary ].iCaliberfld) = ammoTable[ wptTable[ self.iSlotPrimary ].iCaliber ].iMaxAmount;
		}
	}  
}

void Ammo_BuySecondary( void ) {	
	if ( !self.iSlotSecondary ) {
		return;
	}

	int iRequiredAmmo = ( ammoTable[ wptTable[ self.iSlotSecondary ].iCaliber ].iMaxAmount - self.(wptTable[ self.iSlotSecondary ].iCaliberfld));
	float fNew = ceil( ( (float)iRequiredAmmo / (float)ammoTable[ wptTable[ self.iSlotSecondary ].iCaliber ].iSize ) );
	
	for ( int i = 0; i < fNew; i++ ) {
		if ( self.fMoney - ammoTable[ wptTable[ self.iSlotSecondary ].iCaliber ].iPrice < 0 ) {
			break;
		}
		
		self.(wptTable[ self.iSlotSecondary ].iCaliberfld) += ammoTable[ wptTable[ self.iSlotSecondary ].iCaliber ].iSize;
		self.fMoney -= ammoTable[ wptTable[ self.iSlotSecondary ].iCaliber ].iPrice;
		
		if ( self.(wptTable[ self.iSlotSecondary ].iCaliberfld) > ammoTable[ wptTable[ self.iSlotSecondary ].iCaliber ].iMaxAmount ) {
			self.(wptTable[ self.iSlotSecondary ].iCaliberfld) = ammoTable[ wptTable[ self.iSlotSecondary ].iCaliber ].iMaxAmount;
		}
	}  
}

void CSEv_GamePlayerBuyAmmo_f( float fType ) {
	if ( Rules_BuyingPossible() == FALSE ) {
		return;
	}
	
	if ( fType == 0 ) {
		Ammo_BuyPrimary();
	} else {
		Ammo_BuySecondary();
	}
	
	sound( self, CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
	Weapon_UpdateCurrents();
	self.fAttackFinished = time + 1.0;
}

