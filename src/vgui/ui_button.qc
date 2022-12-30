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
	BUTTON_VISIBLE,
	BUTTON_HOVER,
	BUTTON_DOWN,
	BUTTON_LASTACTIVE
};

class VGUIButton:VGUIWidget
{
public:
	void VGUIButton(void);

	/** Sets the title of the button. */
	nonvirtual void SetTitle(string);
	/** Sets the icon of the button. */
	nonvirtual void SetIcon(string);
	/** Sets the color of the button text. */
	nonvirtual void SetColor(vector);
	/** Sets the color of the icon on the button. */
	nonvirtual void SetIconColor(vector);
	/** Sets the function to call when the button is pressed. */
	nonvirtual void SetFunc(void(void));
	/** Sets the command to execute when the button is pressed. */
	nonvirtual void SetExec(string);

	/* overrides */
	virtual void Draw(void);
	virtual bool Input(float,float,float,float);

private:
	vector m_vecIMGSize;
	vector m_vecColor;
	vector m_vecIconColor;
	float m_flAlpha;
	string m_strTitle;
	string m_strTitleActive;
	string m_strIcon;
	string m_strExec;
	virtual void m_vFunc(void) = 0;
};

void
VGUIButton::VGUIButton(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
	m_vecSize = [96,24];
	m_vecIconColor = [1,1,1];
	m_iFlags = BUTTON_VISIBLE;
}

void
VGUIButton::SetColor(vector vecColor)
{
	m_vecColor = vecColor;
}

void
VGUIButton::SetIconColor(vector vecColor)
{
	m_vecIconColor = vecColor;
};

void
VGUIButton::SetSize(vector vecSize)
{
	m_vecSize = vecSize;
}

void
VGUIButton::SetTitle(string strName)
{
	vector newsize = [0.0f, 0.0f, 0.0f];

	m_strTitle = strName;
	m_strTitleActive = sprintf("^3%s", m_strTitle);
	drawfont = g_fntDefault.iID;

	newsize[0] = stringwidth(m_strTitle, TRUE, [g_fntDefault.iScaleX, g_fntDefault.iScaleY]) + 16;
	newsize[1] = 24;
	SetSize(newsize);
}
void
VGUIButton::SetIcon(string strName)
{
	m_strIcon = strName;
	m_vecIMGSize = drawgetimagesize(strName);

	if (vlen(GetSize()) < vlen(m_vecIMGSize)) {
		SetSize(m_vecIMGSize + [4,4]);
	}
}
void
VGUIButton::SetFunc(void(void) vFunc)
{
	m_vFunc = vFunc;
}
void
VGUIButton::SetExec(string exe)
{
	m_strExec = exe;
}

void
VGUIButton::Draw(void)
{
	if (!Visible())
		return;

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

	if (m_strTitle) {
		if (m_iFlags & BUTTON_LASTACTIVE) {
			Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], m_strTitleActive, g_fntDefault);
		} else {
			Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], m_strTitle, g_fntDefault);
		}
	}
	if (m_strIcon) {
		if (m_iFlags & BUTTON_DOWN)
			drawpic(m_parent.m_vecOrigin + m_vecOrigin + [2,2], m_strIcon, m_vecIMGSize, m_vecIconColor * 0.25, 1.0f, 0);
		else
			drawpic(m_parent.m_vecOrigin + m_vecOrigin + [2,2], m_strIcon, m_vecIMGSize, m_vecIconColor, 1.0f, 0);
	}
}

bool
VGUIButton::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	if (!Visible())
		return false;

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			FlagRemove(BUTTON_LASTACTIVE);
			if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				FlagAdd(BUTTON_DOWN);
				FlagAdd(BUTTON_LASTACTIVE);
				ret = true;
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			if (m_iFlags & BUTTON_DOWN && Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				if (m_vFunc)
					m_vFunc();
				if (m_strExec)
					localcmd(sprintf("%s\n", m_strExec));

				ret = true;
			}
			FlagRemove(BUTTON_DOWN);
		}
	}
	return (ret);
}
