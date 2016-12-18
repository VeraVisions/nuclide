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

/* Called when a spectator joins the game. */
void SpectatorConnect( void ) {
	Spawn_MakeSpectator();
	Spawn_ObserverCam();
}
	
void SpectatorDisconnect( void ) {
	
}
	
void SpectatorThink( void ) {
	
}

void ClientKill( void ) {}


void ClientConnect( void ) {}

void ClientDisconnect( void ) {
	// We were part of the session
	if( self.iInGame == TRUE ) {
		if ( self.team == TEAM_T ) {
			if ( self.health > 0 ) {
				iAlivePlayers_T--;
			}
		} else if ( self.team == TEAM_CT ) {
			if ( self.health > 0 ) {
				iAlivePlayers_CT--;
			}
		}
	}
}

void PlayerPreThink( void ) { 
	Input_Handle();
	OpenCSGunBase_ShotMultiplierUpdate();
}

void PlayerPostThink( void ) {
	Animation_PlayerUpdate();
}

void PutClientInServer( void ) {
	entity eTarget = world;

	Spawn_MakeSpectator();
	Spawn_ObserverCam();
	//self.SendEntity = Player_SendEntity;
	
	// Because we don't want to reset these when we die
	Money_AddMoney( self, autocvar_mp_startmoney );
	
	self.team = 0;
	forceinfokey( self, "*team", "0" ); 
}

void SV_RunClientCommand( void ) {
	
	// The individual zones will just override this behavior
	self.fInBombZone = FALSE;
	self.fInBuyZone = FALSE;
	self.fInHostageZone = FALSE;
	
	if( fGameState == GAME_FREEZE && self.team != 0 ) {
		input_movevalues = '0 0 0';
		input_buttons = 0;
		input_impulse = 0;
	}
	
	if ( self.team && self.health > 0 ) {
		self.SendFlags |= PLAYER_SENDFLAG_INGAME;
	} else {
		self.SendFlags |= PLAYER_SENDFLAG_UPDATE;
	}
	
	Footsteps_Update();

	runstandardplayerphysics( self );
}

void Client_SendEvent( entity eClient, float fEVType ) {
	Weapon_UpdateCurrents();
	
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, fEVType );

	msg_entity = eClient;
	multicast( '0 0 0', MULTICAST_ONE );
}

void Client_TriggerCamera( entity eTarget, vector vPos, vector vEndPos, float fResetTime ) {
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	
	WriteByte( MSG_MULTICAST, EV_CAMERATRIGGER );
	
	WriteCoord( MSG_MULTICAST, vPos_x );
	WriteCoord( MSG_MULTICAST, vPos_y );
	WriteCoord( MSG_MULTICAST, vPos_z );
	
	WriteCoord( MSG_MULTICAST, vEndPos_x );
	WriteCoord( MSG_MULTICAST, vEndPos_y );
	WriteCoord( MSG_MULTICAST, vEndPos_z );
	
	WriteFloat( MSG_MULTICAST, fResetTime );
	msg_entity = eTarget;
	multicast( '0 0 0', MULTICAST_ONE );
}
