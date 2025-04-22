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
	PROPROPE_CHANGED_MAT,
	PROPROPE_CHANGED_SAG,
	PROPROPE_CHANGED_SWING,
	PROPROPE_CHANGED_SEGMENTS,
	PROPROPE_CHANGED_ORIGIN,
	PROPROPE_CHANGED_TARGET,
	PROPROPE_CHANGED_FLAGS
};

void(float radius, vector texcoordbias) R_EndPolygonRibbon = #0;

var int autocvar_rope_debug = FALSE;
var float autocvar_rope_sag = 2.0;
var float autocvar_rope_swing = 2.0;
var bool autocvar_rope_fast = TRUE;
var int autocvar_rope_maxsegments = -1;

/*! \brief Shared-Entity: Faux Physics Rope */
/*!QUAKED prop_rope (1 0 0) (-8 -8 -8) (8 8 8) ROPE_VERTICAL
# OVERVIEW
Client-side decorative rope entity. 
Connect the entity to a named info_notnull and watch it swing around.

# KEYS
- "sag" : Multiplier on how much sagginess will be applied to the rope.
- "segments" : Number of total segments. Default is "16".
- "material" : The texture to use on the rope.
- "swingfactor" : Multiplier on how much the rope swings about.
- "target" : The info_notnull to connect the rope to.

# SPAWNFLAGS
- ROPE_VERTICAL (1) : Only draw the first half of the rope, useful for vertical setups.

# TRIVIA
This entity was introduced in The Wastes (2018).

@ingroup sharedentity
@ingroup pointentity
*/
class prop_rope:ncEntity
{
public:
	void prop_rope(void);

#ifdef CLIENT
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
	virtual void DrawSegment(vector, vector, vector);
#endif

#ifdef SERVER
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#endif

private:
	string m_strShader;
	PREDICTED_FLOAT(m_flSag)
	PREDICTED_FLOAT(m_flSwingFactor)
	PREDICTED_INT(m_iSegments)
	PREDICTED_VECTOR(m_vecTarget)
};

#ifdef CLIENT

void
prop_rope::DrawSegment(vector pos1, vector pos2, vector vecPlayer)
{
	vector lit1 = /*[0.1,0.1,0.1] */ getlight(pos1) / 255;
	vector lit2 = /*[0.1,0.1,0.1] */ getlight(pos2) / 255;

	R_BeginPolygon(m_strShader, 0, 0);
		R_PolygonVertex(pos1, [0,0], lit1, 1.0f);
		R_PolygonVertex(pos2, [0,1], lit2, 1.0f);
	R_EndPolygonRibbon(2, [-1,0]);
}

/* a is a value between 0.0 - 1.0, aka our progress */
float
ropecos(float a)
{
	a *= 0.5f;
	float b = (a - 0.5f) * 2.0;
	float c = 1.0 - b;
	return -(b * a);
}

float
prop_rope::predraw(void)
{
	vector pos1;
	vector pos2;
	float segments;
	vector vecPlayer;
	ncPlayer pl;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	pl = (ncPlayer)pSeat->m_ePlayer;
	vecPlayer = pl.GetEyePos();

	/* draw the start/end without segments */
	if (autocvar_rope_debug == TRUE) {
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(origin, [0,1], [0,1,0], 1.0f);
		R_PolygonVertex(m_vecTarget, [1,1], [0,1,0], 1.0f);
		R_EndPolygon();
	}

	if (autocvar_rope_maxsegments > 0)
		segments = bound(1, autocvar_rope_maxsegments, (float)m_iSegments);
	else
		segments = (float)m_iSegments;

	float travel = 1.0f / segments;
	float progress= 0.0f;
	pos1 = origin;

	makevectors(getproperty(VF_CL_VIEWANGLES));
	setproperty(VF_ORIGIN, vecPlayer);

	/* get the direction */
	makevectors(vectoangles(m_vecTarget - origin));

	for (float i = 0; i < segments; i++) {
		float sag = 0.0f;
		float swing = 0.0f;
		progress += travel;
		float c1 = (ropecos(progress) * M_PI) * 2.25f;

		/* loose hanging rope */
		if (flags & 1) {
			sag = c1 * m_flSag;
			swing = c1 * m_flSwingFactor;
		} else {
			sag = c1 * m_flSag;
			swing = c1 * m_flSwingFactor;
		}

		/* travel further and sag */
		pos2 = vectorLerp(origin, m_vecTarget, progress);
		pos2 += (v_up * -sag) * autocvar_rope_sag;

		if (!autocvar_rope_fast)
			pos2 += ((v_right * swing) * sin(time)) * autocvar_rope_swing;

		DrawSegment(pos1, pos2, vecPlayer);
		pos1 = pos2;
	}

	return (PREDRAW_NEXT);
}

void
prop_rope::ReceiveEntity(float new, float flSendFlags)
{
	if (flSendFlags & PROPROPE_CHANGED_MAT)
		m_strShader = readstring();
	if (flSendFlags & PROPROPE_CHANGED_SAG)
		m_flSag = readfloat();
	if (flSendFlags & PROPROPE_CHANGED_SWING)
		m_flSwingFactor = readfloat();
	if (flSendFlags & PROPROPE_CHANGED_SEGMENTS)
		m_iSegments = readint();
	if (flSendFlags & PROPROPE_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setsize(this, [0,0,0], [0,0,0]);
		setorigin(this, origin);
	}
	if (flSendFlags & PROPROPE_CHANGED_TARGET) {
		m_vecTarget[0] = readcoord();
		m_vecTarget[1] = readcoord();
		m_vecTarget[2] = readcoord();
	}
	if (flSendFlags & PROPROPE_CHANGED_FLAGS)
		flags = readfloat();
}
#endif

#ifdef SERVER
void
prop_rope::Respawn(void)
{
	super::Respawn();

	if (HasSpawnFlags(1)) {
		flags = 1;
	}
	SetSize([0,0,0], [0,0,0]);
}
void
prop_rope::EvaluateEntity(void)
{
	entity eFind = find(world, ::targetname, target);

	if (!eFind) {
		EntError("Unable to find rope target %S", target);
		return;
	}

	m_vecTarget = eFind.origin;

	if (ATTR_CHANGED(m_flSag)) {
		SetSendFlags(PROPROPE_CHANGED_SAG);
	}
	if (ATTR_CHANGED(m_flSwingFactor)) {
		SetSendFlags(PROPROPE_CHANGED_SWING);
	}
	if (ATTR_CHANGED(m_iSegments)) {
		SetSendFlags(PROPROPE_CHANGED_SEGMENTS);
	}

	if (ATTR_CHANGED(origin)) {
		SetSendFlags(PROPROPE_CHANGED_ORIGIN);
	}
	if (ATTR_CHANGED(m_vecTarget)) {
		SetSendFlags(PROPROPE_CHANGED_TARGET);
	}
	if (ATTR_CHANGED(flags)) {
		SetSendFlags(PROPROPE_CHANGED_FLAGS);
	}

	SAVE_STATE(m_flSag)
	SAVE_STATE(m_flSwingFactor)
	SAVE_STATE(m_iSegments)
	SAVE_STATE(origin)
	SAVE_STATE(m_vecTarget)
	SAVE_STATE(flags)
}

float
prop_rope::SendEntity(entity ePVEnt, float flSendFlags)
{
	WriteByte(MSG_ENTITY, ENT_PROPROPE);
	WriteFloat(MSG_ENTITY, flSendFlags);

	if (flSendFlags & PROPROPE_CHANGED_MAT)
		WriteString(MSG_ENTITY, m_strShader);
	if (flSendFlags & PROPROPE_CHANGED_SAG)
		WriteFloat(MSG_ENTITY, m_flSag);
	if (flSendFlags & PROPROPE_CHANGED_SWING)
		WriteFloat(MSG_ENTITY, m_flSwingFactor);
	if (flSendFlags & PROPROPE_CHANGED_SEGMENTS)
		WriteInt(MSG_ENTITY, m_iSegments);
	if (flSendFlags & PROPROPE_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	if (flSendFlags & PROPROPE_CHANGED_TARGET) {
		WriteCoord(MSG_ENTITY, m_vecTarget[0]);
		WriteCoord(MSG_ENTITY, m_vecTarget[1]);
		WriteCoord(MSG_ENTITY, m_vecTarget[2]);
	}
	if (flSendFlags & PROPROPE_CHANGED_FLAGS) {
		WriteFloat(MSG_ENTITY, flags);
	}

	return 1;
}

void
prop_rope::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "sag":
		m_flSag = stof(setValue);
		break;
	case "segments":
		m_iSegments = stoi(setValue);
		break;
	case "RopeMaterial":
	case "shader":
		m_strShader = setValue;
		break;
	case "swingfactor":
		m_flSwingFactor = stof(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
prop_rope::Save(float handle)
{
	super::Save(handle);

	SaveString(handle, "m_strShader", m_strShader);
	SaveFloat(handle, "m_flSag", m_flSag);
	SaveFloat(handle, "m_flSwingFactor", m_flSwingFactor);
	SaveInt(handle, "m_iSegments", m_iSegments);
	SaveVector(handle, "m_vecTarget", m_vecTarget);
}

void
prop_rope::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_strShader":
		m_strShader = ReadString(setValue);
		break;
	case "m_flSag":
		m_flSag = ReadFloat(setValue);
		break;
	case "m_flSwingFactor":
		m_flSwingFactor = ReadFloat(setValue);
		break;
	case "m_iSegments":
		m_iSegments = ReadInt(setValue);
		break;
	case "m_vecTarget":
		m_vecTarget = ReadVector(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}
#endif

void
prop_rope::prop_rope(void)
{
#ifdef SERVER
	m_flSwingFactor = random();
	m_flSag = 15.0f;
	m_iSegments = 16;
	m_strShader = "textures/props/wire_default";
#endif

#ifdef CLIENT
	/* this is empty for a good reason */
	drawmask = MASK_ENGINE;
#endif
}
