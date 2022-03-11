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

class CFrame:CWidget
{
	int m_background;
	int m_bsize[2];
	int m_size[2];
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;

	virtual void(int, int) SetSize;
	virtual void(int) SetBorder;
};

void
CFrame::CFrame(void)
{
	m_bsize[0] = m_bsize[1] = 3;
}

void
CFrame::Draw(void)
{
	if (g_focuswidget == this) {
		drawfill([g_menuofs[0] + m_x, g_menuofs[1] + m_y], 
			 [m_size[0],m_size[1]], [0.5,0.5,0.5], 1.0f);
	} else {
		drawfill([g_menuofs[0] + m_x, g_menuofs[1] + m_y], 
			 [m_size[0],m_size[1]], [0.25,0.25,0.25], 1.0f);
	}

	if (m_bsize[0] > 0)
	drawfill([g_menuofs[0] + m_x + m_bsize[0], g_menuofs[1] + m_y + m_bsize[1]], 
			 [m_size[0] - (m_bsize[0] * 2),m_size[1]-(m_bsize[1] * 2)],
			 [0,0,0], 1.0f);
}

void
CFrame::Input(float type, float x, float y, float devid)
{
	if (Util_CheckMouse(m_x, m_y, m_size[0], m_size[1])) {
		if (type == IE_KEYDOWN) {
			if (x == K_MOUSE1) {
				g_focuswidget = this;
			}
		}
	}
}

void
CFrame::SetSize(int x, int y)
{
	m_size[0] = x;
	m_size[1] = y;
}

void
CFrame::SetBorder(int x)
{
	m_bsize[0] = m_bsize[1] = x;
}
