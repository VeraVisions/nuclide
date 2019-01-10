/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

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
