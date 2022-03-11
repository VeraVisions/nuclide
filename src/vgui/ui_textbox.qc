/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
	TEXTBOX_FOCUS
};

class CUITextBox:CUIWidget
{
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecSize;
	string m_strText;
	float m_flTime;
	
	void(void) CUITextBox;
	virtual void(void) Draw;
	virtual void(vector) SetSize;
	virtual void(string) SetText;
	virtual string() GetText;
	virtual void(float, float, float, float) Input;
};

void CUITextBox::CUITextBox(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
	m_vecSize = [96,24];
	m_iFlags = BUTTON_VISIBLE;
}

void CUITextBox::SetSize (vector vecSize)
{
	m_vecSize = vecSize;
}
void CUITextBox::SetText (string strName)
{
	m_strText = strName;
}
string CUITextBox::GetText(void)
{
	return m_strText;
}

void CUITextBox::Draw(void)
{

#ifdef CLASSIC_VGUI
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
#else
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, [0,0,0], 0.25f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
#endif
	m_flTime += frametime * 2;

	// blinking cursor
	if (m_iFlags & TEXTBOX_FOCUS) {
		if (rint(m_flTime) & 1) {
			Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], sprintf("%s|", m_strText), g_fntDefault);
			return;
		}
	}
	
	if (m_strText) {
		Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], m_strText, g_fntDefault);
	}
}

void CUITextBox::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	if (flEVType == IE_KEYDOWN) {
		switch (flKey) {
		case K_MOUSE1 :
			if (Util_MouseAbove(getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				m_iFlags |= TEXTBOX_DOWN;
			}
			break;
		case K_BACKSPACE:
			if (m_iFlags & TEXTBOX_FOCUS) {
				m_strText = substring(m_strText, 0, strlen(m_strText) - 1);
			}
			break;
		case K_ENTER:
			break;
		default:
			if (m_iFlags & TEXTBOX_FOCUS) {
				if ((flChar >= 48 && flChar <= 57) || (flChar >= 65 && flChar <= 90) || (flChar >= 97 && flChar <= 122)) {
					m_strText = sprintf("%s%s", m_strText, chr2str(flChar));
				}
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			if (m_iFlags & TEXTBOX_DOWN && Util_MouseAbove(getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				m_iFlags |= TEXTBOX_FOCUS;
			} else {
				m_iFlags -= (m_iFlags & TEXTBOX_FOCUS);
			}
			m_iFlags -= (m_iFlags & TEXTBOX_DOWN);
		}
	}
}
