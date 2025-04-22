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

#define ENVFOG_STARTACTIVE 1

/*! \brief Shared-Entity: Simple Fog Controller */
/*!QUAKED env_fog (1 .5 0) (-8 -8 -8) (8 8 8) STARTACTIVE
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

# KEYS (DMC/SPIRIT)
- "fadein" : Fade in time (ignored)
- "fadeout" : Fade out time (ignored)
- "holdtime" : Hold time, 0 is permanent.

# SPAWNFLAGS
- STARTACTIVE (1) : Start active on map load.

# TRIVIA
This entity was introduced in Counter-Strike (1998).

@ingroup sharedentity
@ingroup pointentity
*/
class
env_fog:ncPointTrigger
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
	nonvirtual void EnableFog(void);
	nonvirtual void DisableFog(void);
#endif

private:
	PREDICTED_FLOAT(m_flStartDist)
	PREDICTED_FLOAT(m_flEndDist)
	PREDICTED_FLOAT(m_flDensity)
	PREDICTED_VECTOR(m_vecColor)
	PREDICTED_BOOL(m_bEnabled)

#ifdef SERVER
	float m_holdTime;
#endif
#ifdef CLIENT
	bool m_wasActive;
#endif
};

void
env_fog::env_fog(void)
{
	m_flStartDist = 0;
	m_flEndDist = 512;
	m_flDensity = 1.0f;
	m_vecColor = [255, 255, 255];
	m_bEnabled = true;
#ifdef SERVER
	m_holdTime = 0.0f;
#endif
#ifdef CLIENT
	m_wasActive = false;
#endif

}

#ifdef CLIENT
void
env_fog::FogUpdate(void)
{
	if (!m_bEnabled) {
		if (m_wasActive) {
			localcmd("fog 0\n");
			m_wasActive = false;
		}
		return;
	}

	m_wasActive = true;

	localcmd(sprintf("r_fog_linear 1; fog %f %f %f %f %f %f\n", \
		m_flEndDist, /* winging this */
		m_vecColor[0] / 255,
		m_vecColor[1] / 255,
		m_vecColor[2] / 255,
		1.0f,
		m_flStartDist)); /* rough conversion from units */
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
env_fog::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flStartDist":
		m_flStartDist = ReadFloat(setValue);
		break;
	case "m_flEndDist":
		m_flEndDist = ReadFloat(setValue);
		break;
	case "m_flDensity":
		m_flDensity = ReadFloat(setValue);
		break;
	case "m_vecColor":
		m_vecColor = ReadVector(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_fog::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "startdist":
		m_flStartDist = ReadFloat(setValue);
		break;
	case "enddist":
		m_flEndDist = ReadFloat(setValue);
		break;
	case "density":
		m_flDensity = ReadFloat(setValue);
		break;
	case "rendercolor":
		m_vecColor = ReadVector(setValue);
		break;
	case "holdtime":
		m_holdTime = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
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

	if (HasSpawnFlags(ENVFOG_STARTACTIVE) == false && HasTargetname() == true) {
		DisableFog();
	} else {
		EnableFog();
	}
}

void
env_fog::EnableFog(void)
{
	m_bEnabled = true;
}

void
env_fog::DisableFog(void)
{
	m_bEnabled = false;
}

void
env_fog::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		DisableFog();
		break;
	case TRIG_ON:
		EnableFog();

		if (m_holdTime > 0.0) {
			ScheduleThink(DisableFog, m_holdTime);
		}
		break;
	default:
		Trigger(act, m_bEnabled ? TRIG_OFF : TRIG_ON);
	}
}
#endif
