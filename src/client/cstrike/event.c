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

/*
=================
CSQC_ConsoleCommand_Init

Init all the cmds in one place
=================
*/
void CSQC_ConsoleCommand_Init(void)
{
	
	registercommand("dev_testorbituary");
	registercommand("minimap");
	registercommand("overview_test");
	
	registercommand("buy");
	registercommand("motd");
	registercommand("chooseteam");

	registercommand("drop");
	registercommand("nightvision");
	
	registercommand("radio1");
	registercommand("radio2");
	registercommand("radio3");
	
	registercommand("glock");
	registercommand("usp");
	registercommand("p228");
	registercommand("deagle");
	registercommand("fn57");
	registercommand("elites");
	registercommand("m3");
	registercommand("xm1014");
	registercommand("tmp");
	registercommand("mac10");
	registercommand("mp5");
	registercommand("ump45");
	registercommand("p90");
	registercommand("ak47");
	registercommand("m4a1");
	registercommand("sg552");
	registercommand("aug");
	registercommand("scout");
	registercommand("sg550");
	registercommand("awp");
	registercommand("g3sg1");
	registercommand("m249");
	
	registercommand("primammo");
	registercommand("buyammo1");
	registercommand("secammo");
	registercommand("buyammo2");
	
	registercommand("vest");
	registercommand("vesthelm");
	registercommand("flash");
	registercommand("hegren");
	registercommand("vsgren");
	registercommand("defuser");
	registercommand("nvg");

	registercommand("coverme");
	registercommand("takepoint");
	registercommand("holdpos");
	registercommand("regroup");
	registercommand("followme");
	registercommand("takingfire");
	registercommand("go");
	registercommand("fallback");
	registercommand("sticktog");
	registercommand("getinpos");
	registercommand("stormfront");
	registercommand("report");
	registercommand("roger");
	registercommand("enemyspot");
	registercommand("needbackup");
	registercommand("sectorclear");
	registercommand("inposition");
	registercommand("reportingin");
	registercommand("getout");
	registercommand("negative");
	registercommand("enemydown");
}

/*
=================
CSQC_ConsoleCommand

Can interject cmds and create new ones
=================
*/
float Game_ConsoleCommand(void)
{
	/* This has already been tokenized */
	switch (argv(0)) {
	case "dev_testorbituary":
		HUD_AddOrbituaries(player_localnum, TEAM_T, player_localnum, TEAM_CT, floor(random(1, CS_WEAPON_COUNT)), FALSE);
		break;
	case "minimap":
		pSeat.iMapExpand = 1 - pSeat.iMapExpand;
		break;
	case "overview_test":
		pSeat.iOverview = 1 - pSeat.iOverview;
		break;
	case "motd":
		VGUI_MessageOfTheDay();
		break;
	case "buy":
		if(getstatf(STAT_BUYZONE) == TRUE) {
			VGUI_BuyMenu();
		}
		break;
	case "chooseteam":
		VGUI_ChooseTeam();
		break;
	case "nightvision":
		Nightvision_Toggle();
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
		sendevent("RadioMessage", "f", RADIO_CT_COVERME);
		break;
	case "takepoint":
		sendevent("RadioMessage", "f", RADIO_CT_POINT);
		break;
	case "takepoint":
		sendevent("RadioMessage", "f", RADIO_POSITION);
		break;
	case "regroup":
		sendevent("RadioMessage", "f", RADIO_REGROUP);
		break;
	case "followme":
		sendevent("RadioMessage", "f", RADIO_FOLLOWME);
		break;
	case "takingfire":
		sendevent("RadioMessage", "f", RADIO_FIREASSIS);
		break;
	case "go":
		sendevent("RadioMessage", "f", RADIO_GO);
		break;
	case "fallback":
		sendevent("RadioMessage", "f", RADIO_FALLBACK);
		break;
	case "sticktog":
		sendevent("RadioMessage", "f", RADIO_STICKTOG);
		break;
	case "getinpos":
		sendevent("RadioMessage", "f", RADIO_COM_GETINPOS);
		break;
	case "stormfront":
		sendevent("RadioMessage", "f", RADIO_STORMFRONT);
		break;
	case "report":
		sendevent("RadioMessage", "f", RADIO_COM_REPORTIN);
		break;
	case "roger":
		sendevent("RadioMessage", "f", RADIO_ROGER);
		break;
	case "enemyspot":
		sendevent("RadioMessage", "f", RADIO_CT_ENEMYS);
		break;
	case "needbackup":
		sendevent("RadioMessage", "f", RADIO_CT_BACKUP);
		break;
	case "sectorclear":
		sendevent("RadioMessage", "f", RADIO_CLEAR);
		break;
	case "inposition":
		sendevent("RadioMessage", "f", RADIO_CT_INPOS);
		break;
	case "reportingin":
		sendevent("RadioMessage", "f", RADIO_CT_REPORTINGIN);
		break;
	case "getout":
		sendevent("RadioMessage", "f", RADIO_GETOUT);
		break;
	case "negative":
		sendevent("RadioMessage", "f", RADIO_NEGATIVE);
		break;
	case "enemydown":
		sendevent("RadioMessage", "f", RADIO_ENEMYDOWN);
		break;
	case "radio1":
		VGUI_RadioCommands();
		break;
	case "radio2":
		VGUI_RadioGroup();	
		break;
	case "radio3":
	 	VGUI_RadioResponse();	
		break;
	default:
		return FALSE;
	}
	return TRUE;
}

/*
=================
Game_Parse_Event

Whenever we call a SVC_CGAMEPACKET on the SSQC, this is being run
=================
*/
void Game_Parse_Event(float fHeader) {
	int s;
	if (fHeader == EV_WEAPON_DRAW) {
		fWeaponEventPlayer = readbyte();
		for (s = 0; s < numclientseats; s++)	//lame loop
			if (seats[s].ePlayer.entnum == fWeaponEventPlayer) {
				setproperty(VF_ACTIVESEAT, (float)s);
				pSeat = &seats[s];
				break;
			}
		Weapon_Draw(getstatf(STAT_ACTIVEWEAPON));
	} else if (fHeader == EV_WEAPON_PRIMARYATTACK) {
		fWeaponEventPlayer = readbyte();
		for (s = 0; s < numclientseats; s++)	//lame loop
			if (seats[s].ePlayer.entnum == fWeaponEventPlayer) {
				setproperty(VF_ACTIVESEAT, (float)s);
				pSeat = &seats[s];
				break;
			}
		Weapon_PrimaryAttack(getstatf(STAT_ACTIVEWEAPON));
	} else if (fHeader == EV_WEAPON_SECONDARYATTACK) {
		fWeaponEventPlayer = readbyte();
		for (s = 0; s < numclientseats; s++)	//lame loop
			if (seats[s].ePlayer.entnum == fWeaponEventPlayer) {
				setproperty(VF_ACTIVESEAT, (float)s);
				pSeat = &seats[s];
				break;
			}
		Weapon_SecondaryAttack(getstatf(STAT_ACTIVEWEAPON));
	} else if (fHeader == EV_WEAPON_RELOAD) {
		fWeaponEventPlayer = readbyte();
		for (s = 0; s < numclientseats; s++)	//lame loop
			if (seats[s].ePlayer.entnum == fWeaponEventPlayer) {
				setproperty(VF_ACTIVESEAT, (float)s);
				pSeat = &seats[s];
				break;
			}
		Weapon_Reload(getstatf(STAT_ACTIVEWEAPON));
	} else if (fHeader == EV_RADIOMSG) {
		Radio_PlayMessage(readbyte());
	} else if (fHeader == EV_RADIOMSG2) {
		Radio_PlayPlayerMessage(readbyte(), readbyte());
	} else if (fHeader == EV_OLDREMOVEME) {
		HUD_AddOrbituaries(readbyte(), readbyte(), readbyte(), readbyte(), readbyte(), readbyte());
	} else if (fHeader == EV_SMOKE) {
		vector vSmokePos;
		
		vSmokePos[0] = readcoord();
		vSmokePos[1] = readcoord();
		vSmokePos[2] = readcoord();

		Effect_CreateSmoke(vSmokePos);
	} else if (fHeader == EV_FLASH) {
		pSeat->fFlashTime = 3.0f;
		pSeat->fFlashAlpha = 1.0f;
	} else if (fHeader == EV_CHAT) {
		float fSender = readbyte();
		float fTeam = readbyte();
		string sMessage = readstring();
		
		CSQC_Parse_Print(sprintf("%s%s^xF80: %s", HUD_GetChatColorHEX(fTeam), getplayerkeyvalue(fSender, "name"), sMessage), PRINT_CHAT);
	} else if (fHeader == EV_CHAT_TEAM) {
		float fSender2 = readbyte();
		float fTeam2 = readbyte();
		string sMessage2 = readstring();
		
		CSQC_Parse_Print(sprintf("%s%s^xF80: %s", HUD_GetChatColorHEXTeam(fTeam2), getplayerkeyvalue(fSender2, "name"), sMessage2), PRINT_CHAT);
	} else if (fHeader == EV_CHAT_VOX) {
		Sound_PlayVOX(readstring());
	}
}
