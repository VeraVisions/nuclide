/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

class CCheckBox:CWidget
{
	int m_value;
	int m_hover;
	int m_click;
	virtual void(float value) m_changed = 0;

	virtual void() Draw;
	virtual void(float type, float x, float y, float devid) Input;
	virtual void(void(float val) vFunc) SetCallback;
	virtual void(float val) SetValue;
};

void CCheckBox::Draw(void)
{
	if (m_click) {
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[CB_DOWN],
			[19,19], [1,1,1], 1.0f, 0);
	} else {
		if (m_value) {
			drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[CB_CHECKED],
				[19,19], [1,1,1], 1.0f);
		} else {
			drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[CB_EMPTY],
				[19,19], [1,1,1], 1.0f);
		}
	}

	if (m_hover) {
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[CB_OVER],
			[19,19], [1,1,1], 1.0f, 1);
	}
}
void CCheckBox::Input(float type, float x, float y, float devid)
{
	if (Util_CheckMouse(m_x, m_y, 19, 19) == TRUE) {
		m_hover = TRUE;
	} else {
		m_hover = FALSE;
	}

	if (m_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_click = TRUE;
	}

	if (type == IE_KEYUP && x == K_MOUSE1) {
		if (m_click) {
			m_click = FALSE;
			m_value = TRUE - m_value;
			if (m_changed) {
				m_changed(m_value);
			}
		}
	}
}
void CCheckBox::SetCallback(void(float val) vFunc)
{
	m_changed = vFunc;
}

void CCheckBox::SetValue(float val)
{
	m_value = (int)val;
}
