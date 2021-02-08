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

float
Math_LerpAngle(float fStart, float fEnd, float fAmount)
{
	float shortest_angle = ((((fEnd - fStart) % 360) + 540) % 360) - 180;
	return shortest_angle * fAmount;
}

float
Math_Lerp(float fA, float fB, float fPercent)
{
	return (fA * (1 - fPercent)) + (fB * fPercent);
}

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
Math_Reflect(vector v1, vector v2)
{
	return v1 - 2 * dotproduct(v1, v2) * v2;
}
