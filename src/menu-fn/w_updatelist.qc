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

#ifndef WEBMENU
class CUpdateList:CWidget
{
	int m_size[2];
	int m_max;
	int m_scroll;
	int m_selected;
	virtual void(void) m_changed = 0;
	virtual void(void) m_dclicked = 0;

	void(void) CUpdateList;
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;

	virtual void(int, int) SetSize;
	virtual void(void(void)) SetChanged;
	virtual void(void(void)) SetDClicked;
	virtual void(int) SetSelected;
	virtual int(void) GetSelected;
	virtual void SetScroll(int);
	virtual void SetMax(int);
};

void
CUpdateList::CUpdateList(void)
{
	m_selected = -1;
}

void
CUpdateList::Draw(void)
{
	int visible;
	int pos;
	drawfill([g_menuofs[0] + m_x, g_menuofs[1] + m_y], [m_size[0], m_size[1]], 
			 [0,0,0], 1.0f);

	visible = floor(m_size[1] / 18);

	if (visible > m_max)
		visible = m_max;

	pos = m_y;

	for (int i = m_scroll; i < (visible + m_scroll); i++) {
		vector colo;
		string updateTitle = Updates_GetInfo(i, UPDATE_TITLE);
		updateState_t updateState = Updates_GetInfo(i, UPDATE_STATE);
		updateAction_t updateAction = Updates_GetInfo(i, UPDATE_ACTION);

		if (m_selected == i) {
			colo = ML_COL_2;
			drawfill([g_menuofs[0] + m_x, g_menuofs[1] + pos], [m_size[0], 18], 
					 [84/255,45/255,0], 1.0f);
		} else {
			colo = ML_COL_1;
		}


		switch (updateState) {
		case UPDATESTATE_ENABLED:
			colo = ML_COL_1;
			break;
		case UPDATESTATE_CORRUPT:
			colo = [1, 0, 0];	/* red */
			break;
		case UPDATESTATE_PENDING:
			float p = Updates_GetInfo(i, UPDATE_DLPERCENTAGE) / 100;
			colo = [0,1,0] * p;
			drawfill([g_menuofs[0] + m_x, g_menuofs[1] + pos], [m_size[0] * p, 18], 
				colo, 0.5f);

			colo = [0.25,0.25,0.25] + ([0.75,0.75,0.75] * p);
			break;
		case UPDATESTATE_DISABLED:
		case UPDATESTATE_NONE:
			colo = [0.5, 0.5, 0.5]; /* grey */
		default:
			break;
		}

		if ((time*2) & 1) {
			switch (updateAction) {
			case UPDATEACTION_INSTALL:	/* blinking orange */
				colo = [1,1,0];
				break;
			case UPDATEACTION_REINSTALL:
				colo = [0,1,0];
				break;
			case UPDATEACTION_UNINSTALL:	/* blinking red */
				colo = [1,0,0];
				break;
			case UPDATEACTION_AUTOINSTALL:	/* blinking orange/grey */
				colo = [0.5,0.5,0];
				break;
			case UPDATEACTION_DISABLE:		/* blinking grey/color */
				colo = [0.5,0.5,0.5];
				break;
			case UPDATEACTION_RETAIN:
			case UPDATEACTION_NONE:
			default:
				break;
			}
		}

		/* Game */
		WLabel_Static(m_x + 3, pos + 3, updateTitle, 11, 11, colo,
					1.0f, 0, font_arial);

		pos += 18;
	}
}

void
CUpdateList::Input(float type, float x, float y, float devid)
{
	int visible;
	int pos[2];
	static float clicktime;

	visible = floor(m_size[1] / 18);

	if (visible > m_max)
		visible = m_max;

	pos[0] = m_x;
	pos[1] = m_y;

	for (int i = m_scroll; i < (visible + m_scroll); i++) {
		if (Util_CheckMouse(pos[0], pos[1], m_size[0], 18)) {
			if (type == IE_KEYDOWN) {
				if (x == K_MOUSE1) {
					if (m_selected != i) {
						SetSelected(i);
						clicktime = time + 0.5f;
					} else {
						if (time < clicktime) {
							dprint("double click!\n");
							if (m_dclicked) {
								m_dclicked();
							}
						} else {
							clicktime = time + 0.5f;
						}
					}
					break;
				}
			}
		}
		pos[1] += 18;
	}
}

void
CUpdateList::SetSize(int w, int h)
{
	m_size[0] = w;
	m_size[1] = h;
}

void
CUpdateList::SetScroll(int i)
{
	m_scroll = i;
}

void
CUpdateList::SetChanged(void(void) func)
{
	m_changed = func;
}


void
CUpdateList::SetDClicked(void(void) func)
{
	m_dclicked = func;
}

void
CUpdateList::SetSelected(int i)
{
	m_selected = i;

	if (m_changed) {
		m_changed();
	}
}

void
CUpdateList::SetMax(int i)
{
	m_max = i;
}

int
CUpdateList::GetSelected(void)
{
	return m_selected;
}

/*string
CUpdateList::GetSelectedItem(void)
{
	if (m_selected == -1) {
		return (__NULL__);
	}
	return m_entries[m_selected];
}*/
#endif
