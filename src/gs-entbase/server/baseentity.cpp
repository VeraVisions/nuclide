/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/* we want to really use those set functions because they'll notify of any
 * networking related changes. otherwise we'll have to keep track of copies
 * that get updated every frame */
void
CBaseEntity::SetEffects(float newEffects)
{
	if (newEffects == effects)
		return;

	effects = newEffects;
	SendFlags |= BASEFL_CHANGED_EFFECTS;
}
void
CBaseEntity::SetFrame(float newFrame)
{
	if (newFrame == frame)
		return;

	frame = newFrame;
	frame1time = 0.0f;
	SendFlags |= BASEFL_CHANGED_FRAME;
}
void
CBaseEntity::SetModel(string newModel)
{
	model = newModel;
	setmodel(this, newModel);
	SendFlags |= BASEFL_CHANGED_MODELINDEX;
}
void
CBaseEntity::SetModelindex(float newModelIndex)
{
	if (newModelIndex == modelindex)
		return;

	modelindex = newModelIndex;
	SendFlags |= BASEFL_CHANGED_MODELINDEX;
}
void
CBaseEntity::SetMovetype(float newMovetype)
{
	if (newMovetype == movetype)
		return;

	movetype = newMovetype;
	SendFlags |= BASEFL_CHANGED_MOVETYPE;
}
void
CBaseEntity::SetSkin(float newSkin)
{
	if (newSkin == skin)
		return;

	skin = newSkin;
	SendFlags |= BASEFL_CHANGED_SKIN;
}
void
CBaseEntity::SetSolid(float newSolid)
{
	if (newSolid == solid)
		return;

	solid = newSolid;
	SendFlags |= BASEFL_CHANGED_SOLID;
}
void
CBaseEntity::SetBody(int newBody)
{
	if (newBody == m_iBody)
		return;

	m_iBody = newBody;
	SendFlags |= BASEFL_CHANGED_BODY;
}
void
CBaseEntity::SetScale(float newScale)
{
	if (newScale == scale)
		return;

	scale = newScale;
	SendFlags |= BASEFL_CHANGED_SCALE;
}
void
CBaseEntity::SetAngles(vector newAngles)
{
	if (newAngles == angles)
		return;

	angles = newAngles;
	SendFlags |= BASEFL_CHANGED_ANGLES;
}
void
CBaseEntity::SetSize(vector newMins, vector newMaxs)
{
	if (newMins == mins && newMaxs == maxs)
		return;

	setsize(this, newMins, newMaxs);
	SendFlags |= BASEFL_CHANGED_SIZE;
}
void
CBaseEntity::SetOrigin(vector newOrigin)
{
	if (newOrigin == origin)
		return;

	setorigin(this, newOrigin);
	SendFlags |= BASEFL_CHANGED_ORIGIN;
}

#ifdef GS_RENDERFX
void
CBaseEntity::SetRenderFX(int newFX)
{
	if (newFX == m_iRenderFX)
		return;

	m_iRenderFX = newFX;
	SendFlags |= BASEFL_CHANGED_RENDERFX;
}
void
CBaseEntity::SetRenderMode(float newMode)
{
	if (newMode == m_iRenderMode)
		return;

	m_iRenderMode = newMode;
	SendFlags |= BASEFL_CHANGED_RENDERMODE;
}
void
CBaseEntity::SetRenderAmt(float newAmt)
{
	if (newAmt == m_flRenderAmt)
		return;

	m_flRenderAmt = newAmt;
	SendFlags |= BASEFL_CHANGED_RENDERAMT;
}
void
CBaseEntity::SetRenderColor(vector newColor)
{
	if (newColor == m_vecRenderColor)
		return;

	m_vecRenderColor = newColor;
	SendFlags |= BASEFL_CHANGED_RENDERCOLOR;
}
#endif

/* Make sure StartFrame calls this */
float
CBaseEntity::SendEntity(entity ePEnt, float fChanged)
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
	if (fChanged & BASEFL_CHANGED_SCALE) {
		WriteFloat(MSG_ENTITY, scale);
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

void
CBaseEntity::Pain(void)
{
	
}

void
CBaseEntity::Death(void)
{
	
}

/* Make sure StartFrame calls this */
void
CBaseEntity::ParentUpdate(void)
{
	/* while the engine is still handling physics for these, we can't
	 * predict when origin/angle might change */
	if (net_origin != origin) {
		net_origin = origin;
		SendFlags |= BASEFL_CHANGED_ORIGIN;
	}
	if (net_angles != angles) {
		net_angles = angles;
		SendFlags |= BASEFL_CHANGED_ANGLES;
	}

	if (m_parent) {
		entity p = find(world, ::targetname, m_parent);

		if (!p) {
			return;
		}

		SetOrigin(p.origin);
	}
}

void
CBaseEntity::SpawnInit(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		SpawnKey(argv(i), argv(i+1));
	}

	/* some entity might involuntarily call SpawnInit as part of being
	   a member of CBaseEntity. So we need to make sure that it doesn't
	   inherit stuff from the last previously loaded entity */
	__fullspawndata = "";
}

void
CBaseEntity::Respawn(void)
{
	health = m_oldHealth;
	SetModel(m_oldModel);
	SetSolid(m_oldSolid);
	SetAngles(m_oldAngle);
	SetOrigin(m_oldOrigin);
	target = m_oldstrTarget;

#ifdef GS_RENDERFX
	SetRenderFX(m_oldiRenderFX);
	SetRenderMode(m_oldiRenderMode);
	SetRenderAmt(m_oldflRenderAmt);
	SetRenderColor(m_oldvecRenderColor);
#endif
}

void
CBaseEntity::Hide(void)
{
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	takedamage = DAMAGE_NO;
}

void
CBaseEntity::SpawnKey(string strKey, string strValue)
{
	/* we do re-read a lot of the builtin fields in case we want to set
	   defaults. just in case anybody is wondering. */
	switch (strKey) {
	case "scale":
		scale = stof(strValue);
		break;
	case "origin":
		origin = stov(strValue);
		break;
	case "angles":
		angles = stov(strValue);
		break;
	case "angle":
		angles[1] = stof(strValue);
		break;
	case "solid":
		solid = stof(strValue);
		break;
	case "health":
		health = stof(strValue);
		break;
	case "shadows":
		if (stof(strValue) == 1) {
			effects &= ~EF_NOSHADOW;
		}
		break;
	case "targetname":
		targetname = strValue;
		break;
	case "target":
		target = strValue;
		break;
	case "color":
#ifdef GS_RENDERFX
		m_vecRenderColor = stov(strValue);
#else
		colormod = stov(strValue);
#endif
		break;
	case "alpha":
#ifdef GS_RENDERFX
		m_flRenderAmt = stof(strValue);
#else
		alpha = stof(strValue);
#endif
		break;
#ifdef GS_RENDERFX
	case "renderamt":
		m_flRenderAmt = stof(strValue) / 255;
		break;
	case "rendercolor":
		m_vecRenderColor = stov(strValue) / 255;
		break;
	case "rendermode":
		m_iRenderMode = stoi(strValue);
		break;
	case "renderfx":
		m_iRenderFX = stoi(strValue);
		break;
#endif
	case "parentname":
		m_parent = strValue;
		break;
	case "model":
		model = strValue;
		break;
	case "classname":
	case "spawnflags":
		break;
	default:
		print(sprintf("^3%s^7::SpawnKey:: Unknown key '%s' with value '%s'\n",
		      classname, strKey, strValue));
		break;
	}
}

void
CBaseEntity::CBaseEntity(void)
{
	/* Not in Deathmatch */
	if (spawnflags & 2048) {
		if (cvar("sv_playerslots") > 1) {
			remove(this);
			return;
		}
	}

	identity = 1;
	effects |= EF_NOSHADOW;
	scale = 1.0f;

	SpawnInit();

	m_oldAngle = angles;
	m_oldOrigin = origin;
	m_oldSolid = solid;
	m_oldHealth = health;
	m_oldModel = Util_FixModel(model);

#ifdef GS_RENDERFX
	m_oldiRenderFX = m_iRenderFX;
	m_oldiRenderMode = m_iRenderMode;
	m_oldvecRenderColor = m_vecRenderColor;
	m_oldflRenderAmt = m_flRenderAmt;
	m_oldvecRenderColor = m_vecRenderColor;
	m_oldflRenderAmt = m_flRenderAmt;
#endif

	m_oldstrTarget = target;

	if (m_oldModel != "") {
		precache_model(m_oldModel);
	}
}
