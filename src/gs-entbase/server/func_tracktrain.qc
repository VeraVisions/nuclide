/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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
	TRAIN_NOPITCH,
	TRAIN_NOUSER,
	TRAIN_NONSOLID,
	TRAIN_FIXED,
	TRAIN_UNUSED1,
	TRAIN_SOUNDPITCH,
	TRAIN_NOBLOCK
};

enumflags
{
	FNCTKTRNET_DRIVER,
	FNCTKTRNET_MODELINDEX,
	FNCTKTRNET_ORIGIN,
	FNCTKTRNET_ANGLES,
	FNCTKTRNET_VELOCITY,
	FNCTKTRNET_TURNING,
	FNCTKTRNET_SOLIDMOVETYPE,
	FNCTKTRNET_FLAGS
};

/*! \brief Server-Entity: Interactive Moving Train */
/*!QUAKED func_tracktrain (0 .5 .8) ? NOPITCH NOUSER NOTSOLID
# OVERVIEW
An interactive train that moves along a series of path_track entities.
It turns and can respond to user input. It does not necessarily have to.

# KEYS
- "targetname" : Name
- "target" : First node to target.
- "killtarget" : Target to kill when triggered.
- "dmg" : Damage to inflict upon a person blocking the way.
- "snd_move" : Path to sound sample which plays when it's moving.
- "snd_stop" : Path to sound sample which plays when it stops moving.

# SPAWNFLAGS
- NOPITCH (1) : Stop at each path_track until we're triggered again.
- NOUSER (2) : Train does not pivot up/down at all.
- NOTSOLID (8) : Don't do collision testing against this entity.
- FIXED (16) : Fixed orientation. Will not turn, only move.

# NOTES
Upon level entry, the func_tracktrain will spawn right where its first path_track
node is, as specified in `target`. 

This is so you can light the func_tracktrain somewhere else - like a lonely
box somewhere outside the playable area.

If no targetname is specified, the train will move on its own at map-launch.

By default, any func_tracktrain can be interacted with by players.
You can restrict the area in which the train can be used with a func_traincontrols
entity. You can also set the NOUSER (2) spawnflag to disable it entirely.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
func_tracktrain:ncVehicle
{
public:
	void func_tracktrain(void);

#ifdef CLIENT
	/* overrides */
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void ReceiveEntity(float, float);
	virtual void UpdateView(void);
	//virtual void postdraw(void);
#endif

#ifdef SERVER
	/** Call to move the tracktrain forward. */
	nonvirtual void PathMoveForward(void);
	/** Call to move the tracktrain backward. */
	nonvirtual void PathMoveBack(void);

	/** Called when the current path is cleared, and a stop sound is played. */
	nonvirtual void PathClear(void);
	/** Called when the current path is cleared, and a stop sound is played. */
	nonvirtual void PathDone(void);

	/** Returns if the train can pitch up/down. */
	nonvirtual bool IgnoresPitch(void);

	/** Returns the track node (path_track) ahead of the train. */
	nonvirtual path_track GetTrackNodeForward(void);
	/** Returns the track node (path_track) back of the train. */
	nonvirtual path_track GetTrackNodeBack(void);
	/** Returns a 3d position between two nodes at the specified progression. Value between 0.0f - 1.0f, 1.0 being closest to the next node heading forward.*/
	nonvirtual vector GetPointBetweenNodes(float);
	nonvirtual vector GetTrainPivotPoint(bool);

	nonvirtual void RenderDebugInfo(void);
	nonvirtual bool ControlCheck(entity);

	/* overrides */
	virtual void Blocked(entity);
	virtual void OnPlayerUse(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void TransitionComplete(void);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float)
;
#endif

	virtual void PlayerInput(void);

#ifdef SERVER
private:

	float m_flWait;
	float m_flSpeed;
	float m_flDamage;
	float m_flHeight;
	float m_flStartSpeed;
	float m_flCurrentSpeed;
	float m_flBank;
	string m_strMoveSnd;
	string m_strStopSnd;
	vector m_vecRelationTarget;
	float m_flUseTime;
	int m_iInputDirection;
	int m_iOldInputDirection;
	int m_iInputLevel;
	int m_iOldInputLevel;
	ncTimer m_timerAngled;
	float m_flTrainLength;
	bool _m_bDriving;

	nonvirtual void _SoundMove(void);
	nonvirtual void _SoundStop(void);
	nonvirtual void _AfterSpawn(void);
	nonvirtual void _PathArrivedForward(void);
	nonvirtual void _PathArrivedBack(void);
	nonvirtual void _AngleDone(void);
#endif
};

void
func_tracktrain::func_tracktrain(void)
{
#ifdef SERVER
	m_flWait = 0.0f;
	m_flSpeed = 100; /* FIXME: This is all decided by the first path_track pretty much */
	m_flDamage = 0.0f;
	m_flHeight = 0.0f;
	m_flStartSpeed = 0.0f;
	m_flCurrentSpeed = 0.0f;
	m_flBank = 0.0f;
	m_strMoveSnd = __NULL__;
	m_strStopSnd = __NULL__;
	m_vecRelationTarget = g_vec_null;
	m_flUseTime = 0.0f;
	m_iInputDirection = 0i;
	m_iOldInputDirection = 0i;
	m_iInputLevel = 0i;
	m_iOldInputLevel = 0i;
	m_timerAngled = __NULL__;
	m_flTrainLength = 0.0f;
	_m_bDriving = false;
#endif
}

#ifdef SERVER
vector
func_tracktrain::GetPointBetweenNodes(float percentageValue)
{
	vector newPos = g_vec_null;
	path_track nextNode = GetTrackNodeForward();
	path_track prevNode = GetTrackNodeBack();
	newPos = vectorLerp(prevNode.origin, nextNode.origin, percentageValue);
	return newPos;
}

vector
func_tracktrain::GetTrainPivotPoint(bool drivingBackwards)
{
/* needs more work */
#if 1
	return GetOrigin();
#else
	vector newPos;
	path_track nextNode;
	vector currentDifference;
	float currentLength;
	float shorterLengthTest;

	if (drivingBackwards) {
		return GetOrigin();
	} else {

		newPos = GetOrigin();
		nextNode = GetTrackNodeForward();
		currentDifference = (newPos - nextNode.GetOrigin());
		currentLength = vlen(currentDifference);

		makevectors(GetAngles());
		newPos += v_forward * -m_flTrainLength;

		shorterLengthTest = vlen(GetOrigin() - newPos);

		/* too short to turn */
		if (shorterLengthTest > currentLength) {
			return GetOrigin();
		}
	}

	return newPos;
#endif
}

path_track
func_tracktrain::GetTrackNodeForward(void)
{
	if (!HasTriggerTarget()) {
		return __NULL__;
	}

	for (entity e = world; (e = find(e, ::targetname, GetTriggerTarget()));) {
		if (e.classname == "path_track" || e.classname == "path_corner") {
			if (e.classname == "path_track") {
				path_track track = (path_track)e;

				if (track.m_bTrackEnabled == false) {
					continue;
				}
			}
			return e;
		}
	}

	return __NULL__;
}

path_track
func_tracktrain::GetTrackNodeBack(void)
{
	path_track forwardNode = GetTrackNodeForward();

	if (forwardNode) {
		return forwardNode.GetSelfTargetEntity();
	}

	return __NULL__;
}

void
func_tracktrain::RenderDebugInfo(void)
{
	path_track eNode;
	path_track oldNode;
	vector startPos = GetTrainPivotPoint(false);

	/* draw axis lines */
	{
		makevectors(GetAngles());
		
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(startPos, [0,1], [0,1,0], 1.0);
		R_PolygonVertex(startPos + (v_forward * -128), [1,1], [0,1,0], 1.0);
		R_EndPolygon();
		
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(startPos, [0,1], [1,0,0], 1.0);
		R_PolygonVertex(startPos + (v_up * 128), [1,1], [1,0,0], 1.0);
		R_EndPolygon();
		
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(startPos, [0,1], [0,0,1], 1.0);
		R_PolygonVertex(startPos + (v_right * -128), [1,1], [0,0,1], 1.0);
		R_EndPolygon();
	}

	/* next node */
	eNode = (path_track)GetTrackNodeForward();

	/* line to the next node forward (green) */
	if (eNode) {
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(startPos, [0,1], [0,1,0], 1.0);
		R_PolygonVertex(eNode.GetOrigin() + [0,0, m_flHeight], [1,1], [0,1,0], 1.0);
		R_EndPolygon();
	}

	oldNode = eNode;

	/* line to the next node forward (green) */
	if (eNode) {
		eNode = (path_track)eNode.GetPathTargetEntity();
		if (eNode) {
			R_BeginPolygon("", 0, 0);
			R_PolygonVertex(oldNode.GetOrigin() + [0,0, m_flHeight], [0,1], [0,0.75,0], 1.0);
			R_PolygonVertex(eNode.GetOrigin() + [0,0, m_flHeight], [1,1], [0,0.75,0], 1.0);
			R_EndPolygon();
			oldNode = eNode;
			eNode = (path_track)eNode.GetPathTargetEntity();

			if (eNode) {
				R_BeginPolygon("", 0, 0);
				R_PolygonVertex(oldNode.GetOrigin() + [0,0, m_flHeight], [0,1], [0,0.75,0], 1.0);
				R_PolygonVertex(eNode.GetOrigin() + [0,0, m_flHeight], [1,1], [0,0.75,0], 1.0);
				R_EndPolygon();
			}
		}
	}

	/* node back */
	eNode = (path_track)GetTrackNodeBack();

	/* line to the next node forward (green) */
	if (eNode) {
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(startPos, [0,1], [1,0,0], 1.0);
		R_PolygonVertex(eNode.GetOrigin() + [0,0, m_flHeight], [1,1], [1,0,0], 1.0);
		R_EndPolygon();
	}

	oldNode = eNode;

	if (eNode) {
		eNode = (path_track)eNode.GetSelfTargetEntity();

		if (eNode) {
			/* line to the next node forward (green) */
			R_BeginPolygon("", 0, 0);
			R_PolygonVertex(oldNode.GetOrigin() + [0,0, m_flHeight], [0,1], [0.75,0,0], 1.0);
			R_PolygonVertex(eNode.GetOrigin() + [0,0, m_flHeight], [1,1], [0.75,0,0], 1.0);
			R_EndPolygon();

			oldNode = eNode;
			eNode = (path_track)eNode.GetSelfTargetEntity();

			if (eNode) {
				R_BeginPolygon("", 0, 0);
				R_PolygonVertex(oldNode.GetOrigin() + [0,0, m_flHeight], [0,1], [0.75,0,0], 1.0);
				R_PolygonVertex(eNode.origin + [0,0, m_flHeight], [1,1], [0.75,0,0], 1.0);
				R_EndPolygon();
			}
		}
	}
}

bool
func_tracktrain::IgnoresPitch(void)
{
	if (HasSpawnFlags(TRAIN_NOPITCH)) {
		return (true);
	}

	return (false);
}

void
func_tracktrain::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flDamage", m_flDamage);
	SaveFloat(handle, "m_flHeight", m_flHeight);
	SaveFloat(handle, "m_flStartSpeed", m_flStartSpeed);
	SaveFloat(handle, "m_flCurrentSpeed", m_flCurrentSpeed);
	SaveFloat(handle, "m_flBank", m_flBank);
	SaveString(handle, "m_strMoveSnd", m_strMoveSnd);
	SaveString(handle, "m_strStopSnd", m_strStopSnd);
	SaveFloat(handle, "m_flUseTime", m_flUseTime);
	SaveInt(handle, "m_iInputDirection", m_iInputDirection);
	SaveInt(handle, "m_iOldInputDirection", m_iOldInputDirection);
	SaveInt(handle, "m_iInputLevel", m_iInputLevel);
	SaveEntity(handle, "m_timerAngled", m_timerAngled);
	SaveFloat(handle, "m_flTrainLength", m_flTrainLength);
	SaveBool(handle, "_m_bDriving", _m_bDriving);

	/* if we are on a track, take the difference in offset so we can smoothly transition */
	if (HasTriggerTarget()) {
		path_track targetEnt = GetTrackNodeForward();
		m_vecRelationTarget = targetEnt.GetOrigin() - GetOrigin();
	} else {
		m_vecRelationTarget = g_vec_null;
	}

	SaveVector(handle, "m_vecRelationTarget", m_vecRelationTarget);
}

void
func_tracktrain::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flWait":
		m_flWait = ReadFloat(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flDamage":
		m_flDamage = ReadFloat(strValue);
		break;
	case "m_flHeight":
		m_flHeight = ReadFloat(strValue);
		break;
	case "m_flStartSpeed":
		m_flStartSpeed = ReadFloat(strValue);
		break;
	case "m_flCurrentSpeed":
		m_flCurrentSpeed = ReadFloat(strValue);
		break;
	case "m_flBank":
		m_flBank = ReadFloat(strValue);
		break;
	case "m_strMoveSnd":
		m_strMoveSnd = ReadString(strValue);
		break;
	case "m_strStopSnd":
		m_strStopSnd = ReadString(strValue);
		break;
	case "m_flUseTime":
		m_flUseTime = ReadFloat(strValue);
		break;
	case "m_iInputDirection":
		m_iInputDirection = ReadInt(strValue);
		break;
	case "m_iOldInputDirection":
		m_iOldInputDirection = ReadInt(strValue);
		break;
	case "m_iInputLevel":
		m_iInputLevel = ReadInt(strValue);
		break;
	case "m_timerAngled":
		m_timerAngled = (ncTimer)ReadEntity(strValue);
		break;
	case "m_flTrainLength":
		m_flTrainLength = ReadFloat(strValue);
		break;
	case "_m_bDriving":
		_m_bDriving = ReadBool(strValue);
		break;
	case "m_vecRelationTarget":
		m_vecRelationTarget = ReadVector(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_tracktrain::TransitionComplete(void)
{
	/* don't mess with this entity if it wasn't carrying over from someplace */
	if (!STRING_SET(m_strGlobalName)) {
		return;
	}

	/* it might have a globalname, but we may not have been carrying over the the next
	   level yet! */
	if (m_vecRelationTarget == g_vec_null) {
		return;
	}

	/* targetting something, which was used as a reference point */
	if (HasTriggerTarget() == true) {
		path_track targetEnt = GetTrackNodeForward();
		SetOrigin(targetEnt.GetOrigin() - m_vecRelationTarget);
	}
}

void
func_tracktrain::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "speed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "startspeed":
		m_flStartSpeed = stof(strValue);
		break;
	case "height":
		m_flHeight = stof(strValue);
		break;
	case "dmg":
		m_flDamage = stof(strValue);
		break;
	case "snd_move":
	case "MoveSound":
		m_strMoveSnd = strValue;
		break;
	case "snd_stop":
	case "StopSound":
		m_strStopSnd = strValue;
		break;
	case "wheels":
		m_flTrainLength = 0; //ReadFloat(strValue);
		break;
	/* compatibility */
	case "sounds":
	case "movesnd":
		m_strMoveSnd = sprintf("func_tracktrain.move_%i", stoi(strValue) + 1i);
		break;
	case "stopsnd":
		m_strStopSnd = sprintf("func_tracktrain.stop_%i", stoi(strValue) + 1i);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_tracktrain::Spawned(void)
{
	super::Spawned();

	if (STRING_SET(m_strMoveSnd))
		Sound_Precache(m_strMoveSnd);
	if (STRING_SET(m_strStopSnd))
		Sound_Precache(m_strStopSnd);

	Sound_Precache("func_tracktrain.stop_1");
}

void
func_tracktrain::Respawn(void)
{
	super::Respawn();

	/* legacy compat */
	SetSolid(HasSpawnFlags(TRAIN_NONSOLID) ? SOLID_NOT : SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);

	m_flCurrentSpeed = m_flStartSpeed;

	/* this needs to be a bit later than anything else. */
	ScheduleThink(_AfterSpawn, 0.1f);
	PlayerUse = OnPlayerUse;

	if (m_flTrainLength == 0.0f)
		m_flTrainLength = 100.0f;
}

void
func_tracktrain::Blocked(entity eBlocker)
{
	if (eBlocker.groundentity == this) {
		return;
	}

	if (eBlocker == m_eDriver) {
		return;
	}

	/* evil, since we're not based on it (yet) */
	func_train::Blocked(eBlocker);
}

void
func_tracktrain::_SoundMove(void)
{
	if (STRING_SET(m_strMoveSnd)) {
		StartSoundDef(m_strMoveSnd, CHAN_VOICE, true);
	}
}

void
func_tracktrain::_SoundStop(void)
{
	if (STRING_SET(m_strStopSnd)) {
		StartSoundDef(m_strStopSnd, CHAN_BODY, true);
	}

	if (STRING_SET(m_strMoveSnd)) {
		if (!STRING_SET(m_strStopSnd)) {
			StartSoundDef("func_tracktrain.stop_1", CHAN_BODY, true);
		}
		StopSound(CHAN_VOICE, true);
	}
}

void
func_tracktrain::PathMoveForward(void)
{
	path_track eNode;
	path_track previousNode;
	float flTravelTime;
	vector vecVelocity;
	vector vecAngleDest;
	vector vecDiff;
	vector vecAngleDiff;
	float travelSpeed;
	float turnTime;

	eNode = GetTrackNodeForward();
	previousNode = GetTrackNodeBack();

	if (!eNode) {
		ncVehicle_Log("No node.");
		return;
	}

	/* determine current speed */
	if (m_iInputLevel > 0) {
		travelSpeed = (m_flCurrentSpeed * (float)m_iInputLevel) / 2.0f;
	} else {
		travelSpeed = m_flCurrentSpeed * 1.25f; /* HACK: escape multi_manager rc in c0a0b */
	}

	vecVelocity = (GetPointBetweenNodes(1.0f) + [0,0,m_flHeight]) - GetTrainPivotPoint(false);
	turnTime = (vlen(vecVelocity) / travelSpeed);

	vecVelocity = (eNode.GetOrigin() + [0,0,m_flHeight]) - GetOrigin();
	flTravelTime = (vlen(vecVelocity) / travelSpeed);

	if (flTravelTime <= 0.0) {
		ncVehicle_Log("^1func_tracktrain::^3PathMoveForward^7: Distance short, going next");
		SetVelocity([1,1,1]);
		ScheduleThink(_PathArrivedForward, 0.1f);
		return;
	}

	ncVehicle_Log("^1func_tracktrain::^3PathMoveForward^7: Changing velocity from '%v' to '%v'", GetVelocity(), vecVelocity);
	SetVelocity(vecVelocity * (1 / flTravelTime));

	if (_m_bDriving == false) {
		_SoundMove();
	}

	/* the direction we're aiming for */
	vecDiff = GetOrigin() - (eNode.GetOrigin() + [0, 0, m_flHeight]);
	vecAngleDest = vectoangles(vecDiff);
	vecAngleDiff = angleDifference(vecAngleDest, angles);
	vecAngleDiff[2] = 0;

	if (vecAngleDiff[0] > 180)
		vecAngleDiff[0] -= 180;
	if (vecAngleDiff[0] < -180)
		vecAngleDiff[0] += 180;
	if (vecAngleDiff[1] > 180)
		vecAngleDiff[1] -= 180;
	if (vecAngleDiff[1] < -180)
		vecAngleDiff[1] += 180;

	if (IgnoresPitch() == true) {
		vecAngleDiff[0] = 0;
		vecAngleDest[0] = 0;
	} 

	ncVehicle_Log("^1func_tracktrain::^3PathMoveBack^7: angleDelta: '%v'", vecAngleDiff);

	if (vecAngleDiff[1] == 0)
		SetAngles(vecAngleDest);
	else
		SetAngularVelocity(vecAngleDiff * (1 / turnTime));

	if (!eNode)
		SetAngularVelocity([0,0,0]);

	_m_bDriving = true;
	ScheduleThink(_PathArrivedForward, flTravelTime);
	m_timerAngled = m_timerAngled.ScheduleTimer(this, _AngleDone, turnTime, false);
}

void
func_tracktrain::_AngleDone(void)
{
	SetAngularVelocity(g_vec_null);
}

void
func_tracktrain::PathMoveBack(void)
{
	path_track eNode;
	float flTravelTime;
	vector vecVelocity;
	vector vecAngleDest;
	vector vecDiff;
	vector vecAngleDiff;
	float travelSpeed;
	float turnTime;

	/* grab the node that's pointing at the current target (back) */
	eNode = (path_track)GetTrackNodeBack();

	/* None, abort */
	if (!eNode) {
		ncVehicle_Log("No node.\n");
		return;
	}

	/* determine current speed */
	if (m_iInputLevel < 0) {
		travelSpeed = (m_flCurrentSpeed * (float)-m_iInputLevel) / 2.0f;
	} else {
		travelSpeed = m_flCurrentSpeed;
	}

	vecVelocity = (GetPointBetweenNodes(0.15f) + [0,0,m_flHeight]) - GetTrainPivotPoint(true);
	turnTime = (vlen(vecVelocity) / travelSpeed);

	vecVelocity = (eNode.GetOrigin() + [0,0,m_flHeight]) - GetOrigin();
	flTravelTime = (vlen(vecVelocity) / travelSpeed);

	if (flTravelTime <= 0.0) {
		ncVehicle_Log("^Distance short, teleporting next.");
		ScheduleThink(_PathArrivedBack, 0.0f);
		SetVelocity([1,1,1]);
		return;
	}

	ncVehicle_Log("Changing velocity from '%v' to '%v'", GetVelocity(), vecVelocity);
	SetVelocity(vecVelocity * (1 / flTravelTime));
	_SoundMove();

	/* the direction we're aiming for */
	vecDiff = (eNode.GetOrigin() + [0, 0, m_flHeight]) - GetOrigin();
	vecAngleDest = vectorToAngles(vecDiff);
	vecAngleDiff = angleDifference(vecAngleDest, angles);
	vecAngleDiff[2] = 0;

	if (vecAngleDiff[0] > 180)
		vecAngleDiff[0] -= 180;
	if (vecAngleDiff[0] < -180)
		vecAngleDiff[0] += 180;
	if (vecAngleDiff[1] > 180)
		vecAngleDiff[1] -= 180;
	if (vecAngleDiff[1] < -180)
		vecAngleDiff[1] += 180;

	if (IgnoresPitch() == true) {
		vecAngleDiff[0] = 0;
		vecAngleDest[0] = 0;
	} 

	ncVehicle_Log("^1func_tracktrain::^3PathMoveBack^7: angleDelta: %v", vecAngleDiff);

	if (vecAngleDiff[1] == 0)
		SetAngles(vecAngleDest);
	else
		SetAngularVelocity(vecAngleDiff * (1 / turnTime));

	if (!eNode)
		SetAngularVelocity([0,0,0]);

	_m_bDriving = true;
	ScheduleThink(_PathArrivedBack, flTravelTime);
	m_timerAngled = m_timerAngled.ScheduleTimer(this, _AngleDone, turnTime, false);
}

void
func_tracktrain::PathDone(void)
{
	path_track eNode;
	eNode = (path_track)find(world, ::targetname, target);

	if (!eNode) {
		error("Node we were targetting no longer exists.");
		return;
	}

	ncVehicle_Log("func_tracktrain (%s): Touched base with path_track %S", targetname, target);

	/* fire the path_tracks' target */
	eNode.PathPassTrigger(this, TRIG_TOGGLE);
}

void
func_tracktrain::_PathArrivedForward(void)
{
	path_track eNode;

	/* train has been disabled. */
	if (HasTriggerTarget() == false) {
		return;
	}

	/* get what's in front of us. */
	eNode = (path_track)GetTrackNodeForward();

	/* we have to check this _after_ moving... */
	if (eNode.DisablesTrain() == true) {
		/* first clear velocity, in case our trigger targets our train */
		PathClear();
		eNode.PathEndTrigger(this, TRIG_TOGGLE);
		target = __NULL__;	/* makes the train inaccessible */
		return;
	}

	/* we have nothing. */
	if (!eNode) {
		PathClear();
		return;
	}
	
	ncVehicle_Log("^1func_tracktrain::^3_PathArrivedForward^7: Going to target %S (%s)", target, eNode.classname);
	SetOrigin((eNode.GetOrigin()) + [0,0,m_flHeight]);
	PathDone();

	if (m_iInputLevel == 0) {
		/* if speed is 0, retain current speed */
		if (eNode.m_flSpeed > 0) {
			m_flCurrentSpeed = eNode.m_flSpeed;
		} else {
			m_flCurrentSpeed = m_flSpeed;
		}
	}

	m_flWait = eNode.m_flWait;

	ncVehicle_Log("^1func_tracktrain::^3_PathArrivedForward^7: Target changed from %S to %S", target, eNode.GetPathTarget());

	target = eNode.GetPathTarget();

	if (!HasTriggerTarget() || target == eNode.targetname) {
		/* first clear velocity, in case our trigger targets our train */
		PathClear();
		eNode.PathEndTrigger(this, TRIG_TOGGLE);
		return;
	}

	/* warp */
	if (eNode.HasSpawnFlags(PC_TELEPORT)) {
		SetOrigin((eNode.GetOrigin()) + [0,0,m_flHeight]);
	}

	/* stop until triggered again */
	if (eNode.HasSpawnFlags(PC_WAIT)) {
		PathClear();
		return;
	}

	PathMoveForward();
}

void
func_tracktrain::_PathArrivedBack(void)
{
	path_track eNode;

	/* train has been disabled */
	if (HasTriggerTarget() == false) {
		return;
	}

	/* what's the node 'behind' us? */
	eNode = (path_track)GetTrackNodeBack();

	/* we have none... clear velocity */
	if (!eNode) {
		PathClear();
		return;
	}

	ncVehicle_Log("^1func_tracktrain::^3_PathArrivedBack^7: Going to target %S (%s)", target, eNode.classname);
	SetOrigin((eNode.GetOrigin()) + [0,0,m_flHeight]);
	PathDone();

	/* if speed is 0, retain current speed */
	if (m_iInputLevel == 0) {
		if (eNode.m_flSpeed > 0)
			m_flCurrentSpeed = eNode.m_flSpeed;
		else
			m_flCurrentSpeed = m_flSpeed;
	}

	m_flWait = eNode.m_flWait;
	ncVehicle_Log("^1func_tracktrain::^3_PathArrivedBack^7: Target changed from %S to %S", target, eNode.targetname);
	target = eNode.targetname;

	/* warp */
	if (eNode.HasSpawnFlags(PC_TELEPORT)) {
		SetOrigin((eNode.GetOrigin()) + [0,0,m_flHeight]);
	}

	/* stop until triggered again */
	if (eNode.HasSpawnFlags(PC_WAIT)) {
		PathClear();
		return;
	}

	PathMoveBack();

	/* we have to check this _after_ moving... */
	if (eNode.DisablesTrain() == true) {
		target = __NULL__;	/* makes the train inaccessible */
	}
}

void
func_tracktrain::PathClear(void)
{
	if (length(velocity) >= 1.0f) {
		_SoundStop();
	}

	_m_bDriving = false;
	ClearVelocity();
	ReleaseThink();
}

/* TODO: Handle state? */
void
func_tracktrain::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_ON:
		PathMoveForward();
		break;
	case TRIG_OFF:
		PathClear();
		break;
	case TRIG_TOGGLE:
	default:
		if (_m_bDriving == false)
			PathMoveForward();
		else {
			PathClear();
		}
	}
}

/* TODO: Handle state? */
void
func_tracktrain::Input(entity act, string inputName, string dataString)
{
	switch (inputName) {
	case "StartForward":
		PathMoveForward();
		break;
	case "Stop":
		PathClear();
		break;
	default:
		super::Input(act, inputName, dataString);
	}
}

void
func_tracktrain::_AfterSpawn(void)
{
	path_track targetNode;
	path_track nodeAhead;

	SetTriggerTarget(GetSpawnString("target"));

	/* get the first target */
	targetNode = (path_track)GetTrackNodeForward();

	/* unpossible */
	if (!targetNode || HasTriggerTarget() == false) {
		ncVehicle_Log("^1func_tracktrain::^3_AfterSpawn^7: %d has no valid target (%S).", num_for_edict(this), GetTriggerTarget());
		return;
	}

	ncVehicle_Log("^1func_tracktrain::^3_AfterSpawn^7: Start at target %S (%s)", target, targetNode.classname);

	/* teleport to the first target for starters. */
	SetOrigin((targetNode.GetOrigin()) + [0,0,m_flHeight]);
	PathDone();

	/* face the train towards the next target. while it may be tempting to use
	   GetPathTargetEntity() here, that node may be disabled. so look manually. */
	nodeAhead = (path_track)find(world, ::targetname, targetNode.target);

	/* node found. */
	if (nodeAhead) {
		vector newAngle = vectoangles(targetNode.GetOrigin() - nodeAhead.GetOrigin());

		if (IgnoresPitch() == true) {
			newAngle[0] = 0;
		} else {
			newAngle[0] = -fixAngleDelta(newAngle[0]);
		}

		SetAngles(newAngle);
	}

	/* if speed is 0, retain current speed */
	if (targetNode.m_flSpeed > 0) {
		m_flCurrentSpeed = targetNode.m_flSpeed;
	} else {
		m_flCurrentSpeed = m_flSpeed;
	}

	m_flWait = targetNode.m_flWait;
	target = targetNode.target;

	/* warp */
	if (targetNode.HasSpawnFlags(PC_TELEPORT)) {
		SetOrigin((targetNode.GetOrigin()) + [0,0,m_flHeight]);
	}

	/* stop until triggered again */
	if (targetNode.HasSpawnFlags(PC_WAIT)) {
		_SoundStop();
		return;
	}

	/* auto start */
	if (!targetname || m_flStartSpeed > 0.0f) {
		PathMoveForward();
	}
}

bool
func_tracktrain::ControlCheck(entity toCheck)
{
	entity controller = __NULL__;

	/* this train can never be used by a player. */
	if (HasSpawnFlags(TRAIN_NOUSER)) {
		return (false);
	}

	/* no targetname = no control area possible, auto true */
	if (HasTargetname() == false) {
		return (true);
	}

	/* find the traincontrol responsible for us */
	for (entity f = world;(f = find(f, ::target, targetname));) {
		if (f.classname == "func_traincontrols") {
			controller = f;
			break;
		}
	}

	/* are we inside the controller? */
	if (toCheck.absmin[0] > controller.absmax[0] ||
		 toCheck.absmin[1] > controller.absmax[1] ||
		 toCheck.absmin[2] > controller.absmax[2] ||
		 toCheck.absmax[0] < controller.absmin[0] ||
		 toCheck.absmax[1] < controller.absmin[1] ||
		 toCheck.absmax[2] < controller.absmin[2]) {
		 return (false);
	}

	return (true);
}

void
func_tracktrain::OnPlayerUse(void)
{
	/* it's not been a second */
	if (m_flUseTime > time)
 {
		return;
	}

	/* we're already the driver, so leave */
	if (m_eDriver == eActivator) {
		PlayerLeave((ncPlayer)eActivator);
	} else if (!m_eDriver) {
		/* check if they're allowed to control it */
		if (ControlCheck(eActivator) == false) {
			return;
		}
		PlayerEnter((ncPlayer)eActivator);
	}

	m_flUseTime = time + 1.0f;
}

void
func_tracktrain::EvaluateEntity(void)
{
	angles = fixAngle(angles);
	PlayerAlign();

	EVALUATE_FIELD(modelindex, FNCTKTRNET_MODELINDEX)
	EVALUATE_FIELD(origin, FNCTKTRNET_ORIGIN)
	EVALUATE_FIELD(angles, FNCTKTRNET_ANGLES)
	EVALUATE_FIELD(velocity, FNCTKTRNET_VELOCITY)
	EVALUATE_FIELD(flags, FNCTKTRNET_FLAGS)
	EVALUATE_FIELD(solid, FNCTKTRNET_SOLIDMOVETYPE)
	EVALUATE_FIELD(movetype, FNCTKTRNET_SOLIDMOVETYPE)
	EVALUATE_FIELD(mins, FNCTKTRNET_SOLIDMOVETYPE)
	EVALUATE_FIELD(maxs, FNCTKTRNET_SOLIDMOVETYPE)
}

float
func_tracktrain::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex) {
		return (false);
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (false);
	}

	WriteByte(MSG_ENTITY, ENT_TRACKTRAIN);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_SHORT(modelindex, FNCTKTRNET_MODELINDEX)
	SENDENTITY_COORD(origin[0], FNCTKTRNET_ORIGIN)
	SENDENTITY_COORD(origin[1], FNCTKTRNET_ORIGIN)
	SENDENTITY_COORD(origin[2], FNCTKTRNET_ORIGIN)
	SENDENTITY_ANGLE(angles[0], FNCTKTRNET_ANGLES)
	SENDENTITY_ANGLE(angles[1], FNCTKTRNET_ANGLES)
	SENDENTITY_ANGLE(angles[2], FNCTKTRNET_ANGLES)
	SENDENTITY_COORD(velocity[0], FNCTKTRNET_VELOCITY)
	SENDENTITY_COORD(velocity[1], FNCTKTRNET_VELOCITY)
	SENDENTITY_COORD(velocity[2], FNCTKTRNET_VELOCITY)
	SENDENTITY_INT(flags, FNCTKTRNET_FLAGS)
	SENDENTITY_BYTE(solid, FNCTKTRNET_SOLIDMOVETYPE)
	SENDENTITY_BYTE(movetype, FNCTKTRNET_SOLIDMOVETYPE)
	SENDENTITY_INT(flags, FNCTKTRNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(mins[0], FNCTKTRNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(mins[1], FNCTKTRNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(mins[2], FNCTKTRNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(maxs[0], FNCTKTRNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(maxs[1], FNCTKTRNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(maxs[2], FNCTKTRNET_SOLIDMOVETYPE)

	return (true);
}
#endif

#ifdef CLIENT
void
func_tracktrain::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_SHORT(modelindex, FNCTKTRNET_MODELINDEX)
	READENTITY_COORD(origin[0], FNCTKTRNET_ORIGIN)
	READENTITY_COORD(origin[1], FNCTKTRNET_ORIGIN)
	READENTITY_COORD(origin[2], FNCTKTRNET_ORIGIN)
	READENTITY_ANGLE(angles[0], FNCTKTRNET_ANGLES)
	READENTITY_ANGLE(angles[1], FNCTKTRNET_ANGLES)
	READENTITY_ANGLE(angles[2], FNCTKTRNET_ANGLES)
	READENTITY_COORD(velocity[0], FNCTKTRNET_VELOCITY)
	READENTITY_COORD(velocity[1], FNCTKTRNET_VELOCITY)
	READENTITY_COORD(velocity[2], FNCTKTRNET_VELOCITY)
	READENTITY_INT(flags, FNCTKTRNET_FLAGS)
	READENTITY_BYTE(solid, FNCTKTRNET_SOLIDMOVETYPE)
	READENTITY_BYTE(movetype, FNCTKTRNET_SOLIDMOVETYPE)
	READENTITY_INT(flags, FNCTKTRNET_SOLIDMOVETYPE)
	READENTITY_COORD(mins[0], FNCTKTRNET_SOLIDMOVETYPE)
	READENTITY_COORD(mins[1], FNCTKTRNET_SOLIDMOVETYPE)
	READENTITY_COORD(mins[2], FNCTKTRNET_SOLIDMOVETYPE)
	READENTITY_COORD(maxs[0], FNCTKTRNET_SOLIDMOVETYPE)
	READENTITY_COORD(maxs[1], FNCTKTRNET_SOLIDMOVETYPE)
	READENTITY_COORD(maxs[2], FNCTKTRNET_SOLIDMOVETYPE)

	if (flChanged & FNCTKTRNET_SOLIDMOVETYPE) {
		setsize(this, mins, maxs);
	}

	if (flChanged & FNCTKTRNET_MODELINDEX) {
		//setsize( this, [-50,-50,0], [50,50,64]);
	}

	if (flChanged & FNCTKTRNET_ORIGIN) {
		setorigin(this, origin);
		makevectors(angles);
	}

	if (flNew) {
		drawmask = MASK_ENGINE;
		SetSolid(SOLID_BSP);
	}

	PredictPreFrame();
}

void
func_tracktrain::UpdateView(void)
{
}

void
func_tracktrain::PredictPreFrame(void)
{
	SAVE_STATE(modelindex)
	SAVE_STATE(origin)
	SAVE_STATE(angles)
	SAVE_STATE(velocity)
	SAVE_STATE(flags)
}

void
func_tracktrain::PredictPostFrame(void)
{
	ROLL_BACK(modelindex)
	ROLL_BACK(angles)
	ROLL_BACK(origin)
	ROLL_BACK(velocity)
	ROLL_BACK(flags)
}
#endif

void
func_tracktrain::PlayerInput(void)
{
#ifdef SERVER
	/* we tap forward/back to switch directions. */
	if (input_movevalues[0] > 100) {
		m_iInputDirection = 1i;
	} else if (input_movevalues[0] < -100) {
		m_iInputDirection = -1i;
	} else if (input_movevalues[0] == 0) {
		m_iInputDirection = 0i;
	}

	/* if the movement keys have been pressed differently... */
	if (m_iInputDirection != m_iOldInputDirection) {
		/* increase the level if the direction is positive */
		if (m_iInputDirection == 1i) {
			m_iInputLevel += 1i;
		} else if (m_iInputDirection == -1i) {
			m_iInputLevel += -1i;
		}

		/* max speed multiplier is 4 in either dir */
		if (m_iInputLevel > 4i) {
			m_iInputLevel = 4i;
		} else if (m_iInputLevel < -4i) {
			m_iInputLevel = -4i;
		}

		m_iOldInputDirection = m_iInputDirection;
	}

	/* level differs, adjust speed */
	if (m_iOldInputLevel != m_iInputLevel) {
		m_iOldInputLevel = m_iInputLevel;

		if (m_iInputLevel > 0i) {
			PathMoveForward();
		} else if (m_iInputLevel < 0i) {
			PathMoveBack();
		} else {
			PathClear();
		}
	}

	/* exit vehicle */
	if (input_buttons & INPUT_BUTTON5) {
		if (m_flUseTime > time)
 {
			return;
		}

		eActivator = m_eDriver;
		OnPlayerUse();
		input_buttons &= ~INPUT_BUTTON5;
	}
#endif
}
