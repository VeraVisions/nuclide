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
	WINDOW_DRAGGING,
	WINDOW_RESIZING,
};

typedef enumflags
{
	VGUIWindowBorderless,
	VGUIWindowTitled,
	VGUIWindowClosable,
	VGUIWindowMiniaturizable,
	VGUIWindowResizeable,
	VGUIWindowMovable,
	VGUIWindowFullscreen
} vguiWindowStyle_t;

#define VGUIWindowStyleDefault VGUIWindowMovable | \
		VGUIWindowTitled | \
		VGUIWindowClosable | \
		VGUIWindowMiniaturizable

/* TODO: MOVE THESE INTO VGUIWindow! COMPILER NEEDS TO BE FIXED FIRST HOWEVER. */
.void(void) tmpVGUIWindow1;
.void(void) tmpVGUIWindow2;

/** VGUI: Window

Top-most window class in VGUILib.

@ingroup vgui
*/
class VGUIWindow:VGUIView
{
public:
	void VGUIWindow(void);

	/** Set the title of the window widget. */
	nonvirtual void SetTitle(string);
	/** Returns the title of the window widget. */
	nonvirtual string GetTitle(void);

	/** Sets the icon of the window widget. */
	nonvirtual void SetIcon(string);
	/** Returns the icon of the window widget. */
	nonvirtual string GetIcon(void);

	/** Sets the style mask of the specified window. */
	nonvirtual void SetStyleMask(vguiWindowStyle_t);

	/** Called when the window is was resized by the user. */
	nonvirtual void CallOnResize(void(void) vFunc);
	/** Called when the window has been repositioned by the user. */
	nonvirtual void CallOnMove(void(void) vFunc);

	/** Will focus the window when called. */
	nonvirtual bool Focus(void);

	/** Called when the VGUIWindow got moved successfully. */
	virtual void WindowDidMove(vector, vector);
	/** Called when the VGUIWindow got resized successfully. */
	virtual void WindowDidResize(vector, vector);
	/** Called when the VGUIWindow was successfully closed. */
	virtual void WindowDidClose(void);

	/* overrides */
	virtual void Draw(void);
	virtual void SizeChanged(vector, vector);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);
	virtual void NowVisible();

private:
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecDragOffset;
	string m_strTitle;
	string m_strIcon;
	vguiWindowStyle_t m_styleMask;

	VGUIButton m_btnClose;
};

void
VGUIWindow::VGUIWindow(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
	m_styleMask = VGUIWindowStyleDefault;
}

void
VGUIWindow::NowVisible(void)
{
	Focus();
}

bool
VGUIWindow::Focus(void)
{
	VGUIWidget wLast = this;
	VGUIWidget wEdit = m_parent; /* start at parent */
//	error("Focusing!!!\n");

	/* iterate through the main windows, we start at the parent of all windows... */
	do {
		//print(sprintf("At %S\n", wEdit.classname));
		wLast = wEdit;
		wEdit = wEdit.m_next; /* next window of parent */

		/* skip over ourselves. */
		if (wEdit == this) {
			wEdit = this.m_next;
			wLast.m_next = this.m_next;
		//	print("Skipping over ourselves...\n");
			//print(sprintf("At %S\n", wEdit.classname));
		}

		/* if empty... mark ourselves as the last window */
		if (wEdit == __NULL__) {
			//print("Last window is us...\n");
			wLast.m_next = this;
			this.m_next = __NULL__;
		}
	} while (wEdit);

	return true;
}

void
VGUIWindow::SetStyleMask(vguiWindowStyle_t val)
{
	if (!(val & VGUIWindowClosable)) {
		m_btnClose.Hide();
	}

	m_styleMask = val;
}

void
VGUIWindow::CallOnResize(void(void) func)
{
	//#warning "SetFunc in VGUIButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override VGUIButton and define a OnMouseDown/Up method instead"
	//m_vFunc = vFunc;
	tmpVGUIWindow1 = func;
}

void
VGUIWindow::CallOnMove(void(void) func)
{
	//#warning "SetFunc in VGUIButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override VGUIButton and define a OnMouseDown/Up method instead"
	//m_vFunc = vFunc;
	tmpVGUIWindow2 = func;
}


void
VGUIWindow::Spawned(void)
{
	static void VGUIWindowButtonClose(void) {
		VGUIButton winSelf = (VGUIButton)self;
		winSelf.m_parent.Hide();
	}

	SetMinSize([64,64]);
	SetMaxSize([640,480]); // TODO: Make this the screen res

	m_strTitle = "Window";

	m_btnClose = spawn(VGUIButton);
	m_btnClose.SetTitle(__NULL__);
	m_btnClose.SetIcon("textures/ui/steam/icon_close");

#ifdef CLASSIC_VGUI
	m_btnClose.SetIconColor(m_vecColor);
#else
	m_btnClose.SetIconColor([1,1,1]);
#endif
	m_btnClose.SetColor(m_vecColor);
	m_btnClose.SetFunc(VGUIWindowButtonClose);
	m_btnClose.SetSize([20,20]);
	Add(m_btnClose);

	SetSize([320,240]);
}

void VGUIWindow::SetTitle (string strName)
{
	m_strTitle = strName;
}
string VGUIWindow::GetTitle(void)
{
	return m_strTitle;
}

void VGUIWindow::SetIcon (string strName)
{
	m_strIcon = strName;
}
string VGUIWindow::GetIcon(void)
{
	return m_strIcon;
}

void VGUIWindow::SizeChanged (vector vecOld, vector vecNew)
{
	m_btnClose.SetPos([vecNew[0] - 24, 4]);
}

void
VGUIWindow::WindowDidMove(vector oldPosition, vector newPosition)
{

}

void
VGUIWindow::WindowDidResize(vector oldSize, vector newSize)
{

}

void
VGUIWindow::WindowDidClose(void)
{

}

void VGUIWindow::Draw(void)
{
#ifdef CLASSIC_VGUI
	if (m_styleMask & VGUIWindowFullscreen)
		drawfill([0,0], g_vidsize, [0,0,0], 0.5);
	else
		drawfill(m_vecOrigin, m_vecSize, [0,0,0], 0.5);

	if (!(m_styleMask & VGUIWindowBorderless)) {
	drawfill(m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
	drawfill(m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
	}

	if (m_styleMask & VGUIWindowResizeable) {
		drawpic(m_vecOrigin + m_vecSize - [16,16], "textures/ui/steam/icon_resizer", [16,16], m_vecColor, 1.0f, 0);
	}

	if (m_styleMask & VGUIWindowTitled)
	if (m_strTitle) {
		if (m_strIcon) {
			Font_DrawText(m_vecOrigin + [26, 8], m_strTitle, g_fntDefault);
			drawpic(m_vecOrigin + [4, 4], m_strIcon, [16,16], [1,1,1], 1.0f, 0);
		} else {
			Font_DrawText(m_vecOrigin + [8, 8], m_strTitle, g_fntDefault);
		}
	}
#else
	VGUITheme theme = GetTheme();

	if (m_styleMask & VGUIWindowFullscreen)
		theme.DrawWindowBackground([0, 0], g_vidsize, VGUI_STATE_ACTIVE);
	else if  (!(m_styleMask & VGUIWindowBorderless))
		theme.DrawWindow(m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);
	else
		theme.DrawWindowBackground(m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);

	if (m_styleMask & VGUIWindowResizeable) {
		drawpic(m_vecOrigin + m_vecSize - [16,16], "textures/ui/steam/icon_resizer", [16,16], m_vecColor, 1.0f, 0);
	}

	if (m_styleMask & VGUIWindowTitled)
	if (m_strTitle) {
		if (m_strIcon) {
			theme.DrawText(m_vecOrigin + [26, 8], m_strTitle, m_vecSize, g_fntDefault);
			drawpic(m_vecOrigin + [4, 4], m_strIcon, [16,16], [1,1,1], 1.0f, 0);
		} else {
			theme.DrawText(m_vecOrigin + [8, 8], m_strTitle, m_vecSize, g_fntDefault);
		}
	}
#endif

	super::Draw();

#ifdef UI_DEVELOPER
	if (m_iFlags & WINDOW_DRAGGING) {
		Font_DrawText([8, g_vidsize[1] - 18], sprintf("Window Position: %d, %d\n", m_vecOrigin[0], m_vecOrigin[1]), g_fntDefault);
	}
	if (m_iFlags & WINDOW_RESIZING) {
		Font_DrawText([8, g_vidsize[1] - 18], sprintf("Window Size: %d, %d\n", m_vecSize[0], m_vecSize[1]), g_fntDefault);
	}
#endif
}

bool VGUIWindow::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			if (m_styleMask & VGUIWindowResizeable && Util_MouseAbove(g_vecMousePos, m_vecOrigin + (m_vecSize - [16,16]), [16,16])) {
				m_iFlags |= WINDOW_RESIZING;
				return Focus();
			} else if (m_styleMask & VGUIWindowMovable && Util_MouseAbove(g_vecMousePos, m_vecOrigin, [m_vecSize[0] - 32, 16])) {
				m_iFlags |= WINDOW_DRAGGING;
				m_vecDragOffset = m_vecOrigin - g_vecMousePos;
				return Focus();
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			m_iFlags -= (m_iFlags & WINDOW_DRAGGING);
			m_iFlags -= (m_iFlags & WINDOW_RESIZING);
		}
	}

	if (m_iFlags & WINDOW_RESIZING) {
		if (flEVType == IE_MOUSEABS) {
			vector oldSize = m_vecSize;
			vector newSize = GetSize() + ([flKey, flChar] - m_vecOrigin - m_vecSize);
			SetSize(newSize);
			WindowDidResize(oldSize, newSize);

			if (tmpVGUIWindow1)
				tmpVGUIWindow1();
		}
		ret = true;
	} else if (m_iFlags & WINDOW_DRAGGING) {
		if (flEVType == IE_MOUSEABS) {
			vector oldPos = m_vecOrigin;
			vector newPos = GetPos() + ([flKey, flChar] - m_vecOrigin) + m_vecDragOffset;
			SetPos(newPos);
			WindowDidMove(oldPos, newPos);

			if (tmpVGUIWindow2)
				tmpVGUIWindow2();
		}
		ret = true;
	}

	if (ret == false) {
		ret = super::Input(flEVType, flKey, flChar, flDevID);
	}

	return (ret);
}
