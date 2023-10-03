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

/*!QUAKED trigger_autosave (.5 .5 .5) ?
# OVERVIEW
Volume that'll save the current game when a client enters its bounds.
This entity does not work in multiplayer.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
trigger_autosave:NSBrushTrigger
{
public:
	void trigger_autosave(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Touch(entity);

private:
	float m_flDelay;
};

void
trigger_autosave::trigger_autosave(void)
{
	m_flDelay = 0.0f;
}

void
trigger_autosave::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flDelay", m_flDelay);
}

void
trigger_autosave::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_autosave::Spawned(void)
{
	super::Spawned();

	if (cvar("sv_playerslots") > 1) {
		Destroy();
		return;
	}
}

void
trigger_autosave::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_autosave::Touch(entity eToucher)
{
	if (GetMaster() == FALSE)
		return;

	/* saved text */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MESSAGE);
	WriteString(MSG_MULTICAST, "GAMESAVED");
	WriteString(MSG_MULTICAST, "common/menu2.wav");
	WriteFloat(MSG_MULTICAST, 1.0);
	WriteByte(MSG_MULTICAST, ATTN_NONE);
	msg_entity = this;
	multicast(origin, MULTICAST_ALL);

	NSLog("^2trigger_autosave::^3Touch^7: %s called autosave", 
		eToucher.netname);

	localcmd("save autosave\n");
	SetSolid(SOLID_NOT);

	UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);
}
