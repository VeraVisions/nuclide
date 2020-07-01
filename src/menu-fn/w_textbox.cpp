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

enumflags
{
	TEXTBOX_VISIBLE,
	TEXTBOX_HOVER,
	TEXTBOX_DOWN,
	TEXTBOX_FOCUS,
};

class CTextBox:CWidget
{
	string m_text;
	int m_length;
	int m_flags;
	virtual void(string) m_onEnter = 0;

	void(void) CTextBox;
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;

	virtual void(void(string) vFunc) SetCallOnEnter;
	virtual void(string) SetText;
	virtual void(int) SetLength;
};

void
CTextBox::CTextBox(void)
{
	m_length = 184;
}

void
CTextBox::Draw(void)
{
	if (g_focuswidget == this) {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [m_length,24], [0.5,0.5,0.5], 1.0f);
	} else {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [m_length,24], [0.25,0.25,0.25], 1.0f);
	}
	drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [m_length-6,18], [0,0,0], 1.0f);
	drawfont = font_label;

	if (m_flags & TEXTBOX_FOCUS) {
		if (rint(time*4) & 1) {
			drawstring([g_menuofs[0]+m_x+6,g_menuofs[1]+m_y+6], 
				sprintf("%s|", m_text), [12,12], col_input_text, 1.0f, 0);
			return;
		}
	}

	if (m_text) {
		drawstring([g_menuofs[0] + m_x + 6, g_menuofs[1] + m_y + 6], m_text,
					[12,12], col_input_text, 1.0f, 0);
	}
}

void
CTextBox::Input(float type, float x, float y, float devid)
{
	if (type == IE_KEYDOWN) {
		switch (x) {
		case K_MOUSE1:
			if (Util_CheckMouse(m_x,m_y,m_length,24)) {
				g_focuswidget = this;
				m_flags |= TEXTBOX_DOWN;
			}
			break;
		case K_BACKSPACE:
			if (m_flags & TEXTBOX_FOCUS) {
				m_text = substring(m_text, 0, strlen(m_text) - 1);
			}
			break;
		case K_ENTER:
			if (m_onEnter) {
				m_onEnter(m_text);
			}
			break;
		case K_ESCAPE:
			break;
		default:
			if (m_flags & TEXTBOX_FOCUS) {
				m_text = sprintf("%s%s", m_text, chr2str(y));
			}
		}
	} else if (type == IE_KEYUP) {
		if (x == K_MOUSE1) {
			if (m_flags & TEXTBOX_DOWN && Util_CheckMouse(m_x,m_y,m_length,24)) {
				m_flags |= TEXTBOX_FOCUS;
			} else {
				m_flags -= (m_flags & TEXTBOX_FOCUS);
			}
			m_flags -= (m_flags & TEXTBOX_DOWN);
		}
	}
}

void
CTextBox::SetCallOnEnter(void(string) vFunc)
{
	m_onEnter = vFunc;
}

void
CTextBox::SetText(string txt)
{
	m_text = txt;
}

void
CTextBox::SetLength(int len)
{
	m_length = len;
}
