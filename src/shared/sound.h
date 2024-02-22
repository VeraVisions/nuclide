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

/*! @file sound.h
    @brief SoundDef system functions.

    Anything concerned with soundDef scripting happens here.
    They're the primary system with which you should be messing
    with the sound system. It allows modders to override/expand
    on the audio experience without having to edit the source code.

    Read [Sound: soundDef](Documentation/Sound/SoundDefs.md) for more information.
*/

.float maxspeed;
.float flags;

var bool autocvar_s_developer = false;
void
_Sound_Log(string msg)
{
	if (autocvar_s_developer == true)
		print(sprintf("%f %s\n", time, msg));
}
#define SndLog(...) _Sound_Log(sprintf(__VA_ARGS__))

/** Global hash table for name > soundDef id lookup. */
var hashtable g_hashsounds;

/** Enumeration of valid sound flags. */
typedef enumflags
{
	SNDFL_LOOPING,	/**< forceloop */
	SNDFL_NODUPS,	/**< don't random the samples */
	SNDFL_GLOBAL,	/**< no attenuation */
	SNDFL_NOREVERB,	/**< skip reverb */
	SNDFL_OMNI,		/**< volume on all channels is equal */
	SNDFL_PRIVATE,	/**< only play on target */
	SNDFL_STEP,		/**< volume is calculated from entity speed */
	SNDFL_FOLLOW,	/**< sample follows entity as it plays */
	SNDFL_ALERTS	/**< this sounds alerts AI, takes distance into account */
} soundFlag_t;

/** A soundDef aka 'sound shader' type. */
typedef struct
{
	float dist_min; /**< Minimum playback distance. Default is 0. */
	float dist_max; /**< Maximum playback distance. */
	float offset;	/**< Sound sample offset. Will start playback this many seconds in. */
	float pitch_min; /**< Minimum sound pitch. */
	float pitch_max; /**< Maximum sound pitch. */
	float shakes; /**< Earthquake/Shake amplifier. Default is 0. */
	float volume; /**< Desired playback volume. */
	soundFlag_t flags; /**< Sound flags that are applied to this soundDef. */
	int playc; /**< Number of plays. */
	int sample_count; /**< Total amount of samples within this soundDef. */
	string samples; /**< Separated list of samples. */
	string name; /**< Name of the soundDef. */
	string distshader; /**< soundDef to play where this soundDef is not audible. */
	float pointparticle;
} snd_t;

/** A sound sample of a sentences.txt word sequence. */
typedef struct
{
	string m_strSnd;
	float m_flLength;
	float m_flPitch;
} sound_t;

/** Pointer to the global soundDef table. */
snd_t *g_sounds;
/** Total amount of registered soundDef entries. */
int g_sounds_count; 

/** Called by the client inside CSQC_Init(), and on the server inside init(). */
void Sound_Init(void);
/** Called by CSQC_Shutdown() and in theory, somewhere on the server. */
void Sound_Shutdown(void);
/** Force the precache of a soundDef file. */
int Sound_Precache(string sndDef);
/** Play a soundDef on a given target entity. */
void Sound_Play(entity targetEntity, int sndChannel, string sndDef);
/** Play a soundDef a a given location. */
void Sound_PlayAt(vector worldPos, string sndDef);

#ifdef CLIENT
/** Client-side only: Play a sound locally, outside the game world. */
void Sound_PlayLocal(string shader);
/** Client-side only: Update the sound parameters on a given entity. */
void Sound_Update(entity targetEntity, int sndChannel, int sndSample, float desiredVolume);

int Sound_GetID(string sndDef);
#else
/** Server-side only: Play a sentences.txt entry on a given entity. */
void Sound_Speak(entity targetEntity, string sentencesEntry);
#endif

/** Stops sounds on a given channel, on a target entity. */
void Sound_Stop(entity target, int chan);

void Sound_DebugList();