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

.entity eUser;
.entity eTargetPoint;
.entity eLastCreated;
.int iHasBeenUsed;
enum {
	HOSTAGE_IDLE,
	HOSTAGE_WALK,
	HOSTAGE_RUN
};

// To make sure they are following us right
entity hostage_waypoint( void ) {
	entity ePoint = spawn();
	setorigin( ePoint, self.eUser.origin );
	//setmodel( ePoint, "models/chick.mdl" ); // Visual feedback...
	return ePoint;
}

// Called whenver a hostage is shot
void hostage_pain( void ) {
	self.frame = 13 - ceil( random() * 5);
}

// hosdown.wav
void hostage_die( void ) {
	Radio_BroadcastMessage( RADIO_HOSDOWN );
	self.frame = 30 + ceil( random() * 5);
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	
	if ( other.eTargetPoint != other.eUser ) {
			remove( other.eTargetPoint );
	}
}

// Happens upon calling 'use'
void hostage_use( void ) {
	if ( eActivator.team == TEAM_CT ) {
		if ( ( self.eUser == world ) ) {
			
			if ( self.iHasBeenUsed == FALSE ) {
				Money_AddMoney( eActivator, 150 );
				sound( self, CHAN_VOICE, sprintf( "hostage/hos%d.wav", ceil( random() * 5 ) ), 1.0, ATTN_IDLE );
				self.iHasBeenUsed = TRUE;
			}
			
			self.eUser = eActivator;
			self.eTargetPoint = self.eUser;
		} else {
			self.eUser = world;
		}
	}
}

// Run every frame
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
		float fTurn = Math_LerpAngle( self.angles_y, vEndAngle_y, 0.2 );
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
				if ( self.fStepTime < time ) {
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
		
		// Decide speed and stuff
		if ( self.style == HOSTAGE_WALK ) {
			self.frame = 0;
			input_movevalues = '110 0 0';
		} else if ( self.style == HOSTAGE_RUN ) {
			input_movevalues = '220 0 0';
			self.frame = 2;
		} else {
			input_movevalues = '0 0 0';
			
			if ( fTurn > 0 ) {
				self.frame = 5;
			} else if ( fTurn < 0 ){
				self.frame = 6;
			} else {
				self.frame = 13;
			}
		}
	}
	
	// Calculate physstuff
	runstandardplayerphysics( self );
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
		self.movetype = MOVETYPE_WALK;
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
