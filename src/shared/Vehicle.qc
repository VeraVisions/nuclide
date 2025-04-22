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

void
ncVehicle::ncVehicle(void)
{
	m_iVehicleFlags = 0i;
	m_iMoveButtons = 0i;
	m_vecMoveValues = [0.0f, 0.0f, 0.0f];
	m_eDriver = __NULL__;
	m_eDriverLast = __NULL__;
	m_vecPlayerPos = [0.0f, 0.0f, 0.0f];
	m_vecExitPos = [0.0f, 0.0f, 0.0f];
}

#ifdef SERVER
void
ncVehicle::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iVehicleFlags", m_iVehicleFlags);
	SaveInt(handle, "m_iMoveButtons", m_iMoveButtons);
	SaveVector(handle, "m_vecMoveValues",  m_vecMoveValues);
	SaveEntity(handle, "m_eDriver", m_eDriver);
	SaveEntity(handle, "m_eDriverLast", m_eDriverLast);
	SaveVector(handle, "m_vecPlayerPos",  m_vecPlayerPos);
	SaveVector(handle, "m_vecExitPos",  m_vecExitPos);
}

void
ncVehicle::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_iVehicleFlags":
		m_iVehicleFlags = ReadInt(setValue);
		break;
	case "m_iMoveButtons":
		m_iMoveButtons = ReadInt(setValue);
		break;
	case "m_vecMoveValues":
		m_vecMoveValues = ReadVector(setValue);
		break;
	case "m_eDriver":
		m_eDriver = (ncEntity)ReadEntity(setValue);
		break;
	case "m_eDriverLast":
		m_eDriverLast = (ncEntity)ReadEntity(setValue);
		break;
	case "m_vecPlayerPos":
		m_vecPlayerPos = ReadVector(setValue);
		break;
	case "m_vecExitPos":
		m_vecExitPos = ReadVector(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}
#endif

bool
ncVehicle::CanDriverCrouch(void)
{
	return (false);
}

bool
ncVehicle::PreventPlayerMovement(void)
{
	return (true);
}

bool
ncVehicle::PreventPlayerFire(void)
{
	return (true);
}

float
ncVehicle::DriverAnimation(void)
{
	return (-1);
}

entity
ncVehicle::GetDriver(void)
{
	return (m_eDriver);
}

#ifdef CLIENT
bool
ncVehicle::HideViewWeapon(void)
{
	return (false);
}
bool
ncVehicle::HideCrosshair(void)
{
	return (true);
}
bool
ncVehicle::HidePlayermodel(void)
{
	return (true);
}

void
ncVehicle::DriverRelink(void)
{
	if (!driver_entnum)
		m_eDriver = __NULL__;
	else {
		ncPlayer pl;
		m_eDriver = (ncEntity)findentity(world, ::entnum, driver_entnum);
		pl = (ncPlayer)m_eDriver;
		pl.vehicle = this;
	}
}
bool
ncVehicle::IsLocalDriver(void)
{
	DriverRelink();

	if (m_eDriver == pSeat->m_ePlayer)
		return (true);
	else
		return (false);
}

void
ncVehicle::UpdateView(void)
{
}

void
ncVehicle::PredictPreFrame(void)
{
	SAVE_STATE(angles)
	SAVE_STATE(origin)
	SAVE_STATE(velocity)
	SAVE_STATE(size)
	SAVE_STATE(modelindex)
	SAVE_STATE(solid)
	SAVE_STATE(movetype)
	SAVE_STATE(m_eDriver)
}

void
ncVehicle::PredictPostFrame(void)
{
	ROLL_BACK(angles)
	ROLL_BACK(origin)
	ROLL_BACK(velocity)
	ROLL_BACK(size)
	ROLL_BACK(modelindex)
	ROLL_BACK(solid)
	ROLL_BACK(movetype)
	ROLL_BACK(m_eDriver)
}

void
ncVehicle::ReceiveEntity(float new, float fChanged)
{
	if (fChanged & VEHFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}

	if (fChanged & VEHFL_CHANGED_ANGLES) {
		angles[0] = readshort() / (32767 / 360);
		angles[1] = readshort() / (32767 / 360);
		angles[2] = readshort() / (32767 / 360);
	}

	if (fChanged & VEHFL_CHANGED_MODELINDEX) {
		setmodelindex(this, readshort());
	}

	if (fChanged & VEHFL_CHANGED_SOLID) {
		solid = readbyte();
	}

	if (fChanged & VEHFL_CHANGED_MOVETYPE) {
		movetype = readbyte();
	}

	if (fChanged & VEHFL_CHANGED_SIZE) {
		mins[0] = readcoord();
		mins[1] = readcoord();
		mins[2] = readcoord();
		maxs[0] = readcoord();
		maxs[1] = readcoord();
		maxs[2] = readcoord();
	}

	if (fChanged & VEHFL_CHANGED_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

	if (fChanged & VEHFL_CHANGED_DRIVER) {
		m_eDriver = (ncEntity)findfloat(world, ::entnum, readentitynum());
	}

	if (new)
		drawmask = MASK_ENGINE;
}
#else
vector
ncVehicle::GetExitPos(void)
{
	vector vecOut;
	makevectors(angles);
	vecOut = origin;
	vecOut += v_forward * m_vecExitPos[0];
	vecOut += v_right * m_vecExitPos[1];
	vecOut += v_up * m_vecExitPos[2];

	/* check if we get stuck inside a wall */
	tracebox(vecOut, VEC_HULL_MIN, VEC_HULL_MAX, vecOut, MOVE_NORMAL, this);

	/* we're inside a wall... */
	if (trace_startsolid) {
		float test_distance = 256.0f;
		float start_distance = 128.0f;
		vector test;
		vector startpos = origin + [0,0,48];

		/* see how far we have to go in each dir */
		makevectors(angles);

		/* let's try left /right */
		for (float i = 128; i < test_distance; i += 16) {
			test = startpos + (v_right * i);
			tracebox(startpos, VEC_HULL_MIN, VEC_HULL_MAX, test, MOVE_NOMONSTERS, m_eDriverLast);

			if (!trace_startsolid)
				return trace_endpos;
		}
		for (float i = 128; i < test_distance; i += 16) {
			test = startpos - (v_right * i);
			tracebox(startpos, VEC_HULL_MIN, VEC_HULL_MAX, test, MOVE_NOMONSTERS, m_eDriverLast);

			if (!trace_startsolid)
				return trace_endpos;
		}

		/* forward / back */
		for (float i = 164; i < test_distance; i += 16) {
			test = startpos + (v_forward * i);
			tracebox(startpos, VEC_HULL_MIN, VEC_HULL_MAX, test, MOVE_NOMONSTERS, m_eDriverLast);

			if (!trace_startsolid)
				return trace_endpos;
		}
		for (float i = 164; i < test_distance; i += 16) {
			test = startpos + (v_forward * -i);
			tracebox(startpos, VEC_HULL_MIN, VEC_HULL_MAX, test, MOVE_NOMONSTERS, m_eDriverLast);

			if (!trace_startsolid)
				return trace_endpos;
		}

		/* up */
		for (float i = 128; i < test_distance; i += 16) {
			test = startpos + (v_up * i);
			tracebox(startpos, VEC_HULL_MIN, VEC_HULL_MAX, test, MOVE_NOMONSTERS, m_eDriverLast);

			if (!trace_startsolid)
				return trace_endpos;
		}

		print("Warning: vehicle exit position is not OK.\n");
		return origin;
	} else {
		return vecOut;
	}
}

void
ncVehicle::EvaluateEntity(void)
{
	/* while the engine is still handling physics for these, we can't
	 * predict when origin/angle might change */
	if (ATTR_CHANGED(origin))
		SetSendFlags(VEHFL_CHANGED_ORIGIN);

	if (ATTR_CHANGED(angles)) {
		SetSendFlags(VEHFL_CHANGED_ANGLES);
	}
	if (ATTR_CHANGED(velocity))
		SetSendFlags(VEHFL_CHANGED_VELOCITY);

	if (ATTR_CHANGED(modelindex))
		SetSendFlags(VEHFL_CHANGED_MODELINDEX);

	if (ATTR_CHANGED(solid))
		SetSendFlags(VEHFL_CHANGED_SOLID);

	if (ATTR_CHANGED(movetype))
		SetSendFlags(VEHFL_CHANGED_MOVETYPE);

	if (ATTR_CHANGED(size))
		SetSendFlags(VEHFL_CHANGED_SIZE);

	if (ATTR_CHANGED(m_eDriver))
		SetSendFlags(VEHFL_CHANGED_DRIVER);

	SAVE_STATE(origin)
	SAVE_STATE(angles)
	SAVE_STATE(velocity)
	SAVE_STATE(modelindex)
	SAVE_STATE(solid)
	SAVE_STATE(movetype)
	SAVE_STATE(size)
	SAVE_STATE(m_eDriver)
}

float
ncVehicle::SendEntity(entity ePEnt, float fChanged)
{
	WriteByte(MSG_ENTITY, ENT_VEHICLE);
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & VEHFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (fChanged & VEHFL_CHANGED_ANGLES) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
	}

	if (fChanged & VEHFL_CHANGED_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
	}

	if (fChanged & VEHFL_CHANGED_SOLID) {
		WriteByte(MSG_ENTITY, solid);
	}

	if (fChanged & VEHFL_CHANGED_MOVETYPE) {
		WriteByte(MSG_ENTITY, movetype);
	}

	if (fChanged & VEHFL_CHANGED_SIZE) {
		WriteCoord(MSG_ENTITY, mins[0]);
		WriteCoord(MSG_ENTITY, mins[1]);
		WriteCoord(MSG_ENTITY, mins[2]);
		WriteCoord(MSG_ENTITY, maxs[0]);
		WriteCoord(MSG_ENTITY, maxs[1]);
		WriteCoord(MSG_ENTITY, maxs[2]);
	}

	if (fChanged & VEHFL_CHANGED_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

	if (fChanged & VEHFL_CHANGED_DRIVER) {
		WriteEntity(MSG_ENTITY, m_eDriver);
	}

	return (1);
}
#endif

void
ncVehicle::PlayerInput(void)
{

}

void
ncVehicle::PlayerUpdateFlags(void)
{
	if (m_iVehicleFlags & VHF_FROZEN)
		m_eDriver.m_nuclideFlags |= VFL_FROZEN;

	/*if (m_iVehicleFlags & VHF_NOATTACK)
		m_eDriver.flags |= FL_NOATTACK;*/
}

void
ncVehicle::PlayerAlign(void)
{
	vector vecPlayerPos;

	if (!m_eDriver)
		return;

	makevectors(angles);
	vecPlayerPos = origin + v_forward * m_vecPlayerPos[0];
	vecPlayerPos += v_right * m_vecPlayerPos[1];
	vecPlayerPos += v_up * m_vecPlayerPos[2];
	setorigin(m_eDriver, vecPlayerPos);

	/* remove any player velocity to prevent fall damage or other unnicecities */
	m_eDriver.velocity = [0,0,0];
}

void
ncVehicle::PlayerEnter(ncPlayer pl)
{
	vector offs;

	if (!pl)
		return;

	/* cache the position */
	offs = pl.origin - origin;

	makevectors(angles);
	m_vecPlayerPos[0] = dotproduct(offs, v_forward);
	m_vecPlayerPos[1] = dotproduct(offs, v_right);
	m_vecPlayerPos[2] = dotproduct(offs, v_up);
	m_vecExitPos = m_vecPlayerPos;
	owner = pl;
	//pl.movetype = MOVETYPE_NOCLIP;
	m_eDriver = (ncEntity)pl;
	m_eDriverLast = m_eDriver;
	pl.vehicle = this;
	pl.m_nuclideFlags |= VFL_INVEHICLE;
	EntLog("Player %S entered this vehicle.", pl.GetInfoKey("name"));
}

void
ncVehicle::PlayerLeave(ncPlayer pl)
{
	if (!pl)
		return;

	EntLog("Player %S exits this vehicle.", pl.GetInfoKey("name"));

	owner = __NULL__;
	pl.m_nuclideFlags &= ~VFL_INVEHICLE;
	pl.ClearVelocity();
	pl.SetOriginUnstick(pl.GetOrigin());

	if (m_iVehicleFlags & VHF_FROZEN)
		pl.m_nuclideFlags &= ~VFL_FROZEN;

	/*if (m_iVehicleFlags & VHF_NOATTACK)
		pl.flags &= ~FL_NOATTACK;*/

	pl.vehicle = __NULL__;
	m_eDriver = __NULL__;
}
