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

enum
{ 
	RM_NORMAL,
	RM_COLOR,
	RM_TEXTURE,
	RM_GLOW,
	RM_SOLID,
	RM_ADDITIVE
};

// keep in sync with client/baseentity.cpp
enumflags
{
	BASEFL_CHANGED_ORIGIN,
	BASEFL_CHANGED_ANGLES,
	BASEFL_CHANGED_MODELINDEX,
	BASEFL_CHANGED_SIZE,
	BASEFL_CHANGED_SOLID,
	BASEFL_CHANGED_FRAME,
	BASEFL_CHANGED_SKIN,
	BASEFL_CHANGED_MOVETYPE,
	BASEFL_CHANGED_ALPHA,
	BASEFL_CHANGED_EFFECTS
};

class CBaseEntity
{
	string m_strTarget;
	string m_strTargetName;
	string m_oldModel;
	float m_oldSolid;
	float m_oldHealth;
	vector m_oldOrigin;
	vector m_oldAngle;
	
	vector oldnet_origin;
	vector oldnet_angles;
	float oldnet_modelindex;
	vector oldnet_mins;
	vector oldnet_maxs;
	float oldnet_solid;
	float oldnet_movetype;
	float oldnet_alpha;
	float oldnet_frame;
	float oldnet_skin;
	float oldnet_effects;
	
	float m_rendermode;
	float m_renderamt;
	vector m_rendercolor;
	string m_parent;
	
	void() CBaseEntity;
	virtual void() Respawn;
	virtual void() Hide;
	virtual void() RendermodeUpdate;
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
	if (fChanged & BASEFL_CHANGED_ALPHA) {
		WriteFloat(MSG_ENTITY, alpha);
	}
	if (fChanged & BASEFL_CHANGED_EFFECTS) {
		WriteFloat(MSG_ENTITY, effects);
	}

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
	if (alpha != oldnet_alpha) {
		SendFlags |= BASEFL_CHANGED_ALPHA;
		oldnet_alpha = alpha;
	}
	if (effects != oldnet_effects) {
		SendFlags |= BASEFL_CHANGED_EFFECTS;
		oldnet_effects = effects;
	}
	
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

	/*m_renderamt = 255;
	m_rendercolor = [1,1,1];
	m_rendermode = 0;*/

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
			m_rendercolor = stov( argv( i + 1 ) );
			break;
		case "alpha":
			m_renderamt = stof( argv( i + 1 ) );
			break;
		case "renderamt":
			m_renderamt = stof( argv( i + 1 ) ) / 255;
			break;
		case "rendercolor":
			m_rendercolor = stov( argv( i + 1 ) ) / 255;
			break;
		case "rendermode":
			m_rendermode = stof( argv( i + 1 ) );
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

	RendermodeUpdate();
}

void CBaseEntity::RendermodeUpdate(void)
{
	if (m_rendermode == RM_NORMAL) {
		return;
	}
	
	if (m_rendermode == RM_SOLID && m_renderamt != 0) {
		return;
	}

	colormod = m_rendercolor;
	alpha = bound(0.001, m_renderamt, 1.0);

	if ( m_rendermode == RM_ADDITIVE ) {
		effects = EF_FLAG2; // SSQC: EF_ADDITIVE
	} else if ( m_rendermode == RM_GLOW ) {
		effects = EF_FLAG2 | EF_FULLBRIGHT;
	}
	
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
