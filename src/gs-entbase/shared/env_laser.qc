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
	LASER_CHANGED_SPRITE,
	LASER_CHANGED_STARTPOS_X,
	LASER_CHANGED_STARTPOS_Y,
	LASER_CHANGED_STARTPOS_Z,
	LASER_CHANGED_ENDPOS_X,
	LASER_CHANGED_ENDPOS_Y,
	LASER_CHANGED_ENDPOS_Z,
	LASER_CHANGED_ACTIVE,
	LASER_CHANGED_FLAGS,
	LASER_CHANGED_COLOR,
	LASER_CHANGED_WIDTH,
	LASER_CHANGED_AMPLITUDE
};

enumflags
{
	LASER_STARTON,
	LASER_UNUSED1,
	LASER_UNUSED2,
	LASER_UNUSED3,
	LASER_STARTSPARKS,
	LASER_ENDSPARKS,
	LASER_DECAL
};

/*! \brief Shared-Entity: Laser Emitter */
/*!QUAKED env_laser (1 .5 0) (-8 -8 -8) (8 8 8) LASER_STARTON x x x LASER_STARTSPARKS LASER_ENDSPARKS LASER_DECAL
# OVERVIEW
Controllable laser effect. More or less a stripped-down version of env_beam.

# KEYS
- "targetname"     : Name
- "LaserTarget"    : Targetname of the entity that acts as end point for the laser.
- "damage"         : Damage per second that's dealt when touching the inner laser.
- "texture"        : Path to the sprite to use in place of a texture.
- "BoltWidth"      : Thickness multiplier. 0-255 range.
- "NoiseAmplitude" : Amplitude multiplier. 0-255 range.

# SPAWNFLAGS
- LASER_STARTON (1) : Activate the laser at map start.
- LASER_STARTSPARKS (16) :Start of the laser will spark when set.
- LASER_ENDSPARKS (32) : End of the laser will spark when set.
- LASER_DECAL (64) : TODO: Presumably leaves decals when sparks hit a surface.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup shared
@ingroup pointentity
*/
class
env_laser:NSRenderableEntity
{
public:
	void env_laser(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Trigger(entity, triggermode_t);
	nonvirtual void CastLaser(void);
#else
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
	virtual void RendererRestarted(void);
#endif

private:
	PREDICTED_VECTOR(m_vecEndPos)
	PREDICTED_INT(m_iActive)
	PREDICTED_INT(m_iBeamFlags)
	PREDICTED_FLOAT(m_flBeamWidth)
	PREDICTED_FLOAT(m_flAmplitude)

	/* visual fluff */
	string m_strTexture;
	PREDICTED_INT(m_iSpriteID)

#ifdef SERVER
	string m_strEndEnt;
	float m_iDamage;
	float m_flTraceTime;
#else
	float m_flSparkTime;
#endif
};

void
env_laser::env_laser(void)
{
#ifdef SERVER
	m_strEndEnt = __NULL__;
	m_iDamage = 0i;
	m_iBeamFlags = 0i;

	m_strTexture = __NULL__;
	m_flBeamWidth = 4.0f;
#else
	m_flSparkTime = 0.0f;
#endif
}

#ifdef SERVER
void
env_laser::Respawn(void)
{
	super::Respawn();

	SetSize([0,0,0], [0,0,0]);
	m_iValue = 0;

	/* force us to precache the sprite model... and get a modelindex back */
	m_iSpriteID = getmodelindex(m_strTexture, false);

	if (HasSpawnFlags(LASER_STARTON))
		Trigger(this, TRIG_ON);

	/* keep it simple */
	m_iBeamFlags = spawnflags;
}

void
env_laser::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "LaserTarget":
		m_strEndEnt = ReadString(strValue);
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
env_laser::CastLaser(void)
{
	traceline(origin, m_vecEndPos, MOVE_NORMAL, this);

	if (trace_fraction >= 1.0)
		return;

	if (trace_ent.takedamage == DAMAGE_NO)
		return;

	vector center = WorldSpaceCenter();
	string dmgDef = sprintf("\"damage\" \"%i\"\n\"type\" \"electro\"", m_iDamage);
	entityDamage(trace_ent, this, trace_ent, dmgDef, "", center, g_vec_null, trace_ent.origin);
	m_flTraceTime = time + 1.0f;
}

void
env_laser::Trigger(entity act, triggermode_t state)
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

	m_iActive = m_iValue;
}

void
env_laser::EvaluateEntity(void)
{
	entity eFind;

	/* only bother updating our start/end pos if we're running */
	if (m_iActive) {
		m_vecEndPos = origin;

		if (m_strEndEnt) {
			eFind = find(world, ::targetname, m_strEndEnt);

			if (eFind) {
				m_vecEndPos = eFind.origin;
			}
		}
	}

	if (m_flTraceTime < time) {
		CastLaser();
	}

	traceline(origin, m_vecEndPos, MOVE_NORMAL, this);
	m_vecEndPos = trace_endpos;

	EVALUATE_FIELD(m_iSpriteID, LASER_CHANGED_SPRITE)
	EVALUATE_VECTOR(origin, 0, LASER_CHANGED_STARTPOS_X)
	EVALUATE_VECTOR(origin, 1, LASER_CHANGED_STARTPOS_Y)
	EVALUATE_VECTOR(origin, 2, LASER_CHANGED_STARTPOS_Z)
	EVALUATE_VECTOR(m_vecEndPos, 0, LASER_CHANGED_ENDPOS_X)
	EVALUATE_VECTOR(m_vecEndPos, 1, LASER_CHANGED_ENDPOS_Y)
	EVALUATE_VECTOR(m_vecEndPos, 2, LASER_CHANGED_ENDPOS_Z)
	EVALUATE_FIELD(m_iActive, LASER_CHANGED_ACTIVE)
	EVALUATE_FIELD(m_iBeamFlags, LASER_CHANGED_FLAGS)
	EVALUATE_VECTOR(m_vecRenderColor, 0, LASER_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, LASER_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, LASER_CHANGED_COLOR)
	EVALUATE_FIELD(m_flBeamWidth, LASER_CHANGED_WIDTH)
	EVALUATE_FIELD(m_flAmplitude, LASER_CHANGED_AMPLITUDE)
}

float
env_laser::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_LASER);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_INT(m_iSpriteID, LASER_CHANGED_SPRITE)
	SENDENTITY_COORD(origin[0], LASER_CHANGED_STARTPOS_X)
	SENDENTITY_COORD(origin[1], LASER_CHANGED_STARTPOS_Y)
	SENDENTITY_COORD(origin[2], LASER_CHANGED_STARTPOS_Z)
	SENDENTITY_COORD(m_vecEndPos[0], LASER_CHANGED_ENDPOS_X)
	SENDENTITY_COORD(m_vecEndPos[1], LASER_CHANGED_ENDPOS_Y)
	SENDENTITY_COORD(m_vecEndPos[2], LASER_CHANGED_ENDPOS_Z)
	SENDENTITY_BYTE(m_iActive, LASER_CHANGED_ACTIVE)
	SENDENTITY_BYTE(m_iBeamFlags, LASER_CHANGED_FLAGS)
	SENDENTITY_BYTE(m_vecRenderColor[0], LASER_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecRenderColor[1], LASER_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecRenderColor[2], LASER_CHANGED_COLOR)
	SENDENTITY_BYTE(m_flBeamWidth, LASER_CHANGED_WIDTH)
	SENDENTITY_BYTE(m_flAmplitude, LASER_CHANGED_AMPLITUDE)

	//print(sprintf("S (%x): %v %v %i\n", flChanged, origin, m_vecEndPos, m_iActive));

	return (1);
}
#else
void
env_laser::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_INT(m_iSpriteID, LASER_CHANGED_SPRITE)
	READENTITY_COORD(origin[0], LASER_CHANGED_STARTPOS_X)
	READENTITY_COORD(origin[1], LASER_CHANGED_STARTPOS_Y)
	READENTITY_COORD(origin[2], LASER_CHANGED_STARTPOS_Z)
	READENTITY_COORD(m_vecEndPos[0], LASER_CHANGED_ENDPOS_X)
	READENTITY_COORD(m_vecEndPos[1], LASER_CHANGED_ENDPOS_Y)
	READENTITY_COORD(m_vecEndPos[2], LASER_CHANGED_ENDPOS_Z)
	READENTITY_BYTE(m_iActive, LASER_CHANGED_ACTIVE)
	READENTITY_BYTE(m_iBeamFlags, LASER_CHANGED_FLAGS)
	READENTITY_BYTE(m_vecRenderColor[0], LASER_CHANGED_COLOR)
	READENTITY_BYTE(m_vecRenderColor[1], LASER_CHANGED_COLOR)
	READENTITY_BYTE(m_vecRenderColor[2], LASER_CHANGED_COLOR)
	READENTITY_BYTE(m_flBeamWidth, LASER_CHANGED_WIDTH)
	READENTITY_BYTE(m_flAmplitude, LASER_CHANGED_AMPLITUDE)

	//print(sprintf("R (%x): %v %v %i\n", flChanged, origin, m_vecEndPos, m_iActive));

	drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
	setorigin(this, origin);

	/* the sprite has changed, we need to query a new texture */
	if (flChanged & LASER_CHANGED_SPRITE) {
		RendererRestarted();
	}
}

void
env_laser::RendererRestarted(void)
{
	m_strTexture = spriteframe(modelnameforindex(m_iSpriteID), 0, 0.0f);
}

#define LASER_COUNT 16

static float env_laser_jitlut[LASER_COUNT] = {
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
env_laser::predraw(void)
{
	vector vecPlayer;
	NSClientPlayer pl;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	pl = (NSClientPlayer)pSeat->m_ePlayer;
	vecPlayer = pl.GetEyePos();

	/* only draw when active. */
	if (!m_iActive)
		return (PREDRAW_NEXT);

	if (autocvar(r_skipBeams, 0))
		return (PREDRAW_NEXT);

	/* primitive representation */
#if 0
	R_BeginPolygon("", 0, 0);
		R_PolygonVertex(origin, [0,1], [0,1,0], 1.0f);
		R_PolygonVertex(m_vecEndPos, [1,1], [0,1,0], 1.0f);
	R_EndPolygon();
#endif

	if (m_strTexture) {
		float last_progression = 0.0f;
		makevectors(g_view.GetCameraAngle());
		setproperty(VF_ORIGIN, vecPlayer);
		R_BeginPolygon(m_strTexture, DRAWFLAG_ADDITIVE, 0);

		for (float i = 0; i < LASER_COUNT; i++) {
			float progression = (i / (LASER_COUNT-1));
			vector point;
			vector jitter;
			float a = 1.0f;

			/* our steps from a - b */
			point = vectorLerp(origin, m_vecEndPos, progression);

			/* get the direction the laser is 'looking' */
			makevectors(vectoangles(m_vecEndPos - origin));

			/* nudge it a lil bit up/down left/right from its trajectory */
			/* these are all randomly chosen constants */
			jitter = v_right * (pseudorand((4 * time) + i + entnum) - 0.5);
			jitter += v_up * (pseudorand((4 * time) + i + 64.12 + entnum) - 0.5);
			jitter += v_right * (pseudorand(100 + (8 * time) + i + entnum) - 0.5);
			jitter += v_up * (pseudorand(100 + (8 * time) + i + 25.4 + entnum) - 0.5);
			jitter *= m_flAmplitude;

			/* start/end points get less jittery the closer we get*/
			jitter *= env_laser_jitlut[i];

			/* apply jitter */
			point += jitter;

			R_PolygonVertex(point, [1, 0], m_vecRenderColor / 255, a);

			if (autocvar(cl_showoff, 0))
				dynamiclight_add(point, 150, m_vecRenderColor/255);

			last_progression = progression;
		}

		R_EndPolygonRibbon(m_flBeamWidth/8, [-1,0]);
	}

	if (m_flSparkTime > time)
		return (PREDRAW_NEXT);

	if (m_iBeamFlags & (LASER_STARTSPARKS)) {
		vector dir = vectoangles(origin - m_vecEndPos);
		makevectors(dir);
		pointparticles(particleeffectnum("fx.spark"), origin, -v_forward, 1);
	}

	if (m_iBeamFlags & (LASER_ENDSPARKS)) {
		vector dir2 = vectoangles(m_vecEndPos - origin);

		makevectors(dir2);
		pointparticles(particleeffectnum("fx.spark"), m_vecEndPos, -v_forward, 1);
	}

	m_flSparkTime = time + 0.25f;

	return (PREDRAW_NEXT);
}
#endif