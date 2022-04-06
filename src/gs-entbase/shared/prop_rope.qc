/*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED prop_rope (1 1 0.5) (-8 -8 -8) (8 8 8) ROPE_VERTICAL
Client-side decorative rope entity. 
Connect the entity to a named info_notnull and watch it swing around.

-------- KEYS --------
"sag" : Multiplier on how much sagginess will be applied to the rope.
"segments" : Number of total segments. Default is "16".
"material" : The texture to use on the rope.
"swingfactor" : Multiplier on how much the rope swings about.
"target" : The info_notnull to connect the rope to.

-------- SPAWNFLAGS --------
ROPE_HALF : Only draw the first half of the rope, useful for vertical setups.

-------- TRIVIA --------
This entity was introduced in The Wastes (2018).
*/

typedef enumflags
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

class prop_rope:NSEntity
{
	string m_strShader;
	PREDICTED_FLOAT(m_flSag);
	PREDICTED_FLOAT(m_flSwingFactor);
	PREDICTED_INT(m_iSegments);
	PREDICTED_VECTOR(m_vecTarget);

	void(void) prop_rope;

#ifdef CLIENT
	virtual float() predraw;
	virtual void(float,float) ReadEntity;
	virtual void(vector, vector, vector) DrawSegment;
#else
	virtual void(void) Respawn;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	virtual void(string, string) SpawnKey;
#endif
};

#ifdef CLIENT

void
prop_rope::DrawSegment(vector pos1, vector pos2, vector vecPlayer)
{
	vector lit1 = /*[0.1,0.1,0.1] */ getlight(pos1) / 255;
	vector lit2 = /*[0.1,0.1,0.1] */ getlight(pos2) / 255;

	makevectors(getproperty(VF_CL_VIEWANGLES));
	setproperty(VF_ORIGIN, vecPlayer);
	R_BeginPolygon(m_strShader, 0, 0);
		R_PolygonVertex(pos1, [0,0], lit1, 1.0f);
		R_PolygonVertex(pos2, [0,1], lit2, 1.0f);
	R_EndPolygonRibbon(2, [-1,0]);
}

float
prop_rope::predraw(void)
{
	vector pos1;
	vector pos2;
	float segments;
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	if (checkpvs(vecPlayer, this) == FALSE)
		return (PREDRAW_NEXT);

	/* draw the start/end without segments */
	if (autocvar_rope_debug == TRUE) {
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(origin, [0,1], [0,1,0], 1.0f);
		R_PolygonVertex(m_vecTarget, [1,1], [0,1,0], 1.0f);
		R_EndPolygon();
	}

	segments = (float)m_iSegments;
	float travel = 1.0f / segments;
	float progress= 0.0f;
	pos1 = origin;

	for (float i = 0; i < segments; i++) {
		float sag = 0.0f;
		float swing = 0.0f;
		progress += travel;

		if (flags & 1) {
			sag = cos(M_PI * (progress * 0.5) - (M_PI/2)) * m_flSag;
			swing = cos(M_PI * (progress * 0.5) - (M_PI/2)) * m_flSwingFactor;
		} else {
			sag = cos(M_PI * (progress) - (M_PI/2)) * m_flSag;
			swing = cos(M_PI * (progress) - (M_PI/2)) * m_flSwingFactor;
		}

		/* get the direction */
		makevectors(vectoangles(m_vecTarget - origin));

		/* travel further and sag */
		pos2[0] = Math_Lerp(origin[0], m_vecTarget[0], progress);
		pos2[1] = Math_Lerp(origin[1], m_vecTarget[1], progress);
		pos2[2] = Math_Lerp(origin[2], m_vecTarget[2], progress);
		pos2 += (v_up * -sag) * autocvar_rope_sag;
		pos2 += ((v_right * swing) * sin(time)) * autocvar_rope_swing;

		DrawSegment(pos1, pos2, vecPlayer);
		pos1 = pos2;
	}

	return (PREDRAW_NEXT);
}

void
prop_rope::ReadEntity(float flSendFlags, float new)
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
#else
void
prop_rope::Respawn(void)
{
	if (HasSpawnFlags(1)) {
		flags = 1;
	}
	SetOrigin(GetSpawnOrigin());
	SetSize([0,0,0], [0,0,0]);
}
void
prop_rope::EvaluateEntity(void)
{
	entity eFind = find(world, ::targetname, target);

	if (!eFind) {
		print(sprintf("prop_rope: Unable to find target %S\n", target));
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

	SAVE_STATE(m_flSag);
	SAVE_STATE(m_flSwingFactor);
	SAVE_STATE(m_iSegments);
	SAVE_STATE(origin);
	SAVE_STATE(m_vecTarget);
	SAVE_STATE(flags);
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
prop_rope::SpawnKey(string strKey, string strValue)
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
	default:
		super::SpawnKey(strKey, strValue);
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

	super::NSEntity();
#else
	/* this is empty for a good reason */
	drawmask = MASK_ENGINE;
#endif
}


#ifdef CLIENT
void
prop_rope_readentity(float isnew)
{
	prop_rope rope = (prop_rope)self;
	float flags = readfloat();

	if (isnew)
		spawnfunc_prop_rope();

	rope.ReadEntity(flags, isnew);
}
#endif