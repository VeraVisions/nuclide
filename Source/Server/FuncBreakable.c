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

// Entity information from http://twhl.info/wiki.php?id=164
/*

	Flags

    Only Trigger (1) - Entity can only be activated (broken) by being triggered.
    Touch (2) - Brush will break on touch.
    Pressure (4) - Brush will break when pressured (e.g. player walking on it).
*/

#define SF_TRIGGER	1
#define SF_TOUCH	2
#define SF_PRESSURE	4

/*
=================
func_breakable_pain
=================
*/
void func_breakable_pain( int iNull ) {
	switch ( self.material ) {
		case MATERIAL_GLASS:
		case MATERIAL_COMPUTER:
		case MATERIAL_GLASS_UNBREAKABLE:
			sound( self, CHAN_VOICE, sprintf( "debris/glass%d.wav", random( 1, 4 ) ), 1.0, ATTN_NORM );
			break;
		case MATERIAL_WOOD:
			sound( self, CHAN_VOICE, sprintf( "debris/wood%d.wav", random( 1, 4 ) ), 1.0, ATTN_NORM );
			break;
		case MATERIAL_METAL:
			sound( self, CHAN_VOICE, sprintf( "debris/metal%d.wav", random( 1, 4 ) ), 1.0, ATTN_NORM );
			break;
		case MATERIAL_FLESH:
			float fRand  = floor( random( 1, 8 ) );
			if ( fRand == 4 ) { // sigh
				fRand = 5;
			}
			sound( self, CHAN_VOICE, sprintf( "debris/flesh%d.wav", fRand ), 1.0, ATTN_NORM );
			break;
		case MATERIAL_CINDER:
		case MATERIAL_ROCK:
			sound( self, CHAN_VOICE, sprintf( "debris/concrete%d.wav", random( 1, 4 ) ), 1.0, ATTN_NORM );
			break;
	}
}

/*
=================
func_breakable_die
=================
*/
void func_breakable_die( int iNull ) {	
	// Make sure this is dead
	if ( self.vUse == __NULL__ ) {
		return;
	}
	
	self.health = 0;
	self.vUse = __NULL__;
	Effect_BreakModel( self.absmin, self.absmax, self.velocity, self.material );
	Entities_UseTargets();
	Entities_Remove();
}

/*
=================
func_breakable_use
=================
*/
void func_breakable_use( void ) {
	func_breakable_die( 0 );
}

/*
=================
func_breakable_touch
=================
*/
void func_breakable_touch( void ) {
	static void func_breakable_touch_NULL( void ) { }
	
	if( other.classname != "player" ) {
		return;
	}

	if ( self.spawnflags & SF_TOUCH ) {
		int fDamage = (float)(vlen( self.velocity ) * 0.01f );

		if ( fDamage >= self.health ) {
			self.touch = func_breakable_touch_NULL;
			Damage_Apply( self, other, fDamage, self.absmin, FALSE );
			
			if ( ( self.material == MATERIAL_GLASS ) || ( self.material == MATERIAL_COMPUTER ) ) {
				Damage_Apply( other, self, fDamage / 4, other.origin, FALSE );
			}
		}
	}

	if ( ( self.spawnflags & SF_PRESSURE ) && ( other.absmin_z >= self.maxs_z - 2 ) ) {
		self.think = func_breakable_use;
		
		if ( self.delay == 0 ) {
			self.delay = 0.1f;
		}

		self.nextthink = self.ltime + self.delay;
	}	
}

/*
=================
func_breakable_respawn

Respawns the breakable entity
=================
*/
void func_breakable_respawn( void ) {
	if ( self.spawnflags & SF_TRIGGER ) {
		self.takedamage = DAMAGE_NO;
	} else {
		self.takedamage = DAMAGE_YES;
		self.vPain = func_breakable_pain;
		self.vDeath = func_breakable_die;
		self.iBleeds = FALSE;
	}
		
	if ( ( self.spawnflags & SF_TOUCH ) || ( self.spawnflags & SF_PRESSURE ) ) {
		self.touch = func_breakable_touch;
	} 
		
	self.vUse = func_breakable_use;
}
	
/*
=================
SPAWN: func_breakable

Entry function for the brushes that can die etc.
=================
*/
void func_breakable( void ) {
	func_wall();
	func_breakable_respawn();
	
	Entities_InitRespawnable( func_breakable_respawn );
}
