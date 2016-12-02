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

void Spawn_GameClient( float fTeam ) {
	entity eSpawn;
	
	if( self.fInGame == FALSE ) {
		self.fInGame = TRUE;
		fInGamePlayers++;
	}
	
	// What team are we on - 0= Spectator, < 5 Terrorists
	if( fTeam == 0 ) {
		PutClientInServer();
		return;
	} else if( fTeam < 5 ) {
		eSpawn = find ( world, classname, "info_player_deathmatch" );
		self.team = TEAM_T; // This is only important to the Server codebase
		forceinfokey( self, "team", "t" ); // This is for the Client codebase
		
		// TODO: Move this away from here
		Weapon_AddItem( WEAPON_GLOCK18 );
		Weapon_GiveAmmo( WEAPON_GLOCK18, 40 );
	} else {
		eSpawn = find ( world, classname, "info_player_start" );
		self.team = TEAM_CT; // This is only important to the Server codebase
		forceinfokey( self, "team", "ct" ); // This is for the Client codebase
		
		// TODO: Move this away from here
		Weapon_AddItem( WEAPON_USP45 );
		Weapon_GiveAmmo( WEAPON_USP45, 24 );

	}
	
	forceinfokey( self, "*spectator", "0" ); // Make sure we are known as a spectator

	self.classname = "player";
	self.health = self.max_health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;

	self.origin = eSpawn.origin;
	self.angles = eSpawn.angles;
	self.fixangle = TRUE;

	// Get the player-model from Defs.h's list
	setmodel( self, sCSPlayers[ fTeam ] );
	setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );

	self.view_ofs = '0 0 24';
	self.velocity = '0 0 0';
	
	self.frame = 1; // Idle frame
	
	// Set the fields
	self.fMoney = cvar( "mp_startmoney" );
	self.fAttackFinished = time + 1;
}

// Event Handling, called by the Client codebase via 'sendevent'
void CSEv_GamePlayerSpawn_f( float fTeam ) {
	Spawn_GameClient( fTeam );
}

// Counter-Terrorist Spawnpoints
void info_player_start( void ) {
}

// Terrorist Spawnpoints
void info_player_deathmatch( void ) {
}

// Spectator Spawnpoints
void trigger_camera( void ) {
}
void info_target( void ) { }
