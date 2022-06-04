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
	RADIO_VISIBLE,
	RADIO_HOVER,
	RADIO_DOWN,
	RADIO_ACTIVE
};

class CUIRadio:CUIWidget
{
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecSize;
	string m_strTitle;
	virtual void(void) m_vFunc = 0;
	
	void(void) CUIRadio;
	virtual void(void) Draw;
	virtual void(vector) SetSize;
	virtual void(string) SetTitle;
	virtual int(void) GetValue;
	virtual void(int) SetValue;
	virtual void(void(void)) SetFunc;
	virtual bool(float, float, float, float) Input;
};

void CUIRadio::CUIRadio(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
	m_vecSize = [96,24];
	m_iFlags = RADIO_VISIBLE;
}

void CUIRadio::SetSize (vector vecSize)
{
	m_vecSize = vecSize;
}
void CUIRadio::SetTitle (string strName)
{
	m_strTitle = strName;
}
int CUIRadio::GetValue(void)
{
	if (m_iFlags & RADIO_ACTIVE) {
		return (1);
	} else {
		return (0);
	}
}
void CUIRadio::SetValue (int iValue)
{
	if (iValue == TRUE) {
		m_iFlags |= RADIO_ACTIVE;
	} else {
		m_iFlags -= (m_iFlags & RADIO_ACTIVE);
	}
}
void CUIRadio::SetFunc (void(void) vFunc)
{
	m_vFunc = vFunc;
}

void CUIRadio::Draw(void)
{
#ifndef CLASSIC_VGUI
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, m_flAlpha);
	
	if (m_iFlags & RADIO_DOWN) {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
	}
	if (m_iFlags & RADIO_ACTIVE) {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_radiosel", [16,16], [1,1,1], 1.0f, 0);
	} else {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "textures/ui/steam/icon_radiounsel", [16,16], [1,1,1], 1.0f, 0);
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
#endif

	if (m_strTitle) {
		Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [24, 3], m_strTitle, g_fntDefault);
	}
}

bool CUIRadio::Input (float flEVType, float flKey, float flChar, float flDevID)
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
				if (m_vFunc) {
					m_vFunc();
				}
				SetValue(TRUE);
				ret = true;
			}
			m_iFlags -= (m_iFlags & RADIO_DOWN);
		}
	}
	return (ret);
}
