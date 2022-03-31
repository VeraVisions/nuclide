/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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
NSEntity::ClientRemove

The client-side has received information that this entity has been
removed on the server. This is where sub-entities of a class can safely
get removed from the world as well.
============
*/
void
NSEntity::ClientRemove(void)
{
	
};
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
NSEntity::ReceiveEntity(float flNew, float flChanged)
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
	if (ATTR_CHANGED(origin)) {
		SetSendFlags(BASEFL_CHANGED_ORIGIN);
	}

	if (ATTR_CHANGED(angles)) {
		angles[0] = Math_FixDelta(angles[0]);
		angles[1] = Math_FixDelta(angles[1]);
		angles[2] = Math_FixDelta(angles[2]);
		SetSendFlags(BASEFL_CHANGED_ANGLES);
	}

	if (ATTR_CHANGED(modelindex)) {
		SetSendFlags(BASEFL_CHANGED_MODELINDEX);
	}

	if (ATTR_CHANGED(size)) {
		SetSendFlags(BASEFL_CHANGED_SIZE);
	}

	if (ATTR_CHANGED(solid)) {
		SetSendFlags(BASEFL_CHANGED_SOLID);
	}

	if (ATTR_CHANGED(movetype)) {
		SetSendFlags(BASEFL_CHANGED_MOVETYPE);
	}

	if (ATTR_CHANGED(scale)) {
		SetSendFlags(BASEFL_CHANGED_SCALE);
	}

	if (ATTR_CHANGED(velocity)) {
		SetSendFlags(BASEFL_CHANGED_VELOCITY);
	}

	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(modelindex);
	SAVE_STATE(size);
	SAVE_STATE(solid);
	SAVE_STATE(movetype);
	SAVE_STATE(scale);
	SAVE_STATE(velocity);
}

/* Make sure StartFrame calls this */
void
NSEntity::ParentUpdate(void)
{
	EvaluateEntity();

	frame1time += frametime;

	if (m_parent) {
		NSEntity parent;
		entity p = find(world, ::targetname, m_parent);

		if (p) {
			if (!m_parent_attachment) {
				parent = (NSEntity)p;
				vector ofs = parent.origin - parent.GetSpawnOrigin();
				SetOrigin(GetSpawnOrigin() + ofs);
			} else if (m_parent_attachment == "origin") {
				SetOrigin(p.origin);
			}
		}
	}
}
void
NSEntity::SetParent(string name)
{
	m_parent = name;
}
void
NSEntity::SetParentAttachment(string name)
{
	m_parent_attachment = name;
}
void
NSEntity::ClearParent(void)
{
	m_parent = __NULL__;
	m_parent_attachment = __NULL__;
}

void
NSEntity::RestoreAngles(void)
{
	angles = GetSpawnAngles();
}
void
NSEntity::ClearAngles(void)
{
	angles = [0,0,0];
}
#endif

void
NSEntity::SetOwner(entity newOwner)
{
	owner = newOwner;
};

void
NSEntity::SetVelocity(vector vecNew)
{
	if (vecNew == velocity)
		return;

	velocity = vecNew;
};

void
NSEntity::SetTouch(void() newTouch)
{
	touch = newTouch;
};

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
}
void
NSEntity::SetSolid(float newSolid)
{
	if (newSolid == solid)
		return;

	solid = newSolid;
}
void
NSEntity::SetScale(float newScale)
{
	if (newScale == scale)
		return;

	scale = newScale;
}

void
NSEntity::UpdateBounds(void)
{
	vector newMins, newMaxs;
	float flScale = 1.0f;

	newMins = m_vecMins;
	newMaxs = m_vecMaxs;

	/* avoid useless computation */
	if (angles != [0,0,0]) {
		/* adjust bbox according to rotation */
		vector vecCorner[8];
		newMins = newMaxs = [0,0,0];
		for (int i = 0; i < 8; i++) {
			vecCorner[i][0] = (i & 1) ? m_vecMins[0] : m_vecMaxs[0];
			vecCorner[i][1] = (i & 2) ? m_vecMins[1] : m_vecMaxs[1];
			vecCorner[i][2] = (i & 4) ? m_vecMins[2] : m_vecMaxs[2];
			vecCorner[i] += origin;
			vecCorner[i] = Math_RotateAroundPivot(vecCorner[i], origin, angles[1]);
			vecCorner[i] -= origin;

			if (!(vecCorner[i][0] <= newMaxs[0]))
				newMaxs[0] = vecCorner[i][0];
			if (!(vecCorner[i][1] <= newMaxs[1]))
				newMaxs[1] = vecCorner[i][1];
			if (!(vecCorner[i][2] <= newMaxs[2]))
				newMaxs[2] = vecCorner[i][2];

    			if (!(vecCorner[i][0] >= newMins[0]))
				newMins[0] = vecCorner[i][0];
    			if (!(vecCorner[i][1] >= newMins[1]))
				newMins[1] = vecCorner[i][1];
    			if (!(vecCorner[i][2] >= newMins[2]))
				newMins[2] = vecCorner[i][2];
		}
	}

	/* 0.0 is never valid, if you want it to disappear do something else */
	if (scale != 0.0)
		flScale = scale;

	setsize(this, newMins * flScale, newMaxs * flScale);
}

void
NSEntity::SetAngles(vector newAngles)
{
	if (newAngles == angles)
		return;

	angles = newAngles;
}

void
NSEntity::SetSize(vector newMins, vector newMaxs)
{
	float flScale = 1.0f;

	m_vecMins = newMins;
	m_vecMaxs = newMaxs;

	/* 0.0 is never valid, if you want it to disappear do something else */
	if (scale != 0.0)
		flScale = scale;

	setsize(this, newMins * flScale, newMaxs * flScale);
}

void
NSEntity::SetOrigin(vector newOrigin)
{
	if (newOrigin == origin)
		return;

	setorigin(this, newOrigin);
}

void
NSEntity::SetModel(string newModel)
{
	model = newModel;
	setmodel(this, newModel);

	/* mins/maxs have been updated by setmodel */
	SetSize(mins, maxs);
}
void
NSEntity::SetModelindex(float newModelIndex)
{
	if (newModelIndex == modelindex)
		return;

	modelindex = newModelIndex;
	SetSize(mins, maxs);
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
	SaveFloat(handle, "spawnflags", spawnflags);
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
	case "spawnflags":
		spawnflags = stof(strValue);
		break;
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
		setorigin(this, origin);
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
NSEntity::RestoreComplete(void)
{
	/* this is where we can handle anything post-loading */
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
	case "SetParentAttachment":
		SetParentAttachment(strData);
		break;
	case "ClearParent":
		ClearParent();
		break;
	case "Use":
		eActivator = eAct;

		if (PlayerUse)
			PlayerUse();
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
	case "spawnflags":
		spawnflags = stof(strValue);
		break;
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
NSEntity::Destroy

Call if the entity is to be removed the next possible frame.
If you want an entity to be purged immediately, you'll have to jump
through your own hoops. This however will be sufficient 99,99% of the time.
============
*/
void
NSEntity::Destroy(void)
{
	think = Util_Destroy;

	if (!time)
		nextthink = time + 0.01;
	else
		nextthink = time;
};

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
#else
	isCSQC = 1;
#endif
}
