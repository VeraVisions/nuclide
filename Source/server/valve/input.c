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
void Input_Handle(void)
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

	if ( self.button5 ) {
		Player_UseDown(); 
	} else {
		Player_UseUp();
	}
	
	self.impulse = 0;
}
