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
	WriteFloat(MSG_ENTITY, framerate);
	WriteFloat(MSG_ENTITY, scale);
	WriteFloat(MSG_ENTITY, alpha);
	WriteFloat(MSG_ENTITY, effects);
	return TRUE;
}

void env_sprite::NetworkOnce(void)
{
	WriteByte(MSG_ENTITY, EV_SPRITE);
	WriteCoord(MSG_ENTITY, origin_x);
	WriteCoord(MSG_ENTITY, origin_y);
	WriteCoord(MSG_ENTITY, origin_z);
	WriteFloat(MSG_ENTITY, modelindex);
	WriteFloat(MSG_ENTITY, framerate);
	WriteFloat(MSG_ENTITY, scale);
	WriteFloat(MSG_ENTITY, alpha);
	WriteFloat(MSG_ENTITY, effects);
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
	CBaseTrigger::CBaseTrigger();
	precache_model(m_oldModel);
	Respawn();

	m_iToggled = ((spawnflags & ENVS_STARTON) > 0);

	if (!(spawnflags & ENVS_PLAYONCE)) {
		SendEntity = Network;
		SendFlags = 1;
	}
}
