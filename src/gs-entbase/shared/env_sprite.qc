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

/*! \brief Shared-Entity: Animated Sprite */
/*!QUAKED env_sprite (1 .5 0) (-8 -8 -8) (8 8 8) ENVS_STARTON ENVS_PLAYONCE
# OVERVIEW
A sprite entity manager with fancy overrides.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "angles" : Sets the pitch, yaw and roll angles of the sprite.
- "model" : Path to the sprite in question.
- "material" : Instead of model, you can set the path of a material/image here.
- "rendercolor" : Color modifier of the sprite.
- "renderamt" : Alpha modifier of the sprite.
- "rendermode" : Render mode of the sprite.
- "framerate" : Rate between frames in seconds.
- "scale" : Scale modifier of the sprite.

# SPAWNFLAGS
- ENVS_STARTON (1) : Start visible.
- ENVS_PLAYONCE (2) : Play once from start to finish, then make invisible.

# NOTES
Only used with an external sprite format, like SPR, SPRHL and SPR32, unless the material key is specified.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup sharedentity
@ingroup pointentity
*/
class env_sprite:ncRenderableEntity
{
public:
	void env_sprite(void);

	virtual void SetFramerate(bool);

#ifdef SERVER
	virtual void Spawned(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void SpawnKey(string,string);
	virtual void NetworkOnce(void);
	virtual void Respawn(void);
#endif

#ifdef CLIENT
	virtual float predraw(void);
	virtual void think(void);
	virtual void ReceiveEntity(float,float);
	virtual void SetMaxFrame(int);
	virtual void SetLoopFlag(bool);
#endif

private:
	bool m_iIsShader;
	int m_iToggled;
	float m_flEffects;

	NETWORKED_STRING(m_strMaterial)
	NETWORKED_FLOAT(m_flFramerate)

#ifdef CLIENT
	int m_iMaxFrame;
	bool m_bLoops;
#endif
};

void
env_sprite::env_sprite(void)
{
	NETWORKED_DEFAULT(m_strMaterial, __NULL__)
	NETWORKED_DEFAULT(m_flFramerate, 10.0f)
	NETWORKED_DEFAULT(scale, 1.0f)
	m_iIsShader = false;
}

#ifdef SERVER
void
env_sprite::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, SPRITE_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, SPRITE_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, SPRITE_CHANGED_ORIGIN)
	EVALUATE_FIELD(modelindex, SPRITE_CHANGED_MODELINDEX)
	EVALUATE_FIELD(m_flFramerate, SPRITE_CHANGED_FRAMERATE)
	EVALUATE_FIELD(scale, SPRITE_CHANGED_SCALE)
	EVALUATE_FIELD(m_renderMode, SPRITE_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_renderFX, SPRITE_CHANGED_RENDERFX)
	EVALUATE_VECTOR(m_renderColor, 0, SPRITE_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_renderColor, 1, SPRITE_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_renderColor, 2, SPRITE_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_renderAmount, SPRITE_CHANGED_RENDERAMT)
	EVALUATE_FIELD(m_strMaterial, SPRITE_CHANGED_MATERIAL)
}

float
env_sprite::SendEntity(entity ePEnt, float flChanged)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	if (HasSpawnFlags(ENVS_PLAYONCE))
		return (0);

	/* Delete it on the client. */
	if (m_iToggled == FALSE)
		return (0);

	/* strings are expensive. */
	if (!STRING_SET(m_strMaterial))
		flChanged &= ~SPRITE_CHANGED_MATERIAL;

	WriteByte(MSG_ENTITY, ENT_SPRITE);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], SPRITE_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], SPRITE_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], SPRITE_CHANGED_ORIGIN)
	SENDENTITY_FLOAT(modelindex, SPRITE_CHANGED_MODELINDEX)
	SENDENTITY_FLOAT(m_flFramerate, SPRITE_CHANGED_FRAMERATE)
	SENDENTITY_FLOAT(scale, SPRITE_CHANGED_SCALE)
	SENDENTITY_BYTE(m_renderMode, SPRITE_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_renderFX, SPRITE_CHANGED_RENDERFX)
	SENDENTITY_BYTE(m_renderColor[0], SPRITE_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderColor[1], SPRITE_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderColor[2], SPRITE_CHANGED_RENDERCOLOR)
	SENDENTITY_BYTE(m_renderAmount, SPRITE_CHANGED_RENDERAMT)
	SENDENTITY_STRING(m_strMaterial, SPRITE_CHANGED_MATERIAL)
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

	if (STRING_SET(m_strMaterial))
		WriteFloat(MSG_MULTICAST, 0);
	else
		WriteFloat(MSG_MULTICAST, modelindex);

	WriteFloat(MSG_MULTICAST, m_flFramerate);
	WriteFloat(MSG_MULTICAST, scale);
	WriteByte(MSG_MULTICAST, m_renderMode);
	WriteByte(MSG_MULTICAST, m_renderFX);
	WriteByte(MSG_MULTICAST, m_renderColor[0]);
	WriteByte(MSG_MULTICAST, m_renderColor[1]);
	WriteByte(MSG_MULTICAST, m_renderColor[2]);
	WriteByte(MSG_MULTICAST, m_renderAmount);
	WriteString(MSG_MULTICAST, m_strMaterial);

	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

/* TODO: Implement state */
void
env_sprite::Trigger(entity act, triggermode_t state)
{
	if (HasSpawnFlags(ENVS_PLAYONCE)) {
		NetworkOnce();
	} else {
		switch (state) {
		case TRIG_ON:
			m_iToggled = 1;
			break;
		case TRIG_OFF:
			m_iToggled = 0;
			break;
		case TRIG_TOGGLE:
		default:
			m_iToggled = 1 - m_iToggled;
		}

		SendFlags = 1;
	}
}

void
env_sprite::Input(entity theActivator, string inputName, string dataString)
{
	switch (inputName) {
	case "ShowSprite":
		Trigger(theActivator, TRIG_ON);
		break;
	case "HideSprite":
		Trigger(theActivator, TRIG_OFF);
		break;
	default:
		super::Input(theActivator, inputName, dataString);
	}
}

void
env_sprite::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "shader":
	case "material":
		m_strMaterial = setValue;
		break;
	case "framerate":
		m_flFramerate = stof(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
env_sprite::Spawned(void)
{
	super::Spawned();

	m_iToggled = (HasSpawnFlags(ENVS_STARTON) > 0) ? TRUE : FALSE;

	/* how pointless this would be otherwise. */
	if (!STRING_SET(targetname))
		m_iToggled = TRUE;
}

void
env_sprite::Respawn(void)
{
	super::Respawn();

	string modelTest = GetSpawnString("model");

	/* HACK: Source Engine support. Yes, they re-used 'model' for this. */
	if (exists.InVFS(modelTest) == false) {

		string sourceVMT = strcat("materials/", Util_ChangeExtension(modelTest, "vmt"));

		if (exists.InVFS(sourceVMT)) {
			m_strMaterial = sourceVMT;
			model = __NULL__;
			modelindex = 0;
		}
	}
}
#endif

#ifdef CLIENT
float
env_sprite::predraw(void)
{
	if (m_strMaterial == __NULL__) {
		return super::predraw();
	}

	vector color = m_renderColor / 255;
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vector vecPlayer = pSeat->m_vecPredictedOrigin;
	makevectors(view_angles);
	makevectors(vectoangles(origin - vecPlayer));
	vector forg = origin + (v_forward * -16);
	vector fsize = [64,64];

	traceline(origin, vecPlayer, MOVE_WORLDONLY, this);

	trace_fraction = 1.0f;

	if (trace_fraction < 1.0)
		return (PREDRAW_NEXT);

	R_BeginPolygon(m_strMaterial, 1, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], color, 1.0);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], color, 1.0);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], color, 1.0);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], color, 1.0);
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
env_sprite::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], SPRITE_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], SPRITE_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], SPRITE_CHANGED_ORIGIN)
	READENTITY_FLOAT(modelindex, SPRITE_CHANGED_MODELINDEX)
	READENTITY_FLOAT(m_flFramerate, SPRITE_CHANGED_FRAMERATE)
	READENTITY_FLOAT(scale, SPRITE_CHANGED_SCALE)
	READENTITY_BYTE(m_renderMode, SPRITE_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_renderFX, SPRITE_CHANGED_RENDERFX)
	READENTITY_BYTE(m_renderColor[0], SPRITE_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderColor[1], SPRITE_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderColor[2], SPRITE_CHANGED_RENDERCOLOR)
	READENTITY_BYTE(m_renderAmount, SPRITE_CHANGED_RENDERAMT)
	READENTITY_STRING(m_strMaterial, SPRITE_CHANGED_MATERIAL)

	m_netEffects = effects = EF_NOSHADOW;
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
	spr.m_renderMode = readbyte();
	spr.m_renderFX = readbyte();
	spr.m_renderColor[0] = readbyte();
	spr.m_renderColor[1] = readbyte();
	spr.m_renderColor[2] = readbyte();
	spr.m_renderAmount = readbyte();
	spr.m_strMaterial = readstring();

	spr.drawmask = MASK_ENGINE;
	spr.nextthink = time + (1 / spr.m_flFramerate);
	spr.m_iMaxFrame = modelframecount(spr.modelindex);
	spr.m_bLoops = 0; /* does not repeat */
	setorigin(spr, spr.origin);
}
#endif
