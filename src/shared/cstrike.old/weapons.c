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

void Temp_Nothing(void) { }

#ifdef SERVER
string sWeaponModels[CS_WEAPON_COUNT] = {
	"",
	"models/w_knife.mdl",
	"models/w_usp.mdl",
	"models/w_glock18.mdl",
	"models/w_deagle.mdl",
	"models/w_p228.mdl",
	"models/w_elite.mdl",
	"models/w_fiveseven.mdl",
	"models/w_m3.mdl",
	"models/w_xm1014.mdl",
	"models/w_mp5.mdl",
	"models/w_p90.mdl",
	"models/w_ump45.mdl",
	"models/w_mac10.mdl",
	"models/w_tmp.mdl",
	"models/w_ak47.mdl",
	"models/w_sg552.mdl",
	"models/w_m4a1.mdl",
	"models/w_aug.mdl",
	"models/w_scout.mdl",
	"models/w_awp.mdl",
	"models/w_g3sg1.mdl",
	"models/w_sg550.mdl",
	"models/w_m249.mdl",
	"models/w_backpack.mdl",
	"models/w_flashbang.mdl",
	"models/w_hegrenade.mdl",
	"models/w_smokegrenade.mdl"
};
#endif 

weaponfunc_t wpnFuncTable[CS_WEAPON_COUNT] = {
	{ Temp_Nothing, Temp_Nothing, Temp_Nothing, Temp_Nothing },
	{ WeaponKNIFE_Draw, WeaponKNIFE_PrimaryFire, WeaponKNIFE_Secondary, Temp_Nothing },
	{ WeaponUSP45_Draw, WeaponUSP45_PrimaryFire, WeaponUSP45_Secondary, WeaponUSP45_Reload },
	{ WeaponGLOCK18_Draw, WeaponGLOCK18_PrimaryFire, WeaponGLOCK18_Secondary, WeaponGLOCK18_Reload },
	{ WeaponDEAGLE_Draw, WeaponDEAGLE_PrimaryFire, Temp_Nothing, WeaponDEAGLE_Reload },
	{ WeaponP228_Draw, WeaponP228_PrimaryFire, Temp_Nothing, WeaponP228_Reload },
	{ WeaponELITES_Draw, WeaponELITES_PrimaryFire, Temp_Nothing, WeaponELITES_Reload },
	{ WeaponFIVESEVEN_Draw, WeaponFIVESEVEN_PrimaryFire, Temp_Nothing, WeaponFIVESEVEN_Reload },
#ifdef SERVER
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
	{ WeaponC4BOMB_Draw, WeaponC4BOMB_PrimaryFire, Temp_Nothing, Temp_Nothing },
	{ WeaponFLASHBANG_Draw, WeaponFLASHBANG_PrimaryFire, Temp_Nothing, Temp_Nothing },
	{ WeaponHEGRENADE_Draw, WeaponHEGRENADE_PrimaryFire, Temp_Nothing, Temp_Nothing },
	{ WeaponSMOKEGRENADE_Draw, WeaponSMOKEGRENADE_PrimaryFire, Temp_Nothing, Temp_Nothing }
};

/*
=================
Weapon_Draw
=================
*/
void Weapon_Draw(float fWeapon) {
	if (!fWeapon) {
		return;
	}
	
#ifdef SERVER
	// In case reloading logic is still going on
	self.think = Empty;
	
	self.viewzoom = 1.0;
	self.weapon = fWeapon;
	self.fAttackFinished = time + 1.0;
#endif

#ifdef CLIENT
	if (fWeaponEventPlayer != player_localentnum) {
		return;
	}
#endif
		
	wpnFuncTable[fWeapon].vDraw();
}

/*
=================
Weapon_PrimaryAttack
=================
*/
void Weapon_PrimaryAttack(float fWeapon) {
#ifdef SERVER
	if (self.fAttackFinished > time) {
		return;
	}
	if (!(self.flags & FL_SEMI_TOGGLED)) {
		return;
	}
#endif
#ifdef CLIENT
	if (fWeaponEventPlayer != player_localentnum || autocvar_cl_thirdperson == TRUE) {
		entity ono = findfloat(world, entnum, fWeaponEventPlayer);
		if (ono != __NULL__) {
			Animation_ShootWeapon(ono);
		}
		return;
	}
#endif

	wpnFuncTable[fWeapon].vPrimary();
}

/*
=================
Weapon_SecondaryAttack
=================
*/
void Weapon_SecondaryAttack(float fWeapon) {
#ifdef SERVER
	if (self.fAttackFinished > time) {
		return;
	}
#endif
#ifdef CLIENT
	if (fWeaponEventPlayer != player_localentnum || autocvar_cl_thirdperson == TRUE) {
		return;
	}
#endif
	wpnFuncTable[fWeapon].vSecondary();
}

/*
=================
Weapon_Reload
=================
*/
void Weapon_Reload(float fWeapon) {
#ifdef SERVER
	if (self.fAttackFinished > time) {
		return;
	}
	self.viewzoom = 1.0;
#endif
#ifdef CLIENT
	if (fWeaponEventPlayer != player_localentnum || autocvar_cl_thirdperson == TRUE) {
		entity ono = findfloat(world, entnum, fWeaponEventPlayer);
		if (ono != __NULL__) {
			Animation_ReloadWeapon(ono);
		}
		return;
	}
#endif
	wpnFuncTable[fWeapon].vReload();
}

/*
=================
Weapon_GetAnimType

Returns which animationset a weapon will use on a player
=================
*/
float Weapon_GetAnimType(float fWeapon) {
	return wptTable[fWeapon].fAnimType;
}

/*
=================
Weapon_GetFireRate

Returns the delay between shots of a given weapon
=================
*/
float Weapon_GetFireRate(float fWeapon) {
	return wptTable[fWeapon].fAttackFinished;
}

/*
=================
Weapon_GetReloadTime

Returns the reloading delay before being able to be fired again
=================
*/
float Weapon_GetReloadTime(float fWeapon) {
	return wptTable[fWeapon].fReloadFinished;
}

/*
=================
Weapon_GetSpeedM

Returns the speed multiplier
=================
*/
float Weapon_GetSpeedM(float fWeapon) {
	return wptTable[fWeapon].fSpeedM;
}

#ifdef SERVER
/*
=================
Weapon_Release

Called when letting go one of the weapon firing buttons
=================
*/
void Weapon_Release(void) {
	self.flags = self.flags | FL_SEMI_TOGGLED;
	
	if (self.weapon == WEAPON_FLASHBANG) {
		WeaponFLASHBANG_Release();
	} else if (self.weapon == WEAPON_HEGRENADE) {
		WeaponHEGRENADE_Release();
	} else if (self.weapon == WEAPON_SMOKEGRENADE) {
		WeaponSMOKEGRENADE_Release();
	} else if (self.weapon == WEAPON_C4BOMB) {
		WeaponC4BOMB_Release();
	} else {
		if (self.weapon == WEAPON_XM1014) {
			return;
		} else if (self.weapon == WEAPON_M3) {
			return;
		}
		if (self.(wptTable[self.weapon].iMagfld) <= 0) {
			if (self.(wptTable[self.weapon].iCaliberfld)) {
				Weapon_Reload(self.weapon);
			}
		}
	}
}

/*
=================
Weapon_GetSlot

Returns which slot a weapon belongs to
=================
*/
int Weapon_GetSlot(float fWeapon) {
	return wptTable[fWeapon].iSlot;
}

/*
=================
Weapon_AlreadyExists

Returns whether or not we have the given weapon already
=================
*/
float Weapon_AlreadyExists(float fWeapon) {
	if (fWeapon == WEAPON_FLASHBANG || fWeapon == WEAPON_HEGRENADE || fWeapon == WEAPON_SMOKEGRENADE) {
		int iNades = self.iAmmo_FLASHBANG + self.iAmmo_HEGRENADE + self.iAmmo_SMOKEGRENADE;
		if (iNades) {
			return TRUE;
		} else {
			return FALSE;
		}
	} else { 
		if (wptTable[fWeapon].iSlot == SLOT_PRIMARY) {
			if (self.fSlotPrimary == fWeapon) {
				return TRUE;
			}
		} else if (wptTable[fWeapon].iSlot == SLOT_SECONDARY) {
			if (self.fSlotSecondary == fWeapon) {
				return TRUE;
			}
		} else if (wptTable[fWeapon].iSlot == SLOT_GRENADE) {
			if (self.fSlotGrenade == fWeapon) {
				return TRUE;
			}
		} else if (wptTable[fWeapon].iSlot == SLOT_C4BOMB) {
			if (self.fSlotC4Bomb == fWeapon) {
				return TRUE;
			}
		}
	}
	
	return FALSE;
}

/*
=================
Weapon_SlotEmpty

Returns whether or not a slot is empty
=================
*/
float Weapon_SlotEmpty(int fSlot) {
	if (fSlot == SLOT_PRIMARY) {
		if (self.fSlotPrimary == 0) {
			return TRUE;
		}
	} else if (fSlot == SLOT_SECONDARY) {
		if (self.fSlotSecondary == 0) {
			return TRUE;
		}
	} else if (fSlot == SLOT_GRENADE) {
		if (self.fSlotGrenade == 0) {
			return TRUE;
		}
	} else if (fSlot == SLOT_C4BOMB) {
		if (self.fSlotC4Bomb == 0) {
			return TRUE;
		}
	}
	
	return FALSE;
}

/*
=================
Weapon_Switch

Switch to the weapon in a given slot
=================
*/
void Weapon_Switch(int iSlot) {
	float fWeapon;
	
	if (iSlot == SLOT_MELEE) {
		fWeapon = self.fSlotMelee;
	} else if (iSlot == SLOT_PRIMARY) {
		fWeapon = self.fSlotPrimary;
	} else if (iSlot == SLOT_SECONDARY) {
		fWeapon = self.fSlotSecondary;
	} else if (iSlot == SLOT_GRENADE) {
		fWeapon = self.fSlotGrenade;
	} else if (iSlot == SLOT_C4BOMB) {
		fWeapon = self.fSlotC4Bomb;
	}
	
	if (!fWeapon || self.weapon == fWeapon) {
		return;
	}
	
	Weapon_Draw(fWeapon);
}

/*
=================
Weapon_UpdateCurrents

Update the ammo fields for the clientside display
=================
*/
void Weapon_UpdateCurrents(void) {
	self.iCurrentMag = self.(wptTable[self.weapon].iMagfld);
	self.iCurrentCaliber = self.(wptTable[self.weapon].iCaliberfld);
}

/*
=================
Weapon_AddItem

Gives a weapon to the player
=================
*/
void Weapon_AddItem(float fWeapon) {
	if (Weapon_SlotEmpty (wptTable[fWeapon].iSlot) == FALSE) {
		Weapon_DropWeapon(wptTable[fWeapon].iSlot);
	}
	
	// Add the gun to the appropriate slot
	if(wptTable[fWeapon].iSlot == SLOT_MELEE) {
		self.fSlotMelee = fWeapon;
	} else if (wptTable[fWeapon].iSlot == SLOT_SECONDARY) {
		self.fSlotSecondary = fWeapon;
	} else if(wptTable[fWeapon].iSlot == SLOT_PRIMARY) {
		self.fSlotPrimary = fWeapon;
	} else if (wptTable[fWeapon].iSlot == SLOT_GRENADE) {
		self.fSlotGrenade = fWeapon;
	} else if (wptTable[fWeapon].iSlot == SLOT_C4BOMB) {
		self.fSlotC4Bomb = fWeapon;
	}
	
	// Make sure we've got at least one full clip
	self.(wptTable[fWeapon].iMagfld) = wptTable[fWeapon].iMagSize;
}

/*
=================
Weapon_GiveAmmo

Gives a specific amount of ammo to the player
=================
*/
void Weapon_GiveAmmo(float fWeapon, float fAmount) {
	self.(wptTable[fWeapon].iCaliberfld) += fAmount;
	Weapon_UpdateCurrents();
}

/*
=================
Weapon_SwitchBest

Switches to the currently best suited weapon
=================
*/
void Weapon_SwitchBest(void) {
	if (self.fSlotSecondary) {
		Weapon_Switch(SLOT_SECONDARY);
	} else if (self.fSlotPrimary) {
		Weapon_Switch(SLOT_PRIMARY);
	} else {
		Weapon_Switch(SLOT_MELEE);
	}
}

/*
=================
Weapon_DropWeapon

Drop the weapon in a given slot
=================
*/
void Weapon_DropWeapon(int iSlot) {
	static void Weapon_DropWeapon_Touch(void) {
		if (other.classname != "player") {
			return;
		} else if (other == self.owner) {
			return;
		}
		
		// No bomb for the CTs
		if ((self.weapon == WEAPON_C4BOMB) && (other.team == TEAM_CT)) {
			return;
		}
		
		entity eOld = self;
		self = other;
		
		if (Weapon_SlotEmpty(Weapon_GetSlot(eOld.weapon))) {
			Weapon_AddItem(eOld.weapon);
			Weapon_Draw(eOld.weapon);
			self.(wptTable[eOld.weapon].iMagfld) = eOld.health;
			Weapon_UpdateCurrents();
		} else {
			self = eOld;
			return;
		}
		
		self = eOld;
		remove(self);
	}
	
	static void Weapon_DropWeapon_Think(void) {
		self.owner = world;
	}
	
	float fWeapon;
	
	if (iSlot == SLOT_PRIMARY) {
		fWeapon = self.fSlotPrimary;
		self.fSlotPrimary = 0;
	} else if (iSlot == SLOT_SECONDARY) {
		fWeapon = self.fSlotSecondary;
		self.fSlotSecondary = 0;
	} else if (iSlot == SLOT_GRENADE) {
		fWeapon = self.fSlotGrenade;
		self.fSlotGrenade = 0;
	} else if (iSlot == SLOT_C4BOMB) {
		fWeapon = self.fSlotC4Bomb;
		self.fSlotC4Bomb = 0;
	} else {
		return;
	}
	
	entity eDrop = spawn();
	setorigin(eDrop, self.origin + self.view_ofs);
	setmodel(eDrop, sWeaponModels[fWeapon]);
	eDrop.classname = "remove_me";
	eDrop.owner = self;
	eDrop.movetype = MOVETYPE_TOSS;
	eDrop.solid = SOLID_TRIGGER;
	eDrop.weapon = fWeapon;
	eDrop.think = Weapon_DropWeapon_Think;
	eDrop.touch = Weapon_DropWeapon_Touch;
	eDrop.nextthink = time + 1.0f;
	eDrop.health = self.(wptTable[fWeapon].iMagfld);
	setsize(eDrop, '-16 -16 0', '16 16 16');

	makevectors(self.v_angle);

	if (fWeapon == WEAPON_C4BOMB && autocvar_fcs_bombaltthrow) {
		eDrop.velocity = v_forward * random(32, 96);
		eDrop.velocity += v_right * random(-64, 64);
		eDrop.velocity[2] = 0;
	} else {
		eDrop.velocity = self.velocity + v_forward * 256;
	}

	self.weapon = 0;
	Weapon_SwitchBest();
}

/*
=================
CSEv_PlayerBuyWeapon_f

Client call for buying a weapon through GUI or console command
=================
*/
void CSEv_PlayerBuyWeapon_f(float fWeapon) {
	if (Rules_BuyingPossible() == FALSE) {
		return;
	}
	
	if (self.team == TEAM_T) {
		if (fWeapon == WEAPON_M4A1) { return; }
		if (fWeapon == WEAPON_AUG) { return; }
		if (fWeapon == WEAPON_SG550) { return; }
		if (fWeapon == WEAPON_FIVESEVEN) { return; }
		if (fWeapon == WEAPON_TMP) { return; }
	} else if (self.team == TEAM_CT) {
		if (fWeapon == WEAPON_AK47) { return; }
		if (fWeapon == WEAPON_SG552) { return; }
		if (fWeapon == WEAPON_G3SG1) { return; }
		if (fWeapon == WEAPON_ELITES) { return; }
		if (fWeapon == WEAPON_MAC10) { return; }
	}
			
	if ((self.fMoney - wptTable[fWeapon].iPrice) >= 0) {
		Weapon_AddItem(fWeapon);
		Ammo_AutoFill(fWeapon);

		Weapon_Draw(fWeapon);
		Money_AddMoney(self, -wptTable[fWeapon].iPrice);
		
		sound(self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
	} else {
		centerprint(self, "You have insufficient funds!");
	}
}

/*
=================
CSEv_PlayerSwitchWeapon_i

Client-HUD call that switches to a specific weapon
=================
*/
void CSEv_PlayerSwitchWeapon_i(int fWeapon) {
	if ((Weapon_AlreadyExists(fWeapon) == FALSE) && (fWeapon != WEAPON_KNIFE)) {
		return;
	}
	if (wptTable[fWeapon].iSlot == SLOT_GRENADE) {
		if (fWeapon == WEAPON_HEGRENADE && !(self.iAmmo_HEGRENADE)) {
			return;
		} else if (fWeapon == WEAPON_FLASHBANG && !(self.iAmmo_FLASHBANG)) {
			return;
		} else if (fWeapon == WEAPON_SMOKEGRENADE && !(self.iAmmo_SMOKEGRENADE)) {
			return;
		}
	}
	if (fWeapon != self.weapon) {
		Weapon_Draw(fWeapon);
	}
}

/*
=================
CSEv_WeaponDrop

Client call that tells us to drop the currently equipped weapon
=================
*/
void CSEv_WeaponDrop(void) {
	Weapon_DropWeapon(wptTable[self.weapon].iSlot);
}
#endif
