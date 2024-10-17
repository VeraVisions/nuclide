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

const vector VGUIScrollbar_ArrowSize = [19,20];

class VGUIScrollbar:VGUIWidget
{
	int m_hold;
	int m_hover;

	int m_height;
	int m_theight;
	int m_scroll;
	int m_minus;
	int m_maxvisible;
	int m_totalentries;
	int m_itemheight;
	virtual void(void) m_changed = 0;

	int m_up_hover;
	int m_up_hold;
	int m_dn_hover;
	int m_dn_hold;

	void VGUIScrollbar(void);
	virtual void Draw(void);
	virtual float Input(float, float, float, float);

	virtual int GetValue(void);
	virtual void SetStep(int);
	virtual void SetMin(int);
	virtual void SetValue(int);
	virtual void SetMax(int);
	virtual void SetLength(int);
	virtual void SetItemheight(int) ;
	virtual void CallOnChange(void(void));

	nonvirtual void DrawArrowUp(vector);
	nonvirtual void DrawArrowDown(vector);
};

void
VGUIScrollbar::VGUIScrollbar(void)
{
	/* There's the physical length (t_length) and the actual length
	 * (border, etc. ignored) */
	SetItemheight(20);
	SetLength(128);
}

void
VGUIScrollbar::SetStep(int step)
{

}

void
VGUIScrollbar::SetMin(int step)
{

}


void
VGUIScrollbar::DrawArrowUp(vector vecPos)
{
	VGUITheme theme = GetTheme();
	if (m_up_hold) {
		theme.DrawButton(vecPos, VGUIScrollbar_ArrowSize, VGUI_STATE_ACTIVE);
	} else {
		theme.DrawButton(vecPos, VGUIScrollbar_ArrowSize, VGUI_STATE_NORMAL);
	}

	drawpic(vecPos + [2,2], "gfx/icon16/bullet_arrow_up", [16,16], [1,1,1], 1.0f, 0);
}

void
VGUIScrollbar::DrawArrowDown(vector vecPos)
{
	VGUITheme theme = GetTheme();
	if (m_dn_hold) {
		theme.DrawButton(vecPos, VGUIScrollbar_ArrowSize, VGUI_STATE_ACTIVE);
	} else {
		theme.DrawButton(vecPos, VGUIScrollbar_ArrowSize, VGUI_STATE_NORMAL);
	}

	drawpic(vecPos + [2,2], "gfx/icon16/bullet_arrow_down", [16,16], [1,1,1], 1.0f, 0);
}

void
VGUIScrollbar::Draw(void)
{
	VGUITheme theme = GetTheme();
	int barheight = 0;
	float barstep = 0;

	barheight = (float)(m_minus) / (float)(m_totalentries) * m_theight;

	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0,VGUIScrollbar_ArrowSize[1]], [VGUIScrollbar_ArrowSize[0],m_theight], [1.0f,1.0f,1.0f], 0.1f);

	DrawArrowUp([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]]);
	DrawArrowDown([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+m_theight + VGUIScrollbar_ArrowSize[1]]);


	if (barheight < 20)
		barheight = 20;

	barstep = m_theight - barheight;
	barstep *= (float)(m_scroll) / (float)(m_maxvisible);

	/* too few entries? don't even bother */
	if (m_totalentries * m_itemheight < m_height) {
		drawfill([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+VGUIScrollbar_ArrowSize[1]], [VGUIScrollbar_ArrowSize[0],m_theight], [0.25,0.25,0.25], 1.0f);
		return;
	}

	drawfill([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+VGUIScrollbar_ArrowSize[1]+barstep], [VGUIScrollbar_ArrowSize[0],barheight], UI_MAINCOLOR, UI_MAINALPHA);

	if (!m_hold) {
		theme.DrawButton([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+VGUIScrollbar_ArrowSize[1]+barstep], [VGUIScrollbar_ArrowSize[0],barheight], VGUI_STATE_NORMAL);
	} else {
		theme.DrawButton([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+VGUIScrollbar_ArrowSize[1]+barstep], [VGUIScrollbar_ArrowSize[0],barheight], VGUI_STATE_ACTIVE);
	}
}

float
VGUIScrollbar::Input(float type, float x, float y, float devid)
{
	int barheight = 0;
	float barstep = 0;
	float returnVal = false;

	/* too few entries? don't even bother */
	if (m_totalentries * m_itemheight < m_height) {
		return false;
	}

	barheight = (float)(m_minus) / (float)(m_totalentries) * m_theight;

	if (barheight < 20)
		barheight = 20;

	barstep = m_theight - barheight;
	barstep *= (float)(m_scroll) / (float)(m_maxvisible);

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, VGUIScrollbar_ArrowSize)) {
		m_up_hover = TRUE;
	} else {
		m_up_hover = FALSE;
	}

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin + [0, m_theight + VGUIScrollbar_ArrowSize[1]], VGUIScrollbar_ArrowSize)) {
		m_dn_hover = TRUE;
	} else {
		m_dn_hover = FALSE;
	}

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin + [0, barstep + VGUIScrollbar_ArrowSize[1]], [VGUIScrollbar_ArrowSize[0],barheight])) {
		m_hover = TRUE;
	} else {
		m_hover = FALSE;
	}

	if (m_up_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_up_hold = TRUE;
		returnVal = true;
	} else if (type == IE_KEYUP && x == K_MOUSE1) {
		m_up_hold = FALSE;
	}
	if (m_up_hold) {
		SetValue(m_scroll - 1);
	}

	if (m_dn_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_dn_hold = TRUE;
		returnVal = true;
	} else if (type == IE_KEYUP && x == K_MOUSE1) {
		m_dn_hold = FALSE;
	}
	if (m_dn_hold) {
		SetValue(m_scroll + 1);
	}

	if (m_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_hold = TRUE;
		returnVal = true;
	} else if (type == IE_KEYUP && x == K_MOUSE1) {
		m_hold = FALSE;
	}

	if (m_hold) {
		if (g_vecMousePos[0] != g_lastmousepos[0] || g_vecMousePos[1] != g_lastmousepos[1]) {
			int mdelta;
			float m_value;
			/* The - 10 is putting the slider in the middle of the cursor */
			mdelta = (g_vecMousePos[1] - (barheight / 2)) - ( m_parent.m_vecOrigin[1] + m_vecOrigin[1]);
			m_value = ((float)mdelta / (float)m_theight);
			m_value = bound(0.0f, m_value, 1.0f);

			SetValue(rint(m_totalentries * m_value));
			g_lastmousepos[0] = g_vecMousePos[0];
			g_lastmousepos[1] = g_vecMousePos[1];

			/*if (m_changed) {
				m_changed(m_value);
			}*/
		}
	}

	return (returnVal);
}

int
VGUIScrollbar::GetValue(void)
{
	return m_scroll;
}

void
VGUIScrollbar::SetValue(int val)
{
	m_scroll = bound(0,val,m_totalentries);

	if (m_changed) {
		m_changed();
	}
}

void
VGUIScrollbar::SetMax(int val)
{
	m_minus = m_height / m_itemheight;
	m_totalentries = val;
	m_maxvisible = m_totalentries - m_minus;
}

void
VGUIScrollbar::SetLength(int val)
{
	m_height = val;
	m_theight = m_height - (VGUIScrollbar_ArrowSize[1] * 2);
}

void
VGUIScrollbar::SetItemheight(int val)
{
	m_itemheight = val;
}

void
VGUIScrollbar::CallOnChange(void(void) vFunc)
{
	m_changed = vFunc;
}
