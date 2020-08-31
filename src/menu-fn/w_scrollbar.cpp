/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

class CScrollbar:CWidget
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
	virtual void(int) m_changed = 0;
	
	int m_up_hover;
	int m_up_hold;
	int m_dn_hover;
	int m_dn_hold;

	void(void) CScrollbar;
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;

	virtual void(int) SetScroll;
	virtual void(int) SetMax;
	virtual void(int) SetHeight;
	virtual void(int) SetItemheight;
	virtual void(void(int)) SetCallback;
};

void
CScrollbar::CScrollbar(void)
{
	/* There's the physical length (t_length) and the actual length 
	 * (border, etc. ignored) */
	SetItemheight(15);
	SetHeight(128);
}

void
CScrollbar::Draw(void)
{
	int barheight = 0;
	float barstep = 0;

	if (m_up_hold) {
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[UPARROWP],
				[16,16], [1,1,1], 1.0f, 0);
	} else if (m_up_hover) {
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[UPARROWF],
				[16,16], [1,1,1], 1.0f, 0);
	} else {
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[UPARROWD],
				[16,16], [1,1,1], 1.0f, 0);
	}

	if (m_dn_hold) {
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y+m_theight + 16], g_bmp[DNARROWP],
				[16,16], [1,1,1], 1.0f, 0);
	} else if (m_dn_hover) {
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y+m_theight + 16], g_bmp[DNARROWF],
				[16,16], [1,1,1], 1.0f, 0);
	} else {
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y+m_theight + 16], g_bmp[DNARROWD],
				[16,16], [1,1,1], 1.0f, 0);
	}

	barheight = (float)(m_minus) / (float)(m_totalentries) * m_theight;

	barstep = m_theight - barheight;
	barstep *= (float)(m_scroll) / (float)(m_maxvisible);

	/* too few entries? don't even bother */
	if (m_totalentries * m_itemheight < m_height) {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y+16], [16,m_theight], [0.25,0.25,0.25], 1.0f);
		return;
	}

	if (!m_hold) {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y+16], [16,m_theight], [0.25,0.25,0.25], 1.0f);
		if (!m_hover) {
			drawfill([g_menuofs[0]+m_x+4,g_menuofs[1]+m_y+16+4+barstep], [8,barheight-8], [0,0,0], 1.0f);
		} else {
			drawfill([g_menuofs[0]+m_x+4,g_menuofs[1]+m_y+16+4+barstep], [8,barheight-8], [1,0.5,0.25], 1.0f);
		}
	} else {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y+16], [16,m_theight], [0,0,0], 1.0f);
		drawfill([g_menuofs[0]+m_x+4,g_menuofs[1]+m_y+16+4+barstep], [8,barheight-8], [1,0.5,0.25], 1.0f);
	}
}

void
CScrollbar::Input(float type, float x, float y, float devid)
{
	int barheight = 0;
	float barstep = 0;

	/* too few entries? don't even bother */
	if (m_totalentries * m_itemheight < m_height) {
		return;
	}

	/* Up Arrow */
	if (Util_CheckMouse(m_x, m_y, 16, 16)) {
		m_up_hover = TRUE;
	} else {
		m_up_hover = FALSE;
	}
	if (m_up_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_up_hold = TRUE;
	} else if (type == IE_KEYUP && x == K_MOUSE1) {
		m_up_hold = FALSE;
	}
	if (m_up_hold) {
		SetScroll(m_scroll - 1);
	}

	/* Down Arrow */
	if (Util_CheckMouse(m_x, m_y + m_theight + 16, 16, 16)) {
		m_dn_hover = TRUE;
	} else {
		m_dn_hover = FALSE;
	}
	if (m_dn_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_dn_hold = TRUE;
	} else if (type == IE_KEYUP && x == K_MOUSE1) {
		m_dn_hold = FALSE;
	}
	if (m_dn_hold) {
		SetScroll(m_scroll + 1);
	}

	barheight = (float)(m_minus) / (float)(m_totalentries) * m_theight;

	barstep = m_theight - barheight;
	barstep *= (float)(m_scroll) / (float)(m_maxvisible);

	if (Util_CheckMouse(m_x, m_y + 16 + barstep, 16, barheight)) {
		m_hover = TRUE;
	} else {
		m_hover = FALSE;
	}

	if (m_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_hold = TRUE;
	} else if (type == IE_KEYUP && x == K_MOUSE1) {
		m_hold = FALSE;
	}

	if (m_hold) {
		if (g_mousepos[0] != g_lastmousepos[0] || g_mousepos[1] != g_lastmousepos[1]) {
			int mdelta;
			float m_value;
			/* The - 10 is putting the slider in the middle of the cursor */
			mdelta = (g_mousepos[1] - (barheight / 2)) - (g_menuofs[1]+m_y);
			m_value = ((float)mdelta / (float)m_theight);
			m_value = bound(0.0f, m_value, 1.0f);
			
			SetScroll(rint(m_totalentries * m_value));
			g_lastmousepos[0] = g_mousepos[0];
			g_lastmousepos[1] = g_mousepos[1];
			
			/*if (m_changed) {
				m_changed(m_value);
			}*/
		}
	}
}

void
CScrollbar::SetScroll(int val)
{
	m_scroll = bound(0,val,m_maxvisible);

	if (m_changed) {
		m_changed(m_scroll);
	}
}

void
CScrollbar::SetMax(int val)
{
	m_minus = m_height / m_itemheight;
	m_totalentries = val;
	m_maxvisible = m_totalentries - m_minus;
}

void
CScrollbar::SetHeight(int val)
{
	m_height = val;
	m_theight = m_height - 32;
}

void
CScrollbar::SetItemheight(int val)
{
	m_itemheight = val;
}

void
CScrollbar::SetCallback(void(int val) vFunc)
{
	m_changed = vFunc;
}
