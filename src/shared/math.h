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

#define MATH_PI 3.1415926

float Math_LerpAngle(float fStart, float fEnd, float fAmount);
float Math_Lerp(float fA, float fB, float fPercent);
float Math_FixDelta(float fDelta);
vector Math_FixDeltaVector(vector);
vector Math_Reflect(vector v1, vector v2);
vector Math_RandomVector(float flyup);
vector Math_RotateAroundPivot(vector pos, vector pivot, float degr);
vector Math_AngleDiff(vector from, vector to);

vector hsv2rgb(float h, float s, float v);
