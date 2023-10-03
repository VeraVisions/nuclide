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
*/
class trigger_camera:NSPointTrigger
{
public:
	void trigger_camera(void);

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
#else
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void NextPath(void);
	virtual void GoToTarget(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual float SendEntity(entity,float);
	virtual void EvaluateEntity(void);
#endif

private:
	NETWORKED_FLOAT(m_flWait)
	entity m_eLooker;
#ifdef SERVER
	string m_strAimAt;
	string m_strMoveTo;
	entity m_eLooker_net;
	float m_flSpeed;
#endif
};

void
trigger_camera::trigger_camera(void)
{
	m_flWait = 4.0f;
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

	//if (flFlags & OCAMFL_CHANGED_VIEWER) {
		m_eLooker = findfloat(world, ::entnum, readentitynum());
	//}

	//if (flFlags & OCAMFL_CHANGED_WAIT) {
		m_flWait = readfloat();
	//}

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];

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
		//error(sprintf("Wait! %f %f\n", time, pSeat->m_flCameraTime));
	//}

	classname = "trigger_camera";
}
#else
void
trigger_camera::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "target":
		m_strAimAt = strValue;
		break;
	case "moveto":
		m_strMoveTo = strValue;
		break;
	case "wait":
		m_flWait = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_camera::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
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
trigger_camera::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flWait":
		m_flWait = ReadFloat(strValue);
		break;
	case "m_eLooker":
		m_eLooker = ReadEntity(strValue);
		break;
	case "m_strAimAt":
		m_strAimAt = ReadString(strValue);
		break;
	case "m_strMoveTo":
		m_strMoveTo = ReadString(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
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
	entity t;

	if (!m_eLooker)
		return;

	t = find(world, ::targetname, m_strAimAt);

	if (t) {
		angles = vectoangles(t.origin - origin);
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
	float flTravelTime;
	vector vecVelocity;

	path_corner eNode;
	eNode = (path_corner)find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	vecVelocity = (eNode.origin - origin);
	flTravelTime = (vlen(vecVelocity) / eNode.m_flSpeed);

	NSLog("trigger_camera (%s): Moving to path_corner %S within %f secs", targetname, target, flTravelTime);

	if (!flTravelTime) {
		NSEntWarning("distance too short, going to next");
		NextPath();
		return;
	}

	SetVelocity(vecVelocity * (1 / flTravelTime));
	ScheduleThink(NextPath, flTravelTime);
}

void
trigger_camera::NextPath(void)
{
	path_corner eNode;

	if (target == "") {
		return;
	}

	print(sprintf("Looking for target %S\n", target));
	eNode = (path_corner)find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	NSLog("trigger_camera (%s): Touched base with path_corner %S", targetname, target);

	/* fire the path_corners' target */
	eNode.Trigger(this, TRIG_TOGGLE);

	SetOrigin(eNode.origin - (mins + maxs) * 0.5);
	SetTriggerTarget(eNode.target);
	ClearVelocity();

	/* warp next frame */
	if (eNode.HasSpawnFlags(PC_TELEPORT)) {
		NSLog("^1trigger_camera::^3NextPath^7: Node %s wants %s to teleport\n", eNode.targetname, targetname);
		ScheduleThink(NextPath, 0.0f);
		return;
	}

	/* stop until triggered again */
	if (eNode.HasSpawnFlags(PC_WAIT)) {
		return;
	}

	if (eNode.m_flWait > 0) {
		ScheduleThink(GoToTarget, eNode.m_flWait);
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
		act = find(world, ::classname, "player");
	}

	NSLog("trigger_camera for %s %S is now %S\n", act.classname, act.netname, targetname);

	/* kill the other cams the player may be attached to */
	for (trigger_camera cam = __NULL__; (cam = (trigger_camera)find(cam, ::classname, "trigger_camera"));) {
		if (cam.m_eLooker == act) {
			cam.m_eLooker = __NULL__;
			cam.SetSendFlags(-1);
		}
	}

	m_eLooker = act;
	m_eLooker.view2 = this;
	NSLog("Triggering it on %s\n", act.netname);
	SetOrigin(GetSpawnOrigin());
	ClearVelocity();
	ReleaseThink();
	SetTriggerTarget(m_strMoveTo);
	NextPath();
	GoToTarget();
	SetSendFlags(0xFFFFFF);
	pvsflags = PVSF_IGNOREPVS;
}
#endif
