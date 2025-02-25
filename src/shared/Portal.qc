/*
 * Copyright (c) 2024 Vera Visions LLC.
 * Copyright (c) 2014 David Walton
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

void
ncPortal::ncPortal(void)
{
	m_ePortalTarget = __NULL__;
	m_ePortalTarget_net = __NULL__;
	m_vecTargetPos = g_vec_null;
	m_vecTargetAngle = g_vec_null;
	m_vecPortalPos = g_vec_null;
	m_vecPortalN = g_vec_null;
	m_vecPortalS = g_vec_null;
	m_vecPortalT = g_vec_null;
	m_brushNum = -1;
	m_bEnabled = false;
	isPortal = true;
	m_vecTargetPos = g_vec_null;
	m_vecTargetN = g_vec_null;
	m_vecTargetS = g_vec_null;
	m_vecTargetT = g_vec_null;

#ifdef SERVER

	pvsflags = PVSF_NOREMOVE;
	frame1time = 0.0f;
	m_iPortalValue = -1;

	/* unique portal IDs */
	{
		float numPortals = 0;
		for (ncPortal e = __NULL__; (e = (ncPortal)findfloat(e, ::isPortal, true));) {
			e.portalnum = numPortals++;
		}
	}

	/* default fallback */
	precache.Model("models/b_portal.bsp");
	SetPortalModel("models/b_portal.bsp");
#endif
}

#ifdef SERVER
void
ncPortal::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "m_ePortalTarget", m_ePortalTarget);
	SaveVector(handle, "m_vecTargetPos", m_vecTargetPos);
	SaveVector(handle, "m_vecTargetAngle", m_vecTargetAngle);
	SaveVector(handle, "m_vecPortalPos", m_vecPortalPos);
	SaveVector(handle, "m_vecPortalN", m_vecPortalN);
	SaveVector(handle, "m_vecPortalS", m_vecPortalS);
	SaveVector(handle, "m_vecPortalT", m_vecPortalT);
	SaveInt(handle, "m_iPortalValue", m_iPortalValue);
}

void
ncPortal::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_ePortalTarget":
		m_ePortalTarget = (ncPortal)ReadEntity(strValue);
		break;
	case "m_vecTargetPos":
		m_vecTargetPos = ReadVector(strValue);
		break;
	case "m_vecTargetAngle":
		m_vecTargetAngle = ReadVector(strValue);
		break;
	case "m_vecPortalPos":
		m_vecPortalPos = ReadVector(strValue);
		break;
	case "m_vecPortalN":
		m_vecPortalN = ReadVector(strValue);
		break;
	case "m_vecPortalS":
		m_vecPortalS = ReadVector(strValue);
		break;
	case "m_vecPortalT":
		m_vecPortalT = ReadVector(strValue);
		break;
	case "m_iPortalValue":
		m_iPortalValue = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

void
ncPortal::PortalAutoLink(bool openPortal)
{
	/* this just links against the youngest portal of the same ID at this time */
	ncPortal youngestPortal, oldestPortal;
	oldestPortal = youngestPortal = __NULL__;
	float youngestTime = 99999.0f;
	float oldestTime = 0.0f;

	/* delete any portal with the same id */
	for (ncPortal e = __NULL__; (e = (ncPortal)findfloat(e, ::isPortal, true));) {
		if (e == this)
			continue;

		/* find first AND last portal */
		if (e.m_iPortalValue == m_iPortalValue) {
			if (oldestTime < e.frame1time) {
				oldestTime = e.frame1time;
				oldestPortal = e;
			}
			if (youngestTime > e.frame1time) {
				youngestTime = e.frame1time;
				youngestPortal = e;
			}
		}
	}

	/* remove the first portal from the world */
	if (youngestPortal != oldestPortal) {
		oldestPortal.PortalClose();
	}

	PortalLinkTo(youngestPortal, openPortal);
}

void
ncPortal::PortalClose(void)
{
	/* invalidate the other portal's reference to this one, only
	   if we're still actively linked. */
	if (m_ePortalTarget && m_ePortalTarget.m_ePortalTarget == this) {
		m_ePortalTarget.m_bEnabled = false;
		m_ePortalTarget.m_ePortalTarget = __NULL__;
		m_ePortalTarget._PortalUpdated();
	}

	/* now kill our own reference */
	m_ePortalTarget = __NULL__;
	m_bEnabled = false;
	_PortalUpdated();
}

bool
ncPortal::PortalLinkTo(ncPortal target, bool openPortal)
{
	m_ePortalTarget = target;

	m_bEnabled = openPortal;

	SendFlags = -1;
	_PortalUpdated();

	if (m_ePortalTarget)
 {
		m_ePortalTarget.m_ePortalTarget = this;
		m_ePortalTarget.m_bEnabled = openPortal;
		m_ePortalTarget.SendFlags = -1;
		m_ePortalTarget._PortalUpdated();
	}

	return target ? true : false;
}

void
ncPortal::SetPortalID(int value)
{
	m_iPortalValue = value;
}

void
ncPortal::SetPortalModel(string modelPath)
{
	m_flPortalModel = getmodelindex(modelPath);
}

void
ncPortal::PortalWasOpened(void)
{
}

void
ncPortal::PortalWasClosed(void)
{
}
#endif

void
ncPortal::_PortalUpdated(void)
{
	/* the displayed surface must be in a known position.
	we're not going to compensate for the model here, because I'm too lazy.
 */
	vector newAngles = angles;
	//newAngles[0] * -1;
	makevectors(newAngles);

	m_vecPortalN = v_forward;
	m_vecPortalS = -v_right;
	m_vecPortalT = v_up;
	m_vecPortalPos = origin;

	/* expand the size of the object along the plane, and set up a portal region.
 */
	movetype = MOVETYPE_NONE;

	if (m_bEnabled == true) {
		solid = SOLID_PORTAL;
		setmodel(this, modelnameforindex(m_flPortalModel));
		if (m_bWasEnabled == false) {
			m_bWasEnabled = true;
#ifdef SERVER
			PortalWasOpened();
#endif
#ifdef CLIENT
			m_flSize = 0.0f;
#endif
		}
	} else {
		if (m_bWasEnabled == true) {
			m_bWasEnabled = false;
#ifdef SERVER
			PortalWasClosed();
#endif
		}
		solid = SOLID_NOT;
		//modelindex = 0;
	}

	/* determine size of major axis
 */
	float portalSize = max(size[0], size[1], size[2]);
	impulse = portalSize;	/* let the engine know how wide the portal should be
 */
		
	/* make sure the abs size contains the entire portal.
 */
	portalSize = sqrt(portalSize * portalSize * 2);
	mins -= portalSize * [1, 1, 1];
	maxs += portalSize * [1, 1, 1];
	setsize(this, mins, maxs);
	geomtype = GEOMTYPE_NONE;
}

vector
ncPortal::_DirectionTransform(vector v)
{
	/* FIXME: this should include .angles stuff
 */
	vector tmp, r;
	tmp[0] = v * m_vecPortalN;
	tmp[1] = v * m_vecPortalS;
	tmp[2] = v * m_vecPortalT;

	r = [0, 0, 0];

	if (!m_ePortalTarget) {
		r += tmp[2] * m_vecTargetT;
		r -= tmp[1] * m_vecTargetS;
		r -= tmp[0] * m_vecTargetN;
	} else {
		r += tmp[2] * m_ePortalTarget.m_vecPortalT;
		r -= tmp[1] * m_ePortalTarget.m_vecPortalS;
		r -= tmp[0] * m_ePortalTarget.m_vecPortalN;
	}

	return r;
}

vector
ncPortal::_OriginTransform(vector p)
{
	if (!m_ePortalTarget) {
		return m_vecPortalPos - _DirectionTransform(m_vecPortalPos - p);
	}

	return m_ePortalTarget.m_vecPortalPos - _DirectionTransform(m_vecPortalPos - p);
}

// need to generate forward/right/up vectors
// return value is the new view origin.
// trace_end_pos needs to contain the pvs origin.
vector
ncPortal::camera_transform(vector originalOrg, vector originalAngles)
{
	vector newCameraPos;

	newCameraPos = _OriginTransform(originalOrg);
	v_forward = _DirectionTransform(v_forward);
	v_right = _DirectionTransform(v_right);
	v_up = _DirectionTransform(v_up);

	//trace from the center of the target to the view, to set trace_endpos for the pvs origin
	if (m_ePortalTarget)
		traceline(m_ePortalTarget.m_vecPortalPos, newCameraPos, MOVE_NOMONSTERS, this);
	else
		trace_endpos = this.m_vecPortalPos;

	return newCameraPos;
}

/* because when using custom player physics, the engine will not do us any favors
   we have to do the portal transformation manually. DO NOT USE THIS METHOD YOURSELF
	unless you really know what you're doing. This is a private method! */
void
ncPortal::TransportEntity(ncEntity target)
{
	static void getMatrixDiff(vector aX, vector aY, vector aZ, vector bX, vector bY, vector bZ) {
		v_forward.x = aX.x * bX.x + aY.x * bX.y + aZ.x * bX.z;
		v_forward.y = aX.y * bX.x + aY.y * bX.y + aZ.y * bX.z;
		v_forward.z = aX.z * bX.x + aY.z * bX.y + aZ.z * bX.z;

		v_right.x = aX.x * bY.x + aY.x * bY.y + aZ.x * bY.z;
		v_right.y = aX.y * bY.x + aY.y * bY.y + aZ.y * bY.z;
		v_right.z = aX.z * bY.x + aY.z * bY.y + aZ.z * bY.z;

		v_up.x = aX.x * bZ.x + aY.x * bZ.y + aZ.x * bZ.z;
		v_up.y = aX.y * bZ.x + aY.y * bZ.y + aZ.y * bZ.z;
		v_up.z = aX.z * bZ.x + aY.z * bZ.y + aZ.z * bZ.z;
	}

	vector offsetPos;
	vector portalAngleX, portalAngleY, portalAngleZ;
	vector exitAngleX, exitAngleY, exitAngleZ;
	vector playerDelta;
	vector targetAngleX, targetAngleY, targetAngleZ;
	vector playerVelX, playerVelY, playerVelZ;
	vector angleDiff;
	float totalSpeed;

	/* angle matrix of the portal entry */
	makevectors(GetAngles());
	portalAngleX = v_forward * -1;
	portalAngleY = v_right * -1;
	portalAngleZ = v_up;

	/* matrix of target entity angles */
	if (target.flags & FL_CLIENT) {
		makevectors(input_angles);
	} else {
		makevectors(target.GetAngles());
	}
	targetAngleX = v_forward;
	targetAngleY = v_right;
	targetAngleZ = v_up;

	/* angle matrix of portal exit */
	makevectors(m_ePortalTarget.GetAngles());
	exitAngleX = v_forward;
	exitAngleY = v_right;
	exitAngleZ = v_up;

	/* ! CALCULATE THE NEW POSITION - START ! */
	/* get the offset */
	offsetPos = target.GetOrigin() - GetOrigin();

	/* calculate the delta of player pos to portal using said angle matrix */
	playerDelta[0] = dotproduct(offsetPos, portalAngleX);
	playerDelta[1] = dotproduct(offsetPos, portalAngleY);
	playerDelta[2] = dotproduct(offsetPos, portalAngleZ);

	/* now, translate the offset to the exit angle */
	offsetPos = m_ePortalTarget.GetOrigin();
	offsetPos += exitAngleX * playerDelta[0];
	offsetPos += exitAngleY * playerDelta[1];
	offsetPos += exitAngleZ * playerDelta[2];
	target.SetOrigin(offsetPos); /* apply the new position */

	/* ! CALCULATE THE NEW ANGLE - START ! */
	/* get the difference between the two rotational matrices */
	getMatrixDiff(portalAngleX, portalAngleY, portalAngleZ * -1, targetAngleX, targetAngleY, targetAngleZ);
	angleDiff = vectoangles(v_forward, -v_up); /* we now have an euler angle */

	/* apply the new angles */
	if (target.flags & FL_CLIENT) {
		input_angles = m_ePortalTarget.GetAngles() - angleDiff;
		target.v_angle = input_angles;
		//Client_FixAngle(this, target.v_angle);
	} else {
		target.angles = m_ePortalTarget.GetAngles() - angleDiff;
	}

	/* ! CALCULATE DESTINATION VELOCITY - START ! */
	/* let's get the current speed first */
	totalSpeed = vlen(target.GetVelocity());
	/* convert target velocity into a direction matrix */
	makevectors(vectoangles(target.GetVelocity()));
	playerVelX = v_forward;
	playerVelY = v_right;
	playerVelZ = v_up;
	getMatrixDiff(portalAngleX, portalAngleY, portalAngleZ, playerVelX, playerVelY, playerVelZ);
	angleDiff = vectoangles(v_forward, v_up); /* we now have an euler angle again */
	/* get the new movement direction relative to the exit portal */
	makevectors(m_ePortalTarget.GetAngles() + angleDiff);
	/* apply the final velocity */
	target.SetVelocity(v_forward * totalSpeed);
}

#ifdef SERVER
void
ncPortal::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, PORTALFL_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, PORTALFL_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, PORTALFL_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, PORTALFL_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, PORTALFL_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, PORTALFL_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(m_ePortalTarget, PORTALFL_CHANGED_TARG_ENTITY)
	EVALUATE_VECTOR(m_vecTargetPos, 0, PORTALFL_CHANGED_TARG_ORIGIN_X)
	EVALUATE_VECTOR(m_vecTargetPos, 1, PORTALFL_CHANGED_TARG_ORIGIN_Y)
	EVALUATE_VECTOR(m_vecTargetPos, 2, PORTALFL_CHANGED_TARG_ORIGIN_Z)
	EVALUATE_VECTOR(m_vecTargetAngle, 0, PORTALFL_CHANGED_TARG_ANGLES_X)
	EVALUATE_VECTOR(m_vecTargetAngle, 1, PORTALFL_CHANGED_TARG_ANGLES_Y)
	EVALUATE_VECTOR(m_vecTargetAngle, 2, PORTALFL_CHANGED_TARG_ANGLES_Z)
	EVALUATE_FIELD(m_bEnabled, PORTALFL_CHANGED_ENABLED)
	EVALUATE_FIELD(m_flPortalModel, PORTALFL_CHANGED_MODELINDEX)
}

float
ncPortal::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_PORTAL);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], PORTALFL_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], PORTALFL_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], PORTALFL_CHANGED_ORIGIN_Z)
	SENDENTITY_FLOAT(angles[0], PORTALFL_CHANGED_ANGLES_X)
	SENDENTITY_FLOAT(angles[1], PORTALFL_CHANGED_ANGLES_Y)
	SENDENTITY_FLOAT(angles[2], PORTALFL_CHANGED_ANGLES_Z)
	SENDENTITY_ENTITY(m_ePortalTarget, PORTALFL_CHANGED_TARG_ENTITY)

	if (1) {
		SENDENTITY_COORD(m_vecTargetPos[0], PORTALFL_CHANGED_TARG_ORIGIN_X)
		SENDENTITY_COORD(m_vecTargetPos[1], PORTALFL_CHANGED_TARG_ORIGIN_Y)
		SENDENTITY_COORD(m_vecTargetPos[2], PORTALFL_CHANGED_TARG_ORIGIN_Z)
		SENDENTITY_FLOAT(m_vecTargetAngle[0], PORTALFL_CHANGED_TARG_ANGLES_X)
		SENDENTITY_FLOAT(m_vecTargetAngle[1], PORTALFL_CHANGED_TARG_ANGLES_Y)
		SENDENTITY_FLOAT(m_vecTargetAngle[2], PORTALFL_CHANGED_TARG_ANGLES_Z)
	}

	SENDENTITY_BYTE(m_bEnabled, PORTALFL_CHANGED_ENABLED)
	SENDENTITY_FLOAT(m_flPortalModel, PORTALFL_CHANGED_MODELINDEX)

	return (true);
}
#endif

#ifdef CLIENT
void
ncPortal::ReceiveEntity(float flNew, float flChanged)
{
	if (m_ePortalTarget) {
		m_ePortalTarget.m_ePortalTarget = __NULL__;
		m_ePortalTarget = __NULL__;
	}

	READENTITY_COORD(origin[0], PORTALFL_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], PORTALFL_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], PORTALFL_CHANGED_ORIGIN_Z)
	READENTITY_FLOAT(angles[0], PORTALFL_CHANGED_ANGLES_X)
	READENTITY_FLOAT(angles[1], PORTALFL_CHANGED_ANGLES_Y)
	READENTITY_FLOAT(angles[2], PORTALFL_CHANGED_ANGLES_Z)
	READENTITY_PORTAL(m_ePortalTarget, PORTALFL_CHANGED_TARG_ENTITY)

		READENTITY_COORD(m_vecTargetPos[0], PORTALFL_CHANGED_TARG_ORIGIN_X)
		READENTITY_COORD(m_vecTargetPos[1], PORTALFL_CHANGED_TARG_ORIGIN_Y)
		READENTITY_COORD(m_vecTargetPos[2], PORTALFL_CHANGED_TARG_ORIGIN_Z)
		READENTITY_FLOAT(m_vecTargetAngle[0], PORTALFL_CHANGED_TARG_ANGLES_X)
		READENTITY_FLOAT(m_vecTargetAngle[1], PORTALFL_CHANGED_TARG_ANGLES_Y)
		READENTITY_FLOAT(m_vecTargetAngle[2], PORTALFL_CHANGED_TARG_ANGLES_Z)

	READENTITY_BYTE(m_bEnabled, PORTALFL_CHANGED_ENABLED)
	READENTITY_FLOAT(m_flPortalModel, PORTALFL_CHANGED_MODELINDEX)

	if (m_ePortalTarget) {
		if (m_ePortalTarget.m_ePortalTarget)
			m_ePortalTarget.m_ePortalTarget.m_ePortalTarget = __NULL__;

		m_ePortalTarget. m_ePortalTarget = this;
	} else {
		makevectors(angles);
		m_vecTargetPos = origin;
		m_vecTargetN = v_forward;
		m_vecTargetS = v_right;
		m_vecTargetT = v_up;
	}

	_PortalUpdated();
	drawmask = MASK_ENGINE;
//	predraw = 0;
}

float
ncPortal::predraw(void)
{
	scale = m_flSize;

	addentity(this);

	m_flSize += frametime * 10.0f;

	if (m_flSize > 1.0)
		m_flSize = 1.0f;

	return PREDRAW_NEXT;
}
#endif
