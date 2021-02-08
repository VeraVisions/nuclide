/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
"targetname"    Name
"message"       Message to display
"messagetime"   Message lifetime (not implemented)
"loadtime"      Time until we load the last autosave
"duration"      Fade effect total duration
"holdtime"      Fade effect hold time
"rendercolor"   Fade effect color vector (RGB255)
"renderamt"     Fade effect alpha value

This trigger reloads the last autosaved game with a custom message.
This is commonly used when a mission objective has failed.

Trivia:
This entity was introduced in Half-Life (1998).
*/

class player_loadsaved:CBaseTrigger
{
	string m_strMessage;
	float m_flLoadTime;
	float m_flFadeDuration;
	float m_flFadeHold;

	void(void) player_loadsaved;
	virtual void(entity, int) Trigger;
	virtual void(void) ReloadSave;
	virtual void(string, string) SpawnKey;
};

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

#ifdef GS_RENDERFX
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[0]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[1]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[2]);
	WriteFloat(MSG_MULTICAST, m_flRenderAmt);
#else
	WriteFloat(MSG_MULTICAST, colormod[0]);
	WriteFloat(MSG_MULTICAST, colormod[1]);
	WriteFloat(MSG_MULTICAST, colormod[2]);
	WriteFloat(MSG_MULTICAST, alpha);
#endif

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
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
player_loadsaved::player_loadsaved(void)
{
	CBaseTrigger::CBaseTrigger();
}
