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

/*
=================
Input_Handle

Handles impulse and whatnot
=================
*/
void Game_Input(void)
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

	if (cvar("sv_cheats") == 1) {
		player pl = (player)self;
		if (self.impulse == 101) {
			pl.health = 100;
			pl.armor = 100;
			pl.g_items |= ITEM_SUIT;
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
				caw.SendFlags |= 
					BASEFL_CHANGED_ORIGIN |
					BASEFL_CHANGED_ANGLES |
					BASEFL_CHANGED_MODELINDEX |
					BASEFL_CHANGED_SIZE |
					BASEFL_CHANGED_SOLID |
					BASEFL_CHANGED_FRAME |
					BASEFL_CHANGED_SKIN |
					BASEFL_CHANGED_MOVETYPE |
					BASEFL_CHANGED_ALPHA |
					BASEFL_CHANGED_EFFECTS;
			}
			bprint(PRINT_HIGH, "Respawning all map entities...\n");
		}
	}
	
	self.impulse = 0;
}
