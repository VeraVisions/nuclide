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

void Ammo_BuyPrimary( float fFree ) {
	if ( !self.fSlotPrimary ) {
		return;
	}

	int iRequiredAmmo = ( ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iMaxAmount - self.(wptTable[ self.fSlotPrimary ].iCaliberfld));
	float fNew = ceil( ( (float)iRequiredAmmo / (float)ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iSize ) );
	
	for ( int i = 0; i < fNew; i++ ) {
		self.(wptTable[ self.fSlotPrimary ].iCaliberfld) += ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iSize;
		Money_AddMoney( self, -ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iPrice );
		sound( self, CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_IDLE );
		
		if ( self.(wptTable[ self.fSlotPrimary ].iCaliberfld) > ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iMaxAmount ) {
			self.(wptTable[ self.fSlotPrimary ].iCaliberfld) = ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iMaxAmount;
		}
	}  
}

void Ammo_BuySecondary( float fFree ) {	
	if ( !self.fSlotSecondary ) {
		return;
	}

	int iRequiredAmmo = ( ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iMaxAmount - self.(wptTable[ self.fSlotSecondary ].iCaliberfld));
	float fNew = ceil( ( (float)iRequiredAmmo / (float)ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iSize ) );
	
	for ( int i = 0; i < fNew; i++ ) {
		if ( fFree == FALSE ) {
			if ( self.fMoney - ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iPrice < 0 ) {
				break;
			}
			Money_AddMoney( self, -ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iPrice );
		}
		
		self.(wptTable[ self.fSlotSecondary ].iCaliberfld) += ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iSize;
		sound( self, CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_IDLE );
		
		if ( self.(wptTable[ self.fSlotSecondary ].iCaliberfld) > ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iMaxAmount ) {
			self.(wptTable[ self.fSlotSecondary ].iCaliberfld) = ammoTable[ wptTable[ self.fSlotSecondary ].iCaliber ].iMaxAmount;
		}
	}  
}

void CSEv_GamePlayerBuyAmmo_f( float fType ) {
	if ( Rules_BuyingPossible() == FALSE ) {
		return;
	}
	
	if ( fType == 0 ) {
		Ammo_BuyPrimary( FALSE );
	} else {
		Ammo_BuySecondary( FALSE );
	}
	
	Weapon_UpdateCurrents();
	self.fAttackFinished = time + 1.0;
}
