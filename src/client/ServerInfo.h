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

/** A cache/manager for serverinfo on the client. You can talk to it for fast retrieval of server specific information
that is common to multiplayer games. It will offer string return values in certain cases too that are cached so no
conversion would have to be done per-frame. Everything returned here should be fast!

The per-player analog to this is ncUserInfoManager.

@ingroup client
*/
class
ncServerInfoManager
{
public:
	void ncServerInfoManager(void);

	nonvirtual void Init(void);
	nonvirtual void Shutdown(void);
	nonvirtual void UpdateCache(void);

	nonvirtual string HostName(void);
	nonvirtual string HostAddress(void);
	nonvirtual string MapName(void);

	nonvirtual int MaxClients(void);
	nonvirtual int MaxPlayers(void);
	nonvirtual int MaxSpectators(void);

	/* speedier for display purposes */
	nonvirtual string MaxClientsString(void);
	nonvirtual string MaxPlayersString(void);
	nonvirtual string MaxSpectatorsString(void);

private:
	string m_hostName;
	string m_hostAddress;
	string m_mapName;
	int m_maxClients;
	int m_maxPlayers;
	int m_maxSpectators;
	string m_maxClientsString;
	string m_maxPlayersString;
	string m_maxSpectatorsString;
};
