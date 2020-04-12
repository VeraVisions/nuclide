/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

#define LB_MAX_ENTRIES 512

class CListBox:CWidget
{
	int m_size[2];
	string m_entries[LB_MAX_ENTRIES];
	int m_count;
	int m_scroll;
	int m_selected;
	virtual void(int val) m_execute = 0;

	void(void) CListBox;
	virtual void(void) Draw;
	virtual void(float type, float x, float y, float devid) Input;

	virtual void(string m) AddEntry;
	virtual void(void) Clear;
	virtual void(int, int) SetSize;
	virtual void(void(int val) func) SetChanged;
	virtual string(int) GetItem;
	virtual void(int, string) SetItem;
	virtual void(int i) SetSelected;
	virtual string() GetSelectedItem;
	virtual int(void) GetSelected;
	virtual int(void) GetCount;
};

void CListBox::CListBox(void)
{
	m_selected = -1;
}

void CListBox::Draw(void)
{
	int visible;
	int pos[2];
	drawfill([g_menuofs[0] + m_x, g_menuofs[1] + m_y], [m_size[0], m_size[1]], 
			 [0,0,0], 1.0f);

	visible = floor(m_size[1] / 15);
	pos[0] = m_x + 2;
	pos[1] = m_y + 2;

	for (int i = m_scroll; i < (visible + m_scroll); i++) {
		if (m_selected == i) {
			drawfill([g_menuofs[0] + pos[0] - 2, g_menuofs[1] + pos[1] - 2], [m_size[0], 15], 
			 [84/255,45/255,0], 1.0f);
		}
		WLabel_Static(pos[0], pos[1], m_entries[i], 12, 12, [1,0.5,0.1],
					1.0f, 0, font_label);
		pos[1] += 15;
	}
}

void CListBox::Input(float type, float x, float y, float devid)
{
	int visible;
	int pos[2];

	visible = floor(m_size[1] / 15);
	pos[0] = m_x;
	pos[1] = m_y;

	for (int i = m_scroll; i < (visible + m_scroll); i++) {
		if (Util_CheckMouse(pos[0], pos[1], m_size[0], 15)) {
			if (type == IE_KEYDOWN) {
				if (x == K_MOUSE1) {
					SetSelected(i);
					break;
				}
			}
		}
		pos[1] += 15;
	}
}

void CListBox::AddEntry(string m)
{
	for (int i = 0; i < LB_MAX_ENTRIES; i++) {
		if (m_entries[i] == __NULL__) {
			m_entries[i] = m;
			m_count = i + 1;
			break;
		}
	}
}

void CListBox::Clear(void)
{
	for (int i = 0; i < LB_MAX_ENTRIES; i++) {
		m_entries[i] = __NULL__;
	}
}

void CListBox::SetSize(int w, int h)
{
	m_size[0] = w;
	m_size[1] = h;
}

void CListBox::SetScroll(int i)
{
	if (i >= 0 && i < LB_MAX_ENTRIES) {
		m_scroll = i;
	}
}

void CListBox::SetChanged(void(int val) func)
{
	m_execute = func;
}

void CListBox::SetSelected(int i)
{
	if (m_entries[i] == __NULL__) {
		return;
	}

	m_selected = i;

	if (m_execute) {
		m_execute(i);
	}
}

int CListBox::GetSelected(void)
{
	return m_selected;
}

string CListBox::GetItem(int i)
{
	return m_entries[i];
}

void CListBox::SetItem(int i, string s)
{
	m_entries[i] = s;
}


string CListBox::GetSelectedItem(void)
{
	if (m_selected == -1) {
		return __NULL__;
	}
	return m_entries[m_selected];
}

int CListBox::GetCount(void)
{
	return m_count;
}
