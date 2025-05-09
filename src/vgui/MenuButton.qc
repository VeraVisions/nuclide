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
	MBUTTON_SHOWOFFLINE = BUTTON_CUSTOMFLAGS,
	MBUTTON_SHOWSP,
	MBUTTON_SHOWMP,
	MBUTTON_AUTHONLY
};

.void(void) tmpvguiMenuButton1;

/** VGUI Widget: Menu Button

@ingroup vgui
*/
class
vguiMenuButton: vguiButton
{
public:
	void vguiMenuButton(void);


	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);
	virtual void Reposition(void);
	virtual void OnMouseEntered(void);
	virtual void OnMouseDown(void);
	virtual void OnMouseUp(void);


	nonvirtual void SetPosition(int);

private:
	int m_menuPosition;
};

void
vguiMenuButton::vguiMenuButton(void)
{
}

void
vguiMenuButton::OnMouseEntered(void)
{
	localsound("UI/buttonrollover.wav");
}

void
vguiMenuButton::OnMouseDown(void)
{
	localsound("UI/buttonclick.wav");
}

void
vguiMenuButton::OnMouseUp(void)
{
	localsound("UI/buttonclickrelease.wav");
}

void
vguiMenuButton::Spawned(void)
{
	super::Spawned();
	FlagAdd(MBUTTON_SHOWOFFLINE | MBUTTON_SHOWSP | MBUTTON_SHOWMP);
}

void
vguiMenuButton::Reposition(void)
{
	vector newPosition = g_vec_null;
	super::Reposition();

	if (m_iFlags & MBUTTON_AUTHONLY) {
		newPosition = [(g_vidsize[0] - (g_vidsize[0] / 16) - m_vecSize[0]), g_vidsize[1] / 2 - 64];
	} else {
		newPosition = [g_vidsize[0] / 16, g_vidsize[1] / 2 - 64];
	}

	newPosition[1] += m_menuPosition * 24;
	SetPos(newPosition);
}

void
vguiMenuButton::Draw(void)
{
	if (m_iFlags & MBUTTON_AUTHONLY) {
		if (FragNet_Status() != STATE_ONLINE) {
			return;
		}
	}

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

	vguiTheme theme = GetTheme();

	if (m_iFlags & BUTTON_DOWN) {
		//theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);
	} else if (m_iFlags & BUTTON_HOVER) {
		//theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_HOVER);
	} else {
		//theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_NORMAL);
	}

	float textPadding = 8;

	if (m_keyEquivalent >= 0) {
		float length;
		string keyText = GetKeyEquivalent();

		length = Font_StringWidth(keyText, FALSE, g_fntMenuButton);
		textPadding += length + 8;
		theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], keyText, m_vecSize, g_fntMenuButton);
	}

	if (STRING_SET(m_strIcon) && UI_NOICONS == false) {
		if (m_iFlags & BUTTON_DOWN)
			drawpic(m_parent.m_vecOrigin + m_vecOrigin + [4,4], m_strIcon, m_vecIMGSize, m_vecIconColor * 0.25, 1.0f, 0);
		else
			drawpic(m_parent.m_vecOrigin + m_vecOrigin + [4,4], m_strIcon, m_vecIMGSize, m_vecIconColor, 1.0f, 0);

		textPadding += m_vecIMGSize[0] + 4;
	}

	if (STRING_SET(m_strTitle)) {
		if (m_iFlags & BUTTON_HOVER) {
			Font_DrawText_RGB(m_parent.m_vecOrigin + m_vecOrigin + [textPadding, 8], m_strTitle, [1,1,1], g_fntMenuButton);
		} else {
			Font_DrawText_RGB(m_parent.m_vecOrigin + m_vecOrigin + [textPadding, 8], m_strTitle, [0.75,0.75,0.75], g_fntMenuButton);
		}
	}
}

bool
vguiMenuButton::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	if (m_iFlags & MBUTTON_AUTHONLY) {
		if (FragNet_Status() != STATE_ONLINE) {
			return;
		}
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

	return super::Input(flEVType, flKey, flChar, flDevID);
}

void
vguiMenuButton::SetPosition(int newPosition)
{
	m_menuPosition = newPosition;
	Reposition();
}

#endif
