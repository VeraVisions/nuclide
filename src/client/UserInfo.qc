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
ncUserInfo::ncUserInfo(void)
{

}

string
ncUserInfo::ID(void)
{
	return (m_userID);
}

string
ncUserInfo::Name(void)
{
	return (m_userNames);
}

string
ncUserInfo::Model(void)
{
	return (m_userModels);
}

string
ncUserInfo::Avatar(void)
{
	return (m_userAvatars);
}

string
ncUserInfo::Banner(void)
{
	return (m_userBanner);
}

string
ncUserInfo::Contact(void)
{
	return (m_userContact);
}

string
ncUserInfo::Flag(void)
{
	return (m_userFlag);
}

int
ncUserInfo::Team(void)
{
	return (m_userTeam);
}

int
ncUserInfo::Kills(void)
{
	return (m_userKills);
}

int
ncUserInfo::Deaths(void)
{
	return (m_userDeaths);
}

int
ncUserInfo::Score(void)
{
	return (m_userScore);
}

void
ncUserInfo::DebugPrint(void)
{
	if (STRING_SET(m_userNames)) {
		printf("%d: %s\n", m_slot, Name());
	} else {
		printf("%d: ^8[ empty player slot ]\n", m_slot);
	}
}

void
ncUserInfo::Update(void)
{
	m_userID = getplayerkeyvalue(m_slot, "guid");
	m_userNames = getplayerkeyvalue(m_slot, "name");

	/* user isn't even valid */
	if (!STRING_SET(m_userNames)) {
		m_userID = "";
		m_userModels = "";
		m_userAvatars = "";
		m_userBanner = "";
		m_userContact = "";
		m_userFlag = "";

		m_userKills = 0i;
		m_userDeaths = 0i;
		m_userScore = 0i;
		return;
	}

	if (!STRING_SET(m_userID)) {
		m_userID = "NOAUTH";
	}

	m_userModels = getplayerkeyvalue(m_slot, "model");
	m_userAvatars = getplayerkeyvalue(m_slot, "avatar");
	m_userBanner = getplayerkeyvalue(m_slot, "bg");
	m_userContact = getplayerkeyvalue(m_slot, "fedi");
	m_userFlag = getplayerkeyvalue(m_slot, "flag");

	m_userKills = (int)getplayerkeyfloat(m_slot, "frags");
	m_userDeaths = (int)getplayerkeyfloat(m_slot, "*deaths");
	m_userScore = (int)getplayerkeyfloat(m_slot, "*score");
	m_userTeam = (int)getplayerkeyfloat(m_slot, "*team");

	if (!STRING_SET(m_userAvatars)) {
		m_userAvatars = "gfx/ui/avatar_missing";
	}

	if (!STRING_SET(m_userFlag)) {
		m_userFlag = "gfx/flags16/earth";
	} else {
		m_userFlag = strcat("gfx/flags16/", m_userFlag);
	}
	
	ncLog("cached updated UserInfo from %S %S (%d)", m_userID, m_userNames, m_slot);
}
