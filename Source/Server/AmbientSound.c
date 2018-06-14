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

/*
ambient_generic

The ambient_generic allows you to play a specific sound.

Attributes:
Name (targetname) - Property used to identify entities.
WAV name (message) - This is the path/filename of the .wav file.
Volume (health) - Volume of the sound. Range: 0-10.
Dynamic Presets (preset) - Various effects that can be applied to the sound:

Flags:
Play Everywhere (1) - Sound will be heard in the entire level.
Small Radius (2) - Sound range is about 800 units at max volume.
Medium Radius (4) - Sound range is about 1250 units at max volume.
Large Radius (8) - Sound range is about 2000 units at max volume.
Start Silent (16) - Checking this means the entity must be triggered to work.
Not Toggled (32) - 	Older FGDs show this as Not Looped. 
      				Makes the entity interpret each call as "turn on" instead of "toggle state". 
      				Must be left unchecked for looping sound files. 
      				Note that actual looping depends purely on cue points defined in the .wav file (see notes).
*/
.float pitch;
.float loop;
.float lforate;
void ambient_generic( void ) {
	static float ambient_generic_send( entity ePEnt, float fChanged ) {
		WriteByte( MSG_ENTITY, ENT_AMBIENTSOUND );
		WriteCoord( MSG_ENTITY, self.origin_x );
		WriteCoord( MSG_ENTITY, self.origin_y );
		WriteCoord( MSG_ENTITY, self.origin_z );
		WriteString( MSG_ENTITY, self.message );
		WriteFloat( MSG_ENTITY, self.health );
		WriteByte( MSG_ENTITY, self.style );
		WriteByte( MSG_ENTITY, self.loop );
		WriteByte( MSG_ENTITY, self.lforate );
		return TRUE;
	}
	static void ambient_generic_use( void ) {
		sound( self, CHAN_VOICE, self.message, self.health, self.style, self.pitch );
	}
	static void ambient_generic_useloop( void ) {
		if ( self.state == TRUE ) {
			self.message = "common/null.wav";
			self.SendFlags = 128;
			self.state = FALSE;
		} else {
			self.message = self.noise;
			self.SendFlags = 128;
			self.state = TRUE;
		}
	}
	static void ambient_generic_respawn( void ) {
		// If we are supposed to be looping, but have stopped playing... make sure we do again
		if( !( self.spawnflags & 32 ) && ( self.state == FALSE ) ) {
			ambient_generic_useloop();
		}
	}

	precache_sound( self.message );
	setorigin( self, self.origin );
	self.health = self.health / 10;

	if ( self.spawnflags & 1 ) {
		self.style = ATTN_NONE;
	} else if ( self.spawnflags & 2 ) {
		self.style = ATTN_IDLE;
	} else if ( self.spawnflags & 4 ) {
		self.style = ATTN_STATIC;
	} else if ( self.spawnflags & 8 ) {
		self.style = ATTN_NORM;
	} else {
		self.style = ATTN_STATIC;
	}
	
	if ( self.spawnflags & 32 ) {
		self.loop = FALSE;
	} else {
		self.loop = TRUE;
	}

	if( self.spawnflags & 16 ) {
		self.vUse = ambient_generic_use;
	} else {
		self.noise = self.message; // Needed later for resuming
		self.pvsflags = PVSF_NOREMOVE | PVSF_IGNOREPVS;
		self.vUse = ambient_generic_useloop;
		self.SendEntity = ambient_generic_send;
		self.state = TRUE;
	}
	
	Entities_InitRespawnable( ambient_generic_respawn );
}
