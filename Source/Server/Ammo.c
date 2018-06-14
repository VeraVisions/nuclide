/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
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

/*
=================
Ammo_BuyPrimary

Buy ammo for the primary weapon you're equipped with
=================
*/
void Ammo_BuyPrimary( float fFree ) {
	if ( !self.fSlotPrimary ) {
		return;
	}

	int iRequiredAmmo = ( ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iMaxAmount - self.(wptTable[ self.fSlotPrimary ].iCaliberfld));
	float fNew = ceil( ( (float)iRequiredAmmo / (float)ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iSize ) );
	
	for ( int i = 0; i < fNew; i++ ) {
		if ( self.fMoney - ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iPrice  >= 0 ) {
			self.(wptTable[ self.fSlotPrimary ].iCaliberfld) += ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iSize;
			Money_AddMoney( self, -ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iPrice );
			sound( self, CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_IDLE );
			
			if ( self.(wptTable[ self.fSlotPrimary ].iCaliberfld) > ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iMaxAmount ) {
				self.(wptTable[ self.fSlotPrimary ].iCaliberfld) = ammoTable[ wptTable[ self.fSlotPrimary ].iCaliber ].iMaxAmount;
			}
		} else {
			break;
		}
	}  
}

/*
=================
Ammo_BuySecondary

Buy ammo for the secondary weapon you're equipped with
=================
*/
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
		Ammo_BuyPrimary( FALSE );
	} else {
		Ammo_BuySecondary( FALSE );
	}
	
	Weapon_UpdateCurrents();
}
