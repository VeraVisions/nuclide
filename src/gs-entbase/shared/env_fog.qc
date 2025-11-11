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
- "rendercolor" : Color of the fog.
- "fadein" : Fade in time (ignored)
- "fadeout" : Fade out time (ignored)

# KEYS (CS, non-linear fog)
- "density" : Strength of the fog.

# KEYS (DMC/SPIRIT)
- "holdtime" : Hold time, 0 is permanent.

# SPAWNFLAGS
- STARTACTIVE (1) : Start active on map load.

# NOTES

There are two conflicting implementations of this entity in GoldSrc.
The variant used in Spirit of Half-Life as well as Deathmatch Classic
uses a linear fog. It can be identifier with the far plane appearing
to move with the camera.

The other implementation of fog is more pleasing, but uses
the "density" key instead.

If no "density" key is detected, we assume it's the linear
fog (and the `STARTACTIVE` spawnflag is also ignored, for compatibility).


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
	PREDICTED_BOOL(m_fogIsLinear)

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
	m_fogIsLinear = true;

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

	if (m_fogIsLinear == true) {
		localcmd(sprintf("set r_fog_linear 1; fog %f %f %f %f %f %f\n", \
			m_flEndDist, /* winging this */
			m_vecColor[0] / 255,
			m_vecColor[1] / 255,
			m_vecColor[2] / 255,
			1.0f,
			m_flStartDist)); /* rough conversion from units */
	} else {
		localcmd(sprintf("set r_fog_linear 0; fog %f %f %f %f %f %f\n", \
			m_flDensity * 100, /* winging this */
			m_vecColor[0] / 255,
			m_vecColor[1] / 255,
			m_vecColor[2] / 255,
			1.0f,
			m_flStartDist / 10)); /* rough conversion from units */
	}
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
	READENTITY_BYTE(m_fogIsLinear, ENVFOG_CHANGED_ACTIVE)
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
	SENDENTITY_BYTE(m_fogIsLinear, ENVFOG_CHANGED_ACTIVE)
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
	EVALUATE_FIELD(m_fogIsLinear, ENVFOG_CHANGED_ACTIVE)
}

void
env_fog::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flStartDist", m_flStartDist);
	SaveFloat(handle, "m_flEndDist", m_flEndDist);
	SaveFloat(handle, "m_flDensity", m_flDensity);
	SaveVector(handle, "m_vecColor", m_vecColor);
	SaveBool(handle, "m_bEnabled", m_bEnabled);
	SaveBool(handle, "m_fogIsLinear", m_fogIsLinear);
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
	case "m_bEnabled":
		m_bEnabled = ReadBool(setValue);
		break;
	case "m_fogIsLinear":
		m_fogIsLinear = ReadBool(setValue);
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
	case "fogStartDistance":
		m_flStartDist = ReadFloat(setValue);
		break;
	case "enddist":
	case "fogStopDistance":
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
	case "fadeout":
	case "fadein":
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

	m_flDensity = GetSpawnFloat("density");

	if (m_flDensity > 0.0f) {
		m_fogIsLinear = false;

		/* only CS maps support this, `dmc2_psx_hydrophobia` uses a targetname and will break otherwise! */
		if (HasSpawnFlags(ENVFOG_STARTACTIVE) == false && HasTargetname() == true) {
			DisableFog();
		} else {
			EnableFog();
		}
	} else {
		m_fogIsLinear = true;
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
