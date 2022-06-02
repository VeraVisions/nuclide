/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED env_sprite (1 0 0) (-8 -8 -8) (8 8 8) ENVS_STARTON ENVS_PLAYONCE
A sprite entity manager with fancy overrides.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"angles" : Sets the pitch, yaw and roll angles of the sprite.
"model" : Path to the sprite in question.
"rendercolor" : Color modifier of the sprite.
"renderamt" : Alpha modifier of the sprite.
"rendermode" : Render mode of the sprite.
"framerate" : Rate between frames in seconds.
"scale" : Scale modifier of the sprite.

-------- SPAWNFLAGS --------
ENVS_STARTON : Start visible.
ENVS_PLAYONCE : Play once from start to finish, then make invisible.

-------- NOTES --------
Only used with an external sprite format, like SPR, SPRHL and SPR32.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	ENVS_STARTON,
	ENVS_PLAYONCE
};

class env_sprite:NSRenderableEntity
{
	bool m_iIsShader;
	int m_iToggled;
	float m_flFramerate;
	float m_flScale;
	float m_flEffects;
	string m_strMaterial;

	void(void) env_sprite;

	virtual void(void) Spawned;
	virtual void(entity, int) Trigger;
	virtual float(entity, float) SendEntity;
	virtual void(string, string) SpawnKey;
	virtual void(entity, string, string) Input;
};

void
env_sprite::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Color":
		m_vecRenderColor = stov(strData) / 255;
		SendFlags |= 1;
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

float
env_sprite::SendEntity(entity ePEnt, float flags)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	if (HasSpawnFlags(ENVS_PLAYONCE))
		return (0);

	/* Delete it on the client. */
	if (m_iToggled == FALSE)
		return (0);

	WriteByte(MSG_ENTITY, ENT_SPRITE);
	WriteFloat(MSG_ENTITY, 666);
	WriteCoord(MSG_ENTITY, origin[0]);
	WriteCoord(MSG_ENTITY, origin[1]);
	WriteCoord(MSG_ENTITY, origin[2]);
	WriteFloat(MSG_ENTITY, modelindex);
	WriteFloat(MSG_ENTITY, m_flFramerate);
	WriteFloat(MSG_ENTITY, m_flScale);
	WriteString(MSG_ENTITY, m_strMaterial);

#ifdef GS_RENDERFX
	WriteByte(MSG_ENTITY, m_iRenderFX);
	WriteByte(MSG_ENTITY, m_iRenderMode);
	WriteFloat(MSG_ENTITY, m_vecRenderColor[0]);
	WriteFloat(MSG_ENTITY, m_vecRenderColor[1]);
	WriteFloat(MSG_ENTITY, m_vecRenderColor[2]);
	WriteFloat(MSG_ENTITY, m_flRenderAmt);
#else
	WriteFloat(MSG_ENTITY, colormod[0]);
	WriteFloat(MSG_ENTITY, colormod[1]);
	WriteFloat(MSG_ENTITY, colormod[2]);
	WriteFloat(MSG_ENTITY, alpha);
#endif

	return (1);
}

void
env_sprite::NetworkOnce(void)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SPRITE);
	WriteCoord(MSG_MULTICAST, origin[0]);
	WriteCoord(MSG_MULTICAST, origin[1]);
	WriteCoord(MSG_MULTICAST, origin[2]);
	WriteFloat(MSG_MULTICAST, modelindex);
	WriteFloat(MSG_MULTICAST, m_flFramerate);
	WriteFloat(MSG_MULTICAST, m_flScale);
	WriteString(MSG_MULTICAST, m_strMaterial);

#ifdef GS_RENDERFX
	WriteByte(MSG_MULTICAST, m_iRenderFX);
	WriteByte(MSG_MULTICAST, m_iRenderMode);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[0]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[1]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[2]);
	WriteFloat(MSG_MULTICAST, m_flRenderAmt);
#else
	WriteFloat(MSG_MULTICAST, colormod[0]);
	WriteFloat(MSG_MULTICAST, colormod[1]);
	WriteFloat(MSG_MULTICAST, colormod[2]);
	WriteFloat(MSG_MULTICAST, alpha);
#endif

	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

/* TODO: Implement state */
void
env_sprite::Trigger(entity act, int state)
{
	if (HasSpawnFlags(ENVS_PLAYONCE)) {
		NetworkOnce();
	} else {
		m_iToggled = 1 - m_iToggled;
		SendFlags = 1;
	}
}

void
env_sprite::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "shader":
	case "material":
		m_strMaterial = strValue;
		break;
	case "framerate":
		m_flFramerate = stof(strValue);
		break;
	case "scale":
		m_flScale = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_sprite::Spawned(void)
{
	m_iToggled = (HasSpawnFlags(ENVS_STARTON) > 0) ? TRUE : FALSE;

	/* how pointless this would be otherwise. */
	if (!targetname)
		m_iToggled = TRUE;
}

void
env_sprite::env_sprite(void)
{
	m_iIsShader = false;
	m_flFramerate = 10;
	m_flScale = 1.0f;
}
