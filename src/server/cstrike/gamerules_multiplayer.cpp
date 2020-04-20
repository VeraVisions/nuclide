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

void
CSMultiplayerRules::PlayerPreFrame(player pl)
{
	if (pl.health <= 0)
		return;

	if (g_cs_gamestate == GAME_FREEZE) {
		pl.flags |= FL_FROZEN;
	} else {
		pl.flags &= ~FL_FROZEN;
	}
}

void
CSMultiplayerRules::FrameStart(void)
{
	if ((g_cs_alive_t + g_cs_alive_ct) == 0) {
		int iInGamePlayers = 0;
		for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
			iInGamePlayers++;
		}
		
		if ((iInGamePlayers > 0) && (g_cs_gamestate != GAME_COMMENCING && g_cs_gamestate != GAME_END)) {
			TimerBegin(2, GAME_COMMENCING);
		} else if (iInGamePlayers == 0) {
			g_cs_gamestate = GAME_INACTIVE;
			g_cs_gametime = 0;
			g_cs_roundswon_t = 0;
			g_cs_roundswon_ct = 0;
			g_cs_roundsplayed = 0;
		} else {
			TimerUpdate(); // Timer that happens once players have started joining
		}
	} else {
		TimerUpdate(); // Normal gameplay timer
	}
}

void
CSMultiplayerRules::CreateRescueZones(void)
{
	int zones = 0;

	/* not in hostage rescue mode */
	if (g_cs_hostagestotal <= 0) {
		return;
	}

	/* count the already existing rescue zones. */
	for (entity e = world; (e = find(e, ::classname, "func_hostage_rescue"));) {
		if (e.team == TEAM_CT) {
			zones++;
		}
	}

	/* we don't need to create any additional rescue zones. */
	if (zones > 0)
		return;

	/* since no buyzones are available, let's create one around every CT spawn */
	for (entity e = world; (e = find(e, ::classname, "info_player_start"));) {
		info_hostage_rescue newzone = spawn(info_hostage_rescue);
		setorigin(newzone, e.origin);
	}
}

void
CSMultiplayerRules::CreateCTBuyzones(void)
{
	int zones = 0;

	/* count the already existing CT zones. */
	for (entity e = world; (e = find(e, ::classname, "func_buyzone"));) {
		if (e.team == TEAM_CT) {
			zones++;
		}
	}

	/* we don't need to create any additional CT zones. */
	if (zones > 0)
		return;

	/* since no buyzones are available, let's create one around every CT spawn */
	for (entity e = world; (e = find(e, ::classname, "info_player_start"));) {
		info_buyzone newzone = spawn(info_buyzone);
		setorigin(newzone, e.origin);
		newzone.team = TEAM_CT;
	}
}

void
CSMultiplayerRules::CreateTBuyzones(void)
{
	int zones = 0;

	/* count the already existing T zones. */
	for (entity e = world; (e = find(e, ::classname, "func_buyzone"));) {
		if (e.team == TEAM_T) {
			zones++;
		}
	}

	/* we don't need to create any additional T zones. */
	if (zones > 0)
		return;

	/* since no buyzones are available, let's create one around every T spawn */
	for (entity e = world; (e = find(e, ::classname, "info_player_deathmatch"));) {
		info_buyzone newzone = spawn(info_buyzone);
		setorigin(newzone, e.origin);
		newzone.team = TEAM_T;
	}
}

void
CSMultiplayerRules::InitPostEnts(void)
{
	/* let's check if we need to create buyzones */
	switch (g_cstrike_buying) {
	case BUY_CT:
		CreateCTBuyzones();
		break;
	case BUY_T:
		CreateTBuyzones();
		break;
	case BUY_NEITHER:
		break;
	default:
		CreateCTBuyzones();
		CreateTBuyzones();
	}

	CreateRescueZones();
}

void
CSMultiplayerRules::TimerBegin(float tleft, int mode)
{
	if (mode == GAME_FREEZE) {
		g_cs_gamestate = GAME_FREEZE;
	} else if (mode == GAME_ACTIVE) {
		g_cs_gamestate = GAME_ACTIVE;
	} else if (mode == GAME_END) {
		g_cs_gamestate = GAME_END;
	} else if (mode == GAME_COMMENCING) {
		g_cs_gamestate = GAME_COMMENCING;
	} else if (mode == GAME_OVER) {
		g_cs_gamestate = GAME_OVER;
	}

	g_cs_gametime = tleft;
}

void
CSMultiplayerRules::TimerUpdate(void)
{
	if (cvar("sv_playerslots") == 1) {
		g_cs_gametime = -1;
		return;
	}

	if (g_cs_hostagestotal > 0) {
		if (g_cs_hostagesrescued >= g_cs_hostagestotal) {
			RoundOver(TEAM_CT, 0, FALSE);
			return;
		}
	}

	// This map has been played enough we think
	if (g_cs_gamestate != GAME_OVER) {
		if (cvar("mp_timelimit") > 0) {
			if (time >= (cvar("mp_timelimit") * 60)) {
				TimerBegin(5, GAME_OVER);
			}
		}
	}

	if ((g_cs_gamestate == GAME_OVER) && (g_cs_gametime < 0)) {
		localcmd("echo nextmap\n");
	}

	// Okay, this means that timelimit is not the only deciding factor
	if (autocvar_mp_winlimit > 0 && g_cs_gamestate != GAME_OVER) {
		// It really doesn't matter who won. Do some logging perhaps?
		if (g_cs_roundswon_ct == autocvar_mp_winlimit) {
			TimerBegin(5, GAME_OVER);
		} else if (g_cs_roundswon_t == autocvar_mp_winlimit) {
			TimerBegin(5, GAME_OVER);
		}
	}

	if (g_cs_gamestate == GAME_INACTIVE) {
		return;
	}

	if (g_cs_gametime > 0) {
		g_cs_gametime -= frametime;
	} else {
		g_cs_gametime = 0;
	}

	if (g_cs_gamestate == GAME_COMMENCING || g_cs_gamestate == GAME_END) {
		if (g_cs_gametime <= 0) {
			if (g_cs_roundswon_t == 0 && g_cs_roundswon_ct == 0) {
				Money_ResetTeamReward();
				Money_ResetRoundReward();
				RestartRound(TRUE);
			} else {
				if (autocvar_mp_halftime == TRUE && (autocvar_mp_winlimit / 2 == g_cs_roundsplayed)) {
					Money_ResetTeamReward();
					SwitchTeams();
					RestartRound(TRUE);
				} else {
					RestartRound(FALSE);
				}
			}
		}
		return;
	}

	if ((g_cs_gamestate == GAME_ACTIVE) || (g_cs_gamestate == GAME_FREEZE)) {
		if (g_cs_gametime <= 0) {
			if (g_cs_gamestate == GAME_ACTIVE) {
				/* 1.5 will make the T's lose if time runs out no matter what */
				if (autocvar_fcs_fix_bombtimer == TRUE) {
					if (g_cs_bombzones > 0 && g_cs_bombplanted == TRUE) {
						return;
					}
				}
				TimeOut();
				TimerBegin(5, GAME_END); // Round is over, 5 seconds til a new round starts
			} else {
				TimerBegin(autocvar_mp_roundtime * 60, GAME_ACTIVE); // Unfreeze
				Radio_StartMessage();
			}
		}
	}
}

/*
=================
BuyingPossible

Checks if it is possible for players to buy anything
=================
*/
int
CSMultiplayerRules::BuyingPossible(player pl)
{
	if (pl.health <= 0) {
		return FALSE;
	}
	
	if (g_cs_gamestate == GAME_ACTIVE) {
		if (((autocvar_mp_roundtime * 60) - g_cs_gametime) > autocvar_mp_buytime) {
			centerprint(pl, sprintf("%d seconds have passed...\nYou can't buy anything now!", autocvar_mp_buytime));
			return FALSE;
		}
	}
	
	if (pl.team == TEAM_VIP) {
		centerprint(pl, "You are the VIP...\nYou can't buy anything!\n");
		return FALSE;
	}
	
	if (g_cstrike_buying == BUY_NEITHER) {
		centerprint(pl, "Sorry, you aren't meant\nto be buying anything.\n");
		return FALSE;
	}
	
	if (g_cstrike_buying != BUY_BOTH) {
		if (g_cstrike_buying == BUY_CT && pl.team == TEAM_T) {
			centerprint(pl, "Terrorists aren't allowed to\nbuy anything on this map!\n");
			return FALSE;
		} else if (g_cstrike_buying == BUY_T && pl.team == TEAM_CT) {
			centerprint(pl, "CTs aren't allowed to buy\nanything on this map!\n");
			return FALSE;
		}
	}
	
	if (pl.buyzone == FALSE) {
		centerprint(pl, "Sorry, you aren't in a buyzone.\n");
		return FALSE;
	}
	
	return TRUE;
}

void
CSMultiplayerRules::MakeBomber(player pl)
{
	Weapons_AddItem(pl, WEAPON_C4BOMB);
	centerprint(pl, "You have the bomb!\nFind the target zone or DROP\nthe bomb for another Terrorist.");
}

void
CSMultiplayerRules::MakeVIP(player pl)
{
	pl.team = TEAM_VIP;
	PlayerRespawn(pl, pl.team);
	centerprint(pl, "You are the VIP\nMake your way to the safety zones!");
	forceinfokey(pl, "*dead", "2");
}

/*
=================
RestartRound

Loop through all ents and handle them
=================
*/
void
CSMultiplayerRules::RestartRound(int iWipe)
{
	g_cs_hostagesrescued = 0;

	// Spawn/Respawn everyone at their team position and give them $$$
	for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
		player pl = (player)eFind;

		if (pl.health > 0 && iWipe == FALSE) {
			PlayerRespawn(pl, pl.team);
		} else {
			PlayerMakeSpectator(pl);
			PlayerMakePlayable(pl, pl.charmodel);
		}

		if (iWipe == FALSE) {
			Money_GiveTeamReward();
		} else {
			pl.money = 0;
			Money_AddMoney(pl, autocvar_mp_startmoney);
		}
	}

	// Clear the corpses/items
	for (entity eFind = world; (eFind = find(eFind, ::classname, "remove_me"));) {
		remove(eFind);
	}

	// Find the bombs. Destory them!
	for (entity eFind = world; (eFind = find(eFind, ::classname, "c4bomb"));) {
		remove(eFind);
	}

	// Select a random Terrorist for the bomb, if needed
	if (g_cs_bombzones > 0) {
		int iRandomT = floor(random(1, (float)g_cs_alive_t + 1)); 
		int iPickT = 0;
		
		for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) { 
			if (eFind.team == TEAM_T) {
				iPickT++;
				
				if (iPickT == iRandomT) {
					MakeBomber((player)eFind);
				}
			}
		}
	} 

	// If there is a VIP, select a random CT to be it
	if (g_cs_vipzones > 0) {
		int iRandomCT = floor(random(1, (float)g_cs_alive_ct + 1));
		int iPickCT = 0;

		for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) { 
			if (eFind.team == TEAM_CT) {
				iPickCT++;
				if (iPickCT == iRandomCT) {
					MakeVIP((player)eFind);
				}
			}
		}
	}

	// Respawn all the entities
	for (entity a = world; (a = findfloat(a, ::gflags, GF_CANRESPAWN));) {
		CBaseEntity caw = (CBaseEntity)a;
		caw.Respawn();
	}

	TimerBegin(autocvar_mp_freezetime, GAME_FREEZE);
	Money_ResetTeamReward();
}

/*
=================
RoundOver

This happens whenever an objective is complete or time is up
=================
*/
void
CSMultiplayerRules::RoundOver(int iTeamWon, int iMoneyReward, int fSilent)
{
	
	if (g_cs_gamestate != GAME_ACTIVE) {
		return;
	}

	if (iTeamWon == TEAM_T) {
		if (fSilent == FALSE) {
			Radio_BroadcastMessage(RADIO_TERWIN);
		}
		g_cs_roundswon_t++;
	} else if (iTeamWon == TEAM_CT) {
		if (fSilent == FALSE) {
			Radio_BroadcastMessage(RADIO_CTWIN);
		}
		g_cs_roundswon_ct++;

		/* In Bomb Defusal, if Terrorists were able to plant the bomb
		 * but lose the round, all Terrorists receive an $800 bonus. */
		if (g_cs_bombplanted) {
			Money_QueTeamReward(TEAM_T, 800);
		}
	} else {
		if (fSilent == FALSE) {
			Radio_BroadcastMessage(RADIO_ROUNDDRAW);
		}
	}

	Money_HandleRoundReward(iTeamWon);
	Money_QueTeamReward(iTeamWon, iMoneyReward);
	TimerBegin(5, GAME_END); // Round is over, 5 seconds til a new round starts

	g_cs_hostagesrescued = 0;
	g_cs_bombplanted = 0;
	g_cs_roundsplayed++;
}

/*
=================
TimeOut

Whenever mp_roundtime was being counted down to 0
=================
*/
void
CSMultiplayerRules::TimeOut(void)
{
	if (g_cs_vipzones > 0) {
		RoundOver(TEAM_T, 3250, FALSE);
	} else if (g_cs_bombzones > 0) {
		/* In Bomb Defusal, all Counter-Terrorists receive $3250
		 *  if they won running down the time. */
		RoundOver(TEAM_CT, 3250, FALSE);
	} else if (g_cs_hostagestotal > 0) {
		// TODO: Broadcast_Print: Hostages have not been rescued!
		RoundOver(TEAM_T, 3250, FALSE);
	} else {
		RoundOver(0, 0, FALSE);
	}
}

/*
=================
SwitchTeams

Happens rarely
=================
*/
void
CSMultiplayerRules::SwitchTeams(void)
{
	int iCTW, iTW;

	for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) { 
		player pl = (player)eFind;
		if (pl.team == TEAM_CT) {
			pl.team = TEAM_T;
			pl.charmodel -= 4;
		} else if (pl.team == TEAM_T) {
			pl.team = TEAM_CT;
			pl.charmodel += 4;
		}
		forceinfokey(pl, "*team", ftos(pl.team));
	}

	iCTW = g_cs_roundswon_ct;
	iTW = g_cs_roundswon_t;

	g_cs_roundswon_t = iCTW;
	g_cs_roundswon_ct = iTW;

	iCTW = g_cs_alive_ct;
	iTW = g_cs_alive_t;

	g_cs_alive_ct = iTW;
	g_cs_alive_t = iCTW;
}

void
CSMultiplayerRules::CountPlayers(void)
{
	g_cs_alive_t = 0;
	g_cs_alive_ct = 0;

	for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
		if (eFind.health > 0) {
			if (eFind.team == TEAM_T) {
				g_cs_alive_t++;
			} else if (eFind.team == TEAM_CT) {
				g_cs_alive_ct++;
			} else if (eFind.team == TEAM_VIP) {
				g_cs_alive_ct++;
			}
		}
	}
}

void
CSMultiplayerRules::DeathCheck(player pl)
{
	if ((g_cs_alive_t == 0) && (g_cs_alive_ct == 0)) {
		if (g_cs_bombplanted == TRUE) {
			RoundOver(TEAM_T, 3600, FALSE);
		} else {
			RoundOver(FALSE, 0, FALSE);
		}
	} else {
		int winner;
		if ((pl.team == TEAM_T) && (g_cs_alive_t == 0)) {
			winner = TEAM_CT;
		} else if ((pl.team == TEAM_CT) && (g_cs_alive_ct == 0)) {
			winner = TEAM_T;
		} else {
			return;
		}
		if (g_cs_bombzones > 0) {
			/* In Bomb Defusal, the winning team receives $3250
			 * if they won by eliminating the enemy team. */
			if (!g_cs_bombplanted || g_cs_alive_ct == 0) {
				RoundOver(winner, 3250, FALSE);
			}
		} else {
			/* In Hostage Rescue, the winning team receives $3600
			 * if they won by eliminating the enemy team. */
			RoundOver(winner, 3600, FALSE);
		}
	}
}

/*
=================
PlayerFindSpawn

Recursive function that gets the next spawnpoint
=================
*/
entity
CSMultiplayerRules::PlayerFindSpawn(float fTeam)
{
	entity eSpot, eLastSpawn;
	entity eThing;
	int iCount;
	string sClassname;

	if (fTeam == TEAM_T) {
		sClassname = "info_player_deathmatch";
		eSpot = eLastSpawn = m_eLastTSpawn;
	} else if (fTeam == TEAM_CT) {
		sClassname = "info_player_start";
		eSpot = eLastSpawn = m_eLastCTSpawn;
	} else if (fTeam == TEAM_VIP) {
		return find(world, ::classname, "info_vip_start");
	}

	while (1) {
		eSpot = find(eSpot, ::classname, sClassname);
		
		if (eSpot == eLastSpawn)
		{//fall back on lame cycling/spawnfragging
			eLastSpawn = find(eLastSpawn, ::classname, sClassname);
			if (!eLastSpawn)
				eLastSpawn = find(eLastSpawn, ::classname, sClassname);
			return eLastSpawn;
		}
		if (eSpot != world) {
			iCount = 0;
			eThing = findradius(eSpot.origin, 32);
			while(eThing) {
				if (eThing.classname == "player")
					iCount++;
				eThing = eThing.chain;
			}
			if (iCount == 0) {
				eLastSpawn = eSpot;
				return eSpot;
			}
		}
	}

	return eSpot;
}

/*
=================
PlayerRespawn

Called whenever a player survived a round and needs a basic respawn.
=================
*/
void
CSMultiplayerRules::PlayerRespawn(player pl, int fTeam)
{
	entity eSpawn;
	forceinfokey(pl, "*spec", "0");
	eSpawn = PlayerFindSpawn(pl.team);

	pl.classname = "player";
	pl.health = pl.max_health = 100;
	forceinfokey(pl, "*dead", "0");
	CountPlayers();

	pl.takedamage = DAMAGE_YES;
	pl.solid = SOLID_SLIDEBOX;
	pl.movetype = MOVETYPE_WALK;
	pl.flags = FL_CLIENT;
	pl.iBleeds = TRUE;
	pl.viewzoom = 1.0;

	pl.origin = eSpawn.origin;
	pl.angles = eSpawn.angles;
	setmodel(pl, "models/player/vip/vip.mdl");
	setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	pl.view_ofs = VEC_PLAYER_VIEWPOS;
	pl.velocity = [0,0,0];

	/*Ammo_AutoFill(pl.fSlotPrimary);
	Ammo_AutoFill(pl.fSlotSecondary);*/
}

/*
=================
PlayerMakePlayable

Called whenever need a full-reinit of a player.
This may be after a player had died or when the game starts for the first time.
=================
*/
void
CSMultiplayerRules::PlayerMakePlayable(player pl, int chara)
{
	/* spectator */
	if (chara == 0) {
		PlayerSpawn(pl);
		return;
	}

	pl.g_items |= ITEM_SUIT;
	Weapons_AddItem(pl, WEAPON_KNIFE);

	if (chara < 5) {
		/* terrorists */
		pl.team = TEAM_T;
		if (autocvar_fcs_knifeonly == FALSE) {
			Weapons_AddItem(pl, WEAPON_GLOCK18);
			/*Weapon_GiveAmmo(WEAPON_GLOCK18, 40);*/
			/*Weapon_Draw(WEAPON_GLOCK18);*/
		} else {
			/*Weapon_Draw(WEAPON_KNIFE);*/
		}
	} else {
		/* counter */
		pl.team = TEAM_CT;
		pl.g_items |= ITEM_SUIT;

		Weapons_AddItem(pl, WEAPON_KNIFE);
		if (autocvar_fcs_knifeonly == FALSE) {
			Weapons_AddItem(pl, WEAPON_USP45);
			/*Weapon_GiveAmmo(WEAPON_USP45, 24);*/
			/*Weapon_Draw(WEAPON_USP45);*/
		} else {
			/*Weapon_Draw(WEAPON_KNIFE);*/
		}
	}

	pl.ingame = TRUE;
	forceinfokey(pl, "*team", ftos(pl.team)); 
	PlayerRespawn(pl, pl.team);
}

/*
=================
PlayerMakeSpectator

Force the player to become an observer.
=================
*/
void
CSMultiplayerRules::PlayerMakeSpectator(player pl)
{
	pl.classname = "spectator";
	pl.health = 0;
	pl.armor = 0;
	pl.takedamage = DAMAGE_NO;
	pl.solid = SOLID_NOT;
	pl.movetype = MOVETYPE_NOCLIP;
	pl.SendEntity = Player_SendEntity;
	pl.flags = FL_CLIENT;
	pl.weapon = 0;
	pl.viewzoom = 1.0f;
	pl.model = 0;
	setsize (pl, [-16,-16,-16], [16,16,16]);
	pl.view_ofs = pl.velocity = [0,0,0];
	forceinfokey(pl, "*spec", "2");

	/* clear the inventory */
	pl.items = 0x0;
	pl.activeweapon = 0;
}

/*
=================
PlayerSpawn

Called on the client first joining the server.
=================
*/
void
CSMultiplayerRules::PlayerSpawn(player pl)
{
	/* immediately put us into spectating mode */
	PlayerMakeSpectator(pl);
	Spawn_ObserverCam(pl);

	/* give the initial server-joining money */
	Money_AddMoney(pl, autocvar_mp_startmoney);

	/* we don't belong to any team */
	pl.team = 0;
	forceinfokey(pl, "*team", "0"); 
}

void
CSMultiplayerRules::CSMultiplayerRules(void)
{
	forceinfokey(world, "*gamemode", "classic"); 
}

/*
=================
CSEv_JoinTeam_f

Event Handling, called by the Client codebase via 'sendevent'
=================
*/
void CSEv_JoinTeam_f(float flChar)
{
	CSMultiplayerRules rules = (CSMultiplayerRules)g_grMode;
	player pl = (player)self;

	if (pl.team == TEAM_VIP) {
		centerprint(pl, "You are the VIP!\nYou cannot switch roles now.\n");
		return;
	}

	// alive and are trying to switch teams, so subtract us from the Alive_Team counter.
	if (pl.health > 0) {
		rules.PlayerKill(pl);
	}

	switch (g_cs_gamestate) {
	/* spawn the players immediately when its in the freeze state */
	case GAME_FREEZE:
		pl.charmodel = (int)flChar;
		rules.PlayerMakePlayable(pl, (int)flChar);

		if ((pl.team == TEAM_T) && (g_cs_alive_t == 1)) {
			if (g_cs_bombzones > 0) {
				rules.MakeBomber(pl);
			}
		} else if ((pl.team == TEAM_CT) && (g_cs_alive_ct == 1)) {
			if (g_cs_vipzones > 0) {
				rules.MakeVIP(pl);
			}
		}

		break;
	/* otherwise, just prepare their fields for the next round */
	default:
		if (flChar == 0) {
			rules.PlayerSpawn(pl);
			return;
		}

		if (flChar < 5) {
			pl.team = TEAM_T;
		} else {
			pl.team = TEAM_CT;
		}

		rules.PlayerMakeSpectator(pl);
		pl.classname = "player";
		pl.charmodel = (int)flChar;
		pl.health = 0;
		forceinfokey(pl, "*dead", "1");
		forceinfokey(pl, "*team", ftos(pl.team)); 
		break;
	}

	pl.frags = 0;
	pl.deaths = 0;
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

	/* if no players are present in the chosen team, force restart round */
	if ((pl.team == TEAM_T) && (g_cs_alive_t == 0)) {
		rules.RoundOver(FALSE, 0, FALSE);
	} else if ((pl.team == TEAM_CT) && (g_cs_alive_ct == 0)) {
		rules.RoundOver(FALSE, 0, FALSE);
	}
}

void weaponbox_spawn(player pl) {}
