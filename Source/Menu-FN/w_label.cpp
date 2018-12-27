/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CLabel:CWidget
{
	string m_label;
	vector m_color;
	int m_sx;
	int m_sy;
	float m_alpha;
	int m_font;

	void() CLabel;
	virtual void() Draw;
};

void CLabel::CLabel(void)
{
	m_label = "Label";
	m_color = [1,1,1];
	m_alpha = 1.0f;
	m_sx = m_sy = 8;
}

void CLabel::Draw(void)
{
	drawfont = m_font;
	drawstring([m_x,m_y], m_label, [m_sx,m_sy], m_color, m_alpha, 0);
}

/* Sometimes all you need is a static label */
void WLabel_Static(int x, int y, string msg, int sx, int sy, vector col,
					float alpha, float flags, int font)
{
	drawfont = font;
	x += g_menuofs[0];
	y += g_menuofs[1];
	drawstring([x,y], msg, [sx,sy], col, alpha, flags);
}
void WLabel_StaticR(int x, int y, string msg, int sx, int sy, vector col,
					float alpha, float flags, int font)
{
	drawfont = font;
	x += g_menuofs[0] - stringwidth(msg, TRUE,[sx,sy]);
	y += g_menuofs[1];
	drawstring([x,y], msg, [sx,sy], col, alpha, flags);
}

void WField_Static(int x, int y, string msg, int sx, int sy, vector col,
					float alpha, float flags, int font)
{
	drawfont = font;
	x += g_menuofs[0];
	y += g_menuofs[1];
	drawtextfield([x,y], [sx,sy], flags, sprintf("^xAAA%s",msg));
}
