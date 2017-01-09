/*
OpenCS Project
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
SPAWN: func_pushable

Entry function for the brushes that players can push.
Pushables are an extension of breakables, so they mostly
explain themselves.
=================
*/
void func_pushable( void ) {
	static void func_pushable_touch( void ) {
		if ( other.classname == "player" ) {
			func_breakable_touch();
			
			if ( other.absmin_z <= self.maxs_z - 2 ) {
				self.movedir = other.movement;
				self.v_angle = other.angles;
			}
		}
	}
	static void func_pushable_use( void ) {
		if ( eActivator.classname != "player" ) {
			func_breakable_use();
			return;
		}
		
		self.movedir = eActivator.movement;
		self.v_angle = eActivator.angles;
	}
	static void func_pushable_physics( void ) {
		input_movevalues = [ self.movedir_x, self.movedir_y, 0 ];
		input_impulse = input_buttons = 0;
		input_angles = self.v_angle;
		self.movedir = '0 0 0';
		
		runstandardplayerphysics( self );
	}
	static void func_pushable_respawn( void ) {
		func_breakable_respawn();
		
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_WALK;
		self.customphysics = func_pushable_physics;
		self.touch = func_pushable_touch;
		self.vUse = func_pushable_use;
		self.iUsable = TRUE;
	}
	
	func_wall();
	func_pushable_respawn();
	
	Entities_InitRespawnable( func_pushable_respawn );
}
