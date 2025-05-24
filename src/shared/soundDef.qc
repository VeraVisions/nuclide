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

#warning SoundDef should be stored in ncDict

static void pointsound_proper(vector origin, string sample, float volume, float attenuation, float pitch) = #483;

#ifndef SOUNDSHADER_DYNAMIC
	#ifndef SOUNDSHADER_MAX
		/** The max amount of soundDef entries. Can override this in your progs.src. */
		#define SOUNDSHADER_MAX 512
	#endif
#endif

/*
#define SOUNDSHADER_DYNAMIC

Your game can define SOUNDSHADER_DYNAMIC in its progs.src if you want an unpredictable amount of sound shaders.
Other than that, you can increase the value of SOUNDSHADER_MAX.

We switched to up-front allocation because QCLIB fragments memory like hell as there's
no real garbage collector to speak of
*/

void
SoundDef_Shutdown(void)
{
	if (g_sounds) {
		memfree(g_sounds);
	}

	g_sounds_count = 0;
	g_hashsounds = 0;
}

void SoundSource_Init(void);

void
SoundDef_Init(void)
{
	InitStart();

	/* make sure it's all reset */
	SoundDef_Shutdown();

#ifndef SOUNDSHADER_DYNAMIC
	g_sounds = (snd_t *)memalloc(sizeof(snd_t) * SOUNDSHADER_MAX);
	ncLog("...allocated %d bytes for SoundDef", sizeof(snd_t) * SOUNDSHADER_MAX);
#endif

	/* Source Engine conventions */
	SoundSource_Init();

	precache_sound("common/null.wav");
	InitEnd();
}

var int autocvar_s_nominaldistance = 1000;
#define SND_NOMINALDISTANCE autocvar_s_nominaldistance
#define SND_MAXRADIUS_QUAKE 1000
#define SND_MAXRADIUS_SOURCE 1000

#define ATTN_SOURCE_NONE		0.0f
#define ATTN_SOURCE_NORM		0.8f
#define ATTN_SOURCE_IDLE		2.0f
#define ATTN_SOURCE_STATIC		1.25f
#define ATTN_SOURCE_RICOCHET	1.5f
#define ATTN_SOURCE_GUNFIRE		0.27f
#define ATTN_SOURCE_TALKING		0.7f

static void
SoundDef_ParseField(int i, int a, string keyName, string valueCS)
{
	bool precacheSound = true;
	string setValue = strtolower(valueCS);

	switch (keyName) {
	/* classic Quake attenuation, used also by GoldSrc */
	case "attenuation":
		if (a == 2) {
			switch(setValue) {
			case "idle":
				g_sounds[i].dist_max = SND_MAXRADIUS_QUAKE / ATTN_IDLE;
				break;
			case "static":
				g_sounds[i].dist_max = SND_MAXRADIUS_QUAKE / ATTN_STATIC;
				break;
			case "none":
				g_sounds[i].dist_max = 0;
				break;
			case "normal":
				g_sounds[i].dist_max = SND_MAXRADIUS_QUAKE / ATTN_NORM;
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
				g_sounds[i].dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_IDLE;
				break;
			case "attn_ricochet":
			case "attn_static":
			case "sndlvl_static":
				g_sounds[i].dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_STATIC;
				break;
			case "0":
			case "attn_none":
			case "sndlvl_none":
				g_sounds[i].dist_max = ATTN_SOURCE_NONE;
				break;
			case "attn_norm":
			case "sndlvl_norm":
				g_sounds[i].dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_NORM;
				break;
			case "attn_gunfire":
			case "sndlvl_gunfire":
				g_sounds[i].dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_GUNFIRE;
				break;
			case "attn_talking":
			case "sndlvl_talking":
				g_sounds[i].dist_max = SND_MAXRADIUS_SOURCE / ATTN_SOURCE_TALKING;
				break;
			default:
				if (substring(setValue, 0, 7) == "sndlvl_") {
					float dbLevel = stof(substring(setValue, 7, -3));
					g_sounds[i].dist_max = SND_MAXRADIUS_SOURCE / ((dbLevel > 50.0f) ? (20.0f / (dbLevel - 50.0f)) : 4.0f);
				} else {
					ncError("Unknown soundlevel %S", setValue);
				}
				break;
			}
		}
		break;
	case "dist_min":
		if (a == 2) {
			g_sounds[i].dist_min = stof(setValue);
		}
		break;
	case "dist_max":
		if (a == 2) {
			g_sounds[i].dist_max = stof(setValue);
		}
		break;
	case "volume":
		if (a == 2) {
			g_sounds[i].volume = stof(setValue);
		}
		break;
	case "shakes":
		if (a == 2) {
			g_sounds[i].shakes = stof(setValue);
		}
		break;
	case "pitch":
		if (a == 2) {
			int comma = tokenizebyseparator(setValue, ",");

			if (comma == 2) {
				g_sounds[i].pitch_min = stof(argv(0));
				g_sounds[i].pitch_max = stof(argv(1));
			} else {
				g_sounds[i].pitch_min = fabs(stof(setValue)) * 100;
				g_sounds[i].pitch_max = g_sounds[i].pitch_min;
			}
		}
		break;
	case "pitch_min":
		if (a == 2) {
			g_sounds[i].pitch_min = fabs(stof(setValue)) * 100;
		}
		break;
	case "pitch_max":
		if (a == 2) {
			g_sounds[i].pitch_max = fabs(stof(setValue)) * 100;
		}
		break;
	case "offset":
		if (a == 2) {
			g_sounds[i].offset = stof(setValue);
		}
		break;
	case "looping":
		g_sounds[i].flags |= SNDFL_LOOPING;
		break;
	case "nodups":
		g_sounds[i].flags |= SNDFL_NODUPS;
		break;
	case "global":
		g_sounds[i].flags |= SNDFL_GLOBAL;
		break;
	case "private":
		g_sounds[i].flags |= SNDFL_PRIVATE;
		break;
	case "no_reverb":
		g_sounds[i].flags |= SNDFL_NOREVERB;
		break;
	case "omnidirectional":
		g_sounds[i].flags |= SNDFL_OMNI;
		break;
	case "follow":
		g_sounds[i].flags |= SNDFL_FOLLOW;
		break;
	case "footstep":
		g_sounds[i].flags |= SNDFL_STEP;
		break;
	case "distshader":
		g_sounds[i].distshader = valueCS;
		break;
	case "pointparticle":
		g_sounds[i].pointparticle = particleeffectnum(valueCS);
		break;
	case "alerts":
		g_sounds[i].flags |= SNDFL_ALERTS;
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

			g_sounds[i].samples = sprintf("%s%s\n", g_sounds[i].samples, setValue);
			g_sounds[i].sample_count++;
		}
		break;
	}
}

static float
SoundDef_GetAttenuation(int i)
{
	if (g_sounds[i].dist_max == 0)
		return 0;
	else
		return cvar("s_nominaldistance") / g_sounds[i].dist_max;
}

static int
SoundDef_Parse(int i, string line, string shader)
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
			SoundDef_ParseField(i, c, argv(0), argv(1));
		} else {
			/* name/identifer of our message */
			t_name = line;

			if (t_name == shader) {
				/* I guess it's what we want */
				g_sounds[i].name = shader;
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
	filestream scriptFile;
	string lineStream;
	int braceDepth = 0i;
	string sndDefName = "";
	int startIndex = g_sounds_count;

	if (g_sounds_count >= SOUNDSHADER_MAX)
		return false;

	scriptFile = fopen(fileName, FILE_READ);

	if (scriptFile < 0) {
		return false;
	}

	/* create the hash-table if it doesn't exist */
	if (!g_hashsounds) {
		g_hashsounds = hash_createtab(2, HASH_ADD);
	}

	SndLog("Precaching SOURCE ENGINE file %S", fileName);

	while ((lineStream = fgets(scriptFile))) {
		/* when we found it, quit */
		int lineSegments = tokenize_console(lineStream);

		/* word for word */
		for (int i = 0i; i < lineSegments; i++) {
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

					hash_add(g_hashsounds, sndDefName, startIndex);
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
}

int
SoundDef_Precache(string shader)
{
	searchhandle sh;
	filestream fh;
	string line;
	int index;

	if (!STRING_SET(shader)) {
		return -1i;
	}

	if (fileExists(strcat("sound/", shader)) == true) {
		precache_sound(shader);
		return -1i;
	}

	index = g_sounds_count;

	SndLog("Precaching SoundDef %S", shader);

	/* create the hash-table if it doesn't exist */
	if (!g_hashsounds) {
		g_hashsounds = hash_createtab(2, HASH_ADD);
	}

	/* check if it's already cached */
	{
		int cache;
		cache = (int)hash_get(g_hashsounds, shader, -1);

		if (cache >= 0) {
			return cache;
		}
	}

	g_sounds_count++;

#ifdef SOUNDSHADER_DYNAMIC
	g_sounds = (snd_t *)memreallocOld(g_sounds, sizeof(snd_t), index, g_sounds_count);
#else
	if (g_sounds_count >= SOUNDSHADER_MAX) {
		ncError("Reached SOUNDSHADER_MAX (%d)", SOUNDSHADER_MAX);
		return -1;
	}
#endif

	g_sounds[index].volume = 1.0f;
	g_sounds[index].dist_max = 1000;
	g_sounds[index].pitch_min = g_sounds[index].pitch_max = 100;
	g_sounds[index].offset = 0;
	g_sounds[index].flags = SNDFL_FOLLOW;

	sh = search_begin("decls/sound/*.sndshd", TRUE, TRUE);

	for (int i = 0; i < search_getsize(sh); i++) {
		fh = fopen(search_getfilename(sh, i), FILE_READ);
		if (fh < 0) {
			continue;
		}

		while ((line = fgets(fh))) {
			/* when we found it, quit */
			if (SoundDef_Parse(index, line, shader) == TRUE) {
				search_end(sh);
				fclose(fh);
				hash_add(g_hashsounds, shader, (int)index);

				/* distant shader */
				if (g_sounds[index].distshader) {
					SoundDef_Precache(g_sounds[index].distshader);
				}

				/* REGISTER IT so the client knows. */
				precache_model(strcat("*S:", shader));
				return index;
			}
		}
		fclose(fh);
	}

	ncError("No SoundDef %S found.", shader);
	g_sounds_count--;
	search_end(sh);
	return -1;
}

static void
SoundDef_Distance(entity target, string shader)
{
	int r;
	float volume;
	float radius;
	float pitch;
	int flag;
	int sample;

	flag = 0;
	sample = (int)hash_get(g_hashsounds, shader, -1);

	if (sample < 0) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);
	radius = SoundDef_GetAttenuation(sample);
	volume = g_sounds[sample].volume;

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}

#ifdef CLIENT
	if (g_sounds[sample].flags & SNDFL_OMNI) {
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
		g_sounds[sample].offset
	);
}

static void
SoundDef_DistancePos(vector pos, string shader)
{
	int r;
	float volume;
	float radius;
	float pitch;
	int flag;
	int sample;

	flag = 0;
	sample = (int)hash_get(g_hashsounds, shader, -1);

	if (sample < 0) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);
	radius = SoundDef_GetAttenuation(sample);
	volume = g_sounds[sample].volume;

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}

#ifdef CLIENT
	if (g_sounds[sample].flags & SNDFL_OMNI) {
		flag |= SOUNDFLAG_NOSPACIALISE;
	}
#endif

	SndLog("Playing %S (radius: %f)", argv(r), g_sounds[sample].dist_max );
	pointsound_proper(pos, argv(r), volume, ATTN_NONE, pitch);
}

void
SoundDef_Stop(entity target, float chan)
{
	SndLog("Stopping sound channel %d on %s (%d)", chan, target.classname, num_for_edict(target));
	sound(target, chan, "common/null.wav", 0.1f, ATTN_NORM, 100, SOUNDFLAG_FOLLOW, 0 );
}

void
SoundDef_Play(entity target, int chan, string shader)
{
	int r;
	float volume;
	float radius;
	float pitch;
	float flag;
	int sample;

	if (shader == "")
		return;

	flag = 0;
	sample = (int)hash_get(g_hashsounds, shader, -1);

	if (sample < 0) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);
	radius = SoundDef_GetAttenuation(sample);
	volume = g_sounds[sample].volume;

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_GLOBAL) {
		radius = ATTN_NONE;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}
	if (g_sounds[sample].flags & SNDFL_FOLLOW) {
		flag |= SOUNDFLAG_FOLLOW;
	}
	if (g_sounds[sample].flags & SNDFL_STEP) {
		float s = vlen(target.velocity);

		if (s <= (g_pmoveVars.pm_walkspeed * 0.5)) {
			return;
		} else if (s <= g_pmoveVars.pm_walkspeed) {
			volume *= 0.35f;
		} else {
			volume *= 0.75f;
		}
	}
#ifdef CLIENT
	if (g_sounds[sample].flags & SNDFL_OMNI) {
		flag |= SOUNDFLAG_NOSPACIALISE;
	}
#else
	if (g_sounds[sample].flags & SNDFL_PRIVATE) {
		flag |= SOUNDFLAG_UNICAST;
		msg_entity = target;
	}
	if (g_sounds[sample].flags & SNDFL_ALERTS) {
		ncMonster_AlertEnemyAlliance(target.origin, g_sounds[sample].dist_max, target.m_iAlliance);
		BotLib_Alert(target.origin, g_sounds[sample].dist_max, target.team);
	}
#endif

	SndLog("Playing %S (radius: %f)", argv(r), g_sounds[sample].dist_max );

#ifdef SERVER
	if (g_sounds[sample].shakes > 0.0) {
		Client_ShakeOnce(target.origin, 512, 2.5, 1.0, 1.0f);
	}
#else
	if (g_sounds[sample].shakes > 0.0) {
		float srad = 512;
		float dist = vlen(pSeat->m_vecPredictedOrigin - target.origin);
		if (dist < srad) {
			float dif = 1.0 - (dist/srad);
			pSeat->m_flShakeFreq = (1.0 * dif) * g_sounds[sample].shakes;
			pSeat->m_flShakeAmp = (1.0 * dif) * g_sounds[sample].shakes;
			pSeat->m_flShakeDuration = soundlength(argv(r));
			pSeat->m_flShakeTime = pSeat->m_flShakeDuration;
		}
	}
#endif

#ifdef CLIENT
	if (g_sounds[sample].pointparticle)
		pointparticles(g_sounds[sample].pointparticle, target.origin, [0,0,0], 1);
#else
	if (g_sounds[sample].pointparticle)
		ncWarning("SoundDef %S is attempting to spawn a particle on the server side.", shader);
#endif

	sound(
		target,
		chan,
		argv(r),
		volume,
		radius,
		pitch,
		flag,
		g_sounds[sample].offset
	);

	if (g_sounds[sample].distshader) {
		SoundDef_Distance(target, g_sounds[sample].distshader);
	}
}

void
SoundDef_PlayAt(vector pos, string shader)
{
	int r;
	float radius;
	float pitch;
	int flag;
	int sample;

	if (shader == "")
		return;

	flag = 0;
	sample = (int)hash_get(g_hashsounds, shader, -1);

	if (sample < 0) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_GLOBAL) {
		radius = 0;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}
#ifdef CLIENT
	if (g_sounds[sample].flags & SNDFL_OMNI) {
		flag |= SOUNDFLAG_NOSPACIALISE;
	}
#endif

	SndLog("Playing %S (radius: %f)", argv(r), g_sounds[sample].dist_max );

	/* really? this doesn't do any more? */
	pointsound_proper(pos, argv(r), g_sounds[sample].volume, SoundDef_GetAttenuation(sample), pitch);

	if (g_sounds[sample].distshader) {
		SoundDef_DistancePos(pos, g_sounds[sample].distshader);
	}
}

#ifdef CLIENT
void
SoundDef_PlayLocal(string shader)
{
	int r;
	int flag;
	int sample;

	if (shader == "")
		return;

	flag = 0;
	sample = (int)hash_get(g_hashsounds, shader, -1);

	if (sample < 0) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* really? this doesn't do any more? */
	localsound(argv(r));
}

int
SoundDef_GetID(string defName)
{
	if (defName == "")
		return -1;

	return (int)hash_get(g_hashsounds, defName, -1);
}

void
SoundDef_Update(entity target, int channel, int sample, float volume)
{
	int r;
	float radius;
	float pitch;
	int flag;

	if (sample < 0) {
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);
	radius = SoundDef_GetAttenuation(sample);
	flag = 0;

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_GLOBAL) {
		radius = ATTN_NONE;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}
	if (g_sounds[sample].flags & SNDFL_OMNI) {
		flag |= SOUNDFLAG_NOSPACIALISE;
	}

	soundupdate(
		target,
		channel,
		argv(0),
		g_sounds[sample].volume * volume,
		radius,
		pitch,
		flag,
		g_sounds[sample].offset
	);
}
#else
void
SoundDef_Speak(entity target, string shader)
{
	int r;
	float radius;
	float pitch;
	int flag;
	int sample;

	sample = (int)hash_get(g_hashsounds, shader, -1);

	if (sample < 0) {
		ncError("SoundDef %S is not precached", shader);
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);
	radius = g_sounds[sample].dist_max;
	flag = 0;

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_GLOBAL) {
		radius = ATTN_NONE;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}
	if (g_sounds[sample].flags & SNDFL_FOLLOW) {
		flag |= SOUNDFLAG_FOLLOW;
	}

	if (g_sounds[sample].flags & SNDFL_PRIVATE) {
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
	for (int i = 0; i < g_sounds_count; i++) {
		print(sprintf("%i: %s (%i samples)\n", i, g_sounds[i].name, g_sounds[i].sample_count));
	}

	print(sprintf("\t%i total soundDef loaded\n", g_sounds_count));
}
