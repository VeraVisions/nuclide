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
	TEXTBOX_HOVER,
	TEXTBOX_DOWN,
	TEXTBOX_FOCUS
};

class VGUITextBox:VGUIWidget
{
public:
	void VGUITextBox(void);

	/** Set the starting text of the textbox. */
	nonvirtual void SetText(string);
	/** Get the text inside the textbox. */
	nonvirtual string GetText(void);

	/* overrides */
	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	vector m_vecColor;
	float m_flAlpha;
	string m_strText;
	float m_flTime;
};

void VGUITextBox::VGUITextBox(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
}

void VGUITextBox:: Spawned(void)
{
	SetSize([96,24]);
}

void VGUITextBox::SetText (string strName)
{
	m_strText = strName;
}
string VGUITextBox::GetText(void)
{
	return m_strText;
}

void VGUITextBox::Draw(void)
{

#ifdef CLASSIC_VGUI
	VGUITheme theme = GetTheme();

	theme. DrawTextBackground(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_NORMAL);
#else
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, [0,0,0], 0.25f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
#endif
	m_flTime += frametime * 2;

	/* these are to deal with text going off-screen */
	float len = Font_StringWidth(m_strText, TRUE, g_fntDefault);
	float ofs = bound(0, len - (m_vecSize[0] - 16), len);

	// blinking cursor
	if (m_iFlags & TEXTBOX_FOCUS) {
		if (rint(m_flTime) & 1) {
			drawsetcliparea(m_parent.m_vecOrigin[0] + m_vecOrigin[0], m_parent.m_vecOrigin[1] + m_vecOrigin[1], m_vecSize[0], m_vecSize[1]);
			Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8 - ofs, 8], sprintf("%s|", m_strText), g_fntDefault);
			drawresetcliparea();
			return;
		}
	}
	
	if (m_strText) {
			drawsetcliparea(m_parent.m_vecOrigin[0] + m_vecOrigin[0], m_parent.m_vecOrigin[1] + m_vecOrigin[1], m_vecSize[0], m_vecSize[1]);
		Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8 - ofs, 8], m_strText, g_fntDefault);
		drawresetcliparea();
	}
}

bool VGUITextBox::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	switch (flKey) {
	case K_MOUSE1 :
		if (flEVType == IE_KEYDOWN) {
			if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				m_iFlags |= TEXTBOX_DOWN;
				ret = true;
			}
		} else {
			if (m_iFlags & TEXTBOX_DOWN && Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				m_iFlags |= TEXTBOX_FOCUS;
				ret = true;
			} else {
				m_iFlags -= (m_iFlags & TEXTBOX_FOCUS);
			}
			m_iFlags -= (m_iFlags & TEXTBOX_DOWN);
		}
		break;
	case K_BACKSPACE:
			if (flEVType == IE_KEYDOWN)
				if (m_iFlags & TEXTBOX_FOCUS)
					m_strText = substring(m_strText, 0, strlen(m_strText) - 1);
		break;
	case K_ENTER:
		break;
	default:
		if (m_iFlags & TEXTBOX_DOWN)
			ret = true;
		else if (m_iFlags & TEXTBOX_FOCUS) {
			if ((flChar >= 32 && flChar <= 125)) {
				if (flEVType == IE_KEYDOWN)
					m_strText = sprintf("%s%s", m_strText, chr2str(flChar));
				ret = true;
			}
			if ((flKey >= 32 && flKey <= 125)) {
				ret = true;
			}
		}
	}

	return (ret);
}
