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
	BEAM_CHANGED_SPRITE,
	BEAM_CHANGED_STARTPOS_X,
	BEAM_CHANGED_STARTPOS_Y,
	BEAM_CHANGED_STARTPOS_Z,
	BEAM_CHANGED_ENDPOS_X,
	BEAM_CHANGED_ENDPOS_Y,
	BEAM_CHANGED_ENDPOS_Z,
	BEAM_CHANGED_ACTIVE,
	BEAM_CHANGED_FLAGS,
	BEAM_CHANGED_COLOR,
	BEAM_CHANGED_WIDTH,
	BEAM_CHANGED_AMPLITUDE
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

/*! \brief Shared-Entity: Beam/Lightning Emitter */
/*!QUAKED env_beam (1 .5 0) (-8 -8 -8) (8 8 8) BEAM_STARTON BEAM_TOGGLE BEAM_RANDOMSTRIKE BEAM_RING BEAM_STARTSPARKS BEAM_ENDSPARKS BEAM_DECAL BEAM_SHADESTART BEAM_SHADEEND
# OVERVIEW
Controllable beam effect, akin to lightning. Also known as env_lightning.

# KEYS
- "targetname" : Name
- "LightningStart" : Targetname of the entity that acts as starting point for the beam.
- "LightningEnd"   : Targetname of the entity that acts as an ending point for the beam.
- "Radius"         : If either start/end point is undefined, it'll pick the nearest surface
                     in this specified radius as start/end points.
- "life"           : Lifetime of the beam in seconds.
- "StrikeTime"     : Time in seconds before the beam reactivates.
- "damage"         : Damage per second that's dealt when touching the inner beam.
- "texture"        : Path to the sprite to use in place of a texture.
- "BoltWidth"      : Thickness multiplier. 0-255 range.
- "NoiseAmplitude" : Amplitude multiplier. 0-255 range.

# SPAWNFLAGS
- BEAM_STARTON (1) : Activate the beam at map start.
- BEAM_TOGGLE (2) : Beam can now be toggled off, else StrikeTime + life keys take over.
- BEAM_RANDOMSTRIKE (4) : Use variations in StrikeTime + life keys when set.
- BEAM_RING (8) : Instead of a beam, two points will connect into a ring.
- BEAM_STARTSPARKS (16) : TODO: Start of the beam will spark when set.
- BEAM_ENDSPARKS (32) :  TODO: End of the beam will spark when set.
- BEAM_DECAL (64) : TODO: Presumably leaves decals when sparks hit a surface.
- BEAM_SHADESTART (128) : Beam will fade towards the start point when set.
- BEAM_SHADEEND (256) : Beam will fade towards the end point when set.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup shared
@ingroup pointentity
*/
class
env_beam:NSRenderableEntity
{
public:
	void env_beam(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Trigger(entity, triggermode_t);
	nonvirtual void CastLaser(void);
	nonvirtual void LaunchBeam(void);
	nonvirtual void EndBeam(void);
	nonvirtual void StopBeam(void);
#else
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
	virtual void RendererRestarted(void);
#endif

private:
	PREDICTED_VECTOR(m_vecStartPos)
	PREDICTED_VECTOR(m_vecEndPos)
	PREDICTED_INT(m_iActive)
	PREDICTED_INT(m_iBeamFlags)
	PREDICTED_FLOAT(m_flBeamWidth)
	PREDICTED_FLOAT(m_flAmplitude)

	/* visual fluff */
	string m_strTexture;
	PREDICTED_INT(m_iSpriteID)

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
	m_iBeamFlags = 0i;

	m_strTexture = __NULL__;
	m_flBeamWidth = 0.0f;
#endif
}

#ifdef SERVER
void
env_beam::Respawn(void)
{
	super::Respawn();

	SetSize([0,0,0], [0,0,0]);
	m_iValue = 0;

	/* force us to precache the sprite model... and get a modelindex back */
	m_iSpriteID = getmodelindex(m_strTexture, false);

	if (HasSpawnFlags(BEAM_STARTON))
		Trigger(this, TRIG_ON);

	/* keep it simple */
	m_iBeamFlags = spawnflags | BEAM_SHADEEND;
	pvsflags = PVSF_IGNOREPVS;
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
	case "texture":
		m_strTexture = ReadString(strValue);
		break;
	case "BoltWidth":
		m_flBeamWidth = ReadFloat(strValue);
		break;
	case "NoiseAmplitude":
		m_flAmplitude = ReadFloat(strValue);
		break;
	case "rendercolor":
		m_vecRenderColor = ReadVector(strValue);
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

	vector center = WorldSpaceCenter();
	string dmgDef = sprintf("\"damage\" \"%i\"\n\"type\" \"electro\"", m_iDamage);
	entityDamage(trace_ent, this, trace_ent, dmgDef, "", center, g_vec_null, trace_ent.origin);
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

	/* if lifetime is less or equal to 0, it's an infinite beam */
	if (m_flLifeTime <= 0.0f)
		return;

	/* if we have a specific life time set */
	lifetime = m_flLifeTime;

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
env_beam::Trigger(entity act, triggermode_t state)
{
	/* if toggle isn't enabled, it can only ever get activated */
	if (m_flLifeTime > 0 && HasSpawnFlags(BEAM_TOGGLE) == false) {
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

	EVALUATE_FIELD(m_iSpriteID, BEAM_CHANGED_SPRITE)
	EVALUATE_VECTOR(m_vecStartPos, 0, BEAM_CHANGED_STARTPOS_X)
	EVALUATE_VECTOR(m_vecStartPos, 1, BEAM_CHANGED_STARTPOS_Y)
	EVALUATE_VECTOR(m_vecStartPos, 2, BEAM_CHANGED_STARTPOS_Z)
	EVALUATE_VECTOR(m_vecEndPos, 0, BEAM_CHANGED_ENDPOS_X)
	EVALUATE_VECTOR(m_vecEndPos, 1, BEAM_CHANGED_ENDPOS_Y)
	EVALUATE_VECTOR(m_vecEndPos, 2, BEAM_CHANGED_ENDPOS_Z)
	EVALUATE_FIELD(m_iActive, BEAM_CHANGED_ACTIVE)
	EVALUATE_FIELD(m_iBeamFlags, BEAM_CHANGED_FLAGS)
	EVALUATE_VECTOR(m_vecRenderColor, 0, BEAM_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, BEAM_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, BEAM_CHANGED_COLOR)
	EVALUATE_FIELD(m_flBeamWidth, BEAM_CHANGED_WIDTH)
	EVALUATE_FIELD(m_flAmplitude, BEAM_CHANGED_AMPLITUDE)
}

float
env_beam::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_BEAM);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_INT(m_iSpriteID, BEAM_CHANGED_SPRITE)
	SENDENTITY_COORD(m_vecStartPos[0], BEAM_CHANGED_STARTPOS_X)
	SENDENTITY_COORD(m_vecStartPos[1], BEAM_CHANGED_STARTPOS_Y)
	SENDENTITY_COORD(m_vecStartPos[2], BEAM_CHANGED_STARTPOS_Z)
	SENDENTITY_COORD(m_vecEndPos[0], BEAM_CHANGED_ENDPOS_X)
	SENDENTITY_COORD(m_vecEndPos[1], BEAM_CHANGED_ENDPOS_Y)
	SENDENTITY_COORD(m_vecEndPos[2], BEAM_CHANGED_ENDPOS_Z)
	SENDENTITY_BYTE(m_iActive, BEAM_CHANGED_ACTIVE)
	SENDENTITY_BYTE(m_iBeamFlags, BEAM_CHANGED_FLAGS)
	SENDENTITY_BYTE(m_vecRenderColor[0], BEAM_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecRenderColor[1], BEAM_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecRenderColor[2], BEAM_CHANGED_COLOR)
	SENDENTITY_BYTE(m_flBeamWidth, BEAM_CHANGED_WIDTH)
	SENDENTITY_BYTE(m_flAmplitude, BEAM_CHANGED_AMPLITUDE)

	//print(sprintf("S (%x): %v %v %i\n", flChanged, m_vecStartPos, m_vecEndPos, m_iActive));

	return (1);
}
#else
void
env_beam::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_INT(m_iSpriteID, BEAM_CHANGED_SPRITE)
	READENTITY_COORD(m_vecStartPos[0], BEAM_CHANGED_STARTPOS_X)
	READENTITY_COORD(m_vecStartPos[1], BEAM_CHANGED_STARTPOS_Y)
	READENTITY_COORD(m_vecStartPos[2], BEAM_CHANGED_STARTPOS_Z)
	READENTITY_COORD(m_vecEndPos[0], BEAM_CHANGED_ENDPOS_X)
	READENTITY_COORD(m_vecEndPos[1], BEAM_CHANGED_ENDPOS_Y)
	READENTITY_COORD(m_vecEndPos[2], BEAM_CHANGED_ENDPOS_Z)
	READENTITY_BYTE(m_iActive, BEAM_CHANGED_ACTIVE)
	READENTITY_BYTE(m_iBeamFlags, BEAM_CHANGED_FLAGS)
	READENTITY_BYTE(m_vecRenderColor[0], BEAM_CHANGED_COLOR)
	READENTITY_BYTE(m_vecRenderColor[1], BEAM_CHANGED_COLOR)
	READENTITY_BYTE(m_vecRenderColor[2], BEAM_CHANGED_COLOR)
	READENTITY_BYTE(m_flBeamWidth, BEAM_CHANGED_WIDTH)
	READENTITY_BYTE(m_flAmplitude, BEAM_CHANGED_AMPLITUDE)

	//print(sprintf("R (%x): %v %v %i\n", flChanged, m_vecStartPos, m_vecEndPos, m_iActive));

	drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
	origin = m_vecStartPos;

	/* the sprite has changed, we need to query a new texture */
	if (flChanged & BEAM_CHANGED_SPRITE) {
		RendererRestarted();
	}
}

void
env_beam::RendererRestarted(void)
{
	m_strTexture = spriteframe(modelnameforindex(m_iSpriteID), 0, 0.0f);
}

#define BEAM_COUNT 16
float
pseudorand(float input)
{
	float seed = (float)input % 5.0f;
	seed += (float)input % 8.0f;
	seed += (float)input % 4.0f;
	seed += (float)input % 13.0f;
	seed += (float)input % 70.0f;

	/* like the engine its random(), never return 0, never return 1 */
	return bound(0.01, (seed) / 100.0f, 0.99f);
}

static float env_beam_jitlut[BEAM_COUNT] = {
	0.000000,
	0.195090,
	0.382683,
	0.555570,
	0.707106,
	0.831469,
	0.923879,
	0.980785,
	1.000000,
	0.980786,
	0.923880,
	0.831471,
	0.707108,
	0.555572,
	0.382685,
	0.000000,
};

float
env_beam::predraw(void)
{
	vector vecPlayer;
	vecPlayer = g_view.GetCameraOrigin();

	/* only draw when active. */
	if (!m_iActive)
		return (PREDRAW_NEXT);

	if (autocvar(r_skipBeams, 0))
		return (PREDRAW_NEXT);

	/* primitive representation */
#if 0
	R_BeginPolygon("", 0, 0);
		R_PolygonVertex(m_vecStartPos, [0,1], [0,1,0], 1.0f);
		R_PolygonVertex(m_vecEndPos, [1,1], [0,1,0], 1.0f);
	R_EndPolygon();
#endif

	if (m_strTexture) {
		float last_progression = 0.0f;
		makevectors(g_view.GetCameraAngle());
		setproperty(VF_ORIGIN, vecPlayer);
		R_BeginPolygon(m_strTexture, DRAWFLAG_ADDITIVE, 0);

		for (float i = 0; i < BEAM_COUNT; i++) {
			float progression = (i / (BEAM_COUNT-1));
			vector point;
			vector jitter;
			float a = 1.0f;

			/* our steps from a - b */
			if (m_iBeamFlags & BEAM_RING) {
				vector center = m_vecStartPos - (m_vecStartPos - m_vecEndPos) * 0.5f;
				float length = vlen(m_vecStartPos - m_vecEndPos) * 0.5;

				float theta = 2.0f * M_PI * (i / (BEAM_COUNT-1));
				vector p = [sin(theta), cos(theta)] * length;

				point = center + p;
			} else {
				point = vectorLerp(m_vecStartPos, m_vecEndPos, progression);
			}

			/* get the direction the beam is 'looking' */
			makevectors(vectoangles(m_vecEndPos - m_vecStartPos));

			/* nudge it a lil bit up/down left/right from its trajectory */
			/* these are all randomly chosen constants */
			jitter = v_right * (pseudorand((4 * time) + i + entnum) - 0.5);
			jitter += v_up * (pseudorand((4 * time) + i + 64.12 + entnum) - 0.5);
			jitter += v_right * (pseudorand(100 + (8 * time) + i + entnum) - 0.5);
			jitter += v_up * (pseudorand(100 + (8 * time) + i + 25.4 + entnum) - 0.5);
			jitter *= m_flAmplitude;

			/* start/end points get less jittery the closer we get*/
			jitter *= env_beam_jitlut[i];

			/* apply jitter */
			point += jitter;

			/* fading flag stuff */
			if ((i == 0 && m_iBeamFlags & BEAM_SHADESTART) || 
				(i == BEAM_COUNT && m_iBeamFlags & BEAM_SHADEEND))
				a = 0.0f;

			R_PolygonVertex(point, [1, 0], m_vecRenderColor / 255, a);

			if (autocvar(cl_showoff, 0))
				dynamiclight_add(point, 150, m_vecRenderColor/255);

			last_progression = progression;
		}

		R_EndPolygonRibbon(m_flBeamWidth/8, [-1,0]);
	}

	return (PREDRAW_NEXT);
}
#endif