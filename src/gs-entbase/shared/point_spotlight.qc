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
	PNTSPTLGHT_CHANGED_STYLE,
};

/*! \brief Shared-Entity: Spotlight With Beam */
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

@ingroup sharedentity
@ingroup pointentity
*/
class point_spotlight:ncPointTrigger
{
public:
	void point_spotlight(void);

#ifdef CLIENT
	vector m_vecBeamEnd;
	float m_flBeamTrace;
	float m_flBeamHalfwidth;
	string m_flareMaterial;
	string m_coneMaterial;

	virtual void ReceiveEntity(float,float);
	virtual float predraw(void);
	nonvirtual void UpdateBeamLength(void);
	nonvirtual float BeamViewDelta(vector, vector);
	nonvirtual float FlareViewDelta(float, vector);
	nonvirtual void SetBeamMaterial(string);
	nonvirtual void SetGlowMaterial(string);
	nonvirtual void SetRenderColor(vector);
	nonvirtual void SetLightStyle(float);
	virtual void ReloadVideoResources(void);
#endif

#ifdef SERVER
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual float SendEntity(entity,float);
	virtual void SpawnKey(string,string);
	virtual void EvaluateEntity(void);
	virtual void Input(entity, string, string);
#endif

	nonvirtual void SetBeamWidth(float);
	nonvirtual void SetBeamLength(float);

private:
	PREDICTED_VECTOR(m_vecColor)
	PREDICTED_FLOAT(m_flBeamLength)
	PREDICTED_FLOAT(m_flBeamWidth)
	PREDICTED_INT(m_iState)
	PREDICTED_FLOAT_N(style)
};



void
point_spotlight::point_spotlight(void)
{
	m_vecColor = [255,255,255];
	m_flBeamLength = 500.0f;
	m_flBeamWidth = 50.0f;
	m_iState = 0;

#ifdef CLIENT
	m_flareMaterial = "sprites/light_glow03";
	m_coneMaterial = "sprites/glow_test02";
#endif
}

void
point_spotlight::SetBeamWidth(float newWidth)
{
	m_flBeamWidth = newWidth;

#ifdef CLIENT
	m_flBeamHalfwidth = (m_flBeamWidth * 0.5f);
#endif
}

void
point_spotlight::SetBeamLength(float beamLength)
{
	m_flBeamLength = beamLength;

#ifdef CLIENT
	UpdateBeamLength();
#endif
}

#ifdef CLIENT
void
point_spotlight::SetRenderColor(vector renderColor)
{
	m_vecColor[0] = renderColor[0];
	m_vecColor[1] = renderColor[1];
	m_vecColor[2] = renderColor[2];
}

void
point_spotlight::SetLightStyle(float newStyle)
{
	style = newStyle;
}
#endif

#ifdef CLIENT
void
point_spotlight::ReloadVideoResources(void)
{
	precache_pic(m_coneMaterial);
	precache_pic(m_flareMaterial);
}

void
point_spotlight::SetBeamMaterial(string beamMaterial)
{
	m_coneMaterial = beamMaterial;

	precache_pic(m_coneMaterial);
}

void
point_spotlight::SetGlowMaterial(string glowMaterial)
{
	m_flareMaterial = glowMaterial;

	precache_pic(m_flareMaterial);
}

void
point_spotlight::UpdateBeamLength(void)
{
	traceline(origin, origin + anglesToForward(angles) * m_flBeamLength, MOVE_NORMAL, this);
	m_vecBeamEnd = trace_endpos;
}

float
point_spotlight::BeamViewDelta(vector vecPlayer, vector cameraAngle)
{
	vector camForward = anglesToForward(cameraAngle);
	vector pointForward = anglesToForward(angles);
	float flDot = pointForward * camForward;

	if (flDot < 0.0f)
		return (1.0 + flDot);
	else
		return (1.0f);
}

float
point_spotlight::FlareViewDelta(float beamDelta, vector cameraAngle)
{
	return 1.0 - beamDelta;
}

float
point_spotlight::predraw(void)
{
	vector lightColor = g_vec_null;
	vector lightStyleColor = getlightstylergb(style);

	if (!m_iState) {
		return (PREDRAW_NEXT);
	}

	for (int i = 0; i < 3; i++) {
		lightColor[i] = (m_vecColor[i] * (1/255)) * lightStyleColor[i];
	}

	/* beams */
	{
		float coneAlpha = 1.0f;
		vector vecPlayer = g_view.GetCameraOrigin();
		vector vecAngle = g_view.GetCameraAngle();
		float playerDistanceAlpha = bound(0.0f, distance(GetOrigin(), vecPlayer) / 512.0f, 1.0);
		coneAlpha = BeamViewDelta(vecPlayer, vecAngle) * playerDistanceAlpha;

		/* beam */
		if (coneAlpha > 0.0) {
			vector finalColor = (lightColor * coneAlpha);
			makevectors(vectoangles(m_vecBeamEnd - vecPlayer));
			R_BeginPolygon(m_coneMaterial);
			R_PolygonVertex(m_vecBeamEnd + (v_right * m_flBeamWidth),
				[1,1], finalColor, 1.0f);
			R_PolygonVertex(m_vecBeamEnd - (v_right * m_flBeamWidth),
				[0,1], finalColor, 1.0f);
			R_PolygonVertex(origin - (v_right * m_flBeamWidth),
				[0,0], finalColor, 1.0f);
			R_PolygonVertex(origin + (v_right * m_flBeamWidth),
				[1,0], finalColor, 1.0f);
			R_EndPolygon();
		}

		coneAlpha = FlareViewDelta(coneAlpha, vecAngle);

		if (coneAlpha > 0.0) {
			vector flareOrg = origin;
			makevectors(vectoangles(origin - vecPlayer));
			flareOrg += v_forward * - 16.0f;

			R_BeginPolygon(m_flareMaterial);
			R_PolygonVertex(flareOrg + v_right * m_flBeamHalfwidth - v_up * m_flBeamHalfwidth,
				[1,1], lightColor * coneAlpha, 1.0f);
			R_PolygonVertex(flareOrg - v_right * m_flBeamHalfwidth - v_up * m_flBeamHalfwidth,
				[0,1], lightColor * coneAlpha, 1.0f);
			R_PolygonVertex(flareOrg - v_right * m_flBeamHalfwidth + v_up * m_flBeamHalfwidth,
				[0,0], lightColor * coneAlpha, 1.0f);
			R_PolygonVertex(flareOrg + v_right * m_flBeamHalfwidth + v_up * m_flBeamHalfwidth,
				[1,0], lightColor * coneAlpha, 1.0f);
			R_EndPolygon();
		}
	}

	/* skip dlight */
	if (m_iState == 2i)
		return (PREDRAW_NEXT);

	float p = dynamiclight_add(origin, m_flBeamLength, lightColor, 0, "lights/flashlight");
	dynamiclight_set(p, LFIELD_ANGLES, angles);
	dynamiclight_set(p, LFIELD_FLAGS, LFLAG_NORMALMODE | LFLAG_REALTIMEMODE | LFLAG_SHADOWMAP);
	dynamiclight_set(p, LFIELD_STYLE, style);

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
	READENTITY_BYTE(m_vecColor[0], PNTSPTLGHT_CHANGED_COLOR)
	READENTITY_BYTE(m_vecColor[1], PNTSPTLGHT_CHANGED_COLOR)
	READENTITY_BYTE(m_vecColor[2], PNTSPTLGHT_CHANGED_COLOR)
	READENTITY_FLOAT(m_flBeamLength, PNTSPTLGHT_CHANGED_LENGTH)
	READENTITY_FLOAT(m_flBeamWidth, PNTSPTLGHT_CHANGED_WIDTH)
	READENTITY_BYTE(m_iState, PNTSPTLGHT_CHANGED_STATE)
	READENTITY_BYTE(style, PNTSPTLGHT_CHANGED_STYLE)

	if ((flChanged & PNTSPTLGHT_CHANGED_ORIGIN) || 
		(flChanged & PNTSPTLGHT_CHANGED_ANGLES) || 
		(flChanged & PNTSPTLGHT_CHANGED_LENGTH))
		UpdateBeamLength();

	if (flChanged & PNTSPTLGHT_CHANGED_WIDTH) {
		m_flBeamHalfwidth = m_flBeamWidth / 2;
	}
	
	/* the sprite has changed, we need to query a new texture */
	if (flNew) {
		ReloadVideoResources();
	}

	setorigin(this, origin);
	classname = "point_spotlight";
	drawmask = MASK_ENGINE;
}
#endif

#ifdef SERVER
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
	EVALUATE_FIELD(style, PNTSPTLGHT_CHANGED_STYLE)
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
	SENDENTITY_BYTE(m_vecColor[0], PNTSPTLGHT_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecColor[1], PNTSPTLGHT_CHANGED_COLOR)
	SENDENTITY_BYTE(m_vecColor[2], PNTSPTLGHT_CHANGED_COLOR)
	SENDENTITY_FLOAT(m_flBeamLength, PNTSPTLGHT_CHANGED_LENGTH)
	SENDENTITY_FLOAT(m_flBeamWidth, PNTSPTLGHT_CHANGED_WIDTH)
	SENDENTITY_BYTE(m_iState, PNTSPTLGHT_CHANGED_STATE)
	SENDENTITY_BYTE(style, PNTSPTLGHT_CHANGED_STYLE)

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
point_spotlight::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "rendercolor":
		m_vecColor = ReadVector(setValue);
		break;
	case "spotlightlength":
		m_flBeamLength = ReadFloat(setValue);
		break;
	case "spotlightwidth":
		m_flBeamWidth = ReadFloat(setValue);
		break;
	case "style":
		style = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
point_spotlight::Respawn(void)
{
	super::Respawn();

	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_NOT);
	SetSize([-16,-16,-16], [16,16,16]);

	m_iState = HasSpawnFlags(1) ? 1 : 0;

	if (m_iState && HasSpawnFlags(2)) {
		m_iState = 2;
	}
}
#endif
