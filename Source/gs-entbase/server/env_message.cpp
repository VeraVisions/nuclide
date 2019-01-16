/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	EMF_ONCE,
    EMF_ALLPLAYERS
};

class env_message:CBaseTrigger
{
	string m_strSound;
	float m_flVolume;
	int m_iAttenuation;

	void() env_message;

	virtual void() Play;
	virtual void() Respawn;
};

void env_message::Play(void)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MESSAGE);
	WriteString(MSG_MULTICAST, m_strMessage);
	WriteString(MSG_MULTICAST, m_strSound);
	WriteFloat(MSG_MULTICAST, m_flVolume);
	WriteByte(MSG_MULTICAST, m_iAttenuation);

	if (spawnflags & EMF_ALLPLAYERS) {
		msg_entity = this;
		multicast(origin, MULTICAST_ALL);
	} else {
		msg_entity = eActivator;
		multicast(origin, MULTICAST_ONE_R);
	}

	if (spawnflags & EMF_ONCE) {
		Trigger = __NULL__;
	}
}

void env_message::Respawn(void)
{
	Trigger = Play;
}

void env_message::env_message(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "messagesound":
			m_strSound = argv(i+1);
			break;
		case "messagevolume":
			m_flVolume = stof(argv(i+1));
			break;
		case "messageattenuation":
			m_iAttenuation = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
	env_message::Respawn();
}
