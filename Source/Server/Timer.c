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

// Detects the state of the game that we are in and cycles between them. INACTIVE > FREEZE > INGAME > ACTIVE
void Timer_Begin( float fTime, float fMode) {
	if ( fMode == GAME_FREEZE ) {
		dprint( "[DEBUG] Game Freezetime\n" );
		fGameState = GAME_FREEZE;
	} else if ( fMode == GAME_ACTIVE ) {
		dprint( "[DEBUG] Game Started\n" );
		fGameState = GAME_ACTIVE;
	} else if ( fMode == GAME_END ) {
		dprint( "[DEBUG] Game Ended\n" );
		fGameState = GAME_END;
	}
	
	fGameTime = fTime;
}

void Timer_Update( void ) {
	if ( fGameTime <= 0 || fGameState == GAME_INACTIVE ) {
		return;
	}
	
	fGameTime -= frametime;
	
	if ( ( fGameState == GAME_ACTIVE ) || ( fGameState == GAME_FREEZE ) ) {
		if ( fGameTime <= 0 ) {
			if ( fGameState == GAME_ACTIVE ) {
				Timer_Begin( 5, GAME_END); // Round is over, 5 seconds til a new round starts
			} else {
				Timer_Begin( cvar( "mp_roundtime" ) * 60, GAME_ACTIVE ); // Unfreeze
				
				float fRand = ceil( random() * 6 );
				if ( fRand == 1 ) {
					sound(world, CHAN_VOICE, "radio/moveout.wav", 1, ATTN_NONE );
				} else if ( fRand == 2 ) {
					sound(world, CHAN_VOICE, "radio/locknload.wav", 1, ATTN_NONE );
				} else {
					sound(world, CHAN_VOICE, "radio/letsgo.wav", 1, ATTN_NONE );
				}
			}
		}
	} else if ( fGameState == GAME_END ) {
		if ( fGameTime <= 0 ) {
			// Restart round
		}
	}
}
