/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#define SHAKE_YAW_DEGREES 5.0f
#define SHAKE_YAW_HERTZ 15.0f
#define SHAKE_PITCH_DEGREES 5.0f
#define SHAKE_PITCH_HERTZ 5.0f
#define SHAKE_ROLL_DEGREES 5.0f
#define SHAKE_ROLL_HERTZ 5.0f

void
Shake_Update(NSClientPlayer pl)
{
	if (pSeat->m_flShakeDuration > 0.0) {
		float shakeMultiplier = (pSeat->m_flShakeDuration / pSeat->m_flShakeTime);
		float sineWave1 = (sin(time * SHAKE_PITCH_HERTZ) * SHAKE_PITCH_DEGREES) * shakeMultiplier;
		float sineWave2 = (sin(time * SHAKE_YAW_HERTZ) * SHAKE_YAW_DEGREES) * shakeMultiplier;
		float sineWave3 = (sin(time * SHAKE_ROLL_HERTZ) * SHAKE_ROLL_DEGREES) * shakeMultiplier;
		vector vecShake = [0,0,0];
		vecShake[0] += random() * 1.5;
		vecShake[1] += random() * 1.5;
		vecShake[2] += random() * 1.5;
		vecShake[0] += sineWave1;
		vecShake[1] += sineWave2;
		vecShake[2] += sineWave3;
		pl.punchangle += (vecShake * pSeat->m_flShakeAmp) * shakeMultiplier;
		pSeat->m_flShakeDuration -= clframetime;
	}
}
