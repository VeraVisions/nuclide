/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

#define EVS_GLOBAL 1

class env_shake : CBaseTrigger
{
	float m_flRadius;
	float m_flAmplitude;
	float m_flDuration;
	float m_flFrequency;

	void() env_shake;
	virtual void() Trigger;
};

void env_shake :: Trigger (void)
{
	for (entity eClients = world; (eClients = find(eClients, ::classname, "Player"));) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_SHAKE);
		WriteFloat(MSG_MULTICAST, m_flRadius);
		WriteFloat(MSG_MULTICAST, m_flAmplitude);
		WriteFloat(MSG_MULTICAST, m_flDuration);
		WriteFloat(MSG_MULTICAST, m_flFrequency);
		msg_entity = eClients;
		multicast('0 0 0', MULTICAST_ONE_R);
	}
}

void env_shake :: env_shake (void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "radius":
			m_flRadius = stof(argv(i + 1));
			break;
		case "amplitude":
			m_flAmplitude = stof(argv(i + 1));
			break;
		case "duration":
			m_flDuration = stof(argv(i + 1));
			break;
		case "frequency":
			m_flFrequency = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}
	CBaseTrigger::CBaseTrigger();
}
