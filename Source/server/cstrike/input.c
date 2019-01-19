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
void Input_Handle( void ) {
	// Dead, specatator
	if ( self.health <= 0 ) {
		/*if ( self.button2 ) {
			if ( infokey( self, "*spectator" ) == "0" ) {
				forceinfokey( self, "*spectator", "1" );
			} else {
				forceinfokey( self, "*spectator", "1" );
			}
		}*/
		return;
	}
	
	// TODO: Make this fast switch only
	if ( self.impulse == 3 ) {
		Weapon_Switch( SLOT_MELEE );
	} else if ( self.impulse == 2 ) {
		Weapon_Switch( SLOT_SECONDARY );
	} else if ( self.impulse == 1 ) {
		Weapon_Switch( SLOT_PRIMARY );
	} else if ( self.impulse == 4 ) {
		Weapon_Switch( SLOT_GRENADE );
	} 
	
	if ( self.button5 ) {
		Player_UseDown(); 
	} else {
		Player_UseUp();
	}
	
	if ( self.button0 ) {
		if ( fGameState != GAME_FREEZE ) {
			Weapon_PrimaryAttack( self.weapon );
		}
	} else if ( self.button4 ) {
		Weapon_Reload( self.weapon );
	} else if ( self.button3 ) {
		Weapon_SecondaryAttack( self.weapon );
	} else {
		Weapon_Release();
	}
	
	self.impulse = 0; 
}
