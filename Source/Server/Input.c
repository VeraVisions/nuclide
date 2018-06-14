/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

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
	
	if ( self.button3 ) {
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
	} else if ( self.button5 ) {
		Weapon_SecondaryAttack( self.weapon );
	} else {
		Weapon_Release();
	}
	
	self.impulse = 0; 
}
