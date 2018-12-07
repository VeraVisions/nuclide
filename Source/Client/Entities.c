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

void CSQC_ambient_generic( string sSample, float fVolume, float fAttenuation, float fLoop, float lFORate ) {
	//print( sprintf( "SOUND: %s, %f, %d\n%d %d %d", sSample, fVolume, fAttenuation, self.origin_x, self.origin_y, self.origin_z ) );
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
	
	if ( fLoop ) {
		sound( self, CHAN_VOICE, sSample, fVolume, fAttenuation, 0, SOUNDFLAG_FORCELOOP );
	} else {
		sound( self, CHAN_VOICE, sSample, fVolume, fAttenuation, 0, 0 );
	}
}

/*
=================
CSQC_Ent_Update

Called whenever an entity is sent manually via .SendFlags and so on
=================
*/
void CSQC_Ent_Update( float flIsNew ) {
	float fEntType = readbyte();
	
	if( fEntType == ENT_PLAYER ) {
		if ( flIsNew == TRUE ) {
			self.classname = "player";
			self.solid = SOLID_SLIDEBOX;
			self.predraw = Player_PreDraw;
			self.drawmask = MASK_ENGINE;
			self.pmove_frame = servercommandframe;
		} else {
			Player_PreUpdate();
		}
		
		self.modelindex = readbyte();
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		self.flUpAngle = readcoord() / 90;
		self.angles_y = readcoord();
		self.angles_z = readcoord();
		self.velocity_x = readshort();
		self.velocity_y = readshort();
		self.velocity_z = readshort();
		self.flags = readfloat();
		self.weapon = readbyte();
		
		Player_PostUpdate();
		
		if ( self.flags & FL_CROUCHING ) {
			setsize( self, VEC_CHULL_MIN, VEC_CHULL_MAX );
		} else {
			setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );
		}
		
		setorigin( self, self.origin );
	} else if ( fEntType == ENT_AMBIENTSOUND ) {
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		
		setorigin( self, self.origin );
		
		CSQC_ambient_generic( readstring(), readfloat(), readbyte(), readbyte(), readbyte() );
	} else if ( fEntType == ENT_SPRITE ) {
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();

		Effect_AnimatedSprite( self.origin, readfloat(), readfloat(), readfloat(), readfloat(), readfloat() );
	} else if ( fEntType == ENT_SPRAY ) {
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		
		self.angles_x = readcoord();
		self.angles_y = readcoord();
		self.angles_z = readcoord();
		
		self.color_x = 1.0f - ( readbyte() / 255 );
		self.color_y = 1.0f - ( readbyte() / 255 );
		self.color_z = 1.0f - ( readbyte() / 255 );
		string sLogo = readstring();
		
		self.classname = sprintf( "spray_%s", sLogo );
		self.predraw = Effect_Spraypaint;
		self.drawmask = MASK_ENGINE;
	} else if ( fEntType == ENT_DECAL ) {
		string decalname = "";
		string decalshader = "";

		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		
		self.angles_x = readcoord();
		self.angles_y = readcoord();
		self.angles_z = readcoord();
		
		self.color_x = 1.0f - ( readbyte() / 255 );
		self.color_y = 1.0f - ( readbyte() / 255 );
		self.color_z = 1.0f - ( readbyte() / 255 );
		self.classname = readstring();
		decalname = sprintf("decal_%s", self.classname);
		decalshader = sprintf("{\npolygonOffset\n{\nclampmap %s\nblendFunc filter\n}\n}", self.classname);
		shaderforname(decalname, decalshader);
		self.size = drawgetimagesize(self.classname);
		self.classname = decalname;

		self.predraw = Effect_Decal;
		self.drawmask = MASK_ENGINE;
	}
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

