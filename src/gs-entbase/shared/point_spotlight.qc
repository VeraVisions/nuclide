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
	PNTSPTLGHT_CHANGED_ORIGIN,
	PNTSPTLGHT_CHANGED_ANGLES,
	PNTSPTLGHT_CHANGED_COLOR,
	PNTSPTLGHT_CHANGED_LENGTH,
	PNTSPTLGHT_CHANGED_WIDTH,
	PNTSPTLGHT_CHANGED_STATE,
};

/*!QUAKED point_spotlight (1 .5 0) (-8 -8 -8) (8 8 8) PNTSPTLGHT_STARTON PNTSPTLGHT_NOLIGHT
# OVERVIEW
An entity that draws a spotlight, with beam. Will also spawn a dynamic light, unless specifically disabled via the spawnflags field.

# KEYS
- "targetname" : Name
- "target" : Name of an entity in the map that light will point at.
- "spotlightlength" : Beam length
- "spotlightwidth" : Beam width
- "rendercolor" : Beam color
- "HDRColorScale" : Multiplier that's active when running in HDR (unused)

# INPUTS
- "LightOff" : Turns the entity off.
- "LightOn" : Turns the entity on.

# SPAWNFLAGS
- PNTSPTLGHT_STARTON (1) : Start enabled.
- PNTSPTLGHT_NOLIGHT (2) : No dynamic light

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class point_spotlight:NSPointTrigger
{
private:
	PREDICTED_VECTOR(m_vecColor)
	PREDICTED_FLOAT(m_flBeamLength)
	PREDICTED_FLOAT(m_flBeamWidth)
	PREDICTED_INT(m_iState)

public:
	void point_spotlight(void);

#ifdef CLIENT
	vector m_vecBeamEnd;
	float m_flBeamTrace;
	float m_flBeamHalfwidth;

	virtual void ReceiveEntity(float,float);
	virtual float predraw(void);
	nonvirtual void UpdateBeamLength(void);
	nonvirtual float BeamViewDelta(vector);
	nonvirtual float FlareViewDelta(float, vector);
#else
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual float SendEntity(entity,float);
	virtual void SpawnKey(string,string);
	virtual void EvaluateEntity(void);
	virtual void Input(entity, string, string);
#endif
};

#ifdef CLIENT
void
point_spotlight::UpdateBeamLength(void)
{
	traceline(origin, origin - [0, 0, m_flBeamLength], MOVE_NORMAL, this);
	m_flBeamTrace = m_flBeamLength * trace_fraction;

	makevectors(angles);
	m_vecBeamEnd = origin + v_forward * m_flBeamTrace;
}

float
point_spotlight::BeamViewDelta(vector cameraAngle)
{
	vector v;
	float upDelta;
	float forwardDelta;

	/* depending on whether we're looking 'up' at the spotlight,
	   we'll adjust the delta to reflect that */
	v = normalize(origin - m_vecBeamEnd);

	makevectors(cameraAngle);
	upDelta = (v * v_up);
	forwardDelta = (v * v_forward);

	//NSLog("forwardDelta: %f\n", forwardDelta);
	//NSLog("upDelta: %f (%f)\n", upDelta, 1.0 - upDelta);

	if (forwardDelta < 0.0)
		return upDelta * (1.0 - forwardDelta);

	if (upDelta >= 0.0)
		return upDelta;
	else
		return 0.0f;
}

float
point_spotlight::FlareViewDelta(float beamDelta, vector cameraAngle)
{
	return 1.0 - beamDelta;
}

float
point_spotlight::predraw(void)
{
	if (!m_iState) {
		return (PREDRAW_NEXT);
	}

	/* beams */
	{
		vector vecPlayer = g_view.GetCameraOrigin();
		vector vecAngle = g_view.GetCameraAngle();
		float coneAlpha = BeamViewDelta(vecAngle);

		//NSLog("coneAlpha: %f\n", coneAlpha);

		/* beam */
		if (coneAlpha > 0.0) {
			vector finalColor = (m_vecColor * (coneAlpha * 0.5f));

#if 0
			//vecPlayer[2] = origin[2];
			makevectors(vectoangles(origin - vecPlayer));
			R_BeginPolygon("textures/sfx/spot_cone");
			R_PolygonVertex(m_vecBeamEnd + (v_right * m_flBeamHalfwidth),
				[1,1], m_vecColor * coneAlpha, 1.0f);
			R_PolygonVertex(m_vecBeamEnd - (v_right * m_flBeamHalfwidth),
				[0,1], m_vecColor * coneAlpha, 1.0f);
			R_PolygonVertex(origin - (v_right * m_flBeamHalfwidth),
				[0,0], m_vecColor * coneAlpha, 1.0f);
			R_PolygonVertex(origin + (v_right * m_flBeamHalfwidth),
				[1,0], m_vecColor * coneAlpha, 1.0f);
			R_EndPolygon();
#else
			makevectors(vecAngle);
			setproperty(VF_ORIGIN, vecPlayer);
			R_BeginPolygon("textures/sfx/spot_cone");
			R_PolygonVertex(origin, [1,0], finalColor, 1.0f);
			R_PolygonVertex(m_vecBeamEnd, [1,1], finalColor, 1.0f);
			R_EndPolygonRibbon(m_flBeamWidth, [-1,0]);

			/* debug */
			/*R_BeginPolygon("", 0, 0);
			R_PolygonVertex(origin, [0,1], [0,1,0], 1.0f);
			R_PolygonVertex(m_vecBeamEnd, [1,1], [0,1,0], 1.0f);
			R_EndPolygon();*/
#endif
		}

		coneAlpha = FlareViewDelta(coneAlpha, vecAngle);

		if (coneAlpha > 0.0) {
			vector flareOrg = origin;
			makevectors(vectoangles(origin - vecPlayer));
			flareOrg += v_forward * - 16.0f;

			R_BeginPolygon("textures/sfx/spot_flare");
			R_PolygonVertex(flareOrg + v_right * m_flBeamHalfwidth - v_up * m_flBeamHalfwidth,
				[1,1], m_vecColor * coneAlpha, 1.0f);
			R_PolygonVertex(flareOrg - v_right * m_flBeamHalfwidth - v_up * m_flBeamHalfwidth,
				[0,1], m_vecColor * coneAlpha, 1.0f);
			R_PolygonVertex(flareOrg - v_right * m_flBeamHalfwidth + v_up * m_flBeamHalfwidth,
				[0,0], m_vecColor * coneAlpha, 1.0f);
			R_PolygonVertex(flareOrg + v_right * m_flBeamHalfwidth + v_up * m_flBeamHalfwidth,
				[1,0], m_vecColor * coneAlpha, 1.0f);
			R_EndPolygon();
		}
	}

	/* skip dlight */
	if (m_iState == 2)
		return (PREDRAW_NEXT);

	makevectors(angles);
	float p = dynamiclight_add(origin, m_flBeamLength, m_vecColor / 255, 0, "textures/flashlight");
	dynamiclight_set(p, LFIELD_ANGLES, angles);
	dynamiclight_set(p, LFIELD_FLAGS, LFLAG_NORMALMODE | LFLAG_REALTIMEMODE | LFLAG_SHADOWMAP);

	return (PREDRAW_NEXT);
}

void
point_spotlight::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], PNTSPTLGHT_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], PNTSPTLGHT_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], PNTSPTLGHT_CHANGED_ORIGIN)
	READENTITY_ANGLE(angles[0], PNTSPTLGHT_CHANGED_ANGLES)
	READENTITY_ANGLE(angles[1], PNTSPTLGHT_CHANGED_ANGLES)
	READENTITY_ANGLE(angles[2], PNTSPTLGHT_CHANGED_ANGLES)
	READENTITY_COLOR(m_vecColor[0], PNTSPTLGHT_CHANGED_COLOR)
	READENTITY_COLOR(m_vecColor[1], PNTSPTLGHT_CHANGED_COLOR)
	READENTITY_COLOR(m_vecColor[2], PNTSPTLGHT_CHANGED_COLOR)
	READENTITY_FLOAT(m_flBeamLength, PNTSPTLGHT_CHANGED_LENGTH)
	READENTITY_FLOAT(m_flBeamWidth, PNTSPTLGHT_CHANGED_WIDTH)
	READENTITY_BYTE(m_iState, PNTSPTLGHT_CHANGED_STATE)

	if ((flChanged & PNTSPTLGHT_CHANGED_ORIGIN) || 
		(flChanged & PNTSPTLGHT_CHANGED_ANGLES) || 
		(flChanged & PNTSPTLGHT_CHANGED_LENGTH))
		UpdateBeamLength();

	if (flChanged & PNTSPTLGHT_CHANGED_WIDTH) {
		m_flBeamHalfwidth = m_flBeamWidth / 2;
	}

	setorigin(this, origin);
	classname = "point_spotlight";
	drawmask = MASK_ENGINE;
}
#else
void
point_spotlight::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, PNTSPTLGHT_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, PNTSPTLGHT_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, PNTSPTLGHT_CHANGED_ORIGIN)
	EVALUATE_VECTOR(angles, 0, PNTSPTLGHT_CHANGED_ANGLES)
	EVALUATE_VECTOR(angles, 1, PNTSPTLGHT_CHANGED_ANGLES)
	EVALUATE_VECTOR(angles, 2, PNTSPTLGHT_CHANGED_ANGLES)
	EVALUATE_VECTOR(m_vecColor, 0, PNTSPTLGHT_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecColor, 1, PNTSPTLGHT_CHANGED_COLOR)
	EVALUATE_VECTOR(m_vecColor, 2, PNTSPTLGHT_CHANGED_COLOR)
	EVALUATE_FIELD(m_flBeamLength, PNTSPTLGHT_CHANGED_LENGTH)
	EVALUATE_FIELD(m_flBeamWidth, PNTSPTLGHT_CHANGED_WIDTH)
	EVALUATE_FIELD(m_iState, PNTSPTLGHT_CHANGED_STATE)
}

void
point_spotlight::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_iState = 0;
		break;
	case TRIG_ON:
		m_iState = 1;
		break;
	default:
		m_iState = 1 - m_iState;
	}

	if (m_iState && HasSpawnFlags(2))
		m_iState = 2;

	SendFlags |= PNTSPTLGHT_CHANGED_STATE;
}

float
point_spotlight::SendEntity(entity ePEnt, float flChanged)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_SPOTLIGHT);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], PNTSPTLGHT_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], PNTSPTLGHT_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], PNTSPTLGHT_CHANGED_ORIGIN)
	SENDENTITY_ANGLE(angles[0], PNTSPTLGHT_CHANGED_ANGLES)
	SENDENTITY_ANGLE(angles[1], PNTSPTLGHT_CHANGED_ANGLES)
	SENDENTITY_ANGLE(angles[2], PNTSPTLGHT_CHANGED_ANGLES)
	SENDENTITY_COLOR(m_vecColor[0], PNTSPTLGHT_CHANGED_COLOR)
	SENDENTITY_COLOR(m_vecColor[1], PNTSPTLGHT_CHANGED_COLOR)
	SENDENTITY_COLOR(m_vecColor[2], PNTSPTLGHT_CHANGED_COLOR)
	SENDENTITY_FLOAT(m_flBeamLength, PNTSPTLGHT_CHANGED_LENGTH)
	SENDENTITY_FLOAT(m_flBeamWidth, PNTSPTLGHT_CHANGED_WIDTH)
	SENDENTITY_BYTE(m_iState, PNTSPTLGHT_CHANGED_STATE)

	return (1);
}

void
point_spotlight::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "LightOn":
		Trigger(eAct, TRIG_ON);
		break;
	case "LightOff":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
point_spotlight::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "rendercolor":
		m_vecColor = stov(strValue) / 255;
		break;
	case "spotlightlength":
		m_flBeamLength = stof(strValue);
		break;
	case "spotlightwidth":
		m_flBeamWidth = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
point_spotlight::Respawn(void)
{
	SetSolid(SOLID_NOT);
	SetSize([-16,-16,-16], [16,16,16]);
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());

	m_iState = HasSpawnFlags(1) ? 1 : 0;

	if (m_iState && HasSpawnFlags(2))
		m_iState = 2;
}
#endif

void
point_spotlight::point_spotlight(void)
{
#ifndef CLIENT
	m_flBeamLength = 500.0f;
	m_flBeamWidth = 50.0f;
	m_vecColor = [1.0,1.0,1.0];
#endif
}

#ifdef CLIENT
void
point_spotlight_ReadEntity(float isNew)
{
	point_spotlight ept = (point_spotlight)self;
	if (isNew) {
		spawnfunc_point_spotlight();
	}
	ept.ReceiveEntity(isNew, readfloat());
}
#endif