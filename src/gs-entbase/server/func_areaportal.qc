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

/*!QUAKED func_areaportal (0 .5 .8) ?
# OVERVIEW
Manages a space between two areas.
Requires to be positioned within an areaportal helper brush.

# KEYS
- "targetname" : Name
- "StartOpen"  : Sets the initial state. If 1 the portal will start open.

# INPUTS
- "Open" : Open the areaportal.
- "Close" : Close the areaportal.
- "Toggle" : Toggle the areaportal.

# TRIVIA
This entity was introduced in Quake II (1997).
*/

/*!QUAKED func_areaportalwindow (0 .5 .8) ?
# OVERVIEW
Manages a space between two areas, but only renders
when a player is in the specified range.

Requires a helper func_brush entity that should be textured simple,
and have 'Solidty' set to '1'. This entity will render instead
of the culled area, and needs a targetname to be called by the
areaportalwindow.

# KEYS
- "target" : The targetname of the helper func_brush entity.
- "FadeStartDist"  : Sets the distance for rendering the helper entity.
- "FadeDist"  : Sets the distance for closing the portal.
- "TranslucencyLimit"  : How much should the helper brush fade. Set to '0' for complete fadeout.
- "BackgroundBModel"  : Optional brush entity that can be drawn after the helper entity.

# INPUTS
- "SetFadeStartDistance" : Sets FadeStartDist.
- "SetFadeEndDistance" : Sets FadeDist.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/

class
func_areaportal:NSEntity
{
public:
	void func_areaportal(void);
	
	/* overrides */
	virtual void Spawned(void);
	virtual void SpawnKey(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity,string,string);
	virtual void Save(float);
	virtual void Restore(string, string);
	
	nonvirtual void PortalOpen(void);
	nonvirtual void PortalClose(void);

private:
	bool m_bPortalState;
	bool m_bStartOpen;
	int m_iPortalNumber; /* Source Engine only */
	bool m_bSourcePortal;
};

void
func_areaportal::func_areaportal(void)
{
	m_bPortalState = true;
	m_bStartOpen = false;
	m_iPortalNumber = 0i;
	m_bSourcePortal = false;
}

void
func_areaportal::Save(float handle)
{
	super::Save(handle);
	SaveBool(handle, "m_bPortalState", m_bPortalState);
	SaveBool(handle, "m_bStartOpen", m_bStartOpen);
	SaveInt(handle, "m_iPortalNumber", m_iPortalNumber);
	SaveBool(handle, "m_bSourcePortal", m_bSourcePortal);
}

void
func_areaportal::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_bPortalState":
		m_bPortalState = ReadBool(strValue);
		break;
	case "m_bStartOpen":
		m_bStartOpen = ReadBool(strValue);
		break;
	case "m_iPortalNumber":
		m_iPortalNumber = ReadInt(strValue);
		break;
	case "m_bSourcePortal":
		m_bSourcePortal = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_areaportal::Spawned(void)
{
	super::Spawned();

	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	Hide();
	SetSolid(SOLID_NOT);

	if (m_bSourcePortal)
		style = (float)m_iPortalNumber;

	if (m_bStartOpen == false)
		PortalClose();
	else
		PortalOpen();
}

void
func_areaportal::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "StartOpen":
		m_bStartOpen = ReadBool(strValue);
		break;
	case "portalnumber":
		m_iPortalNumber = ReadInt(strValue);
		m_bSourcePortal = true;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_areaportal::Trigger(entity act, triggermode_t state)
{
	if (state == TRIG_OFF) {
		PortalClose();
	} else if (state == TRIG_ON) {
		PortalOpen();
	} else {
		if (m_bPortalState == true)
			PortalClose();
		else
			PortalOpen();
	}
}

void
func_areaportal::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "TurnOn":
	case "Open":
		Trigger(eAct, TRIG_ON);
		break;
	case "TurnOff":
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
	m_bPortalState = true;
	setorigin(this, origin);
	openportal(this, AREAPORTAL_OPEN);
}

void
func_areaportal::PortalClose(void)
{
	m_bPortalState = false;
	setorigin(this, origin);
	openportal(this, AREAPORTAL_CLOSED);
}