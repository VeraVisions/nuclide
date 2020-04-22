/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

void
Game_Input(void)
{
	if (input_buttons & INPUT_BUTTON0) {
		Weapons_Primary();
	} else if (input_buttons & INPUT_BUTTON4) {
		Weapons_Reload();
	} else if (input_buttons & INPUT_BUTTON3) {
		Weapons_Secondary();
	} else {
		Weapons_Release();
	}

	if (input_buttons & INPUT_BUTTON5) {
		Player_UseDown(); 
	} else {
		Player_UseUp();
	}

	if (self.impulse == 100) {
		Flashlight_Toggle();
	}
	
	if (self.impulse == 240) {
		entity bot = Bot_AddQuick();
		if (bot) {
			entity oself = self;
			self = bot;
			CSEv_JoinAuto();
			self = oself;
		}
	}

	if (cvar("sv_cheats") == 1) {
		player pl = (player)self;
		if (self.impulse == 101) {
			pl.health = 100;
			pl.armor = 100;

			Weapons_AddItem(pl, WEAPON_M3);
			Weapons_AddItem(pl, WEAPON_XM1014);
			Weapons_AddItem(pl, WEAPON_MP5);
			Weapons_AddItem(pl, WEAPON_P90);
			Weapons_AddItem(pl, WEAPON_UMP45);
			Weapons_AddItem(pl, WEAPON_MAC10);
			Weapons_AddItem(pl, WEAPON_TMP);
			Weapons_AddItem(pl, WEAPON_AK47);
			Weapons_AddItem(pl, WEAPON_SG552);
			Weapons_AddItem(pl, WEAPON_M4A1);
			Weapons_AddItem(pl, WEAPON_AUG);
			Weapons_AddItem(pl, WEAPON_SCOUT);
			Weapons_AddItem(pl, WEAPON_AWP);
			Weapons_AddItem(pl, WEAPON_G3SG1);
			Weapons_AddItem(pl, WEAPON_SG550);
			Weapons_AddItem(pl, WEAPON_PARA);
			Weapons_AddItem(pl, WEAPON_C4BOMB);
			Weapons_AddItem(pl, WEAPON_FLASHBANG);
			Weapons_AddItem(pl, WEAPON_HEGRENADE);
			Weapons_AddItem(pl, WEAPON_SMOKEGRENADE);
			Weapons_AddItem(pl, WEAPON_USP45);
			Weapons_AddItem(pl, WEAPON_GLOCK18);
			Weapons_AddItem(pl, WEAPON_DEAGLE);
			Weapons_AddItem(pl, WEAPON_P228);
			Weapons_AddItem(pl, WEAPON_ELITES);
			Weapons_AddItem(pl, WEAPON_FIVESEVEN);
			Weapons_AddItem(pl, WEAPON_KNIFE);
		}

		if (self.impulse == 102) {
			// Respawn all the entities
			for (entity a = world; (a = findfloat(a, ::gflags, GF_CANRESPAWN));) {
				CBaseEntity caw = (CBaseEntity)a;
				caw.Respawn();
			}
			bprint(PRINT_HIGH, "Respawning all map entities...\n");
		}
	}

	self.impulse = 0;
}
