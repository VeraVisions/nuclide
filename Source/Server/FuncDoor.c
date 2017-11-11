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
func_door Spawnflags
=================
*/

void() FuncDoor_MoveAway;
void() FuncDoor_MoveBack;
void() FuncDoor_Touch;

// TODO: Finish these
#define SF_MOV_OPEN		1
#define SF_MOV_UNLINK 	4
#define SF_MOV_PASSABLE	8
#define SF_MOV_TOGGLE	32
#define SF_MOV_USE		256

enum {
	STATE_RAISED = 0,
	STATE_LOWERED,
	STATE_UP,
	STATE_DOWN
};

.float speed;
.float lip;
.float state;
.vector pos1, pos2;

// Not all that customizable...
.float movesnd;
.float stopsnd;

/*
====================
FuncDoor_PrecacheSounds

CS/HL have a lot of door sounds...
====================
*/
void FuncDoor_PrecacheSounds( void ) {
	
	if( self.movesnd > 0 && self.movesnd <= 10 ) {
		precache_sound( sprintf( "doors/doormove%d.wav", self.movesnd ) );
	} else {
		precache_sound( "common/null.wav" );
	}
	
	if( self.stopsnd > 0 && self.stopsnd <= 8 ) {
		precache_sound( sprintf( "doors/doorstop%d.wav", self.stopsnd ) );
	} else {
		precache_sound( "common/null.wav" );
	}
}

/*
====================
FuncDoor_Arrived
====================
*/
void FuncDoor_Arrived( void ) {
	self.state = STATE_RAISED;

	if( self.stopsnd > 0 && self.stopsnd <= 8 ) {
		sound( self, CHAN_VOICE, sprintf( "doors/doorstop%d.wav", self.stopsnd ), 1.0, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM );
	}
	
	if ( ( self.spawnflags & SF_MOV_USE ) ) {
		self.touch = FuncDoor_Touch;
	}
	if ( self.wait < 0 ) {
		return;
	}
	
	if ( !( self.spawnflags & SF_MOV_TOGGLE ) ) {
		self.think = FuncDoor_MoveBack;
		self.nextthink = ( self.ltime + self.wait );
	}
}

/*
====================
FuncDoor_Returned
====================
*/
void FuncDoor_Returned( void ) {
	
	if( self.stopsnd > 0 && self.stopsnd <= 8 ) {
		sound( self, CHAN_VOICE, sprintf( "doors/doorstop%d.wav", self.stopsnd ), 1.0, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM );
	}
	
	if ( ( self.spawnflags & SF_MOV_USE ) ) {
		self.touch = FuncDoor_Touch;
	}
    
	self.state = STATE_LOWERED;
}

/*
====================
FuncDoor_MoveBack
====================
*/
void FuncDoor_MoveBack( void ) {
	
	if( self.movesnd > 0 && self.movesnd <= 10 ) {
		sound( self, CHAN_VOICE, sprintf( "doors/doormove%d.wav", self.movesnd ), 1.0, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM );
	}
	
	if ( ( self.spawnflags & SF_MOV_USE ) ) {
		self.touch = __NULL__;
	}
    
	self.state = STATE_DOWN;
	Entities_MoveToDestination ( self.pos1, self.speed, FuncDoor_Returned );
}

/*
====================
FuncDoor_MoveAway
====================
*/
void FuncDoor_MoveAway( void ) {
	if ( self.state == STATE_UP ) {
		return;
	}
	
	if( self.movesnd > 0 && self.movesnd <= 10 ) {
		sound( self, CHAN_VOICE, sprintf( "doors/doormove%d.wav", self.movesnd ), 1.0, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM );
	}

	if ( !( self.spawnflags & SF_MOV_TOGGLE ) ) {
		if ( self.state == STATE_RAISED ) {	
			self.nextthink = ( self.ltime + self.wait );
			return;
		}
	}
	
	self.state = STATE_UP;
	Entities_MoveToDestination ( self.pos2, self.speed, FuncDoor_Arrived );
}

/*
====================
FuncDoor_Trigger
====================
*/
void FuncDoor_Trigger( void ) {
	if ( self.fAttackFinished > self.ltime ) {
		return;
	}
	self.fAttackFinished = self.ltime + self.wait;
	
	// Only trigger stuff when we are done moving
	if ( ( self.state == STATE_RAISED ) || ( self.state == STATE_LOWERED ) ) {
		if ( self.delay > 0 ) {
			Entities_UseTargets_Delay( self.delay );
		} else {
			Entities_UseTargets();
		}
	}
	
	if ( ( self.state == STATE_UP ) || ( self.state == STATE_RAISED ) ){
		FuncDoor_MoveBack();
		return;
	}

	FuncDoor_MoveAway();
}

/*
====================
FuncDoor_Touch
====================
*/
void FuncDoor_Touch( void ) {
	if ( self.spawnflags & SF_MOV_TOGGLE ) {
		return;
	}
	
	if ( other.movetype == MOVETYPE_WALK ) {
		if ( other.absmin_z <= self.maxs_z - 2 ) {
			FuncDoor_Trigger();
		}
	}
}

/*
====================
FuncDoor_Blocked
====================
*/
void FuncDoor_Blocked( void ) {
	if( self.dmg ) {
		Damage_Apply( other, self, self.dmg, other.origin, FALSE );
	}
	
	if ( self.wait >= 0 ) {
		if ( self.state == STATE_DOWN ) {
			FuncDoor_MoveAway ();
		} else {
			FuncDoor_MoveBack ();
		}
	}
}

/*
====================
func_door

Spawn function of a moving door entity
====================
*/
void func_door( void ) {
	static void func_door_respawn( void ) {
		self.solid = SOLID_BSP;
		self.movetype = MOVETYPE_PUSH;
		setorigin( self, self.origin );	
		setmodel( self, self.model );
	
		self.blocked = FuncDoor_Blocked;
		self.vUse = FuncDoor_Trigger;
		
		if ( self.wait == -1 ) {
			self.spawnflags = self.spawnflags | SF_MOV_TOGGLE;
		}
		
		if ( !self.speed ) {
			self.speed = 100;
		}
	
		if ( !self.dmg ) {
			self.dmg = 2;
		}
	
		if ( self.spawnflags & SF_MOV_USE ) {
			self.iUsable = TRUE;
		} else {
			self.touch = FuncDoor_Touch;
		}
		
		self.state = STATE_LOWERED;
		self.pos1 = self.origin;
		self.pos2 = ( self.pos1 + self.movedir * ( fabs( self.movedir * self.size ) - self.lip ) );
	
		if ( self.spawnflags & SF_MOV_OPEN ) {
			setorigin( self, self.pos2 );
			self.pos2 = self.pos1;
			self.pos1 = self.origin;
		}
	}
	
	FuncDoor_PrecacheSounds();
	Entities_SetMovementDirection();
	func_door_respawn();
	Entities_InitRespawnable( func_door_respawn );
	Entities_RenderSetup();
}
