/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
Input_Handle

Handles impulse and whatnot
=================
*/
void Game_Input(void)
{
	if (self.button0) {
		Weapons_Primary();
	} else if (self.button4) {
		Weapons_Reload();
	} else if (self.button3) {
		Weapons_Secondary();
	} else {
		Weapons_Release();
	}

	if (self.button5) {
		Player_UseDown(); 
	} else {
		Player_UseUp();
	}

	if (self.impulse == 100) {
		if (self.flags & FL_FLASHLIGHT) {
			self.flags &= ~FL_FLASHLIGHT;
		} else {
			self.flags |= FL_FLASHLIGHT;
		}
		sound (self, CHAN_ITEM, "items/flashlight1.wav", 1, ATTN_IDLE);
	}

	if (cvar("sv_cheats") == 1) {
		player pl = (player)self;
		if (self.impulse == 101) {
			Weapons_AddItem(pl, WEAPON_CROWBAR);
			Weapons_AddItem(pl, WEAPON_GLOCK);
			Weapons_AddItem(pl, WEAPON_PYTHON);
			Weapons_AddItem(pl, WEAPON_MP5);
			Weapons_AddItem(pl, WEAPON_SHOTGUN);
			Weapons_AddItem(pl, WEAPON_CROSSBOW);
			Weapons_AddItem(pl, WEAPON_RPG);
			Weapons_AddItem(pl, WEAPON_GAUSS);
			Weapons_AddItem(pl, WEAPON_EGON);
			Weapons_AddItem(pl, WEAPON_HORNETGUN);
			Weapons_AddItem(pl, WEAPON_HANDGRENADE);
			Weapons_AddItem(pl, WEAPON_SATCHEL);
			Weapons_AddItem(pl, WEAPON_TRIPMINE);
			Weapons_AddItem(pl, WEAPON_SNARK);
		}
		
		if (self.impulse == 102) {
			// Respawn all the entities
			for (entity a = world; (a = findfloat(a, gflags, GF_CANRESPAWN));) {
				CBaseEntity caw = (CBaseEntity)a;
				caw.Respawn();
			}
			bprint(PRINT_HIGH, "Respawning all map entities...\n");
		}
	}
	
	self.impulse = 0;
}
