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

int iTotalPenetrations;

/*
=================
TraceAttack_FireSingle

Fires a single shot that can penetrate some materials
=================
*/
void TraceAttack_FireSingle( vector vPos, vector vAngle ) {
	static void TraceAttack_Penetrate( vector vPos, vector vAngle  ) {
		if ( iTotalPenetrations > 0 ) {
			return;
		}
		
		TraceAttack_FireSingle( vPos, vAngle );
		iTotalPenetrations++;
	}
	traceline( vPos, vPos + ( vAngle * wptTable[ self.weapon ].fRange ), MOVE_HITMODEL, self);
		
	if (trace_fraction != 1.0) {
		if ( trace_ent.takedamage == DAMAGE_YES ) {
			Damage_Apply( trace_ent, self, wptTable[ self.weapon ].iDamage, trace_endpos, FALSE );
		}
		
		if ( trace_ent.iBleeds == TRUE ) {
			Effect_Impact( IMPACT_FLESH, trace_endpos, trace_plane_normal );
		} else {
			string sTexture = getsurfacetexture( trace_ent, getsurfacenearpoint( trace_ent, trace_endpos ) );
	
			switch( (float)hash_get( hashMaterials, sTexture ) ) { 
				case 'G':
				case 'V':
					Effect_Impact( IMPACT_METAL, trace_endpos, trace_plane_normal );
					TraceAttack_Penetrate( trace_endpos + ( v_forward * 2 ), vAngle );
					break;
				case 'M':
				case 'P':
					Effect_Impact( IMPACT_METAL, trace_endpos, trace_plane_normal );
					break;
				case 'D':
				case 'W':
					Effect_Impact( IMPACT_WOOD, trace_endpos, trace_plane_normal );
					TraceAttack_Penetrate( trace_endpos + ( v_forward * 2 ), vAngle );
					break;
				case 'Y':
					Effect_Impact( IMPACT_GLASS, trace_endpos, trace_plane_normal );
					break;
				case 'N':
					Effect_Impact( IMPACT_DEFAULT, trace_endpos, trace_plane_normal );
					TraceAttack_Penetrate( trace_endpos + ( v_forward * 2 ), vAngle );
					break;
				case 'T':
				default:
					Effect_Impact( IMPACT_DEFAULT, trace_endpos, trace_plane_normal );
					break;
			 }
		}
	}
}

/*
=================
TraceAttack_FireBullets

Fire a given amount of shots
=================
*/
void TraceAttack_FireBullets( int iShots, vector vPos ) {
	vector vDir;
	makevectors(self.v_angle);
	
	while ( iShots > 0 ) {
		iTotalPenetrations = 0;
		vDir = aim( self, 100000 ) + Math_CRandom()*self.fAccuracy*v_right + Math_CRandom()*self.fAccuracy*v_up;
		TraceAttack_FireSingle( vPos, vDir );
		iShots--;
	}
	
	dprint( sprintf( "[DEBUG] ACCURACY: %f, %d %d %d\n", self.fAccuracy, vDir_x, vDir_y, vDir_z ));
}
