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
			if ( self.health > 0 ) {
				func_breakable_use();
				return;
			}
		}
		
		self.movedir = eActivator.movement;
		self.v_angle = eActivator.angles;
	}
	static void func_pushable_physics( void ) {
		input_movevalues = [ self.movedir_x * 100, self.movedir_y * 100, 0 ];
		input_impulse = input_buttons = 0;
		input_angles = self.v_angle;
		input_timelength = frametime;
		self.movedir = '0 0 0';
		
		runstandardplayerphysics( self );
	}
	static void func_pushable_respawn( void ) {
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_WALK;
		self.customphysics = func_pushable_physics;
		self.touch = func_pushable_touch;
		self.vUse = func_pushable_use;
		self.vPain = func_breakable_pain;
		self.vDeath = func_breakable_die;
		self.iBleeds = FALSE;
		self.iUsable = TRUE;
	}
	
	func_wall();
	func_pushable_respawn();
	
	Entities_InitRespawnable( func_pushable_respawn );
}
