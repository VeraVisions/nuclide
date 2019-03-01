/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

vector vHUDSlotNumPos[6] = {
	[168 / 255,72 / 128],
	[188 / 255,72 / 128],
	[208 / 255,72 / 128],
	[168 / 255,92 / 128],
	[188 / 255,92 / 128],
	[208 / 255,92 / 128]
};

void HUD_DrawWeaponSelect_Forward(void)
{
	player pl = (player)pSeat->ePlayer;
	
	if (!pl.activeweapon) {
		return;
	}
	
	if (pSeat->fHUDWeaponSelectTime < time) {
		pSeat->fHUDWeaponSelected = pl.activeweapon;
		sound(pSeat->ePlayer, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
	} else {
		sound(pSeat->ePlayer, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
		pSeat->fHUDWeaponSelected--;
		if (pSeat->fHUDWeaponSelected <= 0) {
			pSeat->fHUDWeaponSelected = g_weapons.length - 1;
		}
	}

	pSeat->fHUDWeaponSelectTime = time + 3;
	
	if (!(pl.items & g_weapons[pSeat->fHUDWeaponSelected].id)) {
		HUD_DrawWeaponSelect_Forward();
	}
}

void HUD_DrawWeaponSelect_Back(void)
{
	player pl = (player)pSeat->ePlayer;

	if (!pl.activeweapon) {
		return;
	}

	if (pSeat->fHUDWeaponSelectTime < time) {
		pSeat->fHUDWeaponSelected = pl.activeweapon;
		sound(pSeat->ePlayer, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
	} else {
		sound(pSeat->ePlayer, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
		pSeat->fHUDWeaponSelected++;
		if (pSeat->fHUDWeaponSelected >= g_weapons.length) {
			pSeat->fHUDWeaponSelected = 1;
		}
	}

	pSeat->fHUDWeaponSelectTime = time + 3;

	if (!(pl.items & g_weapons[pSeat->fHUDWeaponSelected].id)) {
		HUD_DrawWeaponSelect_Back();
	}
}

void HUD_DrawWeaponSelect_Trigger(void)
{
	sendevent("PlayerSwitchWeapon", "f", pSeat->fHUDWeaponSelected);
	sound(pSeat->ePlayer, CHAN_ITEM, "common/wpn_select.wav", 0.5f, ATTN_NONE);
	pSeat->fHUDWeaponSelected = pSeat->fHUDWeaponSelectTime = 0;
}

void HUD_DrawWeaponSelect_Last(void)
{
	
}

void HUD_DrawWeaponSelect_Num(vector vPos, float fValue)
{
	drawsubpic(vPos, [20,20], "sprites/640hud7.spr_0.tga", vHUDSlotNumPos[fValue], [20/255, 20/128], g_hud_color, 1, DRAWFLAG_ADDITIVE);
}

int Weapon_InSlotPos(int slot, int pos)
{
	player pl = (player)pSeat->ePlayer;
	for (int i = 1; i < g_weapons.length; i++) {
		if (g_weapons[i].slot == slot && g_weapons[i].slot_pos == pos) {
			if (pl.items & g_weapons[i].id) {
				return i;
			} else {
				return -1;
			}
		}
	}
	return -1;
}
void HUD_DrawWeaponSelect(void)
{
	player pl = (player)pSeat->ePlayer;
	if (!pl.activeweapon) {
		return;
	}
	if (pSeat->fHUDWeaponSelectTime < time) {
		if (pSeat->fHUDWeaponSelected) {
			sound(pSeat->ePlayer, CHAN_ITEM, "common/wpn_hudoff.wav", 0.5, ATTN_NONE);
			pSeat->fHUDWeaponSelected = 0;
		}
		return;
	}

	vector vSelectPos = video_mins + [16,16];

	int wantslot = g_weapons[pSeat->fHUDWeaponSelected].slot;
	int wantpos = g_weapons[pSeat->fHUDWeaponSelected].slot_pos;
	int b;
	for (int i = 0; i < 5; i++) {
		int slot_selected = 0;
		vSelectPos[1] = video_mins[1] + 16;
		HUD_DrawWeaponSelect_Num(vSelectPos, i);
		vSelectPos[1] += 20;
		for (int x = 0; x < 32; x++) {
			if (i == wantslot) {
				slot_selected = TRUE;
				if (x == wantpos) {
					// Selected Sprite
					Weapons_HUDPic(pSeat->fHUDWeaponSelected, 1, vSelectPos);
					drawsubpic(vSelectPos, [170,45], "sprites/640hud3.spr_0.tga", 
								[0,180/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
					vSelectPos[1] += 50;
				} else if ((b=Weapon_InSlotPos(i, x)) != -1) {
					// Unselected Sprite
					Weapons_HUDPic(b, 0, vSelectPos);
					vSelectPos[1] += 50;
				}
			} else if (Weapon_InSlotPos(i, x) != -1) {
				HUD_DrawWeaponSelect_Num(vSelectPos, 5);
				vSelectPos[1] += 25;
			}
		}
		
		if (slot_selected == TRUE) {
			vSelectPos[0] += 175;
		} else {
			vSelectPos[0] += 25;
		}
	}
}

