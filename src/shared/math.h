/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

/*! @file math.h
    @brief Vector Math Helper Functions

    Helper functions for various mathematical operations.
    This header can be included in other libraries and projects to help
    deal with these sorts of issues.
    It is usually included by default in a library project.
    If you want to include this file into your own progs, you
    can include `math.h` from `src/shared/`.
*/

/** @ingroup multiprogs
 *  @ingroup client
 *  @ingroup server
 *  @{
 */

/** Approximation of Pi. */
#define MATH_PI 3.1415926
noref const vector g_vec_null = [0.0f, 0.0f, 0.0f];

#ifdef MENU

vector vectoangles2(vector fwd, optional vector up) = #11;
void rotatevectorsbyangle(vector angle) = #0;

#define vectoangles vectoangles2

vector v_forward;
vector v_up;
vector v_right;
void makevectors( vector angles )
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
#endif


/** Euler-angle lerping function that accounts for negative degrees.

@param startValue is the value closest when lerpAmount is 0.0
@param endValue is the value closest when lerpAmount is 1.0
@param lerpAmount is the lerp value. Between 0.0 and 1.0 is common.
@return Interpolated angl between start and end. */
float
lerpAngle(float startAngle, float endAngle, float lerpAmount)
{
	float shortest_angle = ((((endAngle - startAngle) % 360.0f) + 540.0f) % 360.0f) - 180.0f;
	return shortest_angle * lerpAmount;
}

/** Linear lerp function.

@param startValue is the value closest when lerpAmount is 0.0
@param endValue is the value closest when lerpAmount is 1.0
@param lerpAmount is the lerp value. Between 0.0 and 1.0 is common.
@return Interpolated value between start and end. */
float
lerp(float startValue, float endValue, float lerpAmount)
{
	return (startValue * (1 - lerpAmount)) + (endValue * lerpAmount);
}

/** Tecursive function that fixes an euler angle.

@param angleValue is the angle value to 'fix'.
@return Angle value between -180 and +180. */
float
fixAngleDelta(float angleValue)
{
	if (angleValue > 180) {
		angleValue -= 360;
	} else if (angleValue < -180) {
		angleValue += 360;
	} else {
		return angleValue;
	}

	return fixAngleDelta(angleValue);
}


/** Recursive function that fixes euler angles.

@param inputAngle is the angle value to 'fix'.
@return Angle where pitch/yaw/roll are now between -180 and +180. */
vector
fixAngle(vector inputAngle)
{
	inputAngle[0] = fixAngleDelta(inputAngle[0]);
	inputAngle[1] = fixAngleDelta(inputAngle[1]);
	inputAngle[2] = fixAngleDelta(inputAngle[2]);
	return inputAngle;
}

/** Takes a direction and a plane normal, returns a new trajectory.

@param hitDirection is from where a trace/shot is aiming from. Usually a result from anglesToForward().
@param planeNormal is the impact normal. Usually retrieved from a traceline() call updating the trace_plane_normal global.
@return New direction, calculated from hitDirection hitting planeNormal. */
vector
reflect(vector hitDirection, vector planeNormal)
{
	return hitDirection - 2 * dotproduct(hitDirection, planeNormal) * planeNormal;
}

/** Calculates a random Vector, with every axis being a value between -1.0 and 1.0, unless flyUp is `true`.

@param flyUp being `true` will result in the Z-axis never returning negative values.
@return Random output vector. */
vector
randomVector(bool flyUp)
{
	vector tmp;
	tmp[0] = random() - 0.5f;
	tmp[1] = random() - 0.5f;
	
	if ( flyUp == true ) {
		tmp[2] = random();
	} else {
		tmp[2] = random() - 0.5f;
	}

	return tmp * 2.0f;
}

/** Takes a position and a pivot point and rotates point by N degrees around the pivot (YAW)

@param pos is the points' current, absolute position.
@param pivot is the absolute position of the pivot point.
@param degr is the rotation amount in degrees.
@return Point in world-space that's been rotated. */
vector
rotateAroundPoint(vector pos, vector pivot, float degr)
{
	vector new = pos;
	new[0] = pivot[0] + (pos[0] - pivot[0]) * cos(degr) - (pos[1] - pivot[1]) * sin(degr);
	new[1] = pivot[1] + (pos[0] - pivot[0]) * sin(degr) + (pos[1] - pivot[1]) * cos(degr);
	return new;
}

/** Calculates the difference between two angles.

@param angle1 is the first angle.
@param angle2 is the second angle.
@return The difference between angle1 and angle2 in euler angles. */
vector
angleDifference(vector angle1, vector angle2)
{
	static float Math_AngleDiff_S(float from, float to) {
		float angleDelta = from - to;

		if (angleDelta > 180) {
			angleDelta -= 360;
		} else if (angleDelta < -180) {
			angleDelta += 360;
		}

		return angleDelta;
	}

	vector newAngle;

	/* clean up input angles */
	angle1 = fixAngle(angle1);
	angle2 = fixAngle(angle2);

	newAngle[0] = Math_AngleDiff_S(angle1[0], angle2[0]);
	newAngle[1] = Math_AngleDiff_S(angle1[1], angle2[1]);
	newAngle[2] = Math_AngleDiff_S(angle1[2], angle2[2]);
	return newAngle;
}

/** Converts a Hue-Saturation-Value pair to an RGB vector.

@param angle1 is the first angle.
@param angle2 is the second angle.
@return An RGB color, with values ranging between 0 and 255 on each channel. */
vector
hsvToRGB(float h, float s, float v)
{
	float i,f,p,q,t;
	vector col = [0,0,0];

	h = max(0.0, min(360.0, h));
	s = max(0.0, min(100.0, s));
	v = max(0.0, min(100.0, v));

	s /= 100;
	v /= 100;

	if (s == 0) {
		col[0] = col[1] = col[2] = rint(v*255);
		return col;
	}

	h /= 60;
	i = floor(h);
	f = h - i;
	p = v * (1 - s);
	q = v * (1 - s * f);
	t = v * (1 - s * (1 - f));

	switch (i) {
	case 0:
		col[0] = rint(255*v);
		col[1] = rint(255*t);
		col[2] = rint(255*p);
		break;
	case 1:
		col[0] = rint(255*q);
		col[1] = rint(255*v);
		col[2] = rint(255*p);
		break;
	case 2:
		col[0] = rint(255*p);
		col[1] = rint(255*v);
		col[2] = rint(255*t);
		break;
	case 3:
		col[0] = rint(255*p);
		col[1] = rint(255*q);
		col[2] = rint(255*v);
		break;
	case 4:
		col[0] = rint(255*t);
		col[1] = rint(255*p);
		col[2] = rint(255*v);
		break;
	default:
		col[0] = rint(255*v);
		col[1] = rint(255*p);
		col[2] = rint(255*q);
	}
	return col;
}
/** @} */ // end of multiprogs, server

#include "math_vector.h"
