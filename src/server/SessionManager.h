/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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

/** The gamestate, savegame manager.

This class manages state of a session.
Included but not limited to savegames, level transitions
and potentially server transitions.
*/
class
ncSessionManager
{
public:
	void ncSessionManager(void);

	const string GetGlobal(string);
	const void SetGlobal(string, string);
	const void HandleLevelTransition(void);
	const void TransitionFromPVS(ncEntity pvsEnt);
	const void TransitionFromVolume(ncEntity volumeEnt);
	const void RestoreStateFromHandle(float saveHandle, float entityCount, float playerSlots);
	const void SaveStateToHandle(float saveHandle, float entityCount, float playerSlots);
	const void ListGlobals(void);

private:
	const void _LoadTransition(void);
	const void _SaveTransition(ncEntity pvsTest, bool usePVS);
	const ncEntity _FindCarrierEntity(string globalName);
};
