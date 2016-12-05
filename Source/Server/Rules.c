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

// Checks if it is possible for players to buy anything
float Rules_BuyingPossible( void ) {
	if ( fGameState == GAME_ACTIVE ) {
		if ( ( ( cvar( "mp_roundtime" ) * 60 ) - fGameTime ) > cvar( "mp_buytime" ) ) {
			centerprint( self, sprintf( "%d seconds have passed...\nYou can't buy anything now!", cvar( "mp_buytime" ) ) );
			self.fAttackFinished = time + 1.0;
			return FALSE;
		}
	}
	
	return TRUE;
}

// Loop through all players and respawn them
void Rules_Restart( void ) {
	//localcmd( "restart_ents" );
	
	entity eFind = findchain( classname, "player" );
	
	while ( eFind ) {
		entity eOldSelf = self;
		self = eFind;
		
		if ( self.health > 0 ) {
			Spawn_RespawnClient( self.team );
		} else {
			Spawn_CreateClient( self.fCharModel );
		}
		
		self = eOldSelf;
		eFind = eFind.chain;
	}
	
	Timer_Begin( cvar( "mp_freezetime" ), GAME_FREEZE );
}

// This can happen whenever an objective is complete or time is up
void Rules_RoundOver( int iTeamWon ) {
	if ( iTeamWon == TEAM_T ) {
		sound( world, CHAN_VOICE, "radio/terwin.wav", 1.0, ATTN_NONE );
		iWon_T++;
	} else if ( iTeamWon == TEAM_CT ) {
		sound( world, CHAN_VOICE, "radio/ctwin.wav", 1.0, ATTN_NONE );
		iWon_CT++;
	} else {
		sound( world, CHAN_VOICE, "radio/rounddraw.wav", 1.0, ATTN_NONE );
	}
	
	Timer_Begin( 5, GAME_END); // Round is over, 5 seconds til a new round starts
}

// Whenever mp_roundtime was being counted down to 0
void Rules_TimeOver( void ) {
	if ( iBombZones > 0 ) {
		Rules_RoundOver( TEAM_CT );
	} else if ( iHostagesMax > 0 ) {
		// TODO: Broadcast_Print: Hostages have not been rescued!
		Rules_RoundOver( TEAM_T );
	} else {
		Rules_RoundOver( 0 );
	}
}
