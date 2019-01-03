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

.int iStep;

/*
=================
Footsteps_Update

Run every frame for each player, plays material based footsteps
=================
*/
void Footsteps_Update( void ) {
	float fSpeed;
	float fVol;
	string sMaterial = "";
	string sTexture = "";
	
	if (self.flags & FL_CROUCHING) {
		return;
	}

	if ( ( self.movetype == MOVETYPE_WALK ) && ( self.flags & FL_ONGROUND ) ) {
		if ( ( self.velocity_x == 0 && self.velocity_y == 0 ) || self.fStepTime > time ) {
			return;
		}

		fSpeed = vlen( self.velocity );
		traceline( self.origin + self.view_ofs, self.origin + '0 0 -48', FALSE, self );
		sTexture = getsurfacetexture( trace_ent, getsurfacenearpoint( trace_ent, trace_endpos ) );

		if ( fSpeed < 140 ) {
			self.fStepTime = time + 0.35;
			fVol = 0.15f;
		} else if ( fSpeed < 270 ) {
			self.fStepTime = time + 0.35;
			fVol = 0.35f;
		} else {
			self.fStepTime = time + 0.35;
			fVol = 0.75;
		}
		
		switch( (float)hash_get( hashMaterials, sTexture ) ) { 
			case 'M':
				sMaterial = "metal";
				break;
			case 'V':
				sMaterial = "duct";
				break;
			case 'D':
				sMaterial = "dirt";
				break;
			case 'S':
				sMaterial = "slosh";
				break;
			case 'T':
				sMaterial = "tile";
				break;
			case 'G':
				sMaterial = "grate";
				break;
			case 'W':
				sMaterial = "step";
				break;
			case 'P':
				sMaterial = "step";
				break;
			case 'Y':
				sMaterial = "step";
				break;
			case 'N':
				sMaterial = "snow";
				break;
			default:
				sMaterial = "step";
				break;
         }

		if ( self.iStep ) {
			if ( random() < 0.5f ) {
				sound( self, CHAN_BODY, sprintf( "player/pl_%s1.wav", sMaterial), fVol, ATTN_STATIC );
			} else {
				sound( self, CHAN_BODY, sprintf( "player/pl_%s2.wav", sMaterial), fVol, ATTN_STATIC );
			}
		} else {
			if ( random() < 0.5f ) {
				sound( self, CHAN_BODY, sprintf( "player/pl_%s3.wav", sMaterial), fVol, ATTN_STATIC );
			} else {
				sound( self, CHAN_BODY, sprintf( "player/pl_%s4.wav", sMaterial), fVol, ATTN_STATIC );
			}
		}
				
		self.iStep = 1 - self.iStep;
	}
}
