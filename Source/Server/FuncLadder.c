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

// Uncomment this once FTEs engine ladder is fixed?
//#define FTE_LADDER

/*
=================
func_ladder_sound
=================
*/
void func_ladder_sound( entity target ) {
	if ( ( target.velocity_z == 0 ) || ( target.fStepTime > time ) ) {
		return;
	}

	float vStep = target.velocity_z;

	if ( vStep < 0 ) {
		vStep *= -1.0;
	}

	float fForce = vStep;
	float fDelay = clamp( 0.1, 1 / ( fForce / 90 ), 1 );
	
	sound( target, CHAN_BODY, sprintf( "player/pl_ladder%d.wav", floor( random() * 4 ) + 1 ), 0.5, ATTN_IDLE );
	target.fStepTime = ( time + fDelay );
}

/*
=================
func_ladder_touch
=================
*/
void func_ladder_touch( void ) {
 	if ( other.classname != "player" ) {
		return;
	}
	
#ifndef FTE_LADDER
	vector vPlayerVector;
	makevectors( other.v_angle );
	vPlayerVector = v_forward;
	vPlayerVector = ( vPlayerVector * 240 );

	if ( other.movement_x > 0 ) {
		other.velocity = vPlayerVector;
	} else {
		other.velocity = '0 0 0';
	}
#endif
	
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
	
#ifdef FTE_LADDER
	self.skin = CONTENT_LADDER;
	self.alpha = 0.001;
#endif

	self.touch = func_ladder_touch;
}
