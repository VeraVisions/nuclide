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

enumflags
{
	VHF_FROZEN,
	VHF_NOATTACK
};

#ifdef CLIENT
void
CBaseVehicle::UpdateView(void)
{
	vector vecStart, vecEnd;

	pSeat->m_vecPredictedOrigin = origin;
	makevectors(view_angles);
	vecStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
	vecEnd = vecStart + (v_forward * -256) + [0,0,16] + (v_right * 4);
	traceline(vecStart, vecEnd, FALSE, self);
	setproperty(VF_ORIGIN, trace_endpos + (v_forward * 16));
}

void
CBaseVehicle::PredictPreFrame(void)
{
	SAVE_STATE(angles);
	SAVE_STATE(origin);
	SAVE_STATE(velocity);
}

void
CBaseVehicle::PredictPostFrame(void)
{
	ROLL_BACK(angles);
	ROLL_BACK(origin);
	ROLL_BACK(velocity);
}

void
CBaseVehicle::ReadEntity(float fChanged, float new)
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
		m_eDriver = findfloat(world, ::entnum, readentitynum());
	}

	if (new)
		drawmask = MASK_ENGINE;
}
#else
void
CBaseVehicle::EvaluateEntity(void)
{
	/* while the engine is still handling physics for these, we can't
	 * predict when origin/angle might change */
	if (net_origin != origin) {
		net_origin = origin;
		SetSendFlags(VEHFL_CHANGED_ORIGIN);
	}
	if (net_angles != angles) {
		angles[0] = Math_FixDelta(angles[0]);
		angles[1] = Math_FixDelta(angles[1]);
		angles[2] = Math_FixDelta(angles[2]);

		net_angles = angles;
		SetSendFlags(VEHFL_CHANGED_ANGLES);
	}
	if (net_velocity != velocity) {
		net_velocity = velocity;
		SetSendFlags(VEHFL_CHANGED_VELOCITY);
	}
}

float
CBaseVehicle::SendEntity(entity ePEnt, float fChanged)
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
CBaseVehicle::PlayerInput(void)
{

}

void
CBaseVehicle::PlayerUpdateFlags(void)
{
	if (m_iVehicleFlags & VHF_FROZEN)
		m_eDriver.flags |= FL_FROZEN;

	if (m_iVehicleFlags & VHF_NOATTACK)
		m_eDriver.flags |= FL_NOATTACK;
}

void
CBaseVehicle::PlayerAlign(void)
{
	vector vecPlayerPos;

	if (!m_eDriver)
		return;

	makevectors(angles);
	vecPlayerPos = origin + v_forward * m_vecPlayerPos[0];
	vecPlayerPos += v_right * m_vecPlayerPos[1];
	vecPlayerPos += v_up * m_vecPlayerPos[2];

	setorigin(m_eDriver, vecPlayerPos);
}

void
CBaseVehicle::PlayerEnter(base_player pl)
{
	vector offs;

	/* cache the position */
	offs = pl.origin - origin;

	makevectors(angles);
	m_vecPlayerPos[0] = dotproduct(offs, v_forward);
	m_vecPlayerPos[1] = dotproduct(offs, v_right);
	m_vecPlayerPos[2] = dotproduct(offs, v_up);
	pl.movetype = MOVETYPE_NOCLIP;
	m_eDriver = (entity)pl;
	pl.vehicle = this;
	pl.flags |= FL_INVEHICLE;

#ifdef SERVER
	SetSendFlags(VEHFL_CHANGED_DRIVER);
#endif
}

void
CBaseVehicle::PlayerLeave(base_player pl)
{
	pl.movetype = MOVETYPE_WALK;
	pl.flags &= ~FL_INVEHICLE;

	if (m_iVehicleFlags & VHF_FROZEN)
		pl.flags &= ~FL_FROZEN;

	if (m_iVehicleFlags & VHF_NOATTACK)
		pl.flags &= ~FL_NOATTACK;

	pl.vehicle = __NULL__;
	m_eDriver = __NULL__;

#ifdef SERVER
	SetSendFlags(VEHFL_CHANGED_DRIVER);
#endif
}

void
CBaseVehicle::CBaseVehicle(void)
{
	CBaseEntity::CBaseEntity();
}
#ifdef CLIENT
void
basevehicle_readentity(float isnew)
{
	CBaseVehicle veh = (CBaseVehicle)self;
	float flags = readfloat();

	if (isnew)
		spawnfunc_CBaseVehicle();

	veh.ReadEntity(flags, isnew);
}
#endif
