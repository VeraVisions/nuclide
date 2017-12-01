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

entity eLastTSpawn;
entity eLastCTSpawn;

/*
=================
Spawn_FindSpawnPoint

Recursive function that gets the next spawnpoint
=================
*/
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

	while ( 1 ) {
		eSpot = find(eSpot, classname, sClassname);
		
		if (eSpot == eLastSpawn)
		{	//fall back on lame cycling/spawnfragging
			eLastSpawn = find(eLastSpawn, classname, sClassname);
			if (!eLastSpawn)
				eLastSpawn = find(eLastSpawn, classname, sClassname);
			return eLastSpawn;
		}
		if (eSpot != world) {
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

/*
=================
Spawn_ObserverCam

Look for the next spawnpoint
=================
*/
void Spawn_ObserverCam( void ) {
	entity eTarget;
	
	// Go find a camera if we aren't dead
	entity eCamera = find ( world, classname, "trigger_camera" );
	
	if ( eCamera ) {
		self.origin = eCamera.origin;
		
		if ( eCamera.target ) {
			eTarget = find( world, targetname, eCamera.target );
			if ( eTarget ) {
				self.angles = vectoangles( eTarget.origin - eCamera.origin );
				self.angles_x *= -1;
			}
		}
	} else {
		// Can't find a camera? Just do this lazy thing, CS seems to do the same
		eCamera = find ( world, classname, "info_player_start" );
		
		if ( eCamera ) {
			self.origin = eCamera.origin;
			
			if ( eCamera.target ) {
				eTarget = find( world, targetname, eCamera.target );
				if ( eTarget ) {
					self.angles = vectoangles( eTarget.origin - eCamera.origin );
					self.angles_x *= -1;
				}
			}
		}
	}
	
	self.fixangle = TRUE;
}

/*
=================
Spawn_RespawnClient

Called whenever a player just needs his basic properties to be reset
=================
*/
void Spawn_RespawnClient( float fTeam ) {
	entity eSpawn;
	forceinfokey( self, "*spec", "0" ); // Make sure we are known as a spectator
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
	self.iBleeds = TRUE;
	self.fSlotGrenade = 0; // Clear the C4

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

/*
=================
Spawn_CreateClient

Called whenever a player becomes a completely new type of player
=================
*/
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
		if ( autocvar_fcs_knifeonly == FALSE ) {
			Weapon_AddItem( WEAPON_GLOCK18 );
			Weapon_GiveAmmo( WEAPON_GLOCK18, 40 );
			Weapon_Draw( WEAPON_GLOCK18 );
		} else {
			Weapon_Draw( WEAPON_KNIFE );
		}
	} else {
		self.team = TEAM_CT;
		iAlivePlayers_CT++;

		Weapon_AddItem( WEAPON_KNIFE );
		if ( autocvar_fcs_knifeonly == FALSE ) {
			Weapon_AddItem( WEAPON_USP45 );
			Weapon_GiveAmmo( WEAPON_USP45, 24 );
			Weapon_Draw( WEAPON_USP45 );
		} else {
			Weapon_Draw( WEAPON_KNIFE );
		}
	}
	
	if( self.iInGame == FALSE ) {
		self.iInGame = TRUE;
	}
	
	forceinfokey( self, "*team", ftos( self.team ) ); 
	Spawn_RespawnClient( self.team );
	self.fAttackFinished = time + 1;
}

/*
=================
Spawn_MakeSpectator

Called on connect and whenever a player dies
=================
*/
void Spawn_MakeSpectator( void ) {
	self.classname = "spectator";
	
	self.health = 0;
	self.armor = 0;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NOCLIP;
	self.flags = FL_CLIENT;
	self.weapon = 0;
	self.viewzoom = 1.0f;

	self.model = 0;
	setsize (self, '-16 -16 -16', '16 16 16');

	self.view_ofs = self.velocity = '0 0 0';
	forceinfokey( self, "*spec", "2" ); // Make sure we are known as a spectator

	// Clear all the ammo stuff
	for ( int i = 0; i < CS_WEAPON_COUNT; i++ ) {
		self.(wptTable[ i ].iMagfld) = 0;
		self.(wptTable[ i ].iCaliberfld) = 0;
	}
	
	// Clear the inventory
	self.fSlotMelee = self.fSlotPrimary = self.fSlotSecondary = self.fSlotGrenade = self.iEquipment = 0;
}

/*
=================
CSEv_GamePlayerSpawn_f

Event Handling, called by the Client codebase via 'sendevent'
=================
*/
void CSEv_GamePlayerSpawn_f( float fChar ) {
	
	if ( self.team == TEAM_VIP ) {
		centerprint( self, "You are the VIP!\nYou cannot switch roles now.\n" );
		self.fAttackFinished = time + 1.0;
		return;
	}
	
	// Hey, we are alive and are trying to switch teams, so subtract us from the Alive_Team counter.
	if ( self.health > 0 ) {
		if ( self.team == TEAM_T ) {
			iAlivePlayers_T--;
		} else if ( self.team == TEAM_CT ) {
			iAlivePlayers_CT--;
		}
	}
	
	self.fSlotMelee = 0;
	self.fSlotPrimary = 0;
	self.fSlotSecondary = 0;
	self.fSlotGrenade = 0;
	self.iEquipment = 0;
	
	// Spawn the players immediately when its in the freeze state
	switch ( fGameState ) {
		case GAME_FREEZE:
			self.fCharModel = fChar;
			Spawn_CreateClient( fChar );
			
			if ( ( self.team == TEAM_T ) && ( iAlivePlayers_T == 1 ) ) {
				if ( iBombZones > 0 ) {
					Rules_MakeBomber();
				}
			} else if ( ( self.team == TEAM_CT ) && ( iAlivePlayers_CT == 1 ) ) {
				if ( iVIPZones > 0 ) {
					Rules_MakeVIP();
				}
			}
			
			break;
		default:
			if ( fChar == 0 ) {
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
	}
	
	self.frags = 0;
	self.fDeaths = 0;
	forceinfokey( self, "*deaths", "0" );
	
	// Split up for readability and expandability?
	if ( ( self.team == TEAM_T ) && ( iAlivePlayers_T == 0 ) ) {
		Rules_RoundOver( FALSE, 0, FALSE );
	} else if ( ( self.team == TEAM_CT ) && ( iAlivePlayers_CT == 0 ) ) {
		Rules_RoundOver( FALSE, 0, FALSE );
	}
}

/*
=================
info_player_start

Counter-Terrorist Spawnpoints
=================
*/
void info_player_start( void ) {
	if ( autocvar_fcs_swapteams == TRUE ) {
		self.classname = "info_player_deathmatch";
	}
}

/*
=================
info_player_deathmatch

Terrorist Spawnpoints
=================
*/
void info_player_deathmatch( void ) {
	if ( autocvar_fcs_swapteams == TRUE ) {
		self.classname = "info_player_start";
	}
}

/*
=================
info_target

Cameras use this thing
=================
*/
void info_target( void ) { 
	setorigin( self, self.origin );
}

/*
=================
info_vip_start
=================
*/
void info_vip_start( void ) {
}
