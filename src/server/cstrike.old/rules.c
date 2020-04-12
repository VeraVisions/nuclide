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

enum
{
	BUY_BOTH,
	BUY_CT,
	BUY_T,
	BUY_NEITHER
};

/* Edit this for a custom gun-game order */
int gg_order[] = {
	WEAPON_KNIFE,
	WEAPON_GLOCK18,
	WEAPON_USP45,
	WEAPON_P228,
	WEAPON_FIVESEVEN,
	WEAPON_ELITES,
	WEAPON_DEAGLE,
	WEAPON_M3,
	WEAPON_XM1014,
	WEAPON_TMP,
	WEAPON_MAC10,
	WEAPON_MP5,
	WEAPON_UMP45,
	WEAPON_P90,
	WEAPON_AK47,
	WEAPON_SCOUT,
	WEAPON_M4A1,
	WEAPON_SG552,
	WEAPON_AUG,
	WEAPON_G3SG1,
	WEAPON_SG550,
	WEAPON_AWP,
	WEAPON_PARA
};

/*
=================
Rules_BuyingPossible

Checks if it is possible for players to buy anything
=================
*/
float Rules_BuyingPossible(void) {
	if (self.health <= 0) {
		return FALSE;
	}
	
	if (fGameState == GAME_ACTIVE) {
		if (((autocvar_mp_roundtime * 60) - fGameTime) > autocvar_mp_buytime) {
			centerprint(self, sprintf("%d seconds have passed...\nYou can't buy anything now!", autocvar_mp_buytime));
			self.fAttackFinished = time + 1.0;
			return FALSE;
		}
	}
	
	if (self.team == TEAM_VIP) {
		centerprint(self, "You are the VIP...\nYou can't buy anything!\n");
		self.fAttackFinished = time + 1.0;
		return FALSE;
	}
	
	if (iBuyRestriction == BUY_NEITHER) {
		centerprint(self, "Sorry, you aren't meant\nto be buying anything.\n");
		self.fAttackFinished = time + 1.0;
		return FALSE;
	}
	
	if (iBuyRestriction != BUY_BOTH) {
		if (iBuyRestriction == BUY_CT && self.team == TEAM_T) {
			centerprint(self, "Terrorists aren't allowed to\nbuy anything on this map!\n");
			self.fAttackFinished = time + 1.0;
			return FALSE;
		} else if (iBuyRestriction == BUY_T && self.team == TEAM_CT) {
			centerprint(self, "CTs aren't allowed to buy\nanything on this map!\n");
			self.fAttackFinished = time + 1.0;
			return FALSE;
		}
	}
	
	if (self.fInBuyZone == FALSE) {
		return FALSE;
	}
	
	return TRUE;
}

void Rules_MakeBomber(void) {
	Weapon_AddItem(WEAPON_C4BOMB);
	centerprint(self, "You have the bomb!\nFind the target zone or DROP\nthe bomb for another Terrorist.");
}

void Rules_MakeVIP(void) {
	self.team = TEAM_VIP;
	Spawn_RespawnClient(self.team);
	centerprint(self, "You are the VIP\nMake your way to the safety zones!");
	forceinfokey(self, "*dead", "2");
}

/*
=================
Rules_Restart

Loop through all ents and handle them
=================
*/
void Rules_Restart(int iWipe) {
	iHostagesRescued = 0;
	
	entity eOld = self;
	
	// Spawn/Respawn everyone at their team position and give them $$$
	for (entity eFind = world; (eFind = find(eFind, classname, "player"));) {
		self = eFind;
		
		if (self.health > 0 && iWipe == FALSE) {
			Spawn_RespawnClient(self.team);
		} else {
			Spawn_MakeSpectator();
			Spawn_CreateClient(self.fCharModel);
		}
		
		if (iWipe == FALSE) {
			Money_GiveTeamReward();
		} else {
			self.fMoney = 0;
			Money_AddMoney(self, autocvar_mp_startmoney);
		}
	}
	
	// Clear the corpses/items
	for (entity eFind = world; (eFind = find(eFind, classname, "remove_me"));) {
		remove(eFind);
	}
	
	// Find the bombs. Destory them!
	for (entity eFind = world; (eFind = find(eFind, classname, "c4bomb"));) {
		remove(eFind);
	}
	
	// Select a random Terrorist for the bomb, if needed
	if (iBombZones > 0) {
		int iRandomT = floor(random(1, (float)iAlivePlayers_T + 1)); 
		int iPickT = 0;
		
		for (entity eFind = world; (eFind = find(eFind, classname, "player"));) { 
			if (eFind.team == TEAM_T) {
				iPickT++;
				
				if (iPickT == iRandomT) {
					self = eFind;
					Rules_MakeBomber();
				}
			}
		}
	} 
	
	// If there is a VIP, select a random CT to be it
	if (iVIPZones > 0) {
		int iRandomCT = floor(random(1, (float)iAlivePlayers_CT + 1));
		int iPickCT = 0;

		for (entity eFind = world; (eFind = find(eFind, classname, "player"));) { 
			if (eFind.team == TEAM_CT) {
				iPickCT++;
				if (iPickCT == iRandomCT) {
					self = eFind;
					Rules_MakeVIP();
				}
			}
		}

	}

	// Respawn all the entities
	for (entity a = world; (a = findfloat(a, gflags, GF_CANRESPAWN));) {
		CBaseEntity caw = (CBaseEntity)a;
		caw.Respawn();
	}

	self = eOld;

	Timer_Begin(autocvar_mp_freezetime, GAME_FREEZE);
	Money_ResetTeamReward();
	fDefuseProgress = 0;
}

/*
=================
Rules_RoundOver

This happens whenever an objective is complete or time is up
=================
*/
void Rules_RoundOver(int iTeamWon, int iMoneyReward, float fSilent) {
	
	if (fGameState != GAME_ACTIVE) {
		return;
	}

	if (iTeamWon == TEAM_T) {
		if (fSilent == FALSE) {
			Radio_BroadcastMessage(RADIO_TERWIN);
		}
		iWon_T++;
	} else if (iTeamWon == TEAM_CT) {
		if (fSilent == FALSE) {
			Radio_BroadcastMessage(RADIO_CTWIN);
		}
		iWon_CT++;

		/* In Bomb Defusal, if Terrorists were able to plant the bomb
		 * but lose the round, all Terrorists receive an $800 bonus. */
		if (iBombPlanted) {
			Money_QueTeamReward(TEAM_T, 800);
		}
	} else {
		if (fSilent == FALSE) {
			Radio_BroadcastMessage(RADIO_ROUNDDRAW);
		}
	}

	Money_HandleRoundReward(iTeamWon);
	Money_QueTeamReward(iTeamWon, iMoneyReward);
	Timer_Begin(5, GAME_END); // Round is over, 5 seconds til a new round starts

	iBombPlanted = 0;
	iRounds++;
}

/*
=================
Rules_TimeOver

Whenever mp_roundtime was being counted down to 0
=================
*/
void Rules_TimeOver(void) {
	if (iVIPZones > 0) {
		Rules_RoundOver(TEAM_T, 3250, FALSE);
	} else if (iBombZones > 0) {
		/* In Bomb Defusal, all Counter-Terrorists receive $3250
		 *  if they won running down the time. */
		Rules_RoundOver(TEAM_CT, 3250, FALSE);
	} else if (iHostagesMax > 0) {
		// TODO: Broadcast_Print: Hostages have not been rescued!
		Rules_RoundOver(TEAM_T, 3250, FALSE);
	} else {
		Rules_RoundOver(0, 0, FALSE);
	}
}

/*
=================
Rules_SwitchTeams

Happens rarely
=================
*/
void Rules_SwitchTeams(void) {
	int iCTW, iTW;

	for (entity eFind = world; (eFind = find(eFind, classname, "player"));) { 
		if (eFind.team == TEAM_CT) {
			eFind.team = TEAM_T;
			eFind.fCharModel -= 4;
		} else if (eFind.team == TEAM_T) {
			eFind.team = TEAM_CT;
			eFind.fCharModel += 4;
		}
		forceinfokey(eFind, "*team", ftos(eFind.team));
	}

	iCTW = iWon_CT;
	iTW = iWon_T;

	iWon_T = iCTW;
	iWon_CT = iTW;

	iCTW = iAlivePlayers_CT;
	iTW = iAlivePlayers_T;

	iAlivePlayers_CT = iTW;
	iAlivePlayers_T = iCTW;
}

void Rules_CountPlayers(void)
{
	iAlivePlayers_T = 0;
	iAlivePlayers_CT = 0;

	for (entity eFind = world; (eFind = find(eFind, classname, "player"));) {
		if (eFind.health > 0) {
			if (eFind.team == TEAM_T) {
				iAlivePlayers_T++;
			} else if (eFind.team == TEAM_CT) {
				iAlivePlayers_CT++;
			} else if (eFind.team == TEAM_VIP) {
				iAlivePlayers_CT++;
			}
		}
	}
}

void Rules_DeathCheck(void)
{
	if ((iAlivePlayers_T == 0) && (iAlivePlayers_CT == 0)) {
		if (iBombPlanted == TRUE) {
			Rules_RoundOver(TEAM_T, 3600, FALSE);
		} else {
			Rules_RoundOver(FALSE, 0, FALSE);
		}
	} else {
		int winner;
		if ((self.team == TEAM_T) && (iAlivePlayers_T == 0)) {
			winner = TEAM_CT;
		} else if ((self.team == TEAM_CT) && (iAlivePlayers_CT == 0)) {
			winner = TEAM_T;
		} else {
			return;
		}
		if (iBombZones > 0) {
			/* In Bomb Defusal, the winning team receives $3250
			 * if they won by eliminating the enemy team. */
			if (!iBombPlanted || iAlivePlayers_CT == 0) {
				Rules_RoundOver(winner, 3250, FALSE);
			}
		} else {
			/* In Hostage Rescue, the winning team receives $3600
			 * if they won by eliminating the enemy team. */
			Rules_RoundOver(winner, 3600, FALSE);
		}
	}
}
