/*
 * Copyright (c) 2024 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

/*! @file math_vector.h
    @brief Math Vector Helper Functions

    Helper functions for various vector maths operations.
*/

/** @ingroup common
 *  @{
 */

var vector g_vectorCacheLast;
var vector g_vectorCacheForward;
var vector g_vectorCacheRight;
var vector g_vectorCacheUp;

void AngleVectors ( vector angles )
{
	float angle;
	float sr, sp, sy, cr, cp, cy;
	
	angle = angles[1] * (M_PI*2 / 360);
	sy = sin(angle);
	cy = cos(angle);
	angle = angles[0] * (M_PI*2 / 360);
	sp = sin(angle);
	cp = cos(angle);
	angle = angles[2] * (M_PI*2 / 360);
	sr = sin(angle);
	cr = cos(angle);

	v_forward[0] = cp*cy;
	v_forward[1] = cp*sy;
	v_forward[2] = -sp;

	v_right[0] = (-1*sr*sp*cy+-1*cr*-sy);
	v_right[1] = (-1*sr*sp*sy+-1*cr*cy);
	v_right[2] = -1*sr*cp;

	v_up[0] = (cr*sp*cy+-sr*-sy);
	v_up[1] = (cr*sp*sy+-sr*cy);
	v_up[2] = cr*cp;
}

static void
anglesMake(vector targetAngle)
{
	AngleVectors(targetAngle);
	g_vectorCacheLast = targetAngle;
	g_vectorCacheForward = v_forward;
	g_vectorCacheRight = v_right;
	g_vectorCacheUp = v_up;
}

/** Calculates the forward vector of a set of euler-angles.
Will use a cached result to speed up queries.

@param angle is an of euler-angle.
@return Directional vector pointing what the input angle is facing. */
vector
anglesToForward(vector targetAngle)
{
	if (targetAngle != g_vectorCacheLast) {
		anglesMake(targetAngle);
	}

	return (g_vectorCacheForward);
}

/** Calculates the right vector of a set of euler-angles.
Will use a cached result to speed up queries.

@param angle is an of euler-angle.
@return Directional vector pointing right of where the input angle is facing. */
vector
anglesToRight(vector targetAngle)
{
	if (targetAngle != g_vectorCacheLast) {
		anglesMake(targetAngle);
	}

	return (g_vectorCacheRight);
}

/** Calculates the up vector of a set of euler-angles.
Will use a cached result to speed up queries.

@param angle is an of euler-angle.
@return Directional vector pointing up of where the input angle is facing. */
vector
anglesToUp(vector targetAngle)
{
	if (targetAngle != g_vectorCacheLast) {
		anglesMake(targetAngle);
	}

	return (g_vectorCacheUp);
}

/** Calculates the squared distance between two points. This is a lot faster than distance() calls, but does not reflect in-game units. Use it for any distance check you need to be fast.

@param pointA is the first point.
@param pointB is the second point.
@return The distance between pointA and pointB in map units.*/
float
distanceSquared(vector pointA, vector pointB)
{
	float diffX = pointA[0] - pointB[0];
	float diffY = pointA[1] - pointB[1];
	float diffZ = pointA[2] - pointB[2];
	return (diffX * diffX) + (diffY * diffY) + (diffZ * diffZ);
}

/** Calculates the distance between two points.

@param pointA is the first point.
@param pointB is the second point.
@return The distance between pointA and pointB in map units.*/
float
distance(vector pointA, vector pointB)
{
	return sqrt(distanceSquared(pointA, pointB));
}

/** Calculates the distance between two vectors, ignoring the height difference between them.

@param pointA is the first point.
@param pointB is the second point.
@return The distance between pointA and pointB in map units.*/
float
distance2D(vector pointA, vector pointB)
{
	float diffX = pointA[0] - pointB[0];
	float diffY = pointA[1] - pointB[1];
	return sqrt((diffX * diffX) + (diffY * diffY));
}

/** Figure out which point is the closest between two options.

@param referencePoint is our shared point of reference.
@param pointA is the first point to check referencePoint against.
@param pointB is the second point to check referencePoint against.
@return Returns true if pointA is closer to referencePoint than pointB. */
bool
closer(vector referencePoint, vector pointA, vector pointB)
{
	float distanceA = distanceSquared(referencePoint, pointA);
	float distanceB = distanceSquared(referencePoint, pointA);
	return (distanceA < distanceB) ? true : false;
}

/** Calculates a set of angles from a given vector.

@param toAngles is the vector to convert.
@return Euler-angles generated from the input. */
vector
combineAngles(vector angleA, vector angleB)
{
	makevectors(angleA);
	rotatevectorsbyangle(angleB);
	return vectoangles(v_forward, v_up);
}

/** Calculates accurate length of a given vector.

@param target is the only input vector.
@return The accurate length of the input vector. */
float
length(vector toCalculate)
{
	static vector lastInput = g_vec_null;
	static float lastOutput = 0.0f;

	if (toCalculate == lastInput) {
		return lastOutput;
	}

	lastInput = toCalculate;
	lastOutput = vlen(toCalculate);
	return lastOutput;
}

/** Calculates the length of a given vector using a dot product.

@param target is the only input vector.
@return The approximate length of the input vector. */
float
lengthSquared(vector target)
{
	return (target[0] * target[0]) + (target[1] * target[1]) + (target[2] * target[2]);
}

/** Calculate the dot product of two vectors.

@param vectorA is the first input.
@param vectorB is the second input.
@return The dot product of vectorA and vectorB. */
float
vectorDot(vector vectorA, vector vectorB)
{
	return dotproduct(vectorA, vectorB);
}

/** Calculates an interpolated (linear) point between two points.

@param fromVector is the point closest when lerpFraction is `0.0`.
@param toVector is the point closest when lerpFraction is `1.0`.
@param lerpFraction controls the fraction of the way between the two points.
@return A point vector containing the interpolated result. */
vector
vectorLerp(vector fromVector, vector toVector, float lerpFraction)
{
	static float vectorLerp_Lerp( float fA, float fB, float fPercent) {
		return (fA * (1 - fPercent)) + (fB * fPercent);
	}

	vector outputVector = g_vec_null;
	outputVector[0] = vectorLerp_Lerp(fromVector[0], toVector[0], lerpFraction);
	outputVector[1] = vectorLerp_Lerp(fromVector[1], toVector[1], lerpFraction);
	outputVector[2] = vectorLerp_Lerp(fromVector[2], toVector[2], lerpFraction);
	return outputVector;
}

/** Calculates a normalized version of a given vector.

@param toNormalize is the vector to convert.
@return Normalized vector generated from the input. */
vector
vectorNormalize(vector toNormalize)
{
	static vector lastInput = g_vec_null;
	static vector lastOutput = g_vec_null;

	if (toNormalize == lastInput) {
		return lastOutput;
	}

	lastInput = toNormalize;
	lastOutput = normalize(toNormalize);
	return lastOutput;
}

/** Calculates a set of angles from a given vector.

@param toAngles is the vector to convert.
@return Euler-angles generated from the input. */
vector
vectorToAngles(vector toAngles)
{
	static vector lastInput = g_vec_null;
	static vector lastOutput = g_vec_null;

	if (toAngles == lastInput) {
		return lastOutput;
	}

	lastInput = toAngles;
	lastOutput = fixAngle(vectoangles(toAngles));
	return lastOutput;
}

/** Calculates a set of angles from a given vector, with roll support.

@param forwardDir the normalized forward direction vector.
@param rollDir the normalized roll direction vector.
@return Euler-angles generated from the input. */
vector
vectorToAnglesRoll(vector forwardDir, vector rollDir)
{
	static vector lastInput = g_vec_null;
	static vector lastInput2 = g_vec_null;
	static vector lastOutput = g_vec_null;

	if (forwardDir == lastInput && rollDir == lastInput2) {
		return lastOutput;
	}

	lastInput = forwardDir;
	lastInput2 = rollDir;
	lastOutput = fixAngle(vectoangles(forwardDir, rollDir));
	return lastOutput;
}

/** Lerps between two angles.

@param inputAngle is the current direction in euler angles.
@param endAngle is the desired end direction in euler angles.
@param lerpAmount sets the interpolation amount. From 0.0 to 1.0.
@return Euler-angles generated from the input. */
vector
lerpAngleVector(vector inputAngle, vector endAngle, float lerpAmount)
{
	vector currentDir = anglesToForward(inputAngle);
	vector desiredDir = anglesToForward(endAngle);
	return vectorToAngles(vectorLerp(currentDir, desiredDir, lerpAmount));
}

/**
@param lookingEnt is the point-of-view entity.
@param targetEnt is the entity the lookingEnt is 'looking' at.
@return a normalized vector with the world space direction 
of entity A 'looking' at entity B. */
vector
dirFromTarget(vector lookingEnt, vector targetEnt)
{
	return anglesToForward(vectorToAngles(targetEnt - lookingEnt)); 
}

/** @} */ // end of common
