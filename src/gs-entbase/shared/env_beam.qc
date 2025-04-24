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

@ingroup sharedentity
@ingroup pointentity
*/
class
env_beam:ncRenderableEntity
{
public:
	void env_beam(void);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
	nonvirtual void CastLaser(void);
	nonvirtual void LaunchBeam(void);
	nonvirtual void EndBeam(void);
	nonvirtual void StopBeam(void);
	nonvirtual void FindLocation(void);
#endif

#ifdef CLIENT
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
	virtual void ReloadVideoResources(void);
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
	vector m_vecBeamDir;
	vector m_radiusScale;
	vector m_chosenDest;
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
	m_vecBeamDir = g_vec_null;
	m_radiusScale = [1,1,1];
#endif
}

#ifdef SERVER

void
env_beam::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "LightningStart":
		m_strStartEnt = ReadString(setValue);
		break;
	case "LightningEnd":
		m_strEndEnt = ReadString(setValue);
		break;
	case "Radius":
		m_flRadius = ReadFloat(setValue);
		break;
	case "RadiusScale":
		m_radiusScale = ReadVector(setValue);
		break;
	case "life":
		m_flLifeTime = ReadFloat(setValue);
		break;
	case "StrikeTime":
		m_flStrikeTime = ReadFloat(setValue);
		break;
	case "damage":
		m_iDamage = ReadInt(setValue);
		break;
	case "texture":
		m_strTexture = ReadString(setValue);
		break;
	case "BoltWidth":
		m_flBeamWidth = ReadFloat(setValue);
		break;
	case "NoiseAmplitude":
		m_flAmplitude = ReadFloat(setValue);
		break;
	case "BeamDir":
		m_vecBeamDir = ReadVector(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
env_beam::Respawn(void)
{
	super::Respawn();

	SetSize([0,0,0], [0,0,0]);
	SetValue(0i);

	/* force us to precache the sprite model... and get a modelindex back */
	m_iSpriteID = getmodelindex(m_strTexture, false);

	/* keep it simple */
	m_iBeamFlags = spawnflags | BEAM_SHADEEND;
	pvsflags = PVSF_IGNOREPVS;

	FindLocation();

	if (HasSpawnFlags(BEAM_STARTON))
		Trigger(this, TRIG_ON);
}

void
env_beam::Save(float handle)
{
	super::Save(handle);

	SaveVector(handle, "m_vecStartPos", m_vecStartPos);
	SaveVector(handle, "m_vecEndPos", m_vecEndPos);
	SaveInt(handle, "m_iActive", m_iActive);
	SaveInt(handle, "m_iBeamFlags", m_iBeamFlags);
	SaveFloat(handle, "m_flBeamWidth", m_flBeamWidth);
	SaveFloat(handle, "m_flAmplitude", m_flAmplitude);
	SaveString(handle, "m_strTexture", m_strTexture);

	SaveInt(handle, "m_iSpriteID", m_iSpriteID);
	SaveString(handle, "m_strStartEnt", m_strStartEnt);
	SaveString(handle, "m_strEndEnt", m_strEndEnt);
	SaveFloat(handle, "m_flRadius", m_flRadius);
	SaveFloat(handle, "m_flLifeTime", m_flLifeTime);
	SaveFloat(handle, "m_flStrikeTime", m_flStrikeTime);
	SaveFloat(handle, "m_iDamage", m_iDamage);
	SaveVector(handle, "m_vecBeamDir", m_vecBeamDir);
	SaveVector(handle, "m_radiusScale", m_radiusScale);
	SaveVector(handle, "m_chosenDest", m_chosenDest);

}

void
env_beam::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_vecStartPos":
		m_vecStartPos = ReadVector(setValue);
		break;
	case "m_vecEndPos":
		m_vecEndPos = ReadVector(setValue);
		break;
	case "m_iActive":
		m_iActive = ReadInt(setValue);
		break;
	case "m_iBeamFlags":
		m_iBeamFlags = ReadInt(setValue);
		break;
	case "m_flBeamWidth":
		m_flBeamWidth = ReadFloat(setValue);
		break;
	case "m_flAmplitude":
		m_flAmplitude = ReadFloat(setValue);
		break;
	case "m_strTexture":
		m_strTexture = ReadString(setValue);
		break;
	case "m_iSpriteID":
		m_iSpriteID = ReadInt(setValue);
		break;
	case "m_strStartEnt":
		m_strStartEnt = ReadString(setValue);
		break;
	case "m_strEndEnt":
		m_strEndEnt = ReadString(setValue);
		break;
	case "m_flRadius":
		m_flRadius = ReadFloat(setValue);
		break;
	case "m_flLifeTime":
		m_flLifeTime = ReadFloat(setValue);
		break;
	case "m_flStrikeTime":
		m_flStrikeTime = ReadFloat(setValue);
		break;
	case "m_iDamage":
		m_iDamage = ReadFloat(setValue);
		break;
	case "m_vecBeamDir":
		m_vecBeamDir = ReadVector(setValue);
		break;
	case "m_radiusScale":
		m_radiusScale = ReadVector(setValue);
		break;
	case "m_chosenDest":
		m_chosenDest = ReadVector(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_beam::FindLocation(void)
{
	for (int i = 0; i < 16; i++) {
		vector destVec;
		destVec[0] = (random(-1,1) * 180);
		destVec[1] = (random(-1,1) * 180);
		destVec[2] = (random(-1,1) * 180);
		destVec = anglesToForward(destVec) * m_flRadius;

		traceline(origin, origin + destVec, MOVE_NORMAL, this);

		if (trace_fraction < 1.0f) {
			m_chosenDest = trace_endpos;
			break;
		}
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

	ncSurfacePropEntity targetEnt = (ncSurfacePropEntity)trace_ent;

	ncDict damageDecl = spawn(ncDict);
	damageDecl.AddKey("damage", itos(m_iDamage));
	damageDecl.AddKey("type", "electro");
	targetEnt.Damage(this, this, damageDecl, 1.0, g_vec_null, trace_ent.origin);
	remove(damageDecl);
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

	string placeDecal = GetSpawnString("decal_detonate");

	if (STRING_SET(placeDecal)) {
		DecalGroups_Place(placeDecal, m_chosenDest);
	}

	if (HasSpawnFlags(BEAM_RANDOMSTRIKE))
		lifetime *= random();

	ScheduleThink(EndBeam, lifetime);
}

/* called second */
void
env_beam::EndBeam(void)
{
	float striketime;

	m_iActive = 0i; /* beam is now inactive */
	striketime = m_flStrikeTime;

	if (striketime <= 0.0f)
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
env_beam::Input(entity act, string inputName, string dataString)
{
	switch (inputName) {
	case "StrikeOnce":
		LaunchBeam();
		break;
	default:
		super::Input(act, inputName, dataString);
	}
}

void
env_beam::Trigger(entity act, triggermode_t state)
{
	/* if toggle isn't enabled, it can only ever get activated */
	if (m_flLifeTime > 0 && HasSpawnFlags(BEAM_TOGGLE) == false) {
		SetValue(1i);
	} else {
		switch (state) {
		case TRIG_OFF:
			SetValue(0i);
			break;
		case TRIG_ON:
			SetValue(1i);
			break;
		default:
			SetValue(1i - GetValue(this));
		}
	}

	/* either launch a whole new beam, or kill it entirely */
	if (GetValue(this))
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
		if (!GetParent()) {
			if (STRING_SET(m_strStartEnt)) {
				eFind = find(world, ::targetname, m_strStartEnt);

				if (eFind) {
					m_vecStartPos = eFind.origin;
				} else {
					m_vecStartPos = NearestWallPointForRadius(m_flRadius);
				}
			} else {
				m_vecStartPos = NearestWallPointForRadius(m_flRadius);
			}
		} else {
			m_vecStartPos = gettaginfo(GetParent(), tag_index);
		}

		if (STRING_SET(m_strEndEnt)) {
			eFind = find(world, ::targetname, m_strEndEnt);

			if (eFind) {
				m_vecEndPos = eFind.origin;
			} else {
				m_vecEndPos = NearestWallPointForRadius(m_flRadius);
			}
		} else {
			if (m_vecBeamDir != g_vec_null) {
				m_vecEndPos = anglesToForward(GetAngles()) * m_vecBeamDir[0];
				m_vecEndPos += anglesToRight(GetAngles()) * m_vecBeamDir[1];
				m_vecEndPos += anglesToUp(GetAngles()) * m_vecBeamDir[2];

				traceline(m_vecStartPos, m_vecStartPos + m_vecEndPos, MOVE_NORMAL, this);
				m_vecEndPos = trace_endpos;
			} else {
				FindLocation();
				m_vecEndPos = m_chosenDest;
				//m_vecEndPos = NearestWallPointForRadius(m_flRadius);
			}
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
	EVALUATE_VECTOR(m_renderColor, 0, BEAM_CHANGED_COLOR)
	EVALUATE_VECTOR(m_renderColor, 1, BEAM_CHANGED_COLOR)
	EVALUATE_VECTOR(m_renderColor, 2, BEAM_CHANGED_COLOR)
	EVALUATE_FIELD(m_flBeamWidth, BEAM_CHANGED_WIDTH)
	EVALUATE_FIELD(m_flAmplitude, BEAM_CHANGED_AMPLITUDE)
}

float
env_beam::SendEntity(entity ePEnt, float flChanged)
{
	vector renderColor = GetRenderColor();
	float scaler = m_renderAmount / 255;
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
	SENDENTITY_BYTE(renderColor[0] * scaler, BEAM_CHANGED_COLOR)
	SENDENTITY_BYTE(renderColor[1] * scaler, BEAM_CHANGED_COLOR)
	SENDENTITY_BYTE(renderColor[2] * scaler, BEAM_CHANGED_COLOR)
	SENDENTITY_BYTE(m_flBeamWidth, BEAM_CHANGED_WIDTH)
	SENDENTITY_BYTE(m_flAmplitude, BEAM_CHANGED_AMPLITUDE)

	//print(sprintf("S (%x): %v %v %i\n", flChanged, m_vecStartPos, m_vecEndPos, m_iActive));

	return (1);
}
#endif

#ifdef CLIENT
void
env_beam::ReceiveEntity(float flNew, float flChanged)
{
	vector renderColor = g_vec_null;

	READENTITY_INT(m_iSpriteID, BEAM_CHANGED_SPRITE)
	READENTITY_COORD(m_vecStartPos[0], BEAM_CHANGED_STARTPOS_X)
	READENTITY_COORD(m_vecStartPos[1], BEAM_CHANGED_STARTPOS_Y)
	READENTITY_COORD(m_vecStartPos[2], BEAM_CHANGED_STARTPOS_Z)
	READENTITY_COORD(m_vecEndPos[0], BEAM_CHANGED_ENDPOS_X)
	READENTITY_COORD(m_vecEndPos[1], BEAM_CHANGED_ENDPOS_Y)
	READENTITY_COORD(m_vecEndPos[2], BEAM_CHANGED_ENDPOS_Z)
	READENTITY_BYTE(m_iActive, BEAM_CHANGED_ACTIVE)
	READENTITY_BYTE(m_iBeamFlags, BEAM_CHANGED_FLAGS)
	READENTITY_BYTE(renderColor[0], BEAM_CHANGED_COLOR)
	READENTITY_BYTE(renderColor[1], BEAM_CHANGED_COLOR)
	READENTITY_BYTE(renderColor[2], BEAM_CHANGED_COLOR)
	READENTITY_BYTE(m_flBeamWidth, BEAM_CHANGED_WIDTH)
	READENTITY_BYTE(m_flAmplitude, BEAM_CHANGED_AMPLITUDE)

	//print(sprintf("R (%x): %v %v %i\n", flChanged, m_vecStartPos, m_vecEndPos, m_iActive));

	drawmask = MASK_ENGINE;
	setsize(this, [0,0,0], [0,0,0]);
	origin = m_vecStartPos;

	/* the sprite has changed, we need to query a new texture */
	if (flChanged & BEAM_CHANGED_COLOR) {
		SetRenderColor(renderColor);
	}

	/* the sprite has changed, we need to query a new texture */
	if (flChanged & BEAM_CHANGED_SPRITE) {
		ReloadVideoResources();
	}
}

void
env_beam::ReloadVideoResources(void)
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

			R_PolygonVertex(point, [1, 0], m_renderColor / 255, a);

			if (autocvar(cl_showoff, 0)) {
				float dli = dynamiclight_add(point, 150, m_renderColor/255);
				dynamiclight_set(dli, LFIELD_STYLE, 64);
			}

			last_progression = progression;
		}

		R_EndPolygonRibbon(m_flBeamWidth/8, [-1,0]);
	}

	return (PREDRAW_NEXT);
}
#endif
