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

enumflags
{
	COMBOBOX_VISIBLE,
	COMBOBOX_DOWN,
	COMBOBOX_FOCUS
};

class CComboBox:CWidget
{
	CListBox m_list;
	CScrollbar m_scrollbar;
	int m_flags;
	int m_length;

	void(void) CComboBox;

	virtual void(void) Draw;
	virtual bool(void) IsOpen;
	virtual void(float, float, float, float) Input;
	virtual string(void) GetText;

	virtual void(string) AddEntry;
	virtual void(string) AddWrapped;
	virtual void(int) DelEntry;
	virtual void(void) Clear;
	virtual void(int) ListChanged;
};

void
CComboBox::AddEntry(string entry)
{
	m_list.AddEntry(entry);
}

void
CComboBox::AddWrapped(string entry)
{
	m_list.AddWrapped(entry);
}

void
CComboBox::DelEntry(int id)
{
	m_list.DelEntry(id);
}

void
CComboBox::Clear(void)
{
	m_list.Clear();
}

string
CComboBox::GetText(void)
{
	if (m_list.m_selected >= 0)
		return m_list.m_entries[m_list.m_selected];

	return "";
}

bool
CComboBox::IsOpen(void)
{
	return m_flags & COMBOBOX_DOWN ? true : false;
}

void
CComboBox::Draw(void)
{
	if (g_focuswidget == this) {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [m_length,24], [0.5,0.5,0.5], 1.0f);
	} else {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [m_length,24], [0.25,0.25,0.25], 1.0f);
	}
	drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [m_length-6,18], [0,0,0], 1.0f);
	drawfont = Font_GetID(font_label);

	drawstring([g_menuofs[0] + m_x + 6, g_menuofs[1] + m_y + 6], GetText(),
					[12,12], col_input_text, 1.0f, 0);

	if (m_flags & COMBOBOX_FOCUS) {
		m_list.m_x = m_x;
		m_list.m_y = m_y + 24;
		
		m_list.m_size[0] = m_length - 16;
		m_list.m_size[1] = 256;

		m_scrollbar.m_x = m_x + (m_length - 16);
		m_scrollbar.m_y = m_y + 24;
		m_scrollbar.SetHeight(256);
		m_scrollbar.SetMax(m_list.m_count);

		
		m_list.m_scroll = (m_scrollbar.m_scroll);

		m_list.Draw();
		m_scrollbar.Draw();
	}
}

void
CComboBox::ListChanged(int val)
{
}

void
CComboBox::Input(float type, float x, float y, float devid)
{
	int height = 24;

	if (m_flags & COMBOBOX_FOCUS)
		height = m_scrollbar.m_height;

	if (type == IE_KEYDOWN) {
		switch (x) {
		case K_MOUSE1:
			if (Util_CheckMouse(m_x,m_y,m_length,height)) {
				g_focuswidget = this;
				m_flags |= COMBOBOX_DOWN;
			}
			break;
		}
	} else if (type == IE_KEYUP) {
		if (x == K_MOUSE1) {
			if (m_flags & COMBOBOX_DOWN && Util_CheckMouse(m_x,m_y,m_length,height)) {
				m_flags |= COMBOBOX_FOCUS;
			} else {
				m_flags -= (m_flags & COMBOBOX_FOCUS);
			}
			m_flags -= (m_flags & COMBOBOX_DOWN);
		}
	}

	if (m_flags & COMBOBOX_FOCUS) {
		m_list.Input(type, x, y, devid);
		m_scrollbar.Input(type, x, y, devid);
	}
}

void
CComboBox::CComboBox(void)
{
	m_length = 184;
	m_list = spawn(CListBox);
	m_scrollbar  = spawn(CScrollbar);
	m_scrollbar.SetCallback(this.ListChanged);
}
