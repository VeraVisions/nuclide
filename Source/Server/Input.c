/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

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

void Input_Handle( void ) {
	
	if ( self.button0 ) {
		Weapon_PrimaryAttack( self.weapon );
	} else if ( self.button4 ) {
		Weapon_Reload( self.weapon );
	} else if ( self.button5 ) {
		Weapon_SecondaryAttack( self.weapon );
	}
	
	/*if( self.impulse == 10 ) { 
		self.weapon++;
	} 
	if( self.impulse == 11 ) { 
		self.weapon--;
	} 

	self.impulse = 0;  */
}
