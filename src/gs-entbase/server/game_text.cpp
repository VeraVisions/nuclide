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

/*QUAKED game_text (1 0 0) (-8 -8 -8) (8 8 8) GTF_ALLPLAYERS
"targetname"    Name
"x"             Horizontal position of text. 
                    (0 - 1.0 = left to right, -1 = center)
"y"             Vertical position of text.
                    (0 - 1.0 = top to bottom, -1 = center)
"effect"        Effect to apply to the text.
                    Valid values:
                        0 = Fade In/Out
                        1 = Credits
                        2 = Scan Out
"color"         The main colour in RGB8.
"color2"        The highlight colour in RGB8.
"fadein"        Time taken to fade in each character.
"fadeout"       Time taken to fade out message.
"holdtime"      Length of time to hold message on screen after fading in.
"fxtime"        Time the highlight lags behind the leading edge of the text in
                seconds.
"channel"       Message channel to use. Meant for overriding messages.

This entity displays a message of your choice on-screen.
Line breaks can be added with a \n character.

If GTF_ALLPLAYERS is set, it'll display the message to not just the activator,
but all players on the level.

Trivia:
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	GTF_ALLPLAYERS
};

class game_text:CBaseTrigger
{
	float m_flPosX;
	float m_flPosY;
	int m_iEffect;
	vector m_vecColor1;
	vector m_vecColor2;
	float m_flFadeIn;
	float m_flFadeOut;
	float m_flHoldTime;
	float m_flFXTime;
	int m_iChannel;
		
	void(void) game_text;

	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void game_text::Trigger(entity act, int state)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_TEXT);
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

	if (spawnflags & GTF_ALLPLAYERS) {
		msg_entity = this;
		multicast(origin, MULTICAST_ALL);
	} else {
		msg_entity = act;
		multicast(origin, MULTICAST_ONE_R);
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
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void game_text::game_text(void)
{
	CBaseTrigger::CBaseTrigger();
}
