/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/* lerping function that accounts for negative degrees */
float
Math_LerpAngle(float fStart, float fEnd, float fAmount)
{
	float shortest_angle = ((((fEnd - fStart) % 360) + 540) % 360) - 180;
	return shortest_angle * fAmount;
}

/* linear lerp function */
float
Math_Lerp(float fA, float fB, float fPercent)
{
	return (fA * (1 - fPercent)) + (fB * fPercent);
}

/* tries to make sure an angle value stays within certain constraints...
 * however it doesn't account for much larger discrepancies */
float
Math_FixDelta(float fDelta)
{
	if (fDelta >= 180) {
		fDelta -= 360;
	} else if (fDelta <= -180) {
		fDelta += 360;
	}

	return fDelta;
}

vector
Math_FixDeltaVector(vector in)
{
	in[0] = Math_FixDelta(in[0]);
	in[1] = Math_FixDelta(in[1]);
	in[2] = Math_FixDelta(in[2]);
	return in;
}

/* takes an impact angle and a plane normal, returns a new trajectory */
vector
Math_Reflect(vector v1, vector v2)
{
	return v1 - 2 * dotproduct(v1, v2) * v2;
}

/* returns a random vector, if the first paramete is true it'll make
 * sure that vertical velocity is ALWAYS positive */
vector
Math_RandomVector(float fFlyUp)
{
	vector tmp;
	tmp[0] = random() - 0.5f;
	tmp[1] = random() - 0.5f;
	
	if ( fFlyUp == TRUE ) {
		tmp[2] = random();
	} else {
		tmp[2] = random() - 0.5f;
	}

	return tmp * 2.0f;
}

/* takes a position and a pivot point and rotates point by X degrees around the pivot (YAW) */
vector
Math_RotateAroundPivot(vector pos, vector pivot, float degr)
{
	vector new = pos;
	new[0] = pivot[0] + (pos[0] - pivot[0]) * cos(degr) - (pos[1] - pivot[1]) * sin(degr);
	new[1] = pivot[1] + (pos[0] - pivot[0]) * sin(degr) + (pos[1] - pivot[1]) * cos(degr);
	return new;
}
