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
	ENVSTEAM_EMISSIVE
};

enumflags
{
	EVSTEAM_CHANGED_ORIGIN,
	EVSTEAM_CHANGED_ANGLE,
	EVSTEAM_CHANGED_STATE,
	EVSTEAM_CHANGED_TYPE,
	EVSTEAM_CHANGED_SPREAD,
	EVSTEAM_CHANGED_SPEED,
	EVSTEAM_CHANGED_MINS,
	EVSTEAM_CHANGED_MAXS,
	EVSTEAM_CHANGED_RATE,
	EVSTEAM_CHANGED_COLOR,
	EVSTEAM_CHANGED_LENGTH,
	EVSTEAM_CHANGED_ALPHA,
	EVSTEAM_CHANGED_ROLL
};

#ifdef CLIENT
class env_steam_particle
{
public:
	void env_steam_particle(void);
	
	virtual float predraw(void);

private:
	float m_flStartSize;
	float m_flEndSize;
	float lifetime;
	bool m_bEmissive;
	bool m_bType;

	/* attributes */
	float m_flAlpha;
	vector m_vecColor;
	float m_flLifeTime;
};

float
env_steam_particle::predraw(void)
{
	float partSize;
	float lerpPos = (lifetime / m_flLifeTime);
	float alpha = m_flAlpha * lerpPos;
	vector color;
	vector spriteRight;
	vector spriteUp;

	if (m_bEmissive)
		color = m_vecColor;
	else
		color = (getlight(origin) / 255);

	partSize = lerp(m_flStartSize, m_flEndSize, lerpPos);

	/* we really don't want to do this here, but people
	   will mostly pass image samples and thus won't do orientation on the GPU. */
	spriteRight = anglesToRight(g_view.GetCameraAngle());
	spriteUp = anglesToUp(g_view.GetCameraAngle());

	if (m_bType)
		R_BeginPolygon("textures/sfx/heatsteam", 0, 0);
	else
		R_BeginPolygon("textures/sfx/steam", 0, 0);

	R_PolygonVertex(origin + spriteRight * partSize - spriteUp * partSize, [1,1], m_vecColor, alpha);
	R_PolygonVertex(origin - spriteRight * partSize - spriteUp * partSize, [0,1], m_vecColor, alpha);
	R_PolygonVertex(origin - spriteRight * partSize + spriteUp * partSize, [0,0], m_vecColor, alpha);
	R_PolygonVertex(origin + spriteRight * partSize + spriteUp * partSize, [1,0], m_vecColor, alpha);
	R_EndPolygon();

	if (lerpPos >= 1.0f) {
		remove(this);
	}

	lifetime += frametime;

	return PREDRAW_NEXT;
}

void
env_steam_particle::env_steam_particle(void)
{
	setsize(this, [0,0,0], [0,0,0]);
	drawmask = MASK_ENGINE;
	lifetime = 0.0f;
}
#endif

/*!QUAKED env_steam (1 .5 0) (-8 -8 -8) (8 8 8) EMISSIVE
# OVERVIEW
Environmental steam jet entity.

# KEYS
- "targetname" : Name
- "InitialState" : 0 - Start off, 1 - Start on
- "type" : Particle type: 0 - Default, 1 - Heat-wave effect
- "SpreadSpeed" : Amount of spread for the individual steam particles.
- "Speed" : Particle movement speed in units per second.
- "StartSize" : Initial size of the particles.
- "EndSize" : Final size of the particles before removal.
- "Rate" : Rate of particle emission in units per second.
- "rendercolor" : Color of the steam particles. Requires EMISSIVE spawnflag.
- "JetLength" : Lifetime of each particle in units, basically the length of the steam jet.
- "renderamt" : Alpha channel value of the steam particles.
- "rollspeed" : Rotation speed of the particles.

# SPAWNFLAGS
- EMISSIVE (1) : Smoke will be colored after the 'rendercolor' field.

# INPUTS
- "TurnOn" : Turn emitter on.
- "TurnOff" : Turn emitter off.
- "Toggle" : Toggle emitter on/off.
- "JetLength" : Change the length of the steam jet.
- "Rate" : Change the rate of the particles in units per second.
- "Speed" : Change the speed of the particles in units per second.
- "SpreadSpeed" : Change the amount of spread for the particles.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class
env_steam:NSPointTrigger
{
#ifdef SERVER
	bool m_bInitialState;
#else
	float m_flNexTime;
#endif

	PREDICTED_BOOL(m_bEmissive)
	PREDICTED_BOOL(m_bState)
	PREDICTED_BOOL(m_bType)
	PREDICTED_FLOAT(m_flSpread)
	PREDICTED_FLOAT(m_flSpeed)
	PREDICTED_FLOAT(m_flStartSize)
	PREDICTED_FLOAT(m_flEndSize)
	PREDICTED_FLOAT(m_flRate)
	PREDICTED_VECTOR(m_vecColor)
	PREDICTED_FLOAT(m_flLength)
	PREDICTED_FLOAT(m_flAlpha)
	PREDICTED_FLOAT(m_flRollSpeed)

	void env_steam(void);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string strKey, string strValue);
	virtual void Respawn(void);
	virtual void Input(entity, string, string);
	virtual void Trigger(entity, triggermode_t);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#else
	virtual void ReceiveEntity(float,float);
	virtual float predraw(void);
#endif
};

void
env_steam::env_steam(void)
{
#ifdef SERVER
	m_bEmissive = false;
	m_bInitialState = false;
	m_bState = false;
	m_bType = false;
	m_flSpread = 15.0f;
	m_flSpeed = 120.0f;
	m_flStartSize = 10.0f;
	m_flEndSize = 25.0f;
	m_flRate = 26.0f;
	m_vecColor = [1.0, 1.0, 1.0];
	m_flLength = 80.0;
	m_flAlpha = 1.0f;
	m_flRollSpeed = 8.0f;
#endif
}

#ifdef SERVER
void
env_steam::Save(float handle)
{
	super::Save(handle);
	SaveBool(handle, "m_bEmissive", m_bEmissive);
	SaveBool(handle, "m_bInitialState", m_bInitialState);
	SaveBool(handle, "m_bState", m_bState);
	SaveBool(handle, "m_bType", m_bType);
	SaveFloat(handle, "m_flSpread", m_flSpread);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flStartSize", m_flStartSize);
	SaveFloat(handle, "m_flEndSize", m_flEndSize);
	SaveFloat(handle, "m_flRate", m_flRate);
	SaveVector(handle, "m_vecColor", m_vecColor);
	SaveFloat(handle, "m_flLength", m_flLength);
	SaveFloat(handle, "m_flAlpha", m_flAlpha);
	SaveFloat(handle, "m_flRollSpeed", m_flRollSpeed);
}

void
env_steam::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_bEmissive":
		m_bEmissive = ReadBool(strValue);
		break;
	case "m_bInitialState":
		m_bInitialState = ReadBool(strValue);
		break;
	case "m_bState":
		 m_bState = ReadBool(strValue);
		break;
	case "m_bType":
		 m_bType = ReadBool(strValue);
		break;
	case "m_flSpread":
		 m_flSpread = ReadFloat(strValue);
		break;
	case "m_flSpeed":
		 m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flStartSize":
		 m_flStartSize = ReadFloat(strValue);
		break;
	case "m_flEndSize":
		 m_flEndSize = ReadFloat(strValue);
		break;
	case "m_flRate":
		 m_flRate = ReadFloat(strValue);
		break;
	case "m_vecColor":
		 m_vecColor = ReadVector(strValue);
		break;
	case "m_flLength":
		 m_flLength = ReadFloat(strValue);
		break;
	case "m_flAlpha":
		 m_flAlpha = ReadFloat(strValue);
		break;
	case "m_flRollSpeed":
		 m_flRollSpeed = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_steam::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "InitialState":
		m_bInitialState = stof(strValue);
		break;
	case "type":
		m_bType = stof(strValue);
		break;
	case "SpreadSpeed":
		m_flSpread = stof(strValue);
		break;
	case "Speed":
		m_flSpeed = stof(strValue);
		break;
	case "StartSize":
		m_flStartSize = stof(strValue);
		break;
	case "EndSize":
		m_flEndSize = stof(strValue);
		break;
	case "Rate":
		m_flRate = stof(strValue);
		break;
	case "rendercolor":
		m_vecColor = stov(strValue) / 255;
		break;
	case "JetLength":
		m_flLength = stof(strValue);
		break;
	case "renderamt":
		m_flAlpha = stof(strValue) / 255;
		break;
	case "rollspeed":
		m_flRollSpeed = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_steam::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "TurnOn":
		Trigger(eAct, TRIG_ON);
		break;
	case "TurnOff":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "JetLength":
		m_flLength = stof(strData);
		break;
	case "Rate":
		m_flRate = stof(strData);
		break;
	case "Speed":
		m_flSpeed = stof(strData);
		break;
	case "SpreadSpeed":
		m_flSpread = stof(strData);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
env_steam::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_bState = false;
		break;
	case TRIG_ON:
		m_bState = true;
		break;
	default:
		m_bState = (m_bState == true) ? false : true;
	}
}

void
env_steam::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());

	if (m_bInitialState)
		m_bState = true;
	if (HasSpawnFlags(1))
		m_bEmissive = true;
}

void
env_steam::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, EVSTEAM_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, EVSTEAM_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, EVSTEAM_CHANGED_ORIGIN)
	EVALUATE_VECTOR(angles, 0, EVSTEAM_CHANGED_ANGLE)
	EVALUATE_VECTOR(angles, 1, EVSTEAM_CHANGED_ANGLE)
	EVALUATE_VECTOR(angles, 2, EVSTEAM_CHANGED_ANGLE)
	EVALUATE_FIELD(m_bState, EVSTEAM_CHANGED_STATE)
	EVALUATE_FIELD(m_bEmissive, EVSTEAM_CHANGED_TYPE)
	EVALUATE_FIELD(m_bType, EVSTEAM_CHANGED_TYPE)
	EVALUATE_FIELD(m_flSpread, EVSTEAM_CHANGED_SPREAD)
	EVALUATE_FIELD(m_flSpeed, EVSTEAM_CHANGED_SPEED)
	EVALUATE_FIELD(m_flStartSize, EVSTEAM_CHANGED_MINS)
	EVALUATE_FIELD(m_flEndSize , EVSTEAM_CHANGED_MAXS)
	EVALUATE_FIELD(m_flRate, EVSTEAM_CHANGED_RATE)
	EVALUATE_VECTOR(m_vecColor, 0, EVSTEAM_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecColor, 1, EVSTEAM_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecColor, 2, EVSTEAM_CHANGED_COLOR)
	EVALUATE_FIELD(m_flLength, EVSTEAM_CHANGED_LENGTH)
	EVALUATE_FIELD(m_flAlpha, EVSTEAM_CHANGED_ALPHA)
	EVALUATE_FIELD(m_flRollSpeed, EVSTEAM_CHANGED_ROLL)
}

float
env_steam::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_STEAM);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], EVSTEAM_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], EVSTEAM_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], EVSTEAM_CHANGED_ORIGIN)
	SENDENTITY_COORD(angles[0], EVSTEAM_CHANGED_ANGLE)
	SENDENTITY_COORD(angles[1], EVSTEAM_CHANGED_ANGLE)
	SENDENTITY_COORD(angles[2], EVSTEAM_CHANGED_ANGLE)
	SENDENTITY_BYTE(m_bState, EVSTEAM_CHANGED_STATE)
	SENDENTITY_BYTE(m_bEmissive, EVSTEAM_CHANGED_TYPE)
	SENDENTITY_BYTE(m_bType, EVSTEAM_CHANGED_TYPE)
	SENDENTITY_FLOAT(m_flSpread, EVSTEAM_CHANGED_SPREAD)
	SENDENTITY_FLOAT(m_flSpeed, EVSTEAM_CHANGED_SPEED)
	SENDENTITY_FLOAT(m_flStartSize, EVSTEAM_CHANGED_MINS)
	SENDENTITY_FLOAT(m_flEndSize , EVSTEAM_CHANGED_MAXS)
	SENDENTITY_FLOAT(m_flRate, EVSTEAM_CHANGED_RATE)
	SENDENTITY_COLOR(m_vecColor[0], EVSTEAM_CHANGED_COLOR)
	SENDENTITY_COLOR(m_vecColor[1], EVSTEAM_CHANGED_COLOR)
	SENDENTITY_COLOR(m_vecColor[2], EVSTEAM_CHANGED_COLOR)
	SENDENTITY_FLOAT(m_flLength, EVSTEAM_CHANGED_LENGTH)
	SENDENTITY_FLOAT(m_flAlpha, EVSTEAM_CHANGED_ALPHA)
	SENDENTITY_FLOAT(m_flRollSpeed, EVSTEAM_CHANGED_ROLL)

	//print(sprintf("S (%x): %v %v %i\n", flChanged, origin, m_vecEndPos, m_iActive));

	return (1);
}
#else
void
env_steam::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], EVSTEAM_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], EVSTEAM_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], EVSTEAM_CHANGED_ORIGIN)
	READENTITY_COORD(angles[0], EVSTEAM_CHANGED_ANGLE)
	READENTITY_COORD(angles[1], EVSTEAM_CHANGED_ANGLE)
	READENTITY_COORD(angles[2], EVSTEAM_CHANGED_ANGLE)
	READENTITY_BYTE(m_bState, EVSTEAM_CHANGED_STATE)
	READENTITY_BYTE(m_bEmissive, EVSTEAM_CHANGED_TYPE)
	READENTITY_BYTE(m_bType, EVSTEAM_CHANGED_TYPE)
	READENTITY_FLOAT(m_flSpread, EVSTEAM_CHANGED_SPREAD)
	READENTITY_FLOAT(m_flSpeed, EVSTEAM_CHANGED_SPEED)
	READENTITY_FLOAT(m_flStartSize, EVSTEAM_CHANGED_MINS)
	READENTITY_FLOAT(m_flEndSize , EVSTEAM_CHANGED_MAXS)
	READENTITY_FLOAT(m_flRate, EVSTEAM_CHANGED_RATE)
	READENTITY_COLOR(m_vecColor[0], EVSTEAM_CHANGED_COLOR)
	READENTITY_COLOR(m_vecColor[1], EVSTEAM_CHANGED_COLOR)
	READENTITY_COLOR(m_vecColor[2], EVSTEAM_CHANGED_COLOR)
	READENTITY_FLOAT(m_flLength, EVSTEAM_CHANGED_LENGTH)
	READENTITY_FLOAT(m_flAlpha, EVSTEAM_CHANGED_ALPHA)
	READENTITY_FLOAT(m_flRollSpeed, EVSTEAM_CHANGED_ROLL)

	//print(sprintf("R (%x): %v %v %i\n", flChanged, origin, m_vecEndPos, m_iActive));

	drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
	setorigin(this, origin);
}

float
env_steam::predraw(void)
{
	vector vecPlayer = g_view.GetCameraOrigin();

	if (checkpvs(vecPlayer, this) == FALSE)
		return (PREDRAW_NEXT);

	if (m_flNexTime > time)
		return (PREDRAW_NEXT);

	env_steam_particle cloud = spawn(env_steam_particle);
	setorigin(cloud, origin);
	cloud.m_bEmissive = m_bEmissive;
	cloud.m_bType = m_bType;
	cloud.m_vecColor = m_vecColor;
	cloud.m_flAlpha = m_flAlpha;
	cloud.m_flStartSize = m_flStartSize;
	cloud.m_flEndSize = m_flEndSize;
	cloud.m_flLifeTime = m_flLength / m_flSpeed;
	cloud.movetype = MOVETYPE_FLY;
	makevectors(angles);
	cloud.velocity = v_forward * m_flSpeed;
	cloud.velocity += v_right * ((random() - 0.5) * m_flSpread);
	cloud.velocity += v_up * ((random() - 0.5) * m_flSpread);

	m_flNexTime = time + (1/m_flRate);

	addentity(self);
	return (PREDRAW_NEXT);
}
#endif