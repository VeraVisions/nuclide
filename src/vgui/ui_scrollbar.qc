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
	SCROLLBAR_UP_DOWN,
	SCROLLBAR_DN_DOWN,
	SCROLLBAR_SLIDER_DOWN
};

.void(void) tmpVGUIScrollbar1;

/** VGUI Widget: Scrollbar

@ingroup vgui
*/
class VGUIScrollbar:VGUIWidget
{
public:
	void VGUIScrollbar(void);

	/** Sets the ??? */
	nonvirtual void SetLength(int);
	nonvirtual int GetLength(void);
	nonvirtual void SetMin(float);
	nonvirtual float GetMin(void);
	nonvirtual void SetMax(float);
	nonvirtual float GetMax(void);
	nonvirtual void SetStep(float);
	nonvirtual float GetStep(void);
	nonvirtual void SetValue(float,int);
	nonvirtual float GetValue(void);
	nonvirtual void CallOnChange(void(void));

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);

private:
	vector m_vecColor;
	float m_flAlpha;
	
	int m_iLength;
	
	float m_flMin;
	float m_flMax;
	float m_flStep;
	float m_flValue;
};

void VGUIScrollbar::VGUIScrollbar(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
}

void VGUIScrollbar::Draw(void)
{
	vector vecSize = [20, m_iLength];
	vector vecUpPos = m_parent.m_vecOrigin + m_vecOrigin;
	vector vecDownPos = m_parent.m_vecOrigin + m_vecOrigin + [0, m_iLength - 20];
	vector vecSliderPos = m_parent.m_vecOrigin + m_vecOrigin + [0, 20];

#ifndef CLASSIC_VGUI
	VGUITheme theme = GetTheme();
	
	vecSliderPos[1] += (m_iLength - 60) * (m_flValue / m_flMax);

	if (m_iFlags & BUTTON_DOWN) {
		theme.DrawScrollbar(m_parent.m_vecOrigin + m_vecOrigin, vecSize, VGUI_STATE_ACTIVE);
	} else {
		theme.DrawScrollbar(m_parent.m_vecOrigin + m_vecOrigin, vecSize, VGUI_STATE_NORMAL);
	}

	// Slider Button
	if (m_iFlags & SCROLLBAR_SLIDER_DOWN) {
		theme.DrawScroller(vecSliderPos, [20,20], VGUI_STATE_ACTIVE);
	} else {
		theme.DrawScroller(vecSliderPos, [20,20], VGUI_STATE_NORMAL);
	}

	// Button UP
	if (m_iFlags & SCROLLBAR_UP_DOWN) {
		theme.DrawButton(vecUpPos, [20,20], VGUI_STATE_ACTIVE);
	} else {
		theme.DrawButton(vecUpPos, [20,20], VGUI_STATE_NORMAL);
	}
	drawpic(vecUpPos + [2,2], "textures/ui/steam/icon_up", [16,16], [1,1,1], 1.0f, 0);

	if (m_iFlags & SCROLLBAR_DN_DOWN) {
		theme.DrawButton(vecDownPos, [20,20], VGUI_STATE_ACTIVE);
	} else {
		theme.DrawButton(vecDownPos, [20,20], VGUI_STATE_NORMAL);
	}
	drawpic(vecDownPos + [2,2], "textures/ui/steam/icon_down", [16,16], [1,1,1], 1.0f, 0);

#else
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, vecSize[1] - 1], [vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [vecSize[0], 1], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, vecSize[1] - 2], m_vecColor, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [vecSize[0] - 1, 1], [1, vecSize[1] - 2], m_vecColor, 1.0f);

	if (m_iFlags & SCROLLBAR_UP_DOWN) {
		drawfill(vecUpPos, [20,20], m_vecColor, 0.25f);
		drawfill(vecUpPos, [20, 1], m_vecColor, 1.0f);
		drawfill(vecUpPos + [0, 19], [20, 1], m_vecColor, 1.0f);
		drawfill(vecUpPos + [0, 1], [1, 18], m_vecColor, 1.0f);
		drawfill(vecUpPos + [19, 1], [1, 18], m_vecColor, 1.0f);
	} else {
		drawfill(vecUpPos, [20, 1], [1,1,1], 0.5f);
		drawfill(vecUpPos + [0, 19], [20, 1], m_vecColor, 1.0f);
		drawfill(vecUpPos + [0, 1], [1, 18], m_vecColor, 1.0f);
		drawfill(vecUpPos + [19, 1], [1, 18], m_vecColor, 1.0f);
	}
	drawpic(vecUpPos + [2,2], "textures/ui/steam/icon_up", [16,16], m_vecColor, 1.0f, 0);

	// Button DOWN
	if (m_iFlags & SCROLLBAR_DN_DOWN) {
		drawfill(vecDownPos, [20,20], m_vecColor, 0.25f);
		drawfill(vecDownPos, [20, 1], m_vecColor, 1.0f);
		drawfill(vecDownPos + [0, 19], [20, 1], m_vecColor, 1.0f);
		drawfill(vecDownPos + [0, 1], [1, 18], m_vecColor, 1.0f);
		drawfill(vecDownPos + [19, 1], [1, 18], m_vecColor, 1.0f);
	} else {
		drawfill(vecDownPos, [20, 1], m_vecColor, 1.0f);
		drawfill(vecDownPos+ [0, 19], [20, 1], m_vecColor, 1.0f);
		drawfill(vecDownPos + [0, 1], [1, 18], m_vecColor, 1.0f);
		drawfill(vecDownPos + [19, 1], [1, 18], m_vecColor, 1.0f);
	}
	drawpic(vecDownPos + [2,2], "textures/ui/steam/icon_down", [16,16], m_vecColor, 1.0f, 0);
#endif
}

bool VGUIScrollbar::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;
	vector vecUpPos = m_parent.m_vecOrigin + m_vecOrigin;
	vector vecDownPos = m_parent.m_vecOrigin + m_vecOrigin + [0, m_iLength - 20];
	
	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			if (Util_MouseAbove(g_vecMousePos, vecUpPos, [20,20])) {
				m_iFlags |= SCROLLBAR_UP_DOWN;
				ret = true;
			} else if (Util_MouseAbove(g_vecMousePos, vecDownPos, [20,20])) {
				m_iFlags |= SCROLLBAR_DN_DOWN;
				ret = true;
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			if (m_iFlags & SCROLLBAR_UP_DOWN && Util_MouseAbove(g_vecMousePos, vecUpPos, [20,20])) {
				SetValue(GetValue() - GetStep(), TRUE);
			} else if (m_iFlags & SCROLLBAR_DN_DOWN && Util_MouseAbove(g_vecMousePos, vecDownPos, [20,20])) {
				SetValue(GetValue() + GetStep(), TRUE);
			}
			m_iFlags -= (m_iFlags & SCROLLBAR_UP_DOWN);
			m_iFlags -= (m_iFlags & SCROLLBAR_DN_DOWN);
		} else if (flKey == K_MWHEELDOWN && Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, [20, m_iLength])) {
			SetValue(GetValue() + GetStep(), TRUE);
		} else if (flKey == K_MWHEELUP && Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, [20, m_iLength])) {
			SetValue(GetValue() - GetStep(), TRUE);
		}
	}
	return (ret);
}

void VGUIScrollbar::SetLength (int iLength)
{
	m_iLength = iLength;
}
int VGUIScrollbar::GetLength(void)
{
	return m_iLength;
}

void VGUIScrollbar::SetMin (float flVal)
{
	m_flMin = flVal;
}
float VGUIScrollbar::GetMin(void)
{
	return m_flMin;
}

void VGUIScrollbar::SetMax (float flVal)
{
	m_flMax = flVal;
}
float VGUIScrollbar::GetMax(void)
{
	return m_flMax;
}

void VGUIScrollbar::SetStep (float flVal)
{
	m_flStep = flVal;
}
float VGUIScrollbar::GetStep(void)
{
	return m_flStep;
}

void VGUIScrollbar::SetValue (float flVal, int iCallBack)
{
	m_flValue = bound(m_flMin, flVal, m_flMax);
	
	if (tmpVGUIScrollbar1 && iCallBack) {
		tmpVGUIScrollbar1();
	}
}
float VGUIScrollbar::GetValue(void)
{
	return m_flValue;
}

void VGUIScrollbar::CallOnChange (void(void) vFunc)
{
	tmpVGUIScrollbar1 = vFunc;
}
