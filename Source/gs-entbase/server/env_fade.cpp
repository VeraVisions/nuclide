/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	EVF_FADEDROM,
	EVF_MODULATE,
	EVF_ONLYUSER
};

class env_fade : CBaseTrigger
{
	float m_flFadeDuration;
	float m_flFadeHold;

	void() env_fade;
	virtual void() Trigger;
};

void env_fade :: Trigger (void)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_FADE);
	WriteByte(MSG_MULTICAST, m_rendercolor[0]);
	WriteByte(MSG_MULTICAST, m_rendercolor[1]);
	WriteByte(MSG_MULTICAST, m_rendercolor[2]);
	WriteByte(MSG_MULTICAST, m_renderamt);
	WriteFloat(MSG_MULTICAST, m_flFadeDuration);
	WriteFloat(MSG_MULTICAST, m_flFadeHold);
	WriteByte(MSG_MULTICAST, spawnflags);
	msg_entity = eActivator;
	
	if (spawnflags & EVF_ONLYUSER) {
		multicast('0 0 0', MULTICAST_ONE_R);
	} else {
		multicast('0 0 0', MULTICAST_ALL);
	}
}

void env_fade :: env_fade (void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "duration":
			m_flFadeDuration = stof(argv(i + 1));
			break;
		case "holdtime":
			m_flFadeHold = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
}
