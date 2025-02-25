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

class CSlider:CWidget
{
	int m_length;
	int m_tlength;
	int m_hover;
	int m_hold;
	float m_value;
	virtual void m_changed(float) = 0;
	resource_t m_resSlider;

	void CSlider(void);
	virtual void Draw(void);
	virtual void Input(float, float, float, float);
	
	virtual void SetValue(float);
	virtual void SetLength(float);
	virtual void SetCallback(void(float));

};

void
CSlider::CSlider(void)
{
	/* There's the physical length (t_length) and the actual length 
	 * (border, etc. ignored) */
	m_length = 156;
	m_tlength = m_length - 27;
	m_resSlider = Resource_Check(strcat(g_bmp[SLIDER], ".bmp"));
}

void
CSlider::Draw(void)
{
	drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [m_length,8], [0.25,0.25,0.25], 1.0f);
	drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [m_length-6,2], [0,0,0], 1.0f);

	if (Resource_Available(m_resSlider))
	drawpic([g_menuofs[0]+m_x+(m_value * m_tlength)+3,g_menuofs[1]+m_y], g_bmp[SLIDER],
			[21,8], [1,1,1], 1.0f);
	else {
		drawfill([g_menuofs[0]+m_x+(m_value * m_tlength)+3,g_menuofs[1]+m_y], [21,8], [1,1,1], 0.75f);
	}
}

void
CSlider::Input(float type, float x, float y, float devid)
{
	if (Util_CheckMouse(m_x, m_y, m_length, 8) == TRUE) {
		m_hover = TRUE;
	} else {
		m_hover = FALSE;
	}

	if (m_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_hold = TRUE;
	}

	if (type == IE_KEYUP && x == K_MOUSE1) {
		if (m_hold) {
			m_hold = FALSE;
		}
	}

	if (m_hold) {
		if (g_vecMousePos[0] != g_lastmousepos[0] || g_vecMousePos[1] != g_lastmousepos[1]) {
			int mdelta;
			/* The - 10 is putting the slider in the middle of the cursor */
			mdelta = (g_vecMousePos[0] - 10) - (g_menuofs[0]+m_x);
			m_value = ((float)mdelta / (float)m_tlength);
			m_value = bound(0.0f, m_value, 1.0f);
			g_lastmousepos[0] = g_vecMousePos[0];
			g_lastmousepos[1] = g_vecMousePos[1];
			
			if (m_changed) {
				m_changed(m_value);
			}
		}
	}
}

void
CSlider::SetLength(float val)
{
	m_length = val;
	m_tlength = m_length - 27;
}

void
CSlider::SetValue(float val)
{
	m_value = val;
}

void
CSlider::SetCallback(void(float val) vFunc)
{
	m_changed = vFunc;
}
