/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

var float g_flDamageAlpha;
var vector g_vecDamageLocation;

void Damage_Draw(void)
{
	if ( g_flDamageAlpha > 0.0f ) {
		vector vecMiddle = [ vVideoResolution[0] / 2, vVideoResolution[1] / 2 ];
		makevectors( getproperty( VF_CL_VIEWANGLES ) );

		vector location = normalize( g_vecDamageLocation - getproperty( VF_ORIGIN ) );
		float fForward = dotproduct( location, v_forward );
		float fRight = dotproduct( location, v_right );

		if ( fForward > 0.25 ) {
			drawpic( vecMiddle + [-64,-70 - 32], "sprites/640_pain.spr_0.tga", [128,48], [1,1,1], fabs( fForward ) * g_flDamageAlpha, DRAWFLAG_ADDITIVE );
		} else if ( fForward < -0.25 ) {
			drawpic( vecMiddle + [-64,70], "sprites/640_pain.spr_2.tga", [128,48], [1,1,1], fabs( fForward ) * g_flDamageAlpha, DRAWFLAG_ADDITIVE );
		}
		if ( fRight > 0.25 ) {
			drawpic( vecMiddle + [70,-64], "sprites/640_pain.spr_1.tga", [48,128], [1,1,1], fabs( fRight ) * g_flDamageAlpha, DRAWFLAG_ADDITIVE );
		} else if ( fRight < -0.25 ) {
			drawpic( vecMiddle + [-70 - 32,-64], "sprites/640_pain.spr_3.tga", [48,128], [1,1,1], fabs( fRight ) * g_flDamageAlpha, DRAWFLAG_ADDITIVE );
		}
		g_flDamageAlpha -= frametime;
	}
}

float CSQC_Parse_Damage(float save, float take, vector org)
{
	if (org) {
		g_vecDamageLocation = org;
		g_flDamageAlpha = 1.0f;
	}
	sound(self, CHAN_VOICE, "player/pl_pain2.wav", 1, ATTN_NORM);
	return TRUE;
}
