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

#define BOB_STRENGTH 0.02
#define BOB_CYCLE 1.0
#define BOB_UP 0.60

var vector autocvar_bg_bobAmplitudeDucked = [0.0075, 0.0065, 0.0000];
var vector autocvar_bg_bobAmplitudeProne = [0.02, 0.005, 0.0000];
var vector autocvar_bg_bobAmplitudeSprinting = [0.02, 0.014, 0.0000];
var vector autocvar_bg_bobAmplitudeStanding = [0.007, 0.007, 0.0000];
var float autocvar_bg_bobMax = 8.0;
var float autocvar_player_sprintCameraBob = 0.5;

struct
{
	float m_flBobTime;
	float m_flBobTime2;
	float m_flBob;
	float m_flBob2;
	float m_flBobCycle;
	float m_flBobCycle2;
	float m_flSpeed;

	float m_flViewBob;
	float m_flViewBob2;
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
	bool isSprinting = pSeat->m_ePlayer.vv_flags & VFL_SPRINTING;
	bool isCrouching = pSeat->m_ePlayer.vv_flags & VFL_CROUCHING;

//	if (pSeatLocal->m_iSprinting && vlen(pSeat->m_vecPredictedVelocity) > 240)
	//	isSprinting = true;

	var_bob = BOB_STRENGTH;
	var_cycle = BOB_CYCLE;
	var_up = BOB_UP;

	if (isSprinting)
		var_cycle *= autocvar_player_sprintCameraBob;

	pViewBob->m_flBobTime += frametime;
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
	flBob = flBob * sin(pViewBob->m_flBobCycle);
	pViewBob->m_flBob = flBob;

	/* BOB2, which is half the cycle of bob1 */
	pViewBob->m_flBobTime2 += frametime;
	pViewBob->m_flBobCycle2 = pViewBob->m_flBobTime2 - (int)(pViewBob->m_flBobTime2 / (var_cycle * 0.5f)) * (var_cycle * 0.5f);
	pViewBob->m_flBobCycle2 /= (var_cycle * 0.5f);

	if (pViewBob->m_flBobCycle2 < var_up) {
		pViewBob->m_flBobCycle2 = MATH_PI * pViewBob->m_flBobCycle2 / var_up;
	} else {
		pViewBob->m_flBobCycle2 = MATH_PI + MATH_PI * (pViewBob->m_flBobCycle2 - var_up)/(1.0 - var_up);
	}

	flBob = pViewBob->m_flSpeed * (var_bob * 0.5);
	flBob = flBob * cos(pViewBob->m_flBobCycle2);
	pViewBob->m_flBob2 = flBob;

	if (isSprinting) {
		pViewBob->m_flViewBob2 = pViewBob->m_flBob2 * autocvar_bg_bobAmplitudeSprinting[0] * 25.0f;
		pViewBob->m_flViewBob = pViewBob->m_flBob * autocvar_bg_bobAmplitudeSprinting[1] * 25.0f;
		pViewBob->m_flBob2 *= autocvar_bg_bobAmplitudeSprinting[0] * 20.0;
		pViewBob->m_flBob *= autocvar_bg_bobAmplitudeSprinting[1] * 20.0;
	} else if (isCrouching) {
		pViewBob->m_flViewBob2 = pViewBob->m_flBob2 * autocvar_bg_bobAmplitudeDucked[0] * 25.0f;
		pViewBob->m_flViewBob = pViewBob->m_flBob * autocvar_bg_bobAmplitudeDucked[1] * 25.0f;
		pViewBob->m_flBob2 *= autocvar_bg_bobAmplitudeDucked[0] * 20.0;
		pViewBob->m_flBob *= autocvar_bg_bobAmplitudeDucked[1] * 20.0;
	} else {
		pViewBob->m_flViewBob2 = pViewBob->m_flBob2 * autocvar_bg_bobAmplitudeStanding[0] * 25.0f;
		pViewBob->m_flViewBob = pViewBob->m_flBob * autocvar_bg_bobAmplitudeStanding[1] * 25.0f;
		pViewBob->m_flBob2 *= autocvar_bg_bobAmplitudeStanding[0] * 20.0;
		pViewBob->m_flBob *= autocvar_bg_bobAmplitudeStanding[1] * 20.0;
	}
}

void
Viewmodel_ApplyBob(entity gun)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];

	float sintime;
	float strength;
	float kickUp;
	//gun.angles[2] = pViewBob->m_flBob2 * -2.0f;
	gun.angles[2] = pViewBob->m_flViewBob * 4.0f;
	kickUp = pViewBob->m_flViewBob2 * 4.0f;

	vector angmod = [0,0,0];

	angmod[0] = pViewBob->m_flViewBob2 + kickUp;
	angmod[1] = pViewBob->m_flViewBob;

	//angmod[2] += pViewBob->m_flBob * 3.0f;
	gun.angles += angmod;

	/* sway with speed */
	sintime = sin(time);
	strength = pViewBob->m_flSpeed;

	if (strength > 240)
		strength = 240;

	strength = 240 - strength;
	strength *= 0.01f;

	float sprint;
	if (pSeat->m_ePlayer.vv_flags & VFL_SPRINTING) {
		pSeat->m_flSprintLerp = bound(0.0f, pSeat->m_flSprintLerp + clframetime, 1.0f);
	} else {
		pSeat->m_flSprintLerp = bound(0.0f, pSeat->m_flSprintLerp - clframetime, 1.0f);
	}
	sprint = 20 * pSeat->m_flSprintLerp;
	gun.angles[0] += sprint;
	gun.angles[1] += sprint + (sprint * pViewBob->m_flBob) * 0.25f;

#ifdef WASTES
	if (pSeat->m_ePlayer.gflags & GF_IS_HEALING) {
		pSeatLocal->m_flHealLerp = bound(0.0f, pSeatLocal->m_flHealLerp + clframetime, 1.0f);
	} else {
		pSeatLocal->m_flHealLerp = bound(0.0f, pSeatLocal->m_flHealLerp - clframetime, 1.0f);
	}
	gun.angles[0] += pSeatLocal->m_flHealLerp * 45;
	gun.origin[2] -= pSeatLocal->m_flHealLerp * 5;
#endif

	gun.angles[0] += strength * sintime;
	gun.angles[1] += strength * sintime;
	//gun.angles[2] += strength * sintime;
	gun.origin += [0,0,-1];

	makevectors(g_view.GetCameraAngle());
	gun.origin += v_forward * cvar("cl_gunx");
	gun.origin += v_right * cvar("cl_guny");
	gun.origin += v_up * cvar("cl_gunz");

	/* lower gun when moving */
	if (pViewBob->m_flSpeed > 10.0) {
		gun.origin += (v_up * -pViewBob->m_flSpeed * 0.005f);
		gun.origin += (v_right * -pViewBob->m_flSpeed * 0.005f);
	}
}


vector
Camera_AddCamBob(vector cameraAngle)
{
	vector angmod = g_vec_null;

	makevectors(cameraAngle);

	angmod = (pViewBob->m_flBob2 * -v_up);
	angmod += (pViewBob->m_flBob * -v_right);

	return angmod;
}
