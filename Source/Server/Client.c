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

/*
=================
SpectatorThink

Run every frame on every spectator
=================
*/
void SpectatorThink( void ) {
	self.SendFlags = 1;
}

/*
=================
ClientKill

Suicide command 'kill' executes this function.
=================
*/
void ClientKill( void ) {
	Damage_Apply( self, self, self.health, self.origin, TRUE );
}

/*
=================
ClientConnect

Run whenever a new client joins
=================
*/
void ClientConnect( void ) {}

/*
=================
SpectatorConnect

Called when a spectator joins the game
=================
*/
void SpectatorConnect( void ) {
	//Spawn_MakeSpectator();
	//Spawn_ObserverCam();
	ClientConnect();
	PutClientInServer();
}

/*
=================
SpectatorDisconnect

Called when a spectator leaves the game
=================
*/
void SpectatorDisconnect( void ) {
	Effect_RemoveSpray( self );
}

/*
=================
ClientDisconnect

Run whenever a client quits
=================
*/
void ClientDisconnect( void ) {
	// We were part of the session
	self.health = 0;
	Rules_CountPlayers();
	Rules_DeathCheck();
	Effect_RemoveSpray( self );
}

/*
=================
PutClientInServer

Puts a client into the world.
=================
*/
void PutClientInServer( void ) {
	entity eTarget = world;

	Spawn_MakeSpectator();
	Spawn_ObserverCam();
	self.SendEntity = Player_SendEntity;
	
	// Because we don't want to reset these when we die
	Money_AddMoney( self, autocvar_mp_startmoney );
	
	if ( cvar( "mp_timelimit" ) > 0 ) {
		if ( autocvar_sv_voxannounce == TRUE ) {
			float fTimeLeft = cvar( "mp_timelimit" ) - ( time / 60 );
			Vox_Singlecast( self, sprintf( "we have %s minutes remaining", Vox_TimeToString( fTimeLeft ) ) );
		}
	}
	
	self.team = 0;
	forceinfokey( self, "*team", "0" ); 
}

/*
=================
SV_RunClientCommand

Funtion that can interrupt client commands before physics are run
=================
*/
void SV_RunClientCommand( void ) {
	if (clienttype(self) == CLIENTTYPE_BOT) {
		((CBot)self).RunAI();
	}

	if ( fGameState == GAME_FREEZE && self.health > 0 ) {
		input_movevalues = '0 0 0';
		//input_buttons = 0;
		input_impulse = 0;
	}

	// The individual zones will just override this behavior
	self.fInBombZone = FALSE;
	self.fInBuyZone = FALSE;
	self.fInHostageZone = FALSE;

	QPhysics_Run( self );

	Input_Handle();
}

/*
=================
Client_SendEvent

Send a game event
=================
*/
void Client_SendEvent( entity eClient, float fEVType ) {
	Weapon_UpdateCurrents();
	
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, fEVType );
	WriteByte( MSG_MULTICAST, num_for_edict( eClient ) );
	msg_entity = eClient;
	multicast( self.origin, MULTICAST_PVS );
}

/*
=================
Client_TriggerCamera

Switches the player camera to a different position for a specific time
=================
*/
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
