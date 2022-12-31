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
	WINDOW_CANRESIZE
};

/** Top-most window class in VGUILib */
class VGUIWindow:VGUIWidget
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

	/** Called when the window is was resized by the user. */
	nonvirtual void CallOnResize(void(void) vFunc);
	/** Called when the window has been repositioned by the user. */
	nonvirtual void CallOnMove(void(void) vFunc);

	/* overrides */
	virtual void Draw(void);
	virtual void SizeChanged(vector, vector);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecDragOffset;
	string m_strTitle;
	string m_strIcon;

	VGUIButton m_btnClose;
	
	virtual void(void) m_vResizeCB = 0;
	virtual void(void) m_vMoveCB = 0;
};

void
VGUIWindow::VGUIWindow(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
}

void
VGUIWindow::Spawned(void)
{
	static void WindowButtonClose(void) {
		m_parent.Hide();
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
	m_btnClose.SetFunc(WindowButtonClose);
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

void VGUIWindow:: SizeChanged (vector vecOld, vector vecNew)
{
	m_btnClose.SetPos([vecNew[0] - 24, 4]);
}

void VGUIWindow::CallOnMove (void(void) vFunc)
{
	m_vMoveCB = vFunc;
}
void VGUIWindow::CallOnResize (void(void) vFunc)
{
	m_vResizeCB = vFunc;
}



void VGUIWindow::Draw(void)
{
#ifdef CLASSIC_VGUI
	drawfill(m_vecOrigin, m_vecSize, [0,0,0], 0.5);
	drawfill(m_vecOrigin, [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);
	drawfill(m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], m_vecColor, 1.0f);

	if (m_iFlags & WINDOW_CANRESIZE) {
		drawpic(m_vecOrigin + m_vecSize - [16,16], "textures/ui/steam/icon_resizer", [16,16], m_vecColor, 1.0f, 0);
	}
#else
	drawfill(m_vecOrigin, m_vecSize, m_vecColor, m_flAlpha);
	drawfill(m_vecOrigin, [m_vecSize[0], 1], [1,1,1], 0.5f);
	drawfill(m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [0,0,0], 0.5f);
	drawfill(m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
	drawfill(m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);

	if (m_iFlags & WINDOW_CANRESIZE) {
		drawpic(m_vecOrigin + m_vecSize - [16,16], "textures/ui/steam/icon_resizer", [16,16], m_vecColor, 1.0f, 0);
	}
#endif

	if (m_strTitle) {
		if (m_strIcon) {
			Font_DrawText(m_vecOrigin + [26, 8], m_strTitle, g_fntDefault);
			drawpic(m_vecOrigin + [4, 4], m_strIcon, [16,16], [1,1,1], 1.0f, 0);
		} else {
			Font_DrawText(m_vecOrigin + [8, 8], m_strTitle, g_fntDefault);
		}
	}
	
#ifdef UI_DEVELOPER
	if (m_iFlags & WINDOW_DRAGGING) {
		Font_DrawText([8, video_res[1] - 18], sprintf("Window Position: %d, %d\n", m_vecOrigin[0], m_vecOrigin[1]), g_fntDefault);
	}
	if (m_iFlags & WINDOW_RESIZING) {
		Font_DrawText([8, video_res[1] - 18], sprintf("Window Size: %d, %d\n", m_vecSize[0], m_vecSize[1]), g_fntDefault);
	}
#endif
}

bool VGUIWindow::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			if (m_iFlags & WINDOW_CANRESIZE && Util_MouseAbove(g_vecMousePos, m_vecOrigin + (m_vecSize - [16,16]), [16,16])) {
				m_iFlags |= WINDOW_RESIZING;
			} else if (Util_MouseAbove(g_vecMousePos, m_vecOrigin, [m_vecSize[0] - 32, 16])) {
				m_iFlags |= WINDOW_DRAGGING;
				m_vecDragOffset = m_vecOrigin - g_vecMousePos;
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
			vector vNewScale = [flKey, flChar] - m_vecOrigin - m_vecSize;
			SetSize(GetSize() + vNewScale);
			
			if (m_vResizeCB) {
				m_vResizeCB();
			}
		}
		ret = true;
	} else if (m_iFlags & WINDOW_DRAGGING) {
		if (flEVType == IE_MOUSEABS) {
			vector vNewPos = [flKey, flChar] - m_vecOrigin;
			SetPos(GetPos() + vNewPos + m_vecDragOffset);
			
			if (m_vMoveCB) {
				m_vMoveCB();
			}
		}
		ret = true;
	}
	return (ret);
}
