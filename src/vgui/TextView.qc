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

/** VGUI Widget: Text View

Handles large buffers of scrolling text.
You can always scroll the text with the wheel on your pointing device,
as well as **Page Up** and **Page Down**.

@ingroup vgui
*/
class
vguiTextView:vguiWidget
{
public:
	void vguiTextView(void);

	/* overrides */
	virtual void Spawned(void);
	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	nonvirtual void AddLine(string);
	nonvirtual void Clear(void);
	nonvirtual int LineCount(void);

private:
	vguiColor m_frameColor;
	string m_conInstance;
};

void
vguiTextView::vguiTextView(void)
{
	m_frameColor = __NULL__;
	m_conInstance = __NULL__;
}


void
vguiTextView::Spawned(void)
{
	super::Spawned();

	m_frameColor = spawn(vguiColor);
	m_frameColor. SetColorWithAlpha(UI_MAINCOLOR, 0.0f);

	string conName = sprintf("UIBuffer_%d", num_for_edict(this));

	/* required to 'spawn' the console! */
	con_printf(conName, "\n");

	/* set up parameters */
	con_getset(conName, "hidden", "1");
 	con_getset(conName, "forceutf8", "1");

	m_conInstance = con_getset(conName, "name", conName);
}

void
vguiTextView::Draw(void)
{
	vguiTheme ourTheme = GetTheme();
	ourTheme.DrawBorder(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_BORDER_INSET, m_frameColor);
	drawfont = g_fntDefault.iID;
	float xPos = m_parent.m_vecOrigin[0] + m_vecOrigin[0] + 4;
	float yPos = m_parent.m_vecOrigin[1] + m_vecOrigin[1] + 4;
	float wSize = m_vecSize[0] - 8;
	float wHeight = m_vecSize[1] - 8;
	drawsetcliparea(xPos, yPos, wSize, wHeight);
	con_draw(m_conInstance, [xPos, yPos], [wSize, wHeight], g_fntDefault.iScaleY);
	drawresetcliparea();
}

float
vguiTextView::Input(float type, float x, float y, float devid)
{
	bool mouseIsHovering = false;

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
		mouseIsHovering = true;
	}

	con_input(m_conInstance, IE_FOCUS, 1, -1, 0);

	/* only forward inputs when mouse updates happen, or some direct key presses */
	if (type == IE_MOUSEABS || type == IE_MOUSEDELTA) {
		float xPos = g_vecMousePos[0] - (m_parent.m_vecOrigin[0] + m_vecOrigin[0] + 4);
		float yPos = g_vecMousePos[1] - (m_parent.m_vecOrigin[1] + m_vecOrigin[1] + 4);
		con_input(m_conInstance, IE_MOUSEABS, xPos, yPos, 0);
	}

	if (type == IE_KEYUP || (type == IE_KEYDOWN && mouseIsHovering == true)) {
		con_input(m_conInstance, type, x, y, 0);
	}

	return super::Input(type, x, y, devid);
}

void
vguiTextView::AddLine(string line)
{
	con_printf(m_conInstance, strcat(line, "\n"));
}

void
vguiTextView::Clear(void)
{
	con_getset(m_conInstance, "clear");
}

int
vguiTextView::LineCount(void)
{
	return (int)stof(con_getset(m_conInstance, "linecount"));
}
