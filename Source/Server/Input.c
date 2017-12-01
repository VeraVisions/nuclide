/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
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
	
	if ( fGameState == GAME_FREEZE ) {
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
	
	if ( self.button6 ) {
		Player_CrouchDown();
	} else if ( self.flags & FL_CROUCHING ) {
		Player_CrouchUp();
	}
	
	if ( self.button0 ) {
		Weapon_PrimaryAttack( self.weapon );
	} else if ( self.button4 ) {
		Weapon_Reload( self.weapon );
	} else if ( self.button5 ) {
		Weapon_SecondaryAttack( self.weapon );
	} else {
		Weapon_Release();
	}
	
	if ( self.impulse == 201 ) {
		Effect_Spraypaint();	
	}
	
	self.impulse = 0; 
}
