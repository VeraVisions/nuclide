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

/*
=================
CSQC_ConsoleCommand_Init

Init all the cmds in one place
=================
*/
void CSQC_ConsoleCommand_Init(void)
{
	registercommand("slot1");
	registercommand("slot2");
	registercommand("slot3");
	registercommand("slot4");
	registercommand("slot5");
	registercommand("slot6");
	registercommand("slot7");
	registercommand("slot8");
	registercommand("slot9");
	registercommand("slot10");
	
	registercommand("dev_testorbituary");
	registercommand("minimap");
	registercommand("overview_test");
	registercommand("vox_test");
	registercommand("+attack2");
	registercommand("-attack2");
	registercommand("+reload");
	registercommand("-reload");
	registercommand("+use");
	registercommand("-use");
	registercommand("+duck");
	registercommand("-duck");
	
	registercommand("buy");
	registercommand("chooseteam");
	registercommand("lastinv");
	registercommand("invnext");
	registercommand("invprev");
	registercommand("+showscores");
	registercommand("-showscores");
	registercommand("nightvision");
	registercommand("drop");
	
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
float CSQC_ConsoleCommand(string sCMD) {
	int s = (float)getproperty(VF_ACTIVESEAT);	//the engine will hide the p1 etc commands... which is fun...
	pSeat = &seats[s];
	
	tokenize(sCMD);

	switch (argv(0)) {
	case "lastinv":
		HUD_DrawWeaponSelect_Last();
		break;
	case "slot1":
		localcmd("impulse 1\n");
		break;
	case "slot2":
		localcmd("impulse 2\n");
		break;
	case "slot3":
		localcmd("impulse 3\n");
		break;
	case "slot4":
		localcmd("impulse 4\n");
		break;
	case "slot5":
		localcmd("impulse 5\n");
		break;
	case "slot6":
		localcmd("impulse 6\n");
		break;
	case "slot7":
		localcmd("impulse 7\n");
		break;
	case "slot8":
		localcmd("impulse 8\n");
		break;
	case "slot9":
		localcmd("impulse 9\n");
		break;
	case "slot10":
		localcmd("impulse 10\n");
		break;
	case "dev_testorbituary":
		HUD_AddOrbituaries(player_localnum, TEAM_T, player_localnum, TEAM_CT, floor(random(1, CS_WEAPON_COUNT)), FALSE);
		break;
	case "minimap":
		pSeat.iMapExpand = 1 - pSeat.iMapExpand;
		break;
	case "overview_test":
		pSeat.iOverview = 1 - pSeat.iOverview;
		break;
	case "vox_test":
		Sound_PlayVOX(sCMD);
		break;
	case "+attack2":
		iInputAttack2 = TRUE;
		break;
	case "-attack2":
		iInputAttack2 = FALSE;
		break;
	case "+reload":
		iInputReload = TRUE;
		break;
	case "-reload":
		iInputReload = FALSE;
		break;
	case "+use":
		iInputUse = TRUE;
		break;
	case "-use":
		iInputUse = FALSE;
		break;
	case "+duck":
		iInputDuck = TRUE;
		break;
	case "-duck":
		iInputDuck = FALSE;
		break;
	case "buy":
		if(getstatf(STAT_BUYZONE) == TRUE) {
			pSeat->fVGUI_Display = VGUI_BM_MAIN;
		}
		break;
	case "chooseteam":
		pSeat->fVGUI_Display = VGUI_TEAMSELECT;
		break;
	case "invnext":
		HUD_DrawWeaponSelect_Back();
		break;
	case "invprev":
		HUD_DrawWeaponSelect_Forward();
		break;
	case "+showscores":
		pSeat->iShowScores = TRUE;
		break;
	case "-showscores":
		pSeat->iShowScores = FALSE;
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
		VGUI_Radio_Toggle(VGUI_RADIO1);
		break;
	case "radio2":
		VGUI_Radio_Toggle(VGUI_RADIO2);
		break;
	case "radio3":
		VGUI_Radio_Toggle(VGUI_RADIO3);
		break;
	default:
		return FALSE;
	}
	return TRUE;
}

/*
=================
CSQC_Parse_Event

Whenever we call a SVC_CGAMEPACKET on the SSQC, this is being run
=================
*/
void CSQC_Parse_Event(void) {
	int s = (float)getproperty(VF_ACTIVESEAT);	//always 0, unless it was sent with a MULTICAST_ONE or MULTICAST_ONE_R to p2+
	pSeat = &seats[s];
	
	float fHeader = readbyte();
	
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
	} else if (fHeader == EV_MODELGIB) {
		vector vPos;
		vPos_x = readcoord();
		vPos_y = readcoord();
		vPos_z = readcoord();
		
		vector vSize;
		vSize_x = readcoord();
		vSize_y = readcoord();
		vSize_z = readcoord();

		float fStyle = readbyte();
		Effect_BreakModel(vPos, vSize, '0 0 0', fStyle);
	} else if (fHeader == EV_CAMERATRIGGER) {
		pSeat->vCameraPos.x = readcoord();
		pSeat->vCameraPos.y = readcoord();
		pSeat->vCameraPos.z = readcoord();

		pSeat->vCameraAngle.x = readcoord();
		pSeat->vCameraAngle.y = readcoord();
		pSeat->vCameraAngle.z = readcoord();
		
		pSeat->fCameraTime = time + readfloat();
	} else if (fHeader == EV_RADIOMSG) {
		Radio_PlayMessage(readbyte());
	} else if (fHeader == EV_RADIOMSG2) {
		Radio_PlayPlayerMessage(readbyte(), readbyte());
	} else if (fHeader == EV_ORBITUARY) {
		HUD_AddOrbituaries(readbyte(), readbyte(), readbyte(), readbyte(), readbyte(), readbyte());
	} else if (fHeader == EV_IMPACT) {
		int iType;
		vector vOrigin, vNormal;
		
		iType = (int)readbyte();
		vOrigin_x = readcoord();
		vOrigin_y = readcoord();
		vOrigin_z = readcoord();

		vNormal_x = readcoord();
		vNormal_y = readcoord();
		vNormal_z = readcoord();
		
		Effect_Impact(iType, vOrigin, vNormal);
	} else if (fHeader == EV_EXPLOSION) {
		vector vExploPos;
		
		vExploPos_x = readcoord();
		vExploPos_y = readcoord();
		vExploPos_z = readcoord();
		
		Effect_CreateExplosion(vExploPos);
	} else if (fHeader == EV_SPARK) {
		vector vSparkPos, vSparkAngle;
		
		vSparkPos_x = readcoord();
		vSparkPos_y = readcoord();
		vSparkPos_z = readcoord();
		
		vSparkAngle_x = readcoord();
		vSparkAngle_y = readcoord();
		vSparkAngle_z = readcoord();
		
		Effect_CreateSpark(vSparkPos, vSparkAngle);
	} else if (fHeader == EV_SMOKE) {
		vector vSmokePos;
		
		vSmokePos_x = readcoord();
		vSmokePos_y = readcoord();
		vSmokePos_z = readcoord();

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
	} else if (fHeader == EV_FADE) {
		Fade_Parse();
	} else if (fHeader == EV_SPRITE) {
		Sprite_ParseEvent();
	} else if (fHeader == EV_TEXT) {
		GameText_Parse();
	} else if (fHeader == EV_MESSAGE) {
		GameMessage_Parse();
	}
}

/*
=================
CSQC_InputEvent

Updates all our input related globals for use in other functions
=================
*/
float CSQC_InputEvent(float fEventType, float fKey, float fCharacter, float fDeviceID) {
	switch(fEventType) {
		case IE_KEYDOWN:
			if (fKey == K_MOUSE1) {
				fMouseClick = 1;
			} else {
				fInputKeyDown = 1;
			}

			fInputKeyCode = fKey;
			fInputKeyASCII = fCharacter;
			break;
		case IE_KEYUP:
			if (fKey == K_MOUSE1) {
				fMouseClick = 0;
			} else {
				fInputKeyDown = 0;
			}
			fInputKeyCode = 0;
			fInputKeyASCII = 0;
			break;
		case IE_MOUSEABS:
			vMousePos_x = fKey;
			vMousePos_y = fCharacter;
			break;
		case IE_MOUSEDELTA:
			vMousePos_x += fKey;
			vMousePos_y += fCharacter;
			
			if (vMousePos_x < 0) {
				vMousePos_x = 0;
			} else if (vMousePos_x > vVideoResolution_x) {
				vMousePos_x = vVideoResolution_x;
			}
			
			if (vMousePos_y < 0) {
				vMousePos_y = 0;
			} else if (vMousePos_y > vVideoResolution_y) {
				vMousePos_y = vVideoResolution_y;
			}
			break;
		default:
			return TRUE;
	}
	return FALSE;
}

/*
=================
CSQC_Input_Frame

Hijacks and controls what input globals are being sent to the server
=================
*/
void CSQC_Input_Frame(void) {
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];
	
	// If we are inside a VGUI, don't let the client do stuff outside
	if ((pSeat->fVGUI_Display != VGUI_NONE)) {
		fInputSendNext = time + 0.2;
	} else if ((pSeat->fHUDWeaponSelected) && (input_buttons & INPUT_BUTTON0)) {
		HUD_DrawWeaponSelect_Trigger();
		input_buttons = 0;
		fInputSendNext = time + 0.2;
	}
	
	if (fInputSendNext > time) {
		input_impulse = 0;
		input_buttons = 0;
		return;
	}
	
	if (input_impulse == 101) {
		print("This aint Half-Life.\n");
		input_impulse = 0;
	}
	
	if (input_impulse == 201) {
		sendevent("Spraylogo", "");
	}
	
	if (iInputAttack2 == TRUE) {
		input_buttons |= INPUT_BUTTON3;
	} 

	if (iInputReload == TRUE) {
		input_buttons |= INPUT_BUTTON4;
	} 
	
	if (iInputUse == TRUE) {
		input_buttons |= INPUT_BUTTON5;
	} 
	
	if (iInputDuck == TRUE) {
		input_buttons |= INPUT_BUTTON8;
	}
	
	input_angles += pSeat->vPunchAngle;
}
