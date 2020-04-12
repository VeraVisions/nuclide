/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

int iArmouryItems[19] = {
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
	WEAPON_SMOKEGRENADE
};

string sArmouryModels[19] = {
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

class armoury_entity:CBaseEntity
{
	int m_iCount;
	int m_iLeft;
	int m_iItem;

	void(void) armoury_entity;
	virtual void(void) touch;
	virtual void(void) Respawn;
};

int amoury_entity_pickup(armoury_entity item, entity player)
{
	entity eOld = self;
	self = player;

	// Only MP5 til PARA
	if (item.m_iItem < 14) {
		if (Weapon_SlotEmpty(Weapon_GetSlot(iArmouryItems[item.m_iItem]))) {
			Weapon_AddItem(iArmouryItems[item.m_iItem]);
			Weapon_Draw(iArmouryItems[item.m_iItem]);
		} else {
			self = eOld;
			return FALSE;
		}
	} else {
		// Equipment
		if (iArmouryItems[item.m_iItem] == EQUIPMENT_KEVLAR) {
			if (self.armor != 100) {
				self.armor = 100;
			} else {
				self = eOld;
				return FALSE;
			}
		} else if (iArmouryItems[item.m_iItem] == EQUIPMENT_HELMET) {
			if (self.armor == 100) {
				if (!(self.iEquipment & EQUIPMENT_HELMET)) {
					sound(self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE);
				} else {
					self = eOld;
					return FALSE;
				}
			} else {
				if (self.iEquipment & EQUIPMENT_HELMET) {
					self.armor = 100;
					sound(self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE);
				} else {
					self.armor = 100;
					self.iEquipment = self.iEquipment | EQUIPMENT_HELMET;
					sound(self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE);
				}
			}
		} else {
			int iNades = self.iAmmo_FLASHBANG + self.iAmmo_HEGRENADE + self.iAmmo_SMOKEGRENADE;
			if (iNades < 3) {
				if (iArmouryItems[item.m_iItem]  == WEAPON_FLASHBANG) {
					self.iAmmo_FLASHBANG++;
					sound(self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
				} else if (iArmouryItems[item.m_iItem]  == WEAPON_HEGRENADE) {
					self.iAmmo_HEGRENADE++;
					sound(self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
				} else if (iArmouryItems[item.m_iItem]  == WEAPON_SMOKEGRENADE) {
					self.iAmmo_SMOKEGRENADE++;
					sound(self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
				}
			} else {
				self = eOld;
				return FALSE;
			}
		}
	}
	self = eOld;
	return TRUE;
}

void armoury_entity::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	if (amoury_entity_pickup(this, other)) {
		m_iLeft--;
			
		if (m_iLeft <= 0) {
			Hide();
		}
	}
}

void armoury_entity::Respawn(void)
{
	CBaseEntity::Respawn();

	solid = SOLID_TRIGGER;
	m_iLeft = m_iCount;
	droptofloor();
}

void armoury_entity::armoury_entity(void)
{
	if (autocvar_fcs_nopickups == TRUE) {
		remove(this);
		return;
	}

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "count":
			m_iCount = stoi(argv(i+1));
			break;
		case "item":
			m_iItem = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}
	
	model = sArmouryModels[m_iItem];

	CBaseEntity::CBaseEntity();

	precache_model(m_oldModel);
	setmodel(this, m_oldModel);
	setsize(this, [-16,-16,0], [16,16,16]);

	armoury_entity::Respawn();
}
