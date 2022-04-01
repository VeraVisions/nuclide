/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED trigger_camera (1 0 0) (-8 -8 -8) (8 8 8)
Forces a camera change when triggered.

-------- KEYS --------
"targetname" : Name
"target" : Camera aims at this target.
"moveto" : First path_corner entity, if present.
"wait" : The total time the camera effect is active.

-------- NOTES --------
The client who triggers it will get its camera perspective changed to this
trigger_camera. It is capable of following a track in case "moveto" is set.
The movement finishes independently of the "wait" key.
In case you are follow a path, the triggers of the respective path_corners will
be respected.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	OCAMFL_CHANGED_ORIGIN,
	OCAMFL_CHANGED_ANGLES,
	OCAMFL_CHANGED_WAIT
};

class trigger_camera:NSPointTrigger
{
#ifdef CLIENT
#else
	float m_flWait;
	string m_strAimAt;
	string m_strMoveTo;
	entity m_eLooker;
#endif

	void(void) trigger_camera;

#ifdef CLIENT
	virtual void(float,float) ReceiveEntity;
#else
	virtual void(void) NextPath;
	virtual void(void) GoToTarget;
	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
	virtual float(entity, vector) SendEntity;
	virtual void(void) EvaluateEntity;
#endif
};

#ifdef CLIENT
void
trigger_camera::ReceiveEntity(float flNew, float flFlags)
{
	if (flFlags & OCAMFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setorigin(this, origin);
	}

	if (flFlags & OCAMFL_CHANGED_ANGLES) {
		angles[0] = readfloat();
		angles[1] = readfloat();
		angles[2] = readfloat();
	}

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	pSeat->m_vecCameraOrigin = origin;
	pSeat->m_vecCameraAngle = angles;

	if (flFlags & OCAMFL_CHANGED_WAIT) {
		float flWait = readfloat();

		if (flWait == -1)
			pSeat->m_flCameraTime = -1;
		else
			pSeat->m_flCameraTime = time + flWait;

		setproperty(VF_CL_VIEWANGLES, angles);
		setproperty(VF_ANGLES, angles);
	}

	classname = "trigger_camera";
}
#else
float
trigger_camera::SendEntity(entity ePEnt, vector vecChangedBits)
{
	float flFlags = vecChangedBits[2];

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	if (ePEnt != m_eLooker)
		return (0);

	WriteByte(MSG_ENTITY, ENT_OLDCAMERA);
	WriteFloat(MSG_ENTITY, flFlags);

	if (flFlags & OCAMFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (flFlags & OCAMFL_CHANGED_ANGLES) {
		WriteFloat(MSG_ENTITY, angles[0]);
		WriteFloat(MSG_ENTITY, angles[1]);
		WriteFloat(MSG_ENTITY, angles[2]);
	}

	if (flFlags & OCAMFL_CHANGED_WAIT) {
		WriteFloat(MSG_ENTITY, m_flWait);
	}

	return (1);
}

void
trigger_camera::EvaluateEntity(void)
{
	entity t = find(world, ::targetname, m_strAimAt);
	if (t) {
		angles = vectoangles(t.origin - origin);
	}

	if (ATTR_CHANGED(origin)) {
		SetSendFlags(OCAMFL_CHANGED_ORIGIN);
	}
	if (ATTR_CHANGED(angles)) {
		SetSendFlags(OCAMFL_CHANGED_ANGLES);
	}

	SAVE_STATE(origin);
	SAVE_STATE(angles);
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

	if (!flTravelTime) {
		print("^1trigger_camera::^3GoToTarget^7: Distance short, going next\n");
		think = NextPath;

		/* because ltime may be 0 */
		if (!ltime)
			nextthink = ltime + 0.001f;
		else
			nextthink = ltime;

		return;
	}

	velocity = (vecVelocity * (1 / flTravelTime));
	think = NextPath;
	nextthink = (ltime + flTravelTime);
}

void
trigger_camera::NextPath(void)
{
	path_corner eNode;
	eNode = (path_corner)find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	/* fire the path_corners' target */
	eNode.Trigger(this, TRIG_TOGGLE);

	SetOrigin(eNode.origin - (mins + maxs) * 0.5);

	target = eNode.target;
	velocity = [0,0,0];

	/* warp next frame */
	if (eNode.spawnflags & PC_TELEPORT) {
		print(sprintf("^1trigger_camera::^3NextPath^7: Node %s wants %s to teleport\n", eNode.targetname, targetname));
		think = NextPath;
		nextthink = ltime;
		return;
	}

	/* stop until triggered again */
	if (eNode.spawnflags & PC_WAIT) {
		return;
	}

	if (eNode.m_flWait > 0) {
		think = GoToTarget;
		nextthink = ltime + eNode.m_flWait;
	} else {
		GoToTarget();
	}
}

/* TODO: Handle state? */
void
trigger_camera::Trigger(entity act, int state)
{
	m_eLooker = act;

	SetOrigin(GetSpawnOrigin());
	velocity = [0,0,0];
	think = __NULL__;
	nextthink = 0.0f;
	target = m_strMoveTo;
	NextPath();
	GoToTarget();
	SetSendFlags(OCAMFL_CHANGED_ORIGIN | OCAMFL_CHANGED_ANGLES | OCAMFL_CHANGED_WAIT);
}

void
trigger_camera::Respawn(void)
{
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
}

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
#endif

void
trigger_camera::trigger_camera(void)
{
#ifdef CLIENT
	drawmask = MASK_ENGINE;
#else
	m_flWait = 4.0f;
	super::NSPointTrigger();
#endif
}
