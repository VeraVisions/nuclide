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

vector vHUDSlotNumPos[6] =
{
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

	if (!(pl.g_items & g_weapons[pSeat->fHUDWeaponSelected].id)) {
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

	if (!(pl.g_items & g_weapons[pSeat->fHUDWeaponSelected].id)) {
		HUD_DrawWeaponSelect_Back();
	}
}

void HUD_DrawWeaponSelect_Trigger(void)
{
	player pl = (player)pSeat->ePlayer;
	pl.activeweapon = pSeat->fHUDWeaponSelected;
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

int HUD_InSlotPos(int slot, int pos)
{
	player pl = (player)pSeat->ePlayer;
	for (int i = 1; i < g_weapons.length; i++) {
		if (g_weapons[i].slot == slot && g_weapons[i].slot_pos == pos) {
			if (pl.g_items & g_weapons[i].id) {
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

	vector vecPos = video_mins + [16,16];

	int b;
	int wantslot = g_weapons[pSeat->fHUDWeaponSelected].slot;
	int wantpos = g_weapons[pSeat->fHUDWeaponSelected].slot_pos;
	for (int i = 0; i < 5; i++) {
		int slot_selected = 0;
		vecPos[1] = video_mins[1] + 16;
		HUD_DrawWeaponSelect_Num(vecPos, i);
		vecPos[1] += 20;
		for (int x = 0; x < 32; x++) {
			if (i == wantslot) {
				slot_selected = TRUE;
				if (x == wantpos) {
					// Selected Sprite
					Weapons_HUDPic(pSeat->fHUDWeaponSelected, 1, vecPos);
					drawsubpic(vecPos, [170,45], "sprites/640hud3.spr_0.tga", 
								[0,180/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
					vecPos[1] += 50;
				} else if ((b=HUD_InSlotPos(i, x)) != -1) {
					// Unselected Sprite
					Weapons_HUDPic(b, 0, vecPos);
					vecPos[1] += 50;
				}
			} else if (HUD_InSlotPos(i, x) != -1) {
				HUD_DrawWeaponSelect_Num(vecPos, 5);
				vecPos[1] += 25;
			}
		}

		if (slot_selected == TRUE) {
			vecPos[0] += 175;
		} else {
			vecPos[0] += 25;
		}
	}
}
