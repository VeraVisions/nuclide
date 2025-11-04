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
ncUserInfoManager::ncUserInfoManager(void)
{
	m_numUsers = 0i;
	m_users = __NULL__;
	m_serverRanking = __NULL__;
}

void
ncUserInfoManager::InitWithSlots(int maxUserSlots)
{
	m_numUsers = maxUserSlots;
	m_users = memalloc(sizeof(ncUserInfo) * m_numUsers);
	m_serverRanking = memalloc(sizeof(int) * m_numUsers);

	for (int i = 0; i < m_numUsers; i++) {
		m_users[i] = spawn(ncUserInfo);
		m_users[i].m_slot = i;
		m_serverRanking[i] = -1i;
	}
}

void
ncUserInfoManager::Shutdown(void)
{
	if (m_numUsers <= 0i) {
		return;
	}

	for (int i = 0; i < m_numUsers; i++) {
		remove(m_users[i]);
	}

	m_numUsers = 0i;
	memfree(m_users);
	memfree(m_serverRanking);
}

void
ncUserInfoManager::UpdateRanking(void)
{
	int a = 0i;

	/* we first iterate over the server rankings */
	for (int i = 0; i < m_numUsers; i++) {
		m_serverRanking[i] = -1i;
	}

	/* ranked slots start at -1 */
	for (int i = -1; i >= -m_numUsers; i--) {
		float rankedSlot = (float)i;

		/* FIXME: we only have 'name' as a semi reliable bit to tie player ID with rank ID? */
		string rankedName = getplayerkeyvalue(rankedSlot, "name");

		/* end of the line */
		if (!STRING_SET(rankedName)) {
			break;
		}

		for (int x = 0; x < m_numUsers; x++) {
			string testSlotName = getplayerkeyvalue((float)x, "name");
			
			/* that's our player, return the actual id. */
			if (testSlotName == rankedName) {
				m_serverRanking[a] = x;
				a++;
				break;
			}
		}
	}
}

void
ncUserInfoManager::UpdateCachedSlot(int cachedSlot)
{
	ncUserInfo targetSlot = InfoByIndex(cachedSlot);

	if (targetSlot != __NULL__) {
		targetSlot.Update();
	}
}

int
ncUserInfoManager::NumSlots(void)
{
	return (m_numUsers);
}

void
ncUserInfoManager::DebugPrint(void)
{
	printf("ncUserInfoManager: %i entries\n", NumSlots());

	printf("users by numeric id order:\n");

	for (int i = 0; i < NumSlots(); i++) {
		ncUserInfo targetSlot = InfoByIndex(i);

		if (!targetSlot) {
			break;
		}

		targetSlot.DebugPrint();
	}
	printf("users by server ranking:\n");

	for (int i = 0; i < NumSlots(); i++) {
		ncUserInfo targetSlot = InfoByRanking(i);

		if (!targetSlot) {
			break;
		}

		targetSlot.DebugPrint();
	}
}

ncUserInfo
ncUserInfoManager::InfoByIndex(int rankingIndex)
{
	if (m_numUsers <= 0) {
		return (__NULL__);
	}

	if ((rankingIndex <= -1i) || (rankingIndex >= m_numUsers)) {
		return (__NULL__);
	}

	return (m_users[rankingIndex]);
}

ncUserInfo
ncUserInfoManager::InfoByRanking(int rankingIndex)
{
	int targetSlot = -1i;

	if (m_numUsers <= 0) {
		return (__NULL__);
	}

	if ((rankingIndex <= -1i) || (rankingIndex >= m_numUsers)) {
		return (__NULL__);
	}

	targetSlot = m_serverRanking[rankingIndex];

	if (targetSlot == -1i) {
		return (__NULL__);
	}

	return (m_users[targetSlot]);
}


ncUserInfo
ncUserInfoManager::LocalPlayerInfo(void)
{
	ncPlayer pl = (ncPlayer)pSeat->m_ePlayer;
	int playerIndex = -1i;
	
	if (pl) {
		playerIndex = pl.entnum-1;
	}

	if ((playerIndex <= -1i) || (playerIndex >= m_numUsers)) {
		return (__NULL__);
	}

	return (m_users[playerIndex]);
}


/* FIXME: this callback is run whenever a single user infokey changes.
   so we might want to curb repetition by scheduling updates */
void
CSQC_PlayerInfoChanged(float playerNum)
{
	if (!g_userInfo) {
		g_userInfo = spawn(ncUserInfoManager);
		g_userInfo.InitWithSlots(serverinfo.GetInteger("maxclients"));
	}

	g_userInfo.UpdateRanking();
	g_userInfo.UpdateCachedSlot((int)playerNum);
}
