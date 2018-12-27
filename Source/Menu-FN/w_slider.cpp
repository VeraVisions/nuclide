/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CSlider:CWidget
{
	int m_length;
	int m_tlength;
	int m_hover;
	int m_hold;
	float m_value;
	virtual void(float value) m_changed = 0;

	void() CSlider;
	virtual void() Draw;
	virtual void(float type, float x, float y, float devid) Input;
	
	virtual void(float val) SetValue;
	virtual void(void(float val) vFunc) SetCallback;
};

void CSlider::CSlider(void)
{
	/* There's the physical length (t_length) and the actual length 
	 * (border, etc. ignored) */
	m_length = 156;
	m_tlength = m_length - 27;
}

void CSlider::Draw(void)
{
	drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [m_length,8], [0.25,0.25,0.25], 1.0f);
	drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [m_length-6,2], [0,0,0], 1.0f);
	
	
	drawpic([g_menuofs[0]+m_x+(m_value * m_tlength)+3,g_menuofs[1]+m_y], g_bmp[SLIDER],
			[21,8], [1,1,1], 1.0f);
}

void CSlider::Input(float type, float x, float y, float devid)
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
		if (g_mousepos[0] != g_lastmousepos[0] || g_mousepos[1] != g_lastmousepos[1]) {
			int mdelta;
			/* The - 10 is putting the slider in the middle of the cursor */
			mdelta = (g_mousepos[0] - 10) - (g_menuofs[0]+m_x);
			m_value = ((float)mdelta / (float)m_tlength);
			m_value = bound(0.0f, m_value, 1.0f);
			g_lastmousepos[0] = g_mousepos[0];
			g_lastmousepos[1] = g_mousepos[1];
			
			if (m_changed) {
				m_changed(m_value);
			}
		}
	}
}

void CSlider::SetValue(float val)
{
	m_value = val;
}

void CSlider::SetCallback(void(float val) vFunc)
{
	m_changed = vFunc;
}
