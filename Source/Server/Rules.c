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

enum {
	BUY_BOTH,
	BUY_CT,
	BUY_T,
	BUY_NEITHER
};

/*
=================
Rules_BuyingPossible

Checks if it is possible for players to buy anything
=================
*/
float Rules_BuyingPossible( void ) {
	if ( self.health <= 0 ) {
		return FALSE;
	}
	
	if ( fGameState == GAME_ACTIVE ) {
		if ( ( ( autocvar_mp_roundtime * 60 ) - fGameTime ) > autocvar_mp_buytime ) {
			centerprint( self, sprintf( "%d seconds have passed...\nYou can't buy anything now!", autocvar_mp_buytime ) );
			self.fAttackFinished = time + 1.0;
			return FALSE;
		}
	}
	
	if ( self.team == TEAM_VIP ) {
		centerprint( self, "You are the VIP...\nYou can't buy anything!\n" );
		self.fAttackFinished = time + 1.0;
		return FALSE;
	}
	
	if ( iBuyRestriction == BUY_NEITHER ) {
		centerprint( self, "Sorry, you aren't meant\nto be buying anything.\n" );
		self.fAttackFinished = time + 1.0;
		return FALSE;
	}
	
	if ( iBuyRestriction != BUY_BOTH ) {
		if ( iBuyRestriction == BUY_CT && self.team == TEAM_T ) {
			centerprint( self, "Terrorists aren't allowed to\nbuy anything on this map!\n" );
			self.fAttackFinished = time + 1.0;
			return FALSE;
		} else if ( iBuyRestriction == BUY_T && self.team == TEAM_CT ) {
			centerprint( self, "CTs aren't allowed to buy\nanything on this map!\n" );
			self.fAttackFinished = time + 1.0;
			return FALSE;
		}
	}
	
	if ( self.fInBuyZone == FALSE ) {
		return FALSE;
	}
	
	return TRUE;
}

/*
=================
Rules_Restart

Loop through all ents and handle them
=================
*/
void Rules_Restart( void ) {
	iHostagesRescued = 0;
	
	entity eOld = self;
	
	// Spawn/Respawn everyone at their team position and give them $$$
	for ( entity eFind = world; ( eFind = find( eFind, classname, "player" ) ); ) {
		self = eFind;
		
		if ( self.health > 0 ) {
			Spawn_RespawnClient( self.team );
		} else {
			Spawn_CreateClient( self.fCharModel );
		}
		
		Money_GiveTeamReward();
	}
	
	// Clear the corpses/items
	for ( entity eFind = world; ( eFind = find( eFind, classname, "remove_me" ) ); ) {
		remove( eFind );
	}
	
	// Find the bombs. Destory them!
	for ( entity eFind = world; ( eFind = find( eFind, classname, "c4bomb" ) ); ) {
		remove( eFind );
	}
	
	// Select a random Terrorist for the bomb, if needed
	if ( iBombZones > 0 ) {
		int iRandomT = floor( random( 1, (float)iAlivePlayers_T + 1 ) ); 
		int iPickT = 0;
		
		for ( entity eFind = world; ( eFind = find( eFind, classname, "player" ) ); ) { 
			if ( eFind.team == TEAM_T ) {
				iPickT++;
				
				if ( iPickT == iRandomT ) {
					self = eFind;
					Weapon_AddItem( WEAPON_C4BOMB );
					centerprint( self, "You have the bomb!\nFind the target zone or DROP\nthe bomb for another Terrorist." );
				}
			}
		}
	} 
	
	// If there is a VIP, select a random CT to be it
	if ( iVIPZones > 0 ) {
		int iRandomCT = floor( random( 1, (float)iAlivePlayers_CT + 1 ) );
		int iPickCT = 0;

		for ( entity eFind = world; ( eFind = find( eFind, classname, "player" ) ); ) { 
			if ( eFind.team == TEAM_CT ) {
				iPickCT++;
				if ( iPickCT == iRandomCT ) {
					self = eFind;
					self.team = TEAM_VIP;
					Spawn_RespawnClient( self.team );
					centerprint( self, "You are the VIP\nMake your way to the safety zones!" );
					forceinfokey( self, "*dead", "2" );
				}
			}
		}

	}
	
	// Respawn all the entities
	for ( entity eFind = world; ( eFind = findfloat( eFind, fRespawns, TRUE ) ); ) { 
		self = eFind;
		Entities_Respawn();
	}
	
	self = eOld;
	
	Timer_Begin( autocvar_mp_freezetime, GAME_FREEZE );
	Money_ResetTeamReward();
}

/*
=================
Rules_RoundOver

This happens whenever an objective is complete or time is up
=================
*/
void Rules_RoundOver( int iTeamWon, int iMoneyReward, float fSilent ) {
	
	if ( fGameState != GAME_ACTIVE ) {
		return;
	}
	
	if ( iTeamWon == TEAM_T ) {
		if ( fSilent == FALSE ) {
			Radio_BroadcastMessage( RADIO_TERWIN );
		}
		iWon_T++;
	} else if ( iTeamWon == TEAM_CT ) {
		if ( fSilent == FALSE ) {
			Radio_BroadcastMessage( RADIO_CTWIN );
		}
		iWon_CT++;
	} else {
		if ( fSilent == FALSE ) {
			Radio_BroadcastMessage( RADIO_ROUNDDRAW );
		}
	}
	Money_QueTeamReward( iTeamWon, iMoneyReward );
	Timer_Begin( 5, GAME_END); // Round is over, 5 seconds til a new round starts
}

/*
=================
Rules_TimeOver

Whenever mp_roundtime was being counted down to 0
=================
*/
void Rules_TimeOver( void ) {
	if ( iVIPZones > 0 ) {
		Rules_RoundOver( TEAM_T, 3250, FALSE );
	} else if ( iBombZones > 0 ) {
		Rules_RoundOver( TEAM_CT, 3250, FALSE );
	} else if ( iHostagesMax > 0 ) {
		// TODO: Broadcast_Print: Hostages have not been rescued!
		Rules_RoundOver( TEAM_T, 3250, FALSE );
	} else {
		Rules_RoundOver( 0, 0, FALSE );
	}
}

/*
=================
SPAWN: info_map_parameters

Let's map authors decide who can buy stuff and who CAN'T.
Also allows people to set the bomb placing radius incase you want to use info_bomb_target.
=================
*/
.float buying;
.float bombradius;
void info_map_parameters( void ) {	
	if ( self.bombradius ) {
		iBombRadius = self.bombradius;
	}
	if ( self.buying ) {
		iBuyRestriction = self.buying;
	}
}
