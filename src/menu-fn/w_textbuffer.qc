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

#define TB_MAX_ENTRIES 128

class CTextBuffer:CWidget
{
	int m_size[2];
	string m_entries[TB_MAX_ENTRIES];
	virtual void(int) m_execute = 0;

	void(void) CTextBuffer;
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;

	virtual void(string) Insert;
	virtual void(string) InsertWrapped;
	virtual void(void) Clear;
	virtual void(int, int) SetSize;
};

void
CTextBuffer::CTextBuffer(void)
{
}

void
CTextBuffer::Draw(void)
{
	int visible;
	int pos[2];
	drawfill([g_menuofs[0] + m_x, g_menuofs[1] + m_y], [m_size[0], m_size[1]], 
			 [0,0,0], 1.0f);

	visible = floor(m_size[1] / 15);
	pos[0] = m_x + 2;
	pos[1] = m_y + 2 + ((visible - 1) * 15);

	for (int i = (TB_MAX_ENTRIES - 1); i > (TB_MAX_ENTRIES - visible) - 1; i--) {
		drawsetcliparea(g_menuofs[0] + m_x, g_menuofs[1] + m_y, m_size[0], m_size[1]);
		WLabel_Static(pos[0], pos[1], m_entries[i], 12, 12, [1,1,1],
					1.0f, 0, font_label);
		drawresetcliparea();
		pos[1] -= 15;
	}
}

void
CTextBuffer::Input(float type, float x, float y, float devid)
{

}

void
CTextBuffer::Insert(string m)
{
	for (int i = 0; i < TB_MAX_ENTRIES; i++) {
		if (i == TB_MAX_ENTRIES - 1) {
			m_entries[i] = m;
		} else {
			m_entries[i] = m_entries[i+1];
		}
	}
}

void
CTextBuffer::InsertWrapped(string m)
{
	int len;
	int argc;
	string tmp;
	string new;

	drawfont = Font_GetID(font_label);

	argc = tokenizebyseparator(m, " ");

	tmp = new = "";

	for (int i = 0; i < argc; i++) {
		tmp = sprintf("%s%s ", new, argv(i));

		len = stringwidth(tmp, TRUE, [12, 12]);

		if (len >= m_size[0]) {
			Insert(new);
			new = "";
		} else {
			new = tmp;
		}
	}

	Insert(new);
}

void
CTextBuffer::Clear(void)
{
	for (int i = 0; i < TB_MAX_ENTRIES; i++) {
		m_entries[i] = __NULL__;
	}
}

void
CTextBuffer::SetSize(int w, int h)
{
	m_size[0] = w;
	m_size[1] = h;
}
