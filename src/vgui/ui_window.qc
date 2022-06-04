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
	WINDOW_VISIBLE,
	WINDOW_DRAGGING,
	WINDOW_RESIZING,
	WINDOW_CANRESIZE
};

class CUIWindow:CUIWidget
{
	vector m_vecOrigin;
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecSize;
	vector m_vecMinSize;
	vector m_vecMaxSize;
	vector m_vecDragOffset;
	string m_strTitle;
	string m_strIcon;

	CUIButton m_btnClose;
	
	virtual void(void) m_vResizeCB = 0;
	virtual void(void) m_vMoveCB = 0;

	void(void) CUIWindow;
	
	virtual void(string) SetTitle;
	virtual string() GetTitle;
	
	virtual void(string) SetIcon;
	virtual string() GetIcon;
	
	virtual void(vector) SetSize;
	virtual vector() GetSize;
	
	virtual void(vector) SetMinSize;
	virtual vector() GetMinSize;
	
	virtual void(vector) SetMaxSize;
	virtual vector() GetMaxSize;
	
	
	virtual void(void(void) vFunc) CallOnResize;
	virtual void(void(void) vFunc) CallOnMove;

	virtual bool(void) Visible;
	virtual void(void) Draw;
	virtual void(void) Hide;
	virtual bool(float, float, float, float) Input;
};

void CUIWindow::CUIWindow(void)
{
	static void WindowButtonClose(void) {
		m_parent.m_iFlags -= (m_parent.m_iFlags & WINDOW_VISIBLE);
	}
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;

	m_vecMinSize = [64,64];
	m_vecMaxSize = [640,480]; // TODO: Make this the screen res

	m_strTitle = "Window";

	m_btnClose = spawn(CUIButton);
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

bool
CUIWindow::Visible(void)
{
	return (m_iFlags & WINDOW_VISIBLE) ? true : false;
}

void CUIWindow::SetTitle (string strName)
{
	m_strTitle = strName;
}
string CUIWindow::GetTitle(void)
{
	return m_strTitle;
}

void CUIWindow::SetIcon (string strName)
{
	m_strIcon = strName;
}
string CUIWindow::GetIcon(void)
{
	return m_strIcon;
}

void CUIWindow::SetSize (vector vecNewSize)
{
	m_vecSize[0] = bound(m_vecMinSize[0], vecNewSize[0], m_vecMaxSize[0]);
	m_vecSize[1] = bound(m_vecMinSize[1], vecNewSize[1], m_vecMaxSize[1]);
	m_btnClose.SetPos([m_vecSize[0] - 24, 4]);
}
vector CUIWindow::GetSize(void)
{
	return m_vecSize;
}

void CUIWindow::SetMinSize (vector vecNewSize)
{
	m_vecMinSize = vecNewSize;
}
vector CUIWindow::GetMinSize(void)
{
	return m_vecMinSize;
}

void CUIWindow::SetMaxSize (vector vecNewSize)
{
	m_vecMaxSize = vecNewSize;
}
vector CUIWindow::GetMaxSize(void)
{
	return m_vecMaxSize;
}

void CUIWindow::SetPos (vector vecNewPos)
{
	m_vecOrigin[0] = bound(0, vecNewPos[0], video_res[0] - 32);
	m_vecOrigin[1] = bound(0, vecNewPos[1], video_res[1] - 32);
}
vector CUIWindow::GetPos(void)
{
	return m_vecOrigin;
}

void CUIWindow::CallOnMove (void(void) vFunc)
{
	m_vMoveCB = vFunc;
}
void CUIWindow::CallOnResize (void(void) vFunc)
{
	m_vResizeCB = vFunc;
}

void CUIWindow::Hide(void)
{
	m_iFlags -= (m_iFlags & WINDOW_VISIBLE);
}
void CUIWindow::Show(void)
{
	m_iFlags |= WINDOW_VISIBLE;
}

void CUIWindow::Draw(void)
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

bool CUIWindow::Input (float flEVType, float flKey, float flChar, float flDevID)
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
