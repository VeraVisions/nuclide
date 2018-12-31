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

enum {
	HOSTAGE_IDLE,
	HOSTAGE_WALK,
	HOSTAGE_RUN
};

enum {
	A_WALK,
	A_WALKSCARED,
	A_RUN,
	A_RUNSCARED,
	A_RUNLOOK,
	A_180LEFT,
	A_180RIGHT,
	A_FLINCH,
	A_PAIN,
	A_PAINLEFT,
	A_PAINRIGHT,
	A_PAINLEGLEFT,
	A_PAINLEGRIGHT,
	A_IDLE1,
	A_IDLE2,
	A_IDLE3,
	A_IDLE4,
	A_IDLE5,
	A_IDLE6,
	A_SCARED_END,
	A_SCARED1,
	A_SCARED2,
	A_SCARED3,
	A_PANIC,
	A_FEAR1,
	A_FEAR2,
	A_CRY,
	A_SCI1,
	A_SCI2,
	A_SCI3,
	A_DIE_SIMPLE,
	A_DIE_FORWARD1,
	A_DIE_FORWARD2,
	A_DIE_BACKWARD,
	A_DIE_HEADSHOT,
	A_DIE_GUTSHOT,
	A_LYING1,
	A_LYING2,
	A_DEADSIT,
	A_DEADTABLE1,
	A_DEADTABLE2,
	A_DEADTABLE3
};

/*
=================
hostage_waypoint

Spawns a new waypoint for the hostage
=================
*/
entity hostage_waypoint( void ) {
	entity ePoint = spawn();
	setorigin( ePoint, self.eUser.origin );
	setsize( ePoint, self.mins, self.maxs );
	ePoint.classname = "remove_me";
	ePoint.movetype = MOVETYPE_TOSS;
	//setmodel( ePoint, "models/chick.mdl" ); // Visual feedback...
	return ePoint;
}

/*
=================
hostage_waypoint_needed

Determines when we need to spawn a new waypoint
=================
*/
float hostage_waypoint_needed( void ) {
	float fState;
	if ( self.eUser.movement == self.movement ) {
		fState =  FALSE;
	} else {
		fState = TRUE;
	}
	
	self.movement = self.eUser.movement;
	
	return fState;
}

/*
=================
hostage_pain

Called whenever a hostage is shot
=================
*/
void hostage_pain( int iHitBody ) {
	self.frame = A_PAIN + floor( random( 0, 5 ) );
}

/*
=================
hostage_die

hosdown.wav
=================
*/
void hostage_die( int iHitBody ) {
	Radio_BroadcastMessage( RADIO_HOSDOWN );
	self.frame = A_DIE_SIMPLE + floor( random( 0, 6 ) );
	
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	
	if ( other.eTargetPoint != other.eUser ) {
		remove( other.eTargetPoint );
	}
}

/*
=================
hostage_use

Whenever a hostage is 'used'
=================
*/
void hostage_use( void ) {
	if ( eActivator.team == TEAM_CT ) {
		if ( ( self.eUser == world ) ) {
			// Only give cash to the CT for using it for the first time
			if ( self.iHasBeenUsed == FALSE ) {
				Money_AddMoney( eActivator, 150 );
				sound( self, CHAN_VOICE, sprintf( "hostage/hos%d.wav", random( 1, 6 ) ), 1.0, ATTN_IDLE );
				self.iHasBeenUsed = TRUE;
			}
			
			self.eUser = eActivator;
			self.eTargetPoint = self.eUser;
		} else {
			self.eUser = world;
		}
	}
}

/*
=================
hostage_physics

Run every frame
=================
*/
void hostage_physics( void ) {
	input_movevalues = '0 0 0';
	input_impulse = 0;
	input_buttons = 0;
		
	// Are we meant to follow someone and AREN'T dead?
	if ( ( self.eUser != world ) && ( self.health > 0 )  ) {
		// Which direction we have to face
		vector vEndAngle = vectoangles( self.eTargetPoint.origin - self.origin );
		
		// Slowly turn towards target
		float fTurn = Math_LerpAngle( self.v_angle_y, vEndAngle_y, frametime * 4 );
		self.v_angle_y += fTurn;
		self.v_angle_y = Math_FixDelta( self.v_angle_y );
		
		// Is the waypoint close? if so, remove and go set the next one!
		float fDist1 = vlen( self.eTargetPoint.origin - self.origin );
		
		if ( fDist1 < 100 && self.eTargetPoint != self.eUser ) {
			entity eTemp = self.eTargetPoint;
			
			if ( self.eTargetPoint.eTargetPoint ) {
				self.eTargetPoint = self.eTargetPoint.eTargetPoint;
			} else {
				self.eTargetPoint = self.eUser;
			}
			
			remove( eTemp ); // Delete the old waypoint
		} 
		
		// Don't switch states so often
		if( self.fAttackFinished < time ) {
			// Here we check the distance of us and the player, then choosing if we should walk/run etc.
			float fDist = vlen( self.eUser.origin - self.origin );
			
			if ( fDist < 130 ) {
				self.style = HOSTAGE_IDLE;
				self.fAttackFinished = time + 0.1;
			} else if ( fDist < 200 ) {
				self.style = HOSTAGE_WALK;
				self.fAttackFinished = time + 0.4;
			} else {
				self.style = HOSTAGE_RUN;
				self.fAttackFinished = time + 0.1;
				
				// We only ever need to create waypoints when we run
				if ( hostage_waypoint_needed() == TRUE ) {
					if ( self.eTargetPoint == self.eUser ) {
						// Create the first waypoint
						self.eTargetPoint = hostage_waypoint();
						self.eLastCreated = self.eTargetPoint;
					} else {
						// Create the next one and link
						self.eLastCreated.eTargetPoint = hostage_waypoint();
						self.eLastCreated = self.eLastCreated.eTargetPoint;
					}
				}
			}
		}
		
		if ( fTurn > 0.01 ) {
			self.frame = A_180LEFT;
		} else if ( fTurn < -0.01 ){
			self.frame = A_180RIGHT;
		} else {
			self.frame = A_IDLE1;
		}
		
		// Decide speed and stuff
		if ( self.style == HOSTAGE_WALK ) {
			self.frame = A_WALK;
			input_movevalues_x = 160;
		} else if ( self.style == HOSTAGE_RUN ) {
			input_movevalues_x = 320;
			self.frame = A_RUN;
		} else {
			input_movevalues_x = 0;
		}
	}
	
	input_timelength = frametime;
	input_angles = self.v_angle;
	self.movetype = MOVETYPE_WALK;
	
	runstandardplayerphysics( self );
	Footsteps_Update();
	
	self.angles = self.v_angle;
	self.movetype = MOVETYPE_NONE;
}

/*
=================
SPAWN: hostage_entity

Entry function for the hostages.
=================
*/
void hostage_entity( void ) {
	
	static void hostage_entity_respawn( void ) {
		self.v_angle_x = Math_FixDelta ( self.angles_x );
		self.v_angle_y = Math_FixDelta ( self.angles_y );
		self.v_angle_z = Math_FixDelta ( self.angles_z );
		
		setorigin( self, self.origin );
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_NONE;
		setmodel( self, self.model );
		setsize( self, VEC_HULL_MIN + '0 0 36', VEC_HULL_MAX + '0 0 36' );
		self.customphysics = hostage_physics;

		self.eUser = world;
		self.eTargetPoint = world;
		self.gflags = GF_USABLE;
		self.PlayerUse = hostage_use;
		self.iBleeds = TRUE;
		self.takedamage = DAMAGE_YES;
		self.vPain = hostage_pain;
		self.vDeath = hostage_die;
		self.style = HOSTAGE_IDLE;

		self.frame = A_IDLE1;
		self.health = 100;
		self.velocity = '0 0 0';
		self.iHasBeenUsed = FALSE;
	}

	// Path hack
	if ( self.model == "/models/hostage.mdl" ) {
		self.model = "";
	}

	if ( !self.model ) {
		self.model = "models/hostage.mdl";
	}
	
	precache_model( self.model );
	hostage_entity_respawn();
	iHostagesMax = iHostagesMax + 1; // Increase the global count of hostages
	
	Entities_InitRespawnable( hostage_entity_respawn );
}
