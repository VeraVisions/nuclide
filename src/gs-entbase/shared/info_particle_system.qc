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

/*QUAKED info_particle_system (1 0 0) (-8 -8 -8) (8 8 8) PSFL_STARTACTIVE
An entity that's spawns particles from the engine's particle system.

-------- KEYS --------
"targetname" : Name
"effect_name" : Name of the particle effect to spawn
"start_active" : Whether or not the entity needs to be triggered first
"interval" : Override for spawn intervals.
"spawncount" : Override for the amount of particles that will be emitted

-------- INPUTS --------
"Start" : Starts the emitter.
"Stop" : Stops the emitter.
"Toggle" : Toggles the emitter from an on/off state.

-------- TRIVIA --------
This entity was introduced in The Orange Box (2007).
*/

#define PSFL_STARTACTIVE 1

enumflags
{
	PARTSYSFL_CHANGED_ORIGIN,
	PARTSYSFL_CHANGED_ANGLES,
	PARTSYSFL_CHANGED_EFFECT,
	PARTSYSFL_CHANGED_STATUS,
	PARTSYSFL_CHANGED_INTERVAL,
	PARTSYSFL_CHANGED_COUNT
};

class info_particle_system:NSPointTrigger
{
private:
#ifdef CLIENT
	int m_iValue;
	int m_iEffectID;
#endif
	string m_strEffectName;
	float m_flInterval;
	int m_iSpawnCount;

public:
	void info_particle_system(void);

#ifdef CLIENT
	virtual void Emit(void);
	virtual void ReceiveEntity(float,float);
#else
	virtual void Respawn(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void SpawnKey(string,string);
	virtual void Trigger(entity,int);
	virtual void Input(entity, string, string);
#endif
};

#ifdef CLIENT
void
info_particle_system::Emit(void)
{
	makevectors(angles);

	if (m_iValue)
	if (m_iSpawnCount)
		pointparticles((float)m_iEffectID, origin, v_forward, m_iSpawnCount);
	else
		pointparticles((float)m_iEffectID, origin, v_forward, 1);

	nextthink = time + m_flInterval;
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
		m_strEffectName = readstring();
		m_iEffectID = particleeffectnum(m_strEffectName);
	}

	if (flFlags & PARTSYSFL_CHANGED_STATUS) {
		m_iValue = readbyte();
	}

	if (flFlags & PARTSYSFL_CHANGED_INTERVAL) {
		m_flInterval = readfloat();
		nextthink = time + m_flInterval;
	}

	if (flFlags & PARTSYSFL_CHANGED_COUNT)
		m_iSpawnCount = readbyte();

	classname = "info_particle_system";

	setorigin(this, origin);
	setsize(this, mins, maxs);
}
#else
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
		WriteString(MSG_ENTITY, m_strEffectName);

	if (flFlags & PARTSYSFL_CHANGED_STATUS)
		WriteByte(MSG_ENTITY, m_iValue);

	if (flFlags & PARTSYSFL_CHANGED_INTERVAL)
		WriteFloat(MSG_ENTITY, m_flInterval);

	if (flFlags & PARTSYSFL_CHANGED_COUNT)
		WriteByte(MSG_ENTITY, m_iSpawnCount);

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

	SAVE_STATE(origin);
	SAVE_STATE(angles);
}

void
info_particle_system::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		m_iValue = 0;
		break;
	case TRIG_ON:
		m_iValue = 1;
		break;
	default:
		m_iValue = 1 - m_iValue;
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
info_particle_system::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "effect_name":
		m_strEffectName = strValue;
		break;
	case "start_active":
		spawnflags |= stoi(strValue);
		break;
	/* out of spec */
	case "interval":
		m_flInterval = stof(strValue);
		break;
	case "spawncount":
		m_iSpawnCount = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
info_particle_system::Respawn(void)
{
	SetSolid(SOLID_NOT);
	SetSize([-16,-16,-16], [16,16,16]);
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());

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
