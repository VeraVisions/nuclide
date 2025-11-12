/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

static void pointsound_proper(vector origin, string sample, float volume, float attenuation, float pitch) = #483;

#define SND_NOMINALDISTANCE autocvar_s_nominaldistance
#define SND_MAXRADIUS_QUAKE 1000.0f
#define SND_MAXRADIUS_SOURCE 1000.0f

#define ATTN_SOURCE_NONE		0.0f
#define ATTN_SOURCE_NORM		0.8f
#define ATTN_SOURCE_IDLE		2.0f
#define ATTN_SOURCE_STATIC		1.25f
#define ATTN_SOURCE_RICOCHET	1.5f
#define ATTN_SOURCE_GUNFIRE		0.27f
#define ATTN_SOURCE_TALKING		0.7f

void
SoundDef_Shutdown(void)
{
	/* free up the entity slot */
	for (ncSoundDict spaceList = 0; (spaceList = (ncSoundDict)find(spaceList, ::classname, "ncSoundDict"));) {
		remove(spaceList);
	}
}

void SoundSource_Init(void);

void
SoundDef_Init(void)
{
	InitStart();

	/* make sure it's all reset */
	SoundDef_Shutdown();

	/* Source Engine conventions */
	SoundSource_Init();

	precache_sound("common/null.wav");
	InitEnd();
}

static void
SoundDef_ParseField(ncSoundDict newSound, int a, string keyName, string valueCS)
{
	bool precacheSound = true;
	string setValue = strtolower(valueCS);

	switch (keyName) {
	/* classic Quake attenuation, used also by GoldSrc */
	case "attenuation":
		if (a == 2) {
			switch(setValue) {
			case "idle":
				newSound.dist_max = SND_MAXRADIUS_QUAKE / ATTN_IDLE;
				break;
			case "static":
				newSound.dist_max = SND_MAXRADIUS_QUAKE / ATTN_STATIC;
				break;
			case "none":
				newSound.dist_max = 0;
				break;
			case "normal":
				newSound.dist_max = SND_MAXRADIUS_QUAKE / ATTN_NORM;
			default:
				break;
			}
		}
		break;
	/* soundlevels = Source Engine, dB based. needs conversion to our attenuation > range */
	case "soundlevel":
		if (a == 2) {
			switch(setValue) {
			case "attn_idle":
			case "sndlvl_idle":
				newSound.dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_IDLE;
				break;
			case "attn_ricochet":
			case "attn_static":
			case "sndlvl_static":
				newSound.dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_STATIC;
				break;
			case "0":
			case "attn_none":
			case "sndlvl_none":
				newSound.dist_max = ATTN_SOURCE_NONE;
				break;
			case "attn_norm":
			case "sndlvl_norm":
				newSound.dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_NORM;
				break;
			case "attn_gunfire":
			case "sndlvl_gunfire":
				newSound.dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_GUNFIRE;
				break;
			case "attn_talking":
			case "sndlvl_talking":
				newSound.dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_TALKING;
				break;
			default:
				if (substring(setValue, 0, 7) == "sndlvl_") {
					float dbLevel = stof(substring(setValue, 7, -3));
					newSound.dist_max = SND_MAXRADIUS_SOURCE / ((dbLevel > 50.0f) ? (20.0f / (dbLevel - 50.0f)) : 4.0f);
				} else {
					ncError("Unknown soundlevel %S", setValue);
				}
				break;
			}
		}
		break;
	case "dist_min":
		if (a == 2) {
			newSound.dist_min = stof(setValue);
		}
		break;
	case "dist_max":
		if (a == 2) {
			newSound.dist_max = stof(setValue);
		}
		break;
	case "volume":
		if (a == 2) {
			newSound.volume = stof(setValue);
		}
		break;
	case "shakes":
		if (a == 2) {
			newSound.shakes = stof(setValue);
		}
		break;
	case "pitch":
		if (a == 2) {
			int comma = tokenizebyseparator(setValue, ",");

			if (comma == 2) {
				newSound.pitch_min = stof(argv(0));
				newSound.pitch_max = stof(argv(1));
			} else {
				newSound.pitch_min = fabs(stof(setValue)) * 100;
				newSound.pitch_max = newSound.pitch_min;
			}
		}
		break;
	case "pitch_min":
		if (a == 2) {
			newSound.pitch_min = fabs(stof(setValue)) * 100;
		}
		break;
	case "pitch_max":
		if (a == 2) {
			newSound.pitch_max = fabs(stof(setValue)) * 100;
		}
		break;
	case "offset":
		if (a == 2) {
			newSound.offset = stof(setValue);
		}
		break;
	case "looping":
		newSound.flags |= SNDFL_LOOPING;
		break;
	case "nodups":
		newSound.flags |= SNDFL_NODUPS;
		break;
	case "global":
		newSound.flags |= SNDFL_GLOBAL;
		break;
	case "private":
		newSound.flags |= SNDFL_PRIVATE;
		break;
	case "no_reverb":
		newSound.flags |= SNDFL_NOREVERB;
		break;
	case "omnidirectional":
		newSound.flags |= SNDFL_OMNI;
		break;
	case "follow":
		newSound.flags |= SNDFL_FOLLOW;
		break;
	case "footstep":
		newSound.flags |= SNDFL_STEP;
		break;
	case "distshader":
		newSound.distshader = valueCS;
		break;
	case "pointparticle":
		newSound.pointparticle = particleeffectnum(valueCS);
		break;
	case "alerts":
		newSound.flags |= SNDFL_ALERTS;
		break;
	case "music":
		if (a == 2) {
			precache.Music(setValue);
			newSound.musictracks = sprintf("%s%s\n", newSound.musictracks, setValue);
			newSound.music_count++;
		}
		break;
	case "wave":
		string randomPrefix = substring(setValue, 0, 1);

		/* why? what is any of this about? */
		if (randomPrefix == "^" || randomPrefix == ")" || randomPrefix == "*") {
			setValue = substring(setValue, 1, -1);
		}

		/* hack to deal with all the stuff we don't yet support */
		//if not (whichpack(strcat("sound/", setValue)))
			precacheSound = false;

	case "sample":
		if (a == 2) {
			if (precacheSound)
				precache_sound(setValue);

			newSound.samples = sprintf("%s%s\n", newSound.samples, setValue);
			newSound.sample_count++;
		}
		break;
	}
}

static int
SoundDef_Parse(ncSoundDict newSound, string line, string shader)
{
	int c;
	static string t_name;
	static int braced;

	c = tokenize_console(line);

	switch(argv(0)) {
	case "{":
		/* skip broken syntax */
		if (braced == TRUE || t_name == "") {
			break;
		}

		braced = TRUE;
		break;
	case "}":
		/* skip broken syntax */
		if (braced == FALSE) {
			break;
		}
		braced = FALSE;
		t_name = "";
		return (1);
		break;
	default:
		if (braced == TRUE) {
			SoundDef_ParseField(newSound, c, argv(0), argv(1));
		} else {
			/* name/identifer of our message */
			t_name = line;

			if (t_name == shader) {
				/* I guess it's what we want */
				newSound.name = shader;
			} else {
				/* not what we're looking for */
				t_name = "";
			}
		}
	}
	return (0);
}

bool
SoundDef_PrecacheFile(string fileName)
{
#if 1
	return (false);
#else
	filestream scriptFile;
	string lineStream;
	int braceDepth = 0i;
	string sndDefName = "";

	scriptFile = fopen(fileName, FILE_READ);

	if (scriptFile < 0) {
		return false;
	}

	SndLog("Precaching SOURCE ENGINE file %S", fileName);

	while ((lineStream = fgets(scriptFile))) {
		/* when we found it, quit */
		int lineSegments = tokenize_console(lineStream);

		/* word for word */
		for (int i = 0i; i < tokenize_console(lineStream); i++) {
			string word = argv(i);

			switch (word) {
			case "{":
				if (braceDepth == 0) {
					g_sounds[startIndex].volume = 1.0f;
					g_sounds[startIndex].dist_max = 1000;
					g_sounds[startIndex].pitch_min = g_sounds[startIndex].pitch_max = 100;
					g_sounds[startIndex].offset = 0;
				}
				braceDepth++;
				break;
			case "}":
				braceDepth--;

				/* sound definition done */
				if (braceDepth == 0) {
					//if (substring(sndDefName, 0, 11) == "Weapon_SMG1")
					//	error("");

				//	print(sprintf("sfx add %i %S\n", startIndex, sndDefName));
					sndDefName = "";
					startIndex++;
					g_sounds_count++;

					if (g_sounds_count >= SOUNDSHADER_MAX)
						return false;
				}
				break;
			default:
				if (braceDepth == 0) {
					sndDefName = word;
				} else {
					//print(sprintf("field %S %S\n", argv(i), argv(i+1)));
					SoundDef_ParseField(startIndex, 2, argv(i), argv(i+1));
					i++;
				}
				break;
			}
		}

	}

	fclose(scriptFile);
	return true;
#endif
}

static ncSoundDict
SoundDef_FindSoundByName(string soundName)
{
	for (ncSoundDict spaceList = 0; (spaceList = (ncSoundDict)find(spaceList, ::classname, "ncSoundDict"));) {
		if (spaceList.name == soundName) {
			return (spaceList);
		}
	}

	return (__NULL__);
}

static int
SoundDef_GetSoundIDByName(string soundName)
{
	float fakeModelIndex = getmodelindex(strcat("*S:", soundName), true);

	/* convert invalid modelindex to invalid sound index */
	if (!fakeModelIndex) {
		fakeModelIndex = -1;
	}

	return (int)fakeModelIndex;
}

int
SoundDef_Precache(string shader)
{
	searchhandle sh;
	filestream fh;
	string line;
	ncSoundDict newSound;

	if (!STRING_SET(shader)) {
		return -1i;
	}

	if (fileExists(strcat("sound/", shader)) == true) {
		precache_sound(shader);
		return -1i;
	}

	SndLog("Precaching SoundDef %S", shader);

	/* check if it's already cached */
	newSound = SoundDef_FindSoundByName(shader);
	
	if (newSound) {
		return (int)SoundDef_GetSoundIDByName(shader);
	}

	newSound = spawn(ncSoundDict);

	sh = search_begin("decls/sound/*.sndshd", TRUE, TRUE);

	for (int i = 0; i < search_getsize(sh); i++) {
		fh = fopen(search_getfilename(sh, i), FILE_READ);
		if (fh < 0) {
			continue;
		}

		while ((line = fgets(fh))) {
			/* when we found it, quit */
			if (SoundDef_Parse(newSound, line, shader) == TRUE) {
				search_end(sh);
				fclose(fh);

				/* distant shader */
				if (newSound.distshader) {
					SoundDef_Precache(newSound.distshader);
				}

				/* REGISTER IT so the client knows. */
#ifdef SERVER
				precache_model(strcat("*S:", shader));
#endif
				return SoundDef_GetSoundIDByName(shader);
			}
		}
		fclose(fh);
	}

	ncError("No SoundDef %S found.", shader);
	remove(newSound);
	search_end(sh);
	return -1;
}

void
SoundDef_Distance(entity target, string shader)
{
	int r;
	float volume;
	float radius;
	float pitch;
	int flag;
	ncSoundDict newSound;

	if (!STRING_SET(shader)) {
		return;
	}

	flag = 0;
	newSound = SoundDef_FindSoundByName(shader);

	if (!newSound) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  newSound.sample_count));
	tokenizebyseparator(newSound.samples, "\n");

	/* set pitch */
	pitch = random(newSound.pitch_min, newSound.pitch_max);
	radius = newSound.AttenuationValue();
	volume = newSound.volume;

	/* flags */
	if (newSound.flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (newSound.flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (newSound.flags & SNDFL_NODUPS) {
		if (newSound.playc >= newSound.sample_count) {
			newSound.playc = 0;
		}
		r = newSound.playc++;
	}

#ifdef CLIENT
	if (newSound.flags & SNDFL_OMNI) {
		flag |= SOUNDFLAG_NOSPACIALISE;
	}
#endif

	sound(
		target,
		5,
		argv(r),
		volume,
		ATTN_NONE,
		pitch,
		flag,
		newSound.offset
	);

	SndLog("Playing %S (vol: %f, pitch: %d)", argv(r), volume, pitch );
}

void
SoundDef_DistancePos(vector pos, string shader)
{
	int r;
	float volume;
	float radius;
	float pitch;
	int flag;
	ncSoundDict newSound;

	if (!STRING_SET(shader)) {
		return;
	}

	flag = 0;
	newSound = SoundDef_FindSoundByName(shader);

	if (!newSound) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  newSound.sample_count));
	tokenizebyseparator(newSound.samples, "\n");

	/* set pitch */
	pitch = random(newSound.pitch_min, newSound.pitch_max);
	radius = newSound.AttenuationValue();
	volume = newSound.volume;

	/* flags */
	if (newSound.flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (newSound.flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (newSound.flags & SNDFL_NODUPS) {
		if (newSound.playc >= newSound.sample_count) {
			newSound.playc = 0;
		}
		r = newSound.playc++;
	}

#ifdef CLIENT
	if (newSound.flags & SNDFL_OMNI) {
		flag |= SOUNDFLAG_NOSPACIALISE;
	}
#endif

	SndLog("Playing %S (radius: %f)", argv(r), newSound.dist_max );
	pointsound_proper(pos, argv(r), volume, ATTN_NONE, pitch);
}

void
SoundDef_Stop(entity target, float chan)
{
	SndLog("Stopping sound channel %d on %s (%d)", chan, target.classname, num_for_edict(target));
	sound(target, chan, "common/null.wav", 0.1f, ATTN_NORM, 100, SOUNDFLAG_FOLLOW, 0 );
}

void
SoundDef_Play(entity targetEntity, int chan, string shader)
{

	if (!STRING_SET(shader)) {
		return;
	}

	ncSoundDict newSound = SoundDef_FindSoundByName(shader);

	if (!newSound) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	newSound.PlayOnEntityChannel(targetEntity, chan);
}

void
SoundDef_PlayAt(vector pos, string shader)
{
	if (!STRING_SET(shader)) {
		return;
	}

	ncSoundDict newSound = SoundDef_FindSoundByName(shader);

	if (!newSound) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	newSound.PlayOnSpot(pos);
}

#ifdef CLIENT
void
SoundDef_PlayLocal(string shader)
{
	int r;
	int flag;

	if (!STRING_SET(shader)) {
		return;
	}
	ncSoundDict newSound;

	flag = 0;
	newSound = SoundDef_FindSoundByName(shader);

	if (!newSound) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  newSound.sample_count));
	tokenizebyseparator(newSound.samples, "\n");

	/* really? this doesn't do any more? */
	localsound(argv(r));
}

int
SoundDef_GetID(string defName)
{
	if (!STRING_SET(defName)) {
		return -1i;
	}

	return SoundDef_GetSoundIDByName(defName);
}

void
SoundDef_Update(entity target, int channel, int sample, float volume)
{
	ncSoundDict newSound = ncSoundDict::SoundForID(sample);
	newSound.UpdateChannelVolumeOnEntity(target, channel, volume);
}
#else
void
SoundDef_Speak(entity target, string shader)
{
	int r;
	float radius;
	float pitch;
	int flag;
	ncSoundDict newSound;

	if (!STRING_SET(shader)) {
		return;
	}

	flag = 0;
	newSound = SoundDef_FindSoundByName(shader);

	if (!newSound) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  newSound.sample_count));
	tokenizebyseparator(newSound.samples, "\n");

	/* set pitch */
	pitch = random(newSound.pitch_min, newSound.pitch_max);
	radius = newSound.dist_max;
	flag = 0;

	/* flags */
	if (newSound.flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (newSound.flags & SNDFL_GLOBAL) {
		radius = ATTN_NONE;
	}
	if (newSound.flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (newSound.flags & SNDFL_NODUPS) {
		if (newSound.playc >= newSound.sample_count) {
			newSound.playc = 0;
		}
		r = newSound.playc++;
	}
	if (newSound.flags & SNDFL_FOLLOW) {
		flag |= SOUNDFLAG_FOLLOW;
	}

	if (newSound.flags & SNDFL_PRIVATE) {
		flag |= SOUNDFLAG_UNICAST;
		msg_entity = target;
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SPEAK);
	WriteEntity(MSG_MULTICAST, target);
	WriteString(MSG_MULTICAST, argv(r));
	WriteFloat(MSG_MULTICAST, pitch);
	msg_entity = target;
	multicast(target.origin, MULTICAST_PVS);
}
#endif

/* utterly basic (and probably wrong...) support for Source Engine sound definitions */
void
SoundSource_Init(void)
{
	const string manifestStart = "scripts/game_sounds_manifest.txt";
	filestream manifestFile;
	string lineStream;

	manifestFile = fopen(manifestStart, FILE_READ);

	/* file doesn't exist. that's okay. */
	if (manifestFile < 0) {
		//error(sprintf("loading %S failed.\n", manifestStart));
		return;
	}

	while ((lineStream = fgets(manifestFile))) {
		/* when we found it, quit */
		int c = tokenize(lineStream);
		string key = argv(0);
		string value = argv(1);

		if (c == 2) {
			if (key == "precache_file") {
#if 1
				SoundDef_PrecacheFile(value);
#endif
			}
		}
	}
	fclose(manifestFile);
}


/** Called by listSoundDef */
void
SoundDef_DebugList(void)
{
	int soundsCount = 0i;

	for (ncSoundDict spaceList = 0; (spaceList = (ncSoundDict)find(spaceList, ::classname, "ncSoundDict"));) {
		print(sprintf("%i: %s (%i samples)\n", soundsCount, spaceList.name, spaceList.sample_count));
		soundsCount++;
	}

	print(sprintf("\t%i total soundDef loaded\n", soundsCount));
}
