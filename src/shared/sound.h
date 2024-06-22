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

/** @defgroup sounddefs Sound Definitions
    @brief SoundDef system functions.
    @ingroup sound

# SoundDefs {#sounddefs}

Nuclide mimics the sound defintion spec from **id Tech 4** somewhat, albeit
with some changes/enhancements. We call them **soundDefs**.

**The elevator pitch**: To allow for more control over the sounds than what was previously
allowed in id Tech engines we also allow designers to drop sounds into
the game without having to set some common parameters every time.

Instead of directly calling which .wav or .ogg file to play, we tell it
to play the single name of a sound def. For example:
*c1_sentry_loader_in* which can be located in **any** text file ending
with the **.sndshd** file extension inside the `sound/` directory.

```
  c1_sentry_loader_in
  {
    dist_min	10
    dist_max	25
  
    no_occlusion
    volume	0.25
  
    sample sound/movers/comm1/sentry_loader_in.wav
  }
```

![Attenuation Visualisation](sounds_attenuation.png "Attenuation")
-   dist_min / dist_max sets the radius where the sound fades out. The
    sound is at maximum volume inside 'dist_min' radius, and it
    completely silent after 'dist_max' radius.
-   The no_occlusion key tells the engine not to take level geometry in
    to account when calculating volume.
-   'volume' is the volume inside the inner radius of the sound.
-   The last line sets the actual sound file to play.

Let's take a look at another one:

```
  emetal_impacts
  {
    dist_min	5
    dist_max	45
    volume	0.5
  
    sample sound/impact/ambient_impacts/emetal_01.wav
    sample sound/impact/ambient_impacts/emetal_02.wav
    sample sound/impact/ambient_impacts/emetal_03.wav
    sample sound/impact/ambient_impacts/emetal_04.wav
    sample sound/impact/ambient_impacts/emetal_05.wav
  }
```

This one has multiple sound files specified, which means that **Nuclide** will randomly choose one to play.

## Commands {#commands}

|                 |                         |                                                                                                             |
|-----------------|-------------------------|-------------------------------------------------------------------------------------------------------------|
| **Key**         | **Value**               | **Description**                                                                                             |
| attenuation     | idle/static/none/normal | Changes the sound's attenuation, aka playback radius/distance. This essentially just changes **dist_max**.  |
| dist_min        | <float>                 | Sets the minimum playback distance in quake units.                                                          |
| dist_max        | <float>                 | Sets the maximum playback distance in quake units.                                                          |
| volume          | <float>                 | Sets the playback volume. 0.0 - 1.0 range.                                                                  |
| shakes          | <float>                 | Will shake the screen with an intensity specified. Play around with this, 256 is a good starting value.     |
| pitch           | <float>                 | Will set a specific pitch change. 0.0 - 2.0 range most commonly, but there's wiggle room.                   |
| pitch_min       | <float>                 | Will set a minimum pitch instead of an exact one. This means it'll play a random pitch between min and max. |
| pitch_max       | <float>                 | Will set a maximum pitch instead of an exact one. This means it'll play a random pitch between min and max. |
| offset          | <float>                 | Sound sample offset in seconds.                                                                             |
| looping         | none                    | Sound set to force loop, regardless of sound markers in file.                                               |
| nodups          | none                    | Don't play duplicate samples in sequence.                                                                   |
| global          | none                    | Play samples everywhere.                                                                                    |
| private         | none                    | Play samples privately onto the entity that it gets played on.                                              |
| no_reverb       | none                    | Disable any [EAX](/EAX "wikilink") on samples in this def.                                               |
| omnidirectional | none                    | Samples won't play from any particular direction.                                                           |
| follow          | none                    | Samples will move alongside the entity it's being played on                                                 |
| footstep        | none                    | Determines sample volume based upon the speed of the entity.                                                |
| distshader      | <string>                | Which sound def to play to everyone who is out of playback reach of this one.                            |
| sample          | <string>                | Adds a sample to play to the list. Will only play one at a time.                                            |

## Power to the developer {#power_to_the_developer}

Unlike the implementation in **id Tech 4**, all of the sound defs handling
is done in the game-logic and is therefore exposed to all developers.
Some mods may want to hook AI callbacks into the system, or create
visual effects when commands are called by a sound def. The
possibilities are endless!

@{
*/

.float maxspeed;
.float flags;

var bool autocvar_s_developer = false;
void
_SndLog(string functionName, string msg)
{
	if (autocvar_g_developerTimestamps)
		print(sprintf("^9%f ^xF50%s^7: %s\n", time, functionName, msg));
	else
		print(sprintf("^xF50%s^7: %s\n", functionName, msg));
}

/** Logs an sound system specific log message.
	 The console variable `s_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define SndLog(...) if (autocvar_s_developer) _SndLog(__FUNC__, sprintf(__VA_ARGS__))

void
_SndEntLog(string className, string functionName, float edictNum, string warnMessage)
{
	if (autocvar_g_developerTimestamps)
		print(sprintf("^9%f ^xF50%s (id: %d)^7: %s\n", time, functionName, edictNum, warnMessage));
	else
		print(sprintf("^xF50%s (id: %d)^7: %s\n", functionName, edictNum, warnMessage));
}

/** Logs an sound specific entity class log message.
	 The console variable `s_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define SndEntLog(...) if (autocvar_s_developer) _SndEntLog(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))

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

/** @} */ // end of sounddefs
