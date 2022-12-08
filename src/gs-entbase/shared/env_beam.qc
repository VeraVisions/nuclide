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

/*QUAKED env_beam (1 0 0) (-8 -8 -8) (8 8 8) BEAM_STARTON BEAM_TOGGLE BEAM_RANDOMSTRIKE BEAM_RING BEAM_STARTSPARKS BEAM_ENDSPARKS BEAM_DECAL BEAM_SHADESTART BEAM_SHADEEND
This entity is incomplete. Purely stub.

-------- KEYS --------
"targetname" : Name
"LightningStart" : Targetname of the entity that acts as starting point for the beam.
"LightningEnd"   : Targetname of the entity that acts as an ending point for the beam.
"Radius"         : If either start/end point is undefined, it'll pick the nearest surface
                   in this specified radius as start/end points.
"life"           : Lifetime of the beam in seconds.
"StrikeTime"     : Time in seconds before the beam reactivates.
"damage"         : Damage per second that's dealt when touching the inner beam.

-------- SPAWNFLAGS --------
BEAM_STARTON : Activate the beam at map start.
BEAM_TOGGLE : Beam can now be toggled off, else StrikeTime + life keys take over.
BEAM_RANDOMSTRIKE : Use variations in StrikeTime + life keys when set.
BEAM_RING : TODO: Instead of a beam, two points will connect into a ring.
BEAM_STARTSPARKS : TODO: Start of the beam will spark when set.
BEAM_ENDSPARKS :  TODO: End of the beam will spark when set.
BEAM_DECAL : TODO: Presumably leaves decals when sparks hit a surface.
BEAM_SHADESTART : TODO: Beam will fade towards the start point when set.
BEAM_SHADEEND : TODO: Beam will fade towards the end point when set.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	BEAM_CHANGED_ORIGIN,
	BEAM_CHANGED_STARTPOS_X,
	BEAM_CHANGED_STARTPOS_Y,
	BEAM_CHANGED_STARTPOS_Z,
	BEAM_CHANGED_ENDPOS_X,
	BEAM_CHANGED_ENDPOS_Y,
	BEAM_CHANGED_ENDPOS_Z,
	BEAM_CHANGED_ACTIVE
};

enumflags
{
	BEAM_STARTON,
	BEAM_TOGGLE,
	BEAM_RANDOMSTRIKE,
	BEAM_RING,
	BEAM_STARTSPARKS,
	BEAM_ENDSPARKS,
	BEAM_DECAL,
	BEAM_SHADESTART,
	BEAM_SHADEEND
};

class
env_beam:NSEntity
{
public:
	void env_beam(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Trigger(entity,int);
	nonvirtual void CastLaser(void);
	nonvirtual void LaunchBeam(void);
	nonvirtual void EndBeam(void);
	nonvirtual void StopBeam(void);
#else
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
#endif

private:
	PREDICTED_VECTOR(m_vecStartPos)
	PREDICTED_VECTOR(m_vecEndPos)
	PREDICTED_INT(m_iActive)

#ifdef SERVER
	string m_strStartEnt;
	string m_strEndEnt;
	float m_flRadius;
	float m_flLifeTime;
	float m_flStrikeTime;
	float m_iDamage;
#endif
};

void
env_beam::env_beam(void)
{
#ifdef SERVER
	m_strStartEnt = __NULL__;
	m_strEndEnt = __NULL__;
	m_flRadius = 0.0f;
	m_flLifeTime = 0.0f;
	m_flStrikeTime = 0.0f;
	m_iDamage = 0i;
#endif
}

#ifdef SERVER
void
env_beam::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());
	m_iValue = 0;

	if (HasSpawnFlags(BEAM_STARTON))
		Trigger(this, TRIG_ON);
}

void
env_beam::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "LightningStart":
		m_strStartEnt = ReadString(strValue);
		break;
	case "LightningEnd":
		m_strEndEnt = ReadString(strValue);
		break;
	case "Radius":
		m_flRadius = ReadFloat(strValue);
		break;
	case "life":
		m_flLifeTime = ReadFloat(strValue);
		break;
	case "StrikeTime":
		m_flStrikeTime = ReadFloat(strValue);
		break;
	case "damage":
		m_iDamage = ReadInt(strValue);
		break;
	default:
		super::SpawnKey(strValue, strKey);
	}
}

void
env_beam::CastLaser(void)
{
	traceline(m_vecStartPos, m_vecEndPos, MOVE_NORMAL, this);

	if (trace_fraction >= 1.0)
		return;

	if (trace_ent.takedamage == DAMAGE_NO)
		return;

	Damage_Apply(trace_ent, this, m_iDamage, 0, DMG_ELECTRO);
}

/* called first */
void
env_beam::LaunchBeam(void)
{
	float lifetime;

	m_iActive = 1i; /* beam is now active */

	/* attack when desired */
	if (m_iDamage > 0)
		CastLaser();

	/* if it's set to be toggle, we will forget about timers altogether */
	if (HasSpawnFlags(BEAM_TOGGLE))
		return;

	/* if we have a specific life time set */
	if (m_flLifeTime)
		lifetime = m_flLifeTime;
	else if (m_flStrikeTime) /* else, we'll just have to take the strike time */
		lifetime = m_flStrikeTime;

	/* if lifetime is less or equal to 0, it's an infinite beam */
	if (lifetime <= 0.0f)
		return;

	if (HasSpawnFlags(BEAM_RANDOMSTRIKE))
		lifetime *= random();

	ScheduleThink(EndBeam, lifetime);
}

/* called second */
void
env_beam::EndBeam(void)
{
	float striketime;

	m_iActive = 0i; /* beam is now active */
	striketime = m_flStrikeTime;

	/* if the strike time is less or equal to 0, don't replay it */
	if (striketime <= 0.0f)
		return;

	/* odd behaviour: don't re-strike if we have no life-time set? */
	if (m_flLifeTime <= 0.0f)
		return;

	if (HasSpawnFlags(BEAM_RANDOMSTRIKE))
		striketime *= random();

	ScheduleThink(LaunchBeam, striketime);
}

/* kill the beam under any circumstances. */
void
env_beam::StopBeam(void)
{
	m_iActive = 0i; /* beam is now active */
	ReleaseThink();
}

void
env_beam::Trigger(entity act, int state)
{
	/* if toggle isn't enabled, it can only ever get activated */
	if (HasSpawnFlags(BEAM_TOGGLE) == false) {
		m_iValue = 1;
	} else {
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
	}

	/* either launch a whole new beam, or kill it entirely */
	if (m_iValue)
		LaunchBeam();
	else
		StopBeam();
}

void
env_beam::EvaluateEntity(void)
{
	entity eFind;

	/* only bother updating our start/end pos if we're running */
	if (m_iActive) {
		m_vecStartPos = origin;
		m_vecEndPos = origin;

		/* Get updated positions */
		if (m_strStartEnt) {
			eFind = find(world, ::targetname, m_strStartEnt);

			if (eFind) {
				m_vecStartPos = eFind.origin;
			} else {
				m_vecStartPos = NearestWallPointForRadius(m_flRadius);
			}
		} else {
			m_vecStartPos = NearestWallPointForRadius(m_flRadius);
		}

		if (m_strEndEnt) {
			eFind = find(world, ::targetname, m_strEndEnt);

			if (eFind) {
				m_vecEndPos = eFind.origin;
			} else {
				m_vecEndPos = NearestWallPointForRadius(m_flRadius);
			}
		} else {
			m_vecEndPos = NearestWallPointForRadius(m_flRadius);
		}
	}

	EVALUATE_VECTOR(m_vecStartPos, 0, BEAM_CHANGED_STARTPOS_X)
	EVALUATE_VECTOR(m_vecStartPos, 1, BEAM_CHANGED_STARTPOS_Y)
	EVALUATE_VECTOR(m_vecStartPos, 2, BEAM_CHANGED_STARTPOS_Z)

	EVALUATE_VECTOR(m_vecEndPos, 0, BEAM_CHANGED_ENDPOS_X)
	EVALUATE_VECTOR(m_vecEndPos, 1, BEAM_CHANGED_ENDPOS_Y)
	EVALUATE_VECTOR(m_vecEndPos, 2, BEAM_CHANGED_ENDPOS_Z)

	EVALUATE_FIELD(m_iActive, BEAM_CHANGED_ACTIVE)
}

float
env_beam::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_BEAM);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(m_vecStartPos[0], BEAM_CHANGED_STARTPOS_X)
	SENDENTITY_COORD(m_vecStartPos[1], BEAM_CHANGED_STARTPOS_Y)
	SENDENTITY_COORD(m_vecStartPos[2], BEAM_CHANGED_STARTPOS_Z)
	SENDENTITY_COORD(m_vecEndPos[0], BEAM_CHANGED_ENDPOS_X)
	SENDENTITY_COORD(m_vecEndPos[1], BEAM_CHANGED_ENDPOS_Y)
	SENDENTITY_COORD(m_vecEndPos[2], BEAM_CHANGED_ENDPOS_Z)
	SENDENTITY_BYTE(m_iActive, BEAM_CHANGED_ACTIVE)

	//print(sprintf("S (%x): %v %v %i\n", flChanged, m_vecStartPos, m_vecEndPos, m_iActive));

	return (1);
}
#else
void
env_beam::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(m_vecStartPos[0], BEAM_CHANGED_STARTPOS_X)
	READENTITY_COORD(m_vecStartPos[1], BEAM_CHANGED_STARTPOS_Y)
	READENTITY_COORD(m_vecStartPos[2], BEAM_CHANGED_STARTPOS_Z)
	READENTITY_COORD(m_vecEndPos[0], BEAM_CHANGED_ENDPOS_X)
	READENTITY_COORD(m_vecEndPos[1], BEAM_CHANGED_ENDPOS_Y)
	READENTITY_COORD(m_vecEndPos[2], BEAM_CHANGED_ENDPOS_Z)
	READENTITY_BYTE(m_iActive, BEAM_CHANGED_ACTIVE)

	//print(sprintf("R (%x): %v %v %i\n", flChanged, m_vecStartPos, m_vecEndPos, m_iActive));

	drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
	setorigin(this, m_vecStartPos);
}

float
env_beam::predraw(void)
{
	/* only draw when active. */
	if (!m_iActive)
		return;

	/* primitive representation */
	R_BeginPolygon("", 0, 0);
		R_PolygonVertex(m_vecStartPos, [0,1], [0,1,0], 1.0f);
		R_PolygonVertex(m_vecEndPos, [1,1], [0,1,0], 1.0f);
	R_EndPolygon();

	return (PREDRAW_NEXT);
}
#endif

#ifdef CLIENT
void
env_beam_ReadEntity(float isnew)
{
	env_beam beam = (env_beam)self;
	float changedflags = readfloat();

	if (isnew)
		spawnfunc_env_beam();

	beam.ReceiveEntity(isnew, changedflags);
}
#endif