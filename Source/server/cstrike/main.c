/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void SV_SendChat(entity eSender, string sMessage, entity eEnt, float fType)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, fType == 0 ? EV_CHAT:EV_CHAT_TEAM);
	WriteByte(MSG_MULTICAST, num_for_edict(eSender) - 1); 
	WriteByte(MSG_MULTICAST, eSender.team); 
	WriteString(MSG_MULTICAST, sMessage);

	if (eEnt) {
		msg_entity = eEnt;
		multicast([0,0,0], MULTICAST_ONE);
	} else {
		multicast([0,0,0], MULTICAST_ALL);
	}
}

/*
=================
SV_ParseClientCommand

Intercepts 'cmd' calls. We use it to intercept
chat messages and handle distribution ourselves.
=================
*/
void Game_ParseClientCommand(string sCommand)
{
	tokenize(sCommand);

	if (argv(1) == "timeleft") {
		float fTimeLeft = cvar("mp_timelimit") - (time / 60);
		Vox_Singlecast(self, sprintf("we have %s minutes remaining", Vox_TimeToString(fTimeLeft)));
		return;
	}

	// Players talk to players, spectators to spectators.
	if (self.health ) {
		if (argv(0) == "say") {
			localcmd(sprintf("echo %s: %s\n", self.netname, argv(1)));
			SV_SendChat(self, argv(1), world, 0);
			return;
		} else if (argv(0) == "say_team") {
			localcmd(sprintf("echo [TEAM %d] %s: %s\n", self.team, self.netname, argv(1)));
			for (entity eFind = world; (eFind = find(eFind, classname, "player"));) { 
				if (eFind.team == self.team) {
					SV_SendChat(self, argv(1), eFind, 1);
				}
			}
			return;
		} 
	} else {
		if (argv(0) == "say") {
			localcmd(sprintf("echo [DEAD] %s: %s\n", self.netname, argv(1)));
			for (entity eFind = world; (eFind = find(eFind, classname, "spectator"));) { 
				SV_SendChat(self, argv(1), eFind, 1);
			}
			return;	
		} else if (argv(0) == "say_team") {
			localcmd(sprintf("echo [DEAD] %s: %s\n", self.netname, argv(1)));
			return;
		} 
	}

	clientcommand(self, sCommand);
}

float Game_ConsoleCmd(string sCommand)
{
	tokenize(sCommand);
	switch (argv(0)) {
	case "vox":
		Vox_Broadcast(argv(1));
		break;
	default:
		return FALSE;
	}
	
	return TRUE;
}

void SV_PausedTic(float fDuration)
{

}

/*
=================
StartFrame

Runs every frame... by worldspawn?
=================
*/
void Game_StartFrame(void)
{
	// We've got hostages, but no rescue zones, create some
	if (!iRescueZones && iHostagesMax > 0) {
		Game_CreateRescueZones();
	}
		
	if (iBuyZones == 0) {
		Game_CreateBuyZones();
	}

	// TODO: Optimise this
	if ((iAlivePlayers_T + iAlivePlayers_CT) == 0) {
		int iInGamePlayers = 0;
		for (entity eFind = world; (eFind = find(eFind, classname, "player"));) {
			iInGamePlayers++;
		}
		
		if ((iInGamePlayers > 0) && (fGameState != GAME_COMMENCING && fGameState != GAME_END)) {
			Timer_Begin(2, GAME_COMMENCING);
		} else if (iInGamePlayers == 0) {
			fGameState = GAME_INACTIVE;
			fGameTime = 0;
			iWon_T = 0;
			iWon_CT = 0;
			iRounds = 0;
		} else {
			Timer_Update(); // Timer that happens once players have started joining
		}
	} else {
		Timer_Update(); // Normal gameplay timer
	}
}

/*
=================
worldspawn

It's the map entity, literally
=================
*/

void Game_Worldspawn(void)
{
	string sTemp;
	int iMOTDLines = 0;

	// The message of the day.
	localcmd(sprintf("echo [MOTD] Loading %s.\n", autocvar_motdfile));
	filestream fmMOTD = fopen(autocvar_motdfile, FILE_READ);
	
	if (fmMOTD >= 0) {
		for (int i = 0; i < 25; i++) {
			sTemp = fgets(fmMOTD);
			if not (sTemp) {
				break;
			} 
			
			if (sTemp == __NULL__) {
				localcmd(sprintf("serverinfo motdline%i /\n", iMOTDLines));
			} else {
				localcmd(sprintf("serverinfo motdline%i %s\n", iMOTDLines, sTemp));
			}
			iMOTDLines++;
		}
		localcmd(sprintf("serverinfo motdlength %i\n", iMOTDLines));
		fclose(fmMOTD);
	} else {
		error("[MOTD] Loading failed.\n");	
	}

	// The mapcycle information.
	localcmd(sprintf("echo [MAPCYCLE] Loading %s.\n", autocvar_mapcyclefile));
	filestream fmMapcycle = fopen(autocvar_mapcyclefile, FILE_READ);
	
	if (fmMapcycle >= 0) {
		for (int i = 0;; i++) {
			sTemp = fgets(fmMapcycle);
			if not (sTemp) {
				break;
			} 
			
			if (sTemp != __NULL__) {
				iMapCycleCount++;
			}
		}
		
		fseek(fmMapcycle, 0);
		localcmd(sprintf("echo [MAPCYCLE] List has %i maps.\n", iMapCycleCount));
		sMapCycle = memalloc(sizeof(string) * iMapCycleCount);
		for (int i = 0; i < iMapCycleCount; i++) {
			sMapCycle[i] = fgets(fmMapcycle);
		}
		fclose(fmMapcycle);
		
		for (int i = 0; i < iMapCycleCount; i++) {
			if (sMapCycle[i] == mapname) {
				if ((i + 1) < iMapCycleCount) {
					localcmd(sprintf("echo [MAPCYCLE] Next map: %s\n", sMapCycle[i + 1]));
				} else {
					break;
				}
			}
		}
	} else {
		iMapCycleCount = 0;
		error("[MAPCYCLE] Loading failed.\n");	
	}

	// Let's make our version information clear
	localcmd(sprintf("serverinfo fcs_ver %s\n", __DATE__));

	// All the important precaches
	for (int i = 1; i < CS_WEAPON_COUNT; i++) {
		precache_model(sWeaponModels[i]);
	}

	/*Bot_Init();*/

	precache_model("models/w_flashbang.mdl");
	precache_model("models/w_hegrenade.mdl");
	precache_model("models/w_smokegrenade.mdl");

	precache_model(sCSPlayers[1]);
	precache_model(sCSPlayers[2]);
	precache_model(sCSPlayers[3]);
	precache_model(sCSPlayers[4]);
	precache_model(sCSPlayers[5]);
	precache_model(sCSPlayers[6]);
	precache_model(sCSPlayers[7]);
	precache_model(sCSPlayers[8]);
	precache_model("models/player/vip/vip.mdl");
	precache_model("models/w_c4.mdl");

	precache_sound("hostage/hos1.wav");
	precache_sound("hostage/hos2.wav");
	precache_sound("hostage/hos3.wav");
	precache_sound("hostage/hos4.wav");
	precache_sound("hostage/hos5.wav");
	precache_sound("player/pl_pain2.wav");
	precache_sound("player/pl_pain4.wav");
	precache_sound("player/pl_pain5.wav");
	precache_sound("player/pl_pain6.wav");
	precache_sound("player/pl_pain7.wav");
	precache_sound("player/die1.wav");
	precache_sound("player/die2.wav");
	precache_sound("player/die3.wav");
	precache_sound("player/headshot1.wav");
	precache_sound("player/headshot2.wav");
	precache_sound("player/headshot3.wav");
	precache_sound("items/tr_kevlar.wav");
	precache_sound("weapons/ak47-1.wav");
	precache_sound("weapons/ak47-2.wav");
	precache_sound("weapons/ak47_boltpull.wav");
	precache_sound("weapons/ak47_clipin.wav");
	precache_sound("weapons/ak47_clipout.wav");
	precache_sound("weapons/aug-1.wav");
	precache_sound("weapons/aug_boltpull.wav");
	precache_sound("weapons/aug_boltslap.wav");
	precache_sound("weapons/aug_clipin.wav");
	precache_sound("weapons/aug_clipout.wav");
	precache_sound("weapons/aug_forearm.wav");
	precache_sound("weapons/awp1.wav");
	precache_sound("weapons/awp_clipin.wav");
	precache_sound("weapons/awp_clipout.wav");
	precache_sound("weapons/awp_deploy.wav");
	precache_sound("weapons/boltdown.wav");
	precache_sound("weapons/boltpull1.wav");
	precache_sound("weapons/boltup.wav");
	precache_sound("weapons/c4_beep1.wav");
	precache_sound("weapons/c4_beep2.wav");
	precache_sound("weapons/c4_beep3.wav");
	precache_sound("weapons/c4_beep4.wav");
	precache_sound("weapons/c4_beep5.wav");
	precache_sound("weapons/c4_click.wav");
	precache_sound("weapons/c4_disarm.wav");
	precache_sound("weapons/c4_disarmed.wav");
	precache_sound("weapons/c4_explode1.wav");
	precache_sound("weapons/c4_plant.wav");
	precache_sound("weapons/clipin1.wav");
	precache_sound("weapons/clipout1.wav");
	precache_sound("weapons/de_clipin.wav");
	precache_sound("weapons/de_clipout.wav");
	precache_sound("weapons/de_deploy.wav");
	precache_sound("weapons/deagle-1.wav");
	precache_sound("weapons/deagle-2.wav");
	precache_sound("weapons/dryfire_pistol.wav");
	precache_sound("weapons/dryfire_rifle.wav");
	precache_sound("weapons/elite_clipout.wav");
	precache_sound("weapons/elite_deploy.wav");
	precache_sound("weapons/elite_fire.wav");
	precache_sound("weapons/elite_leftclipin.wav");
	precache_sound("weapons/elite_reloadstart.wav");
	precache_sound("weapons/elite_rightclipin.wav");
	precache_sound("weapons/elite_sliderelease.wav");
	precache_sound("weapons/elite_twirl.wav");
	precache_sound("weapons/fiveseven-1.wav");
	precache_sound("weapons/fiveseven_clipin.wav");
	precache_sound("weapons/fiveseven_clipout.wav");
	precache_sound("weapons/fiveseven_slidepull.wav");
	precache_sound("weapons/fiveseven_sliderelease.wav");
	precache_sound("weapons/flashbang-1.wav");
	precache_sound("weapons/flashbang-2.wav");
	precache_sound("weapons/g3sg1-1.wav");
	precache_sound("weapons/g3sg1_clipin.wav");
	precache_sound("weapons/g3sg1_clipout.wav");
	precache_sound("weapons/g3sg1_slide.wav");
	precache_sound("weapons/generic_reload.wav");
	precache_sound("weapons/generic_shot_reload.wav");
	precache_sound("weapons/glock18-1.wav");
	precache_sound("weapons/glock18-2.wav");
	precache_sound("weapons/grenade_hit1.wav");
	precache_sound("weapons/grenade_hit2.wav");
	precache_sound("weapons/grenade_hit3.wav");
	precache_sound("weapons/he_bounce-1.wav");
	precache_sound("weapons/headshot2.wav");
	precache_sound("weapons/hegrenade-1.wav");
	precache_sound("weapons/hegrenade-2.wav");
	precache_sound("weapons/knife_deploy1.wav");
	precache_sound("weapons/knife_hit1.wav");
	precache_sound("weapons/knife_hit2.wav");
	precache_sound("weapons/knife_hit3.wav");
	precache_sound("weapons/knife_hit4.wav");
	precache_sound("weapons/knife_hitwall1.wav");
	precache_sound("weapons/knife_slash1.wav");
	precache_sound("weapons/knife_slash2.wav");
	precache_sound("weapons/knife_stab.wav");
	precache_sound("weapons/m249-1.wav");
	precache_sound("weapons/m249-2.wav");
	precache_sound("weapons/m249_boxin.wav");
	precache_sound("weapons/m249_boxout.wav");
	precache_sound("weapons/m249_chain.wav");
	precache_sound("weapons/m249_coverdown.wav");
	precache_sound("weapons/m249_coverup.wav");
	precache_sound("weapons/m3-1.wav");
	precache_sound("weapons/m3_insertshell.wav");
	precache_sound("weapons/m3_pump.wav");
	precache_sound("weapons/m4a1-1.wav");
	precache_sound("weapons/m4a1_boltpull.wav");
	precache_sound("weapons/m4a1_clipin.wav");
	precache_sound("weapons/m4a1_clipout.wav");
	precache_sound("weapons/m4a1_deploy.wav");
	precache_sound("weapons/m4a1_silencer_off.wav");
	precache_sound("weapons/m4a1_silencer_on.wav");
	precache_sound("weapons/m4a1_unsil-1.wav");
	precache_sound("weapons/m4a1_unsil-2.wav");
	precache_sound("weapons/mac10-1.wav");
	precache_sound("weapons/mac10_boltpull.wav");
	precache_sound("weapons/mac10_clipin.wav");
	precache_sound("weapons/mac10_clipout.wav");
	precache_sound("weapons/mp5-1.wav");
	precache_sound("weapons/mp5-2.wav");
	precache_sound("weapons/mp5_clipin.wav");
	precache_sound("weapons/mp5_clipout.wav");
	precache_sound("weapons/mp5_slideback.wav");
	precache_sound("weapons/p228-1.wav");
	precache_sound("weapons/p228_clipin.wav");
	precache_sound("weapons/p228_clipout.wav");
	precache_sound("weapons/p228_slidepull.wav");
	precache_sound("weapons/p228_sliderelease.wav");
	precache_sound("weapons/p90-1.wav");
	precache_sound("weapons/p90_boltpull.wav");
	precache_sound("weapons/p90_clipin.wav");
	precache_sound("weapons/p90_clipout.wav");
	precache_sound("weapons/p90_cliprelease.wav");
	precache_sound("weapons/pinpull.wav");
	precache_sound("weapons/ric1.wav");
	precache_sound("weapons/ric2.wav");
	precache_sound("weapons/ric3.wav");
	precache_sound("weapons/ric4.wav");
	precache_sound("weapons/ric5.wav");
	precache_sound("weapons/ric_conc-1.wav");
	precache_sound("weapons/ric_conc-2.wav");
	precache_sound("weapons/ric_metal-1.wav");
	precache_sound("weapons/ric_metal-2.wav");
	precache_sound("weapons/scout_bolt.wav");
	precache_sound("weapons/scout_clipin.wav");
	precache_sound("weapons/scout_clipout.wav");
	precache_sound("weapons/scout_fire-1.wav");
	precache_sound("weapons/sg550-1.wav");
	precache_sound("weapons/sg550_boltpull.wav");
	precache_sound("weapons/sg550_clipin.wav");
	precache_sound("weapons/sg550_clipout.wav");
	precache_sound("weapons/sg552-1.wav");
	precache_sound("weapons/sg552-2.wav");
	precache_sound("weapons/sg552_boltpull.wav");
	precache_sound("weapons/sg552_clipin.wav");
	precache_sound("weapons/sg552_clipout.wav");
	precache_sound("weapons/sg_explode.wav");
	precache_sound("weapons/slideback1.wav");
	precache_sound("weapons/sliderelease1.wav");
	precache_sound("weapons/tmp-1.wav");
	precache_sound("weapons/tmp-2.wav");
	precache_sound("weapons/ump45-1.wav");
	precache_sound("weapons/ump45_boltslap.wav");
	precache_sound("weapons/ump45_clipin.wav");
	precache_sound("weapons/ump45_clipout.wav");
	precache_sound("weapons/usp1.wav");
	precache_sound("weapons/usp2.wav");
	precache_sound("weapons/usp_clipin.wav");
	precache_sound("weapons/usp_clipout.wav");
	precache_sound("weapons/usp_silencer_off.wav");
	precache_sound("weapons/usp_silencer_on.wav");
	precache_sound("weapons/usp_slideback.wav");
	precache_sound("weapons/usp_sliderelease.wav");
	precache_sound("weapons/usp_unsil-1.wav");
	precache_sound("weapons/xm1014-1.wav");
	precache_sound("weapons/zoom.wav");

	clientstat(0, EV_FLOAT, health);
	clientstat(10, EV_FLOAT, weapon);
	clientstat(16, EV_FLOAT, view_ofs[2]);
	clientstat(21, EV_FLOAT, viewzoom);

	/* FIXME: Turn those into bitflags */
	clientstat(STAT_BUYZONE, EV_FLOAT, fInBuyZone);
	clientstat(STAT_HOSTAGEZONE, EV_FLOAT, fInHostageZone);
	clientstat(STAT_BOMBZONE, EV_FLOAT, fInBombZone);
	clientstat(STAT_ESCAPEZONE, EV_FLOAT, fInEscapeZone);
	clientstat(STAT_VIPZONE, EV_FLOAT, fInVIPZone);

	clientstat(4, EV_FLOAT, armor);
	clientstat(STAT_MONEY, EV_FLOAT, fMoney);
	clientstat(STAT_SLOT_MELEE, EV_FLOAT, fSlotMelee);
	clientstat(STAT_SLOT_PRIMARY, EV_FLOAT, fSlotPrimary);
	clientstat(STAT_SLOT_SECONDARY, EV_FLOAT, fSlotSecondary);
	clientstat(STAT_SLOT_GRENADE, EV_FLOAT, fSlotGrenade);
	clientstat(STAT_SLOT_C4BOMB, EV_FLOAT, fSlotC4Bomb);
	clientstat(STAT_ITEM_FLASHBANG, EV_INTEGER, iAmmo_FLASHBANG);
	clientstat(STAT_ITEM_HEGRENADE, EV_INTEGER, iAmmo_HEGRENADE);
	clientstat(STAT_ITEM_SMOKEGRENADE, EV_INTEGER, iAmmo_SMOKEGRENADE);
	clientstat(STAT_EQUIPMENT, EV_INTEGER, iEquipment);
	clientstat(STAT_CURRENT_MAG, EV_INTEGER, iCurrentMag);
	clientstat(STAT_CURRENT_CALIBER, EV_INTEGER, iCurrentCaliber);
	clientstat(STAT_TEAM, EV_INTEGER, team);
	clientstat(STAT_PROGRESS, EV_FLOAT, fProgressBar);
	clientstat(STAT_FLAGS, EV_FLOAT, flags);
	pointerstat(STAT_GAMETIME, EV_FLOAT, &fGameTime);
	pointerstat(STAT_GAMESTATE, EV_FLOAT, &fGameState);
	pointerstat(STAT_WON_T, EV_INTEGER, &iWon_T);
	pointerstat(STAT_WON_CT, EV_INTEGER, &iWon_CT);

	iBombRadius = 1024;
	localcmd(sprintf("serverinfo slots %d\n", cvar("sv_playerslots")));
	localcmd("teamplay 1\n");
}
