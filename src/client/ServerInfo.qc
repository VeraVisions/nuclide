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

void
ncServerInfoManager::ncServerInfoManager(void)
{
	m_hostName = "";
	m_hostAddress = "";
	m_maxClients = 0i;
	m_maxPlayers = 0i;
	m_maxSpectators = 0i;
	
	m_maxClientsString = "";
	m_maxPlayersString = "";
	m_maxSpectatorsString = "";
}

void
ncServerInfoManager::Init(void)
{
	/* allocations happen here */
}

void
ncServerInfoManager::Shutdown(void)
{
	/* deallocations happen here */
}

string
ncServerInfoManager::HostName(void)
{
	return (m_hostName);
}

string
ncServerInfoManager::HostAddress(void)
{
	return (m_mapName);
}

string
ncServerInfoManager::MapName(void)
{
	return (m_hostAddress);
}

int
ncServerInfoManager::MaxClients(void)
{
	return (m_maxClients);
}

int
ncServerInfoManager::MaxPlayers(void)
{
	return (m_maxPlayers);
}

int
ncServerInfoManager::MaxSpectators(void)
{
	return (m_maxSpectators);
}

string
ncServerInfoManager::MaxClientsString(void)
{
	return (m_maxClientsString);
}

string
ncServerInfoManager::MaxPlayersString(void)
{
	return (m_maxPlayersString);
}

string
ncServerInfoManager::MaxSpectatorsString(void)
{
	return (m_maxSpectatorsString);
}

void
ncServerInfoManager::UpdateCache(void)
{
	m_hostName = serverinfo.GetString("hostname");
	m_hostAddress = serverinfo.GetString("ip");
	m_mapName = serverinfo.GetString("mapname");

	m_maxClientsString = serverinfo.GetString("maxclients");
	m_maxPlayersString = serverinfo.GetString("sv_playerslots");
	m_maxSpectatorsString = serverinfo.GetString("maxspectators");
	m_maxClients = stoi(m_maxClientsString);
	m_maxPlayers = stoi(m_maxPlayersString);
	m_maxSpectators = stoi(m_maxSpectatorsString);
}

void
CSQC_ServerInfoChanged(void)
{
	static ncServerInfoManager g_serverInfo;

	if (!g_serverInfo) {
		g_serverInfo = spawn(ncServerInfoManager);
		g_serverInfo.Init();
	}

	g_serverInfo.UpdateCache();
}
