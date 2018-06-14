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

.entity eDriver;
.entity eVehicle;

.float height;

enum { 
	STATE_REVERSE = -1,
	STATE_OFF,
	STATE_GEAR1,
	STATE_GEAR2,
	STATE_GEAR3
};

/*
=================
SPAWN: func_vehicle

The function that creates life
=================
*/
void func_vehicle_physics( void ) {
	if ( self.eDriver ) {
		// Input, gears
		if ( self.fAttackFinished < time ) {
			if ( self.eDriver.movement_x > 0 ) {
				self.state++;
				if ( self.state > STATE_GEAR3 ) {
					self.state = STATE_GEAR3;
				} 
			} else if ( self.eDriver.movement_x < 0 ) {
				self.state--;
				if ( self.state < STATE_REVERSE ) {
					self.state = STATE_REVERSE;
				}
			}
			self.fAttackFinished = time + 0.25f;
		}
		
		if ( self.eDriver.movement_y > 0 ) {
			self.angles_y -= frametime * 100;
		} else if ( self.eDriver.movement_y < 0 ) {
			self.angles_y += frametime * 100;
		}
	} else { 
			
	}
	
	// Figure out the next position
	makevectors( self.angles + self.v_angle );
	tracebox( self.origin, self.mins, self.maxs, self.origin + ( ( v_forward * ( 100 * self.state ) ) * frametime ), FALSE, self );
	setorigin( self, self.origin + ( ( v_forward * ( 100 * self.state ) ) * frametime ) );
	
	// Update driver position as well	
	if ( self.eDriver ) {
		setorigin( self.eDriver, self.eDriver.origin + ( ( v_forward * ( 100 * self.state ) ) * frametime ) );
	}
}

/*
=================
SPAWN: func_vehicle

The function that creates life
=================
*/
void func_vehicle( void ) {
	static void func_vehicle_setup( void ) {
		entity eStop1 = find( world, targetname, self.target );
		bprint( sprintf( "self.origin: %v targetpos: %v\n", self.origin, eStop1.origin ) );
		setorigin( self, eStop1.origin );
		
		
		entity eStop2 = find( world, targetname, eStop1.target );
		self.v_angle = vectoangles(  eStop2.origin - self.origin );
		bprint( sprintf( "self.origin: %v target2pos: %v & angles: %v\n", self.origin, eStop2.origin, self.v_angle ) );
		setorigin( self, self.origin + [ 0, 0, self.height ] );
	}
	static void func_vehicle_use( void ) {
		bprint( "Used!\n" );
		if ( self.eDriver ) {
			if ( self.eDriver != eActivator ) {
				// Someone else is using it, don't let him
				return;	
			} else {
				// Unassign driver
				self.eDriver = __NULL__;	
			}
		} else {
			self.eDriver = eActivator;	
		}
	}
	static void func_vehicle_respawn( void ) {
		func_vehicle_setup();
		self.angles = '0 0 0';
	}
	
	self.solid = SOLID_BSP;
	self.customphysics = func_vehicle_physics;

	self.iUsable = TRUE;
	self.vUse = func_vehicle_use;
	
	setmodel( self, self.model );
	Entities_RenderSetup();
	
	Entities_InitRespawnable( func_vehicle_respawn );
}

void path_track( void ) {
	
}

/*
=================
SPAWN: func_vehiclecontrols

The function that enables life
=================
*/
/*void func_vehiclecontrols2( void ) {
	static void func_vehiclecontrols_setup( void ) {
		if ( !self.target ) {
			objerror( "func_vehiclecontrols without func_vehicle" );
		}
		
		self.owner = find( world, targetname, self.target );
		
		if ( !self.owner ) {
			objerror( "func_vehiclecontrols' target cannot be found" );
		} else {
			self.owner.owner = self;
		}
		self.owner.vControlPos = self.owner.origin - self.origin;
	}
	static void func_vehiclecontrols_respawn( void ) {
		self.angles = '0 0 0';
	}
	static void func_vehiclecontrols_use( void ) {
		bprint( "Used!\n" );
		if ( self.owner.eDriver ) {
			if ( self.owner.eDriver != eActivator )	{
				// Someone else is using it, don't let him
				return;	
			} else {
				// Unassign driver
				self.owner.eDriver == __NULL__;	
			}
		} else {
			self.owner.eDriver = eActivator;	
			self.owner.vPlayerPos = self.owner.origin - eActivator.origin;
		}
	}
	
	self.solid = SOLID_BSP;
	self.iUsable = TRUE;
	self.vUse = func_vehiclecontrols_use;
	setmodel( self, self.model );
	Entities_RenderSetup();
	Entities_InitRespawnable( func_vehiclecontrols_respawn );
	self.think = func_vehiclecontrols_setup;
	self.nextthink = time + 0.1f;
}*/
