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
var int g_iHDREnabled = 0;

#ifdef VALVE
var string g_strSkyName = "desert";
#else
var string g_strSkyName = "";
#endif

class worldspawn:CBaseEntity
{
	virtual void(string, string) SpawnKey;
	virtual void(void) Initialized;
};

void worldspawn::Initialized(void)
{
	g_vecSunDir = [90,0];

	if (g_iHDREnabled)
		cvar_set("r_hdr_irisadaptation", "1");
	else
		cvar_set("r_hdr_irisadaptation", "0");

	cvar_set("r_hdr_irisadaptation_minvalue", ftos(g_flHDRIrisMinValue));
	cvar_set("r_hdr_irisadaptation_maxvalue", ftos(g_flHDRIrisMaxValue));
	cvar_set("r_hdr_irisadaptation_multiplier", ftos(g_flHDRIrisMultiplier));
	cvar_set("r_hdr_irisadaptation_fade_up", ftos(g_flHDRIrisFadeUp));
	cvar_set("r_hdr_irisadaptation_fade_down", ftos(g_flHDRIrisFadeDown));

	remove(this);
}

void worldspawn::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "chaptertitle":
		GameMessage_Setup(strKey);
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
#ifdef HHDEATH
	case "_bgm":
		localcmd(sprintf("music sound/bgm/%s.mp3\n", strKey));
		break;
#endif
	case "hdr_iris_minvalue":
		g_flHDRIrisMinValue = stof(strKey);
		g_iHDREnabled = 1;
		break;
	case "hdr_iris_maxvalue":
		g_flHDRIrisMaxValue = stof(strKey);
		g_iHDREnabled = 1;
		break;
	case "hdr_iris_multiplier":
		g_flHDRIrisMultiplier = stof(strKey);
		g_iHDREnabled = 1;
		break;
	case "hdr_iris_fade_up":
		g_flHDRIrisFadeUp = stof(strKey);
		g_iHDREnabled = 1;
		break;
	case "hdr_iris_fade_down":
		g_flHDRIrisFadeDown = stof(strKey);
		g_iHDREnabled = 1;
		break;
	default:
		break;
	}
}
