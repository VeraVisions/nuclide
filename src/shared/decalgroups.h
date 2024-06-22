/*
 * Copyright (c) 2022-2024 Vera Visions LLC.
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

/** @defgroup decalgroups Decal Groups
    @brief Handle the placement of random decals from a group.
    @ingroup shared

	A decal group consists of one material per line:

	groupname
	{
		"textures/decals/foo" "1"
		"textures/decals/bar" "1"
	}

	And the weight is used to determine how often the decal gets used.
	If you're unsure, put in "1". 

	Also, any group named 'TranslationData' will be ignored.
	That group is used in Source Engine games to map the 'gamematerial'
	keys from surfaceproperties.txt over to a decal.

	The reason why we can't support it is simple:
	In Source, decals are tied to surfaceproperties and in GoldSrc
	the weapons are responsible for deciding which decals to use
	on a surface. We obviously cannot do both, but the GoldSrc way
	is the most appropriate one for our purposes.

@{
*/

/* public API */
void DecalGroups_Init(void);
void DecalGroups_Place(string group, vector org);
int DecalGroups_NumForName(string group);

#ifdef CLIENT
void DecalGroups_Precache(void);
void DecalGroups_Receive(void);
#endif

/** @} */ // end of decalgroups