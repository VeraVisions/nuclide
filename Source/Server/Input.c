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
	// TODO: Make this fast switch only
	if ( self.impulse == 1 ) {
		Weapon_Switch( SLOT_MELEE );
	} else if ( self.impulse == 2 ) {
		Weapon_Switch( SLOT_SECONDARY );
	} else if ( self.impulse == 3 ) {
		Weapon_Switch( SLOT_PRIMARY );
	} else if ( self.impulse == 4 ) {
		Weapon_Switch( SLOT_GRENADE );
	} 
	
	if ( self.button3 ) {
			Player_CrouchDown();
	} else if ( self.iCrouching == TRUE ) {
			Player_CrouchUp();
	}
	
	if ( self.button0 ) {
		Weapon_PrimaryAttack( self.weapon );
	} else if ( self.button4 ) {
		Weapon_Reload( self.weapon );
	} else if ( self.button5 ) {
		Weapon_SecondaryAttack( self.weapon );
	}
	
	self.impulse = 0; 
}

/*
====================
CSEv_PlayerUse
====================
*/
void CSEv_PlayerUse( void ) {
	vector vSource;
	entity eOriginalSelf;

	makevectors(self.v_angle);
	vSource = self.origin + self.view_ofs;
	traceline ( vSource, vSource + ( v_forward * 64 ), FALSE, self);

	if ( trace_ent.iUsable ) {
		eActivator = self;
		eOriginalSelf = self;
		self = trace_ent;
		self.vUse();
		self = eOriginalSelf;
	}	
}
