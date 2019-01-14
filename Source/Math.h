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

//.vector basevelocity;
int QPhysics_IsStuck( entity eTarget, vector vOffset, vector vecMins, vector vecMaxs )
{
	if ( eTarget.solid != SOLID_SLIDEBOX ) {
		return FALSE;
	}
	tracebox( eTarget.origin + vOffset, vecMins, vecMaxs, eTarget.origin + vOffset, FALSE, eTarget );
	return trace_startsolid;
}

void PMove_Run (void)
void QPhysics_Run ( entity eTarget )
{
	entity eOld = self;
	self = eTarget;

	float flFallVel = ( self.flags & FL_ONGROUND ) ? 0 : -self.velocity_z;

	self.maxspeed = Game_GetMaxSpeed( self );
	//runstandardplayerphysics(self);
	PMove_Run();
#ifdef SSQC
	if ( ( self.flags & FL_ONGROUND ) && self.movetype == MOVETYPE_WALK && ( flFallVel > 580 )) {
		float fFallDamage = ( flFallVel - 580 ) * ( 100 / ( 1024 - 580 ) );
		Damage_Apply( self, world, fFallDamage, self.origin, FALSE );
	}
#endif

	self = eOld;
}
#endif
