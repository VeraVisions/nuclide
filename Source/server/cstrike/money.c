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
void Money_AddMoney( entity ePlayer, int iMoneyValue ) {
	
	dprint( sprintf( "[DEBUG]: Giving %s %i in cash\n", ePlayer.netname, iMoneyValue ) );
	ePlayer.fMoney += (float)iMoneyValue;
	
	if ( ePlayer.fMoney > autocvar_fcs_maxmoney ) {
		ePlayer.fMoney = autocvar_fcs_maxmoney;
	}
	
	// Because people do tend to kill hostages...
	if ( ePlayer.fMoney < 0 ) {
		ePlayer.fMoney = 0;
	}
}

/*
=================
Money_QueTeamReward

Rewards are adding up throughout the match...
=================
*/
void Money_QueTeamReward( float fTeam, int iMoneyValue ) {
	if ( fTeam == TEAM_T ) {
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
void Money_GiveTeamReward( void ) {
	if ( self.team == TEAM_T ) {
		Money_AddMoney( self, iMoneyReward_T );
	} else {
		Money_AddMoney( self, iMoneyReward_CT );
	}
}

/*
=================
Money_ResetTeamReward
=================
*/
void Money_ResetTeamReward( void ) {
	iMoneyReward_T = 0;
	iMoneyReward_CT = 0;
}
