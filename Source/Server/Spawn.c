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

entity eLastTSpawn;
entity eLastCTSpawn;
entity Spawn_FindSpawnPoint( float fTeam ) {
	entity eSpot, eLastSpawn;
	entity eThing;
	int iCount;
	string sClassname;

	if ( fTeam == TEAM_T ) {
		sClassname = "info_player_deathmatch";
		eSpot = eLastSpawn = eLastTSpawn;
	} else if ( fTeam == TEAM_CT ) {
		sClassname = "info_player_start";
		eSpot = eLastSpawn = eLastCTSpawn;
	} else if ( fTeam == TEAM_VIP ) {
		return find( world, classname, "info_vip_start" );
	}

	while (1) {
		eSpot = find(eSpot, classname, sClassname);
		
		if (eSpot != world) {
			if (eSpot == eLastSpawn)
				return eLastSpawn;
			iCount = 0;
			eThing = findradius(eSpot.origin, 32);
			while(eThing) {
				if (eThing.classname == "player")
					iCount++;
				eThing = eThing.chain;
			}
			if (iCount == 0) {
				eLastSpawn = eSpot;
				return eSpot;
			}
		}
	}

	return eSpot;
}

void Spawn_ObserverCam( void ) {
	// Go find a camera if we aren't dead
	entity eCamera = find ( world, classname, "trigger_camera" );
	
	if ( eCamera ) {
		self.origin = eCamera.origin;
		
		if ( eCamera.target ) {
			entity eTarget = find( world, targetname, eCamera.target );
			if ( eTarget ) {
				self.angles = vectoangles( eTarget.origin - eCamera.origin );
				self.angles_x *= -1;
			}
		}
	}
	
	self.fixangle = TRUE;
}

void Spawn_RespawnClient( float fTeam ) {
	entity eSpawn;
	forceinfokey( self, "*spectator", "0" ); // Make sure we are known as a spectator
	eSpawn = Spawn_FindSpawnPoint( self.team );

	self.classname = "player";
	self.health = self.max_health = 100;
	forceinfokey( self, "*dead", "0" );
	
	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;
	self.vPain = Player_Pain;
	self.vDeath = Player_Death;

	self.origin = eSpawn.origin;
	self.angles = eSpawn.angles;
	self.fixangle = TRUE;

	// Get the player-model from Defs.h's list
	if ( self.team != TEAM_VIP ) {
		setmodel( self, sCSPlayers[ self.fCharModel ] );
	} else {
		setmodel( self, "models/player/vip/vip.mdl" );
	}
	setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );

	self.view_ofs = VEC_PLAYER_VIEWPOS;
	self.velocity = '0 0 0';
	
	self.frame = 1; // Idle frame
	self.fBombProgress = 0;
}

void Spawn_CreateClient( float fCharModel ) {
	// What team are we on - 0= Spectator, < 5 Terrorists, CT rest
	if( fCharModel == 0 ) {
		PutClientInServer();
		Spawn_ObserverCam();
		return;
	} else if( fCharModel < 5 ) {
		forceinfokey( self, "*team", "0" ); 
		self.team = TEAM_T;
		iAlivePlayers_T++;
		
		Weapon_AddItem( WEAPON_KNIFE );
		Weapon_AddItem( WEAPON_GLOCK18 );
		Weapon_GiveAmmo( WEAPON_GLOCK18, 40 );
		Weapon_Draw( WEAPON_GLOCK18 );
	} else {
		self.team = TEAM_CT;
		iAlivePlayers_CT++;

		Weapon_AddItem( WEAPON_KNIFE );
		Weapon_AddItem( WEAPON_USP45 );
		Weapon_GiveAmmo( WEAPON_USP45, 24 );
		Weapon_Draw( WEAPON_GLOCK18 ); 
	}
	
	if( self.iInGame == FALSE ) {
		self.iInGame = TRUE;
	}
	
	forceinfokey( self, "*team", ftos( self.team ) ); 
	Spawn_RespawnClient( self.team );
	self.fAttackFinished = time + 1;
}

// This is called on connect and whenever a player dies
void Spawn_MakeSpectator( void ) {
	self.classname = "spectator";
	
	self.health = 0;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NOCLIP;
	self.flags = FL_CLIENT;
	self.weapon = 0;

	self.model = 0;
	setsize (self, '-16 -16 -16', '16 16 16');

	self.view_ofs = self.velocity = '0 0 0';
	forceinfokey( self, "*spectator", "1" ); // Make sure we are known as a spectator

	// Clear all the ammo stuff
	for ( int i = 0; i < CS_WEAPON_COUNT; i++ ) {
		self.(wptTable[ i ].iMagfld) = 0;
		self.(wptTable[ i ].iCaliberfld) = 0;
	}
	
	// Clear the inventory
	self.fSlotMelee = self.fSlotPrimary = self.fSlotSecondary = self.fSlotGrenade = 0;
}

// Event Handling, called by the Client codebase via 'sendevent'
void CSEv_GamePlayerSpawn_f( float fChar ) {
	
	if ( self.team == TEAM_VIP ) {
		centerprint( self, "You are the VIP!\nYou cannot switch roles now.\n" );
		self.fAttackFinished = time + 1.0;
		return;
	}
	
	switch ( fGameState ) {
		case GAME_INACTIVE:
		case GAME_COMMENCING:
		case GAME_ACTIVE:
		case GAME_END:
			if( fChar == 0 ) {
				PutClientInServer();
				return;
			} else if( fChar < 5 ) {
				self.team = TEAM_T;
			} else {
				self.team = TEAM_CT;
			}
			
			Spawn_MakeSpectator();
			self.classname = "player";
			self.fCharModel = fChar;
			self.health = 0;
			forceinfokey( self, "*dead", "1" );
			forceinfokey( self, "*team", ftos( self.team ) ); 
			break;
		default:
			self.fCharModel = fChar;
			Spawn_CreateClient( fChar );
		break;
		
	}
	
	self.frags = 0;
	self.fDeaths = 0;
	forceinfokey( self, "*deaths", "0" );
}

// Counter-Terrorist Spawnpoints
void info_player_start( void ) {
}

// Terrorist Spawnpoints
void info_player_deathmatch( void ) {
}

// VIP Spawnpoints
void info_vip_start( void ) {
}

void info_target( void ) { 
	setorigin( self, self.origin );
}
