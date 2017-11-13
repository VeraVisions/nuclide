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

/*
=================
CSQC_ConsoleCommand_Init

Init all the cmds in one place
=================
*/
void CSQC_ConsoleCommand_Init( void ) {
	registercommand( "vox_test" );
	registercommand( "+attack2" );
	registercommand( "-attack2" );
	registercommand( "+reload" );
	registercommand( "-reload" );
	registercommand( "+use" );
	registercommand( "-use" );
	registercommand( "+duck" );
	registercommand( "-duck" );
	
	registercommand( "buy" );
	registercommand( "chooseteam" );
	registercommand( "invnext" );
	registercommand( "invprev" );
	registercommand( "+showscores" );
	registercommand( "-showscores" );
	registercommand( "nightvision" );
	registercommand( "drop" );
	
	registercommand( "radio1" );
	registercommand( "radio2" );
	registercommand( "radio3" );
	
	registercommand( "glock" );
	registercommand( "usp" );
	registercommand( "p228" );
	registercommand( "deagle" );
	registercommand( "fn57" );
	registercommand( "elites" );
	registercommand( "m3" );
	registercommand( "xm1014" );
	registercommand( "tmp" );
	registercommand( "mac10" );
	registercommand( "mp5" );
	registercommand( "ump45" );
	registercommand( "p90" );
	registercommand( "ak47" );
	registercommand( "m4a1" );
	registercommand( "sg552" );
	registercommand( "aug" );
	registercommand( "scout" );
	registercommand( "sg550" );
	registercommand( "awp" );
	registercommand( "g3sg1" );
	registercommand( "m249" );
	
	registercommand( "primammo" );
	registercommand( "secammo" );
	
	registercommand( "vest" );
	registercommand( "vesthelm" );
	registercommand( "flash" );
	registercommand( "hegren" );
	registercommand( "vsgren" );
	registercommand( "defuser" );
	registercommand( "nvg" );

	registercommand( "coverme" );
	registercommand( "takepoint" );
	registercommand( "holdpos" );
	registercommand( "regroup" );
	registercommand( "followme" );
	registercommand( "takingfire" );
	registercommand( "go" );
	registercommand( "fallback" );
	registercommand( "sticktog" );
	registercommand( "getinpos" );
	registercommand( "stormfront" );
	registercommand( "report" );
	registercommand( "roger" );
	registercommand( "enemyspot" );
	registercommand( "needbackup" );
	registercommand( "sectorclear" );
	registercommand( "inposition" );
	registercommand( "reportingin" );
	registercommand( "getout" );
	registercommand( "negative" );
	registercommand( "enemydown" );
}

/*
=================
CSQC_ConsoleCommand

Can interject cmds and create new ones
=================
*/
float CSQC_ConsoleCommand( string sCMD ) {
	tokenize( sCMD );
	switch ( argv(0) ) {
	case "vox_test":
		Sound_PlayVOX( sCMD );
		return TRUE;
		break;
	case "+attack2":
		iInputAttack2 = TRUE;
		return TRUE;
		break;
	case "-attack2":
		iInputAttack2 = FALSE;
		return TRUE;
		break;
	case "+reload":
		iInputReload = TRUE;
		return TRUE;
		break;
	case "-reload":
		iInputReload = FALSE;
		return TRUE;
		break;
	case "+use":
		iInputUse = TRUE;
		return TRUE;
		break;
	case "-use":
		iInputUse = FALSE;
		return TRUE;
		break;
	case "+duck":
		iInputDuck = TRUE;
		return TRUE;
		break;
	case "-duck":
		iInputDuck = FALSE;
		return TRUE;
		break;
	case "buy":
		if( getstatf( STAT_BUYZONE ) == TRUE ) {
			fVGUI_Display = VGUI_BM_MAIN;
		}
		return TRUE;
		break;
    case "chooseteam":
		fVGUI_Display = VGUI_TEAMSELECT;
		return TRUE;
		break;
	case "invnext":
		HUD_DrawWeaponSelect_Back();
		return TRUE;
		break;
	case "invprev":
		HUD_DrawWeaponSelect_Forward();
		return TRUE;
		break;
	case "+showscores":
		iShowScores = TRUE;
		return TRUE;
		break;
	case "-showscores":
		iShowScores = FALSE;
		return TRUE;
		break;
	case "nightvision":
		Nightvision_Toggle();
		return TRUE;
		break;
	case "drop":
		sendevent( "WeaponDrop", "" );
		return TRUE;
		break;
	case "glock":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_GLOCK18 );
		return TRUE;
		break;
	case "usp":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_USP45 );
		return TRUE;
		break;
	case "p228":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_P228 );
		return TRUE;
		break;
	case "deagle":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_DEAGLE );
		return TRUE;
		break;
	case "fn57":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_FIVESEVEN );
		return TRUE;
		break;
	case "elites":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_ELITES );
		return TRUE;
		break;
	case "m3":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_M3 );
		return TRUE;
		break;
	case "xm1014":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_XM1014 );
		return TRUE;
		break;
	case "tmp":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_TMP );
		return TRUE;
		break;
	case "mac10":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_MAC10 );
		return TRUE;
		break;
	case "mp5":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_MP5 );
		return TRUE;
		break;
	case "ump45":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_UMP45 );
		return TRUE;
		break;
	case "p90":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_P90 );
		return TRUE;
		break;
	case "ak47":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_AK47 );
		return TRUE;
		break;
	case "m4a1":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_M4A1 );
		return TRUE;
		break;
	case "sg552":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_SG552 );
		return TRUE;
		break;
	case "aug":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_AUG );
		return TRUE;
		break;
	case "scout":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_SCOUT );
		return TRUE;
		break;
	case "sg550":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_SG550 );
		return TRUE;
		break;
	case "awp":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_AWP );
		return TRUE;
		break;
	case "g3sg1":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_G3SG1 );
		return TRUE;
		break;
	case "m249":
		sendevent( "PlayerBuyWeapon", "f", WEAPON_PARA );
		return TRUE;
		break;
	case "primammo":
		sendevent( "GamePlayerBuyAmmo", "f", 0 );
		return TRUE;
		break;
	case "secammo":
		sendevent( "GamePlayerBuyAmmo", "f", 1 );
		return TRUE;
		break;
	case "vest":
		sendevent( "PlayerBuyEquipment", "f", 0 );
		return TRUE;
		break;
	case "vesthelm":
		sendevent( "PlayerBuyEquipment", "f", 1 );
		return TRUE;
		break;
	case "flash":
		sendevent( "PlayerBuyEquipment", "f", 2 );
		return TRUE;
		break;
	case "hegren":
		sendevent( "PlayerBuyEquipment", "f", 3 );
		return TRUE;
		break;
	case "vsgren":
		sendevent( "PlayerBuyEquipment", "f", 4 );
		return TRUE;
		break;
	case "defuser":
		sendevent( "PlayerBuyEquipment", "f", 5 );
		return TRUE;
		break;
	case "nvg":
		sendevent( "PlayerBuyEquipment", "f", 6 );
		return TRUE;
		break;
	case "coverme":
		sendevent( "RadioMessage", "f", RADIO_CT_COVERME );
		return TRUE;
		break;
	case "takepoint":
		sendevent( "RadioMessage", "f", RADIO_CT_POINT );
		return TRUE;
		break;
	case "takepoint":
		sendevent( "RadioMessage", "f", RADIO_POSITION );
		return TRUE;
		break;
	case "regroup":
		sendevent( "RadioMessage", "f", RADIO_REGROUP );
		return TRUE;
		break;
	case "followme":
		sendevent( "RadioMessage", "f", RADIO_FOLLOWME );
		return TRUE;
		break;
	case "takingfire":
		sendevent( "RadioMessage", "f", RADIO_FIREASSIS );
		return TRUE;
		break;
	case "go":
		sendevent( "RadioMessage", "f", RADIO_GO );
		return TRUE;
		break;
	case "fallback":
		sendevent( "RadioMessage", "f", RADIO_FALLBACK );
		return TRUE;
		break;
	case "sticktog":
		sendevent( "RadioMessage", "f", RADIO_STICKTOG );
		return TRUE;
		break;
	case "getinpos":
		sendevent( "RadioMessage", "f", RADIO_COM_GETINPOS );
		return TRUE;
		break;
	case "stormfront":
		sendevent( "RadioMessage", "f", RADIO_STORMFRONT );
		return TRUE;
		break;
	case "report":
		sendevent( "RadioMessage", "f", RADIO_COM_REPORTIN );
		return TRUE;
		break;
	case "roger":
		sendevent( "RadioMessage", "f", RADIO_ROGER );
		return TRUE;
		break;
	case "enemyspot":
		sendevent( "RadioMessage", "f", RADIO_CT_ENEMYS );
		return TRUE;
		break;
	case "needbackup":
		sendevent( "RadioMessage", "f", RADIO_CT_BACKUP );
		return TRUE;
		break;
	case "sectorclear":
		sendevent( "RadioMessage", "f", RADIO_CLEAR );
		return TRUE;
		break;
	case "inposition":
		sendevent( "RadioMessage", "f", RADIO_CT_INPOS );
		return TRUE;
		break;
	case "reportingin":
		sendevent( "RadioMessage", "f", RADIO_CT_REPORTINGIN );
		return TRUE;
		break;
	case "getout":
		sendevent( "RadioMessage", "f", RADIO_GETOUT );
		return TRUE;
		break;
	case "negative":
		sendevent( "RadioMessage", "f", RADIO_NEGATIVE );
		return TRUE;
		break;
	case "enemydown":
		sendevent( "RadioMessage", "f", RADIO_ENEMYDOWN );
		return TRUE;
		break;
	case "radio1":
		VGUI_Radio_Toggle( VGUI_RADIO1 );
		return TRUE;
		break;
	case "radio2":
		VGUI_Radio_Toggle( VGUI_RADIO2 );
		return TRUE;
		break;
	case "radio3":
		VGUI_Radio_Toggle( VGUI_RADIO3 );
		return TRUE;
		break;
	}
	return FALSE;
}

/*
=================
CSQC_Parse_Event

Whenever we call a SVC_CGAMEPACKET on the SSQC, this is being run
=================
*/
void CSQC_Parse_Event( void ) {
	float fHeader = readbyte();
	
	if ( fHeader == EV_WEAPON_DRAW ) {
		fWeaponEventPlayer = readbyte();
		Weapon_Draw( getstatf( STAT_ACTIVEWEAPON ) );
	} else if ( fHeader == EV_WEAPON_PRIMARYATTACK ) {
		fWeaponEventPlayer = readbyte();
		Weapon_PrimaryAttack( getstatf( STAT_ACTIVEWEAPON ) );
	} else if ( fHeader == EV_WEAPON_SECONDARYATTACK ) {
		Weapon_SecondaryAttack( getstatf( STAT_ACTIVEWEAPON ) );
		fWeaponEventPlayer = readbyte();
	} else if ( fHeader == EV_WEAPON_RELOAD ) {
		fWeaponEventPlayer = readbyte();
		Weapon_Reload( getstatf( STAT_ACTIVEWEAPON ) );
	} else if ( fHeader == EV_MODELGIB ) {
		vector vPos;
		vPos_x = readcoord();
		vPos_y = readcoord();
		vPos_z = readcoord();
		
		vector vSize;
		vSize_x = readcoord();
		vSize_y = readcoord();
		vSize_z = readcoord();

		float fStyle = readbyte();
		Effect_BreakModel( vPos, vSize, '0 0 0', fStyle );
	} else if ( fHeader == EV_CAMERATRIGGER ) {
		vCameraPos_x = readcoord();
		vCameraPos_y = readcoord();
		vCameraPos_z = readcoord();

		vCameraAngle_x = readcoord();
		vCameraAngle_y = readcoord();
		vCameraAngle_z = readcoord();
		
		fCameraTime = time + readfloat();
	} else if ( fHeader == EV_RADIOMSG ) {
		Radio_PlayMessage( readbyte() );
	} else if ( fHeader == EV_RADIOMSG2 ) {
		Radio_PlayPlayerMessage( readbyte(), readbyte() );
	} else if ( fHeader == EV_ORBITUARY ) {
		HUD_AddOrbituaries( readbyte(), readbyte(), readbyte(), readbyte(), readbyte(), readbyte());
	} else if ( fHeader == EV_IMPACT ) {
		int iType;
		vector vOrigin, vNormal;
		
		iType = (int)readbyte();
		vOrigin_x = readcoord();
		vOrigin_y = readcoord();
		vOrigin_z = readcoord();

		vNormal_x = readcoord();
		vNormal_y = readcoord();
		vNormal_z = readcoord();
		
		Effect_Impact( iType, vOrigin, vNormal );
	} else if ( fHeader == EV_EXPLOSION ) {
		vector vExploPos;
		
		vExploPos_x = readcoord();
		vExploPos_y = readcoord();
		vExploPos_z = readcoord();
		
		Effect_CreateExplosion( vExploPos );
	} else if ( fHeader == EV_SPARK ) {
		vector vSparkPos, vSparkAngle;
		
		vSparkPos_x = readcoord();
		vSparkPos_y = readcoord();
		vSparkPos_z = readcoord();
		
		vSparkAngle_x = readcoord();
		vSparkAngle_y = readcoord();
		vSparkAngle_z = readcoord();
		
		Effect_CreateSpark( vSparkPos, vSparkAngle );
	} else if ( fHeader == EV_SMOKE ) {
		vector vSmokePos;
		
		vSmokePos_x = readcoord();
		vSmokePos_y = readcoord();
		vSmokePos_z = readcoord();

		Effect_CreateSmoke( vSmokePos );
	} else if ( fHeader == EV_FLASH ) {
		fFlashTime = 3.0f;
		fFlashAlpha = 1.0f;
	} else if ( fHeader == EV_CHAT ) {
		float fSender = readbyte();
		float fTeam = readbyte();
		string sMessage = readstring();
		
		CSQC_Parse_Print( sprintf( "%s%s^xF80: %s", HUD_GetChatColorHEX( fTeam ), getplayerkeyvalue( fSender, "name" ), sMessage ), PRINT_CHAT );
	} else if ( fHeader == EV_CHAT_TEAM ) {
		float fSender2 = readbyte();
		float fTeam2 = readbyte();
		string sMessage2 = readstring();
		
		CSQC_Parse_Print( sprintf( "%s%s^xF80: %s", HUD_GetChatColorHEXTeam( fTeam2 ), getplayerkeyvalue( fSender2, "name" ), sMessage2 ), PRINT_CHAT );
	} else if ( fHeader == EV_CHAT_VOX ) {
		Sound_PlayVOX( readstring() );
	}
}

/*
=================
CSQC_InputEvent

Updates all our input related globals for use in other functions
=================
*/
float CSQC_InputEvent( float fEventType, float fKey, float fCharacter, float fDeviceID ) {
	if ( fEventType == IE_KEYDOWN ) {
		if ( fKey == K_MOUSE1 ) {
			fMouseClick = 1;
		} else {
			fInputKeyDown = 1;
		}

		fInputKeyCode = fKey;
		fInputKeyASCII = fCharacter;
	} else if ( fEventType == IE_KEYUP ) {
		if ( fKey == K_MOUSE1 ) {
			fMouseClick = 0;
		} else {
			fInputKeyDown = 0;
		}
		fInputKeyCode = 0;
		fInputKeyASCII = 0;
	} else if ( fEventType == IE_MOUSEABS ) {
		vMousePos_x = fKey;
		vMousePos_y = fCharacter;
	} else if ( fEventType == IE_MOUSEDELTA ) {
		vMousePos_x += fKey;
		vMousePos_y += fCharacter;
		
		if ( vMousePos_x < 0 ) {
			vMousePos_x = 0;
		} else if ( vMousePos_x > vVideoResolution_x ) {
			vMousePos_x = vVideoResolution_x;
		}
		
		if ( vMousePos_y < 0 ) {
			vMousePos_y = 0;
		} else if ( vMousePos_y > vVideoResolution_y ) {
			vMousePos_y = vVideoResolution_y;
		}
	} else {
		return FALSE;
	}
	return FALSE;
}

/*
=================
CSQC_Input_Frame

Hijacks and controls what input globals are being sent to the server
=================
*/
void CSQC_Input_Frame( void ) {
	// If we are inside a VGUI, don't let the client do stuff outside
	if ( ( fVGUI_Display != VGUI_NONE ) ) {
		fInputSendNext = time + 0.2;
	} else if ( ( fHUDWeaponSelected ) && ( input_buttons & INPUT_BUTTON0 ) ) {
		HUD_DrawWeaponSelect_Trigger();
		input_buttons = 0;
		fInputSendNext = time + 0.2;
	}
	
	if ( fInputSendNext > time ) {
		input_impulse = 0;
		input_buttons = 0;
		return;
	}
	
	if ( iInputAttack2 == TRUE ) {
		input_buttons |= INPUT_BUTTON5;
	} 

	if ( iInputReload == TRUE ) {
		input_buttons |= INPUT_BUTTON4;
	} 
	
	if ( iInputUse == TRUE ) {
		input_buttons |= INPUT_BUTTON3;
	} 
	
	if ( iInputDuck == TRUE ) {
		input_buttons |= INPUT_BUTTON6;
	} 
}
