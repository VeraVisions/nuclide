/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void CSQC_ambient_generic( string sSample, float fVolume, float fAttenuation, float fLoop, float lFORate ) {
	//print( sprintf( "SOUND: %s, %f, %d\n%d %d %d", sSample, fVolume, fAttenuation, self.origin[0], self.origin[1], self.origin[2] ) );
	static void LFOHack (void) {
		sound( self, CHAN_VOICE, self.classname, self.movetype, self.style, 0, 0 );
		self.nextthink = self.solid + time;
	}
	// Hack
	if ( lFORate ) {
		self.classname = sSample;
		self.movetype = fVolume;
		self.style = fAttenuation;
		self.think = LFOHack;
		self.solid = lFORate / 10;
		self.nextthink = self.solid + time;
		fLoop = FALSE;
	}
	
	/*if ( fLoop ) {
		sound( self, CHAN_VOICE, sSample, fVolume, fAttenuation, 0, SOUNDFLAG_FORCELOOP );
	} else {*/
		sound( self, CHAN_VOICE, sSample, fVolume, fAttenuation, 0, 0 );
	//}
}

/*
=================
CSQC_Ent_Remove

Self explanatory
=================
*/
void CSQC_Ent_Remove( void ) {
	if ( self.eGunModel ) {
		remove( self.eGunModel );
	}
	
	soundupdate( self, CHAN_VOICE, "", -1, ATTN_IDLE, 0, 0, 0 );
	remove( self );
}

