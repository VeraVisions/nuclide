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
	ENVFIRE_INFINITE,
	ENVFIRE_SMOKELESS,
	ENVFIRE_STARTON,
	ENVFIRE_STARTFULL,
	ENVFIRE_NODROP,
	ENVFIRE_NOGLOW,
	ENVFIRE_UNUSED,
	ENVFIRE_DELETE,
	ENVFIRE_TOPVISIBLE
};

/*!QUAKED env_fire (1 .5 0) (-8 -8 -8) (8 8 8) INFINITE_DURATION SMOKELESS STARTON STARTFULL NODROP NOGLOW x DELETE TOPVISIBLE
# OVERVIEW
Environmental fire/flame entity. Will apply damage to entities, including other fire entities. They grow/shrink depending on their ignition level.

# KEYS
- "targetname" : Name
- "health" : Duration, in seconds.
- "firesize" : Size of the fire in world units.
- "fireattack" : Time in seconds until the fire has fully expanded.
- "firetype" : Type of fire. 0 - Standard, 1 - Plasma
- "ignitionpoint" : Amount of fire damage it takes before igniting fully.
- "damagescale" : Burn damage multiplier.

# SPAWNFLAGS
- INFINITE_DURATION (1) : Don't extinguish by itself.
- SMOKELESS (2) : Don't spawn smoke.
- STARTON (4) : Starts enabled.
- STARTFULL (8) : Starts expanded.
- NODROP (16) : Don't drop to floor (?)
- NOGLOW (32) : Don't glow.
- DELETE (128) : Delete from game when extinguished.
- TOPVISIBLE (256) : Visible from above.

# INPUTS
- "StartFire" : Starts the fire effect.
- "Extinguish" : Puts out the fire, with an optional timer (in seconds).
- "ExtinguishTemporary" : Puts out the fire (temporarily).

# OUTPUTS
- "OnIgnited" : Triggered when the fire ignites.
- "OnExtinguished" : Triggered when the fire is extinguished.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class
env_fire:NSPointTrigger
{
public:
	void env_fire(void);

#ifdef SERVER
	virtual void SpawnKey(string strKey, string strValue);
#endif

private:
	PREDICTED_FLOAT(m_flSize)
	PREDICTED_BOOL(m_bState)
	PREDICTED_FLOAT m_flMaxSize)
	PREDICTED_FLOATm_flGrowTime)
	PREDICTED_BOOL(m_bType)
	float m_flIgnitionPoint;
	float m_flDamageScale;
	float m_flDuration;
};

void
env_fire::env_fire(void)
{
	m_flDuration = 30.0f;
	m_flSize = 64.0;
	m_flGrowTime = 4.0f;
	m_bType = false;
	m_flIgnitionPoint = 32.0f;
	m_flDamageScale = 1.0f;
}

#ifdef SERVER
void
env_fire::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "health":
		m_flDuration = stof(strValue);
		break;
	case "firesize":
		m_flSize = stof(strValue);
		break;
	case "fireattack":
		m_flGrowTime = stof(strValue);
		break;
	case "firetype":
		m_bType = stof(strValue);
		break;
	case "ignitionpoint":
		m_flIgnitionPoint = stof(strValue);
		break;
	case "damagescale":
		m_flDamageScale = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_fire::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());
}

void
env_fire::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, EVFIRE_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, EVFIRE_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, EVFIRE_CHANGED_ORIGIN)
	EVALUATE_VECTOR(angles, 0, EVFIRE_CHANGED_ANGLE)
	EVALUATE_VECTOR(angles, 1, EVFIRE_CHANGED_ANGLE)
	EVALUATE_VECTOR(angles, 2, EVFIRE_CHANGED_ANGLE)
	EVALUATE_FIELD(m_flDuration, EVFIRE_CHANGED_DURATION)
	EVALUATE_FIELD(m_flMaxSize, EVFIRE_CHANGED_SIZE)
	EVALUATE_FIELD(m_flGrowTime, EVFIRE_CHANGED_GROW)
	EVALUATE_FIELD(m_bType, EVFIRE_CHANGED_TYPE)
}

float
env_fire::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_STEAM);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], EVFIRE_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], EVFIRE_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], EVFIRE_CHANGED_ORIGIN)
	SENDENTITY_COORD(angles[0], EVFIRE_CHANGED_ANGLE)
	SENDENTITY_COORD(angles[1], EVFIRE_CHANGED_ANGLE)
	SENDENTITY_COORD(angles[2], EVFIRE_CHANGED_ANGLE)
	SENDENTITY_BYTE(m_bState, EVFIRE_CHANGED_STATE)
	SENDENTITY_BYTE(m_bType, EVFIRE_CHANGED_TYPE)
	SENDENTITY_FLOAT(m_flSpread, EVFIRE_CHANGED_SPREAD)
	SENDENTITY_FLOAT(m_flSpeed, EVFIRE_CHANGED_SPEED)
	SENDENTITY_FLOAT(m_flStartSize, EVFIRE_CHANGED_MINS)
	SENDENTITY_FLOAT(m_flEndSize , EVFIRE_CHANGED_MAXS)
	SENDENTITY_FLOAT(m_flRate, EVFIRE_CHANGED_RATE)
	SENDENTITY_COLOR(m_vecColor[0], EVFIRE_CHANGED_COLOR)
	SENDENTITY_COLOR(m_vecColor[1], EVFIRE_CHANGED_COLOR)
	SENDENTITY_COLOR(m_vecColor[2], EVFIRE_CHANGED_COLOR)
	SENDENTITY_FLOAT(m_flLength, EVFIRE_CHANGED_LENGTH)
	SENDENTITY_FLOAT(m_flAlpha, EVFIRE_CHANGED_ALPHA)
	SENDENTITY_FLOAT(m_flRollSpeed, EVFIRE_CHANGED_ROLL)

	//print(sprintf("S (%x): %v %v %i\n", flChanged, origin, m_vecEndPos, m_iActive));

	return (1);
}
#else
void
env_fire::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], EVFIRE_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], EVFIRE_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], EVFIRE_CHANGED_ORIGIN)
	READENTITY_COORD(angles[0], EVFIRE_CHANGED_ANGLE)
	READENTITY_COORD(angles[1], EVFIRE_CHANGED_ANGLE)
	READENTITY_COORD(angles[2], EVFIRE_CHANGED_ANGLE)
	READENTITY_BYTE(m_bState, EVFIRE_CHANGED_STATE)
	READENTITY_BYTE(m_bType, EVFIRE_CHANGED_TYPE)
	READENTITY_FLOAT(m_flSpread, EVFIRE_CHANGED_SPREAD)
	READENTITY_FLOAT(m_flSpeed, EVFIRE_CHANGED_SPEED)
	READENTITY_FLOAT(m_flStartSize, EVFIRE_CHANGED_MINS)
	READENTITY_FLOAT(m_flEndSize , EVFIRE_CHANGED_MAXS)
	READENTITY_FLOAT(m_flRate, EVFIRE_CHANGED_RATE)
	READENTITY_COLOR(m_vecColor[0], EVFIRE_CHANGED_COLOR)
	READENTITY_COLOR(m_vecColor[1], EVFIRE_CHANGED_COLOR)
	READENTITY_COLOR(m_vecColor[2], EVFIRE_CHANGED_COLOR)
	READENTITY_FLOAT(m_flLength, EVFIRE_CHANGED_LENGTH)
	READENTITY_FLOAT(m_flAlpha, EVFIRE_CHANGED_ALPHA)
	READENTITY_FLOAT(m_flRollSpeed, EVFIRE_CHANGED_ROLL)

	//print(sprintf("R (%x): %v %v %i\n", flChanged, origin, m_vecEndPos, m_iActive));

	//drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
	setorigin(this, origin);
}
#endif