/*
 * Copyright (c) 2025 Vera Visions LLC.
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

var float autocvar_s_nominaldistance = 1000.0f;

/** Enumeration of valid sound flags. */
typedef enumflags
{
	SNDFL_LOOPING,	/**< forceloop */
	SNDFL_NODUPS,	/**< don't random the samples */
	SNDFL_GLOBAL,	/**< no attenuation */
	SNDFL_NOREVERB,	/**< skip reverb */
	SNDFL_OMNI,	/**< volume on all channels is equal */
	SNDFL_PRIVATE,	/**< only play on target */
	SNDFL_STEP,	/**< volume is calculated from entity speed */
	SNDFL_FOLLOW,	/**< sample follows entity as it plays */
	SNDFL_ALERTS	/**< this sounds alerts AI, takes distance into account */
} soundFlag_t;

/** Dictionary for sound effect definition.

@ingroup decl
*/
class
ncSoundDict:ncDict
{
public:
	void ncSoundDict(void);

	nonvirtual float AttenuationValue(void);

private:
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
};

void
ncSoundDict::ncSoundDict(void)
{
	dist_min = 0;
	dist_max = 1000.0f;
	offset = 0;
	pitch_min = 100.0f;
	pitch_max = 100.0f;
	shakes = 0.0f;
	volume = 1.0f;
	flags = SNDFL_FOLLOW;
	playc = 0i;
	sample_count = 0i;
	samples = "";
	name = "";
	distshader = "";
	pointparticle = -1;
}


float
ncSoundDict::AttenuationValue(void)
{
	if (dist_max == 0)
		return 0;
	else
		return autocvar_s_nominaldistance / dist_max;
}
