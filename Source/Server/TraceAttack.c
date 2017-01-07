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

void TraceAttack_FireBullets( int iShots, vector vPos ) {
	vector vDir;

	makevectors(self.v_angle);
	
	while ( iShots > 0) {
		vDir = aim( self, 100000 ) + Math_CRandom()*self.fAccuracy*v_right + Math_CRandom()*self.fAccuracy*v_up;
		
		traceline( vPos, vPos + ( vDir * 2048 ), MOVE_HITMODEL, self);
		if (trace_fraction != 1.0) {
			if ( trace_ent.takedamage == DAMAGE_YES ) {
				Damage_Apply( trace_ent, self, wptTable[ self.weapon ].iDamage, trace_endpos );
			}
			
			if ( trace_ent.iBleeds == TRUE ) {
				Effect_Impact( IMPACT_FLESH, trace_endpos, trace_plane_normal );
			} else {
				string sTexture = getsurfacetexture( trace_ent, getsurfacenearpoint( trace_ent, trace_endpos ) );
		
				switch( (float)hash_get( hashMaterials, sTexture ) ) { 
					case 'G':
					case 'V':
						TraceAttack_FireBullets( iShots, trace_endpos + ( v_forward * 2 ) );
					case 'M':
					case 'P':
						Effect_Impact( IMPACT_METAL, trace_endpos, trace_plane_normal );
						break;
					case 'D':
					case 'W':
						Effect_Impact( IMPACT_WOOD, trace_endpos, trace_plane_normal );
						TraceAttack_FireBullets( iShots, trace_endpos + ( v_forward * 2 ) );
						break;
					case 'Y':
						Effect_Impact( IMPACT_GLASS, trace_endpos, trace_plane_normal );
						break;
					case 'N':
						TraceAttack_FireBullets( iShots, trace_endpos + ( v_forward * 2 ) );
					case 'T':
					default:
						Effect_Impact( IMPACT_DEFAULT, trace_endpos, trace_plane_normal );
						break;
				 }
			}
		}
		iShots--;
	}
	
	dprint( sprintf( "[DEBUG] ACCURACY: %f, %d %d %d\n", self.fAccuracy, vDir_x, vDir_y, vDir_z ));
}
