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

/* Those seem to be hardcoded? None of the default colors match */
#define ML_COL_1 [255,127,24] / 255 // Unselected Main
#define ML_COL_2 [255,200,24] / 255 // Selected Main
#define ML_COL_3 [240,180,20] / 255 // Other
#define ML_COL_4 [200,200,200] / 255 // Grey Info

#ifndef GAME_DIR
#define GAME_DIR "base" // THE game dir ignored in the mod menu.
#endif

class CModList:CWidget
{
	int m_size[2];

	int m_scroll;
	int m_selected;
	virtual void(void) m_changed = 0;

	void(void) CModList;
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;

	virtual void(int, int) SetSize;
	//virtual void(void(int)) SetChanged;
	virtual void(int) SetSelected;
	virtual int(void) GetSelected;
	virtual void SetScroll(int);
	virtual void SetChanged(void(void));
};

void
CModList::CModList(void)
{
	m_selected = -1;
}

void
CModList::Draw(void)
{
	int visible;
	int pos;
	string gameType;
	string gameTitle;
	string gameURL;
	int gameSize;
	string gameVersion;
	bool gameInstalled;

	drawfill([g_menuofs[0] + m_x, g_menuofs[1] + m_y], [m_size[0], m_size[1]], 
			 [0,0,0], 1.0f);

	visible = floor(m_size[1] / 29);
	visible = bound(0, visible, GameLibrary_GetGameCount() - 1);
	pos = m_y;

	for (int i = m_scroll; i <= (visible + m_scroll); i++) {
		vector colo;
		gameType = GameLibrary_GetGameInfo(i, GAMEINFO_TYPE);
		gameTitle = GameLibrary_GetGameInfo(i, GAMEINFO_NAME);
		gameURL = GameLibrary_GetGameInfo(i, GAMEINFO_WEBSITE);
		gameSize = GameLibrary_GetGameInfo(i, GAMEINFO_SIZE);
		gameVersion = GameLibrary_GetGameInfo(i, GAMEINFO_VERSION);
		gameInstalled = GameLibrary_GetGameInfo(i, GAMEINFO_INSTALLED);

		if (m_selected == i) {
			colo = ML_COL_2;
			drawfill([g_menuofs[0] + m_x, g_menuofs[1] + pos], [m_size[0], 29], 
					 [84/255,45/255,0], 1.0f);
		} else {
			colo = ML_COL_1;
		}

		if (gameType!= "") {
			drawsetcliparea(g_menuofs[0] + m_x + 2, g_menuofs[1] + pos + 3, 50,30);
			WLabel_Static(m_x + 2, pos + 3, gameType,
						  11, 11, colo, 1.0f, 0, font_arial);
			drawresetcliparea();
		}

		/* Game */
		drawsetcliparea(g_menuofs[0] + m_x + 57, g_menuofs[1] + pos + 3, 112,30);
		WLabel_Static(m_x + 57, pos + 3, gameTitle, 11, 11, colo,
					1.0f, 0, font_arial);
		drawresetcliparea();
		/* URL */
		WLabel_Static(m_x + 2, pos + 18, sprintf("Info: %s", gameURL), 11, 11, ML_COL_4,
					1.0f, 0, font_arial);
		/* Version */
		WLabel_Static(m_x + 177, pos + 3, gameVersion, 11, 11, colo,
					1.0f, 0, font_arial);
		/* Size */
		float size = gameSize / 1024000;
		WLabel_Static(m_x + 227, pos + 3, sprintf("%.1fmb", size), 11, 11, colo,
					1.0f, 0, font_arial);
		/* Rating */
		WLabel_Static(m_x + 277, pos + 3, "0.0", 11, 11, colo,
					1.0f, 0, font_arial);

		if (gameInstalled == true) {
			/* Installed */
			WLabel_Static(m_x + 327, pos + 3, "Yes", 11, 11, ML_COL_3,
						1.0f, 0, font_arial);
			/* Servers */
			WLabel_Static(m_x + 377, pos + 3, "0", 11, 11, ML_COL_3,
						1.0f, 0, font_arial);
			/* Players */
			WLabel_Static(m_x + 427, pos + 3, "0", 11, 11, ML_COL_3,
						1.0f, 0, font_arial);
		} else {
			/* Installed */
			WLabel_Static(m_x + 327, pos + 3, "No", 11, 11, ML_COL_4,
						1.0f, 0, font_arial);
			/* Servers */
			WLabel_Static(m_x + 377, pos + 3, "0", 11, 11, ML_COL_4,
						1.0f, 0, font_arial);
			/* Players */
			WLabel_Static(m_x + 427, pos + 3, "0", 11, 11, ML_COL_4,
						1.0f, 0, font_arial);
		}

		pos += 29;
	}
}

void
CModList::Input(float type, float x, float y, float devid)
{
	int visible;
	int pos[2];

	visible = floor(m_size[1] / 29);
	visible = bound(0, visible, GameLibrary_GetGameCount() - 1);

	pos[0] = m_x;
	pos[1] = m_y;

	for (int i = m_scroll; i <= (visible + m_scroll); i++) {
		if (Util_CheckMouse(pos[0], pos[1], m_size[0], 29)) {
			if (type == IE_KEYDOWN) {
				if (x == K_MOUSE1) {
					SetSelected(i);
					break;
				}
			}
		}
		pos[1] += 29;
	}
}

void
CModList::SetSize(int w, int h)
{
	m_size[0] = w;
	m_size[1] = h;
}

void
CModList::SetScroll(int i)
{
	m_scroll = i;
}

void
CModList::SetChanged(void(void) func)
{
	m_changed = func;
}

void
CModList::SetSelected(int i)
{
	m_selected = i;

	if (m_changed) {
		m_changed();
	}
}

int
CModList::GetSelected(void)
{
	return m_selected;
}

/*string CModList::GetSelectedItem(void)
{
	if (m_selected == -1) {
		return (__NULL__);
	}
	return m_entries[m_selected];
}*/
