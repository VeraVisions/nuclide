/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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
}
