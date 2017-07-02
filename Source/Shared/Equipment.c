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

equipmentinfo_t eqptTable [ CS_EQUIPMENT_COUNT ] = {
	{ EQUIPMENT_KEVLAR, 650 },
	{ EQUIPMENT_HELMET, 1000 },
	{ WEAPON_FLASHBANG, 300 },
	{ WEAPON_HEGRENADE, 300 },
	{ WEAPON_SMOKEGRENADE, 300 },
	{ EQUIPMENT_DEFUSALKIT, 200 },
	{ EQUIPMENT_NIGHTVISION, 1250 },
};

#ifdef SSQC
void CSEv_PlayerBuyEquipment_f( float fID ) {
	if ( Rules_BuyingPossible() == FALSE ) {
		return;
	}
	
	if ( ( self.fMoney - eqptTable[ fID ].iPrice ) >= 0 ) {
		if ( eqptTable[ fID ].iID == WEAPON_HEGRENADE ) {
			if ( self.iAmmo_HEGRENADE < 2 ) {
				self.iAmmo_HEGRENADE++;
				Money_AddMoney( self, -300 );
			} else {
				centerprint( self, "You can't carry any more!" );
			}
		} else if ( eqptTable[ fID ].iID == WEAPON_FLASHBANG ) {
			if ( self.iAmmo_FLASHBANG < 2 ) {
				self.iAmmo_FLASHBANG++;
				Money_AddMoney( self, -300 );
			} else {
				centerprint( self, "You can't carry any more!" );
			}
		} else if ( eqptTable[ fID ].iID == WEAPON_SMOKEGRENADE ) {
			if ( self.iAmmo_SMOKEGRENADE < 2 ) {
				self.iAmmo_SMOKEGRENADE++;
				Money_AddMoney( self, -300 );
			} else {
				centerprint( self, "You can't carry any more!" );
			}
		} else if ( eqptTable[ fID ].iID == EQUIPMENT_KEVLAR ) {
			if ( self.armor == 100 ) {
				// You already own kevlar etc.
				centerprint( self, "You already have kevlar!" );
			} else {
				self.armor = 100;
				Money_AddMoney( self, -650 );
			}
			
			sound( self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE );
			self.fAttackFinished = time + 1.0;
			return;
		} else if ( eqptTable[ fID ].iID == EQUIPMENT_HELMET ) {
			if ( self.armor == 100 ) {
				if ( self.iEquipment & EQUIPMENT_HELMET ) {
					// You already have full kevlar and a helmet
					centerprint( self, "You already have kevlar and a helmet!" );
				} else {
					// You have full kevlar, but no helmet
					Money_AddMoney( self, -350 );
					sound( self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE );
					centerprint( self, "You already have some kevlar,\nand now you've bought a helmet!" );
				}
			} else {
				if ( self.iEquipment & EQUIPMENT_HELMET ) {
					// Only get kevlar
					self.armor = 100;
					Money_AddMoney( self, -650 );
					sound( self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE );
					centerprint( self, "You already have a helmet,\nand now you're bought some kevlar!" );
				} else {
					// Get both
					self.armor = 100;
					self.iEquipment = self.iEquipment | EQUIPMENT_HELMET;
					Money_AddMoney( self, -1000 );
					sound( self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE );
				}
			}
			
			self.fAttackFinished = time + 1.0;
			return;
		} 
	} else {
		centerprint( self, "You have insufficient funds!" );
	}
	
	self.fAttackFinished = time + 1.0;
}
#endif
