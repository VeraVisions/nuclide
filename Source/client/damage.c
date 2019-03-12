/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Damage_Draw(void)
{
	float fForward;
	float fRight;
	vector vecMiddle;

	if (pSeat->damage_alpha <= 0.0) {
		return;
	}

	vecMiddle = video_mins + (video_res / 2);
	makevectors(getproperty(VF_CL_VIEWANGLES));

	vector location = normalize(pSeat->damage_pos - getproperty(VF_ORIGIN));
	fForward = dotproduct(location, v_forward);
	fRight = dotproduct(location, v_right);

	if (fForward > 0.25) {
		drawpic(vecMiddle + [-64,-70 - 32], "sprites/640_pain.spr_0.tga", 
				[128,48], [1,1,1], fabs(fForward) * pSeat->damage_alpha, DRAWFLAG_ADDITIVE);
	} else if (fForward < -0.25) {
		drawpic(vecMiddle + [-64,70], "sprites/640_pain.spr_2.tga",
				[128,48], [1,1,1], fabs(fForward) * pSeat->damage_alpha, DRAWFLAG_ADDITIVE);
	}
	if (fRight > 0.25) {
		drawpic(vecMiddle + [70,-64], "sprites/640_pain.spr_1.tga",
				[48,128], [1,1,1], fabs(fRight) * pSeat->damage_alpha, DRAWFLAG_ADDITIVE);
	} else if (fRight < -0.25) {
		drawpic(vecMiddle + [-70 - 32,-64], "sprites/640_pain.spr_3.tga",
				[48,128], [1,1,1], fabs(fRight) * pSeat->damage_alpha, DRAWFLAG_ADDITIVE);
	}
	pSeat->damage_alpha -= frametime;
}

float CSQC_Parse_Damage(float save, float take, vector org)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];

	if (org) {
		pSeat->damage_pos = org;
		pSeat->damage_alpha = 1.0f;
	}

	//sound(pSeat->ePlayer, CHAN_VOICE, "player/pl_pain2.wav", 1, ATTN_NORM);
	return TRUE;
}
