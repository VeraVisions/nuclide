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

/*QUAKED player_loadsaved (1 0 0) (-8 -8 -8) (8 8 8)
This trigger reloads the last autosaved game with a custom message.
This is commonly used when a mission objective has failed.

-------- KEYS --------
"targetname" : Name
"message" : Message to display
"messagetime" : Message lifetime (not implemented)
"loadtime" : Time until we load the last autosave
"duration" : Fade effect total duration
"holdtime" : Fade effect hold time
"rendercolor" : Fade effect color vector (RGB255)
"renderamt" : Fade effect alpha value

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class player_loadsaved:NSRenderableEntity // for the rendercolor values
{
	string m_strMessage;
	float m_flLoadTime;
	float m_flFadeDuration;
	float m_flFadeHold;

	void(void) player_loadsaved;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;

	virtual void(void) ReloadSave;
};

void
player_loadsaved::Save(float handle)
{
	SaveString(handle, "message", m_strMessage);
	SaveFloat(handle, "load_time", m_flLoadTime);
	SaveFloat(handle, "fade_duration", m_flFadeDuration);
	SaveFloat(handle, "fade_hold", m_flFadeHold);
	super::Save(handle);
}

void
player_loadsaved::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "message":
		m_strMessage = ReadString(strValue);
		break;
	case "load_time":
		m_flLoadTime = ReadFloat(strValue);
		break;
	case "fade_duration":
		m_flFadeDuration = ReadFloat(strValue);
		break;
	case "fade_hold":
		m_flFadeHold = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
player_loadsaved::ReloadSave(void)
{
	localcmd("load autosave\n");
}

void
player_loadsaved::Trigger(entity act, int unused)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_FADE);

	WriteFloat(MSG_MULTICAST, m_vecRenderColor[0]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[1]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[2]);
	WriteFloat(MSG_MULTICAST, m_flRenderAmt);

	WriteFloat(MSG_MULTICAST, m_flFadeDuration);
	WriteFloat(MSG_MULTICAST, m_flFadeHold);
	WriteByte(MSG_MULTICAST, 0);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);
	env_message_single(act, m_strMessage);

	think = ReloadSave;
	nextthink = time + m_flLoadTime;
}

void
player_loadsaved::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "duration":
		m_flFadeDuration = stof(strValue);
		break;
	case "holdtime":
		m_flFadeHold = stof(strValue);
		break;
	case "message":
		m_strMessage = strValue;
		break;
	case "loadtime":
		m_flLoadTime = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
player_loadsaved::player_loadsaved(void)
{
}
