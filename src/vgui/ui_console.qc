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

#ifdef MENU
/** VGUI: Console

A 'portable' console. It takes up less space.
Not sure what the benefit of it is besides that.

@ingroup vgui
*/
class VGUIConsole:VGUIWindow
{
public:
	void VGUIConsole(void);
	virtual void Spawned(void);
	nonvirtual void ConsoleResized(void);

private:
	VGUIFrame m_outlineFrame;
	VGUIButton m_submitButton;
	VGUITextBox m_commandBox;
};

void
VGUIConsole::VGUIConsole(void)
{
	m_outlineFrame = __NULL__;
	m_submitButton = __NULL__;
	m_commandBox = __NULL__;
}

void
VGUIConsole::ConsoleResized(void)
{
	m_outlineFrame.SetSize(GetSize() - [16, 76]);
	m_commandBox.SetSize([GetSizeWidth() - 88,24]);
	m_commandBox.SetPos([8, GetSizeHeight() - 32]);
	m_submitButton.SetPos([GetSizeWidth() - 72, GetSizeHeight() - 32]);
}

void
VGUIConsole::Spawned(void)
{
	super::Spawned();

	SetTitle("Console");
	SetSize([560, 400]);
	SetPos([40, 40]);
	m_outlineFrame = spawn(VGUIFrame);
	m_outlineFrame.SetPos([8,36]);
	m_outlineFrame.SetSize([544,324]);

	m_commandBox = spawn(VGUITextBox);
	m_commandBox.SetPos([8,368]);
	m_commandBox.SetSize([472,24]);

	m_submitButton = spawn(VGUIButton);
	m_submitButton.SetSize([64,24]);
	m_submitButton.SetPos([488,368]);
	m_submitButton.SetTitle("Submit");

	SetStyleMask( VGUIWindowStyleDefault | VGUIWindowResizeable );
	CallOnResize(ConsoleResized);
	Add(m_outlineFrame);
	Add(m_commandBox);
	Add(m_submitButton);
}
#endif
