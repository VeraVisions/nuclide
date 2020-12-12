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
	float shakes;
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
int g_sounds_count; 

void Sound_Init(void);
void Sound_Shutdown(void);
void Sound_ParseField(int i, int a);
int Sound_Parse(int i, string line, string shader);
int Sound_Precache(string shader);
void Sound_Play(entity target, int chan, string shader);
void Sound_PlayAt(vector pos, string shader);

#ifdef CLIENT
void Sound_Update(entity target, int channel, int sample, float volume);
#else
void Sound_Speak(entity target, string shader);
#endif
