/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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
	WriteCoord(MSG_ENTITY, origin[0]);
	WriteCoord(MSG_ENTITY, origin[1]);
	WriteCoord(MSG_ENTITY, origin[2]);
	WriteFloat(MSG_ENTITY, modelindex);
	WriteFloat(MSG_ENTITY, m_flFramerate);
	WriteFloat(MSG_ENTITY, m_flScale);
	WriteFloat(MSG_ENTITY, alpha);
	WriteFloat(MSG_ENTITY, effects);
	WriteFloat(MSG_ENTITY, colormod[0]);
	WriteFloat(MSG_ENTITY, colormod[1]);
	WriteFloat(MSG_ENTITY, colormod[2]);
	return TRUE;
}

void env_sprite::NetworkOnce(void)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte(MSG_MULTICAST, EV_SPRITE);
	WriteCoord(MSG_MULTICAST, origin[0]);
	WriteCoord(MSG_MULTICAST, origin[1]);
	WriteCoord(MSG_MULTICAST, origin[2]);
	WriteFloat(MSG_MULTICAST, modelindex);
	WriteFloat(MSG_MULTICAST, m_flFramerate);
	WriteFloat(MSG_MULTICAST, m_flScale);
	WriteFloat(MSG_MULTICAST, alpha);
	WriteFloat(MSG_MULTICAST, effects);
	WriteFloat(MSG_MULTICAST, colormod[0]);
	WriteFloat(MSG_MULTICAST, colormod[1]);
	WriteFloat(MSG_MULTICAST, colormod[2]);
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
		default:
			break;
		}
	}
	
	if (!m_flFramerate) {
		m_flFramerate = 10;
	}
	
	if (!m_flScale) {
		m_flScale = 1.0f;
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
