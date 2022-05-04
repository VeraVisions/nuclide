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

/*QUAKED worldspawn (0 0 0) ?
Only used for the world.

-------- KEYS --------
"message" : Full name of the map.
"author" : Author of the map.
"chaptertitle" : Titles entry to display when entering the level.
"sounds" : CD track to play.
"_fog" : Fog in the playable area. Format: (density red green blue alpha depthbias)
"_skyroomfog" : Fog in the skybox area. Format: (density red green blue alpha depthbias)
"skyname" : Which skybox to use. (e.g. textures/skies/sundown)
"ambientsound" : Sound shader to play in the background (looping) for when other env_soundscape entities are NOT active.
"startdark" : Starts the level with a fade in similar to using an env_fade, which lasts for nine seconds.
"hdr_iris_minvalue" : Minimum HDR brightness adjustment. Default is "0.0".
"hdr_iris_maxvalue" : Maximum HDR brightness adjustment. Default is "2.0".
"hdr_iris_multiplier" : HDR effect multiplier. Default is "1.0".
"hdr_iris_fade_up" : HDR iris fade up speed. Default is "0.1".
"hdr_iris_fade_down" : HDR iris fade down speed. Default is "0.5".

-------- NOTES --------
A map must only have one worldspawn entity.
Every game can have varying key definitions for the worldspawn entity.
It's also not affected by "killtarget".

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

#ifdef CLIENT
/* High Dynamic Range - Iris Adaption */
var float g_flHDRIrisMinValue = 0.0;
var float g_flHDRIrisMaxValue = 2.0;
var float g_flHDRIrisMultiplier = 1.0;
var float g_flHDRIrisFadeUp = 0.1;
var float g_flHDRIrisFadeDown = 0.5;
var int g_iHDREnabled = 0;

class worldspawn:NSEntity
{
	void(void) worldspawn;

	virtual void(string, string) SpawnKey;
	virtual void(void) Initialized;
};

void
worldspawn::Initialized(void)
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

void
worldspawn::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "startdark":
		if (stof(strKey) == 1)
			Fade_StartDark();
		break;
	case "chaptertitle":
		GameMessage_Setup(strKey, 0);
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

void
worldspawn::worldspawn(void)
{
#ifdef CLIENT
	Init();
#else
	super::NSEntity();
#endif
}
#endif
