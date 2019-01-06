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
	forceinfokey( self, "*spec", "0" );
	eSpawn = Spawn_FindSpawnPoint( self.team );

	self.classname = "player";
	self.health = self.max_health = 100;
	forceinfokey( self, "*dead", "0" );
	Rules_CountPlayers();

	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;
	self.vPain = Player_Pain;
	self.vDeath = Player_Death;
	self.iBleeds = TRUE;
	self.fSlotC4Bomb = 0; // Clear the C4
	self.viewzoom = 1.0; // Clear scopes

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

	Ammo_AutoFill(self.fSlotPrimary);
	Ammo_AutoFill(self.fSlotSecondary);
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

	Ammo_Clear();

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
		self.health = 0;
		Rules_CountPlayers();
		Rules_DeathCheck();
		Player_Death(0);
	}

	Ammo_Clear();

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

/* Counter-Strike: Source compat */
void info_player_counterterrorist(void)
{
	setorigin(self, self.origin + [0,0,32]);
	self.classname = "info_player_start";
	info_player_start();
}

void info_player_terrorist(void)
{
	setorigin(self, self.origin + [0,0,32]);
	self.classname = "info_player_deathmatch";
	info_player_deathmatch();
}

/*
=================
info_vip_start
=================
*/
void info_vip_start( void ) {
}
