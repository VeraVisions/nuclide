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
ncEntity::ncEntity(void)
{
	_loading = false;
	m_spawnTime = time;
	m_editorColor = [1,1,1];
	m_holdingPlayer = __NULL__;
	tag_entity = 0;

#ifdef SERVER
	m_gameModeFilter = __NULL__;
#endif
}

void
ncEntity::Spawn(void)
{
	Spawned();

#ifdef SERVER
	if (wasfreed(this)) {
		return;
	}

	/* only precache at start time... */
	if (time == 0.0f) {
		Precache();
	}

	Respawn();
#endif
}

void
ncEntity::Precache(void)
{
#ifdef SERVER
	if (STRING_SET(model)) {
		precache.Model(model);
	}

	if (STRING_SET(m_outputOnTrigger)) {
		m_outputOnTrigger = CreateOutput(m_outputOnTrigger);
	}
#endif
}

void
ncEntity::Spawned(void)
{
	super::Spawned();
}

bool
ncEntity::HasModel(void)
{
	return (modelindex == 0) ? (false) : (true);
}

float
ncEntity::EntIndex(void)
{
	return (num_for_edict(this));
}

bool
ncEntity::DropToFloor(void)
{
	return droptofloorwrapper(this);
}

vector
ncEntity::GetForward(void)
{
	return anglesToForward(angles);
}

vector
ncEntity::GetRight(void)
{
	return anglesToRight(angles);
}

vector
ncEntity::GetUp(void)
{
	return anglesToUp(angles);
}

vector
ncEntity::WorldSpaceCenter(void)
{
	return (absmin + (0.5 * (absmax - absmin)));
}

float
ncEntity::WaterLevel(void)
{
	return (waterlevel);
}

bool
ncEntity::VisibleVec(vector org)
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
ncEntity::Visible(entity ent)
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
ncEntity::DistanceFromYaw(vector targetPos)
{
	return vectorNormalize(targetPos - origin) * GetForward();
}

bool
ncEntity::HasSpawnFlags(float sf)
{
	return (spawnflags & sf) ? (true) : (false);
}

bool
ncEntity::IsOnGround(void)
{
	return (flags & FL_ONGROUND) ? (true) : (false);
}

bool
ncEntity::IsSolid(void)
{
	return (solid != SOLID_NOT) ? (true) : (false);
}

entity
ncEntity::GetGroundEntity(void)
{
	return (groundentity);
}

bool
ncEntity::CreatedByMap(void)
{
	return (_mapspawned);
}

bool
ncEntity::Loading(void)
{
	return (_loading);
}

bool
ncEntity::HeldByPlayer(void)
{
	return (m_holdingPlayer) ? (true) : (false);
}

#ifdef CLIENT
void
ncEntity::ReloadVideoResources(void)
{

}

float
ncEntity::predraw(void)
{
	if (GetModelindex() == 0 || IsHidden()) {
		return (PREDRAW_NEXT);
	}

	addentity(this);
	return (PREDRAW_NEXT);
}

void
ncEntity::ReceiveEntity(float flNew, float flChanged)
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
	READENTITY_INT(m_nuclideFlags, BASEFL_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(mins[1], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(mins[2], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], BASEFL_CHANGED_SIZE)
	READENTITY_BYTE(frame, BASEFL_CHANGED_FRAME)
	READENTITY_FLOAT(skin, BASEFL_CHANGED_SKIN)
	READENTITY_INT(effects, BASEFL_CHANGED_EFFECTS)
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
	if (flChanged & BASEFL_CHANGED_MODELINDEX) {
		_ModelChanged();
	}
}

void
ncEntity::ReceiveEvent(float eventType)
{
	switch (eventType) {
	default:
		EntError("Unknown event %d", eventType);
	}
}

void
ncEntity::postdraw(void)
{
}


#else
void
ncEntity::DebugDraw(void)
{
	DebugBox(GetOrigin(), GetMins(), GetMaxs(), m_editorColor, 0.75f);
}

float
ncEntity::SendEntity(entity ePEnt, float flChanged)
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

		if (m_modelBrushBased == true) {
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
	SENDENTITY_INT(m_nuclideFlags, BASEFL_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], BASEFL_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, BASEFL_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, BASEFL_CHANGED_SKIN)
	SENDENTITY_INT(effects, BASEFL_CHANGED_EFFECTS)
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
ncEntity::EvaluateEntity(void)
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
	EVALUATE_FIELD(m_nuclideFlags, BASEFL_CHANGED_FLAGS)
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
ncEntity::ParentUpdate(void)
{
	if (tag_entity) {
		makevectors(tag_entity.angles);
		origin = tag_entity.origin + v_forward * m_parentPosOffs[0];
		origin += v_right * m_parentPosOffs[1];
		origin += v_up * m_parentPosOffs[2];
		angles = v_forward * m_parentPosOffs[0];
		angles += v_right * m_parentPosOffs[1];
		angles += v_up * m_parentPosOffs[2];
		angles = vectoangles(angles);
	}

	EvaluateEntity();

	if (!(m_nuclideFlags & VFL_NOFRAMEADVANCE)) {
		frame1time += frametime;
	}

	/* handle end-touch */
	if (m_beingTouched == true) {
		if (m_timeSinceLastTouch < GetTime()) {
			EndTouch(m_touchingEntity);
			m_beingTouched = false;
			m_touchingEntity = __NULL__;
		}
	}
}

bool
ncEntity::SharesPVSWithPlayer(void)
{
	entity entLoop = world;

	for (entLoop = world; ((entLoop = next.Player(entLoop)));) {
		ncActor testPlayer = (ncActor)entLoop;

		if (checkpvs(testPlayer.GetEyePos(), this) == true) {
			return (true);
		}
	}

	return (false);
}

entity
ncEntity::GetParent(void)
{
	return tag_entity;
}

void
ncEntity::SetParent(string name)
{
	vector parentOffset, angleOffset;
	tag_entity = find(world, ::targetname, name);
	parentOffset = origin - tag_entity.origin;
	angleOffset = anglesToForward(angles) - anglesToForward(tag_entity.angles);
	makevectors(tag_entity.angles);
	m_parentPosOffs[0] = dotproduct(parentOffset, v_forward);
	m_parentPosOffs[1] = dotproduct(parentOffset, v_right);
	m_parentPosOffs[2] = dotproduct(parentOffset, v_up);
	m_parentAngOffs[0] = dotproduct(angleOffset, v_forward);
	m_parentAngOffs[1] = dotproduct(angleOffset, v_right);
	m_parentAngOffs[2] = dotproduct(angleOffset, v_up);
}

void
ncEntity::SetParentAttachment(string name)
{
	if (name != "origin") {
		tag_index = gettagindex(tag_entity, name);
	} else {
		tag_index = 0;
	}
}

void
ncEntity::ClearParent(void)
{
	tag_entity = world;
	tag_index = 0;
}

void
ncEntity::RestoreAngles(void)
{
	vector spawnAngles = g_vec_null;
	string spawnAngleString = GetSpawnString("angles");

	if (!STRING_SET(spawnAngleString)) {
		spawnAngles[1] = GetSpawnFloat("angle");
	} else {
		spawnAngles = stov(spawnAngleString);
	}

	SetAngles(spawnAngles);
}

void
ncEntity::ClearAngles(void)
{
	SetAngles(g_vec_null);
}

void
ncEntity::ForceNetworkUpdate(void)
{
	SendFlags = -1;
}

void
ncEntity::UseBy(entity ourActivator)
{
	if (PlayerUse) {
		eActivator = (ncEntity)ourActivator;
		PlayerUse();
	}
}
#endif

void
ncEntity::SetEffects(__int32 newEffects)
{
	effects = newEffects;
}

void
ncEntity::SetFrame(float newFrame)
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

		eDefEvents = tokenize(m_modelEventCallbacks);

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

				tokenize(m_modelEventCallbacks); /* ensure argv() is 'rewound'... */
			}
		}
	}
#endif
}

void
ncEntity::SetSkin(float newSkin)
{
	skin = newSkin;
}

void
ncEntity::SetOwner(entity newOwner)
{
	owner = newOwner;
}

void
ncEntity::SetVelocity(vector vecNew)
{
	velocity = vecNew;
}

void
ncEntity::SetTouch(void ()newTouch)
{
	touch = newTouch;
}

void
ncEntity::SetMovetype(float newMovetype)
{
	movetype = newMovetype;
}

void
ncEntity::SetGravity(float newGrav)
{
	gravity = newGrav;
}

void
ncEntity::SetSolid(float newSolid)
{
	solid = newSolid;
}

void
ncEntity::SetScale(float newScale)
{
	if (newScale == scale) {
		return;
	}

	scale = newScale;
	setsize(this, m_internalMins * scale, m_internalMaxs * scale);
}

vector
ncEntity::GetViewAngle(void)
{
	if (is.Sentient(this)) {
		return (v_angle);
	} else {
		return (angles);
	}
}

void
ncEntity::SetEyePos(vector value)
{
	view_ofs = value;
}

vector
ncEntity::GetEyePos(void)
{
	if (HasVFlags(VFL_FAKESPEC)) {
		return (origin);
	}

	return (origin + view_ofs);
}

void
ncEntity::UpdateBounds(void)
{
	vector newMins, newMaxs;
	float flScale = 1.0f;

	newMins = m_internalMins;
	newMaxs = m_internalMaxs;

	/* avoid useless computation */
	if (angles != [0, 0, 0]) {
		/* adjust bbox according to rotation */
		vector vecCorner[8];

		newMins = newMaxs =[0, 0, 0];
		for (int i = 0; i < 8; i++) {
			vecCorner[i][0] = (i & 1) ? m_internalMins[0] : m_internalMaxs[0];
			vecCorner[i][1] = (i & 2) ? m_internalMins[1] : m_internalMaxs[1];
			vecCorner[i][2] = (i & 4) ? m_internalMins[2] : m_internalMaxs[2];
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
ncEntity::SetAngles(vector newAngles)
{
	angles = newAngles;
}

void
ncEntity::SetAngularVelocity(vector newAvel)
{
	avelocity = newAvel;
}

void
ncEntity::SetSize(vector newMins, vector newMaxs)
{
	float flScale = 1.0f;

	m_internalMins = newMins;
	m_internalMaxs = newMaxs;

	/* 0.0 is never valid, if you want it to disappear do something else */
	if (scale != 0.0f) {
		flScale = scale;
	}

	setsize(this, newMins * flScale, newMaxs * flScale);
}

void
ncEntity::SetOrigin(vector newOrigin)
{
	setorigin(this, newOrigin);
}

void
ncEntity::SetOriginUnstick(vector newOrigin)
{
	setorigin_safe(this, newOrigin);
}

bool
ncEntity::IsBrush(void)
{
	return (m_modelBrushBased);
}

void
ncEntity::SetModel(string newModel)
{
	m_modelBrushBased = substring(newModel, 0, 1) == "*" ? true : false;
	model = Util_FixModel(newModel);
	setmodel(this, model);
	m_modelMins = mins;
	m_modelMaxs = maxs;

	/* mins/maxs have been updated by setmodel */
	SetSize(mins, maxs);
}

void
ncEntity::SetModelindex(float newModelIndex)
{
	if (newModelIndex == modelindex) {
		return;
	}

	modelindex = newModelIndex;
	SetSize(mins, maxs);
}

void
ncEntity::AddAngularVelocity(vector addVel)
{
	avelocity += addVel;
}

void
ncEntity::AddVelocity(vector addVel)
{
	velocity += addVel;
}

void
ncEntity::AddEffects(__int32 fl) {
	effects |= fl;
}

void
ncEntity::RemoveEffects(__int32 fl) {
	effects &= ~fl;
}


void
ncEntity::AddFlags(float fl) {
	flags |= fl;
}

void
ncEntity::RemoveFlags(float fl) {
	flags &= ~fl;
}


void
ncEntity::AddVFlags(float fl) {
	m_nuclideFlags |= fl;
}

void
ncEntity::RemoveVFlags(float fl) {
	m_nuclideFlags &= ~fl;
}

void
ncEntity::TurnTo(float targetAngle) {
	angles[1] = targetAngle;
}

void
ncEntity::TurnToPos(vector targetPos) {
	angles = vectorToAngles(targetPos - WorldSpaceCenter());
}

__int32
ncEntity::GetEffects(void) {
	return (effects);
}

float
ncEntity::GetFrame(void) {
	return (frame);
}

float
ncEntity::GetSkin(void) {
	return (skin);
}

float
ncEntity::GetScale(void) {
	return (scale);
}

entity
ncEntity::GetOwner(void) {
	return (owner);
}

vector
ncEntity::GetVelocity(void) {
	return (velocity);
}

float
ncEntity::GetSolid(void) {
	return (solid);
}

string
ncEntity::GetModel(void)
{
	return (model);
}

float
ncEntity::GetModelindex(void)
{
	return (modelindex);
}

float
ncEntity::GetMovetype(void)
{
	return (movetype);
}

float
ncEntity::GetGravity(void)
{
	return (gravity);
}

vector
ncEntity::GetAngles(void)
{
	return (angles);
}

vector
ncEntity::GetAngularVelocity(void)
{
	return (avelocity);
}

vector
ncEntity::GetOrigin(void)
{
	return (origin);
}

vector
ncEntity::GetSize(void)
{
	return (size);
}

vector
ncEntity::GetMins(void)
{
	return (mins);
}

vector
ncEntity::GetMaxs(void)
{
	return (maxs);
}

vector
ncEntity::GetRealMins(void)
{
	return (m_internalMins);
}

vector
ncEntity::GetRealMaxs(void)
{
	return (m_internalMaxs);
}

vector
ncEntity::GetAbsoluteMins(void)
{
	return (absmin);
}

vector
ncEntity::GetAbsoluteMaxs(void)
{
	return (absmax);
}

float
ncEntity::GetFlags(void)
{
	return (flags);
}

float
ncEntity::GetVFlags(void)
{
	return (m_nuclideFlags);
}

bool
ncEntity::HasFlags(float bits)
{
	return (flags & bits) ? (true) : (false);
}

bool
ncEntity::HasVFlags(float bits)
{
	return (m_nuclideFlags & bits) ? (true) : (false);
}

void
ncEntity::ClearVelocity(void)
{
	velocity = avelocity = [0.0f, 0.0f, 0.0f];
}

#ifdef SERVER
vector
ncEntity::GetModelMins(void)
{
	return (m_modelMins);
}

vector
ncEntity::GetModelMaxs(void)
{
	return (m_modelMaxs);
}

void
ncEntity::_RelinkToSpawnParent(void)
{
	/* Source Engine key */
	string parentName1 = GetSpawnString("parentname");

	if (STRING_SET(parentName1)) {
		SetParent(parentName1);
	} else {
		/* Spirit of HL compat */
		string parentName2 = GetSpawnString("movewith");

		if (STRING_SET(parentName2)) {
			SetParent(parentName2);
		}
	}
}

void
ncEntity::Respawn(void)
{
	super::Respawn();

	if (CreatedByMap()) {
		SetOrigin(GetSpawnVector("origin"));
	}

	SetAngles(GetSpawnVector("angles"));
	SetModel(GetSpawnString("model"));

	_RelinkToSpawnParent();
}

void
ncEntity::Save(float handle)
{
	/* all the stock Quake fields the engine is aware of */
	SaveFloat(handle, "modelindex", modelindex);
	SaveVector(handle, "absmin", absmin);
	SaveVector(handle, "absmax", absmax);
	SaveFloat(handle, "movetype", movetype);
	SaveFloat(handle, "solid", solid);
	SaveVector(handle, "oldorigin", oldorigin);
	SaveVector(handle, "velocity", velocity);
	SaveVector(handle, "angles", angles);
	SaveVector(handle, "avelocity", avelocity);
	//SaveString(handle, "classname", classname);
	SaveString(handle, "model", model);
	SaveFloat(handle, "frame", frame);
	SaveFloat(handle, "skin", skin);
	SaveFloat(handle, "effects", effects);
	SaveVector(handle, "mins", mins);
	SaveVector(handle, "maxs", maxs);
	SaveVector(handle, "size", size);
	SaveString(handle, "touch", getentityfieldstring(findentityfield("touch"), this));
	SaveString(handle, "use", getentityfieldstring(findentityfield("use"), this));
	SaveString(handle, "think", getentityfieldstring(findentityfield("think"), this));
	SaveString(handle, "blocked", getentityfieldstring(findentityfield("blocked"), this));
	SaveFloat(handle, "nextthink", nextthink);
	SaveEntity(handle, "groundentity", groundentity);
	SaveFloat(handle, "health", health);
	SaveFloat(handle, "frags", frags);
	SaveFloat(handle, "weapon", weapon);
	SaveString(handle, "weaponmodel", weaponmodel);
	SaveFloat(handle, "weaponframe", weaponframe);
	SaveFloat(handle, "currentammo", currentammo);
	SaveFloat(handle, "items", items);
	SaveFloat(handle, "takedamage", takedamage);
	SaveEntity(handle, "chain", chain);
	SaveFloat(handle, "deadflag", deadflag);
	SaveVector(handle, "view_ofs", view_ofs);
	SaveFloat(handle, "button0", button0);
	SaveFloat(handle, "button1", button1);
	SaveFloat(handle, "button2", button2);
	SaveFloat(handle, "impulse", impulse);
	SaveFloat(handle, "fixangle", fixangle);
	SaveVector(handle, "v_angle", v_angle);
	SaveFloat(handle, "idealpitch", idealpitch);
	SaveString(handle, "netname", netname);
	SaveEntity(handle, "enemy", enemy);
	SaveFloat(handle, "flags", flags);
	SaveFloat(handle, "colormap", colormap);
	SaveVector(handle, "glowmod", glowmod);
	SaveFloat(handle, "modelflags", modelflags);
	SaveFloat(handle, "team", team);
	SaveFloat(handle, "max_health", max_health);
	SaveFloat(handle, "teleport_time", teleport_time);
	SaveFloat(handle, "armortype", armortype);
	SaveFloat(handle, "armorvalue", armorvalue);
	SaveFloat(handle, "waterlevel", waterlevel);
	SaveFloat(handle, "watertype", watertype);
	SaveFloat(handle, "ideal_yaw", ideal_yaw);
	SaveFloat(handle, "yaw_speed", yaw_speed);
	SaveEntity(handle, "aiment", aiment);
	SaveEntity(handle, "goalentity", goalentity);
	SaveString(handle, "target", target);
	SaveString(handle, "targetname", targetname);
	SaveFloat(handle, "dmg_take", dmg_take);
	SaveFloat(handle, "dmg_save", dmg_save);
	SaveEntity(handle, "dmg_inflictor", dmg_inflictor);
	SaveEntity(handle, "owner", owner);
	SaveVector(handle, "movedir", movedir);
	SaveString(handle, "message", message);
	SaveFloat(handle, "sounds", sounds);
	SaveString(handle, "noise", noise);
	SaveString(handle, "noise1", noise1);
	SaveString(handle, "noise2", noise2);
	SaveString(handle, "noise3", noise3);

	/* FTEQW relevant fields */
	SaveFloat(handle, "dimension_solid", dimension_solid);
	SaveFloat(handle, "dimension_hit", dimension_hit);
	SaveFloat(handle, "frame1time", frame1time);
	SaveFloat(handle, "basebone", basebone);
	SaveFloat(handle, "baseframe", baseframe);
	SaveFloat(handle, "drawflags", drawflags);
	SaveString(handle, "customphysics", getentityfieldstring(findentityfield("customphysics"), this));
	SaveString(handle, "SendEntity", getentityfieldstring(findentityfield("SendEntity"), this));
	SaveFloat(handle, "viewzoom", viewzoom);
	SaveFloat(handle, "uniquespawnid", uniquespawnid);

	/* Nuclide global fields */
	SaveString(handle, "outputOnTrigger", m_outputOnTrigger);
	SaveString(handle, "outputOnUser1", m_outputOnUser1);
	SaveString(handle, "outputOnUser2", m_outputOnUser2);
	SaveString(handle, "outputOnUser3", m_outputOnUser3);
	SaveString(handle, "outputOnUser4", m_outputOnUser4);
	SaveString(handle, "modelEventCallbacks", m_modelEventCallbacks);
	SaveString(handle, "rawSpawnData", m_rawSpawnData);

	SaveEntity(handle, "tag_entity", tag_entity);
	SaveFloat(handle, "tag_index", tag_index);
	SaveFloat(handle, "scale", scale);
	SaveFloat(handle, "nuclideFlags", m_nuclideFlags);
	SaveFloat(handle, "friction", friction);
	SaveVector(handle, "internalMins", m_internalMins);
	SaveVector(handle, "internalMaxs", m_internalMaxs);
	SaveVector(handle, "modelMins", m_modelMins);
	SaveVector(handle, "modelMaxs", m_modelMaxs);
	SaveVector(handle, "parentPosOffs", m_parentPosOffs);
	SaveVector(handle, "parentAngOffs", m_parentAngOffs);
	SaveString(handle, "parent", m_parent);
	SaveString(handle, "parent_old", m_parent_old);
	SaveString(handle, "parent_attachment", m_parent_attachment);
	SaveVector(handle, "editorColor", m_editorColor);
	SaveFloat(handle, "spawnTime", m_spawnTime);
	SaveEntity(handle, "holdingPlayer", m_holdingPlayer);
	SaveFloat(handle, "lastHeldTime", m_lastHeldTime);

	super::Save(handle);
}

void
ncEntity::Restore(string keyName, string setValue)
{
	switch (keyName) {
	/* START: all the stock Quake fields the engine is aware of */
	case "modelindex":
		modelindex = ReadFloat(setValue);
		break;
	case "absmin":
		absmin = ReadVector(setValue);
		break;
	case "absmax":
		absmax = ReadVector(setValue);
		break;
	case "movetype":
		movetype = ReadFloat(setValue);
		break;
	case "solid":
		solid = ReadFloat(setValue);
		break;
	case "colormap":
		colormap = ReadFloat(setValue);
		break;
	case "glowmod":
		glowmod = ReadVector(setValue);
		break;
	case "modelflags":
		modelflags = ReadFloat(setValue);
		break;
	case "oldorigin":
		oldorigin = ReadVector(setValue);
		break;
	case "velocity":
		velocity = ReadVector(setValue);
		break;
	case "angles":
		angles = ReadVector(setValue);
		break;
	case "avelocity":
		avelocity = ReadVector(setValue);
		break;
	/*case "classname":
		classname = ReadString(setValue);
		break; */
	case "model":
		model = ReadString(setValue);
		setmodel(this, model);
		break;
	case "frame":
		frame = ReadFloat(setValue);
		break;
	case "skin":
		skin = ReadFloat(setValue);
		break;
	case "effects":
		effects = ReadFloat(setValue);
		break;
	case "mins":
		mins = ReadVector(setValue);
		setsize(this, mins, maxs);
		break;
	case "maxs":
		maxs = ReadVector(setValue);
		setsize(this, mins, maxs);
		break;
	case "size":
		size = ReadVector(setValue);
		break;
	case "touch":
		touch = externvalue(-1, setValue);
		break;
	case "use":
		use = externvalue(-1, setValue);
		break;
	case "think":
		think = externvalue(-1, setValue);
		break;
	case "blocked":
		blocked = externvalue(-1, setValue);
		break;
	case "nextthink":
		nextthink = ReadFloat(setValue);
		break;
	case "groundentity":
		groundentity = ReadEntity(setValue);
		break;
	case "health":
		health = ReadFloat(setValue);
		break;
	case "frags":
		frags = ReadFloat(setValue);
		break;
	case "weapon":
		weapon = ReadFloat(setValue);
		break;
	case "weaponmodel":
		weaponmodel = ReadString(setValue);
		break;
	case "weaponframe":
		weaponframe = ReadFloat(setValue);
		break;
	case "currentammo":
		currentammo = ReadFloat(setValue);
		break;
	case "items":
		items = ReadFloat(setValue);
		break;
	case "takedamage":
		takedamage = ReadFloat(setValue);
		break;
	case "chain":
		chain = ReadEntity(setValue);
		break;
	case "deadflag":
		deadflag = ReadFloat(setValue);
		break;
	case "view_ofs":
		view_ofs = ReadVector(setValue);
		break;
	case "button0":
		button0 = ReadFloat(setValue);
		break;
	case "button1":
		button1 = ReadFloat(setValue);
		break;
	case "button2":
		button2 = ReadFloat(setValue);
		break;
	case "impulse":
		impulse = ReadFloat(setValue);
		break;
	case "fixangle":
		fixangle = ReadFloat(setValue);
		break;
	case "v_angle":
		v_angle = ReadVector(setValue);
		break;
	case "idealpitch":
		idealpitch = ReadFloat(setValue);
		break;
	case "netname":
		netname = ReadString(setValue);
		break;
	case "enemy":
		enemy = ReadEntity(setValue);
		break;
	case "flags":
		flags = ReadFloat(setValue);
		break;
	case "team":
		team = ReadFloat(setValue);
		break;
	case "max_health":
		max_health = ReadFloat(setValue);
		break;
	case "teleport_time":
		teleport_time = ReadFloat(setValue);
		break;
	case "armortype":
		armortype = ReadFloat(setValue);
		break;
	case "armorvalue":
		armorvalue = ReadFloat(setValue);
		break;
	case "waterlevel":
		waterlevel = ReadFloat(setValue);
		break;
	case "watertype":
		watertype = ReadFloat(setValue);
		break;
	case "ideal_yaw":
		ideal_yaw = ReadFloat(setValue);
		break;
	case "yaw_speed":
		yaw_speed = ReadFloat(setValue);
		break;
	case "aiment":
		aiment = ReadEntity(setValue);
		break;
	case "goalentity":
		goalentity = ReadEntity(setValue);
		break;
	case "target":
		target = ReadString(setValue);
		break;
	case "targetname":
		targetname = ReadString(setValue);
		break;
	case "dmg_take":
		dmg_take = ReadFloat(setValue);
		break;
	case "dmg_save":
		dmg_save = ReadFloat(setValue);
		break;
	case "dmg_inflictor":
		dmg_inflictor = ReadEntity(setValue);
		break;
	case "owner":
		owner = ReadEntity(setValue);
		break;
	case "movedir":
		movedir = ReadVector(setValue);
		break;
	case "message":
		message = ReadString(setValue);
		break;
	case "sounds":
		sounds = ReadFloat(setValue);
		break;
	case "noise":
		noise = ReadString(setValue);
		break;
	case "noise1":
		noise1 = ReadString(setValue);
		break;
	case "noise2":
		noise2 = ReadString(setValue);
		break;
	case "noise3":
		noise3 = ReadString(setValue);
		break;
	/* FTEQW relevant fields */
	case "dimension_solid":
		dimension_solid = ReadFloat(setValue);
		break;
	case "dimension_hit":
		dimension_hit = ReadFloat(setValue);
		break;
	case "frame1time":
		frame1time = ReadFloat(setValue);
		break;
	case "basebone":
		basebone = ReadFloat(setValue);
		break;
	case "baseframe":
		baseframe = ReadFloat(setValue);
		break;
	case "drawflags":
		drawflags = ReadFloat(setValue);
		break;
	case "customphysics":
		customphysics = externvalue(-1, setValue);
		break;
	case "SendEntity":
		SendEntity = externvalue(-1, setValue);
		break;
	case "viewzoom":
		viewzoom = ReadFloat(setValue);
		break;
	case "uniquespawnid":
		uniquespawnid = ReadFloat(setValue);
		break;
	/* END: all the stock Quake fields the engine is aware of */
	/* Nuclide global fields */
	case "outputOnTrigger":
		m_outputOnTrigger = ReadString(setValue);
		break;
	case "outputOnUser1":
		m_outputOnUser1 = ReadString(setValue);
		break;
	case "outputOnUser2":
		m_outputOnUser2 = ReadString(setValue);
		break;
	case "outputOnUser3":
		m_outputOnUser3 = ReadString(setValue);
		break;
	case "outputOnUser4":
		m_outputOnUser4 = ReadString(setValue);
		break;
	case "modelEventCallbacks":
		m_modelEventCallbacks = ReadString(setValue);
		break;
	case "rawSpawnData":
		m_rawSpawnData = ReadString(setValue);
		break;
	case "tag_entity":
		tag_entity = ReadEntity(setValue);
		break;
	case "tag_index":
		tag_index = ReadFloat(setValue);
		break;
	case "scale":
		scale = ReadFloat(setValue);
		break;
	case "nuclideFlags":
		m_nuclideFlags = ReadFloat(setValue);
		break;
	case "friction":
		friction = ReadFloat(setValue);
		break;
	case "internalMins":
		m_internalMins = ReadVector(setValue);
		break;
	case "internalMaxs":
		m_internalMaxs = ReadVector(setValue);
		break;
	case "modelMins":
		m_modelMins = ReadVector(setValue);
		break;
	case "modelMaxs":
		m_modelMaxs = ReadVector(setValue);
		break;
	case "parentPosOffs":
		m_parentPosOffs = ReadVector(setValue);
		break;
	case "parentAngOffs":
		m_parentAngOffs = ReadVector(setValue);
		break;
	case "parent":
		m_parent = ReadString(setValue);
		break;
	case "parent_old":
		m_parent_old = ReadString(setValue);
		break;
	case "parent_attachment":
		m_parent_attachment = ReadString(setValue);
		break;
	case "spawnTime":
		m_spawnTime = ReadFloat(setValue);
		break;
	case "editorColor":
		m_editorColor = ReadVector(setValue);
		break;
	case "holdingPlayer":
		m_holdingPlayer = ReadEntity(setValue);
		break;
	case "lastHeldTime":
		m_lastHeldTime = ReadFloat(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
		break;
	}
}

void
ncEntity::Event_SpawnDefCenter(string classDef)
{
	ncEntity rocket = EntityDef_CreateClassname(classDef);

	if (!rocket) {
		EntError("Can't spawn %S", classDef);
		return;
	}

	rocket.SetOrigin(WorldSpaceCenter());
	rocket.SetAngles(GetAngles());
	rocket.owner = this;
	rocket.Spawn();
	EntLog("Spawned decl %S at %v", classDef, rocket.origin);
}

void
ncEntity::Event_SpawnDefRelative(string classDef, float xOfs, float yOfs, float zOfs)
{
	vector posOffset;
	posOffset = anglesToForward(GetAngles()) * xOfs;
	posOffset += anglesToRight(GetAngles()) * yOfs;
	posOffset += anglesToUp(GetAngles()) * zOfs;
	ncEntity rocket = EntityDef_CreateClassname(classDef);
	rocket.SetOrigin(GetOrigin() + posOffset);
	rocket.SetAngles(GetAngles());
	rocket.owner = this;
	rocket.Spawn();
	EntLog("Spawned decl %S at relative offset %v (%v)", classDef, posOffset, rocket.origin);
}

void
ncEntity::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Kill":
		Destroy();
		break;
	case "KillHierarchy":
		/* this works because ents are basically just entnums */
		for (entity e = world; (e = findfloat(e, ::owner, this));) {
			ncEntity ent = (ncEntity) e;

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
		eActivator = (ncEntity)eAct;

		if (PlayerUse)
			PlayerUse();
		break;
	case "ShootGib":
		tokenize_console(strData);
		string breakModel = argv(0);
		float breakSpeed = stof(argv(1));
		int breakCount = stoi(argv(2));
		BreakModel_Spawn(origin, origin, v_angle, breakSpeed, breakCount, breakModel);
		break;
	case "SpawnDef":
		break;
	case "SpawnDefCenter":
#ifdef SERVER
		tokenize_console(strData);
		Event_SpawnDefCenter(argv(0));
#endif
		break;
	case "SpawnDefOffset":
#ifdef SERVER
		tokenize_console(strData);
		Event_SpawnDefRelative(argv(0), stof(argv(1)), stof(argv(2)), stof(argv(3)));
#endif
		break;
	case "KillChildClass":
		for (entity e = world; (e = findfloat(e, ::owner, this));) {
			if (strData == e.classname) {
				ncEntity ent = (ncEntity) e;
				ent.Destroy();
			}
		}
		break;
	case "SpawnProjectileOffset":
		vector launchOffset;
		tokenize_console(strData);
		string defName = argv(0);
		launchOffset[0]= stof(argv(1));
		launchOffset[1]= stof(argv(2));
		launchOffset[2]= stof(argv(3));

		if (EntityDef_HasSpawnClass(defName)) {
			ncProjectile_SpawnDefAtPosition(defName, (ncActor)this, GetOrigin() + launchOffset, GetViewAngle());
		}
		break;
	case "SpawnProjectileDef":
		if (EntityDef_HasSpawnClass(strData)) {
			ncProjectile_SpawnDefAttachment(strData, (ncActor)this, 0);
		}
		break;
	case "Flash":
		tokenize_console(strData);
		string flashRadius = argv(0);
		string flashTime = argv(1);
		string flashColorR = argv(2);
		string flashColorG = argv(3);
		string flashColorB = argv(4);
		te_customflash(WorldSpaceCenter(), stof(flashRadius), stof(flashTime), stov(strcat(flashColorR, " ", flashColorG, " ", flashColorB)));
		break;
	case "StartSound":
		StartSound(strData, CHAN_VOICE, 0, true);
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
		m_editorColor = ReadVector(strData);
		break;
	case "Respawn":
		Respawn();
		break;
	case "DropToFloor":
		DropToFloor();
		break;
	case "Show":
		Show();
		break;
	case "Hide":
		Hide();
		break;
	case "Disappear":
		Disappear();
		break;
	default:
		ncTrigger::Input(eAct, strInput, strData);
	}
}
#endif

void
ncEntity::SpawnKey(string keyName, string setValue)
{
	/* we do re-read a lot of the builtin fields in case we want to set
	   defaults. just in case anybody is wondering. */
	switch (keyName) {
	case "spawnflags":
		spawnflags = ReadFloat(setValue);
		break;
	case "origin":
		origin = ReadVector(setValue);
		break;
	case "model":
		model = ReadString(setValue);
		break;
	case "angles":
		angles = ReadVector(setValue);
		break;
	case "angle":
		angles[1] = ReadFloat(setValue);
		break;
	case "solid":
		solid = ReadFloat(setValue);
		break;
	case "friction":
		friction = ReadFloat(setValue);
		break;
	case "editor_color":
		m_editorColor = ReadVector(setValue);
		break;
#ifdef SERVER
	case "health":
		health = ReadFloat(setValue);
		break;
	case "movewith": /* SoHL */
	case "parentname": /* Source Engine */
	case "parent": /* also SoHL? */
		m_parent = ReadString(setValue);
		break;
	case "ignorepvs":
		if (ReadBool(setValue) == true) {
			pvsflags = PVSF_IGNOREPVS;
		} else {
			pvsflags &= ~PVSF_IGNOREPVS;
		}
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
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
ncEntity::Show(void)
{
	effects &= ~EF_NODRAW;
}

void
ncEntity::Hide(void)
{
	effects |= EF_NODRAW;
}

bool
ncEntity::IsHidden(void)
{
	return (effects & EF_NODRAW) ? true : false;
}

void
ncEntity::Disappear(void)
{
	modelindex = (0);
	SetSolid(SOLID_NOT);
}

void
ncEntity::MakeStatic(void)
{
	makestatic(this);
}

bool
ncEntity::CanSpawn(bool clientSide)
{
	return !(clientSide);
}

bool
ncEntity::WithinBounds(entity check)
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
ncEntity::IntersectsWith(entity check)
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
ncEntity::StartSound(string strSample, float channel, float flags, bool broadcast)
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
ncEntity::StartSoundDef(string strSample, float channel, bool broadcast)
{
	SndEntLog("%s (chan: %d bcast: %d)", strSample, channel, broadcast);
	SoundDef_Play(this, channel, strSample);
	return (true);
}

void
ncEntity::StopSound(float channel, bool broadcast)
{
	if (broadcast) {
		SoundDef_Stop(this, channel);
	} else {
#ifdef SERVER
		msg_entity = this;
		sound(this, channel, "common/null.wav", 0.1f, ATTN_NORM, 100, SOUNDFLAG_UNICAST  | SOUNDFLAG_FOLLOW, 0 );
		msg_entity = __NULL__;
#else
		SoundDef_Stop(this, channel);
#endif
	}
}

vector
ncEntity::NearestWallPointForRadius(float radius)
{
	vector vecRadius = [radius, radius, radius];
	tracebox(origin, -vecRadius, vecRadius, origin, MOVE_EVERYTHING, this);
	return (trace_fraction <= 1.0) ? (trace_endpos) : (origin);
}

void
ncEntity::HandleThink(void)
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
ncEntity::IsFacing(entity target)
{
	vector vecDiff = vectorNormalize(target.origin - origin);
	return ((vecDiff * GetForward()) > 0) ? true : false;
}

bool
ncEntity::IsFacingPosition(vector targetPos)
{
	vector vecDiff = vectorNormalize(targetPos - origin);
	return ((vecDiff * GetForward()) > 0) ? true : false;
}

float
ncEntity::GetSpawnAge(void)
{
	return (time - m_spawnTime);
}

float
ncEntity::GetSpawnTime(void)
{
	return (m_spawnTime);
}

void
ncEntity::Transport(vector new_pos, vector new_ang)
{
	float flSpeed = length(this.GetVelocity());
	SetVelocity(anglesToForward(new_ang) * flSpeed);

	SetOrigin(new_pos);
	SetAngles(new_ang);

#ifdef SERVER
	if (is.Client(this)) {
		Client_FixAngle(this, new_ang);
	}
#endif
}

vector
ncEntity::GetNearbySpot(void)
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
ncEntity::_ProjectileAttack(string defName, bool wasReleased)
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
		ncAttack_SpawnDefAtPosition(attackDef, (ncActor)this, GetEyePos(), GetViewAngle());
	}
#endif

	return (true);
}

bool
ncEntity::AttackByDef(string defName, bool wasReleased)
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
ncEntity::SetBotTag(botInfo_t newTag)
{
#ifdef SERVER
	botinfo = newTag;
#endif
}

int
ncEntity::GetSharedID(void)
{
#ifdef CLIENT
	return (int)(entnum);
#else
	return (int)num_for_edict(this);
#endif
}

void
ncEntity::EnablePlayerCollision(void)
{
	dimension_solid = 255;
	dimension_hit = 255;
}

void
ncEntity::DisablePlayerCollision(void)
{
	dimension_solid = 1;
	dimension_hit = 1;
}

void
ncEntity::_ModelChanged(void)
{
	model = modelnameforindex(modelindex);
	m_modelBrushBased = substring(model, 0, 1) == "*" ? true : false;
}
