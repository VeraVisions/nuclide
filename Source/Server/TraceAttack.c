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

void TraceAttack_FireBullets( int iShots ) {
	vector vSrc, vDir;

	makevectors(self.v_angle);

	vSrc = self.origin + self.view_ofs;
	
	while ( iShots > 0) {
		vDir = aim( self, 100000 ) + Math_CRandom()*self.fAccuracy*v_right + Math_CRandom()*self.fAccuracy*v_up;
		
		traceline( vSrc, vSrc + ( vDir * 2048 ), MOVE_HITMODEL, self);
		if (trace_fraction != 1.0) {
			if ( trace_ent.takedamage == DAMAGE_YES ) {
				Damage_Apply( trace_ent, self, wptTable[ self.weapon ].iDamage, trace_endpos );
			} else {
				pointparticles( EFFECT_GUNSHOT, trace_endpos, trace_plane_normal, 1 );
			}
		}
		iShots--;
	}
	
	dprint( sprintf( "[DEBUG] ACCURACY: %f, %d %d %d\n", self.fAccuracy, vDir_x, vDir_y, vDir_z ));
}
