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

#define PSFL_STARTACTIVE 1
#warning needs Save/Restore

enumflags
{
	PARTSYSFL_CHANGED_ORIGIN,
	PARTSYSFL_CHANGED_ANGLES,
	PARTSYSFL_CHANGED_EFFECT,
	PARTSYSFL_CHANGED_STATUS,
	PARTSYSFL_CHANGED_INTERVAL,
	PARTSYSFL_CHANGED_COUNT
};

/*! \brief Shared-Entity: Particle Emitter */
/*!QUAKED info_particle_system (1 0 0) (-8 -8 -8) (8 8 8) PSFL_STARTACTIVE
# OVERVIEW
An entity that's spawns particles from the engine's particle system.

# KEYS
- "targetname" : Name
- "effect_name" : Name of the particle effect to spawn
- "start_active" : Whether or not the entity needs to be triggered first
- "interval" : Override for spawn intervals.
- "spawncount" : Override for the amount of particles that will be emitted

# INPUTS
- "Start" : Starts the emitter.
- "Stop" : Stops the emitter.
- "Toggle" : Toggles the emitter from an on/off state.

# TRIVIA
This entity was introduced in The Orange Box (2007).

@ingroup sharedentity
@ingroup pointentity
*/
class info_particle_system:ncPointTrigger
{
public:
	void info_particle_system(void);

#ifdef CLIENT
	virtual void Emit(void);
	virtual void ReceiveEntity(float,float);
#endif

#ifdef SERVER
	virtual void Respawn(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void SpawnKey(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
#endif

private:

#ifdef CLIENT
	int m_emitterFXID;
#endif

	int m_emitterState;
	string m_emitterFXName;
	float m_emitterInterval;
	int m_emitterCount;
};

#ifdef CLIENT
void
info_particle_system::Emit(void)
{
	makevectors(angles);

	if (m_emitterState)
	if (m_emitterCount)
		pointparticles((float)m_emitterFXID, origin, v_forward, m_emitterCount);
	else
		pointparticles((float)m_emitterFXID, origin, v_forward, 1);

	nextthink = time + m_emitterInterval;
}

void
info_particle_system::ReceiveEntity(float flNew, float flFlags)
{
	if (flFlags & PARTSYSFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}

	if (flFlags & PARTSYSFL_CHANGED_ANGLES) {
		angles[0] = readfloat();
		angles[1] = readfloat();
		angles[2] = readfloat();
	}

	if (flFlags & PARTSYSFL_CHANGED_EFFECT) {
		m_emitterFXName = readstring();
		m_emitterFXID = particleeffectnum(m_emitterFXName);
	}

	if (flFlags & PARTSYSFL_CHANGED_STATUS) {
		m_emitterState = readbyte();
	}

	if (flFlags & PARTSYSFL_CHANGED_INTERVAL) {
		m_emitterInterval = readfloat();
		nextthink = time + m_emitterInterval;
	}

	if (flFlags & PARTSYSFL_CHANGED_COUNT)
		m_emitterCount = readbyte();

	classname = "info_particle_system";

	setorigin(this, origin);
	setsize(this, mins, maxs);
}
#endif

#ifdef SERVER
float
info_particle_system::SendEntity(entity ePEnt, float flFlags)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_PARTSYSTEM);
	WriteFloat(MSG_ENTITY, flFlags);

	if (flFlags & PARTSYSFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (flFlags & PARTSYSFL_CHANGED_ANGLES) {
		WriteFloat(MSG_ENTITY, angles[0]);
		WriteFloat(MSG_ENTITY, angles[1]);
		WriteFloat(MSG_ENTITY, angles[2]);
	}

	if (flFlags & PARTSYSFL_CHANGED_EFFECT)
		WriteString(MSG_ENTITY, m_emitterFXName);

	if (flFlags & PARTSYSFL_CHANGED_STATUS)
		WriteByte(MSG_ENTITY, m_emitterState);

	if (flFlags & PARTSYSFL_CHANGED_INTERVAL)
		WriteFloat(MSG_ENTITY, m_emitterInterval);

	if (flFlags & PARTSYSFL_CHANGED_COUNT)
		WriteByte(MSG_ENTITY, m_emitterCount);

	return (1);
}

void
info_particle_system::EvaluateEntity(void)
{
	if (ATTR_CHANGED(origin)) {
		SetSendFlags(PARTSYSFL_CHANGED_ORIGIN);
	}

	if (ATTR_CHANGED(angles)) {
		SetSendFlags(PARTSYSFL_CHANGED_ANGLES);
	}

	SAVE_STATE(origin)
	SAVE_STATE(angles)
}

void
info_particle_system::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_emitterState = 0;
		break;
	case TRIG_ON:
		m_emitterState = 1;
		break;
	default:
		m_emitterState = 1 - m_emitterState;
	}

	SendFlags |= PARTSYSFL_CHANGED_STATUS;
}

void
info_particle_system::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Start":
		Trigger(eAct, TRIG_ON);
		break;
	case "Stop":
		Trigger(eAct, TRIG_OFF);
		break;
	/* out of spec */
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
info_particle_system::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "effect_name":
		m_emitterFXName = setValue;
		break;
	case "start_active":
		spawnflags |= stoi(setValue);
		break;
	/* out of spec */
	case "interval":
		m_emitterInterval = stof(setValue);
		break;
	case "spawncount":
		m_emitterCount = stoi(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
info_particle_system::Respawn(void)
{
	super::Respawn();

	SetSolid(SOLID_NOT);
	SetSize([-16,-16,-16], [16,16,16]);

	if (HasSpawnFlags(PSFL_STARTACTIVE)) {
		Trigger(this, TRIG_ON);
	} else {
		Trigger(this, TRIG_OFF);
	}
}
#endif

void
info_particle_system::info_particle_system(void)
{
	angles = [90, 0, 0]; /* default pointing up! */

#ifdef CLIENT
	drawmask = MASK_ENGINE;
	think = Emit;
#endif
}
