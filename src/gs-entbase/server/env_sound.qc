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

/*! \brief Server-Entity: GoldSrc Audio DSP/Reverb Controller */
/*!QUAKED env_sound (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Environmental audio reverb modifier.

# KEYS
- "radius" : Radius in units.
- "roomtype" : See room type list.

# NOTES
This works only with the OpenAL sound backend.

## Room types
 - 0 - Default.
 - 1 - Generic location.
 - 2 - small room, out of metal.
 - 3 - Medium room, out of metal.
 - 4 - Large room, out of metal.
 - 5 - Small tunnel.
 - 6 - Medium tunnel.
 - 7 - Large tunnel.
 - 8 - Small chamber.
 - 9 - Medium chamber.
 - 10 - Large chamber.
 - 11 - Small, 'bright' room.
 - 12 - Medium, 'bright' room.
 - 13 - Large, 'bright' room.
 - 14 - Underwater, style #1.
 - 15 - Underwater, style #2.
 - 16 - Underwater, style #3.
 - 17 - Small concrete room.
 - 18 - Medium concrete room.
 - 19 - Large concrete room.
 - 20 - Big room style #1.
 - 21 - Big room style #2.
 - 22 - Big room style #3.
 - 23 - Small cavern.
 - 24 - Medium cavern.
 - 25 - Large cavern.
 - 26 - Weirdo preset #1.
 - 27 - Weirdo preset #2.
 - 28 - Weirdo preset #3.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
@ingroup sound
*/
class
env_sound:ncSoundScape
{
public:
	void env_sound(void);

	virtual void SpawnKey(string, string);

	/** Sets the reverb parameters to that of a legacy room type. */
	nonvirtual void SetRoomType(int);
};

void
env_sound::env_sound(void)
{

}

void
env_sound::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "roomtype":
		SetRoomType(ReadInt(setValue));
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
env_sound::SetRoomType(int roomType)
{
	switch (roomType) {
	case 1i:
		LoadFromEFX("gs_generic");
		break;
	case 2i:
		LoadFromEFX("gs_metal_s");
		break;
	case 3i:
		LoadFromEFX("gs_metal_m");
		break;
	case 4i:
		LoadFromEFX("gs_metal_l");
		break;
	case 5i:
		LoadFromEFX("gs_tunnel_s");
		break;
	case 6i:
		LoadFromEFX("gs_tunnel_m");
		break;
	case 7i:
		LoadFromEFX("gs_tunnel_l");
		break;
	case 8i:
		LoadFromEFX("gs_chamber_s");
		break;
	case 9i:
		LoadFromEFX("gs_chamber_m");
		break;
	case 10i:
		LoadFromEFX("gs_chamber_l");
		break;
	case 11i:
		LoadFromEFX("gs_bright_s");
		break;
	case 12i:
		LoadFromEFX("gs_bright_m");
		break;
	case 13i:
		LoadFromEFX("gs_bright_l");
		break;
	case 14i:
		LoadFromEFX("gs_water1");
		break;
	case 15i:
		LoadFromEFX("gs_water2");
		break;
	case 16i:
		LoadFromEFX("gs_water3");
		break;
	case 17i:
		LoadFromEFX("gs_concrete_s");
		break;
	case 18i:
		LoadFromEFX("gs_concrete_m");
		break;
	case 19i:
		LoadFromEFX("gs_concrete_l");
		break;
	case 20i:
		LoadFromEFX("gs_big1");
		break;
	case 21i:
		LoadFromEFX("gs_big2");
		break;
	case 22i:
		LoadFromEFX("gs_big3");
		break;
	case 23i:
		LoadFromEFX("gs_cavern_s");
		break;
	case 24i:
		LoadFromEFX("gs_cavern_m");
		break;
	case 25i:
		LoadFromEFX("gs_cavern_l");
		break;
	case 26i:
		LoadFromEFX("gs_weirdo1");
		break;
	case 27i:
		LoadFromEFX("gs_weirdo2");
		break;
	case 28i:
		LoadFromEFX("gs_weirdo3");
		break;
	default:
		LoadFromEFX("default");
	}
}
