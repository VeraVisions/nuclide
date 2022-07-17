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

/*QUAKED info_player_start (1 1 1) (-16 -16 -36) (16 16 36)
Player spawn position for single-player games.

-------- KEYS --------
"targetname" : Name

-------- NOTES --------
This entity is also used in Counter-Strike (2000) and its beta versions to mark
spawn-positions for the Counter-Terrorist team.

In order for a player to spawn here, the game needs to be in singleplayer mode
or multiplayer coop (if info_player_coop spawn points don't exist).

Mods may choose to have additional fields that are not documented here as part
of the entity, keep that in mind.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

/*QUAKED info_player_deathmatch (1 1 1) (-16 -16 -36) (16 16 36)
Player spawn position for deathmatch games.

-------- KEYS --------
"targetname" : Name

-------- NOTES --------
This entity is also used in Counter-Strike (2000) and its beta versions to mark
spawn-positions for the Terrorist team.

In order for a player to spawn here, the game needs to be in a compatible
multiplayer mode. This (with the exception of Counter-Strike) excludes team
based modes.

Mods may choose to have additional fields that are not documented here as part
of the entity, keep that in mind.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

/*QUAKED info_player_coop (1 1 1) (-16 -16 -36) (16 16 36)
Player spawn position for cooperative games.

-------- KEYS --------
"targetname" : Name

-------- NOTES --------
In order for a player to spawn here, the game needs to take place on a map
for singleplayer with cooperative multiplayer enabled.
If this entity isn't present on such a mode, info_player_start will be the
fallback spawn-point.

Mods may choose to have additional fields that are not documented here as part
of the entity, keep that in mind.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

CLASSEXPORT(info_target, info_notnull)
CLASSEXPORT(env_sound, info_notnull)
CLASSEXPORT(env_sun, info_notnull)
CLASSEXPORT(info_intermission, info_notnull)

CLASSEXPORT(prop_static, info_null)
CLASSEXPORT(func_dustmotes, info_null)
CLASSEXPORT(env_soundscape, info_null)
CLASSEXPORT(env_cubemap, info_null)
CLASSEXPORT(sky_camera, info_null)

void
env_glow(void)
{
	if (self.model) {
		precache_model(self.model);
	}
}
