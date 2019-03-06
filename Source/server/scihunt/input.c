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
		Flashlight_Toggle();
	}

	if (cvar("sv_cheats") == 1) {
		player pl = (player)self;

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
