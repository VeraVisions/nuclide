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
func_door_rotating Spawnflags
=================
*/

enumflags {
	SF_ROT_OPEN,
	SF_ROT_REVERSE,
	SF_ROT_UNLINK,
	SF_ROT_ONEWAY,
	SF_ROT_TOGGLE,
	SF_ROT_XAXIS,
	SF_ROT_YAXIS,
	SF_ROT_USE
};

void FuncDoorRotate_RotateAway( void );
void FuncDoorRotate_RotateBack( void );
void FuncDoorRotate_Touch( void );

.float distance;

/*
=================
FuncDoorRotate_Arrived
=================
*/
void FuncDoorRotate_Arrived( void ) {
	self.state = STATE_RAISED;

	if( self.stopsnd > 0 && self.stopsnd <= 8 ) {
		sound( self, CHAN_VOICE, sprintf( "doors/doorstop%d.wav", self.stopsnd ), 1.0, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM );
	}
	
	if ( !(self.spawnflags & SF_ROT_USE) ) {
		self.touch = FuncDoorRotate_Touch;
	}
	if ( self.wait < 0 ) {
		return;
	}
		
	self.think = FuncDoorRotate_RotateBack;
	self.nextthink = ( self.ltime + self.wait );
}

/*
=================
FuncDoorRotate_Returned
=================
*/
void FuncDoorRotate_Returned( void ) {
	if ( !(self.spawnflags & SF_ROT_USE) ) {
		self.touch = FuncDoorRotate_Touch;
	}
    
	self.state = STATE_LOWERED;
}

/*
=================
FuncDoorRotate_RotateBack
=================
*/
void FuncDoorRotate_RotateBack( void ) {
	
	if ( self.movesnd > 0 && self.movesnd <= 10 ) {
		sound( self, CHAN_VOICE, sprintf( "doors/doormove%d.wav", self.movesnd ), 1.0, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM );
	}
	
	if ( !(self.spawnflags & SF_ROT_USE) ) {
		self.touch = __NULL__;
	}
    
	self.state = STATE_DOWN;
	Entities_RotateToDestination( self.pos1, self.speed, FuncDoorRotate_Returned );
}

/*
=================
FuncDoorRotate_Away
=================
*/
void FuncDoorRotate_RotateAway( void ) {
	float fDirection = 1.0;

	if ( self.state == STATE_UP ) {
		return;
	}
	
	if ( self.movesnd > 0 && self.movesnd <= 10 ) {
		sound( self, CHAN_VOICE, sprintf( "doors/doormove%d.wav", self.movesnd ), 1.0, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM );
	}
  
	if ( self.state == STATE_RAISED ) {	
		self.nextthink = ( self.ltime + self.wait );
		return;
	}
	
	self.state = STATE_UP;

	if ( !( self.spawnflags & SF_ROT_ONEWAY ) ) {
		vector vDifference = eActivator.origin - self.origin;
		vector vAngles = eActivator.angles;
		vAngles_x = vAngles_z = 0;

		makevectors( vAngles );

		vector vNext = ( eActivator.origin + ( v_forward * 10 ) ) - self.origin;

		if ( ( ( vDifference_x * vNext_y ) - ( vDifference_y * vNext_x ) ) < 0 ) {
			fDirection = -1.0;
		}
	}

	Entities_RotateToDestination( self.pos2 * fDirection, self.speed, FuncDoorRotate_Arrived );
}

/*
=================
brush_rotate_trigger - What happens when you +use the brush or trigger it
=================
*/
void FuncDoorRotate_Trigger( void ) {
	if ( self.fAttackFinished > time ) {
		return;
	}
	self.fAttackFinished = time + self.wait;
	
	if ( ( self.state == STATE_UP ) || ( self.state == STATE_RAISED ) ) {
		FuncDoorRotate_RotateBack();
		return;
	}

	FuncDoorRotate_RotateAway();
	
	if ( self.delay ) {
		Entities_UseTargets_Delay( self.delay );
	} else {
		Entities_UseTargets();
	}
}

/*
=================
FuncDoorRotate_Touch
=================
*/
void FuncDoorRotate_Touch( void ) {
	if ( self.spawnflags & SF_ROT_TOGGLE ) {
		return;
	}
	
	if ( other.movetype == MOVETYPE_WALK ) {
		eActivator = other;
		FuncDoorRotate_Trigger();
	}
}

/*
=================
FuncDoorRotate_Blocked
=================
*/
void FuncDoorRotate_Blocked( void ) {
	if ( self.dmg ) {
		Damage_Apply( other, self, self.dmg, other.origin );
	}
	
	if ( self.wait >= 0 ) {
		if ( self.state == STATE_DOWN ) {
			FuncDoorRotate_RotateAway ();
		} else {
			FuncDoorRotate_RotateBack ();
		}
	}
}

/*
=================
BrushRotate

	Brush entity that rotates into a specific direction. 
	Has the ability to trigger an object once touched, used or triggered otherwise.
=================
*/
void func_door_rotating( void ) {
	static void func_door_rotating_respawn( void ) {
		self.solid = SOLID_BSP;
		self.movetype = MOVETYPE_PUSH;
		setorigin( self, self.origin );	
		setmodel( self, self.model );
	
		self.blocked = FuncDoorRotate_Blocked;
		self.vUse = FuncDoorRotate_Trigger;
	
		if ( self.spawnflags & SF_ROT_USE ) {
			self.iUsable = TRUE;
		} else {
			self.touch = FuncDoorRotate_Touch;
		}
	
		if ( !self.speed ) {
			self.speed = 100;
		}
		
		if ( self.wait == 0 ) {
			self.wait = 4;
		}
	  
		self.state = STATE_LOWERED;
		self.pos1 = self.angles;
		
		// Only do Y
		if ( self.spawnflags & SF_ROT_XAXIS	) {
			self.pos2_y = self.pos1_y + self.distance;
			
		} 
		
		// Only do X
		if ( self.spawnflags & SF_ROT_YAXIS ) {
			self.pos2_x = self.pos1_x + self.distance;
			
		}
		
		// only do Y by default
		if ( !( self.spawnflags & SF_ROT_YAXIS ) && !( self.spawnflags & SF_ROT_XAXIS ) ) {
			self.pos2_y = self.pos1_y + self.distance;
		}
		
		if ( self.spawnflags & SF_ROT_OPEN ) {
			vector vTemp = self.pos2;
			self.pos2 = self.pos1;
			self.pos1 = vTemp;
			self.angles = self.pos1;
		}
	}
	FuncDoor_PrecacheSounds();
	Entities_SetMovementDirection();
	func_door_rotating_respawn();
	Entities_InitRespawnable( func_door_rotating_respawn );
	Entities_RenderSetup();
}
