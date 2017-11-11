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

#define SF_BTT_NOMOVE		1
#define	SF_BTT_TOGGLE		32
#define SF_BTT_TOUCH_ONLY	256

void() FuncButton_MoveAway;
void() FuncButton_MoveBack;
void() FuncButton_Touch;

enum {
	STATE_RAISED = 0,
	STATE_LOWERED,
	STATE_UP,
	STATE_DOWN
};

enum {
	FRAME_OFF,
	FRAME_ON
};

.float speed;
.float lip;
.float dmg;
.float state;
.vector pos1, pos2;

// Not all that customizable... but better than QUAKE.
.float movesnd;
.float stopsnd;

/*
====================
FuncButton_PrecacheSounds
====================
*/
void FuncButton_PrecacheSounds( void ) {
	switch( self.sounds ) {
		case 0: 
			// if you ever wondered why a silent button sounded a bit noisey... it's because this one kinda blows
			self.noise = "common/null.wav";
			break;
		case 1:
			self.noise = "buttons/button1.wav";
			break;
		case 2:
			self.noise = "buttons/button2.wav";
			break;
		case 3:
			self.noise = "buttons/button3.wav";
			break;
		case 4:
			self.noise = "buttons/button4.wav";
			break;
		case 5:
			self.noise = "buttons/button5.wav";
			break;
		case 6:
			self.noise = "buttons/button6.wav";
			break;
		case 7:
			self.noise = "buttons/button7.wav";
			break;
		case 8:
			self.noise = "buttons/button8.wav";
			break;
		case 9:
			self.noise = "buttons/button9.wav";
			break;
		case 10:
			self.noise = "buttons/button10.wav";
			break;
		case 11:
			self.noise = "buttons/button11.wav";
			break;
		case 12:
			self.noise = "buttons/latchlocked1.wav";
			break;
		case 13:
			self.noise = "buttons/latchunlocked1.wav";
			break;
		case 14:
			self.noise = "buttons/lightswitch2.wav";
			break;
		case 21:
			self.noise = "buttons/lever1.wav";
			break;
		case 22:
			self.noise = "buttons/lever2.wav";	
			break;
		case 23:
			self.noise = "buttons/lever3.wav";
			break;
		case 24:
			self.noise = "buttons/lever4.wav";
			break;
		case 25:
			self.noise = "buttons/lever5.wav";
			break;
		default:
			self.noise = "buttons/button9.wav";
	}
	
	precache_sound( self.noise );
}

/*
====================
FuncButton_Arrived
====================
*/
void FuncButton_Arrived( void ) {
	self.state = STATE_RAISED;
	
	if ( !( self.spawnflags & SF_BTT_TOUCH_ONLY ) ) {
		self.touch = FuncButton_Touch;
	}
	if ( self.spawnflags & SF_BTT_TOGGLE ) {
		return;
	}
	
	if ( self.wait != -1 ) {
		self.think = FuncButton_MoveBack;
		self.nextthink = ( self.ltime + self.wait );
	}
}

/*
====================
FuncButton_Returned
====================
*/
void FuncButton_Returned( void ) {
	if ( !( self.spawnflags & SF_BTT_TOUCH_ONLY ) ) {
		self.touch = FuncButton_Touch;
	}
    
	self.state = STATE_LOWERED;
	self.frame = FRAME_OFF;
}

/*
====================
FuncButton_MoveBack
====================
*/
void FuncButton_MoveBack( void ) {

	if ( !( self.spawnflags & SF_BTT_TOUCH_ONLY ) ) {
		self.touch = __NULL__;
	}
    
	self.state = STATE_DOWN;
	
	if ( self.pos2 != self.pos1 ) {
		Entities_MoveToDestination ( self.pos1, self.speed, FuncButton_Returned );
	} else {
		FuncButton_Returned();
	}
}

/*
====================
FuncButton_MoveAway
====================
*/
void FuncButton_MoveAway( void ) {
	if ( self.state == STATE_UP ) {
		return;
	}

	if ( self.state == STATE_RAISED ) {	
		self.nextthink = ( self.ltime + self.wait );
		return;
	}
	
	self.state = STATE_UP;
	
	if ( self.pos2 != self.pos1 ) {
		Entities_MoveToDestination ( self.pos2, self.speed, FuncButton_Arrived );
	} else {
		FuncButton_Arrived();
	}
	
	self.frame = FRAME_ON;
}

/*
====================
FuncButton_Trigger
====================
*/
void FuncButton_Trigger( void ) {
	if ( self.fAttackFinished > time ) {
		return;
	}
	self.fAttackFinished = time + self.wait;
	
	if ( ( self.state == STATE_UP ) || ( self.state == STATE_RAISED ) ){
		if ( self.wait != -1 ) {
			FuncButton_MoveBack();
		}
		return;
	}

	sound( self, CHAN_VOICE, self.noise, 1.0, ATTN_NORM );
	FuncButton_MoveAway();
	
	if ( self.delay ) {
		Entities_UseTargets_Delay( self.delay );
	} else {
		Entities_UseTargets();
	}
}

/*
====================
FuncButton_Touch
====================
*/
void FuncButton_Touch( void ) {
	if ( other.classname == "player" ) {
		FuncButton_Trigger();
    
		if ( !( self.spawnflags & SF_BTT_TOUCH_ONLY ) ) {
			self.touch = __NULL__;
		}
	}
}

/*
====================
FuncButton_Blocked
====================
*/
void FuncButton_Blocked( void ) {
	if ( self.dmg ) {
		Damage_Apply( other, self, self.dmg, other.origin, FALSE );
	}
	
	if ( self.wait >= 0 ) {
		if ( self.state == STATE_DOWN ) {
			FuncButton_MoveAway ();
		} else {
			FuncButton_MoveBack ();
		}
	}
}

/*
====================
func_button

Spawn function of a moving door entity
====================
*/
void func_button( void ) {
	FuncButton_PrecacheSounds();
	Entities_SetMovementDirection();
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin( self, self.origin );	
	setmodel( self, self.model );

	self.blocked = FuncButton_Blocked;
	self.vUse = FuncButton_Trigger;
	
	if ( !self.speed ) {
		self.speed = 100;
	}

	if ( self.spawnflags & SF_BTT_TOUCH_ONLY ) {
		self.touch = FuncButton_Touch;
	}

	self.iUsable = TRUE;
	self.pos1 = self.origin;
	
	if ( self.spawnflags & SF_BTT_NOMOVE ) {
		self.pos2 = self.pos1;
	} else {
		self.pos2 = ( self.pos1 + self.movedir * ( fabs( self.movedir * self.size ) - self.lip ) );
	}

	self.state = STATE_LOWERED;
	Entities_RenderSetup();
}
