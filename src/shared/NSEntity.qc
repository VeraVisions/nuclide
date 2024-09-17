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

static bool
droptofloorwrapper(entity foo)
{
	bool result;
	entity old_self = self;
	self = foo;
	result = droptofloor();
	self = old_self;
	return result;
}

void
NSEntity::NSEntity(void)
{
	identity = 1;
	m_flSpawnTime = time;
	m_vecEditorColor = [1,1,1];
}

void
NSEntity::Spawned(void)
{
	super::Spawned();

#ifdef SERVER
	if (model) {
		precache_model(model);
	}

	if (m_strOnTrigger != "") {
		m_strOnTrigger = CreateOutput(m_strOnTrigger);
	}

	/* used to network our shared ID */
	entityDefID = EntityDef_NetIDFromName(classname);
#endif
}

float
NSEntity::EntIndex(void)
{
	return (num_for_edict(this));
}

bool
NSEntity::DropToFloor(void)
{
	return droptofloorwrapper(this);
}

vector
NSEntity::GetForward(void)
{
	return anglesToForward(angles);
}

vector
NSEntity::GetRight(void)
{
	return anglesToRight(angles);
}

vector
NSEntity::GetUp(void)
{
	return anglesToUp(angles);
}

vector
NSEntity::WorldSpaceCenter(void)
{
	return (absmin + (0.5 * (absmax - absmin)));
}

float
NSEntity::WaterLevel(void)
{
	return (waterlevel);
}

bool
NSEntity::VisibleVec(vector org)
{
	vector flDelta;
	float flFoV;

	flDelta = vectorNormalize(org - origin);
	flFoV = flDelta * GetForward();

	if (flFoV > 0.3f) {
		traceline(origin, org, TRUE, this);

		if (trace_fraction == 1.0f) {
			return (true);
		}
	}

	return (false);
}

bool
NSEntity::Visible(entity ent)
{
	/* is it in our field of view? */
	if (DistanceFromYaw(ent.origin) > 0.3f) {
		traceline(origin, ent.origin, MOVE_NORMAL, this);

		if (trace_fraction == 1.0f || trace_ent == ent) {
			/*print(sprintf("%s can see %s\n", classname, ent.classname));*/
			return (true);
		}
	}

	/*print(sprintf("%s can not see %s\n", classname, ent.classname));*/
	return (false);
}

float
NSEntity::DistanceFromYaw(vector targetPos)
{
	return vectorNormalize(targetPos - origin) * GetForward();
}

bool
NSEntity::HasSpawnFlags(float sf)
{
	return (spawnflags & sf) ? (true) : (false);
}

bool
NSEntity::IsOnGround(void)
{
	return (flags & FL_ONGROUND) ? (true) : (false);
}

bool
NSEntity::IsSolid(void)
{
	return (solid != SOLID_NOT) ? (true) : (false);
}

entity
NSEntity::GetGroundEntity(void)
{
	return (groundentity);
}

bool
NSEntity::CreatedByMap(void)
{
	return (_mapspawned);
}

#ifdef CLIENT
void
NSEntity::RendererRestarted(void)
{

}

float
NSEntity::predraw(void)
{
	if (GetModelindex() == 0 || IsHidden()) {
		return (PREDRAW_NEXT);
	}

	addentity(this);
	return (PREDRAW_NEXT);
}

void
NSEntity::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], BASEFL_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], BASEFL_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], BASEFL_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], BASEFL_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], BASEFL_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], BASEFL_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, BASEFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, BASEFL_CHANGED_SOLID)
	READENTITY_BYTE(movetype, BASEFL_CHANGED_FLAGS)
	READENTITY_INT(flags, BASEFL_CHANGED_FLAGS)
	READENTITY_INT(vv_flags, BASEFL_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(mins[1], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(mins[2], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], BASEFL_CHANGED_SIZE)
	READENTITY_BYTE(frame, BASEFL_CHANGED_FRAME)
	READENTITY_FLOAT(skin, BASEFL_CHANGED_SKIN)
	READENTITY_FLOAT(effects, BASEFL_CHANGED_EFFECTS)
	READENTITY_FLOAT(scale, BASEFL_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], BASEFL_CHANGED_VELOCITY_X)
	READENTITY_COORD(velocity[1], BASEFL_CHANGED_VELOCITY_Y)
	READENTITY_COORD(velocity[2], BASEFL_CHANGED_VELOCITY_Z)
	READENTITY_COORD(avelocity[0], BASEFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], BASEFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], BASEFL_CHANGED_ANGULARVELOCITY)

	drawmask = (modelindex != 0) ? MASK_ENGINE : 0;

	if (scale == 0.0f) {
		scale = 1.0f;
	}

	if (flChanged & BASEFL_CHANGED_SIZE) {
		setsize(this, mins, maxs);
	}
}

void
NSEntity::ReceiveEvent(float eventType)
{
	switch (eventType) {
	default:
		EntError("Unknown event %d", eventType);
	}
}

void
NSEntity::postdraw(void)
{
}


#else
void
NSEntity::DebugDraw(void)
{
	DebugBox(GetOrigin(), GetMins(), GetMaxs(), m_vecEditorColor, 0.75f);
}

float
NSEntity::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex) {
		return (0);
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (0);
	}

	WriteByte(MSG_ENTITY, ENT_ENTITY);

	/* optimisation */
	{
		/* we'll never network these if we aren't moving. */
		if (movetype == MOVETYPE_NONE) {
			flChanged &= ~BASEFL_CHANGED_VELOCITY_X;
			flChanged &= ~BASEFL_CHANGED_VELOCITY_Y;
			flChanged &= ~BASEFL_CHANGED_VELOCITY_Z;
			flChanged &= ~BASEFL_CHANGED_ANGULARVELOCITY;
		}

		if (m_bIsBrush == true) {
			flChanged &= ~BASEFL_CHANGED_FLAGS;
			flChanged &= ~BASEFL_CHANGED_SCALE;
		}
	}

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], BASEFL_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], BASEFL_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], BASEFL_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], BASEFL_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], BASEFL_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], BASEFL_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, BASEFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, BASEFL_CHANGED_SOLID)
	SENDENTITY_BYTE(movetype, BASEFL_CHANGED_FLAGS)
	SENDENTITY_INT(flags, BASEFL_CHANGED_FLAGS)
	SENDENTITY_INT(vv_flags, BASEFL_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], BASEFL_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, BASEFL_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, BASEFL_CHANGED_SKIN)
	SENDENTITY_FLOAT(effects, BASEFL_CHANGED_EFFECTS)
	SENDENTITY_FLOAT(scale, BASEFL_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], BASEFL_CHANGED_VELOCITY_X)
	SENDENTITY_COORD(velocity[1], BASEFL_CHANGED_VELOCITY_Y)
	SENDENTITY_COORD(velocity[2], BASEFL_CHANGED_VELOCITY_Z)
	SENDENTITY_COORD(avelocity[0], BASEFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], BASEFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], BASEFL_CHANGED_ANGULARVELOCITY)
	return (1);
}

void
NSEntity::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, BASEFL_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, BASEFL_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, BASEFL_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, BASEFL_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, BASEFL_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, BASEFL_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, BASEFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, BASEFL_CHANGED_SOLID)
	EVALUATE_FIELD(movetype, BASEFL_CHANGED_FLAGS)
	EVALUATE_FIELD(flags, BASEFL_CHANGED_FLAGS)
	EVALUATE_FIELD(vv_flags, BASEFL_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, BASEFL_CHANGED_SIZE)
	EVALUATE_FIELD(frame, BASEFL_CHANGED_FRAME)
	EVALUATE_FIELD(skin, BASEFL_CHANGED_SKIN)
	EVALUATE_FIELD(effects, BASEFL_CHANGED_EFFECTS)
	EVALUATE_FIELD(scale, BASEFL_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, BASEFL_CHANGED_VELOCITY_X)
	EVALUATE_VECTOR(velocity, 1, BASEFL_CHANGED_VELOCITY_Y)
	EVALUATE_VECTOR(velocity, 2, BASEFL_CHANGED_VELOCITY_Z)
	EVALUATE_VECTOR(avelocity, 0, BASEFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, BASEFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, BASEFL_CHANGED_ANGULARVELOCITY)
}

/* Make sure StartFrame calls this */
void
NSEntity::ParentUpdate(void)
{
	EvaluateEntity();

	frame1time += frametime;

	/* handle end-touch */
	if (m_beingTouched == true) {
		if (m_flTouchTime < GetTime()) {
			EndTouch(m_eTouchLast);
			m_beingTouched = false;
			m_eTouchLast = __NULL__;
		}
	}
}

entity
NSEntity::GetParent(void)
{
	return tag_entity;
}

void
NSEntity::SetParent(string name)
{
	tag_entity = find(world, ::targetname, name);
}

void
NSEntity::SetParentAttachment(string name)
{
	if (name != "origin") {
		tag_index = gettagindex(tag_entity, name);
	} else {
		tag_index = 0;
	}
}

void
NSEntity::ClearParent(void)
{
	tag_entity = world;
	tag_index = 0;
}

void
NSEntity::RestoreAngles(void)
{
	vector spawnAngles = g_vec_null;
	string spawnAngleString = GetSpawnString("angles");

	if (spawnAngleString == "") {
		spawnAngles[1] = GetSpawnFloat("angle");
	} else {
		spawnAngles = stov(spawnAngleString);
	}

	SetAngles(spawnAngles);
}

void
NSEntity::ClearAngles(void)
{
	SetAngles(g_vec_null);
}

void
NSEntity::ForceNetworkUpdate(void)
{
	SendFlags = -1;
}

void
NSEntity::UseBy(entity ourActivator)
{
	if (PlayerUse) {
		eActivator = (NSEntity)ourActivator;
		PlayerUse();
	}
}
#endif

void
NSEntity::SetEffects(float newEffects)
{
	effects = newEffects;
}

void
NSEntity::SetFrame(float newFrame)
{
	if (newFrame == frame) {
		return;
	}

	frame = newFrame;
	frame1time = 0.0f;


#ifdef SERVER
	/* check if an event callback exists */
	{
		int eDefEvents;
		string ourName;

		if (modelframecount(modelindex) > 0) {
			ourName = frametoname(modelindex, frame);
		} else {
			return;
		}

		eDefEvents = tokenize(m_strModelEventCB);

		for (int i = 0; i < eDefEvents; i+=3) {
			string testName = argv(i+0);
			string testInput = argv(i+1);
			string testData = argv(i+2);

			if (ourName == testName) {
				if (testData != "") {
					Input(this, testInput, testData);
				} else {
					Input(this, testInput, ""); /* no parms passed. */
				}

				tokenize(m_strModelEventCB); /* ensure argv() is 'rewound'... */
			}
		}
	}
#endif
}

void
NSEntity::SetSkin(float newSkin)
{
	skin = newSkin;
}

void
NSEntity::SetOwner(entity newOwner)
{
	owner = newOwner;
}

void
NSEntity::SetVelocity(vector vecNew)
{
	velocity = vecNew;
}

void
NSEntity::SetTouch(void ()newTouch)
{
	touch = newTouch;
}

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
	movetype = newMovetype;
}

void
NSEntity::SetGravity(float newGrav)
{
	gravity = newGrav;
}

void
NSEntity::SetSolid(float newSolid)
{
	solid = newSolid;
}

void
NSEntity::SetScale(float newScale)
{
	if (newScale == scale) {
		return;
	}

	scale = newScale;
	setsize(this, m_vecMins * scale, m_vecMaxs * scale);
}

vector
NSEntity::GetViewAngle(void)
{
	if (isSentient(this)) {
		return (v_angle);
	} else {
		return (angles);
	}
}

void
NSEntity::SetEyePos(vector value)
{
	view_ofs = value;
}

vector
NSEntity::GetEyePos(void)
{
	if (HasVFlags(VFL_FAKESPEC)) {
		return (origin);
	}

	return (origin + view_ofs);
}

void
NSEntity::UpdateBounds(void)
{
	vector newMins, newMaxs;
	float flScale = 1.0f;

	newMins = m_vecMins;
	newMaxs = m_vecMaxs;

	/* avoid useless computation */
	if (angles != [0, 0, 0]) {
		/* adjust bbox according to rotation */
		vector vecCorner[8];

		newMins = newMaxs =[0, 0, 0];
		for (int i = 0; i < 8; i++) {
			vecCorner[i][0] = (i & 1) ? m_vecMins[0] : m_vecMaxs[0];
			vecCorner[i][1] = (i & 2) ? m_vecMins[1] : m_vecMaxs[1];
			vecCorner[i][2] = (i & 4) ? m_vecMins[2] : m_vecMaxs[2];
			vecCorner[i] += origin;
			vecCorner[i] = rotateAroundPoint(vecCorner[i], origin, angles[1]);
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
	if (scale != 0.0) {
		flScale = scale;
	}

	setsize(this, newMins * flScale, newMaxs * flScale);
}

void
NSEntity::SetAngles(vector newAngles)
{
	angles = newAngles;
}

void
NSEntity::SetAngularVelocity(vector newAvel)
{
	avelocity = newAvel;
}

void
NSEntity::SetSize(vector newMins, vector newMaxs)
{
	float flScale = 1.0f;

	m_vecMins = newMins;
	m_vecMaxs = newMaxs;

	/* 0.0 is never valid, if you want it to disappear do something else */
	if (scale != 0.0f) {
		flScale = scale;
	}

	setsize(this, newMins * flScale, newMaxs * flScale);
}

void
NSEntity::SetOrigin(vector newOrigin)
{
	setorigin(this, newOrigin);
}

void
NSEntity::SetOriginUnstick(vector newOrigin)
{
	setorigin_safe(this, newOrigin);
}

void
NSEntity::SetModel(string newModel)
{
	m_bIsBrush = substring(newModel, 0, 1) == "*" ? true : false;
	model = newModel;
	setmodel(this, newModel);

	/* mins/maxs have been updated by setmodel */
	SetSize(mins, maxs);
}

void
NSEntity::SetModelindex(float newModelIndex)
{
	if (newModelIndex == modelindex) {
		return;
	}

	modelindex = newModelIndex;
	SetSize(mins, maxs);
}

void
NSEntity::AddAngularVelocity(vector addVel)
{
	avelocity += addVel;
}

void
NSEntity::AddVelocity(vector addVel)
{
	velocity += addVel;
}

void
NSEntity::AddEffects(float fl) {
	effects |= fl;
}

void
NSEntity::RemoveEffects(float fl) {
	effects &= ~fl;
}


void
NSEntity::AddFlags(float fl) {
	flags |= fl;
}

void
NSEntity::RemoveFlags(float fl) {
	flags &= ~fl;
}


void
NSEntity::AddVFlags(float fl) {
	vv_flags |= fl;
}

void
NSEntity::RemoveVFlags(float fl) {
	vv_flags &= ~fl;
}

void
NSEntity::TurnTo(float targetAngle) {
	angles[1] = targetAngle;
}

void
NSEntity::TurnToPos(vector targetPos) {
	angles = vectorToAngles(targetPos - WorldSpaceCenter());
}

void
NSEntity::SetThink(void (void) func) {
	think = func;
}

void
NSEntity::SetNextThink(float fl) {
	float flTime = GetTime() + fl;

	/* HACK: to make sure things happen post-spawn */
	if (flTime == 0.0f) {
		flTime = 0.001f;
	}

	if (flTime >= 0) {
		nextthink = flTime;
	} else {
		EntError("%s sets bogus nextthink value %f", classname, flTime);
	}
}

void
NSEntity::ScheduleThink(void (void) func, float fl) {
	SetThink(func);
	SetNextThink(fl);
}

float
NSEntity::GetEffects(void) {
	return (effects);
}

float
NSEntity::GetFrame(void) {
	return (frame);
}

float
NSEntity::GetSkin(void) {
	return (skin);
}

float
NSEntity::GetScale(void) {
	return (scale);
}

entity
NSEntity::GetOwner(void) {
	return (owner);
}

vector
NSEntity::GetVelocity(void) {
	return (velocity);
}

float
NSEntity::GetSolid(void) {
	return (solid);
}

string
NSEntity::GetModel(void)
{
	return (model);
}

float
NSEntity::GetModelindex(void)
{
	return (modelindex);
}

float
NSEntity::GetMovetype(void)
{
	return (movetype);
}

float
NSEntity::GetGravity(void)
{
	return (gravity);
}

vector
NSEntity::GetAngles(void)
{
	return (angles);
}

vector
NSEntity::GetAngularVelocity(void)
{
	return (avelocity);
}

vector
NSEntity::GetOrigin(void)
{
	return (origin);
}

vector
NSEntity::GetMins(void)
{
	return (mins);
}

vector
NSEntity::GetMaxs(void)
{
	return (maxs);
}

vector
NSEntity::GetRealMins(void)
{
	return (m_vecMins);
}

vector
NSEntity::GetRealMaxs(void)
{
	return (m_vecMaxs);
}

vector
NSEntity::GetAbsoluteMins(void)
{
	return (absmin);
}

vector
NSEntity::GetAbsoluteMaxs(void)
{
	return (absmax);
}

float
NSEntity::GetFlags(void)
{
	return (flags);
}

float
NSEntity::GetVFlags(void)
{
	return (vv_flags);
}

bool
NSEntity::HasFlags(float bits)
{
	return (flags & bits) ? (true) : (false);
}

bool
NSEntity::HasVFlags(float bits)
{
	return (vv_flags & bits) ? (true) : (false);
}

float
NSEntity::GetNextThinkTime(void)
{
	return (nextthink);
}

bool
NSEntity::IsThinking(void)
{
	return (nextthink > GetTime()) ? (true) : (false);
}

void
NSEntity::ReleaseThink(void)
{
	think = __NULL__;
	nextthink = 0.0f;
}

void
NSEntity::ThinkBusy(float busyTime)
{
	static void ThinkBusy_Done(void) {
		/* Guess we're done here... */
	}
	ScheduleThink(ThinkBusy_Done, busyTime);
}

void
NSEntity::ClearVelocity(void)
{
	velocity = avelocity = [0.0f, 0.0f, 0.0f];
}

#ifdef SERVER
void
NSEntity::Respawn(void)
{
	super::Respawn();

	if (CreatedByMap()) {
		SetOrigin(GetSpawnVector("origin"));
	}

	SetAngles(GetSpawnVector("angles"));
	SetModel(GetSpawnString("model"));
}

void
NSEntity::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "tag_entity", tag_entity);
	SaveFloat(handle, "tag_index", tag_index);
	SaveFloat(handle, "pvsflags", pvsflags);
	SaveBool(handle, "_mapspawned", _mapspawned);
	SaveFloat(handle, "scale", scale);
	SaveFloat(handle, "vv_flags", vv_flags);
	SaveFloat(handle, "friction", friction);
	SaveVector(handle, "m_vecMins", m_vecMins);
	SaveVector(handle, "m_vecMaxs", m_vecMaxs);
	SaveFloat(handle, "m_flTouchTime", m_flTouchTime);
	SaveBool(handle, "m_beingTouched", m_beingTouched);
	SaveEntity(handle, "m_eTouchLast", m_eTouchLast);
	SaveVector(handle, "m_vecEditorColor", m_vecEditorColor);
}

void
NSEntity::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "tag_entity":
		tag_entity = ReadEntity(strValue);
		break;
	case "tag_index":
		tag_index = ReadFloat(strValue);
		break;
	case "pvsflags":
		pvsflags = ReadFloat(strValue);
		break;
	case "_mapspawned":
		_mapspawned = ReadBool(strValue);
		break;
	case "scale":
		scale = ReadFloat(strValue);
		break;
	case "vv_flags":
		vv_flags = ReadFloat(strValue);
		break;
	case "friction":
		friction = ReadFloat(strValue);
		break;
	case "m_vecMins":
		m_vecMins = ReadVector(strValue);
		break;
	case "m_vecMaxs":
		m_vecMaxs = ReadVector(strValue);
		break;
	case "m_flTouchTime":
		m_flTouchTime = ReadFloat(strValue);
		break;
	case "m_beingTouched":
		m_beingTouched = ReadBool(strValue);
		break;
	case "m_eTouchLast":
		m_eTouchLast = ReadEntity(strValue);
		break;
	case "m_vecEditorColor":
		m_vecEditorColor = ReadVector(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

void
NSEntity::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Kill":
		Destroy();
		break;
	case "KillHierarchy":
		/* this works because ents are basically just entnums */
		for (entity e = world; (e = findfloat(e, ::owner, this));) {
			NSEntity ent = (NSEntity) e;

			ent.Destroy();
		}
		Destroy();
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
		eActivator = (NSEntity)eAct;

		if (PlayerUse)
			PlayerUse();
		break;
	case "SpawnDef":
		break;
	case "SpawnProjectileDef":
		if (EntityDef_HasSpawnClass(strData)) {
			NSProjectile_SpawnDefAttachment(strData, this, 0);
		}
		break;
	case "StartSoundDef":
		StartSoundDef(strData, CHAN_VOICE, true);
		break;
	case "AddVelocity":
		vector velAdd = stov(strData);
		velocity += GetForward() * velAdd[0];
		velocity += GetRight() * velAdd[1];
		velocity += GetUp() * velAdd[2];
		break;
	case "Shockwave":
		int c = tokenize(strData);
		
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_BEAMCYLINDER);
		WriteCoord(MSG_MULTICAST, origin[0]);
		WriteCoord(MSG_MULTICAST, origin[1]);
		WriteCoord(MSG_MULTICAST, origin[2]);
		WriteCoord(MSG_MULTICAST, angles[0]);
		WriteCoord(MSG_MULTICAST, stof(argv(1)));
		WriteCoord(MSG_MULTICAST, angles[2]);
		WriteShort(MSG_MULTICAST, getmodelindex(argv(0)));
		WriteByte(MSG_MULTICAST, stof(argv(2)));
		WriteByte(MSG_MULTICAST, stof(argv(3)));
		WriteByte(MSG_MULTICAST, stof(argv(4)));
		WriteByte(MSG_MULTICAST, stof(argv(5)));
		WriteByte(MSG_MULTICAST, stof(argv(6)));
		WriteByte(MSG_MULTICAST, stof(argv(7)));
		WriteByte(MSG_MULTICAST, stof(argv(8)));
		WriteByte(MSG_MULTICAST, stof(argv(9)));
		WriteByte(MSG_MULTICAST, stof(argv(10)));
		WriteByte(MSG_MULTICAST, stof(argv(11)));

		msg_entity = this;
		multicast(origin, MULTICAST_PVS);
		break;
	case "SetOrigin":
		SetOrigin(stov(strData));
		break;
	case "SetEditorColor":
		m_vecEditorColor = ReadVector(strData);
		break;
	case "Respawn":
		Respawn();
		break;
	default:
		NSTrigger::Input(eAct, strInput, strData);
	}
}
#endif

void
NSEntity::SpawnKey(string strKey, string strValue)
{
	bool tempCheck = false;
	/* we do re-read a lot of the builtin fields in case we want to set
	   defaults. just in case anybody is wondering. */
	switch (strKey) {
	case "spawnflags":
		spawnflags = ReadFloat(strValue);
		break;
	case "origin":
		origin = ReadVector(strValue);
		break;
	case "model":
		model = ReadString(strValue);
		break;
	case "angles":
		angles = ReadVector(strValue);
		break;
	case "angle":
		angles[1] = ReadFloat(strValue);
		break;
	case "solid":
		solid = ReadFloat(strValue);
		break;
	case "friction":
		friction = ReadFloat(strValue);
		break;
	case "editor_color":
		m_vecEditorColor = ReadVector(strValue);
		break;
#ifdef SERVER
	case "health":
		health = ReadFloat(strValue);
		break;
	case "movewith":
	case "parentname":
		SetParent(ReadString(strValue));
		break;
	case "ignorepvs":
		tempCheck = ReadBool(strValue);

		if (tempCheck == true)
			pvsflags = PVSF_IGNOREPVS;
		else
			pvsflags &= ~PVSF_IGNOREPVS;

		break;
#endif
	case "editor_mins":
	case "editor_maxs":
	case "editor_usage":
	case "editor_model":
	case "editor_rotatable":
	case "editor_description":
	case "_minlight":
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSEntity::Show(void)
{
	effects &= ~EF_NODRAW;
}

void
NSEntity::Hide(void)
{
	effects |= EF_NODRAW;
}

bool
NSEntity::IsHidden(void)
{
	return (effects & EF_NODRAW) ? true : false;
}

void
NSEntity::Disappear(void)
{
	modelindex = (0);
	SetSolid(SOLID_NOT);
}

void
NSEntity::MakeStatic(void)
{
	makestatic(this);
}

bool
NSEntity::CanSpawn(bool clientSide)
{
	return !(clientSide);
}

bool
NSEntity::WithinBounds(entity check)
{
	if not (check.absmin[0] >= absmin[0] && check.absmax[0] <= absmax[0])
			return (false);
	if not (check.absmin[1] >= absmin[1] && check.absmax[1] <= absmax[1])
			return (false);
	if not (check.absmin[2] >= absmin[2] && check.absmax[2] <= absmax[2])
			return (false);

	return (true);
}

bool
NSEntity::IntersectsWith(entity check)
{
	if not (check.origin[0] >= absmin[0] && check.origin[0] <= absmax[0])
			return (false);
	if not (check.origin[1] >= absmin[1] && check.origin[1] <= absmax[1])
			return (false);
	if not (check.origin[2] >= absmin[2] && check.origin[2] <= absmax[2])
			return (false);

	return (true);
}

bool
NSEntity::StartSound(string strSample, float channel, float flags, bool broadcast)
{
	if not (whichpack(strcat("sound/", strSample))) 
		return (false);

	if (broadcast) {
		sound(this, channel, strSample, 1.0f, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
	} else {
#ifdef SERVER
		msg_entity = this;
		sound(this, channel, strSample, 1.0f, ATTN_NORM, 0, SOUNDFLAG_UNICAST | SOUNDFLAG_FOLLOW);
		msg_entity = __NULL__;
#else
		sound(this, channel, strSample, 1.0f, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
#endif
	}

	SndEntLog("%s (chan: %d bcast: %d) (%v)", strSample, channel, broadcast, origin);

	return (true);
}

bool
NSEntity::StartSoundDef(string strSample, float channel, bool broadcast)
{
	SndEntLog("%s (chan: %d bcast: %d)", strSample, channel, broadcast);
	Sound_Play(this, channel, strSample);
	return (true);
}

void
NSEntity::StopSound(float channel, bool broadcast)
{
	if (broadcast) {
		Sound_Stop(this, channel);
	} else {
#ifdef SERVER
		msg_entity = this;
		sound(this, channel, "common/null.wav", 1.0f, ATTN_NORM, 100, SOUNDFLAG_UNICAST  | SOUNDFLAG_FOLLOW, 0 );
		msg_entity = __NULL__;
#else
		Sound_Stop(this, channel);
#endif
	}
}

vector
NSEntity::NearestWallPointForRadius(float radius)
{
	vector vecRadius = [radius, radius, radius];
	tracebox(origin, -vecRadius, vecRadius, origin, MOVE_EVERYTHING, this);
	return (trace_fraction <= 1.0) ? (trace_endpos) : (origin);
}

void
NSEntity::HandleThink(void)
{
	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
}

bool
NSEntity::IsFacing(entity target)
{
	vector vecDiff = vectorNormalize(target.origin - origin);
	return ((vecDiff * GetForward()) > 0) ? true : false;
}

bool
NSEntity::IsFacingPosition(vector targetPos)
{
	vector vecDiff = vectorNormalize(targetPos - origin);
	return ((vecDiff * GetForward()) > 0) ? true : false;
}

float
NSEntity::GetSpawnAge(void)
{
	return (time - m_flSpawnTime);
}

float
NSEntity::GetSpawnTime(void)
{
	return (m_flSpawnTime);
}

void
NSEntity::Transport(vector new_pos, vector new_ang)
{
	float flSpeed = length(this.GetVelocity());
	SetVelocity(anglesToForward(new_ang) * flSpeed);

	SetOrigin(new_pos);
	SetAngles(new_ang);

#ifdef SERVER
	if (isClient(this)) {
		Client_FixAngle(this, new_ang);
	}
#endif
}

void
NSEntity::Relink(void)
{
	setorigin(this, origin);
}

vector
NSEntity::GetNearbySpot(void)
{
	vector testPos;
	float minDist = maxs[0];
	vector fwdDir, rightDir, upDir;

	fwdDir = anglesToForward([0,0,0]);
	rightDir = anglesToRight([0,0,0]);
	upDir = anglesToUp([0,0,0]);

	/* space in front? */
	testPos = GetOrigin() + fwdDir * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (testPos);
	}

	/* behind? */
	testPos = GetOrigin() - fwdDir * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (testPos);
	}

	/* left? */
	testPos = GetOrigin() - rightDir * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (testPos);
	}

	/* right? */
	testPos = GetOrigin() + rightDir * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (testPos);
	}

	/* front left? */
	testPos = GetOrigin() + fwdDir * minDist - rightDir * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (testPos);
	}

	/* front right? */
	testPos = GetOrigin() + fwdDir * minDist + rightDir * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (testPos);
	}

	/* back left? */
	testPos = GetOrigin() - fwdDir * minDist - rightDir * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (testPos);
	}

	/* back right? */
	testPos = GetOrigin() - fwdDir * minDist + rightDir * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f) {
		return (testPos);
	}

	return (g_vec_null);
}

bool
NSEntity::_ProjectileAttack(string defName, bool wasReleased)
{
#ifdef SERVER
	string attackDef;
	int numProjectiles = GetSubDefInt(defName, "numProjectiles");
	float sX = GetSubDefFloat(defName, "spread_x");
	float sY = GetSubDefFloat(defName, "spread_y");

	/* always fire at least 1 */
	if (numProjectiles <= 0i) {
		numProjectiles = 1i;
	}

	if (wasReleased == true) {
		attackDef = GetSubDefString(defName, "def_onRelease");
	} else {
		attackDef = GetSubDefString(defName, "def_onFire");
	}

	for (int i = 0i; i < numProjectiles; i++) {
		EntLog("Launching %S at %v towards %v", attackDef, GetEyePos(), GetViewAngle());
		NSAttack_SpawnDefAtPosition(attackDef, this, GetEyePos(), GetViewAngle());
	}
#endif

	return (true);
}

bool
NSEntity::AttackByDef(string defName, bool wasReleased)
{
	if (!defName) {
		return (false);
	}

#ifdef SERVER
	_ProjectileAttack(defName, wasReleased);
#endif

	return (true);
}

void
NSEntity::SetBotTag(botInfo_t newTag)
{
#ifdef SERVER
	botinfo = newTag;
#endif
}

int
NSEntity::GetSharedID(void)
{
#ifdef CLIENT
	return (int)(entnum);
#else
	return (int)num_for_edict(this);
#endif
}

void
NSEntity::EnablePlayerCollision(void)
{
	dimension_solid = 255;
	dimension_hit = 255;
}

void
NSEntity::DisablePlayerCollision(void)
{
	dimension_solid = 1;
	dimension_hit = 1;
}

NSEntity
spawnClass(string className, vector desiredPos)
{
	NSEntity newEntity = __NULL__;

#ifdef SERVER
	newEntity = Entity_CreateClass(className);

	/* That class didn't exist, so let's take the base Nuclide one */
	if (!newEntity) {
		newEntity = Entity_CreateClass("NSEntity");
	}

	/* OOM. It's over. */
	if (!newEntity) {
		return (__NULL__);
	}

	newEntity.classname = className;
	newEntity.Input(newEntity, "SetOrigin", vtos(desiredPos));
	newEntity.Respawn();
#endif

	return (newEntity);
}

#ifdef SERVER
bool
changeClass(entity target, string className)
{
	return EntityDef_SwitchClass((NSEntity)target, className) ? (true) : (false);
}
#endif

void
sendInput(entity target, string inputName, string dataString, entity activator)
{
	NSEntity targetEntity = (NSEntity)target;
#ifdef SERVER
	targetEntity.Input(activator, inputName, dataString);
#endif
}

/* helper functions */
bool
isAI(entity entityToCheck)
{
	if (entityToCheck.flags & FL_MONSTER) {
		return (true);
	}

	return (false);
}

bool
isAlive(entity entityToCheck)
{
#ifdef SERVER
	if (entityToCheck.takedamage != DAMAGE_NO) {
		NSSurfacePropEntity livingEnt = (NSSurfacePropEntity)entityToCheck;
		return livingEnt.IsAlive();
	}
#endif

	return (false);
}

bool
isGodMode(entity entityToCheck)
{
	if (entityToCheck.flags & FL_GODMODE) {
		return (true);
	}

	return (false);
}

bool
isClient(entity entityToCheck)
{
	return (entityToCheck.flags & FL_CLIENT) ? (true) : (false);
}

bool
isPlayer(entity entityToCheck)
{
	if (isClient(entityToCheck)) {
		NSClient pl = (NSClient)entityToCheck;

		return pl.IsPlayer();
	}

	return (false);
}

bool
isSentient(entity entityToCheck)
{
	if (isAI(entityToCheck) || isPlayer(entityToCheck)) {
		return (true);
	}

	return (false);
}

bool
isBot(entity entityToCheck)
{
#ifdef SERVER
	return (clienttype(entityToCheck) == CLIENTTYPE_BOT) ? (true) : (false);
#else
	return (false);
#endif
}


#ifdef SERVER
void
setUserInfo(entity clientEntity, string serverKey, string setValue)
{
	if (isClient(clientEntity)) {
		NSClient client = (NSClient) clientEntity;
		client.SetInfoKey(serverKey, setValue);
	}
}

string
getUserInfo(entity clientEntity, string serverKey)
{
	if (isClient(clientEntity)) {
		NSClient client = (NSClient) clientEntity;
		return client.GetInfoKey(serverKey);
	}
}
#endif

void
placeSpawnpoint(entity target)
{
	vector testorg = target.origin;

	for (int i = 0; i < 32; i++) {
		tracebox(testorg, target.mins, target.maxs, testorg, MOVE_NORMAL, target);

		if (!trace_startsolid) {
			setorigin(target, testorg);
			break;
		}

		testorg[2] += 1.0;
	}
}
