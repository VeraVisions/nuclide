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
