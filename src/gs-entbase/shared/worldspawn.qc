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

/*! \brief Shared-Entity: Game World */
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
- "_litwater" : Set to 1 for a HL BSP to have lightmapped water surfaces.

# NOTES
A map must only have one worldspawn entity.
Every game can have varying key definitions for the worldspawn entity.
It's also not affected by "killtarget".

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup sharedentity
@ingroup brushentity
*/

#ifdef SERVER
class ncWorldSpawn:ncEntity
{
public:
	void ncWorldSpawn(void);

	virtual void Spawned(void);
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void SpawnKey(string, string);

private:
	string m_strSkyName;
	bool m_bStartDark;
	bool m_bGameTitle;
	string m_strChapterTitle;
	string m_strAmbientSound;
	string m_strBGMTrack;

	float m_flHDRIrisMinValue;
	float m_flHDRIrisMaxValue;
	float m_flHDRIrisMultiplier;
	float m_flHDRIrisFadeUp;
	float m_flHDRIrisFadeDown;
	bool m_bHDREnabled;
	bool m_bLitWater;
};

void
ncWorldSpawn::ncWorldSpawn(void)
{
	/* defaults */
	m_flHDRIrisMinValue = 0.0;
	m_flHDRIrisMaxValue = 1.25;
	m_flHDRIrisFadeUp = 0.1;
	m_flHDRIrisFadeDown = 0.2;
	m_bHDREnabled = false;
	m_bLitWater = false;

	if (serverkeyfloat("*bspversion") == BSPVER_HL) {
		m_strSkyName = "desert";
		m_flHDRIrisMultiplier = 1.5;
		m_flHDRIrisMaxValue = 1.5;
	} else {
		m_strSkyName = "";
		m_flHDRIrisMultiplier = 0.75;
		m_flHDRIrisMaxValue = 1.5;
	}

	m_bStartDark = false;
	m_strChapterTitle = "";
	m_strAmbientSound = "";
	m_strBGMTrack = "";

	InitPrint("Map Initialization");
	NSLog("Map: %s", mapname);

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
	lightstyle(64, "m");
	lightstyle(65, "z");

	precache.Model("models/error.vvm");

	//if (autocvar_sv_levelexec)
	//	readcmd(sprintf("exec maps/%s.cfg\n", mapname));
}

void
ncWorldSpawn::Spawned(void)
{
	super::Spawned();

	touch = __NULL__;
	blocked = __NULL__;

	serverinfo.SetString("skyname", m_strSkyName);
	serverinfo.SetString("chaptertitle", m_strChapterTitle);
	serverinfo.SetString("ambientsound", m_strAmbientSound);
	serverinfo.SetString("bgm", m_strBGMTrack);

	/* these set cvars so we kinda always want to set them to ~something~ */
	serverinfo.SetFloat("hdr_iris_minvalue", m_flHDRIrisMinValue);
	serverinfo.SetFloat("hdr_iris_maxvalue", m_flHDRIrisMaxValue);
	serverinfo.SetFloat("hdr_iris_multiplier", m_flHDRIrisMultiplier);
	serverinfo.SetFloat("hdr_iris_fade_up", m_flHDRIrisFadeUp);
	serverinfo.SetFloat("hdr_iris_fade_down", m_flHDRIrisFadeDown);
	serverinfo.SetBool("hdr", m_bHDREnabled);

	serverinfo.SetBool("gametitle", m_bGameTitle);
	serverinfo.SetBool("startdark", m_bStartDark);
	serverinfo.SetBool("litwater", m_bLitWater);


#if 0
	env_cascade_light sunLight = spawn(env_cascade_light);
	sunLight.Respawn();
	sunLight.SetOrigin(GetOrigin());
	sunLight.m_bUseEnvAngles = true;
	sunLight.m_bUseEnvColors = true;
	sunLight.m_flShadowDistance = 1024;
#endif
}

void
ncWorldSpawn::SpawnKey(string strKey, string strValue)
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
	case "gametitle":
		m_bGameTitle = ReadBool(strValue);
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
	/* empty, ignore */
	case "wad":
	case "MaxRange":
	case "sounds":
		break;
	case "_litwater":
		m_bLitWater = ReadBool(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
ncWorldSpawn::Save(float handle)
{
	super::Save(handle);

	SaveString(handle, "m_strSkyName", m_strSkyName);
	SaveBool(handle, "m_bStartDark", m_bStartDark);
	SaveBool(handle, "m_bGameTitle", m_bGameTitle);
	SaveString(handle, "m_strChapterTitle", m_strChapterTitle);
	SaveString(handle, "m_strAmbientSound", m_strAmbientSound);
	SaveString(handle, "m_strBGMTrack", m_strBGMTrack);
	SaveFloat(handle, "m_flHDRIrisMinValue", m_flHDRIrisMinValue);
	SaveFloat(handle, "m_flHDRIrisMaxValue", m_flHDRIrisMaxValue);
	SaveFloat(handle, "m_flHDRIrisMultiplier", m_flHDRIrisMultiplier);
	SaveFloat(handle, "m_flHDRIrisFadeUp", m_flHDRIrisFadeUp);
	SaveFloat(handle, "m_flHDRIrisFadeDown", m_flHDRIrisFadeDown);
	SaveBool(handle, "m_bHDREnabled", m_bHDREnabled);
	SaveBool(handle, "m_bLitWater", m_bLitWater);
}

void
ncWorldSpawn::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strSkyName":
		m_strSkyName = ReadString(strValue);
		break;
	case "m_bStartDark":
		m_bStartDark = ReadBool(strValue);
		break;
	case "m_bGameTitle":
		m_bGameTitle = ReadBool(strValue);
		break;
	case "m_strChapterTitle":
		m_strChapterTitle = ReadString(strValue);
		break;
	case "m_strAmbientSound":
		m_strAmbientSound = ReadString(strValue);
		break;
	case "m_strBGMTrack":
		m_strBGMTrack = ReadString(strValue);
		break;
	case "m_flHDRIrisMinValue":
		m_flHDRIrisMinValue = ReadFloat(strValue);
		break;
	case "m_flHDRIrisMaxValue":
		m_flHDRIrisMaxValue = ReadFloat(strValue);
		break;
	case "m_flHDRIrisMultiplier":
		m_flHDRIrisMultiplier = ReadFloat(strValue);
		break;
	case "m_flHDRIrisFadeUp":
		m_flHDRIrisFadeUp = ReadFloat(strValue);
		break;
	case "m_flHDRIrisFadeDown":
		m_flHDRIrisFadeDown = ReadFloat(strValue);
		break;
	case "m_bHDREnabled":
		m_bHDREnabled = ReadBool(strValue);
		break;
	case "m_bLitWater":
		m_bLitWater = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

void
worldspawn(void)
{
	ncWorldSpawn ourWorld = spawn(ncWorldSpawn);
	ourWorld.pvsflags = PVSF_IGNOREPVS;

	/* fill the delegate with spawndata */
	if (__fullspawndata) {
		for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
			ourWorld.SpawnKey(argv(i), argv(i+1));
		}
	}

	ourWorld.Spawned();
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

	if (startDark == true) {
		Fade_StartDark();
	}

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
