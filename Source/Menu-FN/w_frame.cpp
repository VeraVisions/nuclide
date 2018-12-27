/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CFrame:CWidget
{
	int m_bsize[2];
	int m_size[2];
	virtual void() Draw;
	virtual void(float type, float x, float y, float devid) Input;

	virtual void(int w, int h) SetSize;
};

void CFrame::CFrame(void)
{
	m_bsize[0] = m_bsize[1] = 3;
}

void CFrame::Draw(void)
{
	if (g_focuswidget == this) {
		drawfill([g_menuofs[0] + m_x, g_menuofs[1] + m_y], 
			 [m_size[0],m_size[1]], [0.5,0.5,0.5], 1.0f);
	} else {
		drawfill([g_menuofs[0] + m_x, g_menuofs[1] + m_y], 
			 [m_size[0],m_size[1]], [0.25,0.25,0.25], 1.0f);
	}
	drawfill([g_menuofs[0] + m_x + m_bsize[0], g_menuofs[1] + m_y + m_bsize[1]], 
			 [m_size[0] - (m_bsize[0] * 2),m_size[1]-(m_bsize[1] * 2)],
			 [0,0,0], 1.0f);
}

void CFrame::Input(float type, float x, float y, float devid)
{
	if (Util_CheckMouse(m_x, m_y, m_size[0], m_size[1])) {
		if (type == IE_KEYDOWN) {
			if (x == K_MOUSE1) {
				g_focuswidget = this;
			}
		}
	}
}
void CFrame::SetSize(int x, int y)
{
	m_size[0] = x;
	m_size[1] = y;
}
