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

class CCheckBox:CWidget
{
	int m_value;
	int m_hover;
	int m_click;
	resource_t m_resChecked;
	resource_t m_resEmpty;
	resource_t m_resHover;
	resource_t m_resDown;

	void CCheckBox(void);

	virtual void(float value) m_changed = 0;

	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;
	virtual void(void(float)) SetCallback;
	virtual void(float) SetValue;

	nonvirtual void DrawBoxChecked(vector);
	nonvirtual void DrawBoxEmpty(vector);
	nonvirtual void DrawBoxHover(vector);
	nonvirtual void DrawBoxDown(vector);
};

void
CCheckBox::CCheckBox(void)
{
	m_resChecked = Resource_Check(strcat(g_bmp[CB_CHECKED], ".bmp"));
	m_resEmpty = Resource_Check(strcat(g_bmp[CB_EMPTY], ".bmp"));
	m_resHover = Resource_Check(strcat(g_bmp[CB_OVER], ".bmp"));
	m_resDown = Resource_Check(strcat(g_bmp[CB_DOWN], ".bmp"));
}

void
CCheckBox::DrawBoxChecked(vector vecPos)
{
	if (Resource_Available(m_resChecked))
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[CB_CHECKED],
			[19,19], [1,1,1], 1.0f);
	else {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [19,19], [0.5,0.5,0.5], 1.0f);
		drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [13,13], [0,0,0], 1.0f);

		drawfill([g_menuofs[0]+m_x+4,g_menuofs[1]+m_y+4],
			[11,11],
			[1,1,1],
			0.75f);
	}
}

void
CCheckBox::DrawBoxEmpty(vector vecPos)
{
	if (Resource_Available(m_resEmpty))
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[CB_EMPTY],
			[19,19], [1,1,1], 1.0f);
	else {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [19,19], [0.5,0.5,0.5], 1.0f);
		drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [13,13], [0,0,0], 1.0f);
	}
}

void
CCheckBox::DrawBoxHover(vector vecPos)
{
	if (Resource_Available(m_resHover))
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[CB_OVER],
			[19,19], [1,1,1], 1.0f, 1);
	else {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [19,19], [0.5,0.5,0.5], 1.0f);
		drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [13,13], [0,0,0], 1.0f);

		drawfill([g_menuofs[0]+m_x+4,g_menuofs[1]+m_y+4],
			[11,11],
			[1,1,1],
			0.5f);
	}
}

void
CCheckBox::DrawBoxDown(vector vecPos)
{
	if (Resource_Available(m_resDown))
		drawpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_bmp[CB_DOWN],
			[19,19], [1,1,1], 1.0f, 0);
	else {
		drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [19,19], [0.5,0.5,0.5], 1.0f);
		drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [13,13], [0,0,0], 1.0f);

		drawfill([g_menuofs[0]+m_x+4,g_menuofs[1]+m_y+4],
			[11,11],
			[1,1,1],
			1.0f);
	}
}

void
CCheckBox::Draw(void)
{
	if (m_click) {
		DrawBoxDown([g_menuofs[0]+m_x,g_menuofs[1]+m_y]);
	} else {
		if (m_value) {
			DrawBoxChecked([g_menuofs[0]+m_x,g_menuofs[1]+m_y]);
		} else {
			DrawBoxEmpty([g_menuofs[0]+m_x,g_menuofs[1]+m_y]);
		}

		if (m_hover) {
			DrawBoxHover([g_menuofs[0]+m_x,g_menuofs[1]+m_y]);
		}
	}
}
void
CCheckBox::Input(float type, float x, float y, float devid)
{
	if (Util_CheckMouse(m_x, m_y, 19, 19) == TRUE) {
		m_hover = TRUE;
	} else {
		m_hover = FALSE;
	}

	if (m_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		m_click = TRUE;
	}

	if (type == IE_KEYUP && x == K_MOUSE1) {
		if (m_click) {
			m_click = FALSE;
			m_value = TRUE - m_value;
			if (m_changed) {
				m_changed(m_value);
			}
		}
	}
}

void
CCheckBox::SetCallback(void(float val) vFunc)
{
	m_changed = vFunc;
}

void
CCheckBox::SetValue(float val)
{
	m_value = (int)val;
}
