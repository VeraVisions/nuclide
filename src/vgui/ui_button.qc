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
	BUTTON_HOVER,
	BUTTON_DOWN,
	BUTTON_LASTACTIVE
};

/* TODO: MOVE THESE INTO VGUIButton! COMPILER NEEDS TO BE FIXED FIRST HOWEVER. */
.void(void) tmpVGUIButton1;

class VGUIButton:VGUIControl
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

	/** Sets the key to be pressed to order to simulate a click event. */
	nonvirtual void SetKeyEquivalent(string);
	/** Returns the key to be pressed in order to simulate a click event. */
	nonvirtual string GetKeyEquivalent(void);

	/** Gets the title of the button. */
	nonvirtual string GetTitle(void);

	/** Sets the function to call when the button is pressed. */
	nonvirtual void SetFunc(void(void));

	/** Sets the command to execute when the button is pressed. */
	nonvirtual void SetExec(string);

	/* overrides */
	virtual void Draw(void);
	virtual bool Input(float,float,float,float);
	virtual void Spawned(void);
private:
	vector m_vecIMGSize;
	vector m_vecColor;
	vector m_vecIconColor;
	float m_flAlpha;
	string m_strTitle;
	string m_strTitleActive;
	string m_strIcon;
	string m_strExec;
	int m_keyEquivalent;
};

void
VGUIButton::VGUIButton(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
	m_vecIconColor = [1,1,1];
	m_keyEquivalent = -1;
}

void
VGUIButton::Spawned(void)
{
	SetSize([96,24]);
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
VGUIButton::SetTitle(string strName)
{
	vector newsize = [0.0f, 0.0f, 0.0f];

	m_strTitle = strName;
	m_strTitleActive = sprintf("^3%s", m_strTitle);
	//m_strTitle = sprintf("%s%s", Font_RGBtoHex(UI_MAINCOLOR), strName);
	drawfont = g_fntDefault.iID;

	if (GetSize() == [0,0]) {
		newsize[0] = stringwidth(m_strTitle, TRUE, [g_fntDefault.iScaleX, g_fntDefault.iScaleY]) + 16;
		newsize[1] = 24;
		SetSize(newsize);
	}
}

string
VGUIButton::GetTitle(void)
{
	return m_strTitle;
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
VGUIButton::SetFunc(void(void) func)
{
	//#warning "SetFunc in VGUIButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override VGUIButton and define a OnMouseDown/Up method instead"
	//m_vFunc = vFunc;
	tmpVGUIButton1 = func;
}
void
VGUIButton::SetExec(string exe)
{
	m_strExec = exe;
}

void
VGUIButton::SetKeyEquivalent(string keyValue)
{
	m_keyEquivalent = stringtokeynum(keyValue);
}

string
VGUIButton::GetKeyEquivalent(void)
{
	return keynumtostring(m_keyEquivalent);
}


void
VGUIButton::Draw(void)
{
#ifndef CLASSIC_VGUI
	VGUITheme theme = GetTheme();

	if (m_iFlags & BUTTON_DOWN) {
		theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);
	} else {
		theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_NORMAL);
	}

	float textPadding = 8;

	if (m_keyEquivalent >= 0) {
		float length;
		string keyText = GetKeyEquivalent();

		length = Font_StringWidth(keyText, FALSE, g_fntDefault);
		textPadding += length + 8;
		theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], keyText, m_vecSize, g_fntDefault);
	}

	if (m_strTitle) {
		if (m_iFlags & BUTTON_HOVER) {
			theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + [textPadding, 8], m_strTitle, m_vecSize, g_fntDefault);
		} else {
			theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + [textPadding, 8], m_strTitle, m_vecSize, g_fntDefault);
		}
	}

	if (m_strIcon) {
		if (m_iFlags & BUTTON_DOWN)
			drawpic(m_parent.m_vecOrigin + m_vecOrigin + [2,2], m_strIcon, m_vecIMGSize, m_vecIconColor * 0.25, 1.0f, 0);
		else
			drawpic(m_parent.m_vecOrigin + m_vecOrigin + [2,2], m_strIcon, m_vecIMGSize, m_vecIconColor, 1.0f, 0);
	}

#else
	if (m_iFlags & BUTTON_HOVER) {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, 0.25f);
	}
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);


	float textPadding = 8;

	{
		vector pos = m_parent.m_vecOrigin + m_vecOrigin;
		drawsetcliparea(pos[0], pos[1], m_vecSize[0], m_vecSize[1]);
	}

	if (m_keyEquivalent >= 0) {
		float length;
		string keyText = GetKeyEquivalent();

		length = Font_StringWidth(keyText, FALSE, g_fntDefault);
		textPadding += length + 8;
		Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], keyText, g_fntDefault);
	}

	if (m_strTitle) {
		if (m_iFlags & BUTTON_LASTACTIVE) {
			Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [textPadding, 8], m_strTitleActive, g_fntDefault);
		} else {
			Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [textPadding, 8], m_strTitle, g_fntDefault);
		}
	}
	if (m_strIcon) {
		if (m_iFlags & BUTTON_DOWN)
			drawpic(m_parent.m_vecOrigin + m_vecOrigin + [2,2], m_strIcon, m_vecIMGSize, m_vecIconColor * 0.25, 1.0f, 0);
		else
			drawpic(m_parent.m_vecOrigin + m_vecOrigin + [2,2], m_strIcon, m_vecIMGSize, m_vecIconColor, 1.0f, 0);
	}

	drawresetcliparea();
#endif
}

bool
VGUIButton::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	bool mouseHover = false;

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
		mouseHover = true;
	}

	if (mouseHover == true && HasFlag(BUTTON_HOVER) == false) {
		FlagAdd(BUTTON_HOVER);
		OnMouseEntered();
	} else if (HasFlag(BUTTON_HOVER) && mouseHover == false) {
		FlagRemove(BUTTON_HOVER);
		OnMouseExited();
	}

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			FlagRemove(BUTTON_LASTACTIVE);
			if (mouseHover) {
				OnMouseDown();

				FlagAdd(BUTTON_DOWN);
				FlagAdd(BUTTON_LASTACTIVE);
				ret = true;
			}
		}
	} else if (flEVType == IE_KEYUP) {
		/* simulate click */
		if (m_keyEquivalent >= 0)
		if (flKey == m_keyEquivalent) {
			m_iFlags |= BUTTON_DOWN;
			mouseHover = true;
			flKey = K_MOUSE1;
		}

		if (flKey == K_MOUSE1) {
			if (m_iFlags & BUTTON_DOWN && mouseHover) {
				OnMouseUp();

				if (tmpVGUIButton1)
					tmpVGUIButton1();

				if (m_strExec)
					localcmd(sprintf("%s\n", m_strExec));

				ret = true;
			}
			FlagRemove(BUTTON_DOWN);
		}
	}
	return (ret);
}
