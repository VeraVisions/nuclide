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

#ifdef CLIENT
class env_smoker_cloud:NSEntity
{
public:
	void env_smoker_cloud(void);
	
	virtual float predraw(void);
};

float
env_smoker_cloud::predraw(void)
{
	vector vecPlayer = g_view.GetCameraOrigin();
	float finalScale;
	float finalAlpha;
	
	if (checkpvs(vecPlayer, this) == false) {
		return (PREDRAW_NEXT);
	}

	finalScale = scale;
	finalAlpha = min(1.0, alpha);

	if (alpha > 1.0) {
		finalAlpha = 2.0 - alpha;
		finalAlpha *= 2.0f;
		finalAlpha = min(1.0, finalAlpha);
	}

	makevectors(g_view.GetCameraAngle() + [0.0f, 0.0f, alpha + time * 15.0f]);
	R_BeginPolygon("textures/sfx/smoke", 0, 0);
	R_PolygonVertex(origin + v_right * finalScale - v_up * finalScale, [1,1], color, finalAlpha);
	R_PolygonVertex(origin - v_right * finalScale - v_up * finalScale, [0,1], color, finalAlpha);
	R_PolygonVertex(origin - v_right * finalScale + v_up * finalScale, [0,0], color, finalAlpha);
	R_PolygonVertex(origin + v_right * finalScale + v_up * finalScale, [1,0], color, finalAlpha);
	R_EndPolygon();

	alpha -= frametime;
	return (PREDRAW_NEXT);
}

void
env_smoker_cloud:: env_smoker_cloud(void)
{
	setsize(this, [0,0,0], [0,0,0]);
	drawmask = MASK_ENGINE;
}
#endif

enumflags
{
	SMOKER_CHANGED_POSITION,
	SMOKER_CHANGED_ANGLE,
	SMOKER_CHANGED_SCALE,
	SMOKER_CHANGED_DISPERSION,
	SMOKER_CHANGED_ACTIVE
};

/*!QUAKED env_smoker (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Basic emitter for smoke like effects.

# KEYS
- "targetname" : Name
- "health" : Duration of the effect.
- "scale" : Scale multiplier.
- "dmg" : Angle variance multiplier.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
env_smoker:NSRenderableEntity
{
public:
	void env_smoker(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);

	nonvirtual void DisableSmoker(void);
#else
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
#endif

private:
	NETWORKED_BOOL(m_bActive)
	NETWORKED_FLOAT(m_flScale)
	NETWORKED_FLOAT(m_flDispersion)

#ifdef SERVER
	float m_flDuration;
#else
	float m_flNextSmoke;
#endif
};

void
env_smoker::env_smoker(void)
{
	m_bActive = true;
	m_flScale = 1.0f;
	m_flDispersion = 0.0f;
	angles[0] = -90.0f;

#ifdef SERVER
	m_flDuration = 0.0f;
#endif
}

#ifdef SERVER
void
env_smoker::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());
	m_bActive = true;

	if (m_flDuration != -1.0f) {
		ScheduleThink(DisableSmoker, m_flDuration);
	}
}

void
env_smoker::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "health":
		m_flDuration = ReadFloat(strValue);
		break;
	case "scale": 
		m_flScale = ReadFloat(strValue);
		break;
	case "dmg":
		m_flDispersion = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strValue, strKey);
	}
}

void
env_smoker::Save(float handle)
{
	super::Save(handle);
	SaveBool(handle, "m_bActive", m_bActive);
	SaveFloat(handle, "m_flScale", m_flScale);
	SaveFloat(handle, "m_flDispersion", m_flDispersion);
	SaveFloat(handle, "m_flDuration", m_flDuration);
}

void
env_smoker::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_bActive":
		m_bActive = ReadBool(strValue);
		break;
	case "m_flScale":
		m_flScale = ReadFloat(strValue);
		break;
	case "m_flDispersion":
		m_flDispersion = ReadFloat(strValue);
		break;
	case "m_flDuration":
		m_flDuration = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_smoker::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Use":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "SetScale":
		m_flScale = ReadFloat(strData);
		break;
	case "SetDispersion":
		m_flDispersion = ReadFloat(strData);
		break;
	case "SetDuration":
		m_flDuration = ReadFloat(strData);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
env_smoker::Trigger(entity act, triggermode_t state)
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

	/* infinity */
	if (m_flDuration == -1.0f) {
		return;
	}

	if (m_bActive == true) {
		ScheduleThink(DisableSmoker, m_flDuration);
	}
}

void
env_smoker::DisableSmoker(void)
{
	m_bActive = false;
}

void
env_smoker::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, SMOKER_CHANGED_POSITION)
	EVALUATE_VECTOR(origin, 1, SMOKER_CHANGED_POSITION)
	EVALUATE_VECTOR(origin, 2, SMOKER_CHANGED_POSITION)
	EVALUATE_VECTOR(angles, 0, SMOKER_CHANGED_ANGLE)
	EVALUATE_VECTOR(angles, 1, SMOKER_CHANGED_ANGLE)
	EVALUATE_VECTOR(angles, 2, SMOKER_CHANGED_ANGLE)
	EVALUATE_FIELD(m_flScale, SMOKER_CHANGED_SCALE)
	EVALUATE_FIELD(m_flDispersion, SMOKER_CHANGED_DISPERSION)
	EVALUATE_FIELD(m_bActive, SMOKER_CHANGED_ACTIVE)
}

float
env_smoker::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_SMOKER);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], SMOKER_CHANGED_POSITION)
	SENDENTITY_COORD(origin[1], SMOKER_CHANGED_POSITION)
	SENDENTITY_COORD(origin[2], SMOKER_CHANGED_POSITION)
	SENDENTITY_COORD(angles[0], SMOKER_CHANGED_ANGLE)
	SENDENTITY_COORD(angles[1], SMOKER_CHANGED_ANGLE)
	SENDENTITY_COORD(angles[2], SMOKER_CHANGED_ANGLE)
	SENDENTITY_FLOAT(m_flScale, SMOKER_CHANGED_SCALE)
	SENDENTITY_FLOAT(m_flDispersion, SMOKER_CHANGED_DISPERSION)
	SENDENTITY_BYTE(m_bActive, SMOKER_CHANGED_ACTIVE)
	return (1);
}
#else
void
env_smoker::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], SMOKER_CHANGED_POSITION)
	READENTITY_COORD(origin[1], SMOKER_CHANGED_POSITION)
	READENTITY_COORD(origin[2], SMOKER_CHANGED_POSITION)
	READENTITY_COORD(angles[0], SMOKER_CHANGED_ANGLE)
	READENTITY_COORD(angles[1], SMOKER_CHANGED_ANGLE)
	READENTITY_COORD(angles[2], SMOKER_CHANGED_ANGLE)
	READENTITY_FLOAT(m_flScale, SMOKER_CHANGED_SCALE)
	READENTITY_FLOAT(m_flDispersion, SMOKER_CHANGED_DISPERSION)
	READENTITY_BYTE(m_bActive, SMOKER_CHANGED_ACTIVE)

	drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
}

float
env_smoker::predraw(void)
{
	if (!m_bActive)
		return (PREDRAW_NEXT);

	if (autocvar(r_skipBeams, 0))
		return (PREDRAW_NEXT);

	if (m_flNextSmoke > time)
		return (PREDRAW_NEXT);

	float r1 = 0.0f;
	float r2 = 0.0f;
	float r3 = random();
	makevectors(angles);

	r1 = 0.5f - random();
	r2 = 0.5f - random();
	r1 *= 2.0f;
	r2 *= 2.0f;
	r1 *= m_flDispersion;
	r2 *= m_flDispersion;
	
	env_smoker_cloud cloud = spawn(env_smoker_cloud);
	cloud.SetMovetype(MOVETYPE_FLY);
	cloud.scale = m_flScale * r3;
	r3 *= 64.0f;
	cloud.SetOrigin(origin + v_forward * r3 + v_right * r1 + v_up * r2);
	cloud.color = [0.1,0.1,0.1];
	cloud.alpha = 2.0f;
	cloud.ScheduleThink(Destroy, 2.0f);

	m_flNextSmoke = time + random(0.1f, 0.2f);
	return (PREDRAW_NEXT);
}
#endif