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

/*! \brief Server-Entity: Redundant Sound Emitter #1 */
/*!QUAKED target_speaker (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
This entity plays a background sound.

# KEYS
- "targetname" : Name
- "target" : Target when triggered
- "killtarget" : Target to kill when triggered
- "noise" : Path to the sound file
- "volume" : Volume to play the sound as (normalized, 0.0 - 1.0)
- "attenuation" : Attenuation. -1 = everywhere, 1 = normal, 2 = ATTN_IDLE, 3 = ATTN_STATIC

# SPAWNFLAGS
- LOOP (1) : Loop sound, always.

# TRIVIA
It was introduced in Quake II (1997).

@ingroup serverentity
@ingroup pointentity
*/
class
target_speaker:ncSound
{
public:
	void target_speaker(void);

	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
};

void
target_speaker::target_speaker(void)
{
}

void
target_speaker::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "noise":
		SetSample(setValue);
	case "volume":
		float ourVolume = ReadFloat(setValue);

		if (ourVolume <= 0.0) {
			ourVolume = 1.0f;
		}

		SetVolume(ourVolume);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
target_speaker::Respawn(void)
{
	if (HasSpawnFlags(1) == true) {
		ForceLoop(true);
	}
}
