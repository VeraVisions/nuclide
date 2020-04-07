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

/* High Dynamic Range - Iris Adaption */
var float g_flHDRIrisMinValue = 0.0;
var float g_flHDRIrisMaxValue = 2.0;
var float g_flHDRIrisMultiplier = 1.0;
var float g_flHDRIrisFadeUp = 0.1;
var float g_flHDRIrisFadeDown = 0.5;

#ifdef VALVE
var string g_strSkyName = "desert";
#else
var string g_strSkyName = "";
#endif

class worldspawn:CBaseEntity
{
	virtual void(string, string) SpawnKey;
	virtual void() Initialized;
};

void worldspawn::Initialized(void)
{
	remove(this);
}

void worldspawn::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "chaptertitle":
		GameMessage_Setup(strKey);
		break;
	case "lf_pos":
		g_vecLensPos = stov(strKey);
		break;
	case "sun_pos":
		g_vecSunDir = stov(strKey);
		break;
	case "skyname":
		g_strSkyName = strKey;
		break;
	case "ambientsound":
		if (g_ambientsound) {
			break;
		}
		g_ambientsound = spawn(env_soundscape);
		g_ambientsound.m_iShader = Sound_Precache(strKey);
		break;
	case "hdr_iris_minvalue":
		g_flHDRIrisMinValue = stof(strKey);
			cvar_set("r_hdr_irisadaptation_minvalue", ftos(g_flHDRIrisMinValue));
		break;
	case "hdr_iris_maxvalue":
		g_flHDRIrisMaxValue = stof(strKey);
		cvar_set("r_hdr_irisadaptation_maxvalue", ftos(g_flHDRIrisMaxValue));
		break;
	case "hdr_iris_multiplier":
		g_flHDRIrisMultiplier = stof(strKey);
		cvar_set("r_hdr_irisadaptation_multiplier", ftos(g_flHDRIrisMultiplier));
		break;
	case "hdr_iris_fade_up":
		g_flHDRIrisFadeUp = stof(strKey);
		cvar_set("r_hdr_irisadaptation_fade_up", ftos(g_flHDRIrisFadeUp));
		break;
	case "hdr_iris_fade_down":
		g_flHDRIrisFadeDown = stof(strKey);
		cvar_set("r_hdr_irisadaptation_fade_down", ftos(g_flHDRIrisFadeDown));
		break;
	default:
		break;
	}
}
