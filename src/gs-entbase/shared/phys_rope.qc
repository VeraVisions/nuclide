/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

/*! \brief Shared-Entity: Physics Rope */
/*!QUAKED phys_rope (1 0 0) (-8 -8 -8) (8 8 8) ROPE_VERTICAL
# OVERVIEW
Physics rope entity.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup sharedentity
@ingroup pointentity
*/
class phys_rope:ncPointTrigger
{
public:
	void phys_rope(void);

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
	PREDICTED_FLOAT(m_flWidth)
	ncPhysicsConstraint m_ropeConstraint;
};

#ifdef CLIENT

void
phys_rope::RendererRestarted(void)
{
	precache_material(m_strShader);
}

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
	ncPlayer pl;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	pl = (ncPlayer)pSeat->m_ePlayer;
	vecPlayer = pl.GetEyePos();

#if 1
	R_BeginPolygon("", 0, 0);
	R_PolygonVertex(origin, [0,1], [0,1,0], 1.0f);
	R_PolygonVertex(m_vecTarget, [1,1], [0,1,0], 1.0f);
	R_EndPolygon();
#else
	DrawSegment(origin, m_vecTarget, vecPlayer);
#endif
	
	return (PREDRAW_NEXT);
}

void
phys_rope::ReceiveEntity(float new, float flSendFlags)
{
	if (flSendFlags & PHYSROPE_CHANGED_MAT) {
		m_strShader = readstring();
		RendererRestarted();
	}

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
	if (flSendFlags & PHYSROPE_CHANGED_WIDTH)
		m_flWidth = readfloat();
}
#endif

#ifdef SERVER
void
phys_rope::Respawn(void)
{
	super::Respawn();

	if (HasSpawnFlags(1)) {
		flags = 1;
	}
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
		Destroy();
		return;
	}


	if (!m_ropeConstraint) {
		m_ropeConstraint = ncPhysicsConstraint::Rope(this, eFind, this.origin, eFind.origin);
	}

	m_vecTarget = eFind.origin;


	if (ATTR_CHANGED(origin)) {
		SetSendFlags(PHYSROPE_CHANGED_ORIGIN);
	}
	if (ATTR_CHANGED(m_vecTarget)) {
		SetSendFlags(PHYSROPE_CHANGED_TARGET);
	}
	if (ATTR_CHANGED(m_flWidth)) {
		SetSendFlags(PHYSROPE_CHANGED_WIDTH);
	}

	SAVE_STATE(origin)
	SAVE_STATE(m_vecTarget)
	SAVE_STATE(m_flWidth)
}

float
phys_rope::SendEntity(entity ePVEnt, float flSendFlags)
{
	if (!target)
		return 0;

	WriteByte(MSG_ENTITY, ENT_PHYSROPE);
	WriteFloat(MSG_ENTITY, flSendFlags);

	if (flSendFlags & PHYSROPE_CHANGED_MAT) {
		WriteString(MSG_ENTITY, m_strShader);
	}
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
	if (flSendFlags & PHYSROPE_CHANGED_WIDTH) {
		WriteFloat(MSG_ENTITY, m_flWidth);
	}

	return 1;
}

void
phys_rope::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "RopeMaterial":
	case "shader":
		m_strShader = ReadString(strValue);
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
	SaveVector(handle, "m_vecTarget", m_vecTarget);
	SaveFloat(handle, "m_flWidth", m_flWidth);
}

void
phys_rope::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strShader":
		m_strShader = ReadString(strValue);
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
	m_strShader = "cable/cable";
#endif

#ifdef CLIENT
	/* this is empty for a good reason */
	drawmask = MASK_ENGINE;
#endif
}

class
move_rope:phys_rope
{
	void move_rope(void);
};

void
move_rope::move_rope(void)
{

}

class
keyframe_rope:phys_rope
{
	void keyframe_rope(void);
};

void
keyframe_rope::keyframe_rope(void)
{

}
