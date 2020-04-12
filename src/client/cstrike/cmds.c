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

int
Game_ConsoleCommand(void)
{
	switch(argv(0)) {
	case "chooseteam":
		Textmenu_Call("TEAM_SELECT");
		break;
	case "buy":
		Textmenu_Call("BUY");
		break;
	case "radio1":
		Textmenu_Call("RADIOA");
		break;
	case "radio2":
		Textmenu_Call("RADIOB");
		break;
	case "radio3":
		Textmenu_Call("RADIOC");
		break;
	case "motd":
		/*VGUI_MessageOfTheDay();*/
		break;
	case "buy":
		/*if (getstatf(STAT_BUYZONE) == TRUE) {
			VGUI_BuyMenu();
		}*/
		break;
	case "chooseteam":
		/*VGUI_ChooseTeam();*/
		break;
	case "nightvision":
		/*Nightvision_Toggle();*/
		break;
	case "drop":
		sendevent("WeaponDrop", "");
		break;
	case "glock":
		sendevent("PlayerBuyWeapon", "f", WEAPON_GLOCK18);
		break;
	case "usp":
		sendevent("PlayerBuyWeapon", "f", WEAPON_USP45);
		break;
	case "p228":
		sendevent("PlayerBuyWeapon", "f", WEAPON_P228);
		break;
	case "deagle":
		sendevent("PlayerBuyWeapon", "f", WEAPON_DEAGLE);
		break;
	case "fn57":
		sendevent("PlayerBuyWeapon", "f", WEAPON_FIVESEVEN);
		break;
	case "elites":
		sendevent("PlayerBuyWeapon", "f", WEAPON_ELITES);
		break;
	case "m3":
		sendevent("PlayerBuyWeapon", "f", WEAPON_M3);
		break;
	case "xm1014":
		sendevent("PlayerBuyWeapon", "f", WEAPON_XM1014);
		break;
	case "tmp":
		sendevent("PlayerBuyWeapon", "f", WEAPON_TMP);
		break;
	case "mac10":
		sendevent("PlayerBuyWeapon", "f", WEAPON_MAC10);
		break;
	case "mp5":
		sendevent("PlayerBuyWeapon", "f", WEAPON_MP5);
		break;
	case "ump45":
		sendevent("PlayerBuyWeapon", "f", WEAPON_UMP45);
		break;
	case "p90":
		sendevent("PlayerBuyWeapon", "f", WEAPON_P90);
		break;
	case "ak47":
		sendevent("PlayerBuyWeapon", "f", WEAPON_AK47);
		break;
	case "m4a1":
		sendevent("PlayerBuyWeapon", "f", WEAPON_M4A1);
		break;
	case "sg552":
		sendevent("PlayerBuyWeapon", "f", WEAPON_SG552);
		break;
	case "aug":
		sendevent("PlayerBuyWeapon", "f", WEAPON_AUG);
		break;
	case "scout":
		sendevent("PlayerBuyWeapon", "f", WEAPON_SCOUT);
		break;
	case "sg550":
		sendevent("PlayerBuyWeapon", "f", WEAPON_SG550);
		break;
	case "awp":
		sendevent("PlayerBuyWeapon", "f", WEAPON_AWP);
		break;
	case "g3sg1":
		sendevent("PlayerBuyWeapon", "f", WEAPON_G3SG1);
		break;
	case "m249":
		sendevent("PlayerBuyWeapon", "f", WEAPON_PARA);
		break;
	case "buyammo1":
	case "primammo":
		sendevent("GamePlayerBuyAmmo", "f", 0);
		break;
	case "buyammo2":
	case "secammo":
		sendevent("GamePlayerBuyAmmo", "f", 1);
		break;
	case "vest":
		sendevent("PlayerBuyEquipment", "f", 0);
		break;
	case "vesthelm":
		sendevent("PlayerBuyEquipment", "f", 1);
		break;
	case "flash":
		sendevent("PlayerBuyEquipment", "f", 2);
		break;
	case "hegren":
		sendevent("PlayerBuyEquipment", "f", 3);
		break;
	case "vsgren":
		sendevent("PlayerBuyEquipment", "f", 4);
		break;
	case "defuser":
		sendevent("PlayerBuyEquipment", "f", 5);
		break;
	case "nvg":
		sendevent("PlayerBuyEquipment", "f", 6);
		break;
	case "coverme":
		sendevent("Radio", "f", RADIO_CT_COVERME);
		break;
	case "takepoint":
		sendevent("Radio", "f", RADIO_CT_POINT);
		break;
	case "takepoint":
		sendevent("Radio", "f", RADIO_POSITION);
		break;
	case "regroup":
		sendevent("Radio", "f", RADIO_REGROUP);
		break;
	case "followme":
		sendevent("Radio", "f", RADIO_FOLLOWME);
		break;
	case "takingfire":
		sendevent("Radio", "f", RADIO_FIREASSIS);
		break;
	case "go":
		sendevent("Radio", "f", RADIO_GO);
		break;
	case "fallback":
		sendevent("Radio", "f", RADIO_FALLBACK);
		break;
	case "sticktog":
		sendevent("Radio", "f", RADIO_STICKTOG);
		break;
	case "getinpos":
		sendevent("Radio", "f", RADIO_COM_GETINPOS);
		break;
	case "stormfront":
		sendevent("Radio", "f", RADIO_STORMFRONT);
		break;
	case "report":
		sendevent("Radio", "f", RADIO_COM_REPORTIN);
		break;
	case "roger":
		sendevent("Radio", "f", RADIO_ROGER);
		break;
	case "enemyspot":
		sendevent("Radio", "f", RADIO_CT_ENEMYS);
		break;
	case "needbackup":
		sendevent("Radio", "f", RADIO_CT_BACKUP);
		break;
	case "sectorclear":
		sendevent("Radio", "f", RADIO_CLEAR);
		break;
	case "inposition":
		sendevent("Radio", "f", RADIO_CT_INPOS);
		break;
	case "reportingin":
		sendevent("Radio", "f", RADIO_CT_REPORTINGIN);
		break;
	case "getout":
		sendevent("Radio", "f", RADIO_GETOUT);
		break;
	case "negative":
		sendevent("Radio", "f", RADIO_NEGATIVE);
		break;
	case "enemydown":
		sendevent("Radio", "f", RADIO_ENEMYDOWN);
		break;
	default:
		return FALSE;
	}
	return TRUE;
}
