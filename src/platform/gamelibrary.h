/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

/** Called when initializing the current game. Does not cache custom game/mod info. */
void GameLibrary_Init(void);
/** Called when you want to initialize custom games/mods. Might want to call this later
if the amount of locally installed mods is overwhelming. */
void GameLibrary_InitCustom(void);

/** Install the specified game. */
void GameLibrary_Install(int);
/** Activate the specified game. */
void GameLibrary_Activate(int);
/** Deactivate the currently running mod. Switching back to the base game. */
void GameLibrary_Deactivate(void);

/** Returns true/false depending on if a Game installation is in progress. */
bool GameLibrary_IsInstalling(void);
/** Returns a 0-100% value of game install progress, tracking across multiple packages. */
float GameLibrary_InstallProgress(void);