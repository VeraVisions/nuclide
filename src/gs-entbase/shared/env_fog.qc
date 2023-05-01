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
	ENVFOG_CHANGED_ACTIVE,
	ENVFOG_CHANGED_STARTDIST,
	ENVFOG_CHANGED_ENDDIST,
	ENVFOG_CHANGED_DENSITY,
	ENVFOG_CHANGED_COLOR
};

/*!QUAKED env_fog (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Covers the map in fog.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "startdist" : Distance between the player and the fog.
- "enddist" : Distance between the player and the end of the fog.
- "density" : Strength of the fog.
- "rendercolor" : Color of the fog.

# TRIVIA
This entity was introduced in Counter-Strike (1998).
*/
class
env_fog:NSPointTrigger
{
public:
	void env_fog(void);

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
	nonvirtual void FogUpdate(void);
#endif

#ifdef SERVER
	virtual float SendEntity(entity,float);
	virtual void EvaluateEntity(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
#endif

private:
	PREDICTED_FLOAT(m_flStartDist)
	PREDICTED_FLOAT(m_flEndDist)
	PREDICTED_FLOAT(m_flDensity)
	PREDICTED_VECTOR(m_vecColor)
	PREDICTED_BOOL(m_bEnabled)
};

void
env_fog::env_fog(void)
{
	m_flStartDist = 0;
	m_flEndDist = 512;
	m_flDensity = 1.0f;
	m_vecColor = [255, 255, 255];
	m_bEnabled = true;
}

#ifdef CLIENT
void
env_fog::FogUpdate(void)
{
	if (!m_bEnabled)
		return;

	localcmd(sprintf("fog %f %f %f %f %f %f\n", \
		m_flDensity * 100, /* winging this */
		m_vecColor[0] / 255,
		m_vecColor[1] / 255,
		m_vecColor[2] / 255,
		1.0f,
		m_flStartDist / 10)); /* rough conversion from units */
}

void
env_fog::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_FLOAT(m_flStartDist, ENVFOG_CHANGED_STARTDIST)
	READENTITY_FLOAT(m_flEndDist, ENVFOG_CHANGED_ENDDIST)
	READENTITY_FLOAT(m_flDensity, ENVFOG_CHANGED_DENSITY)
	READENTITY_BYTE(m_vecColor[0], ENVFOG_CHANGED_COLOR)
	READENTITY_BYTE(m_vecColor[1], ENVFOG_CHANGED_COLOR)
	READENTITY_BYTE(m_vecColor[2], ENVFOG_CHANGED_COLOR)
	READENTITY_BYTE(m_bEnabled, ENVFOG_CHANGED_ACTIVE)
	FogUpdate();
}
#endif

#ifdef SERVER
float
env_fog::SendEntity(entity ePVEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_FOG);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_FLOAT(m_flStartDist, ENVFOG_CHANGED_STARTDIST)
	SENDENTITY_FLOAT(m_flEndDist, ENVFOG_CHANGED_ENDDIST)
	SENDENTITY_FLOAT(m_flDensity, ENVFOG_CHANGED_DENSITY)
	SENDENTITY_BYTE(m_vecColor[0], ENVFOG_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecColor[1], ENVFOG_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecColor[2], ENVFOG_CHANGED_COLOR)
	SENDENTITY_BYTE(m_bEnabled, ENVFOG_CHANGED_ACTIVE)
	return (1);
}

void
env_fog::EvaluateEntity(void)
{
	EVALUATE_FIELD(m_flStartDist, ENVFOG_CHANGED_STARTDIST)
	EVALUATE_FIELD(m_flEndDist, ENVFOG_CHANGED_ENDDIST)
	EVALUATE_FIELD(m_flDensity, ENVFOG_CHANGED_DENSITY)
	EVALUATE_VECTOR(m_vecColor, 0, ENVFOG_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecColor, 1, ENVFOG_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecColor, 2, ENVFOG_CHANGED_COLOR)
	EVALUATE_FIELD(m_bEnabled, ENVFOG_CHANGED_ACTIVE)
}

void
env_fog::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flStartDist", m_flStartDist);
	SaveFloat(handle, "m_flEndDist", m_flEndDist);
	SaveFloat(handle, "m_flDensity", m_flDensity);
	SaveVector(handle, "m_vecColor", m_vecColor);
}

void
env_fog::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flStartDist":
		m_flStartDist = ReadFloat(strValue);
		break;
	case "m_flEndDist":
		m_flEndDist = ReadFloat(strValue);
		break;
	case "m_flDensity":
		m_flDensity = ReadFloat(strValue);
		break;
	case "m_vecColor":
		m_vecColor = ReadVector(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_fog::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "startdist":
		m_flStartDist = stof(strValue);
		break;
	case "enddist":
		m_flEndDist = stof(strValue);
		break;
	case "density":
		m_flDensity = stof(strValue);
		break;
	case "rendercolor":
		m_vecColor = stov(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_fog::Spawned(void)
{
	super::Spawned();
}

void
env_fog::Respawn(void)
{
	pvsflags = PVSF_IGNOREPVS;
}

void
env_fog::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_bEnabled = false;
		break;
	case TRIG_ON:
		m_bEnabled = true;
		break;
	default:
		m_bEnabled = (m_bEnabled) ? false : true;
	}
}
#endif

#ifdef CLIENT
void
env_fog_readentity(float isnew)
{
	env_fog fog = (env_fog)self;
	float flags = readfloat();

	if (isnew)
		spawnfunc_env_fog();

	fog.ReceiveEntity(isnew, flags);
}
#endif