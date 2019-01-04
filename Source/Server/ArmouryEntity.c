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

int iArmouryItems[ 19 ] = {
	WEAPON_MP5,
	WEAPON_TMP,
	WEAPON_P90,
	WEAPON_MAC10,
	WEAPON_AK47,
	WEAPON_SG552,
	WEAPON_M4A1,
	WEAPON_AUG,
	WEAPON_SCOUT,
	WEAPON_G3SG1,
	WEAPON_AWP,
	WEAPON_M3,
	WEAPON_XM1014,
	WEAPON_PARA,
	WEAPON_FLASHBANG,
	WEAPON_HEGRENADE,
	EQUIPMENT_KEVLAR,
	EQUIPMENT_HELMET,
	WEAPON_SMOKEGRENADE,
};

string sArmouryModels[ 19 ] = {
	"models/w_mp5.mdl",       
	"models/w_tmp.mdl",        
	"models/w_p90.mdl",    
	"models/w_mac10.mdl",       
	"models/w_ak47.mdl",       
	"models/w_sg552.mdl",       
	"models/w_m4a1.mdl",       
	"models/w_aug.mdl",        
	"models/w_scout.mdl",      
	"models/w_g3sg1.mdl",      
	"models/w_awp.mdl",         
	"models/w_m3.mdl",          
	"models/w_xm1014.mdl",    
	"models/w_m249.mdl",        
	"models/w_flashbang.mdl",   
	"models/w_hegrenade.mdl",  
	"models/w_kevlar.mdl",
	"models/w_assault.mdl",     
	"models/w_smokegrenade.mdl"
};

/*
=================
SPAWN: armoury_entity

Very old entity that wasn't updated all that much
but is heavily present throughout custom maps, hence the odd item list
=================
*/
void armoury_entity( void ) {
	static void armoury_entity_touch( void ) {
		if ( other.classname != "player" ) {
			return;
		}
		
		entity eOld = self;
		self = other;
		
		// Only MP5 til PARA
		if ( eOld.item < 14 ) {
			if ( Weapon_SlotEmpty( Weapon_GetSlot( iArmouryItems[ eOld.item ] ) ) ) {
				Weapon_AddItem( iArmouryItems[ eOld.item ] );
				Weapon_Draw( iArmouryItems[ eOld.item ] );
			} else {
				self = eOld;
				return;
			}
		} else {
			// Equipment
			if ( iArmouryItems[ eOld.item ] == EQUIPMENT_KEVLAR ) {
				if ( self.armor != 100 ) {
					self.armor = 100;
				} else {
					self = eOld;
					return;
				}
			} else if ( iArmouryItems[ eOld.item ] == EQUIPMENT_HELMET ) {
				if ( self.armor == 100 ) {
					if ( !( self.iEquipment & EQUIPMENT_HELMET ) ) {
						sound( self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE );
					} else {
						self = eOld;
						return;
					}
				} else {
					if ( self.iEquipment & EQUIPMENT_HELMET ) {
						self.armor = 100;
						sound( self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE );
					} else {
						self.armor = 100;
						self.iEquipment = self.iEquipment | EQUIPMENT_HELMET;
						sound( self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE );
					}
				}
			} else {
				int iNades = self.iAmmo_FLASHBANG + self.iAmmo_HEGRENADE + self.iAmmo_SMOKEGRENADE;
				if ( iNades < 3 ) {
					if ( iArmouryItems[ eOld.item ]  == WEAPON_FLASHBANG ) {
						self.iAmmo_FLASHBANG++;
						sound( self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE );
					} else if ( iArmouryItems[ eOld.item ]  == WEAPON_HEGRENADE ) {
						self.iAmmo_HEGRENADE++;
						sound( self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE );
					} else if ( iArmouryItems[ eOld.item ]  == WEAPON_SMOKEGRENADE ) {
						self.iAmmo_SMOKEGRENADE++;
						sound( self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE );
					}
				} else {
					self = eOld;
					return;
				}
			}
		}
		self = eOld;

		self.health--;
		
		if ( self.health <= 0 ) {
			Entities_Remove();
		}
	}
	static void armoury_entity_respawn( void ) {
		self.solid = SOLID_TRIGGER;
		self.health = self.count;
		self.touch = armoury_entity_touch;
		droptofloor();
	}
	if ( autocvar_fcs_nopickups == TRUE ) {
		remove( self );
		return;
	}
	
	precache_model( sArmouryModels[ self.item ] );
	setmodel( self, sArmouryModels[ self.item ] );
	setsize( self, '-16 -16 0', '16 16 16' );

	armoury_entity_respawn();
	Entities_InitRespawnable( armoury_entity_respawn );
}
