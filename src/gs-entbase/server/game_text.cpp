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
		
	void() game_text;

	virtual void() Trigger;
};

void game_text::Trigger(void)
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
		msg_entity = eActivator;
		multicast(origin, MULTICAST_ONE_R);
	}
}

void game_text::game_text(void)
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "x":
			m_flPosX = stof(argv(i+1));
			break;
		case "y":
			m_flPosY = stof(argv(i+1));
			break;
		case "effect":
			m_iEffect = stoi(argv(i+1));
			break;
		case "color":
			m_vecColor1 = stov(argv(i+1));
			break;
		case "color2":
			m_vecColor2 = stov(argv(i+1));
			break;
		case "fadein":
			m_flFadeIn = stof(argv(i+1));
			break;
		case "fadeout":
			m_flFadeOut = stof(argv(i+1));
			break;
		case "holdtime":
			m_flHoldTime = stof(argv(i+1));
			break;
		case "fxtime":
			m_flFXTime = stof(argv(i+1));
			break;
		case "channel":
			m_iChannel = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
}
