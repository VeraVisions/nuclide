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

/*QUAKED trigger_camera (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"target"        Camera aims at this target.
"moveto"        First path_corner entity, if present.

Trivia:
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	OCAMFL_CHANGED_ORIGIN,
	OCAMFL_CHANGED_ANGLES,
	OCAMFL_CHANGED_WAIT
};

#ifdef CLIENT
class trigger_camera
#else
class trigger_camera:CBaseTrigger
#endif
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
	virtual void(float) ReceiveEntity;
#else
	virtual void(void) NextPath;
	virtual void(void) GoToTarget;
	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
	virtual float(entity, float) SendEntity;
	virtual void(void) ParentUpdate;
#endif
};

#ifdef CLIENT
void
trigger_camera::ReceiveEntity(float flFlags)
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
trigger_camera::SendEntity(entity ePEnt, float flFlags)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return FALSE;

	if (ePEnt != m_eLooker)
		return FALSE;

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

	return TRUE;
}

void
trigger_camera::ParentUpdate(void)
{
	entity t = find(world, ::targetname, m_strAimAt);
	if (t) {
		angles = vectoangles(t.origin - origin);
	}

	if (net_origin != origin) {
		net_origin = origin;
		SendFlags |= OCAMFL_CHANGED_ORIGIN;
	}
	if (net_angles != angles) {
		net_angles = angles;
		SendFlags |= OCAMFL_CHANGED_ANGLES;
	}

	/* camera don't support parenting when we're following paths! */
	if (m_parent && !m_strMoveTo) {
		entity p = find(world, ::targetname, m_parent);

		if (p)
			SetOrigin(p.origin);
	}
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

	SetOrigin(m_oldOrigin);
	velocity = [0,0,0];
	think = __NULL__;
	nextthink = 0.0f;
	target = m_strMoveTo;
	NextPath();
	GoToTarget();
	SendFlags |= OCAMFL_CHANGED_ORIGIN | OCAMFL_CHANGED_ANGLES | OCAMFL_CHANGED_WAIT;
}

void
trigger_camera::Respawn(void)
{
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
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
		CBaseTrigger::SpawnKey(strKey, strValue);
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
	CBaseTrigger::CBaseTrigger();
#endif
}
