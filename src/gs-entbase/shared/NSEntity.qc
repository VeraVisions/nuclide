/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

#ifdef CLIENT
/*
============
NSEntity::RendererRestarted

make sure any child-classes precache their assets in here
for vid_reload calls or other sudden deaths (driver restarts)
============
*/
void
NSEntity::RendererRestarted(void)
{
	
};

/*
============
NSEntity::ReceiveEntity
============
*/
void
NSEntity::ReceiveEntity(float flChanged)
{
	if (flChanged & BASEFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}
	if (flChanged & BASEFL_CHANGED_ANGLES) {
		angles[0] = readshort() / (32767 / 360);
		angles[1] = readshort() / (32767 / 360);
		angles[2] = readshort() / (32767 / 360);
	}
	if (flChanged & BASEFL_CHANGED_MODELINDEX) {
		setmodelindex(this, readshort());
	}
	if (flChanged & BASEFL_CHANGED_SOLID) {
		solid = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_MOVETYPE) {
		movetype = readbyte();

		if (movetype == MOVETYPE_PHYSICS) {
			movetype = MOVETYPE_NONE;
		}
	}
	if (flChanged & BASEFL_CHANGED_SIZE) {
		mins[0] = readcoord();
		mins[1] = readcoord();
		mins[2] = readcoord();
		maxs[0] = readcoord();
		maxs[1] = readcoord();
		maxs[2] = readcoord();
		setsize(this, mins, maxs);
	}

	if (flChanged & BASEFL_CHANGED_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

	if (modelindex) {
		drawmask = MASK_ENGINE;
	} else {
		drawmask = 0;
	}

	if (scale == 0.0)
		scale = 1.0f;

	setorigin(this, origin);
}

/*
============
NSEntity::postdraw
============
*/
void
NSEntity::postdraw(void)
{
}


#else
void
NSEntity::Show(void)
{
	alpha = 1.0f;
}

void
NSEntity::Hide(void)
{
	alpha = 0.0f;
}

/* Make sure StartFrame calls this */
float
NSEntity::SendEntity(entity ePEnt, float fChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	if (alpha == 0.0f)
		return (0);

	WriteByte(MSG_ENTITY, ENT_ENTITY);

	/* newly popped into the PVS, sadly this is the only hacky way to check
	 * for this right now. convince the engine maintainer to make this more sensible */
	if (fChanged == 0xFFFFFF) {
		/* check for defaults. if these are predictable fields, don't even bother
		 * networking them! you're just wasting bandwidth. */
		if (scale == 0.0 || scale == 1.0)
			fChanged &= ~BASEFL_CHANGED_SCALE;
		if (origin == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_ORIGIN;
		if (angles == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_ANGLES;
		if (velocity == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_VELOCITY;
		if (mins == [0,0,0] && maxs == [0,0,0])
			fChanged &= ~BASEFL_CHANGED_SIZE;
		if (solid == SOLID_NOT)
			fChanged &= ~BASEFL_CHANGED_SOLID;
		if (movetype == MOVETYPE_NONE)
			fChanged &= ~BASEFL_CHANGED_MOVETYPE;
	}

	/* don't network triggers unless provoked */
	/*if (cvar("developer") == 0 && m_iRenderMode == RM_TRIGGER)
		return (0);*/

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & BASEFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}
	if (fChanged & BASEFL_CHANGED_ANGLES) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
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
	if (fChanged & BASEFL_CHANGED_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

	return (1);
}

void
NSEntity::EvaluateEntity(void)
{
	/* while the engine is still handling physics for these, we can't
	 * predict when origin/angle might change */
	if (net_origin != origin) {
		net_origin = origin;
		SetSendFlags(BASEFL_CHANGED_ORIGIN);
	}
	if (net_angles != angles) {
		angles[0] = Math_FixDelta(angles[0]);
		angles[1] = Math_FixDelta(angles[1]);
		angles[2] = Math_FixDelta(angles[2]);

		net_angles = angles;
		SetSendFlags(BASEFL_CHANGED_ANGLES);
	}
	if (net_velocity != velocity) {
		net_velocity = velocity;
		SetSendFlags(BASEFL_CHANGED_VELOCITY);
	}
}

/* Make sure StartFrame calls this */
void
NSEntity::ParentUpdate(void)
{
	EvaluateEntity();

	frame1time += frametime;

	if (m_parent) {
		entity p = find(world, ::targetname, m_parent);

		if (p)
			SetOrigin(p.origin);
	}
}
void
NSEntity::SetParent(string name)
{
	m_parent = name;
}
void
NSEntity::ClearParent(void)
{
	m_parent = __NULL__;
}
#endif

/* we want to really use those set functions because they'll notify of any
 * networking related changes. otherwise we'll have to keep track of copies
 * that get updated every frame */
void
NSEntity::SetSendFlags(float flSendFlags)
{
#ifdef SERVER
	SendFlags |= flSendFlags;
#endif
}

void
NSEntity::SetMovetype(float newMovetype)
{
	if (newMovetype == movetype)
		return;

	movetype = newMovetype;
	SetSendFlags(BASEFL_CHANGED_MOVETYPE);
}
void
NSEntity::SetSolid(float newSolid)
{
	if (newSolid == solid)
		return;

	solid = newSolid;
	SetSendFlags(BASEFL_CHANGED_SOLID);
}

void
NSEntity::SetAngles(vector newAngles)
{
	if (newAngles == angles)
		return;

	angles = newAngles;
	SetSendFlags(BASEFL_CHANGED_ANGLES);
}
void
NSEntity::SetSize(vector newMins, vector newMaxs)
{
	if (newMins == mins && newMaxs == maxs)
		return;

	setsize(this, newMins, newMaxs);
	SetSendFlags(BASEFL_CHANGED_SIZE);
}
void
NSEntity::SetOrigin(vector newOrigin)
{
	if (newOrigin == origin)
		return;

	setorigin(this, newOrigin);
	SetSendFlags(BASEFL_CHANGED_ORIGIN);
}


void
NSEntity::SetModel(string newModel)
{
	model = newModel;
	setmodel(this, newModel);
	SetSendFlags(BASEFL_CHANGED_MODELINDEX);
}
void
NSEntity::SetModelindex(float newModelIndex)
{
	if (newModelIndex == modelindex)
		return;

	modelindex = newModelIndex;
	SetSendFlags(BASEFL_CHANGED_MODELINDEX);
}


#ifdef SERVER
vector
NSEntity::GetSpawnOrigin(void)
{
	return m_oldOrigin;
}
vector
NSEntity::GetSpawnAngles(void)
{
	return m_oldAngle;
}
string
NSEntity::GetSpawnModel(void)
{
	return m_oldModel;
}

void
NSEntity::Respawn(void)
{
	NSTrigger::Respawn();

	SetSolid(m_oldSolid);
	SetAngles(GetSpawnAngles());
	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());
	target = m_oldstrTarget; /* FIXME: Move into NSTrigger::Respawn */
}

void
NSEntity::Save(float handle)
{
	SaveVector(handle, "origin", origin);
	SaveVector(handle, "absmin", absmin);
	SaveVector(handle, "absmax", absmax);
	SaveVector(handle, "mins", mins);
	SaveVector(handle, "maxs", maxs);
	SaveString(handle, "model", model);
	SaveVector(handle, "angles", angles);
	SaveFloat(handle, "solid", solid);
	SaveFloat(handle, "movetype", movetype);
	SaveFloat(handle, "health", health);
	SaveString(handle, "parentname", m_parent);
	SaveFloat(handle, "pvsflags", pvsflags);
	super::Save(handle);
}
void
NSEntity::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "origin":
		origin = stov(strValue);
		setorigin(this, origin);
		break;
	case "absmin":
		absmin = stov(strValue);
		break;
	case "absmax":
		absmax = stov(strValue);
		break;
	case "mins":
		mins = stov(strValue);
		setsize(this, mins, maxs);
		break;
	case "maxs":
		maxs = stov(strValue);
		setsize(this, mins, maxs);
		break;
	case "model":
		model = strValue;
		setmodel(this, model);
		break;
	case "angles":
		angles = stov(strValue);
		break;
	case "solid":
		solid = stof(strValue);
		break;
	case "movetype":
		movetype = stof(strValue);
		break;
	case "health":
		health = stof(strValue);
		break;
	case "parentname":
		if (strValue != "")
			SetParent(strValue);
		break;
	case "pvsflags":
		pvsflags = stof(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
NSEntity::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Kill":
		think = Util_Destroy;
		nextthink = time;
		break;
	case "KillHierarchy":
		/* this works because ents are basically just entnums */
		for (entity e = world; (e=findfloat(e, ::owner, this));) {
			e.think = Util_Destroy;
			e.nextthink = time;
		}
		think = Util_Destroy;
		nextthink = time;
		break;
	case "SetParent":
		SetParent(strData);
		break;
	case "ClearParent":
		ClearParent();
		break;
	default:
		NSTrigger::Input(eAct, strInput, strData);
	}
}
#endif

/*
============
NSEntity::SpawnKey

note that the engine still likes to try and map key/value
pairs on its own, but we can at least undo some of that in
here if needed
============
*/
void
NSEntity::SpawnKey(string strKey, string strValue)
{
	/* we do re-read a lot of the builtin fields in case we want to set
	   defaults. just in case anybody is wondering. */
	switch (strKey) {
	case "origin":
		origin = stov(strValue);
		break;
	case "model":
		model = strValue;
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
#ifdef SERVER
	case "health":
		health = stof(strValue);
		break;
	case "parentname":
		SetParent(strValue);
		break;
	case "ignorepvs":
		pvsflags = PVSF_IGNOREPVS;
		break;
#endif
	default:
		NSTrigger::SpawnKey(strKey, strValue);
		break;
	}
}

/*
============
NSEntity::NSEntity

client doesn't have to do a whole lot here
============
*/
void
NSEntity::NSEntity(void)
{
#ifdef SERVER
	/* don't call this function more than once per entity */
	if (identity == 1)
		return;

	identity = 1; /* .identity is a global ent field we abuse to let find() calls
			reliably know that those are NSEntity class-based */

	super::NSTrigger();

	m_oldAngle = angles;
	m_oldOrigin = origin;
	m_oldSolid = solid;
	m_oldModel = Util_FixModel(model);

	/* Input/Output system */
	m_strOnTrigger = CreateOutput(m_strOnTrigger);

	m_oldstrTarget = target;

	if (m_oldModel != "") {
		precache_model(GetSpawnModel());
	}
#endif
}
