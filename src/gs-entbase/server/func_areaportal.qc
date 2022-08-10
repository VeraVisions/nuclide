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

/*QUAKED func_areaportal (0 .5 .8) ?
Manages a space between two areas.
Requires to be positioned within an areaportal helper brush.

-------- KEYS --------
"targetname" : Name
"StartOpen"  : Sets the initial state. If 1 the portal will start open.

-------- INPUTS --------
"Open" : Open the areaportal.
"Close" : Close the areaportal.
"Toggle" : Toggle the areaportal.

-------- TRIVIA --------
This entity was introduced in Quake II (1997).
*/

class
func_areaportal:NSEntity
{
	int m_iPortalState;
	int m_iStartOpen;

	void(void) func_areaportal;

	/* overrides */
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
	virtual void(entity, int) Trigger;
	virtual void(entity, string, string) Input;

	virtual void(void) PortalOpen;
	virtual void(void) PortalClose;
};

void
func_areaportal::func_areaportal(void)
{
	m_iPortalState = 0i;
	m_iStartOpen = 0i;
}

void
func_areaportal::Respawn(void)
{
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	Hide();

	if (!m_iStartOpen)
		PortalClose();
	else
		PortalOpen();
}

void
func_areaportal::SpawnKey(string strKey, string strValue)
{

	switch (strKey) {
	case "StartOpen":
		m_iStartOpen = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_areaportal::Trigger(entity act, int state)
{
	if (state == TRIG_OFF) {
		PortalClose();
	} else if (state == TRIG_ON) {
		PortalOpen();
	} else {
		if (m_iPortalState == 1)
			PortalClose();
		else
			PortalOpen();
	}
}

void
func_areaportal::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Open":
		Trigger(eAct, TRIG_ON);
		break;
	case "Close":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
func_areaportal::PortalOpen(void)
{
	if (m_iPortalState == 1)
		return;

	m_iPortalState = 1;
	setorigin(this, origin);
	openportal(this, AREAPORTAL_OPEN);
}

void
func_areaportal::PortalClose(void)
{
	if (m_iPortalState == 0)
		return;

	m_iPortalState = 0;
	setorigin(this, origin);
	openportal(this, AREAPORTAL_CLOSED);
}
