/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
Game_Input(player pl)
{
#ifdef SERVER
	CGameRules rules = (CGameRules)g_grMode;

	if (rules.m_iIntermission) {
		rules.IntermissionEnd();
		return;
	}

	if (input_buttons & INPUT_BUTTON5)
		pl.InputUse_Down(); 
	else
		pl.InputUse_Up();

	if (pl.impulse == 100)
		Flashlight_Toggle();

	pl.impulse = 0;
#endif

	if (pl.health <= 0) {
		Weapons_Release(pl);
		return;
	}

	NSVehicle veh = (NSVehicle)pl.vehicle;
	bool canfire = true;
	if (veh)
		if (veh.PreventPlayerFire() == true)
			canfire = false;

	if (canfire == false)
		return;

	if (input_buttons & INPUT_BUTTON0)
		Weapons_Primary(pl);
	else if (input_buttons & INPUT_BUTTON4)
		Weapons_Reload(pl);
	else if (input_buttons & INPUT_BUTTON3)
		Weapons_Secondary(pl);
	else
		Weapons_Release(pl);
}
