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
	EVRAIN_CHANGED_ORIGIN,
	EVRAIN_CHANGED_ANGLES,
	EVRAIN_CHANGED_SIZE,
	EVRAIN_CHANGED_SPEED,
	EVRAIN_CHANGED_COLOR,
	EVRAIN_CHANGED_BRIGHTNESS,
	EVRAIN_CHANGED_MODEL,
	EVRAIN_CHANGED_RATE,
	EVRAIN_CHANGED_COUNT,
	EVRAIN_CHANGED_AXIS,
	EVRAIN_CHANGED_STATE
};

/*! \brief Shared-Entity: Rain Emitting Volume */
/*!QUAKED env_rain (1 .5 0) ? START_OFF
# OVERVIEW
Environmental rain fall volume entity.

# KEYS
- "targetname" : Name

- "m_dripspeed" : Default is "40".
- "m_dripsize" : Default is "5".
- "rendercolor" : Drip rendercolor. Default is "64 128 255"
- "m_brightness" : Drop brightness, from 0-255. Default is "128"
- "m_burstSize" : Drips per emit-frame. Default is "2".
- "m_flMaxUpdateTime": Max random count. If 0, equals 1.
- "m_flUpdateTime": Min delay between updates.
- "texture" : Drip sprite. Default is "sprites/rain.spr"
- "target" : Trigger on emit-frame. 
- "m_axis" : Beam direction. 0 - down/up, 1 - X axis, 2 = Y axis.

## UNUSED KEYS
- "m_iExtent" : Volume emitting types? Currently not respected.
- "m_iNoise" : Unused? Default is "0".
- "m_fLifeTime" : Unused? Default is "0".

# SPAWNFLAGS
- START_OFF (1) : When set, will have to be triggered to rain.

# TRIVIA
This entity was introduced in Spirit of Half-Life (2001).

@ingroup sharedentity
@ingroup brushentity
*/
class
env_rain:ncBrushTrigger
{
#ifdef SERVER
	bool m_bInitialState;
#endif

#ifdef CLIENT
	float m_flNexTime;
	float m_rainParticleID;
#endif

	PREDICTED_VECTOR_N(absmin)
	PREDICTED_VECTOR_N(absmax)

	PREDICTED_FLOAT(m_rainModel)
	PREDICTED_FLOAT(m_rainSpeed)
	PREDICTED_FLOAT(m_rainSize)
	PREDICTED_VECTOR(m_rainColor)
	PREDICTED_FLOAT(m_rainBrightness)
	PREDICTED_INT(m_rainCount)
	PREDICTED_FLOAT(m_rainMaxEmitDelay)
	PREDICTED_INT(m_rainAxis)
	PREDICTED_BOOL(m_rainEnabled)

	void env_rain(void);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string strKey, string setValue);
	virtual void Respawn(void);
	virtual void Input(entity, string, string);
	virtual void Trigger(entity, triggermode_t);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
	virtual float predraw(void);
#endif
};

void
env_rain::env_rain(void)
{
#ifdef SERVER
	m_rainEnabled = false;
	m_rainMaxEmitDelay = 0.5f;
#endif
}

#ifdef SERVER
void
env_rain::Save(float handle)
{
	super::Save(handle);
	SaveBool(handle, "m_rainEnabled", m_rainEnabled);
	SaveFloat(handle, "m_rainMaxEmitDelay", m_rainMaxEmitDelay);
}

void
env_rain::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_rainEnabled":
		 m_rainEnabled = ReadBool(setValue);
		break;
	case "m_rainMaxEmitDelay":
		 m_rainMaxEmitDelay = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_rain::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flMaxUpdateTime":
		m_rainMaxEmitDelay = stof(setValue);
		break;
	case "texture":
		m_rainModel = getmodelindex(setValue);
		break;

	case "m_dripspeed":
		m_rainSpeed = ReadFloat(setValue);
		break;
	case "m_dripsize":
		m_rainSize = ReadFloat(setValue);
		break;
	case "rendercolor":
		m_rainColor = ReadVector(setValue);
		break;
	case "m_brightness":
		m_rainBrightness = ReadFloat(setValue);
		break;
	case "m_burstSize":
		m_rainCount = ReadInt(setValue);
		break;
	case "m_axis":
		m_rainAxis = ReadInt(setValue);
		break;

	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
env_rain::Input(entity eAct, string strInput, string strData)
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
	case "Rate":
		m_rainMaxEmitDelay = stof(strData);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
env_rain::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_rainEnabled = false;
		break;
	case TRIG_ON:
		m_rainEnabled = true;
		break;
	default:
		m_rainEnabled = (m_rainEnabled == true) ? false : true;
	}
}

void
env_rain::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetModel(GetSpawnString("model"));
	SetOrigin(GetSpawnVector("origin"));	
	m_rainEnabled = true;
	particleeffectnum("fx_rain.main");
}

void
env_rain::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, EVRAIN_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, EVRAIN_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, EVRAIN_CHANGED_ORIGIN)
	EVALUATE_VECTOR(angles, 0, EVRAIN_CHANGED_ANGLES)
	EVALUATE_VECTOR(angles, 1, EVRAIN_CHANGED_ANGLES)
	EVALUATE_VECTOR(angles, 2, EVRAIN_CHANGED_ANGLES)
	EVALUATE_VECTOR(absmin, 0, EVRAIN_CHANGED_SIZE)
	EVALUATE_VECTOR(absmin, 1, EVRAIN_CHANGED_SIZE)
	EVALUATE_VECTOR(absmin, 2, EVRAIN_CHANGED_SIZE)
	EVALUATE_VECTOR(absmax, 0, EVRAIN_CHANGED_SIZE)
	EVALUATE_VECTOR(absmax, 1, EVRAIN_CHANGED_SIZE)
	EVALUATE_VECTOR(absmax, 2, EVRAIN_CHANGED_SIZE)

	EVALUATE_FIELD(m_rainModel, EVRAIN_CHANGED_MODEL)
	EVALUATE_FIELD(m_rainSpeed, EVRAIN_CHANGED_SPEED)
	EVALUATE_FIELD(m_rainSize, EVRAIN_CHANGED_SIZE)
	EVALUATE_FIELD(m_rainColor, EVRAIN_CHANGED_COLOR)
	EVALUATE_FIELD(m_rainBrightness, EVRAIN_CHANGED_BRIGHTNESS)
	EVALUATE_FIELD(m_rainCount, EVRAIN_CHANGED_COUNT)
	EVALUATE_FIELD(m_rainMaxEmitDelay, EVRAIN_CHANGED_RATE)
	EVALUATE_FIELD(m_rainAxis, EVRAIN_CHANGED_AXIS)
	EVALUATE_FIELD(m_rainEnabled, EVRAIN_CHANGED_STATE)
}

float
env_rain::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_RAIN);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], EVRAIN_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], EVRAIN_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], EVRAIN_CHANGED_ORIGIN)
	SENDENTITY_COORD(angles[0], EVRAIN_CHANGED_ANGLES)
	SENDENTITY_COORD(angles[1], EVRAIN_CHANGED_ANGLES)
	SENDENTITY_COORD(angles[2], EVRAIN_CHANGED_ANGLES)
	SENDENTITY_COORD(absmin[0], EVRAIN_CHANGED_SIZE)
	SENDENTITY_COORD(absmin[1], EVRAIN_CHANGED_SIZE)
	SENDENTITY_COORD(absmin[2], EVRAIN_CHANGED_SIZE)
	SENDENTITY_COORD(absmax[0], EVRAIN_CHANGED_SIZE)
	SENDENTITY_COORD(absmax[1], EVRAIN_CHANGED_SIZE)
	SENDENTITY_COORD(absmax[2], EVRAIN_CHANGED_SIZE)

	SENDENTITY_MODELINDEX(m_rainModel, EVRAIN_CHANGED_MODEL)
	SENDENTITY_FLOAT(m_rainSpeed, EVRAIN_CHANGED_SPEED)
	SENDENTITY_FLOAT(m_rainSize, EVRAIN_CHANGED_SIZE)
	SENDENTITY_BYTE(m_rainColor[0], EVRAIN_CHANGED_COLOR)
	SENDENTITY_BYTE(m_rainColor[1], EVRAIN_CHANGED_COLOR)
	SENDENTITY_BYTE(m_rainColor[2], EVRAIN_CHANGED_COLOR)
	SENDENTITY_BYTE(m_rainBrightness, EVRAIN_CHANGED_BRIGHTNESS)
	SENDENTITY_INT(m_rainCount, EVRAIN_CHANGED_COUNT)
	SENDENTITY_FLOAT(m_rainMaxEmitDelay, EVRAIN_CHANGED_RATE)
	SENDENTITY_INT(m_rainAxis, EVRAIN_CHANGED_AXIS)
	SENDENTITY_BYTE(m_rainEnabled, EVRAIN_CHANGED_STATE)

	//print(sprintf("S (%x): %v %v %i\n", flChanged, origin, m_vecEndPos, m_iActive));

	return (1);
}
#endif

#ifdef CLIENT
void
env_rain::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], EVRAIN_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], EVRAIN_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], EVRAIN_CHANGED_ORIGIN)
	READENTITY_COORD(angles[0], EVRAIN_CHANGED_ANGLES)
	READENTITY_COORD(angles[1], EVRAIN_CHANGED_ANGLES)
	READENTITY_COORD(angles[2], EVRAIN_CHANGED_ANGLES)
	READENTITY_COORD(absmin[0], EVRAIN_CHANGED_SIZE)
	READENTITY_COORD(absmin[1], EVRAIN_CHANGED_SIZE)
	READENTITY_COORD(absmin[2], EVRAIN_CHANGED_SIZE)
	READENTITY_COORD(absmax[0], EVRAIN_CHANGED_SIZE)
	READENTITY_COORD(absmax[1], EVRAIN_CHANGED_SIZE)
	READENTITY_COORD(absmax[2], EVRAIN_CHANGED_SIZE)

	READENTITY_MODELINDEX(m_rainModel, EVRAIN_CHANGED_MODEL)
	READENTITY_FLOAT(m_rainSpeed, EVRAIN_CHANGED_SPEED)
	READENTITY_FLOAT(m_rainSize, EVRAIN_CHANGED_SIZE)
	READENTITY_BYTE(m_rainColor[0], EVRAIN_CHANGED_COLOR)
	READENTITY_BYTE(m_rainColor[1], EVRAIN_CHANGED_COLOR)
	READENTITY_BYTE(m_rainColor[2], EVRAIN_CHANGED_COLOR)
	READENTITY_BYTE(m_rainBrightness, EVRAIN_CHANGED_BRIGHTNESS)
	READENTITY_INT(m_rainCount, EVRAIN_CHANGED_COUNT)
	READENTITY_FLOAT(m_rainMaxEmitDelay, EVRAIN_CHANGED_RATE)
	READENTITY_INT(m_rainAxis, EVRAIN_CHANGED_AXIS)
	READENTITY_BYTE(m_rainEnabled, EVRAIN_CHANGED_STATE)

	drawmask = MASK_ENGINE;
	mins = absmin;
	maxs = absmax;
	Relink();
	
	m_rainParticleID = particleeffectnum("fx_rain.main");
}

float
env_rain::predraw(void)
{
	if (m_flNexTime > time)
		return (PREDRAW_NEXT);

	/* emit rain drop in volume here */

	if (m_rainMaxEmitDelay)
		m_flNexTime = time + random(0, m_rainMaxEmitDelay);
	else
		m_flNexTime = time + random();

#if 0
	for (int i = 0; i < m_rainCount; i++) {
		vector rainPos;
		vector rainVelocity;
		
		switch (m_rainAxis) {
		case 0i:
			rainPos[0] = mins[0] + (random() * (maxs[0] - mins[0]));
			rainPos[1] = mins[1] + (random() * (maxs[1] - mins[1]));
			rainPos[2] = absmax[2];
			rainVelocity = [0, 0, -m_rainSpeed];
			break;
		case 1i:
			rainPos[0] = absmax[0];
			rainPos[1] = mins[1] + (random() * (maxs[1] - mins[1]));
			rainPos[2] = mins[2] + (random() * (maxs[2] - mins[2]));
			rainVelocity = [-m_rainSpeed, 0, 0];
			break;
		case 2i:
			rainPos[0] = mins[0] + (random() * (maxs[0] - mins[0]));
			rainPos[1] = absmax[1];
			rainPos[2] = mins[2] + (random() * (maxs[2] - mins[2]));
			rainVelocity = [0, -m_rainSpeed, 0];
			break;
		}

		//printf("(%d) Emit rain at %v\n", num_for_edict(this), vecPos);
		ncRenderableEntity gib = spawn(ncRenderableEntity);
		gib.SetModelindex(m_rainModel);
		gib.SetRenderColor(m_rainColor);
		gib.SetRenderAmt(m_rainBrightness);
		gib.SetRenderMode(RM_ADDITIVE);
		gib.SetOrigin(rainPos);
		gib.SetMovetype(MOVETYPE_BOUNCE);
		gib.SetVelocity(rainVelocity);
		gib.SetSolid(SOLID_NOT);
		gib.SetSize([1,1,-54], [1,1,0]);
		gib.touch = Destroy;
		gib.ScheduleThink(Destroy, 3.0f);
	}
#else
	for (int i = 0; i < m_rainCount; i++) {
		vector vecPos;
		vecPos[0] = mins[0] + (random() * (maxs[0] - mins[0]));
		vecPos[1] = mins[1] + (random() * (maxs[1] - mins[1]));
		vecPos[2] = maxs[2] - 8;
		//printf("(%d) Emit rain at %v\n", num_for_edict(this), vecPos);
		pointparticles(particleeffectnum("fx_rain.main"), vecPos, anglesToForward(angles) * m_rainSpeed, 1);
	}
#endif

	addentity(self);
	return (PREDRAW_NEXT);
}
#endif
