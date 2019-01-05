/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

/* https://twhl.info/wiki/page/env_sprite_(Half-Life) */

enumflags
{
	ENVS_STARTON,
	ENVS_PLAYONCE
};

class env_sprite:CBaseTrigger
{
	int m_iToggled;
	float m_flFramerate;
	float m_flScale;
	float m_flAlpha;
	float m_flEffects;

	void() env_sprite;
	virtual void() Trigger;
	virtual float(entity, float) Network;
};

float env_sprite::Network(entity pvsent, float flags)
{
	/* Delete it on the client. */
	if (m_iToggled == FALSE) {
		return FALSE;
	}
	WriteByte(MSG_ENTITY, ENT_SPRITE);
	WriteCoord(MSG_ENTITY, origin_x);
	WriteCoord(MSG_ENTITY, origin_y);
	WriteCoord(MSG_ENTITY, origin_z);
	WriteFloat(MSG_ENTITY, modelindex);
	WriteFloat(MSG_ENTITY, m_flFramerate);
	WriteFloat(MSG_ENTITY, m_flScale);
	WriteFloat(MSG_ENTITY, m_flAlpha);
	WriteFloat(MSG_ENTITY, effects);
	return TRUE;
}

void env_sprite::NetworkOnce(void)
{
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte(MSG_ENTITY, EV_SPRITE);
	WriteCoord(MSG_ENTITY, origin_x);
	WriteCoord(MSG_ENTITY, origin_y);
	WriteCoord(MSG_ENTITY, origin_z);
	WriteFloat(MSG_ENTITY, modelindex);
	WriteFloat(MSG_ENTITY, m_flFramerate);
	WriteFloat(MSG_ENTITY, m_flScale);
	WriteFloat(MSG_ENTITY, m_flAlpha);
	WriteFloat(MSG_ENTITY, effects);
	msg_entity = this;
	multicast( origin, MULTICAST_PVS );
}

void env_sprite::Trigger(void)
{
	if (spawnflags & ENVS_PLAYONCE) {
		NetworkOnce();
	} else {
		m_iToggled = 1 - m_iToggled;
		SendFlags = 1;
	}
}

void env_sprite::env_sprite(void)
{
	for (int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2) {
		switch ( argv( i ) ) {
		case "framerate":
			m_flFramerate = stof(argv(i + 1));
			break;
		case "scale":
			m_flScale = stof(argv(i + 1));
			break;
		case "alpha":
			m_flAlpha = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}

	CBaseTrigger::CBaseTrigger();
	precache_model(m_oldModel);
	Respawn();

	m_iToggled = ((spawnflags & ENVS_STARTON) > 0);

	if (!(spawnflags & ENVS_PLAYONCE)) {
		SendEntity = Network;
		SendFlags = 1;
	}
}
