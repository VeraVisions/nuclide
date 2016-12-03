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

void ClientKill( void ) {}


void ClientConnect( void ) {}

void ClientDisconnect( void ) {
	// We were part of the session
	if( self.fInGame == TRUE ) {
		fInGamePlayers--;
	}
}

void PlayerPreThink( void ) { 
	Input_Handle();
}

void PlayerPostThink( void ) {
	
}

void PutClientInServer( void ) {
	entity eSpawn;
	eSpawn = find (world, classname, "trigger_camera");

	self.classname = "spectator";
	self.health = self.max_health = 999;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FLY;
	self.flags = FL_CLIENT;

	self.origin = eSpawn.origin + '0 0 1';
	
	// Rotate camera towards a target
	if( eSpawn.target ) {
		entity eTarget = find( eTarget, targetname, eSpawn.target );
		self.angles = vectoangles( eTarget.origin - eSpawn.origin );
		self.angles_x *= -1;
	} else {	
		self.angles = eSpawn.angles;
	}
	
	self.fixangle = TRUE;

	self.model = 0;
	setsize (self, '-16 -16 -16', '16 16 16');

	self.view_ofs = self.velocity = '0 0 0';
	
	forceinfokey( self, "*spectator", "1" ); // Make sure we are known as a spectator
}

void SV_RunClientCommand( void ) {
	
	// The individual zones will just override this behavior
	self.fInBombZone = FALSE;
	self.fInBuyZone = FALSE;
	self.fInHostageZone = FALSE;
	
	if( fGameState != GAME_ACTIVE ) {
		input_movevalues = '0 0 0';
		input_buttons = 0;
		input_impulse = 0;
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
