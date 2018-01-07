/*
OpenCS Project
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

#define MATH_PI 3.1415926

float Math_LerpAngle( float fStart, float fEnd, float fAmount ) {
	float shortest_angle = ( ( ( ( fEnd - fStart ) % 360 ) + 540 ) % 360 ) - 180;
	return shortest_angle * fAmount;
}

float Math_Lerp( float fA, float fB, float fPercent ) {
	return ( fA * ( 1 - fPercent ) ) + ( fB * fPercent );
}

float Math_VectorNormalize( vector v ) {
	float	length, ilength;

	length = v_x*v_x + v_y*v_y + v_z*v_z;
	length = sqrt( length );		// FIXME

	if ( length ) {
		ilength = 1 / length;
		v[0] *= ilength;
		v[1] *= ilength;
		v[2] *= ilength;
	}
		
	return length;
}

void Math_VectorScale( vector in, float scale, __inout vector out ) {
	out_x = in_x * scale;
	out_y = in_y * scale;
	out_z = in_z * scale;
}

float Math_FixDelta( float fDelta ) {
	if ( fDelta >= 180 ) {
		fDelta -= 360;
	} else if ( fDelta <= -180 ) {
		fDelta += 360;
	}
	return fDelta;
}

float Math_CRandom( void ) {
	return 2 * ( random() - 0.5 );
}

#if defined(SSQC) || defined(CSQC)
#ifdef SSQC
void Damage_Apply( entity eTarget, entity eAttacker, int iDamage, vector vHitPos, int iSkipArmor );
#endif
void runplayerphysics(void)
{	//operates on self
	float fallvel = ( self.flags & FL_ONGROUND )?0:-self.velocity_z;
	runstandardplayerphysics(self);
	if ( ( self.flags & FL_ONGROUND ) && self.movetype == MOVETYPE_WALK && ( fallvel > 100 )) {
#ifdef SSQC
		if ( fallvel > 580 ) {
			float fFallDamage = (fallvel-580) * ( 200 / ( 1024 - 580 ) );
			Damage_Apply( self, world, fFallDamage, self.origin, FALSE );
		} 
#endif

#ifdef SSQC
	if ( cvar( "pm_bunnyspeedcap") == 0 ) {
		return;
	}
#else
	if ( serverkey( "pm_bunnyspeedcap") == 0 ) {
		return;
	}
#endif
		if ( fallvel > 245 ) {
			self.velocity *= 0.25;
		}
	}
}
#endif
