/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

entity eLastTSpawn;
entity eLastCTSpawn;

/*
=================
Spawn_FindSpawnPoint

Recursive function that gets the next spawnpoint
=================
*/
entity Spawn_FindSpawnPoint(float fTeam)
{
	entity eSpot, eLastSpawn;
	entity eThing;
	int iCount;
	string sClassname;

	if (fTeam == TEAM_T) {
		sClassname = "info_player_deathmatch";
		eSpot = eLastSpawn = eLastTSpawn;
	} else if (fTeam == TEAM_CT) {
		sClassname = "info_player_start";
		eSpot = eLastSpawn = eLastCTSpawn;
	} else if (fTeam == TEAM_VIP) {
		return find(world, classname, "info_vip_start");
	}

	while (1) {
		eSpot = find(eSpot, classname, sClassname);
		
		if (eSpot == eLastSpawn)
		{//fall back on lame cycling/spawnfragging
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
Spawn_RespawnClient

Called whenever a player just needs his basic properties to be reset
=================
*/
void Spawn_RespawnClient(int fTeam)
{
	entity eSpawn;
	forceinfokey(self, "*spec", "0");
	eSpawn = Spawn_FindSpawnPoint(self.team);

	self.classname = "player";
	self.health = self.max_health = 100;
	forceinfokey(self, "*dead", "0");
	Rules_CountPlayers();

	self.takedamage = DAMAGE_YES;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;
	//self.Pain = Player_Pain;
	//self.Death = Player_Death;
	self.iBleeds = TRUE;
	self.viewzoom = 1.0; // Clear scopes

	self.origin = eSpawn.origin;
	self.angles = eSpawn.angles;

	// Get the player-model from Defs.h's list
	
		setmodel(self, "models/player/vip/vip.mdl");
	
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.view_ofs = VEC_PLAYER_VIEWPOS;
	self.velocity = '0 0 0';

	self.frame = 1; // Idle frame

	/*Ammo_AutoFill(self.fSlotPrimary);
	Ammo_AutoFill(self.fSlotSecondary);*/
}

/*
=================
Spawn_CreateClient

Called whenever a player becomes a completely new type of player
=================
*/
void Spawn_CreateClient(int fCharModel)
{
	player pl = (player)self;
	// What team are we on - 0= Spectator, < 5 Terrorists, CT rest
	if (fCharModel == 0) {
		PutClientInServer();
		Spawn_ObserverCam();
		return;
	} else if(fCharModel < 5) {
		forceinfokey(self, "*team", "0"); 
		pl.team = TEAM_T;
		pl.g_items |= ITEM_SUIT;
		
		Weapons_AddItem(pl, WEAPON_KNIFE);
		if (autocvar_fcs_knifeonly == FALSE) {
			Weapons_AddItem(pl, WEAPON_GLOCK18);
			/*Weapon_GiveAmmo(WEAPON_GLOCK18, 40);*/
			/*Weapon_Draw(WEAPON_GLOCK18);*/
		} else {
			/*Weapon_Draw(WEAPON_KNIFE);*/
		}
	} else {
		pl.team = TEAM_CT;
		pl.g_items |= ITEM_SUIT;

		Weapons_AddItem(pl, WEAPON_KNIFE);
		if (autocvar_fcs_knifeonly == FALSE) {
			Weapons_AddItem(pl, WEAPON_USP45);
			/*Weapon_GiveAmmo(WEAPON_USP45, 24);*/
			/*Weapon_Draw(WEAPON_USP45);*/
		} else {
			/*Weapon_Draw(WEAPON_KNIFE);*/
		}
	}

	if(pl.ingame == FALSE) {
		pl.ingame = TRUE;
	}

	forceinfokey(self, "*team", ftos(pl.team)); 
	Spawn_RespawnClient(pl.team);
}

/*
=================
Spawn_MakeSpectator

Called on connect and whenever a player dies
=================
*/
void Spawn_MakeSpectator(void)
{
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
	forceinfokey(self, "*spec", "2"); // Make sure we are known as a spectator

	//Ammo_Clear();

	// Clear the inventory
	self.items = 0x0;
}

/*
=================
CSEv_GamePlayerSpawn_f

Event Handling, called by the Client codebase via 'sendevent'
=================
*/
void CSEv_GamePlayerSpawn_f(int fChar)
{
	player pl = (player)self;
	if (pl.team == TEAM_VIP) {
		centerprint(self, "You are the VIP!\nYou cannot switch roles now.\n");
		return;
	}

	// Hey, we are alive and are trying to switch teams, so subtract us from the Alive_Team counter.
	if (pl.health > 0) {
		pl.health = 0;
		Rules_CountPlayers();
		Rules_DeathCheck();
		Player_Death(0);
	}

	/*Ammo_Clear();*/

	// Spawn the players immediately when its in the freeze state
	switch (g_cs_gamestate) {
		case GAME_FREEZE:
			pl.charmodel = fChar;
			Spawn_CreateClient(fChar);

			if ((pl.team == TEAM_T) && (g_cs_alive_t == 1)) {
				if (g_cs_bombzones > 0) {
					Rules_MakeBomber();
				}
			} else if ((pl.team == TEAM_CT) && (g_cs_alive_ct == 1)) {
				if (g_cs_vipzones > 0) {
					Rules_MakeVIP();
				}
			}

			break;
		default:
			if (fChar == 0) {
				PutClientInServer();
				return;
			} else if(fChar < 5) {
				pl.team = TEAM_T;
			} else {
				pl.team = TEAM_CT;
			}

			Spawn_MakeSpectator();
			pl.classname = "player";
			pl.charmodel = fChar;
			pl.health = 0;
			forceinfokey(self, "*dead", "1");
			forceinfokey(self, "*team", ftos(pl.team)); 
			break;
	}

	pl.frags = 0;
	pl.deaths = 0;
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

	// Split up for readability and expandability?
	if ((pl.team == TEAM_T) && (g_cs_alive_t == 0)) {
		Rules_RoundOver(FALSE, 0, FALSE);
	} else if ((pl.team == TEAM_CT) && (g_cs_alive_ct == 0)) {
		Rules_RoundOver(FALSE, 0, FALSE);
	}
}

/*
=================
info_player_start

Counter-Terrorist Spawnpoints
=================
*/
void info_player_start(void)
{
	if (autocvar_fcs_swapteams == TRUE) {
		self.classname = "info_player_deathmatch";
	}
}

/*
=================
info_player_deathmatch

Terrorist Spawnpoints
=================
*/
void info_player_deathmatch(void)
{
	if (autocvar_fcs_swapteams == TRUE) {
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
void info_vip_start(void)
{
}
