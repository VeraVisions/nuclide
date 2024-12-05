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

/** VGUI: Console

A 'portable' console. It takes up less space.
Not sure what the benefit of it is besides that.

@ingroup vgui
*/
class VGUIConsole:vguiWindow
{
public:
	void VGUIConsole(void);
	virtual void Spawned(void);
	nonvirtual void ConsoleResized(void);

	virtual void Draw(void);
	virtual void Submit(void);
	virtual float Input(float, float, float, float);

private:
	vguiFrame m_outlineFrame;
	vguiButton m_submitButton;
	vguiTextBox m_commandBox;
	string m_conInstance;
};

void
VGUIConsole::VGUIConsole(void)
{
	m_outlineFrame = __NULL__;
	m_submitButton = __NULL__;
	m_commandBox = __NULL__;
	m_conInstance = __NULL__;
}

void
VGUIConsole::ConsoleResized(void)
{
	m_outlineFrame.SetSize(GetSize() - [16, 76]);
	m_commandBox.SetSize([GetWidth() - 88,24]);
	m_commandBox.SetPos([8, GetHeight() - 32]);
	m_submitButton.SetPos([GetWidth() - 72, GetHeight() - 32]);
}

void
VGUIConsole::Submit(void)
{
	localcmd(strcat(m_commandBox.GetText(), "\n"));
	//con_printf(m_conInstance, strcat("/", m_commandBox.GetText(), "\n"));
	m_commandBox.SetText("");
}

void
VGUIConsole::Spawned(void)
{
	static void VGUIConsole_Submit(void) {
		vguiWidget winSelf = (vguiWidget)self;
		VGUIConsole ourConsole = (VGUIConsole)winSelf.m_parent;
		ourConsole.Submit();
	}

	super::Spawned();

	SetTitle("Console");
	SetSize([560, 400]);
	SetMaxSize([9999,9999]);
	SetPos([40, 40]);
	m_outlineFrame = spawn(vguiFrame);
	m_outlineFrame.SetPos([8,36]);
	m_outlineFrame.SetSize([544,324]);

	m_commandBox = spawn(vguiTextBox);
	m_commandBox.SetPos([8,368]);
	m_commandBox.SetSize([472,24]);
	m_commandBox.CallOnEnter(VGUIConsole_Submit);

	m_submitButton = spawn(vguiButton);
	m_submitButton.SetSize([64,24]);
	m_submitButton.SetPos([488,368]);
	m_submitButton.SetTitle("Submit");
	m_submitButton.SetFunc(VGUIConsole_Submit);

	SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
	CallOnResize(ConsoleResized);
	Add(m_outlineFrame);
	Add(m_commandBox);
	Add(m_submitButton);

	m_conInstance = con_getset("", "next");
}

void
VGUIConsole::Draw(void)
{
	super::Draw();

	drawfont = g_fntDefault.iID;

	float xPos = m_parent.m_vecOrigin[0] + m_vecOrigin[0] + m_outlineFrame.GetPosWidth() + 8;
	float yPos = m_parent.m_vecOrigin[1] + m_vecOrigin[1] + m_outlineFrame.GetPosHeight() + 8;
	float wSize = m_outlineFrame.GetWidth() -16;
	float wHeight = m_outlineFrame.GetHeight() -16;

	drawsetcliparea(xPos, yPos, wSize, wHeight);
	con_draw(m_conInstance, [xPos, yPos], [wSize, wHeight], g_fntDefault.iScaleY);
	drawresetcliparea();
}

float
VGUIConsole::Input(float type, float x, float y, float devid)
{
	float ret = super::Input(type, x, y, devid);

	if (!ret) {
		if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin + m_outlineFrame.GetPos() + [8,8], m_outlineFrame.GetSize() + [-16,-16])) {
			con_input(m_conInstance, type, x, y, 0);
			ret = true;
		}
	}

	return (ret);
}
