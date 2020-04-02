/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

class CBaseEntity
{
	string m_strTarget;
	string m_strTargetName;
	string m_oldModel;
	float m_oldSolid;
	float m_oldHealth;
	vector m_oldOrigin;
	vector m_oldAngle;
	
	int m_iBody;
	int oldnet_body;

	vector oldnet_origin;
	vector oldnet_angles;
	float oldnet_modelindex;
	vector oldnet_mins;
	vector oldnet_maxs;
	float oldnet_solid;
	float oldnet_movetype;
	float oldnet_frame;
	float oldnet_skin;
	float oldnet_effects;

#ifdef GS_RENDERFX
	int m_iRenderFX;
	float m_iRenderMode;
	float m_flRenderAmt;
	vector m_vecRenderColor;

	int m_old_iRenderFX;
	float m_old_iRenderMode;
	float m_old_flRenderAmt;
	vector m_old_vecRenderColor;
#else
	float oldnet_alpha;
#endif

	string m_parent;
	
	void() CBaseEntity;
	virtual void() Respawn;
	virtual void() Hide;
	virtual void() ParentUpdate;
	virtual float(entity, float) SendEntity;
	virtual void(int iHitBody) Pain;
	virtual void(int iHitBody) Death;
};

/* Make sure StartFrame calls this */
float CBaseEntity::SendEntity(entity ePEnt, float fChanged)
{
	if (!modelindex) {
		return FALSE;
	}

	WriteByte(MSG_ENTITY, ENT_ENTITY);
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & BASEFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	if (fChanged & BASEFL_CHANGED_ANGLES) {
		WriteFloat(MSG_ENTITY, angles[0]);
		WriteFloat(MSG_ENTITY, angles[1]);
		WriteFloat(MSG_ENTITY, angles[2]);
	}
	if (fChanged & BASEFL_CHANGED_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
	}
	if (fChanged & BASEFL_CHANGED_SOLID) {
		WriteByte(MSG_ENTITY, solid);
	}
	if (fChanged & BASEFL_CHANGED_MOVETYPE) {
		WriteByte(MSG_ENTITY, movetype);
	}
	if (fChanged & BASEFL_CHANGED_SIZE) {
		WriteCoord(MSG_ENTITY, mins[0]);
		WriteCoord(MSG_ENTITY, mins[1]);
		WriteCoord(MSG_ENTITY, mins[2]);
		WriteCoord(MSG_ENTITY, maxs[0]);
		WriteCoord(MSG_ENTITY, maxs[1]);
		WriteCoord(MSG_ENTITY, maxs[2]);
	}
	if (fChanged & BASEFL_CHANGED_FRAME) {
		WriteByte(MSG_ENTITY, frame);
	}
	if (fChanged & BASEFL_CHANGED_SKIN) {
		WriteByte(MSG_ENTITY, skin + 128);
	}
	if (fChanged & BASEFL_CHANGED_EFFECTS) {
		WriteFloat(MSG_ENTITY, effects);
	}
	if (fChanged & BASEFL_CHANGED_BODY) {
		WriteByte(MSG_ENTITY, m_iBody);
	}

#ifdef GS_RENDERFX
	if (fChanged & BASEFL_CHANGED_RENDERFX) {
		WriteByte(MSG_ENTITY, m_iRenderFX);
	}
	if (fChanged & BASEFL_CHANGED_RENDERMODE) {
		WriteByte(MSG_ENTITY, m_iRenderMode);
	}
	if (fChanged & BASEFL_CHANGED_RENDERCOLOR) {
		WriteFloat(MSG_ENTITY, m_vecRenderColor[0]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[1]);
		WriteFloat(MSG_ENTITY, m_vecRenderColor[2]);
	}
	if (fChanged & BASEFL_CHANGED_RENDERAMT) {
		WriteFloat(MSG_ENTITY, m_flRenderAmt);
	}
#else
	if (fChanged & BASEFL_CHANGED_ALPHA) {
		WriteFloat(MSG_ENTITY, alpha);
	}
#endif

	return TRUE;
}

void CBaseEntity::Pain(int body)
{
	
}

void CBaseEntity::Death(int body)
{
	
}

/* Make sure StartFrame calls this */
void CBaseEntity::ParentUpdate(void)
{
	/* Check our fields for networking */
	if (origin != oldnet_origin) {
		SendFlags |= BASEFL_CHANGED_ORIGIN;
		oldnet_origin = origin;
	}
	if (angles != oldnet_angles) {
		SendFlags |= BASEFL_CHANGED_ANGLES;
		oldnet_angles = angles;
	}
	if (modelindex != oldnet_modelindex) {
		SendFlags |= BASEFL_CHANGED_MODELINDEX;
		oldnet_modelindex = modelindex;
	}
	if (mins != oldnet_mins) {
		SendFlags |= BASEFL_CHANGED_SIZE;
		oldnet_mins = mins;
	}
	if (maxs != oldnet_maxs) {
		SendFlags |= BASEFL_CHANGED_SIZE;
		oldnet_maxs = maxs;
	}
	if (solid != oldnet_solid) {
		SendFlags |= BASEFL_CHANGED_SOLID;
		oldnet_solid = solid;
	}
	if (movetype != oldnet_movetype) {
		SendFlags |= BASEFL_CHANGED_MOVETYPE;
		oldnet_movetype = movetype;
	}
	if (frame != oldnet_frame) {
		SendFlags |= BASEFL_CHANGED_FRAME;
		oldnet_frame = frame;
	}
	if (skin != oldnet_skin) {
		SendFlags |= BASEFL_CHANGED_SKIN;
		oldnet_skin = skin;
	}
	if (effects != oldnet_effects) {
		SendFlags |= BASEFL_CHANGED_EFFECTS;
		oldnet_effects = effects;
	}
	if (m_iBody != oldnet_body) {
		SendFlags |= BASEFL_CHANGED_BODY;
		oldnet_body = m_iBody;
	}
#ifdef GS_RENDERFX
	if (m_old_iRenderFX != m_iRenderFX) {
		SendFlags |= BASEFL_CHANGED_RENDERFX;
		m_old_iRenderFX = m_iRenderFX;
	}
	if (m_old_iRenderMode != m_iRenderMode) {
		SendFlags |= BASEFL_CHANGED_RENDERMODE;
		m_old_iRenderMode = m_iRenderMode;
	}
	if (m_old_flRenderAmt != m_flRenderAmt) {
		SendFlags |= BASEFL_CHANGED_RENDERAMT;
		m_old_flRenderAmt = m_flRenderAmt;
	}
	if (m_old_vecRenderColor != m_vecRenderColor) {
		SendFlags |= BASEFL_CHANGED_RENDERCOLOR;
		m_old_vecRenderColor = m_vecRenderColor;
	}
#else
	if (alpha != oldnet_alpha) {
		SendFlags |= BASEFL_CHANGED_ALPHA;
		oldnet_alpha = alpha;
	}
#endif

	if (m_parent) {
		entity p = find(world, CBaseEntity::m_strTargetName, m_parent);

		if (!p) {
			return;
		}

		setorigin(this, p.origin);
	}
}

void CBaseEntity :: CBaseEntity ( void )
{
	/* Not in Deathmatch */
	if (spawnflags & 2048) {
		if (cvar("sv_playerslots") > 1) {
			remove(this);
			return;
		}
	}

	m_flRenderAmt = 1.0f;

	gflags = GF_CANRESPAWN;
	effects |= EF_NOSHADOW;

	int nfields = tokenize( __fullspawndata );
	for ( int i = 1; i < ( nfields - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "origin":
			origin = stov(argv(i+1));
			break;
		case "angles":
			angles = stov(argv(i+1));
			break;
		case "solid":
			solid = stof(argv(i+1));
			break;
		case "shadows":
			if (stof(argv( i + 1 )) == 1) {
				effects &= ~EF_NOSHADOW;
			}
			break;
		case "targetname":
			m_strTargetName = argv( i + 1 );
			targetname = __NULL__;
			break;
		case "target":
			m_strTarget = argv( i + 1 );
			target = __NULL__;
			break;
		case "color":
			m_vecRenderColor = stov( argv( i + 1 ) );
			break;
		case "alpha":
			m_flRenderAmt = stof( argv( i + 1 ) );
			break;
		case "renderamt":
			m_flRenderAmt = stof( argv( i + 1 ) ) / 255;
			break;
		case "rendercolor":
			m_vecRenderColor = stov( argv( i + 1 ) ) / 255;
			break;
		case "rendermode":
			m_iRenderMode = stoi( argv( i + 1 ) );
			break;
		case "renderfx":
			m_iRenderFX = stoi( argv( i + 1 ) );
			break;
		case "parentname":
			m_parent = argv(i+1);
			break;
		case "model":
			model = argv(i+1);
			break;
		default:
			break;
		}
	}

	m_oldModel = Util_FixModel(model);

	if (m_oldModel != "") {
		precache_model(m_oldModel);
	}

	m_oldSolid = solid;
	m_oldHealth = health;
	m_oldOrigin = origin;
	m_oldAngle = angles;
}

void CBaseEntity :: Respawn ( void )
{
	model = m_oldModel;
	solid = m_oldSolid;
	health = m_oldHealth;
	origin = m_oldOrigin;
	angles = m_oldAngle;
	setorigin( this, origin );

	if (model != "") {
		setmodel(this, model);
	}
}

void CBaseEntity :: Hide ( void )
{
	setmodel( this, "" );
	modelindex = 0;
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
	takedamage = DAMAGE_NO;
}
