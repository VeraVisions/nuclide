/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
	OCAMFL_CHANGED_ORIGIN,
	OCAMFL_CHANGED_ANGLES,
	OCAMFL_CHANGED_WAIT,
	OCAMFL_CHANGED_VIEWER
};

/*! \brief Shared-Entity: Camera System Trigger */
/*!QUAKED trigger_camera (.5 .5 .5) (-8 -8 -8) (8 8 8)
# OVERVIEW
Forces a camera change when triggered.

# KEYS
- "targetname" : Name
- "target" : Camera aims at this target.
- "moveto" : First path_corner entity, if present.
- "wait" : The total time the camera effect is active.

# NOTES
The client who triggers it will get its camera perspective changed to this
trigger_camera. It is capable of following a track in case "moveto" is set.
The movement finishes independently of the "wait" key.
In case you are follow a path, the triggers of the respective path_corners will
be respected.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup sharedentity
@ingroup pointentity
*/
class trigger_camera:ncPointTrigger
{
public:
	void trigger_camera(void);

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
#endif

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void NextPath(void);
	virtual void GoToTarget(void);
	virtual void Input(entity, string, string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual float SendEntity(entity,float);
	virtual void EvaluateEntity(void);
	nonvirtual void DeactivateCamera(void);
#endif

private:
	NETWORKED_FLOAT(m_flWait)
	entity m_eLooker;

#ifdef SERVER
	string m_strAimAt;
	string m_strMoveTo;
	entity m_eLooker_net;
	float m_flSpeed;
	float m_flInitialSpeed;
#endif
};

void
trigger_camera::trigger_camera(void)
{
	m_flWait = 0.0f;
	m_eLooker = __NULL__;
#ifndef CLIENT
	m_strAimAt = __NULL__;
	m_strMoveTo = __NULL__;
#endif
}

#ifdef CLIENT
void
trigger_camera::ReceiveEntity(float flNew, float flFlags)
{
	bool deactiveLocalCam = false;
	//if (flFlags & OCAMFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setorigin(this, origin);
	//}

	//if (flFlags & OCAMFL_CHANGED_ANGLES) {
		angles[0] = readfloat();
		angles[1] = readfloat();
		angles[2] = readfloat();
	//}


	if (m_eLooker == pSeat->m_ePlayer) {
		deactiveLocalCam = true;
	}

	//if (flFlags & OCAMFL_CHANGED_VIEWER) {
		m_eLooker = findfloat(world, ::entnum, readentitynum());
	//}

	//if (flFlags & OCAMFL_CHANGED_WAIT) {
		m_flWait = readfloat();
	//}

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];

	if (!m_eLooker && deactiveLocalCam == true) {
		pSeat->m_flCameraTime = 0.0;
	}

	/* not us */
	if (m_eLooker != pSeat->m_ePlayer)
		return;

	pSeat->m_vecCameraOrigin = origin;
	pSeat->m_vecCameraAngle = angles;

	//if (flFlags & OCAMFL_CHANGED_WAIT) {
		if (m_flWait == -1)
			pSeat->m_flCameraTime = -1;
		else
			pSeat->m_flCameraTime = time + m_flWait;

		g_view.SetCameraAngle(angles);
		g_view.SetClientAngle(angles);
	//}

	classname = "trigger_camera";
}
#endif

#ifdef SERVER
void
trigger_camera::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "target":
		m_strAimAt = ReadString(setValue);
		break;
	case "moveto":
		m_strMoveTo = ReadString(setValue);
		break;
	case "wait":
		m_flWait = ReadFloat(setValue);
		break;
	case "speed":
		m_flSpeed = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
trigger_camera::Respawn(void)
{
	super::Respawn();

	m_eLooker = world;
}

void
trigger_camera::Save(float handle)
{
	super::Save(handle);

	SaveFloat(handle, "m_flWait", m_flWait);
	SaveEntity(handle, "m_eLooker", m_eLooker);
	SaveString(handle, "m_strAimAt", m_strAimAt);
	SaveString(handle, "m_strMoveTo", m_strMoveTo);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
}

void
trigger_camera::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flWait":
		m_flWait = ReadFloat(setValue);
		break;
	case "m_eLooker":
		m_eLooker = ReadEntity(setValue);
		break;
	case "m_strAimAt":
		m_strAimAt = ReadString(setValue);
		break;
	case "m_strMoveTo":
		m_strMoveTo = ReadString(setValue);
		break;
	case "m_flSpeed":
		m_flInitialSpeed = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

float
trigger_camera::SendEntity(entity ePEnt, float flFlags)
{
	WriteByte(MSG_ENTITY, ENT_OLDCAMERA);
	WriteFloat(MSG_ENTITY, flFlags);

	//if (flFlags & OCAMFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	//}

	//if (flFlags & OCAMFL_CHANGED_ANGLES) {
		WriteFloat(MSG_ENTITY, angles[0]);
		WriteFloat(MSG_ENTITY, angles[1]);
		WriteFloat(MSG_ENTITY, angles[2]);
//	}

	//if (flFlags & OCAMFL_CHANGED_VIEWER) {
		WriteEntity(MSG_ENTITY, m_eLooker);
	//}

	//if (flFlags & OCAMFL_CHANGED_WAIT) {
		WriteFloat(MSG_ENTITY, m_flWait);
	//}

	return (1);
}

void
trigger_camera::EvaluateEntity(void)
{
	ncEntity aimingAt;

	if (!m_eLooker)
		return;

	aimingAt = (ncEntity)find(world, ::targetname, m_strAimAt);

	if (aimingAt) {
		TurnToPos(aimingAt.GetOrigin());
	} else {
		//ncEntity targetNode = (ncEntity)find(world, ::targetname, target);
		//TurnToPos(targetNode.GetOrigin());
	}

	if (ATTR_CHANGED(origin)) {
		SetSendFlags(OCAMFL_CHANGED_ORIGIN);
	}
	if (ATTR_CHANGED(angles)) {
		SetSendFlags(OCAMFL_CHANGED_ANGLES);
	}
	if (ATTR_CHANGED(m_eLooker)) {
		SetSendFlags(OCAMFL_CHANGED_VIEWER);
	}
	if (ATTR_CHANGED(m_flWait)) {
		SetSendFlags(OCAMFL_CHANGED_WAIT);
	}

	SAVE_STATE(origin)
	SAVE_STATE(angles)
	SAVE_STATE(m_eLooker)
	SAVE_STATE(m_flWait)
}

void
trigger_camera::GoToTarget(void)
{
	float travelTime;
	vector camVelocity;
	path_corner targetNode;

	targetNode = (path_corner)find(world, ::targetname, target);

	if (!targetNode) {
		EntError("Cannot find target %S", target);
		return;
	}

	camVelocity = (targetNode.GetOrigin() - GetOrigin());

	if (targetNode.DesiredTrainSpeed()) {
		m_flSpeed = targetNode.DesiredTrainSpeed();
	}

	travelTime = (vlen(camVelocity) / m_flSpeed);

	EntLog("Moving to path_corner %S at %d within %f secs (%v)", target, m_flSpeed, travelTime, camVelocity);

	if (!travelTime) {
		EntWarning("Distance too short, going to next.");
		NextPath();
		return;
	}

	if (!m_strAimAt) {
		vector vecAngleDiff = targetNode.GetOrigin() - GetOrigin();
		vector vecAngleDest = vectorToAngles(vecAngleDiff);
		vecAngleDiff = angleDifference(vecAngleDest, angles);
		SetAngularVelocity(vecAngleDiff * (1 / travelTime));
	}

	SetVelocity(camVelocity * (1 / travelTime));
	ScheduleThink(NextPath, travelTime);
}

void
trigger_camera::NextPath(void)
{
	path_corner nextNode;

	if (target == "") {
		return;
	}

	nextNode = (path_corner)find(world, ::targetname, target);

	if (!nextNode) {
		ncError("Node %S suddenly missing from map!", target);
		return;
	}

	EntLog("Arrived at target node %S.", target);

	/* fire the path_corners' target */
	nextNode.PathPassTrigger(this, TRIG_TOGGLE);

	if (target != m_strMoveTo)
		m_strAimAt = __NULL__;

	SetOrigin(nextNode.origin - (mins + maxs) * 0.5);
	SetTriggerTarget(nextNode.target);

	ClearVelocity();

	/* warp next frame */
	if (nextNode.HasSpawnFlags(PC_TELEPORT)) {
		EntLog("Node %S wants %S to teleport.", nextNode.targetname, targetname);
		ScheduleThink(NextPath, 0.0f);
		return;
	}

	/* stop until triggered again */
	if (nextNode.HasSpawnFlags(PC_WAIT)) {
		return;
	}

	if (nextNode.DesiredWaitTime() > 0) {
		ScheduleThink(GoToTarget, nextNode.DesiredWaitTime());
	} else {
		GoToTarget();
	}
}

/* TODO: Handle state? */
void
trigger_camera::Trigger(entity act, triggermode_t state)
{
	/* HACK: if we don't have a valid activator... pick the first player we can find */
	if (!(act.flags & FL_CLIENT)) {
		act = next.Player(world);
	}

	EntLog("Controlling camera of %S", act.netname);

	/* kill the other cams the player may be attached to */
	for (trigger_camera cam = __NULL__; (cam = (trigger_camera)find(cam, ::classname, "trigger_camera"));) {
		if (cam.m_eLooker == act) {
			cam.m_eLooker = __NULL__;
			cam.SetSendFlags(-1);
		}
	}

	if (act == m_eLooker) {
		DeactivateCamera();
		return;
	}

	m_eLooker = act;
	m_eLooker.view2 = this;
	m_flSpeed = m_flInitialSpeed;

	if (!m_flSpeed) {
		m_flSpeed = 100.0f;
	}

	/* Reset to the spawn values */
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_NOT);
	SetOrigin(GetSpawnVector("origin"));
	SetTriggerTarget(m_strMoveTo);
	NextPath();
	GoToTarget();
	SetSendFlags(0xFFFFFF);
	pvsflags = PVSF_IGNOREPVS;
}


void
trigger_camera::DeactivateCamera(void)
{
	EntLog("Turning it off on %S", m_eLooker.netname);
	m_eLooker.view2 = __NULL__;
	m_eLooker = __NULL__;
	SetSendFlags(-1);
}

void
trigger_camera::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
		break;
	case "Enable":
		DeactivateCamera();
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "Disable":
		DeactivateCamera();
		break;
	case "Toggle":
		#warning Toggle doesn't work
		break;
	case "SetTeam":
		SetTeam(stof(strData));
		break;
	default:
		super:: Input(eAct, strInput, strData);
	}
}
#endif
