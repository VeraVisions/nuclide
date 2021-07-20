/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

var float autocvar_v_bob = 0.01;
var float autocvar_v_bobcycle = 0.8;
var float autocvar_v_bobup = 0.5;
var int autocvar_v_bobstyle = 1;

enum
{
	BOB_NONE,
	BOB_CLASSIC,
	BOB_VISIONS
};

struct
{
	float m_flBobTime;
	float m_flBob;
	float m_flBobCycle;
	float m_flSpeed;
} g_viewBobVars[4], *pViewBob;

/* classic bob, similar to Q1 and HL */
void
Viewmodel_ClassicBobCalc(void)
{
	vector vel;

	pViewBob->m_flBobTime += clframetime;
	pViewBob->m_flBobCycle = pViewBob->m_flBobTime - (int)(pViewBob->m_flBobTime / autocvar_v_bobcycle) * autocvar_v_bobcycle;
	pViewBob->m_flBobCycle /= autocvar_v_bobcycle;

	if (pViewBob->m_flBobCycle < autocvar_v_bobup) {
		pViewBob->m_flBobCycle = MATH_PI * pViewBob->m_flBobCycle / autocvar_v_bobup;
	} else {
		pViewBob->m_flBobCycle = MATH_PI + MATH_PI * (pViewBob->m_flBobCycle - autocvar_v_bobup)/(1.0 - autocvar_v_bobup);
	}

	vel = pSeat->m_vecPredictedVelocity;
	vel[2] = 0;
	pViewBob->m_flSpeed = vlen(vel);

	float flBob = pViewBob->m_flSpeed * autocvar_v_bob;
	flBob = flBob * 0.3 + flBob * 0.7 * sin(pViewBob->m_flBobCycle);
	pViewBob->m_flBob = bound(-7, flBob, 4);
}

void
Viewmodel_ClassicBobRun(entity gun)
{
	// Give the gun a tilt effect like in old HL/CS versions
	if (autocvar(v_bobclassic, 1, "Viewmodel bob classic tilt switch") == 1) {
		gun.angles[2] = -pViewBob->m_flBob;
	}

	gun.origin += [0,0,-1] + (v_forward * (pViewBob->m_flBob * 0.4))
		+ (v_forward * autocvar_v_gunofs[0])
		+ (v_right * autocvar_v_gunofs[1])
		+ (v_up * autocvar_v_gunofs[2]);
}

/* Vera Visions signature bob */
void
Viewmodel_VisionsBobCalc(void)
{
	/* same for now */
	Viewmodel_ClassicBobCalc();
}

void
Viewmodel_VisionsBobRun(entity gun)
{
	float sintime;
	float strength;
	gun.angles[2] = -pViewBob->m_flBob;

	vector angmod;
	angmod[0] += pViewBob->m_flBob * 0.5f;
	angmod[1] += pViewBob->m_flBob;
	angmod[2] += pViewBob->m_flBob * 2.5f;
	gun.angles += angmod * 1.5f;

	/* sway with speed */
	sintime = sin(time);
	strength = pViewBob->m_flSpeed * 0.01f;

	gun.angles[0] += strength * sintime;
	gun.angles[1] += strength * sintime;
	gun.angles[2] += strength * sintime;

	gun.origin += [0,0,-1];
}

/* bob vars are calculated separately from application, so that if there's
 * more than one viewmodel we won't affect the speed of the bob by running
 * the math too many times */
void
Viewmodel_CalcBob(void)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];

	switch (autocvar_v_bobstyle)
	{
	case BOB_CLASSIC:
		Viewmodel_ClassicBobCalc();
		break;
	case BOB_VISIONS:
		Viewmodel_VisionsBobCalc();
		break;
	default:
		break;
	}

	/* make sure it's adjusted for scale */
	pViewBob->m_flBob *= autocvar_r_viewmodelscale;
}

void
Viewmodel_ApplyBob(entity gun)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];

	switch (autocvar_v_bobstyle)
	{
	case BOB_CLASSIC:
		Viewmodel_ClassicBobRun(gun);
		break;
	case BOB_VISIONS:
		Viewmodel_VisionsBobRun(gun);
		break;
	default:
		break;
	}
}
