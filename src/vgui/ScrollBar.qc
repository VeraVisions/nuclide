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

const vector vguiScrollBar_ArrowSize = [19,20];

class vguiScrollBar:vguiWidget
{
	int m_hold;
	int m_hover;

	float m_scrollBarHeight;
	float m_maxBarHeight;
	float m_scroll;
	float m_visibleItems;
	float m_listItemMax;
	float m_listItemHeight;
	virtual void(void) m_changed = 0;

	int m_up_hover;
	int m_up_hold;
	int m_dn_hover;
	int m_dn_hold;

	void vguiScrollBar(void);
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
vguiScrollBar::vguiScrollBar(void)
{
	/* There's the physical length (t_length) and the actual length
	 * (border, etc. ignored) */
	SetItemheight(20);
	SetLength(128);
}

void
vguiScrollBar::SetStep(int step)
{

}

void
vguiScrollBar::SetMin(int step)
{

}


void
vguiScrollBar::DrawArrowUp(vector vecPos)
{
	vguiTheme theme = GetTheme();
	if (m_up_hold) {
		theme.DrawButton(vecPos, vguiScrollBar_ArrowSize, VGUI_STATE_ACTIVE);
	} else {
		theme.DrawButton(vecPos, vguiScrollBar_ArrowSize, VGUI_STATE_NORMAL);
	}

	drawpic(vecPos + [2,2], "gfx/icon16/bullet_arrow_up", [16,16], [1,1,1], 1.0f, 0);
}

void
vguiScrollBar::DrawArrowDown(vector vecPos)
{
	vguiTheme theme = GetTheme();
	if (m_dn_hold) {
		theme.DrawButton(vecPos, vguiScrollBar_ArrowSize, VGUI_STATE_ACTIVE);
	} else {
		theme.DrawButton(vecPos, vguiScrollBar_ArrowSize, VGUI_STATE_NORMAL);
	}

	drawpic(vecPos + [2,2], "gfx/icon16/bullet_arrow_down", [16,16], [1,1,1], 1.0f, 0);
}

void
vguiScrollBar::Draw(void)
{
	vguiTheme theme = GetTheme();
	float visualBarHeight = 0;
	float barstep = 0;

	/* the maximum actual bar (draggable) height */
	m_maxBarHeight = m_scrollBarHeight - (vguiScrollBar_ArrowSize[1] * 2);

	/* max visible items = physical length divided by item height */
	m_visibleItems = m_scrollBarHeight / m_listItemHeight;

	visualBarHeight = (m_visibleItems / m_listItemMax) * m_maxBarHeight;

	if (m_visibleItems >= m_listItemMax) {
		visualBarHeight = m_maxBarHeight - 20;
	}

	if (m_listItemMax <= 0) {
		return;
	}

	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0,vguiScrollBar_ArrowSize[1]], [vguiScrollBar_ArrowSize[0],m_maxBarHeight], [1.0f,1.0f,1.0f], 0.1f);

	DrawArrowUp([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]]);
	DrawArrowDown([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+m_maxBarHeight + vguiScrollBar_ArrowSize[1]]);

	if (visualBarHeight < 20)
		visualBarHeight = 20;

	barstep = (m_maxBarHeight - visualBarHeight);
	barstep *= (m_scroll / m_listItemMax);

	/* too few entries? don't even bother */
	if (visualBarHeight > m_maxBarHeight) {
		drawfill([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+vguiScrollBar_ArrowSize[1]], [vguiScrollBar_ArrowSize[0],m_maxBarHeight], [0.25,0.25,0.25], 1.0f);
		return;
	}

	drawfill([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+vguiScrollBar_ArrowSize[1]+barstep], [vguiScrollBar_ArrowSize[0],visualBarHeight], UI_MAINCOLOR, UI_MAINALPHA);

	if (!m_hold) {
		theme.DrawButton([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+vguiScrollBar_ArrowSize[1]+barstep], [vguiScrollBar_ArrowSize[0],visualBarHeight], VGUI_STATE_NORMAL);
	} else {
		theme.DrawButton([m_parent.m_vecOrigin[0]+m_vecOrigin[0],m_parent.m_vecOrigin[1]+m_vecOrigin[1]+vguiScrollBar_ArrowSize[1]+barstep], [vguiScrollBar_ArrowSize[0],visualBarHeight], VGUI_STATE_ACTIVE);
	}
}

float
vguiScrollBar::Input(float type, float x, float y, float devid)
{
	float barheight = 0;
	float barstep = 0;
	float returnVal = false;

	/* the maximum actual bar (draggable) height */
	m_maxBarHeight = m_scrollBarHeight - (vguiScrollBar_ArrowSize[1] * 2);

	/* max visible items = physical length divided by item height */
	m_visibleItems = m_scrollBarHeight / m_listItemHeight;

	barheight = (m_visibleItems / m_listItemMax) * m_maxBarHeight;

	if (m_visibleItems > m_listItemMax) {
		barheight = m_maxBarHeight - 20;
	}

	if (m_listItemMax <= 0) {
		return;
	}

	if (barheight < 20)
		barheight = 20;

	barstep = m_maxBarHeight - barheight;
	barstep *= (m_scroll / m_listItemMax);

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, vguiScrollBar_ArrowSize)) {
		m_up_hover = TRUE;
	} else {
		m_up_hover = FALSE;
	}

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin + [0, m_maxBarHeight + vguiScrollBar_ArrowSize[1]], vguiScrollBar_ArrowSize)) {
		m_dn_hover = TRUE;
	} else {
		m_dn_hover = FALSE;
	}

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin + [0, barstep + vguiScrollBar_ArrowSize[1]], [vguiScrollBar_ArrowSize[0],barheight])) {
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
			m_value = ((float)mdelta / (float)m_maxBarHeight);
			m_value = bound(0.0f, m_value, 1.0f);

			SetValue(rint(m_listItemMax * m_value));
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
vguiScrollBar::GetValue(void)
{
	return m_scroll;
}

void
vguiScrollBar::SetValue(int val)
{
	m_scroll = bound(0,val,m_listItemMax);

	if (m_changed) {
		m_changed();
	}
}

/* maximum number of entries */
void
vguiScrollBar::SetMax(int val)
{
	m_listItemMax = val;
}

/* absolute height of the scrollbar (with up/down arrows included */
void
vguiScrollBar::SetLength(int val)
{
	m_scrollBarHeight = val;
}

/* size of an item in a list. default is 20px */
void
vguiScrollBar::SetItemheight(int val)
{
	m_listItemHeight = val;
}

void
vguiScrollBar::CallOnChange(void(void) vFunc)
{
	m_changed = vFunc;
}
