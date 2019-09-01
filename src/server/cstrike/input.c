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
	// Dead, specatator
	if (self.health <= 0) {
		/*if (self.button2) {
			if (infokey(self, "*spectator") == "0") {
				forceinfokey(self, "*spectator", "1");
			} else {
				forceinfokey(self, "*spectator", "1");
			}
		}*/
		return;
	}
	
	// TODO: Make this fast switch only
	if (self.impulse == 3) {
		Weapon_Switch(SLOT_MELEE);
	} else if (self.impulse == 2) {
		Weapon_Switch(SLOT_SECONDARY);
	} else if (self.impulse == 1) {
		Weapon_Switch(SLOT_PRIMARY);
	} else if (self.impulse == 4) {
		Weapon_Switch(SLOT_GRENADE);
	}

	if (input_buttons & INPUT_BUTTON5) {
		Player_UseDown(); 
	} else {
		Player_UseUp();
	}
	
	if (input_buttons & INPUT_BUTTON0) {
		if (fGameState != GAME_FREEZE) {
			Weapon_PrimaryAttack(self.weapon);
		}
	} else if (input_buttons & INPUT_BUTTON4) {
		Weapon_Reload(self.weapon);
	} else if (input_buttons & INPUT_BUTTON3) {
		Weapon_SecondaryAttack(self.weapon);
	} else {
		Weapon_Release();
	}

	if (self.impulse == 100) {
		Flashlight_Toggle();
	}

	self.impulse = 0; 
}
