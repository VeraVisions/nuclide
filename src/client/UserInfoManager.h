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

/** A cache/manager for userinfo on the client. You can talk to it for fast retrieval of player specific information
that is common to multiplayer games. It will offer string return values in certain cases too that are cached so no
conversion would have to be done per-frame. Everything returned here should be fast!

The per-server analog to this is ncServerInfoManager.

@ingroup client
*/
class
ncUserInfoManager
{
public:
	void ncUserInfoManager(void);

	nonvirtual void InitWithSlots(int maxUserSlots);
	nonvirtual void Shutdown(void);

	nonvirtual void UpdateRanking(void);
	nonvirtual void UpdateCachedSlot(int cachedSlot);

	nonvirtual int NumSlots(void);

	nonvirtual void DebugPrint(void);

	/* Returns the player info according to internal index. Invalid queries return -1. */
	nonvirtual ncUserInfo InfoByIndex(int targetIndex);

	/* Returns the player info according to the server ranking. Invalid queries return -1. */
	nonvirtual ncUserInfo InfoByRanking(int rankingIndex);

private:

	int m_numUsers;
	ncUserInfo *m_users;

	/* each index = id of a player slot */
	int *m_serverRanking;
};

ncUserInfoManager g_userInfo;
