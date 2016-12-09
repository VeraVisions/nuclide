/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

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

#define CS_MAX_MONEY 16000

int iMoneyReward_CT;
int iMoneyReward_T;

void Money_AddMoney( entity ePlayer, int iMoneyValue ) {
	ePlayer.fMoney += (float)iMoneyValue;
	
	if ( ePlayer.fMoney > CS_MAX_MONEY ) {
		ePlayer.fMoney = CS_MAX_MONEY;
	}
	
	// Because people do tend to kill hostages...
	if ( ePlayer.fMoney < 0 ) {
		ePlayer.fMoney = 0;
	}
}

void Money_QueTeamReward( float fTeam, int iMoneyValue ) {
	if ( fTeam == TEAM_T ) {
		iMoneyReward_T += iMoneyValue;
	} else {
		iMoneyReward_CT += iMoneyValue;
	}
}

void Money_GiveTeamReward( void ) {
	if ( self.team == TEAM_T ) {
		Money_AddMoney( self, iMoneyReward_T );
	} else {
		Money_AddMoney( self, iMoneyReward_CT );
	}
}

void Money_ResetTeamReward( void ) {
	iMoneyReward_T = 0;
	iMoneyReward_CT = 0;
}
