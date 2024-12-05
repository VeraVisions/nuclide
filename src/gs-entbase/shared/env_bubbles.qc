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
	BUBBLES_ORIGIN,
	BUBBLES_ANGLES,
	BUBBLES_DENSITY,
	BUBBLES_FREQUENCY,
	BUBBLES_CURRENT,
	BUBBLES_ENABLED
};

#define BUBFL_STARTOFF 1

/*! \brief Shared-Entity: Bubble Emitter */
/*!QUAKED env_bubbles (1 .5 0) ? BUBFL_STARTOFF
# OVERVIEW
Brush volume that emits rising bubbles.

# KEYS
- "targetname" : Name
- "density"    : Bubble count when it's emitting
- "frequency"  : Emitting frequency in seconds
- "angles"     : Direction of water current
- "current"    : Speed of the water current

# SPAWNFLAGS
- BUBFL_STARTOFF (1) : Start disabled.

# INPUTS
- "Activate"     : Turns the entity on
- "Deactive"     : Turns the entity off
- "Toggle"       : Toggles the entity to an on/off state
- "SetDensity"   : Sets the bubble count when it's emitting
- "SetFrequency" : Sets the emitting frequency in seconds
- "SetCurrent"   : Sets the speed of the water current

# NOTES
The bubbles emit will pick a random place in the volume (although always at the bottom)
and rise up in varying speeds. This means you can only place vertical bubble emitters.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup sharedentity
@ingroup brushentity
*/
class
env_bubbles:ncPointTrigger
{
public:
	void env_bubbles(void);

	/* overrides */
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Spawned(void);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity,string,string);
#endif

#ifdef CLIENT
	virtual void EmitBubbles(void);
	virtual void ReceiveEntity(float,float);
#endif

private:
	PREDICTED_INT(m_iDensity)
	PREDICTED_FLOAT(m_flFrequency)
	PREDICTED_FLOAT(m_flCurrent)
	PREDICTED_BOOL(m_bEnabled)

	/* spawn values */
	int m_iSpawnDensity;
	float m_flSpawnFrequency;
	float m_flSpawnCurrent;
};

void
env_bubbles::env_bubbles(void)
{
}

#ifdef SERVER
void
env_bubbles::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iDensity", m_iDensity);
	SaveFloat(handle, "m_flFrequency", m_flFrequency);
	SaveFloat(handle, "m_flCurrent", m_flCurrent);
	SaveBool(handle, "m_bEnabled", m_bEnabled);

	SaveInt(handle, "m_iSpawnDensity", m_iSpawnDensity);
	SaveFloat(handle, "m_flSpawnFrequency", m_flSpawnFrequency);
	SaveFloat(handle, "m_flSpawnCurrent", m_flSpawnCurrent);
}

void
env_bubbles::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iDensity":
		m_iDensity = ReadInt(strValue);
		break;
	case "m_flFrequency":
		m_flFrequency = ReadFloat(strValue);
		break;
	case "m_flCurrent":
		m_flCurrent = ReadFloat(strValue);
		break;
	case "m_bEnabled":
		m_bEnabled = ReadBool(strValue);
		break;
	case "m_iSpawnDensity":
		m_iSpawnDensity = ReadInt(strValue);
		break;
	case "m_flSpawnFrequency":
		m_flSpawnFrequency = ReadFloat(strValue);
		break;
	case "m_flSpawnCurrent":
		m_flSpawnCurrent = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_bubbles::Input(entity eAct, string strKey, string strData)
{
	switch (strKey) {
	case "Activate":
		Trigger(eAct, TRIG_ON);
		break;
	case "Deactivate":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "SetDensity":
		m_iDensity = stoi(strData);
		break;
	case "SetFrequency":
		m_flSpawnFrequency = stof(strData);
		break;
	case "SetCurrent":
		m_flSpawnCurrent = stof(strData);
		break;
	default:
		super::Input(eAct, strKey, strData);
	}
}

void
env_bubbles::Trigger(entity eAct, triggermode_t iState)
{
	switch (iState) {
	case TRIG_OFF:
		m_bEnabled = false;
		break;
	case TRIG_ON:
		m_bEnabled = true;
		break;
	default:
		m_bEnabled = true - m_bEnabled;
	}
}
void
env_bubbles::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, BUBBLES_ORIGIN)
	EVALUATE_VECTOR(origin, 1, BUBBLES_ORIGIN)
	EVALUATE_VECTOR(origin, 2, BUBBLES_ORIGIN)
	EVALUATE_VECTOR(angles, 0, BUBBLES_ANGLES)
	EVALUATE_VECTOR(angles, 1, BUBBLES_ANGLES)
	EVALUATE_VECTOR(angles, 2, BUBBLES_ANGLES)
	EVALUATE_FIELD(m_iDensity, BUBBLES_DENSITY)
	EVALUATE_FIELD(m_flFrequency, BUBBLES_FREQUENCY)
	EVALUATE_FIELD(m_flCurrent, BUBBLES_CURRENT)
	EVALUATE_FIELD(m_bEnabled, BUBBLES_ENABLED)
}
float
env_bubbles::SendEntity(entity ePVSent, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_BUBBLES);
	WriteFloat(MSG_ENTITY, flChanged);

	if (flChanged & BUBBLES_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
		WriteCoord(MSG_ENTITY, mins[0]);
		WriteCoord(MSG_ENTITY, mins[1]);
		WriteCoord(MSG_ENTITY, mins[2]);
		WriteCoord(MSG_ENTITY, maxs[0]);
		WriteCoord(MSG_ENTITY, maxs[1]);
		WriteCoord(MSG_ENTITY, maxs[2]);
	}

	if (flChanged & BUBBLES_ANGLES) {
		WriteCoord(MSG_ENTITY, angles[0]);
		WriteCoord(MSG_ENTITY, angles[1]);
		WriteCoord(MSG_ENTITY, angles[2]);
	}
	
	if (flChanged & BUBBLES_DENSITY)
		WriteByte(MSG_ENTITY, m_iDensity);
	if (flChanged & BUBBLES_FREQUENCY)
		WriteFloat(MSG_ENTITY, m_flFrequency);
	if (flChanged & BUBBLES_CURRENT)
		WriteFloat(MSG_ENTITY, m_flCurrent);
	if (flChanged & BUBBLES_ENABLED)
		WriteByte(MSG_ENTITY, m_bEnabled);

	return (1);
}
#endif

#ifdef CLIENT
void
env_bubbles::EmitBubbles(void)
{
	vector vecPos;

	if (m_bEnabled)
	for (int i = 0; i < m_iDensity; i++) {
		float timer;
		vecPos[0] = mins[0] + (random() * (maxs[0] - mins[0]));
		vecPos[1] = mins[1] + (random() * (maxs[1] - mins[1]));
		vecPos[2] = mins[2];

		env_sprite eBubble = spawn(env_sprite);
		setorigin(eBubble, vecPos);
		setmodel(eBubble, "sprites/bubble.spr");
		eBubble.drawmask = MASK_ENGINE;
		eBubble.SetRenderColor([255,255,255]);
		eBubble.SetRenderMode(RM_ADDITIVE);
		eBubble.SetRenderAmt(255);
		eBubble.SetMovetype(MOVETYPE_FLY);
		eBubble.velocity[2] = 100 + random(0, 50);

		/* apply current */
		if (m_flCurrent > 0) {
			makevectors(eBubble.angles);
			eBubble.velocity *= v_forward * m_flCurrent;
		}

		/* destroy the bubble once it exits out the water */
		timer = (size[2] / eBubble.velocity[2]);
		eBubble.ScheduleThink(Destroy, timer);
	}

	nextthink = time + m_flFrequency;
}

void
env_bubbles::ReceiveEntity(float is_new, float flChanged)
{
	if (flChanged & BUBBLES_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		mins[0] = readcoord();
		mins[1] = readcoord();
		mins[2] = readcoord();
		maxs[0] = readcoord();
		maxs[1] = readcoord();
		maxs[2] = readcoord();
		setsize(this, mins, maxs);
		setorigin(this, origin);
	}

	if (flChanged & BUBBLES_ANGLES) {
		angles[0] = readcoord();
		angles[1] = readcoord();
		angles[2] = readcoord();
	}
	
	if (flChanged & BUBBLES_DENSITY)
		m_iDensity = readbyte();
	if (flChanged & BUBBLES_FREQUENCY)
		m_flFrequency = readfloat();
	if (flChanged & BUBBLES_CURRENT)
		m_flCurrent = readfloat();
	if (flChanged & BUBBLES_ENABLED)
		m_bEnabled = readbyte();

	think = EmitBubbles;
	nextthink = time + m_flFrequency;
}
#endif

void
env_bubbles::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "density":
		m_iSpawnDensity = stoi(strValue);
		break;
	case "frequency":
		m_flSpawnFrequency = stof(strValue);
		break;
	case "current":
		m_flSpawnCurrent = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_bubbles::Respawn(void)
{
	super::Respawn();

	SetSolid(SOLID_NOT);
	m_iDensity = m_iSpawnDensity;
	m_flFrequency = m_flSpawnFrequency;
	m_flCurrent = m_flSpawnCurrent;

	if (spawnflags & BUBFL_STARTOFF)
		m_bEnabled = false;
	else
		m_bEnabled = true;
}

void
env_bubbles::Spawned(void)
{
	super::Spawned();

	precache_model("sprites/bubble.spr");
}
