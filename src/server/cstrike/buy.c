/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

int g_cstrikeWeaponPrice[] =
{
	WEAPON_NONE,
	WEAPON_M3,
	WEAPON_XM1014,
	WEAPON_MP5,
	WEAPON_P90,
	WEAPON_UMP45,
	WEAPON_MAC10,
	WEAPON_TMP,
	WEAPON_AK47,
	WEAPON_SG552,
	WEAPON_M4A1,
	WEAPON_AUG,
	WEAPON_SCOUT,
	WEAPON_AWP,
	WEAPON_G3SG1,
	WEAPON_SG550,
	WEAPON_PARA,
	WEAPON_USP45,
	WEAPON_GLOCK18,
	WEAPON_DEAGLE,
	WEAPON_P228,
	WEAPON_ELITES,
	WEAPON_FIVESEVEN,
	WEAPON_KNIFE,
	WEAPON_HEGRENADE,
	WEAPON_FLASHBANG,
	WEAPON_SMOKEGRENADE,
	WEAPON_C4BOMB
};

void
CSEv_BuyWeapon_f(float fWeapon)
{
	int iWeapon;
	player pl = (player)self;
	iWeapon = (int)fWeapon;

	if (Rules_BuyingPossible() == FALSE) {
		return;
	}

	if (pl.team == TEAM_T) {
		if (iWeapon == WEAPON_M4A1) { return; }
		if (iWeapon == WEAPON_AUG) { return; }
		if (iWeapon == WEAPON_SG550) { return; }
		if (iWeapon == WEAPON_FIVESEVEN) { return; }
		if (iWeapon == WEAPON_TMP) { return; }
	} else if (pl.team == TEAM_CT) {
		if (iWeapon == WEAPON_AK47) { return; }
		if (iWeapon == WEAPON_SG552) { return; }
		if (iWeapon == WEAPON_G3SG1) { return; }
		if (iWeapon == WEAPON_ELITES) { return; }
		if (iWeapon == WEAPON_MAC10) { return; }
	}

	if ((pl.money - g_cstrikeWeaponPrice[iWeapon]) >= 0) {
		Weapons_AddItem(pl, iWeapon);
		//Ammo_AutoFill(iWeapon);

		//Weapon_Draw(iWeapon);
		Money_AddMoney(pl, -g_cstrikeWeaponPrice[iWeapon]);
		
		sound(pl, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
	} else {
		//centerprint(pl, "You have insufficient funds!");
	}
} 
