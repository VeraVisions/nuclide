/*
 * Copyright (c) 2023 Vera Visions LLC.
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
	FUNNEL_CHANGED_SPRITE,
	FUNNEL_CHANGED_STARTPOS_X,
	FUNNEL_CHANGED_STARTPOS_Y,
	FUNNEL_CHANGED_STARTPOS_Z,
	FUNNEL_CHANGED_ENDPOS_X,
	FUNNEL_CHANGED_ENDPOS_Y,
	FUNNEL_CHANGED_ENDPOS_Z,
	FUNNEL_CHANGED_ACTIVE,
	FUNNEL_CHANGED_FLAGS,
	FUNNEL_CHANGED_COLOR,
	FUNNEL_CHANGED_WIDTH,
	FUNNEL_CHANGED_AMOUNT
};

enumflags
{
	FUNNEL_REVERSE,
	FUNNEL_REPEATABLE
};

/*!QUAKED env_funnel (1 .5 0) (-8 -8 -8) (8 8 8) REVERSE REPEATABLE
# OVERVIEW
An effect that when triggered, will create lots of glowing orbs that funnel into
the position of this entity.

# KEYS
- "targetname" : Name
- "sprite" : Particle sprite path.

# SPAWNFLAGS
- REVERSE (1) : Will play the effect in reverse.
- REPEATABLE (2) : Will allow you to trigger the effect multiple times.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
env_funnel:NSRenderableEntity
{
public:
	void env_funnel(void);

#ifdef SERVER
	
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void Save(float);
	virtual void Restore(string, string);

	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
#else
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
	virtual void RendererRestarted(void);
	nonvirtual void RenderGlow(vector, vector, float);
#endif

private:
	string m_strTexture;
	NETWORKED_INT(m_iSpriteID)
	NETWORKED_VECTOR(m_vecStartPos)
	NETWORKED_VECTOR(m_vecEndPos)
	NETWORKED_BOOL(m_bActive)
	NETWORKED_FLOAT_N(spawnflags)

#ifdef SERVER
	float m_flHeight;
#else
	float m_flProgression;
#endif
};

void
env_funnel::env_funnel(void)
{
#ifdef SERVER
	m_strTexture = "sprites/flare6.spr";
	m_iSpriteID = 0i;
	m_flHeight = 512.0f;
#else
	m_flProgression = 0.0f;
#endif
}

#ifdef SERVER
void
env_funnel::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());
	m_vecStartPos = GetOrigin();
	m_vecEndPos = GetOrigin() + [0.0f, 0.0f, m_flHeight];
	m_iSpriteID = getmodelindex(m_strTexture, false);
	pvsflags = PVSF_IGNOREPVS;
	m_vecRenderColor = [1,1,1];
	m_flRenderAmt = 1.0f;
}

void
env_funnel::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "sprite": /* Sven */
	case "netname": /* Spirit */
		m_strTexture = ReadString(strValue);
		break;
	case "height":
		m_flHeight = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strValue, strKey);
	}
}

void
env_funnel::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strTexture", m_strTexture);
	SaveFloat(handle, "m_flHeight", m_flHeight);
}

void
env_funnel::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strTexture":
		m_strTexture = ReadString(strValue);
		break;
	case "m_flHeight":
		m_flHeight = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_funnel::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Use":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
env_funnel::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_bActive = false;
		break;
	case TRIG_ON:
		m_bActive = true;
		break;
	default:
		m_bActive = (m_bActive == true) ? false : true;
	}
}

void
env_funnel::EvaluateEntity(void)
{
	EVALUATE_FIELD(m_iSpriteID, FUNNEL_CHANGED_SPRITE)
	EVALUATE_VECTOR(m_vecStartPos, 0, FUNNEL_CHANGED_STARTPOS_X)
	EVALUATE_VECTOR(m_vecStartPos, 1, FUNNEL_CHANGED_STARTPOS_Y)
	EVALUATE_VECTOR(m_vecStartPos, 2, FUNNEL_CHANGED_STARTPOS_Z)
	EVALUATE_VECTOR(m_vecEndPos, 0, FUNNEL_CHANGED_ENDPOS_X)
	EVALUATE_VECTOR(m_vecEndPos, 1, FUNNEL_CHANGED_ENDPOS_Y)
	EVALUATE_VECTOR(m_vecEndPos, 2, FUNNEL_CHANGED_ENDPOS_Z)
	EVALUATE_FIELD(m_bActive, FUNNEL_CHANGED_ACTIVE)
	EVALUATE_FIELD(spawnflags, FUNNEL_CHANGED_FLAGS)
	EVALUATE_VECTOR(m_vecRenderColor, 0, FUNNEL_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, FUNNEL_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, FUNNEL_CHANGED_COLOR)
	EVALUATE_FIELD(m_flRenderAmt, FUNNEL_CHANGED_AMOUNT)
}

float
env_funnel::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_FUNNEL);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_INT(m_iSpriteID, FUNNEL_CHANGED_SPRITE)
	SENDENTITY_COORD(m_vecStartPos[0], FUNNEL_CHANGED_STARTPOS_X)
	SENDENTITY_COORD(m_vecStartPos[1], FUNNEL_CHANGED_STARTPOS_Y)
	SENDENTITY_COORD(m_vecStartPos[2], FUNNEL_CHANGED_STARTPOS_Z)
	SENDENTITY_COORD(m_vecEndPos[0], FUNNEL_CHANGED_ENDPOS_X)
	SENDENTITY_COORD(m_vecEndPos[1], FUNNEL_CHANGED_ENDPOS_Y)
	SENDENTITY_COORD(m_vecEndPos[2], FUNNEL_CHANGED_ENDPOS_Z)
	SENDENTITY_BYTE(m_bActive, FUNNEL_CHANGED_ACTIVE)
	SENDENTITY_BYTE(spawnflags, FUNNEL_CHANGED_FLAGS)
	SENDENTITY_BYTE(m_vecRenderColor[0], FUNNEL_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecRenderColor[1], FUNNEL_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecRenderColor[2], FUNNEL_CHANGED_COLOR)
	SENDENTITY_BYTE(m_flRenderAmt, FUNNEL_CHANGED_AMOUNT)
	return (1);
}
#else
void
env_funnel::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_INT(m_iSpriteID, FUNNEL_CHANGED_SPRITE)
	READENTITY_COORD(m_vecStartPos[0], FUNNEL_CHANGED_STARTPOS_X)
	READENTITY_COORD(m_vecStartPos[1], FUNNEL_CHANGED_STARTPOS_Y)
	READENTITY_COORD(m_vecStartPos[2], FUNNEL_CHANGED_STARTPOS_Z)
	READENTITY_COORD(m_vecEndPos[0], FUNNEL_CHANGED_ENDPOS_X)
	READENTITY_COORD(m_vecEndPos[1], FUNNEL_CHANGED_ENDPOS_Y)
	READENTITY_COORD(m_vecEndPos[2], FUNNEL_CHANGED_ENDPOS_Z)
	READENTITY_BYTE(m_bActive, FUNNEL_CHANGED_ACTIVE)
	READENTITY_BYTE(spawnflags, FUNNEL_CHANGED_FLAGS)
	READENTITY_BYTE(m_vecRenderColor[0], FUNNEL_CHANGED_COLOR)
	READENTITY_BYTE(m_vecRenderColor[1], FUNNEL_CHANGED_COLOR)
	READENTITY_BYTE(m_vecRenderColor[2], FUNNEL_CHANGED_COLOR)
	READENTITY_BYTE(m_flRenderAmt, FUNNEL_CHANGED_AMOUNT)

	drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
	origin = m_vecStartPos;

	if (flChanged & FUNNEL_CHANGED_SPRITE) {
		RendererRestarted();
	}

	if (flChanged & FUNNEL_CHANGED_ACTIVE) {
		if (m_bActive) {
			m_flProgression = 1.0f;
		}
	}
}

void
env_funnel::RendererRestarted(void)
{
	m_strTexture = spriteframe(modelnameforindex(m_iSpriteID), 0, 0.0f);
}

void
env_funnel::RenderGlow(vector forg, vector fsize, float amount)
{
	float alphaTint = m_flRenderAmt * (1.0 - amount);
	vector renderColor = m_vecRenderColor;

	R_BeginPolygon(m_strTexture, 1, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], renderColor * alphaTint, 1.0f);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], renderColor * alphaTint, 1.0f);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], renderColor * alphaTint, 1.0f);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], renderColor * alphaTint, 1.0f);
	R_EndPolygon();
}

float g_funnelLUT[64] = {
	0.049774,
	0.911133,
	0.425507,
	0.945343,
	0.746552,
	0.490356,
	0.199341,
	0.348816,
	0.690338,
	0.367065,
	0.130249,
	0.207275,
	0.244965,
	0.901581,
	0.310852,
	0.645386,
	0.877228,
	0.736389,
	0.668610,
	0.345398,
	0.901581,
	0.310852,
	0.470245,
	0.736389,
	0.645386,
	0.746552,
	0.490356,
	0.199341,
	0.668610,
	0.987640,
	0.643555,
	0.531952,
	0.968109,
	0.725342,
	0.612732,
	0.166107,
	0.049774,
	0.911133,
	0.470245,
	0.737854,
	0.953552,
	0.345398,
	0.737854,
	0.953552,
	0.425507,
	0.945343,
	0.396271,
	0.877228,
	0.531952,
	0.968109,
	0.725342,
	0.286743,
	0.244965,
	0.286743,
	0.348816,
	0.690338,
	0.367065,
	0.130249,
	0.207275,
	0.987640,
	0.643555,
	0.396271,
	0.612732,
	0.166107,
};

float
env_funnel::predraw(void)
{
	vector vecPlayer;
	vecPlayer = g_view.GetCameraOrigin();
	float progress;

	/* reverse */
	if (HasSpawnFlags(1))
		progress = 1.0 - m_flProgression;
	else
		progress = m_flProgression;

	if (!m_bActive)
		return (PREDRAW_NEXT);

	if (autocvar(r_skipBeams, 0))
		return (PREDRAW_NEXT);

	if (m_flProgression <= 0.0f)
		return (PREDRAW_NEXT);

	makevectors(g_view.GetCameraAngle());

	for (int i = 0; i < 64i; i++) {
		vector startPos;
		vector endPos;
		vector finalPos;
		float rand1 = ((0.5F - g_funnelLUT[i]) * 2.0f);
		float rand2 = ((0.5F - g_funnelLUT[63-i]) * 2.0f);
		float rand3 = rand1 * rand2;

		startPos = m_vecStartPos;
		endPos = m_vecEndPos;

		if (i & 2)
			endPos[0] += rand1 * 512.0f;
		else
			endPos[0] -= rand1 * 512.0f;

		if (i & 1)
			endPos[1] -= rand2 * 512.0f;
		else
			endPos[1] += rand2 * 512.0f;

		endPos[2] += rand3 * 512.0f;

		finalPos[0] = Math_Lerp(startPos[0], endPos[0], progress);
		finalPos[1] = Math_Lerp(startPos[1], endPos[1], progress);
		finalPos[2] = Math_Lerp(startPos[2], endPos[2], progress);

		RenderGlow(finalPos, [64, 64], m_flProgression);
	}

	m_flProgression -= frametime * 0.25;

	return (PREDRAW_NEXT);
}
#endif