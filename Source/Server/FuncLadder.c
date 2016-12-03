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

/*
=================
func_ladder_sound
=================
*/
void func_ladder_sound( entity target ) {
	if ( ( target.velocity_z == 0 ) || ( target.fStepTime > time ) ) {
		return;
	}

	float	vStep = target.velocity_z;

	if ( vStep < 0 ) {
		vStep *= -1.0;
	}

	float fForce = vStep;
	float dDelay = ( clamp( 0.1, 1 / (fForce / 50), 1 ) );
	float fRandom = random();

	if ( fRandom <= 0.25 ) {
		sound( target, CHAN_BODY, "player/pl_ladder1.wav", 0.5, ATTN_IDLE );
	} else if ( fRandom <= 0.50 ) {
		sound( target, CHAN_BODY, "player/pl_ladder2.wav", 0.5, ATTN_IDLE );
	} else if ( fRandom <= 0.75 ) {
		sound( target, CHAN_BODY, "player/pl_ladder3.wav", 0.5, ATTN_IDLE );
	} else {
		sound( target, CHAN_BODY, "player/pl_ladder4.wav", 0.5, ATTN_IDLE );
	}

	target.fStepTime = ( time + dDelay );
}

/*
=================
func_ladder_touch
=================
*/
void func_ladder_touch( void ) {
	vector vPlayerVector;
	
 	if ( other.classname != "player" ) {
		return;
	}
	
	makevectors( other.v_angle );
	vPlayerVector = v_forward;
	vPlayerVector = ( vPlayerVector * 240 );

	if ( other.movement_x > 0 ) {
		other.velocity = vPlayerVector;
	} else {
		other.velocity = '0 0 0';
	}

	func_ladder_sound( other );
}

/*
=================
SPAWN: func_ladder

A trigger like brush that allows you to 'climb' up or down
=================
*/
void func_ladder( void ) {
	precache_sound( "player/pl_ladder1.wav" );
	precache_sound( "player/pl_ladder2.wav" );
	precache_sound( "player/pl_ladder3.wav" );
	precache_sound( "player/pl_ladder4.wav" );
	
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	setmodel( self, self.model );
	self.model = 0;

	self.touch = func_ladder_touch;
}
