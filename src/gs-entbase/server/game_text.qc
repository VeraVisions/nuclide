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
	GTF_ALLPLAYERS
};

/*! \brief Server-Entity: Custom Text Message Display */
/*!QUAKED game_text (1 0 0) (-8 -8 -8) (8 8 8) GTF_ALLPLAYERS
# OVERVIEW
This entity displays a message of your choice on-screen.

# KEYS
- "targetname" : Name
- "message" : Text to display. Can be a titles.txt entry.
- "x" : Horizontal position of text. (0 - 1.0 = left to right, -1 = center)
- "y" : Vertical position of text. (0 - 1.0 = top to bottom, -1 = center)
- "effect" : Effect to apply to the text. 0 : Fade In/Out; 1 : Credits; 2 : Scan Out
- "color" : The main colour in RGB255.
- "color2" : The highlight colour in RGB255.
- "fadein" : Time taken to fade in each character.
- "fadeout" : Time taken to fade out message.
- "holdtime" : Length of time to hold message on screen after fading in.
- "fxtime" : Time the highlight lags behind the leading edge of the text in seconds.
- "channel" : Message channel to use. Meant for overriding messages.

# SPAWNFLAGS
- GTF_ALLPLAYERS (1) : Broadcast message to all players, not just the activator.

# NOTES
Line breaks inside "message" can be added with a \n character.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
game_text:ncPointTrigger
{
public:
	void game_text(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);

private:
	vector m_vecColor1;
	vector m_vecColor2;
	float m_flPosX;
	float m_flPosY;
	float m_flFadeIn;
	float m_flFadeOut;
	float m_flHoldTime;
	float m_flFXTime;
	int m_iChannel;
	int m_iEffect;
};

void
game_text::game_text(void)
{
	m_vecColor1 = [0.0f, 0.0f, 0.0f];
	m_vecColor2 = [0.0f, 0.0f, 0.0f];
	m_flPosX = 0.0f;
	m_flPosY = 0.0f;
	m_flFadeIn = 0.0f;
	m_flFadeOut = 0.0f;
	m_flHoldTime = 0.0f;
	m_flFXTime = 0.0f;
	m_iChannel = 0i;
	m_iEffect = 0i;
}

void
game_text::Save(float handle)
{
	super::Save(handle);
	SaveVector(handle, "m_vecColor1", m_vecColor1);
	SaveVector(handle, "m_vecColor2", m_vecColor2);
	SaveFloat(handle, "m_flPosX", m_flPosX);
	SaveFloat(handle, "m_flPosY", m_flPosY);
	SaveFloat(handle, "m_flFadeIn", m_flFadeIn);
	SaveFloat(handle, "m_flFadeOut", m_flFadeOut);
	SaveFloat(handle, "m_flHoldTime", m_flHoldTime);
	SaveFloat(handle, "m_flFXTime", m_flFXTime);
	SaveInt(handle, "m_iChannel", m_iChannel);
	SaveInt(handle, "m_iEffect", m_iEffect);
}

void
game_text::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_vecColor1":
		m_vecColor1 = ReadVector(strValue);
		break;
	case "m_vecColor2":
		m_vecColor2 = ReadVector(strValue);
		break;
	case "m_flPosX":
		m_flPosX = ReadFloat(strValue);
		break;
	case "m_flPosY":
		m_flPosY = ReadFloat(strValue);
		break;
	case "m_flFadeIn":
		m_flFadeIn = ReadFloat(strValue);
		break;
	case "m_flFadeOut":
		m_flFadeOut = ReadFloat(strValue);
		break;
	case "m_flHoldTime":
		m_flHoldTime = ReadFloat(strValue);
		break;
	case "m_flFXTime":
		m_flFXTime = ReadFloat(strValue);
		break;
	case "m_iChannel":
		m_iChannel = ReadInt(strValue);
		break;
	case "m_iEffect":
		m_iEffect = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
game_text::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "x":
		m_flPosX = stof(strValue);
		break;
	case "y":
		m_flPosY = stof(strValue);
		break;
	case "effect":
		m_iEffect = stoi(strValue);
		break;
	case "color":
		m_vecColor1 = stov(strValue);
		break;
	case "color2":
		m_vecColor2 = stov(strValue);
		break;
	case "fadein":
		m_flFadeIn = stof(strValue);
		break;
	case "fadeout":
		m_flFadeOut = stof(strValue);
		break;
	case "holdtime":
		m_flHoldTime = stof(strValue);
		break;
	case "fxtime":
		m_flFXTime = stof(strValue);
		break;
	case "channel":
		m_iChannel = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
game_text::Trigger(entity act, triggermode_t state)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_TEXT_STRING);
	WriteByte(MSG_MULTICAST, m_iChannel);
	WriteString(MSG_MULTICAST, m_strMessage);
	WriteFloat(MSG_MULTICAST, m_flPosX);
	WriteFloat(MSG_MULTICAST, m_flPosY);
	WriteByte(MSG_MULTICAST, m_iEffect);
	WriteByte(MSG_MULTICAST, m_vecColor1[0]);
	WriteByte(MSG_MULTICAST, m_vecColor1[1]);
	WriteByte(MSG_MULTICAST, m_vecColor1[2]);
	WriteByte(MSG_MULTICAST, m_vecColor2[0]);
	WriteByte(MSG_MULTICAST, m_vecColor2[1]);
	WriteByte(MSG_MULTICAST, m_vecColor2[2]);
	WriteFloat(MSG_MULTICAST, m_flFadeIn);
	WriteFloat(MSG_MULTICAST, m_flFadeOut);
	WriteFloat(MSG_MULTICAST, m_flHoldTime);
	WriteFloat(MSG_MULTICAST, m_flFXTime);

	if (HasSpawnFlags(GTF_ALLPLAYERS)) {
		msg_entity = this;
		multicast(origin, MULTICAST_ALL);
	} else {
		msg_entity = act;
		multicast(origin, MULTICAST_ONE_R);
	}
}

void
game_text::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Display":
		Trigger(eAct, TRIG_ON);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}
