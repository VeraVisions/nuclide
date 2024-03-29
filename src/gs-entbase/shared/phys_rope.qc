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
	PHYSROPE_CHANGED_MAT,
	PHYSROPE_CHANGED_SAG,
	PHYSROPE_CHANGED_SWING,
	PHYSROPE_CHANGED_SEGMENTS,
	PHYSROPE_CHANGED_ORIGIN,
	PHYSROPE_CHANGED_TARGET,
	PHYSROPE_CHANGED_FLAGS,
	PHYSROPE_CHANGED_WIDTH
};

/*!QUAKED phys_rope (1 0 0) (-8 -8 -8) (8 8 8) ROPE_VERTICAL
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
*/
class phys_rope:NSEntity
{
public:
	void phys_rope(void);

#ifdef CLIENT
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
	virtual void DrawSegment(vector, vector, vector);
#else
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
	PREDICTED_FLOAT(m_flWidth)
};

#ifdef CLIENT

void
phys_rope::DrawSegment(vector pos1, vector pos2, vector vecPlayer)
{
	vector lit1 = /*[0.1,0.1,0.1] */ getlight(pos1) / 255;
	vector lit2 = /*[0.1,0.1,0.1] */ getlight(pos2) / 255;

	R_BeginPolygon(m_strShader, 0, 0);
		R_PolygonVertex(pos1, [0,0], lit1, 1.0f);
		R_PolygonVertex(pos2, [0,1], lit2, 1.0f);
	R_EndPolygonRibbon(1, [-1,0]);
}


float
phys_rope::predraw(void)
{
	vector pos1;
	vector pos2;
	float segments;
	vector vecPlayer;
	NSClientPlayer pl;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	pl = (NSClientPlayer)pSeat->m_ePlayer;
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
		pos2[0] = Math_Lerp(origin[0], m_vecTarget[0], progress);
		pos2[1] = Math_Lerp(origin[1], m_vecTarget[1], progress);
		pos2[2] = Math_Lerp(origin[2], m_vecTarget[2], progress);
		pos2 += (v_up * -sag) * autocvar_rope_sag;

		if (!autocvar_rope_fast)
			pos2 += ((v_right * swing) * sin(time)) * autocvar_rope_swing;

		DrawSegment(pos1, pos2, vecPlayer);
		pos1 = pos2;
	}

	return (PREDRAW_NEXT);
}

void
phys_rope::ReceiveEntity(float new, float flSendFlags)
{
	if (flSendFlags & PHYSROPE_CHANGED_MAT)
		m_strShader = readstring();
	if (flSendFlags & PHYSROPE_CHANGED_SAG)
		m_flSag = readfloat();
	if (flSendFlags & PHYSROPE_CHANGED_SWING)
		m_flSwingFactor = readfloat();
	if (flSendFlags & PHYSROPE_CHANGED_SEGMENTS)
		m_iSegments = readint();
	if (flSendFlags & PHYSROPE_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setsize(this, [0,0,0], [0,0,0]);
		setorigin(this, origin);
	}
	if (flSendFlags & PHYSROPE_CHANGED_TARGET) {
		m_vecTarget[0] = readcoord();
		m_vecTarget[1] = readcoord();
		m_vecTarget[2] = readcoord();
	}
	if (flSendFlags & PHYSROPE_CHANGED_FLAGS)
		flags = readfloat();
	if (flSendFlags & PHYSROPE_CHANGED_WIDTH)
		m_flWidth = readfloat();
}
#else
void
phys_rope::Respawn(void)
{
	if (HasSpawnFlags(1)) {
		flags = 1;
	}
	SetOrigin(GetSpawnOrigin());
	SetSize([0,0,0], [0,0,0]);
}
void
phys_rope::EvaluateEntity(void)
{
	if (!target)
		return;

	entity eFind = find(world, ::targetname, target);

	if (!eFind) {
		EntError("phys_rope: Unable to find target %S", target);
		return;
	}

	m_vecTarget = eFind.origin;

	if (ATTR_CHANGED(m_flSag)) {
		SetSendFlags(PHYSROPE_CHANGED_SAG);
	}
	if (ATTR_CHANGED(m_flSwingFactor)) {
		SetSendFlags(PHYSROPE_CHANGED_SWING);
	}
	if (ATTR_CHANGED(m_iSegments)) {
		SetSendFlags(PHYSROPE_CHANGED_SEGMENTS);
	}

	if (ATTR_CHANGED(origin)) {
		SetSendFlags(PHYSROPE_CHANGED_ORIGIN);
	}
	if (ATTR_CHANGED(m_vecTarget)) {
		SetSendFlags(PHYSROPE_CHANGED_TARGET);
	}
	if (ATTR_CHANGED(flags)) {
		SetSendFlags(PHYSROPE_CHANGED_FLAGS);
	}
	if (ATTR_CHANGED(m_flWidth)) {
		SetSendFlags(PHYSROPE_CHANGED_WIDTH);
	}

	SAVE_STATE(m_flSag)
	SAVE_STATE(m_flSwingFactor)
	SAVE_STATE(m_iSegments)
	SAVE_STATE(origin)
	SAVE_STATE(m_vecTarget)
	SAVE_STATE(flags)
	SAVE_STATE(m_flWidth)
}

float
phys_rope::SendEntity(entity ePVEnt, float flSendFlags)
{
	if (!target)
		return 0;

	WriteByte(MSG_ENTITY, ENT_PHYSROPE);
	WriteFloat(MSG_ENTITY, flSendFlags);

	if (flSendFlags & PHYSROPE_CHANGED_MAT)
		WriteString(MSG_ENTITY, m_strShader);
	if (flSendFlags & PHYSROPE_CHANGED_SAG)
		WriteFloat(MSG_ENTITY, m_flSag);
	if (flSendFlags & PHYSROPE_CHANGED_SWING)
		WriteFloat(MSG_ENTITY, m_flSwingFactor);
	if (flSendFlags & PHYSROPE_CHANGED_SEGMENTS)
		WriteInt(MSG_ENTITY, m_iSegments);
	if (flSendFlags & PHYSROPE_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	if (flSendFlags & PHYSROPE_CHANGED_TARGET) {
		WriteCoord(MSG_ENTITY, m_vecTarget[0]);
		WriteCoord(MSG_ENTITY, m_vecTarget[1]);
		WriteCoord(MSG_ENTITY, m_vecTarget[2]);
	}
	if (flSendFlags & PHYSROPE_CHANGED_FLAGS) {
		WriteFloat(MSG_ENTITY, flags);
	}
	if (flSendFlags & PHYSROPE_CHANGED_WIDTH) {
		WriteFloat(MSG_ENTITY, m_flWidth);
	}

	return 1;
}

void
phys_rope::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "sag":
		m_flSag = stof(strValue);
		break;
	case "segments":
		m_iSegments = stoi(strValue);
		break;
	case "shader":
		m_strShader = strValue;
		break;
	case "swingfactor":
		m_flSwingFactor = stof(strValue);
		break;
	case "NextKey":
		target = ReadString(strValue);
		break;
	case "Width":
		m_flWidth = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
phys_rope::Save(float handle)
{
	super::Save(handle);

	SaveString(handle, "m_strShader", m_strShader);
	SaveFloat(handle, "m_flSag", m_flSag);
	SaveFloat(handle, "m_flSwingFactor", m_flSwingFactor);
	SaveInt(handle, "m_iSegments", m_iSegments);
	SaveVector(handle, "m_vecTarget", m_vecTarget);
	SaveFloat(handle, "m_flWidth", m_flWidth);
}

void
phys_rope::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "RopeMaterial":
		m_strShader = ReadString(strValue);
		break;
	case "m_flSag":
		m_flSag = ReadFloat(strValue);
		break;
	case "m_flSwingFactor":
		m_flSwingFactor = ReadFloat(strValue);
		break;
	case "Subdiv":
		m_iSegments = ReadInt(strValue);
		break;
	case "m_vecTarget":
		m_vecTarget = ReadVector(strValue);
		break;
	case "m_flWidth":
		m_flWidth = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}
#endif

void
phys_rope::phys_rope(void)
{
#ifdef SERVER
	m_flSwingFactor = random();
	m_flSag = 15.0f;
	m_iSegments = 16;
	m_flWidth = 2.0f;
	m_strShader = "materials/cable/cable.vmt";
#else
	/* this is empty for a good reason */
	drawmask = MASK_ENGINE;
#endif
}

CLASSEXPORT(move_rope, phys_rope)
CLASSEXPORT(keyframe_rope, phys_rope)