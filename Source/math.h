/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define MATH_PI 3.1415926

float Math_Time(void)
{
#ifdef CSQC
	return 0;
#else
	return 0;
#endif
}

float Math_LerpAngle( float fStart, float fEnd, float fAmount ) {
	float shortest_angle = ( ( ( ( fEnd - fStart ) % 360 ) + 540 ) % 360 ) - 180;
	return shortest_angle * fAmount;
}

float Math_Lerp( float fA, float fB, float fPercent ) {
	return ( fA * ( 1 - fPercent ) ) + ( fB * fPercent );
}

float Math_VectorNormalize( vector v ) {
	float	length, ilength;

	length = v[0]*v[0] + v[1]*v[1] + v[2]*v[2];
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
	out[0] = in[0] * scale;
	out[1] = in[1] * scale;
	out[2] = in[2] * scale;
}

float Math_FixDelta( float fDelta ) {
	if ( fDelta >= 180 ) {
		fDelta -= 360;
	} else if ( fDelta <= -180 ) {
		fDelta += 360;
	}
	return fDelta;
}

vector Math_Reflect( vector v1, vector v2 )
{
	return v1 - 2 * dotproduct( v1, v2 ) * v2;
}

float Math_CRandom( void ) {
	return 2 * ( random() - 0.5 );
}

#if defined(SSQC) || defined(CSQC)
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

	float flFallVel = ( self.flags & FL_ONGROUND ) ? 0 : -self.velocity[2];

#ifdef CSTRIKE
	self.maxspeed = Game_GetMaxSpeed( self );
#endif

	PMove_Run();
#ifdef SSQC

	if (self.waterlevel != 0) {
		flFallVel = 0;
	}

	if ( ( self.flags & FL_ONGROUND ) && self.movetype == MOVETYPE_WALK && ( flFallVel > 580 )) {
		float fFallDamage = ( flFallVel - 580 ) * ( 100 / ( 1024 - 580 ) );
		Damage_Apply( self, world, fFallDamage, self.origin, FALSE );
		sound(self, CHAN_AUTO, "player/pl_fallpain3.wav", 1.0, ATTN_NORM);
	}
#endif

	self = eOld;
}
#endif
