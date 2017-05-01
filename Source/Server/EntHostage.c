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

.entity eTargetPoint;
.entity eLastCreated;
.int iHasBeenUsed;

enum {
	HOSTAGE_IDLE,
	HOSTAGE_WALK,
	HOSTAGE_RUN
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
//	setmodel( ePoint, "models/chick.mdl" ); // Visual feedback...
	return ePoint;
}

/*
=================
hostage_waypoint_needed

Determines when we need to spawn a new waypoint
=================
*/
float hostage_waypoint_needed( void ) {
	if ( self.eUser.fStepTime > time ) {
		return FALSE;
	}
	return TRUE;
}

/*
=================
hostage_pain

Called whenever a hostage is shot
=================
*/
void hostage_pain( int iHitBody ) {
	self.frame = 13 - floor( random( 1, 6 ) );
}

/*
=================
hostage_die

hosdown.wav
=================
*/
void hostage_die( int iHitBody ) {
	Radio_BroadcastMessage( RADIO_HOSDOWN );
	self.frame = 30 + floor( random( 1, 6 ) );
	
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
	input_angles = self.angles;
		
	// Are we meant to follow someone and AREN'T dead?
	if ( ( self.eUser != world ) && ( self.health > 0 )  ) {
		// Which direction we have to face
		vector vEndAngle = vectoangles( self.eTargetPoint.origin - self.origin );
		
		// Slowly turn towards target
		float fTurn = Math_LerpAngle( self.angles_y, vEndAngle_y, frametime * 4 );
		self.angles_y += fTurn;
		
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
					self.fStepTime = time + 0.2;
				}
			}
		}
		
		if ( fTurn > 0.01 ) {
			self.frame = 5;
		} else if ( fTurn < -0.01 ){
			self.frame = 6;
		} else {
			self.frame = 13;
		}
		
		// Decide speed and stuff
		if ( self.style == HOSTAGE_WALK ) {
			self.frame = 0;
			input_movevalues_x = 110;
		} else if ( self.style == HOSTAGE_RUN ) {
			input_movevalues_x = 220;
			self.frame = 2;
		} else {
			input_movevalues_x = 0;
		}
	}
	
	input_timelength = frametime;
	self.movetype = MOVETYPE_WALK;
	runstandardplayerphysics( self );
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
		setorigin( self, self.origin );
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_NONE;
		setmodel( self, self.model );
		setsize( self, VEC_HULL_MIN + '0 0 36', VEC_HULL_MAX + '0 0 36' );
		self.customphysics = hostage_physics;

		self.eUser = world;
		self.eTargetPoint = world;
		self.iUsable = TRUE;
		self.iBleeds = TRUE;
		self.takedamage = DAMAGE_YES;
		self.vUse = hostage_use;
		self.vPain = hostage_pain;
		self.vDeath = hostage_die;
		self.style = HOSTAGE_IDLE;

		self.frame = 13; // Idle frame
		self.health = 100;
		self.velocity = '0 0 0';
		self.iHasBeenUsed = FALSE;
	}
	
	precache_model( self.model );
	hostage_entity_respawn();
	iHostagesMax = iHostagesMax + 1; // Increase the global count of hostages
	
	Entities_InitRespawnable( hostage_entity_respawn );
}
