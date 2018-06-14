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
=================
Footsteps_Update

Run every frame for each player, plays material based footsteps
=================
*/
void Footsteps_Update( void ) {
	float fForce;
	float fDelay;
	vector vStep;
	string sStepSound = "";

	if ( ( self.movetype == MOVETYPE_WALK ) && ( self.flags & FL_ONGROUND ) ) {
		if ( ( self.velocity_x == 0 && self.velocity_y == 0 ) || self.fStepTime > time ) {
			return;
		}

		if ( vlen( self.velocity ) < 150  ) {
			return;
		}
		
		vStep_x = fabs( self.velocity_x );
		vStep_y = fabs( self.velocity_y );

		fForce = ( vStep_x + vStep_y );
		fDelay = clamp( 0.1, 1 / ( fForce / 90 ), 1 );

		traceline( self.origin + self.view_ofs, self.origin + '0 0 -48', FALSE, self );
		
		string sTexture = getsurfacetexture( trace_ent, getsurfacenearpoint( trace_ent, trace_endpos ) );
		
		switch( (float)hash_get( hashMaterials, sTexture ) ) { 
			case 'M':
				sStepSound = sprintf( "player/pl_metal%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			case 'V':
				sStepSound = sprintf( "player/pl_duct%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			case 'D':
				sStepSound = sprintf( "player/pl_dirt%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			case 'S':
				sStepSound = sprintf( "player/pl_slosh%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			case 'T':
				sStepSound = sprintf( "player/pl_tile%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			case 'G':
				sStepSound = sprintf( "player/pl_grate%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			case 'W':
				sStepSound = sprintf( "player/pl_step%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			case 'P':
				sStepSound = sprintf( "player/pl_step%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			case 'Y':
				sStepSound = sprintf( "player/pl_step%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			case 'N':
				sStepSound = sprintf( "player/pl_snow%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
			default:
				sStepSound = sprintf( "player/pl_step%d.wav", floor( ( random() * 4 ) + 1 ) );
				break;
         }

		sound( self, CHAN_BODY, sStepSound, 0.5, ATTN_IDLE );
		self.fStepTime = time + fDelay;
	}
}
