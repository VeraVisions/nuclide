/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

typedef struct {
	string sSprite;
	vector vOrigin;
} weaponsymbolinfo_t;

weaponsymbolinfo_t wpSymbolTable[CS_WEAPON_COUNT] = {
	{ "", [0,0] }, //WEAPON_NONE
	{ "sprites/640hud10.spr_0.tga", [0,0.52734375] },	//WEAPON_KNIFE
	{ "sprites/640hud1.spr_0.tga", [0,0.3515625] },		//WEAPON_USP45
	{ "sprites/640hud1.spr_0.tga", [0,0.17578125] },	//WEAPON_GLOCK18
	{ "sprites/640hud10.spr_0.tga", [0,0.3515625] },	//WEAPON_DEAGLE
	{ "sprites/640hud12.spr_0.tga", [0,0.3515625] },	//WEAPON_P228
	{ "sprites/640hud14.spr_0.tga", [0,0.3515625] },	//WEAPON_ELITES
	{ "sprites/640hud14.spr_0.tga", [0,0.52734375] },	//WEAPON_FIVESEVEN
	{ "sprites/640hud1.spr_0.tga", [0,0.52734375] },	//WEAPON_M3
	{ "sprites/640hud12.spr_0.tga", [0,0.52734375] },	//WEAPON_XM1014
	{ "sprites/640hud1.spr_0.tga", [0,0.703125] },		//WEAPON_MP5
	{ "sprites/640hud12.spr_0.tga", [0,0] },			//WEAPON_P90
	{ "sprites/640hud16.spr_0.tga", [0,0] },			//WEAPON_UMP45
	{ "sprites/640hud14.spr_0.tga", [0,0] },			//WEAPON_MAC10
	{ "sprites/640hud5.spr_0.tga", [0,0] },				//WEAPON_TMP
	{ "sprites/640hud10.spr_0.tga", [0,0] },			//WEAPON_AK47
	{ "sprites/640hud10.spr_0.tga", [0,0.17578125] },	//WEAPON_SG552
	{ "sprites/640hud2.spr_0.tga", [0,0.17578125] },	//WEAPON_M4A1
	{ "sprites/640hud14.spr_0.tga", [0,0.17578125] },	//WEAPON_AUG
	{ "sprites/640hud12.spr_0.tga", [0,0.17578125] },	//WEAPON_SCOUT
	{ "sprites/640hud2.spr_0.tga", [0,0.52734375] },	//WEAPON_AWP
	{ "sprites/640hud2.spr_0.tga", [0,0.703125] },		//WEAPON_G3SG1
	{ "sprites/640hud14.spr_0.tga", [0,0.703125] },		//WEAPON_SG550
	{ "sprites/640hud3.spr_0.tga", [0,0] },				//WEAPON_PARA
	{ "sprites/640hud1.spr_0.tga", [0,0] },				//WEAPON_C4BOMB
	{ "sprites/640hud3.spr_0.tga", [0,0.3515625] },		//WEAPON_FLASHBANG
	{ "sprites/640hud3.spr_0.tga", [0,0.17578125] },	//WEAPON_HEGRENADE
	{ "sprites/640hud3.spr_0.tga", [0,0.52734375] }		//WEAPON_SMOKEGRENADE
};

vector vHUDSlotNumPos[5] = {
	[0.65625,0.28125],	// 1 PRIMARY
	[0.734375,0.28125],	// 2 SECONDARY
	[0.8125,0.28125],	// 3 MELEE
	[0.65625,0.359375],	// 4 GRENADE
	[0.734375,0.359375]	// 5 C4-BOMB
};

/*
=================
HUD_DrawWeaponSelect_NextItem

Checks and returns the next slot with a weapon in it
=================
*/
float HUD_DrawWeaponSelect_NextItem(float fSlot)
{
	if (fSlot == SLOT_PRIMARY) {
		if (getstatf(STAT_SLOT_SECONDARY)) {
			return SLOT_SECONDARY;
		} else {
			return HUD_DrawWeaponSelect_NextItem(SLOT_SECONDARY);
		}
	} else if (fSlot == SLOT_SECONDARY) {
		if (getstatf(STAT_SLOT_MELEE)) {
			return SLOT_MELEE;
		} else {
			return HUD_DrawWeaponSelect_NextItem(SLOT_MELEE);
		}
	} else if (fSlot == SLOT_MELEE) {
		// This happens when we go into the slot for the first time
		pSeat->iHUDGrenades = 0;

		// Keep this order in order for the selection to work
		if (getstati_punf(STAT_ITEM_SMOKEGRENADE)) {
			pSeat->iHUDGrenadesSelected = WEAPON_SMOKEGRENADE;
			pSeat->iHUDGrenades++;
		}
		if (getstati_punf(STAT_ITEM_FLASHBANG)) {
			pSeat->iHUDGrenadesSelected = WEAPON_FLASHBANG;
			pSeat->iHUDGrenades++;
		} 
		
		if (getstati_punf(STAT_ITEM_HEGRENADE)) {
			pSeat->iHUDGrenadesSelected = WEAPON_HEGRENADE;
			pSeat->iHUDGrenades++;
		} 
		
		// If we have any grenades, proceed with that slot
		if (pSeat->iHUDGrenades) {
			return SLOT_GRENADE;
		} else { 
			return HUD_DrawWeaponSelect_NextItem(SLOT_GRENADE);
		}
	} else if (fSlot == SLOT_C4BOMB) {
		if (getstatf(STAT_SLOT_PRIMARY)) {
			return SLOT_PRIMARY;
		} else {
			return HUD_DrawWeaponSelect_NextItem(SLOT_PRIMARY);
		}
	} else {
		// If we're in the grenade slot, go down
		if (pSeat->iHUDGrenadesSelected == WEAPON_HEGRENADE) {
			// Do we have a flash bang? If yes, select that thing
			if (getstati_punf(STAT_ITEM_FLASHBANG)) {
				pSeat->iHUDGrenadesSelected = WEAPON_FLASHBANG;
				return SLOT_GRENADE;
			} else if (getstati_punf(STAT_ITEM_SMOKEGRENADE)) {
				pSeat->iHUDGrenadesSelected = WEAPON_SMOKEGRENADE;
				return SLOT_GRENADE;
			} else if (getstatf(STAT_SLOT_GRENADE)) {
				pSeat->iHUDGrenadesSelected =  getstatf(STAT_SLOT_GRENADE);
				return SLOT_GRENADE;
			} 
		} else if (pSeat->iHUDGrenadesSelected == WEAPON_FLASHBANG) {
			if (getstati_punf(STAT_ITEM_SMOKEGRENADE)) {
				pSeat->iHUDGrenadesSelected = WEAPON_SMOKEGRENADE;
				return SLOT_GRENADE;
			} else if (getstatf(STAT_SLOT_GRENADE)) {
				pSeat->iHUDGrenadesSelected =  getstatf(STAT_SLOT_GRENADE);
				return SLOT_GRENADE;
			} 
		} else if (pSeat->iHUDGrenadesSelected == WEAPON_SMOKEGRENADE) {
			if (getstatf(STAT_SLOT_GRENADE)) {
				pSeat->iHUDGrenadesSelected =  getstatf(STAT_SLOT_GRENADE);
				return SLOT_GRENADE;
			} 
		} 

		if (getstatf(STAT_SLOT_C4BOMB)) {
			return SLOT_C4BOMB;
		} else {
			return HUD_DrawWeaponSelect_NextItem(SLOT_C4BOMB);
		}
	}
}

/*
=================
HUD_DrawWeaponSelect_PreviousItem

Checks and returns the previous slot with a weapon in it
=================
*/
float HUD_DrawWeaponSelect_PreviousItem(float fSlot)
{
	if (fSlot == SLOT_PRIMARY) {
		if (getstatf(STAT_SLOT_C4BOMB)) {
			return SLOT_C4BOMB;
		} else {
			return HUD_DrawWeaponSelect_PreviousItem(SLOT_C4BOMB);
		}
	} else if (fSlot == SLOT_SECONDARY) {
		if (getstatf(STAT_SLOT_PRIMARY)) {
			return SLOT_PRIMARY;
		} else {
			return HUD_DrawWeaponSelect_PreviousItem(SLOT_PRIMARY);
		}
	} else if (fSlot == SLOT_MELEE) {
		if (getstatf(STAT_SLOT_SECONDARY)) {
			return SLOT_SECONDARY;
		} else {
			return HUD_DrawWeaponSelect_PreviousItem(SLOT_SECONDARY);
		}
	} else if (fSlot == SLOT_C4BOMB) {
		pSeat->iHUDGrenades = 0;

		/* See if we any any type of grenade in this slot */
		if (getstati_punf(STAT_ITEM_HEGRENADE)) {
			pSeat->iHUDGrenadesSelected = WEAPON_HEGRENADE;
			pSeat->iHUDGrenades++;
		} 
		if (getstati_punf(STAT_ITEM_FLASHBANG)) {
			pSeat->iHUDGrenadesSelected = WEAPON_FLASHBANG;
			pSeat->iHUDGrenades++;
		} 
		if (getstati_punf(STAT_ITEM_SMOKEGRENADE)) {
			pSeat->iHUDGrenadesSelected = WEAPON_SMOKEGRENADE;
			pSeat->iHUDGrenades++;
		}

		/* If we actually found a grenade, switch to the slot */
		if (pSeat->iHUDGrenades) {
			return SLOT_GRENADE;
		} else {
			return HUD_DrawWeaponSelect_PreviousItem(SLOT_GRENADE);
		}
	} else {
		if (pSeat->iHUDGrenadesSelected == WEAPON_SMOKEGRENADE) {
			if (getstati_punf(STAT_ITEM_FLASHBANG)) {
				pSeat->iHUDGrenadesSelected = WEAPON_FLASHBANG;
				return SLOT_GRENADE;
			} else if (getstati_punf(STAT_ITEM_HEGRENADE)) {
				pSeat->iHUDGrenadesSelected = WEAPON_HEGRENADE;
				return SLOT_GRENADE;
			} 
		} else if (pSeat->iHUDGrenadesSelected == WEAPON_FLASHBANG) {
			if (getstati_punf(STAT_ITEM_HEGRENADE)) {
				pSeat->iHUDGrenadesSelected = WEAPON_HEGRENADE;
				return SLOT_GRENADE;
			} 
		}

		if (getstatf(STAT_SLOT_MELEE)) {
			return SLOT_MELEE;
		} else {
			return HUD_DrawWeaponSelect_PreviousItem(SLOT_MELEE);
		}
	}
}

/*
=================
HUD_DrawWeaponSelect_GetWeapon

Returns what weapon is in which slot
=================
*/
float HUD_DrawWeaponSelect_GetWeapon(float fSlot)
{
	if (fSlot == SLOT_PRIMARY) {
		return getstatf(STAT_SLOT_PRIMARY);
	} else if (fSlot == SLOT_SECONDARY) {
		return getstatf(STAT_SLOT_SECONDARY);
	} else if (fSlot == SLOT_MELEE) {
		return getstatf(STAT_SLOT_MELEE);
	} else if (fSlot == SLOT_C4BOMB) {
		return getstatf(STAT_SLOT_C4BOMB);
	} else {
		return pSeat->iHUDGrenadesSelected;
	}
}

/*
=================
HUD_DrawWeaponSelect_Forward

Called via the invprev command
=================
*/
void HUD_DrawWeaponSelect_Forward(void)
{
	if (!getstatf(STAT_SLOT_MELEE)) {
		return;
	}
	
	if (pSeat->fHUDWeaponSelected == 0) {
		sound(self, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
		pSeat->fHUDWeaponSelected = HUD_DrawWeaponSelect_GetWeapon(HUD_DrawWeaponSelect_NextItem(wptTable[getstatf(STAT_ACTIVEWEAPON)].iSlot));
	} else {
		sound(self, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
		pSeat->fHUDWeaponSelected = HUD_DrawWeaponSelect_GetWeapon(HUD_DrawWeaponSelect_NextItem(wptTable[pSeat->fHUDWeaponSelected].iSlot));
	}
	
	pSeat->fHUDWeaponSelectTime = time + 3;
}

/*
=================
HUD_DrawWeaponSelect_Back

Called via the invnext command
=================
*/
void HUD_DrawWeaponSelect_Back(void)
{
	if (!getstatf(STAT_SLOT_MELEE)) {
		return;
	}
	
	if (pSeat->fHUDWeaponSelected == 0) {
		sound(self, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
		pSeat->fHUDWeaponSelected = HUD_DrawWeaponSelect_GetWeapon(HUD_DrawWeaponSelect_PreviousItem(wptTable[getstatf(STAT_ACTIVEWEAPON)].iSlot));
	} else {
		sound(self, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
		pSeat->fHUDWeaponSelected = HUD_DrawWeaponSelect_GetWeapon(HUD_DrawWeaponSelect_PreviousItem(wptTable[pSeat->fHUDWeaponSelected].iSlot));
	}
	
	pSeat->fHUDWeaponSelectTime = time + 3;
}

/*
=================
HUD_DrawWeaponSelect_Num

Draws the numbers 1-4 on the selection display
=================
*/
void HUD_DrawWeaponSelect_Num(vector vPos, float fValue)
{
	drawsubpic(vPos, [20,20], "sprites/640hud7.spr_0.tga", vHUDSlotNumPos[fValue], [0.078125, 0.078125], vHUDColor, 1, DRAWFLAG_ADDITIVE);
}

/*
=================
HUD_DrawWeaponSelect

Drawn every frame through HUD.c
=================
*/
void HUD_DrawWeaponSelect(void)
{	
	if (pSeat->fHUDWeaponSelectTime < time) {
		if (pSeat->fHUDWeaponSelected) {
			sound(self, CHAN_ITEM, "common/wpn_hudoff.wav", 0.5, ATTN_NONE);
			pSeat->fHUDWeaponSelected = 0;
		}
		return;
	}
	
	vector vSelectPos = vVideoMins + [160,12];
	
	for (int i = 0; i < 5; i++) {
		vSelectPos[1] = vVideoMins[1] + 12;
		HUD_DrawWeaponSelect_Num(vSelectPos, i);
		
		// Again, grenades are treated seperately
		if (i == SLOT_GRENADE) {
			int ihasnade = FALSE;
			if (wptTable[pSeat->fHUDWeaponSelected].iSlot == SLOT_GRENADE) {
				if (getstati_punf(STAT_ITEM_HEGRENADE)) {
					drawsubpic(vSelectPos + [0,20], [170,45], wpSymbolTable[WEAPON_HEGRENADE].sSprite, wpSymbolTable[WEAPON_HEGRENADE].vOrigin, [0.6640625, 0.17578125], vHUDColor, 1, DRAWFLAG_ADDITIVE);
					if (pSeat->iHUDGrenadesSelected == WEAPON_HEGRENADE) {
						drawsubpic(vSelectPos + [0,20], [170,45], "sprites/640hud3.spr_0.tga", [0,0.703125], [0.6640625, 0.17578125], vHUDColor, 1, DRAWFLAG_ADDITIVE);
					}
					vSelectPos_y += 45;
					ihasnade = TRUE;
				}
				if (getstati_punf(STAT_ITEM_FLASHBANG)) {
					drawsubpic(vSelectPos + [0,20], [170,45], wpSymbolTable[WEAPON_FLASHBANG].sSprite, wpSymbolTable[WEAPON_FLASHBANG].vOrigin, [0.6640625, 0.17578125], vHUDColor, 1, DRAWFLAG_ADDITIVE);
					if (pSeat->iHUDGrenadesSelected == WEAPON_FLASHBANG) {
						drawsubpic(vSelectPos + [0,20], [170,45], "sprites/640hud3.spr_0.tga", [0,0.703125], [0.6640625, 0.17578125], vHUDColor, 1, DRAWFLAG_ADDITIVE);
					}
					vSelectPos_y += 45;
					ihasnade = TRUE;
				}
				if (getstati_punf(STAT_ITEM_SMOKEGRENADE)) {
					drawsubpic(vSelectPos + [0,20], [170,45], wpSymbolTable[WEAPON_SMOKEGRENADE].sSprite, wpSymbolTable[WEAPON_SMOKEGRENADE].vOrigin, [0.6640625, 0.17578125], vHUDColor, 1, DRAWFLAG_ADDITIVE);
					if (pSeat->iHUDGrenadesSelected == WEAPON_SMOKEGRENADE) {
						drawsubpic(vSelectPos + [0,20], [170,45], "sprites/640hud3.spr_0.tga", [0,0.703125], [0.6640625, 0.17578125], vHUDColor, 1, DRAWFLAG_ADDITIVE);
					}
					vSelectPos_y += 45;
					ihasnade = TRUE;
				}
			}
			if (ihasnade) {
				vSelectPos_x += 170;
			} else {
				vSelectPos_x += 20;
			}
		} else {
			if (wptTable[pSeat->fHUDWeaponSelected].iSlot == i) {
				drawsubpic(vSelectPos + [0,20], [170,45], wpSymbolTable[pSeat->fHUDWeaponSelected].sSprite, wpSymbolTable[pSeat->fHUDWeaponSelected].vOrigin, [0.6640625, 0.17578125], vHUDColor, 1, DRAWFLAG_ADDITIVE);
				drawsubpic(vSelectPos + [0,20], [170,45], "sprites/640hud3.spr_0.tga", [0,0.703125], [0.6640625, 0.17578125], vHUDColor, 1, DRAWFLAG_ADDITIVE);
				vSelectPos_x += 170;
			} else {
				vSelectPos_x += 20;
			}
		}
	}
}


var float fHUDWeaponLast;
/*
=================
HUD_DrawWeaponSelect_Trigger

Called by CSQC_Input_Frame when conditions are met
=================
*/
void HUD_DrawWeaponSelect_Trigger(void)
{
	fHUDWeaponLast = getstatf(STAT_ACTIVEWEAPON);
	sendevent("PlayerSwitchWeapon", "f", pSeat->fHUDWeaponSelected);
	sound(self, CHAN_ITEM, "common/wpn_select.wav", 0.5f, ATTN_NONE);
	pSeat->fHUDWeaponSelectTime = 0;
	pSeat->fHUDWeaponSelected = 0;
}

/*
=================
HUD_DrawWeaponSelect_Last

Returns the last weapon we've used
=================
*/
void HUD_DrawWeaponSelect_Last(void)
{
	sendevent("PlayerSwitchWeapon", "f", fHUDWeaponLast);
	fHUDWeaponLast = getstatf(STAT_ACTIVEWEAPON);
}
