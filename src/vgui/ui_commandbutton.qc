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

enumflags
{
	BUTTON_HOVER,
	BUTTON_DOWN,
	BUTTON_LASTACTIVE,
	BUTTON_CUSTOMFLAGS
};

/* TODO: MOVE THESE INTO vguiButton! COMPILER NEEDS TO BE FIXED FIRST HOWEVER. */
.void(void) tmpvguiButton1;

/** VGUI Widget: Command Menu Button

@ingroup vgui
*/
class vguiCommandButton:vguiButton
{
public:
	void vguiCommandButton(void);

	/* overrides */
	virtual void Draw(void);
	virtual bool Input(float,float,float,float);

	nonvirtual bool WillDisplay(void);
	nonvirtual void SetMapCondition(string);
	nonvirtual void SetTeamCondition(string);
	nonvirtual void SetClassCondition(string);
	nonvirtual void SetClientCommand(string);
private:

	string m_strMapCondition;
	string m_strTeamCondition;
	string m_strClassCondition;
};

void
vguiCommandButton::vguiCommandButton(void)
{
	m_strMapCondition = __NULL__;
	m_strTeamCondition = __NULL__;
	m_strClassCondition = __NULL__;
}

void
vguiCommandButton::SetMapCondition(string condition)
{
	m_strMapCondition = condition;
}

void
vguiCommandButton::SetTeamCondition(string condition)
{
	m_strTeamCondition = condition;
}

void
vguiCommandButton::SetClassCondition(string condition)
{
	m_strClassCondition = condition;
}

void
vguiCommandButton::SetClientCommand(string condition)
{
}

bool
vguiCommandButton::WillDisplay(void)
{
	if (STRING_SET(m_strMapCondition)) {

	}

	if (STRING_SET(m_strTeamCondition)) {

	}

	if (STRING_SET(m_strClassCondition)) {

	}

	return (true);
}

void
vguiCommandButton::Draw(void)
{
	super::Draw();
	//vguiWidget::Draw();
}

bool
vguiCommandButton::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	bool returnValue = super::Input(flEVType, flKey, flChar, flDevID);

	if (!returnValue) {
		//return vguiWidget::Input(flEVType, flKey, flChar, flDevID);
	}

	return (returnValue);
}
