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

#ifdef SERVER
void EntityDef_Init(void);
void MapTweaks_Init(void);
var int autocvar_sv_levelexec = 1;
#endif

/*!QUAKED worldspawn (0 0 0) ?
# OVERVIEW
Only used for the world.

# KEYS
- "message" : Full title of the map. (e.g. "Barbie's Domain")
- "author" : Author of the map.
- "chaptertitle" : Titles.txt entry to display when entering the level.
- "sounds" : CD track to play. Numerical value. Most likely starts at '2'.
- "_fog" : Fog in the playable area. Format: (density red green blue alpha depthbias)
- "_skyroomfog" : Fog in the skybox area. Format: (density red green blue alpha depthbias)
- "skyname" : Which skybox to use. (e.g. "textures/skies/sundown")
- "ambientsound" : Sound shader to play in the background (looping) for when other env_soundscape entities are NOT active.
- "startdark" : Starts the level with a fade in similar to using an env_fade, which lasts for nine seconds.
- "hdr_iris_minvalue" : Minimum HDR brightness adjustment. Default is "0.0".
- "hdr_iris_maxvalue" : Maximum HDR brightness adjustment. Default is "2.0".
- "hdr_iris_multiplier" : HDR effect multiplier. Default is "1.0".
- "hdr_iris_fade_up" : HDR iris fade up speed. Default is "0.1".
- "hdr_iris_fade_down" : HDR iris fade down speed. Default is "0.5".

# NOTES
A map must only have one worldspawn entity.
Every game can have varying key definitions for the worldspawn entity.
It's also not affected by "killtarget".

# TRIVIA
This entity was introduced in Quake (1996).
*/

#ifdef SERVER
class worldspawn:NSEntity
{
public:
	void worldspawn(void);

	virtual void Spawned(void);
	virtual void SpawnKey(string, string);

private:
	string m_strSkyName;
	bool m_bStartDark;
	string m_strChapterTitle;
	string m_strAmbientSound;
	string m_strBGMTrack;

	float m_flHDRIrisMinValue;
	float m_flHDRIrisMaxValue;
	float m_flHDRIrisMultiplier;
	float m_flHDRIrisFadeUp;
	float m_flHDRIrisFadeDown;
	bool m_bHDREnabled;
};


void
worldspawn::worldspawn(void)
{
	/* defaults */
	m_flHDRIrisMinValue = 1.0;
	m_flHDRIrisMaxValue = 2.0;
	m_flHDRIrisMultiplier = 1.0;
	m_flHDRIrisFadeUp = 0.1;
	m_flHDRIrisFadeDown = 0.5;
	m_bHDREnabled = false;

	if (serverkeyfloat("*bspversion") == BSPVER_HL) {
		m_strSkyName = "desert";
	} else {
		m_strSkyName = "";
	}

	m_bStartDark = false;
	m_strChapterTitle = "";
	m_strAmbientSound = "";
	m_strBGMTrack = "";

	print("--------- Map Initialization ---------\n");
	print(sprintf("Map: %s\n", mapname));
	print("----------- Game Map Init ------------\n");

	lightstyle(0, "m");
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	lightstyle(4, "mamamamamama");
	lightstyle(5, "jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	lightstyle(6, "nmonqnmomnmomomno");
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	lightstyle(9, "aaaaaaaazzzzzzzz");
	lightstyle(10, "mmamammmmammamamaaamammma");
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	lightstyle(12, "mmnnmmnnnmmnn");
	lightstyle(63, "a");

	Skill_Init();
	EntityDef_Init();
	MapTweaks_Init();

	precache_model("models/error.vvm");

	if (autocvar_sv_levelexec)
		readcmd(sprintf("exec maps/%s.cfg\n", mapname));

	print("Spawning entities\n");
}

void
worldspawn::Spawned(void)
{
	super::Spawned();
	touch = __NULL__;
	blocked = __NULL__;

	forceinfokey(world, "skyname", m_strSkyName);
	forceinfokey(world, "startdark", ftos(m_bStartDark));
	forceinfokey(world, "chaptertitle", m_strChapterTitle);
	forceinfokey(world, "ambientsound", m_strAmbientSound);
	forceinfokey(world, "bgm", m_strBGMTrack);

	if (m_bHDREnabled) {
		forceinfokey(world, "hdr_iris_minvalue", ftos(m_flHDRIrisMinValue));
		forceinfokey(world, "hdr_iris_maxvalue", ftos(m_flHDRIrisMaxValue));
		forceinfokey(world, "hdr_iris_multiplier", ftos(m_flHDRIrisMultiplier));
		forceinfokey(world, "hdr_iris_fade_up", ftos(m_flHDRIrisFadeUp));
		forceinfokey(world, "hdr_iris_fade_down", ftos(m_flHDRIrisFadeDown));
	} else {
		forceinfokey(world, "hdr_iris_minvalue", "");
		forceinfokey(world, "hdr_iris_maxvalue", "");
		forceinfokey(world, "hdr_iris_multiplier", "");
		forceinfokey(world, "hdr_iris_fade_up", "");
		forceinfokey(world, "hdr_iris_fade_down", "");
	}

	forceinfokey(world, "hdr", ftos(m_bHDREnabled));
}

void
worldspawn::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "skyname":
		m_strSkyName = ReadString(strValue);
		break;
	case "startdark":
		m_bStartDark = ReadBool(strValue);
		break;
	case "chaptertitle":
		m_strChapterTitle = ReadString(strValue);
		break;
	case "ambientsound":
		m_strAmbientSound = ReadString(strValue);
		break;
	/* Household Death */
	case "_bgm":
		m_strBGMTrack = ReadString(strValue);
		break;
	case "hdr_iris_minvalue":
		m_flHDRIrisMinValue = ReadFloat(strValue);
		m_bHDREnabled = true;
		break;
	case "hdr_iris_maxvalue":
		m_flHDRIrisMaxValue = ReadFloat(strValue);
		m_bHDREnabled = true;
		break;
	case "hdr_iris_multiplier":
		m_flHDRIrisMultiplier = ReadFloat(strValue);
		m_bHDREnabled = true;
		break;
	case "hdr_iris_fade_up":
		m_flHDRIrisFadeUp = ReadFloat(strValue);
		m_bHDREnabled = true;
		break;
	case "hdr_iris_fade_down":
		m_flHDRIrisFadeDown = ReadFloat(strValue);
		m_bHDREnabled = true;
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}
#endif

#ifdef CLIENT
/* There are a few reasons to avoid worldspawn networking itself in the form
of an entity. First of all, entity '0' cannot do that anyway - second we should
learn about the various world properties because we spawn into the game and
start networking various entity states. That way we can prepare to load music
tracks, adjust the client-side rendering (startdark comes to mind) accordingly. */
void
WorldSpawn_Init(void)
{
	string skyName = serverkey("skyname");
	bool startDark = serverkeyfloat("startdark");
	string chapterTitle = serverkey("chaptertitle");
	string ambientSound = serverkey("ambientsound");
	string bgmTrack = serverkey("bgm");
	float hdrMin = serverkeyfloat("hdr_iris_minvalue");
	float hdrMax = serverkeyfloat("hdr_iris_maxvalue");
	float hdrMultiplier = serverkeyfloat("hdr_iris_multiplier");
	float hdrFadeUp = serverkeyfloat("hdr_iris_fade_up");
	float hdrFadeDown = serverkeyfloat("hdr_iris_fade_down");
	bool hdrEnabled = serverkeyfloat("hdr");

	if (startDark == true)
		Fade_StartDark();

	if (chapterTitle) {
		GameMessage_Setup(chapterTitle, 0);
	}

	cvar_set("r_hdr_irisadaptation_minvalue", ftos(hdrMin));
	cvar_set("r_hdr_irisadaptation_maxvalue", ftos(hdrMax));
	cvar_set("r_hdr_irisadaptation_multiplier", ftos(hdrMultiplier));
	cvar_set("r_hdr_irisadaptation_fade_up", ftos(hdrFadeUp));
	cvar_set("r_hdr_irisadaptation_fade_down", ftos(hdrFadeDown));

	if (hdrEnabled == true) {
		cvar_set("r_hdr_irisadaptation", "1");
	} else {
		cvar_set("r_hdr_irisadaptation", "0");
	}

	if (!g_ambientsound) {
		g_ambientsound = spawn(env_soundscape);
		g_ambientsound.m_iShader = Sound_Precache(ambientSound);
	}

	if (bgmTrack) {
		localcmd(sprintf("music sound/bgm/%s.mp3\n", bgmTrack));
	}
}
#endif