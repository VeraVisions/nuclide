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

#ifdef MENU
enumflags
{
	MBUTTON_VISIBLE,
	MBUTTON_HOVER,
	MBUTTON_DOWN,
	MBUTTON_SHOWOFFLINE,
	MBUTTON_SHOWSP,
	MBUTTON_SHOWMP
};

.void(void) tmpVGUIMenuButton1;

/** VGUI Widget: Menu Button

@ingroup vgui
*/
class
VGUIMenuButton:VGUIWidget
{
public:
	void VGUIMenuButton(void);

	nonvirtual void SetTitle(string);
	nonvirtual void SetIcon(string);
	nonvirtual void SetFunc(void(void));

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	vector m_vecColor;
	float m_flAlpha;
	string m_strTitle;
	string m_strIcon;
};

void
VGUIMenuButton::VGUIMenuButton(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
}

void
VGUIMenuButton::Spawned(void)
{
	SetSize([96,24]);
	FlagAdd(MBUTTON_VISIBLE | MBUTTON_SHOWOFFLINE | MBUTTON_SHOWSP | MBUTTON_SHOWMP);
}

void
VGUIMenuButton::Draw(void)
{
	// If we're not ingame
	if (clientstate() == 2 && !g_background) {
		if (!(m_iFlags & MBUTTON_SHOWSP)) {
			return;
		}
	} else {
		if (!(m_iFlags & MBUTTON_SHOWOFFLINE)) {
			return;
		}
	}

#ifndef CLASSIC_VGUI
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, m_flAlpha);

	if (m_iFlags & BUTTON_DOWN) {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
	} else {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [1,1,1], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
	}
#else
	if (m_iFlags & BUTTON_DOWN) {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, 0.25f);
	}
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
#endif

	
	if (m_strIcon) {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin + [4, 4], m_strIcon, [16,16], [1,1,1], 1.0f);
		if (m_strTitle) {
			Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [26, 8], m_strTitle, g_fntDefault);
		}
	} else {
		if (m_strTitle) {
			Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], m_strTitle, g_fntDefault);
		}
	}
}

bool
VGUIMenuButton::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;
	bool mouseHover = false;

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
		mouseHover = true;
	}

	if (mouseHover == true && HasFlag(BUTTON_HOVER) == false) {
		FlagAdd(MBUTTON_HOVER);
	//	OnMouseEntered();
	} else if (HasFlag(BUTTON_HOVER) && mouseHover == false) {
		FlagRemove(MBUTTON_HOVER);
	//	OnMouseExited();
	}


	// If we're not ingame
	if (clientstate() == 2 && !g_background) {
		if (!(m_iFlags & MBUTTON_SHOWSP)) {
			return false;
		}
	} else {
		if (!(m_iFlags & MBUTTON_SHOWOFFLINE)) {
			return false;
		}
	}

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			if (mouseHover == true) {
				m_iFlags |= MBUTTON_DOWN;
				ret = true;
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			if (m_iFlags & MBUTTON_DOWN && mouseHover == true) {
				if (tmpVGUIMenuButton1) {
					tmpVGUIMenuButton1();
				}
				ret = true;
			}
			m_iFlags -= (m_iFlags & MBUTTON_DOWN);
		}
	}
	return (ret);
}

void
VGUIMenuButton::SetTitle (string strName)
{
	m_strTitle = strName;
}

void
VGUIMenuButton::SetIcon (string strName)
{
	m_strIcon = strName;
}

void
VGUIMenuButton::SetFunc (void(void) vFunc)
{
	tmpVGUIMenuButton1 = vFunc;
}
#endif
