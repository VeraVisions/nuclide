/*
FreeCS Project
Copyright (C) 2016, 2017, 2018 Marco "eukara" Hladik

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

float input_timelength;
vector input_angles;
vector input_movevalues;
float input_buttons;

#define PHYSICS_STEPHEIGHT 		18
#define PHYSICS_AIRSTEPHEIGHT		18
#define PHYSICS_FRICTION		4
#define PHYSICS_EDGEFRICTION		2
#define PHYSICS_GRAVITY			800
#define PHYSICS_ACCELERATE		10
#define PHYSICS_STOPSPEED		100

#define PHYSICS_JUMP_CHAINWINDOW 0.5
// maximum possible height from double/chain jump
#define PHYSICS_JUMP_CHAIN 100 
// decay over lifetime of window
#define PHYSICS_JUMP_CHAINDECAY 50 

/*FIXME: jumptime should use the time global, as time intervals are not predictable - decrement it based upon input_timelength*/
.float jumptime;
.float waterlevel;
.float watertype;
.float teleport_time;
.float maxspeed;
.vector view_ofs;

/*
=================
Physics_Categorize

	Figures out where we are in the game world.
	Whether we are in water, on the ground etc.
=================
*/
void Physics_Categorize( void ) {
	int iContents;

	tracebox( self.origin, self.mins, self.maxs, self.origin - '0 0 0.25', FALSE, self );
	
	if ( !trace_startsolid ) {
		if ( ( trace_fraction < 1 ) && ( trace_plane_normal_z > 0.7 ) ) {
			self.flags |= FL_ONGROUND;
		} else {
			if ( self.flags & FL_ONGROUND ) {
				self.flags -= FL_ONGROUND;
			}
		}
	}

	iContents = pointcontents( self.origin + self.mins + '0 0 1' );
	
	if ( iContents < CONTENT_SOLID && iContents != CONTENT_LADDER ) {
		self.watertype = iContents;
		if ( pointcontents( self.origin + ( self.mins + self.maxs ) * 0.5 ) < CONTENT_SOLID && iContents != CONTENT_LADDER ) {
			if ( pointcontents( self.origin + self.maxs - '0 0 1' ) < CONTENT_SOLID && iContents != CONTENT_LADDER ) {
				self.waterlevel = 3;
			} else {
				self.waterlevel = 2;
			}
		} else {
			self.waterlevel = 1;
		}
	} else {
		self.watertype = CONTENT_EMPTY;
		self.waterlevel = 0;
	}
}

/*
=================
Physics_GetMaxSpeed

	Gets the maximum speed of the player
=================
*/
float Physics_GetMaxSpeed( void ) {
	float flMaxSpeed = 240;
	flMaxSpeed *= Weapon_GetSpeedM( self.weapon );
    
	if ( self.flags & FL_CROUCHING ) {
		return ( flMaxSpeed  * 0.5 );
	} else {
		return flMaxSpeed;
	}
}

/*
=================
Physics_Run_Acceleration

	This function applies the velocity changes the player wishes to apply
=================
*/
void Physics_Run_Acceleration( float flMovetime, float flBefore ) {
	vector vWishVelocity;
	vector vWishDirection;
	vector vTemp;
	float flWishSpeed;
	float f;
	float flJumptimeDelta;
	float flChainBonus;

	Physics_Categorize();

	// Update the timer
	self.jumptime -= flMovetime;
	self.teleport_time -= flMovetime;

	// Corpses
	if ( self.movetype == MOVETYPE_TOSS ) {
		self.velocity_z = self.velocity_z - ( PHYSICS_GRAVITY * flMovetime );
		return;
	}
	
	if ( self.movetype == MOVETYPE_WALK ) {
		// Crouching
		if ( input_movevalues_z < 0 ) {
			if ( !( self.flags & FL_CROUCHING ) ) {
				setorigin( self, self.origin - '0 0 18' );
				self.flags |=  FL_CROUCHING;
			}
		} else {
			if ( self.flags & FL_CROUCHING || ( self.flags & FL_CROUCHING ) ) {
				tracebox( self.origin + '0 0 18', VEC_HULL_MIN, VEC_HULL_MAX, self.origin + '0 0 18', FALSE, self );
				if ( trace_startsolid == FALSE ) {
					setorigin( self, self.origin + '0 0 18' );
					self.flags -= FL_CROUCHING;
					
					if ( self.velocity_z <= 0 ) {
						self.velocity_z = self.velocity_z + 25;
					}
				}
			}
		}
	}
	
	// Adjust the bounds and the viewheight, as well as speed
	if ( self.flags & FL_CROUCHING ) {
		self.mins = VEC_CHULL_MIN;
		self.maxs = VEC_CHULL_MAX;
		self.view_ofs = VEC_PLAYER_CVIEWPOS;
	} else {
		self.mins = VEC_HULL_MIN;
		self.maxs = VEC_HULL_MAX;
		self.view_ofs = VEC_PLAYER_VIEWPOS;
	}
	self.maxspeed = Game_GetMaxSpeed( self.weapon );

	makevectors( input_angles );	
	// swim
	if ( self.waterlevel >= 2 ) {
		if ( self.movetype != MOVETYPE_NOCLIP ) {
			if ( self.flags & FL_ONGROUND ) {
				self.flags -= FL_ONGROUND;
			}

			if ( input_movevalues == '0 0 0' ) {
				vWishVelocity = '0 0 -60'; // drift towards bottom
			} else {
				vWishVelocity = v_forward * input_movevalues_x + v_right * vTemp_y + '0 0 1' * input_movevalues_z;
			}
			
			flWishSpeed = vlen( vWishVelocity );
			
			if ( flWishSpeed > self.maxspeed ) {
				flWishSpeed = self.maxspeed;
			}
	
			flWishSpeed = flWishSpeed * 0.7;
	
			// water friction
			if ( self.velocity != '0 0 0' ) {
				f = vlen( self.velocity ) * ( 1 - flMovetime * PHYSICS_FRICTION );
				if ( f > 0 ) {
					self.velocity = normalize( self.velocity ) * f;
				} else {
					self.velocity = '0 0 0';
				}
			} else {
				f = 0;
			}
	
			// water acceleration
			if ( flWishSpeed <= f ) {
				return;
			}
	
			f = min( flWishSpeed - f, PHYSICS_ACCELERATE * flWishSpeed * flMovetime );
			self.velocity = self.velocity + normalize( vWishVelocity ) * f;
			return;
		}
	}
	// hack to not let you back into teleporter
	if ( self.teleport_time > 0 && input_movevalues_x < 0 ) {
		vWishVelocity = v_right * input_movevalues_y;
	} else {
		if ( self.movetype == MOVETYPE_NOCLIP ) {
		} else if ( self.flags & FL_ONGROUND ) {
			makevectors (input_angles_y * '0 1 0');
		}

		vWishVelocity = v_forward * input_movevalues_x + v_right * input_movevalues_y;
	}

	if ( self.movetype != MOVETYPE_WALK ) {
		vWishVelocity_z += input_movevalues_z;
	} else {
		vWishVelocity_z = 0;
	}
	
	vWishDirection = normalize( vWishVelocity );
	flWishSpeed = vlen( vWishVelocity );
	
	if ( flWishSpeed > self.maxspeed ) {
		flWishSpeed = self.maxspeed;
	}

	if (self.movetype == MOVETYPE_NOCLIP) {
		if ( self.flags & FL_ONGROUND ) {
			self.flags -= FL_ONGROUND;
		}
		self.velocity = vWishDirection * flWishSpeed;
	} else {
		/*FIXME: pogostick*/
		if ( self.flags & FL_ONGROUND )
		if ( !( self.flags & FL_WATERJUMP ) )
		if ( self.flags & FL_JUMPRELEASED )
		if ( input_movevalues_z > 0 && flBefore ) {
			if (self.velocity_z < 0) {
				self.velocity_z = 0;
			}
			
			if ( self.waterlevel >= 2 ) {
				if ( self.watertype == CONTENT_WATER ) {
					self.velocity_z = 100;
				} else if ( self.watertype == CONTENT_SLIME ) {
					self.velocity_z = 80;
				} else {
					self.velocity_z = 50;
				}
			} else {
				self.velocity_z += 240;
			}
			
			if ( self.jumptime > 0 ) {
				// time since last jump
				flJumptimeDelta = 0 - ( self.jumptime - PHYSICS_JUMP_CHAINWINDOW );
				//self.velocity_z += PHYSICS_JUMP_CHAIN;
				flChainBonus = PHYSICS_JUMP_CHAIN - ( ( ( PHYSICS_JUMP_CHAINWINDOW - ( PHYSICS_JUMP_CHAINWINDOW - flJumptimeDelta ) ) * 2) * PHYSICS_JUMP_CHAINDECAY );
				self.velocity_z += flChainBonus;
			}
			self.jumptime = PHYSICS_JUMP_CHAINWINDOW;
			self.flags -= FL_ONGROUND;
			self.flags -= FL_JUMPRELEASED;
		}
		// not pressing jump, set released flag
		if ( !( input_movevalues_z > 0 ) ) {
			self.flags |= FL_JUMPRELEASED;
		}
		
		if ( self.flags & FL_ONGROUND ) {
			// friction
			if ( self.velocity_x || self.velocity_y ) {
				vTemp = self.velocity;
				vTemp_z = 0;
				f = vlen( vTemp );

				// if the leading edge is over a dropoff, increase friction
				vTemp = self.origin + normalize( vTemp ) * 16 + '0 0 1' * VEC_HULL_MIN_z;

				traceline( vTemp, vTemp + '0 0 -34', TRUE, self );

				// apply friction
				if ( trace_fraction == 1.0 ) {
					if (f < PHYSICS_STOPSPEED)
						f = 1 - flMovetime * ( PHYSICS_STOPSPEED / f ) * PHYSICS_FRICTION * PHYSICS_EDGEFRICTION;
					else
						f = 1 - flMovetime * PHYSICS_FRICTION * PHYSICS_EDGEFRICTION;
				} else {
					if (f < PHYSICS_STOPSPEED)
						f = 1 - flMovetime * ( PHYSICS_STOPSPEED / f ) * PHYSICS_FRICTION;
					else
						f = 1 - flMovetime * PHYSICS_FRICTION;
				}

				if ( f < 0 ) {
					self.velocity = '0 0 0';
				} else {
					self.velocity = self.velocity * f;
				}
			}

			// acceleration
			f = flWishSpeed - ( self.velocity * vWishDirection );
			if ( f > 0 ) {
				self.velocity += vWishDirection * min( f, PHYSICS_ACCELERATE * flMovetime * flWishSpeed );
			}
			
		} else {
			/*apply gravity*/
			self.velocity_z -= ( PHYSICS_GRAVITY * flMovetime );
			
			if ( flWishSpeed < 30 ) {
				f = flWishSpeed - ( self.velocity * vWishDirection );
			} else {
				f = 30 - ( self.velocity * vWishDirection );
			}
			
			if ( f > 0 ) {
				self.velocity += vWishDirection * ( min( f, PHYSICS_ACCELERATE ) * flWishSpeed * flMovetime );
			}
		}
	}
}

/*
=================
Physics_Rebound

	Calls somethings touch() function upon hit.
=================
*/
void Physics_DoTouch( entity tother ) {
	entity oself = self;

	if ( tother.touch ) {
		other = self;
		self = tother;
		self.touch();
	}

	self = oself;
}

/*
=================
Physics_Rebound

	This function 'bounces' off any surfaces that were hit
=================
*/
static void Physics_Rebound( vector vNormal ) {
	float v;
	v = self.velocity * vNormal;
	self.velocity = self.velocity - vNormal * v;
}

/*
=================
Physics_Fix_Origin

	Incase BSP precision messes up, this function will attempt
	to correct the origin to stop it from being invalid.
=================
*/
float Physics_Fix_Origin( void ) {
	float x, y, z;
	vector norg, oorg = self.origin;
	
	for ( z = 0; z < 3; z++ ) {
		norg_z = oorg_z + ((z==2)?-1:z)*0.0125;
		for ( x = 0; x < 3; x++ ) {
			norg_x = oorg_x + ((x==2)?-1:x)*0.0125;
			for ( y = 0; y < 3; y++ ) {
				norg_y = oorg_y + ((y==2)?-1:y)*0.0125;

				tracebox( norg, self.mins, self.maxs, norg, FALSE, self );
				if ( !trace_startsolid ) {
					//dprint( "[PHYSICS] Unstuck\n" );
					self.origin = norg;
					return TRUE;
				}
			}
		}
	}
	//dprint( "[PHYSICS] Stuck\n" );
	return FALSE;
}

/*
=================
Physics_Run_Move

	This function is responsible for moving the entity 
	forwards according to the various inputs/state.
=================
*/
void Physics_Run_Move( void ) {
	vector destp;
	vector saved_plane_normal;
	float flStepped;
	float flMoveTime;
	int iAttempts;

	if ( self.movetype == MOVETYPE_NOCLIP ) {
		self.origin = self.origin + self.velocity * input_timelength;
		return;
	}

	//we need to bounce off surfaces (in order to slide along them), so we need at 2 attempts
	for ( iAttempts = 3, flMoveTime = input_timelength; flMoveTime > 0 && iAttempts; iAttempts-- ) {
		destp = self.origin + ( self.velocity * flMoveTime );
		tracebox( self.origin, self.mins, self.maxs, destp, FALSE, self );
		
		if ( trace_startsolid ) {
			if ( !Physics_Fix_Origin() ) {
				return;
			}
			continue;
		}
		
		self.origin = trace_endpos;

		if ( trace_fraction < 1 ) {
			saved_plane_normal = trace_plane_normal;
			flMoveTime -= flMoveTime * trace_fraction;

			if ( flMoveTime ) {
				//step up if we can
				trace_endpos = self.origin;
				
				if ( self.flags & FL_ONGROUND ) {
					trace_endpos_z += PHYSICS_STEPHEIGHT;
				} else {
					trace_endpos_z += PHYSICS_AIRSTEPHEIGHT;
				}
				
				tracebox( self.origin, self.mins, self.maxs, trace_endpos, FALSE, self );
				flStepped = trace_endpos_z - self.origin_z;

				float roof_fraction = trace_fraction;
				vector roof_plane_normal = trace_plane_normal;

				destp = trace_endpos + self.velocity*flMoveTime;
				destp_z = trace_endpos_z; /*only horizontally*/
				
				//move forwards
				tracebox( trace_endpos, self.mins, self.maxs, destp, FALSE, self );

				//if we got anywhere, make this raised-step move count
				if ( trace_fraction != 0 ) {
					float fwfrac = trace_fraction;
					vector fwplane = trace_plane_normal;

					//move down
					destp = trace_endpos;
					destp_z -= flStepped + 1;
					tracebox( trace_endpos, self.mins, self.maxs, destp, FALSE, self );
					
					if (trace_fraction == 1 || trace_plane_normal_z > .7) {
						flMoveTime -= flMoveTime * fwfrac;
						/*bounce off the ceiling if we hit it while airstepping*/
						if (roof_fraction < 1) {
							Physics_Rebound( roof_plane_normal );
						}
						
						/*FIXME: you probably want this: && self.velocity_z < 0*/
						if ( trace_fraction < 1 ) {
							Physics_Rebound( trace_plane_normal );
						} else if ( fwfrac < 1 ) {
							Physics_Rebound( fwplane );
						}
						
						self.origin = trace_endpos;
						continue;
					}
				}
			}
			
			//stepping failed, just bounce off
			Physics_Rebound( saved_plane_normal );
			Physics_DoTouch( trace_ent );
		} else {
			break;
		}
	}

	if ( ( self.flags & FL_ONGROUND ) && !( self.velocity_z > 0 ) ) {
		/*try to step down, only if there's something down there*/
		destp = self.origin;
		destp_z -= PHYSICS_STEPHEIGHT;
		tracebox( self.origin, self.mins, self.maxs, destp, FALSE, self );	//try going straight there
		if ( trace_fraction >= 1 ) {
			return;
		}
		if ( trace_startsolid ) {
			if ( !Physics_Fix_Origin() )
				return;
		}
		self.origin = trace_endpos;

		Physics_DoTouch( trace_ent );
	}
}

/*
=================
Physics_Run

	Runs the physics for one input frame.
=================
*/
void Physics_Run( void ) {
	/*Call accelerate flBefore and after the actual move, with half the move each time. This reduces framerate dependance.*/
	Physics_Run_Acceleration( input_timelength / 2, TRUE );
	Physics_Run_Move();
	Physics_Run_Acceleration( input_timelength / 2, FALSE );

	/*NOTE: should clip to network precision here if lower than a float*/
	self.angles = input_angles;
	self.angles_x *= -0.333;

	touchtriggers();
}
