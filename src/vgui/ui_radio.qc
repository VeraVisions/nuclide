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
	RADIO_HOVER,
	RADIO_DOWN,
	RADIO_ACTIVE
};

.void(void) tmpVGUIRadio1;

/** VGUI Widget: Radio Button

@ingroup vgui
*/
class VGUIRadio:VGUIWidget
{
public:
	void VGUIRadio(void);

	nonvirtual void SetTitle(string);
	nonvirtual int GetValue(void);
	nonvirtual void SetValue(int);
	nonvirtual void SetFunc(void(void));

	virtual void Draw(void);
	virtual bool(float, float, float, float) Input;
	virtual void Spawned(void);

private:
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecSize;
	string m_strTitle;
};

void VGUIRadio::VGUIRadio(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
}

void
VGUIRadio::Spawned(void)
{
	SetSize([96,24]);
}


void VGUIRadio::SetTitle (string strName)
{
	m_strTitle = strName;
}
int VGUIRadio::GetValue(void)
{
	if (m_iFlags & RADIO_ACTIVE) {
		return (1);
	} else {
		return (0);
	}
}
void VGUIRadio::SetValue (int iValue)
{
	if (iValue == TRUE) {
		m_iFlags |= RADIO_ACTIVE;
	} else {
		m_iFlags -= (m_iFlags & RADIO_ACTIVE);
	}
}
void VGUIRadio::SetFunc (void(void) vFunc)
{
	tmpVGUIRadio1 = vFunc;
}

void VGUIRadio::Draw(void)
{
#ifndef CLASSIC_VGUI
	VGUITheme theme = GetTheme();

	theme.DrawControlBackground(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);
	
	if (m_iFlags & RADIO_DOWN) {
		theme.DrawBorder(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_BORDER_INSET, __NULL__);
	}
	if (m_iFlags & RADIO_ACTIVE) {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_radiosel", [16,16], [1,1,1], 1.0f, 0);
	} else {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_radiounsel", [16,16], [1,1,1], 1.0f, 0);
	}

	if (m_strTitle) {
		theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + [24, 3], m_strTitle, m_vecSize, g_fntDefault);
	}
#else
	if (m_iFlags & RADIO_DOWN) {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f, 0);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f, 0);
	}
	if (m_iFlags & RADIO_ACTIVE) {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_radiosel", [16,16], m_vecColor, 1.0f, 0);
	} else {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_radiounsel", [16,16], m_vecColor, 1.0f, 0);
	}

	if (m_strTitle) {
		Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [24, 3], m_strTitle, g_fntDefault);
	}
#endif
}

bool VGUIRadio::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				m_iFlags |= RADIO_DOWN;
				ret = true;
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			if (m_iFlags & RADIO_DOWN && Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				if (tmpVGUIRadio1) {
					tmpVGUIRadio1();
				}
				SetValue(TRUE);
				ret = true;
			}
			m_iFlags -= (m_iFlags & RADIO_DOWN);
		}
	}
	return (ret);
}
