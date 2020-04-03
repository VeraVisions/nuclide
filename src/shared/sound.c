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

var hashtable g_hashsounds;

enumflags
{
	SNDFL_LOOPING,	/* forceloop */
	SNDFL_NODUPS,	/* don't random the samples */
	SNDFL_GLOBAL,	/* no attenuation */
	SNDFL_NOREVERB,	/* skip reverb */
	SNDFL_OMNI,	/* volume on all channels is equal */
	SNDFL_PRIVATE,	/* only play on target */
	SNDFL_STEP, /* volume is calculated from entity speed */
	SNDFL_FOLLOW
};

typedef struct
{
	float dist_min;
	float dist_max;
	float offset;
	float pitch_min;
	float pitch_max;
	float shake;
	float volume;
	int flags;
	int playc;
	int sample_count;
	string samples;
	string name;
} snd_t;

typedef struct
{
	string m_strSnd;
	float m_flLength;
	float m_flPitch;
} sound_t;

snd_t *g_sounds;
static int g_sounds_count;

void
Sound_ParseField(int i, int a)
{
	switch (argv(0)) {
	case "attenuation":
		if (a == 2) {
			switch(argv(1)) {
			case "idle":
				g_sounds[i].dist_max = ATTN_IDLE;
				break;
			case "static":
				g_sounds[i].dist_max = ATTN_STATIC;
				break;
			case "none":
				g_sounds[i].dist_max = ATTN_NONE;
				break;
			case "normal":
				g_sounds[i].dist_max = ATTN_NORM;
			default:
				break;
			}
		}
		break;
	case "dist_min":
		if (a == 2) {
			dprint("\tMin distance set\n");
			g_sounds[i].dist_min = stof(argv(1));
		}
		break;
	case "dist_max":
		if (a == 2) {
			dprint("\tMax distance set\n");
			g_sounds[i].dist_max = stof(argv(1));
		}
		break;
	case "volume":
		if (a == 2) {
			dprint("\tVolume set\n");
			g_sounds[i].volume = stof(argv(1));
		}
		break;
	case "shakes":
		if (a == 2) {
			dprint("\tShake set\n");
			g_sounds[i].shake = stof(argv(1));
		}
		break;
	case "pitch":
		if (a == 2) {
			dprint("\tPitch set\n");
			g_sounds[i].pitch_min = fabs(stof(argv(1))) * 100;
			g_sounds[i].pitch_max = g_sounds[i].pitch_min;
		}
		break;
	case "pitch_min":
		if (a == 2) {
			dprint("\tMinimum pitch set\n");
			g_sounds[i].pitch_min = fabs(stof(argv(1))) * 100;
		}
		break;
	case "pitch_max":
		if (a == 2) {
			dprint("\tMaximum pitch set\n");
			g_sounds[i].pitch_max = fabs(stof(argv(1))) * 100;
		}
		break;
	case "offset":
		if (a == 2) {
			dprint("\tOffset set\n");
			g_sounds[i].offset = stof(argv(1));
		}
		break;
	case "looping":
		dprint("\tSound set to loop\n");
		g_sounds[i].flags |= SNDFL_LOOPING;
		break;
	case "nodups":
		dprint("\tSound set to not play duplicate samples\n");
		g_sounds[i].flags |= SNDFL_NODUPS;
		break;
	case "global":
		dprint("\tSound set to play everywhere\n");
		g_sounds[i].flags |= SNDFL_GLOBAL;
		break;
	case "private":
		dprint("\tSound set to play privately\n");
		g_sounds[i].flags |= SNDFL_PRIVATE;
		break;
	case "no_reverb":
		dprint("\tSound set to ignore reverb\n");
		g_sounds[i].flags |= SNDFL_NOREVERB;
		break;
	case "omnidirectional":
		dprint("\tSound set to be omnidirectional\n");
		g_sounds[i].flags |= SNDFL_OMNI;
		break;
	case "follow":
		dprint("\tSound set to follow\n");
		g_sounds[i].flags |= SNDFL_FOLLOW;
		break;
	case "footstep":
		g_sounds[i].flags |= SNDFL_STEP;
		break;
	case "sample":
		if (a == 2) {
			dprint("\tAdded sample ");
			dprint(argv(1));
			dprint("\n");
			precache_sound(argv(1));
			g_sounds[i].samples = sprintf("%s%s\n", g_sounds[i].samples, argv(1));
			g_sounds[i].sample_count++;
		}
		break;
	}
}

int
Sound_Parse(int i, string line, string shader)
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

		dprint("{\n");
		braced = TRUE;
		break;
	case "}":
		/* skip broken syntax */
		if (braced == FALSE) {
			break;
		}
		dprint("}\n");
		braced = FALSE;
		t_name = "";
		return TRUE;
		break;
	default:
		if (braced == TRUE) {
			Sound_ParseField(i, c);
		} else {
			/* name/identifer of our message */
			t_name = strtolower(line);
			
			if (t_name == shader) {
				/* I guess it's what we want */
				dprint("Found shader ");
				dprint(shader);
				dprint(":\n");
				g_sounds[i].name = shader;
			} else {
				/* not what we're looking for */
				t_name = "";
			}
		}
	}
	return FALSE;
}

int
Sound_Precache(string shader)
{
	searchhandle sh;
	filestream fh;
	string line;
	int index;

	index = g_sounds_count;
	shader = strtolower(shader);

	dprint("[SOUND] Precaching sound shader ");
	dprint(shader);
	dprint("\n");

	/* create the hash-table if it doesn't exist */
	if (!g_hashsounds) {
		g_hashsounds = hash_createtab(2, HASH_ADD);
	}

	/* check if it's already cached */
	for (int i = 0; i < g_sounds_count; i++) {
		if (shader == g_sounds[i].name) {
			dprint("[SOUND] Shader already precached.\n");
			return i;
		}
	}

	g_sounds_count++;
	g_sounds = memrealloc(g_sounds, sizeof(snd_t), index, g_sounds_count);

	g_sounds[index].volume = 1.0f;
	g_sounds[index].dist_max = 1;
	g_sounds[index].pitch_min = g_sounds[index].pitch_max = 100;

	sh = search_begin("sound/*.sndshd", TRUE, TRUE);

	for (int i = 0; i < search_getsize(sh); i++) {
		fh = fopen(search_getfilename(sh, i), FILE_READ);
		if (fh < 0) {
			continue;
		}

		while ((line = fgets(fh))) {
			/* when we found it, quit */
			if (Sound_Parse(index, line, shader) == TRUE) {
				search_end(sh);
				fclose(fh);
				hash_add(g_hashsounds, shader, (int)index);
				return index;
			}
		}
		fclose(fh);
	}

	dprint("^1[SOUND] No shader found for ");
	dprint(shader);
	dprint("\n");

	search_end(sh);
	fclose(fh);
	return -1;
}

void
Sound_Play(entity target, int chan, string shader)
{
	int r;
	float volume;
	float radius;
	float pitch;
	int flags;
	int sample;

	sample = (int)hash_get(g_hashsounds, shader);

	if (sample < 0) {
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);
	radius = g_sounds[sample].dist_max;
	volume = g_sounds[sample].volume;

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flags |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_GLOBAL) {
		radius = ATTN_NONE;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flags |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}
	if (g_sounds[sample].flags & SNDFL_FOLLOW) {
		flags |= SOUNDFLAG_FOLLOW;
	}
	if (g_sounds[sample].flags & SNDFL_STEP) {
		float s = vlen(target.velocity);
		if (s < 120) {
			return;
		} else if (s < 270) {
			volume = 0.35f;
		} else {
			volume = 0.75;
		}
	}
#ifdef CSQC
	if (g_sounds[sample].flags & SNDFL_OMNI) {
		flags |= SOUNDFLAG_NOSPACIALISE;
	}
#else
	if (g_sounds[sample].flags & SNDFL_PRIVATE) {
		flags |= SOUNDFLAG_UNICAST;
		msg_entity = target;
	}
#endif

#ifdef DEVELOPER
	print(sprintf("Sound_Play: %s\n", argv(r)));
#endif

	sound(
		target,
		chan, 
		argv(r),
		volume,
		radius,
		pitch,
		flags,
		g_sounds[sample].offset
	);
}

void
Sound_PlayAt(vector pos, string shader)
{
	int r;
	float radius;
	float pitch;
	int flags;
	int sample;

	sample = (int)hash_get(g_hashsounds, shader);

	if (sample < 0) {
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flags |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_GLOBAL) {
		radius = 0;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flags |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}
#ifdef CSQC
	if (g_sounds[sample].flags & SNDFL_OMNI) {
		flags |= SOUNDFLAG_NOSPACIALISE;
	}
#endif

	/* really? this doesn't do any more? */
	pointsound(pos, argv(r), g_sounds[sample].volume, g_sounds[sample].dist_max);
}

#ifdef CSQC
void
Sound_Update(entity target, int channel, int sample, float volume)
{
	int r;
	float radius;
	float pitch;
	int flags;

	if (sample < 0) {
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);
	radius = g_sounds[sample].dist_max;

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flags |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_GLOBAL) {
		radius = ATTN_NONE;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flags |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}
	if (g_sounds[sample].flags & SNDFL_OMNI) {
		flags |= SOUNDFLAG_NOSPACIALISE;
	}

	soundupdate(
		target,
		channel,
		argv(0),
		g_sounds[sample].volume * volume,
		radius,
		pitch,
		flags,
		g_sounds[sample].offset
	);
}
#else
void
Sound_Speak(entity target, string shader)
{
	int r;
	float radius;
	float pitch;
	int flags;
	int sample;

	sample = (int)hash_get(g_hashsounds, shader);

	if (sample < 0) {
		return;
	}

	/* pick a sample */
	r = floor(random(0,  g_sounds[sample].sample_count));
	tokenizebyseparator(g_sounds[sample].samples, "\n");

	/* set pitch */
	pitch = random(g_sounds[sample].pitch_min, g_sounds[sample].pitch_max);
	radius = g_sounds[sample].dist_max;

	/* flags */
	if (g_sounds[sample].flags & SNDFL_NOREVERB) {
		flags |= SOUNDFLAG_NOREVERB;
	}
	if (g_sounds[sample].flags & SNDFL_GLOBAL) {
		radius = ATTN_NONE;
	}
	if (g_sounds[sample].flags & SNDFL_LOOPING) {
		flags |= SOUNDFLAG_FORCELOOP;
	}
	if (g_sounds[sample].flags & SNDFL_NODUPS) {
		if (g_sounds[sample].playc >= g_sounds[sample].sample_count) {
			g_sounds[sample].playc = 0;
		}
		r = g_sounds[sample].playc++;
	}
	if (g_sounds[sample].flags & SNDFL_FOLLOW) {
		flags |= SOUNDFLAG_FOLLOW;
	}

	if (g_sounds[sample].flags & SNDFL_PRIVATE) {
		flags |= SOUNDFLAG_UNICAST;
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
