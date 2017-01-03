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

.float fSteptime;

/*
=================
Footsteps_Update

TODO: Read sound/materials.txt and use that somehow
=================
*/
void Footsteps_Update( void ) {
	float fForce;
	float dDelay;
	vector vStep;
	string sStepSound = "";

	if ( ( self.movetype == MOVETYPE_WALK ) && ( self.flags & FL_ONGROUND ) ) {
		if ( ( self.velocity_x == 0 && self.velocity_y == 0 ) || self.fSteptime > time ) {
			return;
		}

		vStep_x = fabs( self.velocity_x );
		vStep_y = fabs( self.velocity_y );

		fForce = ( vStep_x + vStep_y );
		dDelay = clamp( 0.1, 1 / ( fForce / 90 ), 1 );

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
		self.fSteptime = time + dDelay;
	}
}
