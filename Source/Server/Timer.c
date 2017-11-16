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

/*
=================
Timer_Begin

Initiates a new state timer
=================
*/
void Timer_Begin( float fTime, float fMode) {
	if ( fMode == GAME_FREEZE ) {
		fGameState = GAME_FREEZE;
	} else if ( fMode == GAME_ACTIVE ) {
		fGameState = GAME_ACTIVE;
	} else if ( fMode == GAME_END ) {
		fGameState = GAME_END;
	} else if ( fMode == GAME_COMMENCING ) {
		fGameState = GAME_COMMENCING;
	}
	
	fGameTime = fTime;
}

/*
=================
Timer_Update

Called once every frame to check the status of things
=================
*/
void Timer_Update( void ) {
	// This map has been played enough we think
	if ( time >= ( cvar( "mp_timelimit" ) * 60 ) ) {
		for ( int i = 0; i < iMapCycleCount; i++ ) {
			if ( sMapCycle[ i ] == mapname ) {
				if ( ( i + 1 ) < iMapCycleCount ) {
					localcmd( sprintf( "changelevel %s\n", sMapCycle[ i + 1 ] ) );
					return;
				} else {
					localcmd( sprintf( "changelevel %s\n", sMapCycle[ 0 ] ) );
				}
			}
		}
	}
	
	if ( fGameState == GAME_INACTIVE ) {
		return;
	}
	
	fGameTime -= frametime;
	
	if ( fGameState == GAME_COMMENCING || fGameState == GAME_END ) {
		if ( fGameTime <= 0 ) {
			Rules_Restart();
		}
		return;
	}
	
	if ( ( fGameState == GAME_ACTIVE ) || ( fGameState == GAME_FREEZE ) ) {
		if ( fGameTime <= 0 ) {
			if ( fGameState == GAME_ACTIVE ) {
				Rules_TimeOver();
				Timer_Begin( 5, GAME_END); // Round is over, 5 seconds til a new round starts
			} else {
				Timer_Begin( autocvar_mp_roundtime * 60, GAME_ACTIVE ); // Unfreeze
				Radio_StartMessage();	
			}
		}
	}
}
