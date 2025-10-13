/*
 * Copyright (c) 2025 Vera Visions LLC
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


class
ncEditorMainFrame:vguiWindow
{
public:
	void ncEditorMainFrame(void);

	virtual void Spawned(void);
	virtual void Reposition(void);

private:
	vguiButton m_select;
	vguiButton m_move;
	vguiButton m_rotate;
};

void
ncEditorMainFrame::ncEditorMainFrame(void)
{
	m_select = __NULL__;
	m_move = __NULL__;
	m_rotate = __NULL__;
}

void
ncEditorMainFrame::Spawned(void)
{
	super::Spawned();

	m_select = spawn(vguiButton);
	m_select.SetSize([40,40]);
	m_select.SetIcon("gfx/icon32/side_select");

	m_move = spawn(vguiButton);
	m_move.SetSize([40,40]);
	m_move.SetIcon("gfx/icon32/side_move");

	m_rotate = spawn(vguiButton);
	m_rotate.SetSize([40,40]);
	m_rotate.SetIcon("gfx/icon32/side_rotate");

	Add(m_select);
	Add(m_move);
	Add(m_rotate);

	Reposition();
}

void
ncEditorMainFrame::Reposition(void)
{
	m_select.SetPos([2,2]);
	m_move.SetPos(m_select.GetPos() + [m_select.GetWidth() + 2, 0]);
	m_rotate.SetPos(m_move.GetPos() + [m_move.GetWidth() + 2, 0]);
}

/* Called by `showEditor` command */
void
VGUI_ShowEditor(void)
{
	static bool initialized;
	static ncEditorMainFrame winEditor;

	if (!initialized) {
		initialized = true;
		winEditor = spawn(ncEditorMainFrame);
		winEditor.SetStyleMask(vguiWindowBorderless);
		winEditor.SetSize([640,48]);
		g_uiDesktop.Add(winEditor);
	}

	winEditor.Show();
}
