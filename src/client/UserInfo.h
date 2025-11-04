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

class
ncUserInfo
{
public:
	void ncUserInfo(void);

	nonvirtual void Update(void);

	nonvirtual string ID(void);
	nonvirtual string Name(void);
	nonvirtual string Model(void);
	nonvirtual string Avatar(void);
	nonvirtual string Banner(void);
	nonvirtual string Contact(void);
	nonvirtual string Flag(void);
	nonvirtual int Team(void);
	nonvirtual int Kills(void);
	nonvirtual int Deaths(void);
	nonvirtual int Score(void);

	nonvirtual void DebugPrint(void);

private:
	string m_userID;
	string m_userNames;
	string m_userModels;
	string m_userAvatars;
	string m_userBanner;
	string m_userContact;
	string m_userFlag;
	int m_userKills;
	int m_userTeam;
	int m_userDeaths;
	int m_userScore;
	float m_slot;
};
