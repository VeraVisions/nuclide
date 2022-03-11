/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

var float autocvar_v_bob = 0.01f;
var float autocvar_v_bobcycle = 1.0f;
var float autocvar_v_bobup = 0.5f;

struct
{
	float m_flBobTime;
	float m_flBobTime2;
	float m_flBob;
	float m_flBob2;
	float m_flBobCycle;
	float m_flBobCycle2;
	float m_flSpeed;
} g_viewBobVars[4], *pViewBob;


/* bob vars are calculated separately from application, so that if there's
 * more than one viewmodel we won't affect the speed of the bob by running
 * the math too many times */
void
Viewmodel_CalcBob(void)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];

	vector vecVel;
	float flBob;

	float var_bob;
	float var_cycle;
	float var_up;

	var_bob = autocvar_v_bob;
	var_cycle = autocvar_v_bobcycle;
	var_up = autocvar_v_bobup;

	pViewBob->m_flBobTime += clframetime;
	pViewBob->m_flBobTime2 += clframetime;
	pViewBob->m_flBobCycle = pViewBob->m_flBobTime - (int)(pViewBob->m_flBobTime / var_cycle) * var_cycle;
	pViewBob->m_flBobCycle /= var_cycle;

	if (pViewBob->m_flBobCycle < var_up) {
		pViewBob->m_flBobCycle = MATH_PI * pViewBob->m_flBobCycle / var_up;
	} else {
		pViewBob->m_flBobCycle = MATH_PI + MATH_PI * (pViewBob->m_flBobCycle - var_up)/(1.0 - var_up);
	}

	vecVel = pSeat->m_vecPredictedVelocity;
	vecVel[2] = 0;
	pViewBob->m_flSpeed = vlen(vecVel);

	flBob = pViewBob->m_flSpeed * var_bob;
	flBob = flBob * 0.3 + flBob * 0.7 * sin(pViewBob->m_flBobCycle);
	pViewBob->m_flBob = bound(-7, flBob, 4);

	/* BOB2, which is half the cycle of bob1 */
	pViewBob->m_flBobCycle2 = pViewBob->m_flBobTime2 - (int)(pViewBob->m_flBobTime2 / (var_cycle * 0.5f)) * (var_cycle * 0.5f);
	pViewBob->m_flBobCycle2 /= (var_cycle * 0.5f);

	if (pViewBob->m_flBobCycle2 < var_up) {
		pViewBob->m_flBobCycle2 = MATH_PI * pViewBob->m_flBobCycle2 / var_up;
	} else {
		pViewBob->m_flBobCycle2 = MATH_PI + MATH_PI * (pViewBob->m_flBobCycle2 - var_up)/(1.0 - var_up);
	}

	flBob = pViewBob->m_flSpeed * var_bob;
	flBob = flBob * 0.3 + flBob * 0.7 * sin(pViewBob->m_flBobCycle2);
	pViewBob->m_flBob2 = bound(-7, flBob, 4);

	/* make sure it's adjusted for scale */
	pViewBob->m_flBob *= autocvar_r_viewmodelscale;
}

void
Viewmodel_ApplyBob(entity gun)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];

	float sintime;
	float strength;
	gun.angles[2] = -pViewBob->m_flBob;

	vector angmod = [0,0,0];
	angmod[0] -= pViewBob->m_flBob2 * 0.5f;
	angmod[1] += pViewBob->m_flBob * 2.5f;
	angmod[2] += pViewBob->m_flBob * 3.0f;
	gun.angles += angmod * 1.5f;

	/* sway with speed */
	sintime = sin(time);
	strength = pViewBob->m_flSpeed;

	if (strength > 240)
		strength = 240;

	strength = 240 - strength;
	strength *= 0.005f;

	gun.angles[0] += strength * sintime;
	gun.angles[1] += strength * sintime;
	gun.angles[2] += strength * sintime;
	gun.origin += [0,0,-1];
}
