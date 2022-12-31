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
	CHECKBOX_HOVER,
	CHECKBOX_DOWN,
	CHECKBOX_CHECKED
};

class VGUICheckbox:VGUIWidget
{
public:
	void VGUICheckbox(void);
	
	nonvirtual void SetTitle(string);
	nonvirtual int GetValue(void);
	nonvirtual void SetValue(int);

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	vector m_vecColor;
	float m_flAlpha;
	string m_strTitle;
};

void VGUICheckbox::VGUICheckbox(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
}

void
VGUICheckbox::Spawned(void)
{
	SetSize([96,18]);
}

void VGUICheckbox::SetTitle (string strName)
{
	m_strTitle = strName;
}
int VGUICheckbox::GetValue(void)
{
	if (m_iFlags & CHECKBOX_CHECKED) {
		return (1);
	} else {
		return (0);
	}
}
void VGUICheckbox::SetValue (int iValue)
{
	if (iValue == TRUE) {
		m_iFlags |= CHECKBOX_CHECKED;
	} else {
		m_iFlags -= (m_iFlags & CHECKBOX_CHECKED);
	}
}

void VGUICheckbox::Draw(void)
{
#ifndef CLASSIC_VGUI
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, m_flAlpha);

	if (m_iFlags & CHECKBOX_DOWN) {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
	}
	
	if (m_iFlags & CHECKBOX_CHECKED) {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_checked", [16,16], [1,1,1], 1.0f, 0);
	} else {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_emptybox", [16,16], [1,1,1], 1.0f, 0);
	}
#else
	if (m_iFlags & CHECKBOX_DOWN) {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
	}
	
	if (m_iFlags & CHECKBOX_CHECKED) {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_checked", [16,16], m_vecColor, 1.0f, 0);
	} else {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_emptybox", [16,16], m_vecColor, 1.0f, 0);
	}
#endif
	if (m_strTitle) {
		Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [24, 3], m_strTitle, g_fntDefault);
	}
}

bool VGUICheckbox::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				m_iFlags |= CHECKBOX_DOWN;
				ret = true;
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			if (m_iFlags & CHECKBOX_DOWN && Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				SetValue(!GetValue());
				ret = true;
			}
			m_iFlags -= (m_iFlags & CHECKBOX_DOWN);
		}
	}

	return (ret);
}
