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

.float item;
.float count;

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

		if ( iArmouryItems[ eOld.item ] < 32 ) {
			if ( Weapon_SlotEmpty( Weapon_GetSlot( iArmouryItems[ eOld.item ] ) ) ) {
				Weapon_AddItem( iArmouryItems[ eOld.item ] );
				Weapon_Draw( iArmouryItems[ eOld.item ] );
			} else {
				self = eOld;
				return;
			}
		} else {
			// Equipment
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
	
	precache_model( sArmouryModels[ self.item ] );
	setmodel( self, sArmouryModels[ self.item ] );
	setsize( self, '-16 -16 0', '16 16 16' );
		
	armoury_entity_respawn();
	Entities_InitRespawnable( armoury_entity_respawn );
}
