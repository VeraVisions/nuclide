/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
	SPRITE_CHANGED_ORIGIN,
	SPRITE_CHANGED_MODELINDEX,
	SPRITE_CHANGED_FRAMERATE,
	SPRITE_CHANGED_SCALE,
	SPRITE_CHANGED_RENDERMODE,
	SPRITE_CHANGED_RENDERFX,
	SPRITE_CHANGED_RENDERCOLOR,
	SPRITE_CHANGED_RENDERAMT,
	SPRITE_CHANGED_MATERIAL,
};

enumflags
{
	ENVS_STARTON,
	ENVS_PLAYONCE
};

class env_sprite:NSRenderableEntity
{
	bool m_iIsShader;
	int m_iToggled;
	float m_flEffects;

	PREDICTED_STRING(m_strMaterial)
	PREDICTED_FLOAT(m_flFramerate)

#ifdef CLIENT
	int m_iMaxFrame;
	bool m_bLoops;
#endif

	void(void) env_sprite;

	virtual void(bool) SetFramerate;

#ifdef SERVER
	virtual void Spawned(void);
	virtual void Trigger(entity,int);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void SpawnKey(string,string);
	virtual void NetworkOnce(void);
#else
	virtual float(void) predraw;
	virtual void(void) think;
	virtual void(float, float) ReceiveEntity;
	virtual void(int) SetMaxFrame;
	virtual void(bool) SetLoopFlag;
#endif
};

#ifdef SERVER
void
env_sprite::EvaluateEntity(void)
{
	if (ATTR_CHANGED(origin)) {
		SetSendFlags(SPRITE_CHANGED_ORIGIN);
	}
	if (ATTR_CHANGED(modelindex)) {
		SetSendFlags(SPRITE_CHANGED_MODELINDEX);
	}
	if (ATTR_CHANGED(m_flFramerate)) {
		SetSendFlags(SPRITE_CHANGED_FRAMERATE);
	}
	if (ATTR_CHANGED(scale)) {
		SetSendFlags(SPRITE_CHANGED_SCALE);
	}
	if (ATTR_CHANGED(m_iRenderMode)) {
		SetSendFlags(SPRITE_CHANGED_RENDERMODE);
	}
	if (ATTR_CHANGED(m_vecRenderColor)) {
		SetSendFlags(SPRITE_CHANGED_RENDERCOLOR);
	}
	if (ATTR_CHANGED(m_flRenderAmt)) {
		SetSendFlags(SPRITE_CHANGED_RENDERAMT);
	}
	if (ATTR_CHANGED(m_strMaterial)) {
		SetSendFlags(SPRITE_CHANGED_MATERIAL);
	}

	SAVE_STATE(origin);
	SAVE_STATE(modelindex);
	SAVE_STATE(m_flFramerate);
	SAVE_STATE(scale);
	SAVE_STATE(m_iRenderMode);
	SAVE_STATE(m_iRenderFX);
	SAVE_STATE(m_vecRenderColor);
	SAVE_STATE(m_flRenderAmt);
	SAVE_STATE(m_strMaterial);
}

float
env_sprite::SendEntity(entity ePEnt, float flFlags)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	if (HasSpawnFlags(ENVS_PLAYONCE))
		return (0);

	/* Delete it on the client. */
	if (m_iToggled == FALSE)
		return (0);

	WriteByte(MSG_ENTITY, ENT_SPRITE);
	WriteFloat(MSG_ENTITY, flFlags);

	if (flFlags & SPRITE_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (flFlags & SPRITE_CHANGED_MODELINDEX) {
		WriteFloat(MSG_ENTITY, modelindex);
	}
	if (flFlags & SPRITE_CHANGED_FRAMERATE) {
		WriteFloat(MSG_ENTITY, m_flFramerate);
	}
	if (flFlags & SPRITE_CHANGED_SCALE) {
		WriteFloat(MSG_ENTITY, scale);
	}
	if (flFlags & SPRITE_CHANGED_RENDERMODE) {
		WriteByte(MSG_ENTITY, m_iRenderMode);
	}
	if (flFlags & SPRITE_CHANGED_RENDERFX) {
		WriteByte(MSG_ENTITY, m_iRenderFX);
	}
	if (flFlags & SPRITE_CHANGED_RENDERCOLOR) {
		WriteFloat(MSG_ENTITY, m_vecRenderColor[0]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[1]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[2]);
	}
	if (flFlags & SPRITE_CHANGED_RENDERAMT) {
		WriteFloat(MSG_ENTITY, m_flRenderAmt);
	}
	if (flFlags & SPRITE_CHANGED_MATERIAL) {
		WriteString(MSG_ENTITY, m_strMaterial);
	}

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
	WriteFloat(MSG_MULTICAST, scale);
	WriteByte(MSG_MULTICAST, m_iRenderMode);
	WriteByte(MSG_MULTICAST, m_iRenderFX);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[0]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[1]);
	WriteFloat(MSG_MULTICAST, m_vecRenderColor[2]);
	WriteFloat(MSG_MULTICAST, m_flRenderAmt);
	WriteString(MSG_MULTICAST, m_strMaterial);

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
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_sprite::Spawned(void)
{
	super::Spawned();

	m_iToggled = (HasSpawnFlags(ENVS_STARTON) > 0) ? TRUE : FALSE;

	/* how pointless this would be otherwise. */
	if (!targetname)
		m_iToggled = TRUE;
}
#else
float
env_sprite::predraw(void)
{
	if (m_strMaterial == __NULL__) {
		return super::predraw();
	}

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vector vecPlayer = pSeat->m_vecPredictedOrigin;
	makevectors(view_angles);
	makevectors(vectoangles(origin - vecPlayer));
	vector forg = origin + (v_forward * -16);
	vector fsize = [64,64];

	traceline(origin, vecPlayer, MOVE_WORLDONLY, this);

	if (trace_fraction < 1.0)
		return (PREDRAW_NEXT);

	R_BeginPolygon(m_strMaterial, 1, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], m_vecRenderColor, 1.0);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], m_vecRenderColor, 1.0);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], m_vecRenderColor, 1.0);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], m_vecRenderColor, 1.0);
	R_EndPolygon();

	addentity(this);

	return (PREDRAW_NEXT);
}

void
env_sprite::think(void)
{
	if (frame >= (m_iMaxFrame-1)) {
		if (m_bLoops == 0) {
			Destroy();
			return;
		} else {
			frame = 0;
		}
	} else {
		frame += 1;
	}

	nextthink = time + (1 / m_flFramerate);
}

void
env_sprite::ReceiveEntity(float flNew, float flFlags)
{
	if (flFlags & SPRITE_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}
	if (flFlags & SPRITE_CHANGED_MODELINDEX) {
		modelindex = readfloat();
	}
	if (flFlags & SPRITE_CHANGED_FRAMERATE) {
		m_flFramerate = readfloat();
	}
	if (flFlags & SPRITE_CHANGED_SCALE) {
		scale = readfloat();
	}
	if (flFlags & SPRITE_CHANGED_RENDERMODE) {
		m_iRenderMode = readbyte();
	}
	if (flFlags & SPRITE_CHANGED_RENDERFX) {
		m_iRenderFX = readbyte();
	}
	if (flFlags & SPRITE_CHANGED_RENDERCOLOR) {
		m_vecRenderColor[0] = readfloat();
		m_vecRenderColor[1] = readfloat();
		m_vecRenderColor[2] = readfloat();
	}
	if (flFlags & SPRITE_CHANGED_RENDERAMT) {
		m_flRenderAmt = readfloat();
	}
	if (flFlags & SPRITE_CHANGED_MATERIAL) {
		m_strMaterial = readstring();
	}

	drawmask = MASK_ENGINE;
	nextthink = time + (1 / m_flFramerate);
	m_iMaxFrame = modelframecount(modelindex);
	m_bLoops = 1; /* repeats */
	setorigin(this, origin);
}

void
env_sprite::SetMaxFrame(int fr)
{
	m_iMaxFrame = fr;
}

void
env_sprite::SetLoopFlag(bool loops)
{
	m_bLoops = loops;
}
#endif


void
env_sprite::SetFramerate(bool flag)
{

}

void
env_sprite::env_sprite(void)
{
	m_iIsShader = false;
	m_flFramerate = 10;
	m_strMaterial = __NULL__;
	scale = 1.0f;
}

#ifdef CLIENT
void
EnvSprite_ParseEvent(void)
{
	env_sprite spr = spawn(env_sprite);
	spr.origin[0] = readcoord();
	spr.origin[1] = readcoord();
	spr.origin[2] = readcoord();
	spr.modelindex = readfloat();
	spr.m_flFramerate = readfloat();
	spr.scale = readfloat();
	spr.m_iRenderMode = readbyte();
	spr.m_iRenderFX = readbyte();
	spr.m_vecRenderColor[0] = readfloat();
	spr.m_vecRenderColor[1] = readfloat();
	spr.m_vecRenderColor[2] = readfloat();
	spr.m_flRenderAmt = readfloat();
	spr.m_strMaterial = readstring();

	spr.drawmask = MASK_ENGINE;
	spr.nextthink = time + (1 / spr.m_flFramerate);
	spr.m_iMaxFrame = modelframecount(spr.modelindex);
	spr.m_bLoops = 0; /* does not repeat */
	setorigin(spr, spr.origin);
}
#endif
