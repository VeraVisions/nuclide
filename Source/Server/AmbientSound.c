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
void ambient_generic( void ) {
	static float ambient_generic_send( entity ePEnt, float fChanged ) {
		sound( self, CHAN_VOICE, self.message, self.health, self.style, self.pitch, 0, SOUNDFLAG_FORCELOOP );
		return FALSE;
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
	
	if( self.spawnflags & 32 ) {
		self.vUse = ambient_generic_use;
	} else {
		self.noise = self.message; // Needed later for resuming
		self.pvsflags = PVSF_USEPHS;
		self.vUse = ambient_generic_useloop;
		self.SendEntity = ambient_generic_send;
		self.state = TRUE;
	}
	
	Entities_InitRespawnable( ambient_generic_respawn );
}
