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

struct
{
	float m_flSpeed;
	float m_flFracSin;
	float m_flTime;
	float m_flMove;
	float m_flDelta;
	int m_iCycle;
} g_camBobVars[4], *pCamBob;

/* tilts the camera for a head-bob like effect when moving */
vector
Camera_RunBob(vector camera_angle)
{
	if (!autocvar(v_cambob, 1, "Enables bobbing effect for the first-person camera"))
		return camera_angle;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pCamBob = &g_camBobVars[s];

	/* we don't really care about the vertical velocity */
	vector speed = pSeat->m_vecPredictedVelocity;
	speed[2] = 0.0f;
	pCamBob->m_flSpeed = vlen(speed);

	if (pCamBob->m_flSpeed > 330.0f)
		pCamBob->m_flSpeed = 330.0f;

	/* don't bother on low speeds */
	if ( pCamBob->m_flSpeed < 5.0f ) {
		pCamBob->m_flMove = 0.0f;
		pCamBob->m_flTime = 0.0f; /* progress has halted, start anew */
		return camera_angle;
	} else {
		pCamBob->m_flMove = frametime * (pCamBob->m_flSpeed * 0.01);
	}

	pCamBob->m_flTime = (pCamBob->m_flTime += pCamBob->m_flMove);
	pCamBob->m_flFracSin = fabs(sin(pCamBob->m_flTime * M_PI));
	pCamBob->m_iCycle = (int)pCamBob->m_flTime;
	pCamBob->m_flDelta = (pCamBob->m_flFracSin * 0.0025f) * pCamBob->m_flSpeed;

	camera_angle[0] += pCamBob->m_flDelta;

	if (pCamBob->m_iCycle & 1) {
		pCamBob->m_flDelta = -pCamBob->m_flDelta;
	}

	camera_angle[2] += pCamBob->m_flDelta;
	return camera_angle;
}

/* applies a tilt to the camera for when we're strafing left to right */
vector
Camera_StrafeRoll(vector camera_angle)
{
	if (!autocvar(v_camroll, 0, "Enables strafe-roll for the first-person camera"))
		return camera_angle;

	float roll;
	makevectors(camera_angle);

	roll = dotproduct(pSeat->m_vecPredictedVelocity, v_right);
	roll *= 0.015f;

	camera_angle[2] += roll;
	return camera_angle;
}

int
ClientGame_ConsoleCommand(void)
{
	switch(argv(0)) {
		default:
		return (0);
	}
	return (1);
}


void
ClientGame_PreDraw(void) 
{

}

void
ClientGame_PostDraw(void)
{

}

int
ClientGame_EntityUpdate(float id, float new)
{
	switch (id) {
	default:
		return (0);
	}

	return (1);
}

int
ClientGame_EventParse(float fHeader)
{
	switch (fHeader) {
	default:
		return (0);
	}
	return (1);
}

void
ClientGame_Init(float apilevel, string enginename, float engineversion)
{
}

void
ClientGame_InitDone(void)
{
}

void
ClientGame_RendererRestart(string rstr)
{
}

#define SCORE_HEADER_C [255/255,156/255,0]
#define SCORE_LINE_C [255/255,200/255,0]

var int autocvar_cl_centerscores = FALSE;
var int g_scores_teamplay = 0;

void
Scores_Init(void)
{
	g_scores_teamplay = (int)serverkeyfloat("teamplay");
}

void
Scores_DrawTeam(NSClientPlayer pl, vector pos)
{
	drawfill(pos, [290, 1], SCORE_LINE_C, 1.0f, DRAWFLAG_ADDITIVE);

	drawfont = Font_GetID(FONT_20);
	drawstring(pos + [0,-18], "Teams", [8,8], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [124,-18], "kills / deaths", [8,8], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [240,-18], "latency", [8,8], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	
	pos[1] += 12;

	for (int t = 1; t <= serverkeyfloat("teams"); t++) {
		float l;
		string temp;
		drawstring(pos, serverkey(sprintf("team_%i", t)), [8,8], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
		temp = serverkey(sprintf("teamscore_%i", t));
		l = stringwidth(temp, FALSE, [8,8]);
		drawstring(pos + [150-l, 0], temp, [8,8], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
		drawstring(pos + [158, 0], "wins", [8,8], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
		pos[1] += 16;

		for (int i = -1; i > -32; i--) {
			if (getplayerkeyfloat(i, "*team") != t) {
				continue;
			}

			temp = getplayerkeyvalue(i, "name");

			/* Out of players */
			if (!temp) {
				break;
			} else if (temp == getplayerkeyvalue(pl.entnum-1, "name")) {
				drawfill(pos, [290, 13], [0,0,1], 0.5f, DRAWFLAG_ADDITIVE);
			}

			drawstring(pos + [24,0], getplayerkeyvalue(i, "name"), [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
			drawstring(pos + [154,0], "/", [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

			/* Get the kills and align them left to right */
			temp = getplayerkeyvalue(i, "frags");
			l = stringwidth(temp, FALSE, [8,8]);
			drawstring(pos + [150 - l,0], temp, [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

			/* Deaths are right to left aligned */
			temp = getplayerkeyvalue(i, "*deaths");
			drawstring(pos + [165,0], temp, [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

			/* Get the latency and align it left to right */
			temp = getplayerkeyvalue(i, "ping");
			l = stringwidth(temp, FALSE, [8,8]);

			drawstring(pos + [290 - l,0], temp, [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
			pos[1] += 20;
		}
		pos[1] += 12;
	}
	
	drawfont = Font_GetID(FONT_CON);
}

void
Scores_DrawNormal(NSClientPlayer pl, vector pos)
{
	drawfill(pos, [290, 1], SCORE_LINE_C, 1.0f, DRAWFLAG_ADDITIVE);

	drawfont = Font_GetID(FONT_20);
	drawstring(pos + [0,-18], "Player", [8,8], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [124,-18], "kills / deaths", [8,8], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	drawstring(pos + [240,-18], "latency", [8,8], SCORE_HEADER_C, 1.0f, DRAWFLAG_ADDITIVE);
	
	pos[1] += 12;
	for (int i = -1; i > -32; i--) {
		float l;
		string ping;
		string kills;
		string deaths;
		string name;

		name = getplayerkeyvalue(i, "name");

		/* Out of players */
		if (!name) {
			break;
		} else if (name == getplayerkeyvalue(pl.entnum-1, "name")) {
			drawfill(pos, [290, 13], [0,0,1], 0.5f, DRAWFLAG_ADDITIVE);
		}

		drawstring(pos, getplayerkeyvalue(i, "name"), [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		drawstring(pos + [154,0], "/", [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

		/* Get the kills and align them left to right */
		kills = getplayerkeyvalue(i, "frags");
		l = stringwidth(kills, FALSE, [8,8]);
		drawstring(pos + [150 - l,0], kills, [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

		/* Deaths are right to left aligned */
		deaths = getplayerkeyvalue(i, "*deaths");
		drawstring(pos + [165,0], deaths, [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

		/* Get the latency and align it left to right */
		ping = getplayerkeyvalue(i, "ping");
		l = stringwidth(ping, FALSE, [8,8]);

		drawstring(pos + [290 - l,0], ping, [8,8], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
		pos[1] += 20;
	}
	
	drawfont = Font_GetID(FONT_CON);
}

void
Scores_Draw(void)
{
	vector pos;
	NSClientPlayer pl;
	
	pl = (NSClientPlayer)pSeat->m_ePlayer;

	if (autocvar_cl_centerscores) {
		int c = 10;
		
		/* calculate all valid entries */
		for (int i = -1; i > -32; i--) {
			if (getplayerkeyvalue(i, "name")) {
				break;
			}
			c += 10;
		}
		pos = video_mins + [(g_vidsize[0] / 2) - 145, (g_vidsize[1] / 2) - c];
	} else {
		pos = video_mins + [(g_vidsize[0] / 2) - 145, 30];
	}

	if (Util_IsTeamplay()) {
		Scores_DrawTeam(pl, pos);
	} else {
		Scores_DrawNormal(pl, pos);
	}
}

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
