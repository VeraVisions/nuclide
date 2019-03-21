/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

int iMoneyReward_CT;
int iMoneyReward_T;

/*
=================
Money_AddMoney

Gives a player money and caps it
=================
*/
void Money_AddMoney(entity ePlayer, int iMoneyValue)
{
	
	dprint(sprintf("[DEBUG]: Giving %s %i in cash\n", ePlayer.netname, iMoneyValue));
	ePlayer.fMoney += (float)iMoneyValue;
	
	if (ePlayer.fMoney > autocvar_fcs_maxmoney) {
		ePlayer.fMoney = autocvar_fcs_maxmoney;
	}
	
	// Because people do tend to kill hostages...
	if (ePlayer.fMoney < 0) {
		ePlayer.fMoney = 0;
	}
}

/*
=================
Money_QueTeamReward

Rewards are adding up throughout the match...
=================
*/
void Money_QueTeamReward(float fTeam, int iMoneyValue)
{
	if (fTeam == TEAM_T) {
		iMoneyReward_T += iMoneyValue;
	} else {
		iMoneyReward_CT += iMoneyValue;
	}
}

/*
=================
Money_GiveTeamReward

...and eventually given when this is called
=================
*/
void Money_GiveTeamReward(void)
{
	if (self.team == TEAM_T) {
		Money_AddMoney(self, iMoneyReward_T);
	} else {
		Money_AddMoney(self, iMoneyReward_CT);
	}
}

/*
=================
Money_ResetTeamReward
=================
*/
void Money_ResetTeamReward(void)
{
	iMoneyReward_T = 0;
	iMoneyReward_CT = 0;
}

int iLosses_CT;
int iLosses_T;
int iWinstreak_CT;
int iWinstreak_T;
int iBonus_CT;
int iBonus_T;

int Money_GetLosses(int team)
{
	if (team == TEAM_T) {
		return iLosses_T;
	} else {
		return iLosses_CT;
	}
}
int Money_HasBonus(int team)
{
	if (team == TEAM_T) {
		return iBonus_T;
	} else {
		return iBonus_CT;
	}
}

void Money_HandleRoundReward(int winner)
{
	int loser;

	if (winner == TEAM_CT) {
		iWinstreak_CT++;
		iWinstreak_T = 0;
		iLosses_T++;
		iLosses_CT = 0;
		loser = TEAM_T;

		if (iWinstreak_CT >= 2) {
			iBonus_CT = TRUE;
		}
	} else if (winner == TEAM_T) {
		iWinstreak_T++;
		iWinstreak_CT = 0;
		iLosses_CT++;
		iLosses_T = 0;
		loser = TEAM_CT;

		if (iWinstreak_T >= 2) {
			iBonus_T = TRUE;
		}
	}

	/*  After the condition of a team winning two consecutive rounds is
	 *  satisfied then the loss bonus money changes to above where their
	 *  first loss means they receive $1500 and not $1400. */
	if (Money_HasBonus(loser)) {
		switch (Money_GetLosses(loser)) {
		case 1:
			Money_QueTeamReward(loser, 1500);
			break;
		case 2:
			Money_QueTeamReward(loser, 2000);
			break;
		case 3:
			Money_QueTeamReward(loser, 2500);
			break;
		default:
			Money_QueTeamReward(loser, 3000);
			break;
		}
	} else {
		switch (Money_GetLosses(loser)) {
		case 1:
			Money_QueTeamReward(loser, 1400);
			break;
		case 2:
			Money_QueTeamReward(loser, 1900);
			break;
		case 3:
			Money_QueTeamReward(loser, 2400);
			break;
		case 4:
			Money_QueTeamReward(loser, 2900);
			break;
		default:
			Money_QueTeamReward(loser, 3400);
			break;
		}
	}
}

void Money_ResetRoundReward(void)
{
	iLosses_CT =
	iLosses_T =
	iWinstreak_CT =
	iWinstreak_T =
	iBonus_CT =
	iBonus_T = 0;
}
