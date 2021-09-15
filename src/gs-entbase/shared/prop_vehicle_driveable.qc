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

/*QUAKED prop_vehicle_driveable (0 0 1) (-50 -50 0) (50 50 70)
Point entity defining a 4-wheel vehicle that you can drive.

-------- KEYS --------
"targetname" : Name

-------- SPAWNFLAGS --------


-------- NOTES --------


-------- TRIVIA --------
This entity was introduced in Half-Life 2 (2004).
*/


class prop_vehicle_driveable_wheel
{
	void() prop_vehicle_driveable_wheel;

#ifdef CLIENT
	vector origin_net;
	vector velocity_net;
	vector angles_net;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#endif

	virtual void(float) Move;
	virtual void(vector) Bounce;
	virtual void(float, float m_flTurn) Accel;
	virtual void(float, float) Physics;
};

class prop_vehicle_driveable:CBaseVehicle
{
	/* map-entity fields */
	float m_flBounceFactor;
	float m_flAcceleration;
	float m_flSkidSpeed;
	float m_flTraction;
	float m_flBreakFactor;
	float m_flSteerFactor;
	float m_flStraightenFactor;
	vector m_vecGravityDir;
	float m_flTimeLength;

	prop_vehicle_driveable_wheel m_wlFL;
	prop_vehicle_driveable_wheel m_wlFR;
	prop_vehicle_driveable_wheel m_wlBL;
	prop_vehicle_driveable_wheel m_wlBR;
	vector m_vecControlMins;
	vector m_vecControlMaxs;
	PREDICTED_FLOAT(m_flTurn);

	float m_flBRWheelAxel;
	float m_flBLWheelAxel;
	float m_flFLWheelAxel;
	float m_flFRWheelAxel;

	void(void) prop_vehicle_driveable;
	virtual void(void) RunVehiclePhysics;
	virtual void(void) PlayerInput;

#ifdef CLIENT
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void(float, float) ReadEntity;
	virtual void(void) UpdateView;
#else
	virtual void(void) Respawn;
	virtual void(void) OnPlayerUse;
	virtual float(entity, float) SendEntity;
#endif
};

#ifdef CLIENT
void
prop_vehicle_driveable::UpdateView(void)
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
prop_vehicle_driveable_wheel::PredictPreFrame(void)
{
	SAVE_STATE(angles);
	SAVE_STATE(origin);
	SAVE_STATE(velocity);
}

void
prop_vehicle_driveable_wheel::PredictPostFrame(void)
{
	ROLL_BACK(angles);
	ROLL_BACK(origin);
	ROLL_BACK(velocity);
}
#endif

void
prop_vehicle_driveable_wheel::Bounce(vector normal)
{
	prop_vehicle_driveable vehParent;
	vehParent = (prop_vehicle_driveable)owner;
	velocity -= (velocity * normal) * normal * vehParent.m_flBounceFactor;
	velocity *= 0.95f; /* absorb some energy */
}

void
prop_vehicle_driveable_wheel::Move(float flTimeLength)
{
	vector vecDest;
	vector vecSavedNormal;
	float flStepped;
	float flMovetime;
	int i;

	/* have a few attempts */
	for (i = 3, flMovetime = flTimeLength; flMovetime > 0 && i; i--) {
		vecDest = origin + (velocity * flMovetime);
		tracebox(origin, mins, maxs, vecDest, MOVE_NOMONSTERS, this);

		if (trace_startsolid) {
			continue;
		}

		origin = trace_endpos;

		if (trace_fraction < 1) {
			vecSavedNormal = trace_plane_normal;
			flMovetime -= flMovetime * trace_fraction;

			if (flMovetime) {
				float roof_fraction;
				vector roof_plane_normal;

				/* step up if we can */
				trace_endpos = origin;
				trace_endpos[2] += 8;

				tracebox(origin, mins, maxs, trace_endpos, MOVE_NOMONSTERS, this);
				flStepped = trace_endpos[2] - origin[2];

				roof_fraction = trace_fraction;
				roof_plane_normal = trace_plane_normal;

				vecDest = trace_endpos + velocity * flMovetime;

				 /* only horizontally */
				vecDest[2] = trace_endpos[2];

				/* move forwards */
				tracebox(trace_endpos, mins, maxs, vecDest, MOVE_NOMONSTERS, this);

				/* if we got anywhere, make this raised-step move count */
				if (trace_fraction != 0) {
					float fwfrac;
					vector fwplane;

					fwfrac = trace_fraction;
					fwplane = trace_plane_normal;

					/* move down */
					vecDest = trace_endpos;
					vecDest[2] -= flStepped + 1;
					tracebox(trace_endpos, mins, maxs, vecDest, MOVE_NOMONSTERS, this);

					if (trace_fraction < 1 && trace_plane_normal[2] > 0.7f) {
						flMovetime -= flMovetime * fwfrac;

						if (roof_fraction < 1) {
							Bounce(roof_plane_normal);
						}

						/* FIXME: do we need velocity < 0? */
						if (trace_fraction < 1) {
							Bounce(trace_plane_normal);
						} else if (fwfrac < 1) {
							Bounce(fwplane);
						}

						origin = trace_endpos;
						continue;
					}
				}
			}

			/* stepping failed, assume crash? */
			if (trace_ent == world) {
				if (vlen(velocity) > 300) {
					float impact;
					impact = -dotproduct(trace_plane_normal, velocity);
					int iImpactDamage = impact / 100;
				}
			}

			Bounce(vecSavedNormal);
			/* Physics_DoTouch(this, trace_ent); */
		} else {
			break;
		}
	}
}

void
prop_vehicle_driveable_wheel::Accel(float flMoveTime, float m_flTurn)
{
	prop_vehicle_driveable vehParent;
	entity eDriver;
	float flTraction;
	vector vecAngle;

	vehParent = (prop_vehicle_driveable)owner;
	eDriver = vehParent.m_eDriver;
	vecAngle = vehParent.angles;

	makevectors(vecAngle);

	if (m_flTurn) {
		/* rotates v_forward */
		rotatevectorsbyangle([ 0, m_flTurn * 50, 0]);
	}

	tracebox(origin, mins, maxs, origin - v_up, MOVE_NOMONSTERS, owner);

	/* allow a range, for 1qu's worth of spare tyre pressure. or something */
	flTraction = 1 - trace_fraction;

	/* air friction, doubles up for general rolling friction, ish */
	velocity *= 1 - flMoveTime * 0.1;
	
	if (flTraction) {
		if (eDriver) {
			velocity += v_forward * bound(-1, vehParent.m_vecMoveValues[0] / 400, 1) * vehParent.m_flAcceleration * flMoveTime * flTraction;
		}

		/* nuke sideways velocity. if a wheel is off the ground this probably
		   means that it'll be pushed further. players should try not to roll
		   too much. */
		/* FIXME: push opposite wheel up slightly to model chassis momentum
		   not slowing as much as the wheel itself (zomg: race conditions!) */
		velocity -= (velocity * v_right) * v_right * vehParent.m_flTraction * flMoveTime * flTraction;

		if (!eDriver || (vehParent.m_iMoveButtons & INPUT_BUTTON2 || vehParent.m_vecMoveValues[2] > 0)) {
			vector t;

			/* empty cars are assumed to have their brakes on.
			   nuke forward velocity. if a wheel is off the ground this probably
			   means that it'll be pushed further. players should try not to
			   roll too much.

			   Note: really we ought to be applying some axel friction even
			   when not breaking, but we'll just depend on air friction for
			   that. */
			velocity -= (velocity * v_forward) * v_forward * vehParent.m_flBreakFactor * flMoveTime * flTraction;

			/* if break is on, nuke the final part of the velocity, so we can
			   become truely motionless.*/
			t = velocity - velocity * dotproduct(velocity, vehParent.m_vecGravityDir);
			if (vlen(t) < 15) {
				velocity -= t;
			}
			
			/* don't bother with gravity if we're already on the ground and
			   breaking. this avoids weird slides. */
			if (!trace_fraction && trace_plane_normal * vehParent.m_vecGravityDir < -0.7f) {
				return;
			}
		}
	}

	/* apply gravity */
	velocity += vehParent.m_vecGravityDir * flMoveTime * serverkeyfloat("phy_gravity") * trace_fraction;
}

void
prop_vehicle_driveable_wheel::Physics(float turnrate, float flTimeLength)
{
	vector owner_pos;

	/* try to correct the wheel's position, in case it got stuck */
	owner_pos = owner.origin + (owner.mins + owner.maxs) * 0.5f;
	tracebox(owner_pos, mins, maxs, origin, MOVE_NOMONSTERS, owner);
	setorigin(this, trace_endpos);

	Accel(flTimeLength / 2, turnrate);
	Move(flTimeLength);
	Accel(flTimeLength / 2, turnrate);
}

void
prop_vehicle_driveable_wheel::prop_vehicle_driveable_wheel(void)
{
	hitcontentsmaski = CONTENTBIT_SOLID | CONTENTBIT_BODY;
	mins = [-8,-8,-35];
	maxs = [8,8,8];
}

#ifdef CLIENT
void
prop_vehicle_driveable::PredictPreFrame(void)
{
	SAVE_STATE(angles);
	SAVE_STATE(origin);
	SAVE_STATE(velocity);
	SAVE_STATE(m_flTurn);

	m_wlFL.PredictPreFrame();
	m_wlFR.PredictPreFrame();
	m_wlBL.PredictPreFrame();
	m_wlBR.PredictPreFrame();
}

void
prop_vehicle_driveable::PredictPostFrame(void)
{
	ROLL_BACK(angles);
	ROLL_BACK(origin);
	ROLL_BACK(velocity);
	ROLL_BACK(m_flTurn);

	m_wlFL.PredictPostFrame();
	m_wlFR.PredictPostFrame();
	m_wlBL.PredictPostFrame();
	m_wlBR.PredictPostFrame();
}
#endif

void
prop_vehicle_driveable::PlayerInput(void)
{
	m_vecMoveValues = input_movevalues;
	m_iMoveButtons = input_buttons;
	m_flTimeLength = input_timelength;

	/* prediction frame... */
	RunVehiclePhysics();
}

void
prop_vehicle_driveable::RunVehiclePhysics(void)
{
#if SERVER
	/* eject the dead */
	if (m_eDriver && m_eDriver.health <= 0) {
		PlayerLeave((base_player)m_eDriver);
	}
#endif

	if (m_eDriver) {
		float y;

		y = m_vecMoveValues[1];
		y = bound(-200, y, 200) / 200;
		y *= m_flSteerFactor;

		if (y) {
			if (y < 0 && m_flTurn < 0) {
				m_flTurn = 0.0f;
			} else if (y > 0 && m_flTurn > 0) {
				m_flTurn = 0.0f;
			} else {
				m_flTurn = bound(-1, m_flTurn - y * m_flTimeLength, 1);
			}
		} else {
			/* straighten wheels forward over time */
			if (m_flTurn < 0) {
				m_flTurn = min(0, m_flTurn + m_flTimeLength * m_flStraightenFactor);
			} else if (m_flTurn > 0) {
				m_flTurn = max(0, m_flTurn - m_flTimeLength * m_flStraightenFactor);
			}
		}

		PlayerUpdateFlags();
	}

	angles[0] = Math_FixDelta(angles[0]);
	angles[1] = Math_FixDelta(angles[1]);
	angles[2] = Math_FixDelta(angles[2]);
	angles[0] = bound(-45, angles[0], 45);
	angles[2] = bound(-45, angles[2], 45);


	velocity[0] = bound(-1000, velocity[0], 1000);
	velocity[1] = bound(-1000, velocity[1], 1000);
	velocity[2] = bound(-1000, velocity[2], 1000);

	makevectors(angles);

	setorigin( m_wlFL, origin );
	setorigin( m_wlBL, m_wlFL.origin - v_forward * 85 );
	setorigin( m_wlFL, m_wlFL.origin + v_forward * 85 );
	setorigin( m_wlFR, m_wlFL.origin + v_right * 40 );
	setorigin( m_wlFL, m_wlFL.origin - v_right * 40 );
	setorigin( m_wlBR, m_wlBL.origin + v_right * 40 );
	setorigin( m_wlBL, m_wlBL.origin - v_right * 40 );

	m_wlFL.Physics( this.m_flTurn, m_flTimeLength);
	m_wlFR.Physics( this.m_flTurn, m_flTimeLength);
	m_wlBL.Physics( 0, m_flTimeLength);
	m_wlBR.Physics( 0, m_flTimeLength);

	velocity = m_wlFL.velocity;
	velocity += m_wlFR.velocity;
	velocity += m_wlBL.velocity;
	velocity += m_wlBR.velocity;
	velocity *= 0.25f;

	v_right = (m_wlFR.origin - m_wlFL.origin);
	v_right += (m_wlBR.origin - m_wlBL.origin);
	v_forward = (m_wlFL.origin + m_wlFR.origin);
	v_forward -= (m_wlBL.origin + m_wlBR.origin);
	v_up = -crossproduct(v_forward, v_right);
	angles = vectoangles( v_forward, v_up );

	/* figure out the new chassis position */
	vector new_origin;
	new_origin = m_wlFL.origin;
	new_origin += m_wlFR.origin;
	new_origin += m_wlBL.origin;
	new_origin += m_wlBR.origin;
	new_origin *= 0.25f;
	setorigin(this, new_origin);
	PlayerAlign();

#ifdef SERVER
	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
#endif
}

#ifdef SERVER
void
prop_vehicle_driveable::OnPlayerUse(void)
{
	if (m_eDriver == eActivator) {
		PlayerLeave((base_player)eActivator);
	} else if (!m_eDriver) {
		PlayerEnter((base_player)eActivator);
		m_vecPlayerPos = [0,0,0];
	}
}

void
prop_vehicle_driveable::Respawn(void)
{
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BBOX);
	SetOrigin(m_oldOrigin + [0,0,32]);
	SetAngles(m_oldAngle);
	SetModel(m_oldModel);

	m_flBRWheelAxel = gettagindex( this, "RRWheelAxel" );
	m_flBLWheelAxel = gettagindex( this, "RLWheelAxel" );
	m_flFLWheelAxel = gettagindex( this, "FLWheelAxel" );
	m_flFRWheelAxel = gettagindex( this, "FRWheelAxel" );

	m_wlFL.velocity =
	m_wlFR.velocity =
	m_wlBL.velocity =
	m_wlBR.velocity =
	velocity = [0,0,0];
	PlayerUse = OnPlayerUse;
	setsize( this, [-50,-50,0], [50,50,70]);

	if (m_eDriver)
		PlayerLeave((base_player)m_eDriver);
}
#endif

#ifdef CLIENT
void
prop_vehicle_driveable::ReadEntity(float flSendFlags, float flNew)
{
	m_eDriver = findfloat(world, ::entnum, readentitynum());

	modelindex = readshort();

	origin[0] = readcoord();
	origin[1] = readcoord();
	origin[2] = readcoord();

	angles[0] = readfloat();
	angles[1] = readfloat();
	angles[2] = readfloat();

	velocity[0] = readfloat();
	velocity[1] = readfloat();
	velocity[2] = readfloat();

	m_flTurn = readfloat();

	if (flNew) {
		drawmask = MASK_ENGINE;
		m_flBRWheelAxel = gettagindex( this, "RRWheelAxel" );
		m_flBLWheelAxel = gettagindex( this, "RLWheelAxel" );
		m_flFLWheelAxel = gettagindex( this, "FLWheelAxel" );
		m_flFRWheelAxel = gettagindex( this, "FRWheelAxel" );
		setsize( this, [-50,-50,0], [50,50,70]);
	}
}
#else
float
prop_vehicle_driveable::SendEntity(entity ePVSent, float flSendFlags)
{
	WriteByte(MSG_ENTITY, ENT_VEH_4WHEEL);
	WriteFloat(MSG_ENTITY, flSendFlags);

	WriteEntity(MSG_ENTITY, m_eDriver);

	WriteShort(MSG_ENTITY, modelindex);

	WriteCoord(MSG_ENTITY, origin[0]);
	WriteCoord(MSG_ENTITY, origin[1]);
	WriteCoord(MSG_ENTITY, origin[2]);

	WriteFloat(MSG_ENTITY, angles[0]);
	WriteFloat(MSG_ENTITY, angles[1]);
	WriteFloat(MSG_ENTITY, angles[2]);

	WriteFloat(MSG_ENTITY, velocity[0]);
	WriteFloat(MSG_ENTITY, velocity[1]);
	WriteFloat(MSG_ENTITY, velocity[2]);

	WriteFloat(MSG_ENTITY, m_flTurn);
	return TRUE;
}
#endif

void
prop_vehicle_driveable::prop_vehicle_driveable(void)
{
	m_flBounceFactor = 1.5f;
	m_flAcceleration = 600.0f;
	m_flSkidSpeed = 256.0f;
	m_flTraction = 2.0f;
	m_flBreakFactor = 2.0f;
	m_flSteerFactor = 1.0f;
	m_flStraightenFactor = 1.0f;
	m_vecGravityDir = [0,0,-1];
	m_iVehicleFlags |= VHF_FROZEN;

	CBaseVehicle::CBaseVehicle();

	m_wlFL = spawn(prop_vehicle_driveable_wheel);
	m_wlFR = spawn(prop_vehicle_driveable_wheel);
	m_wlBL = spawn(prop_vehicle_driveable_wheel);
	m_wlBR = spawn(prop_vehicle_driveable_wheel);
	m_wlFL.owner = m_wlFR.owner = m_wlBL.owner = m_wlBR.owner = this;
}

#ifdef CLIENT
void
prop_vehicle_driveable_readentity(float isnew)
{
	prop_vehicle_driveable veh = (prop_vehicle_driveable)self;
	float flags = readfloat();

	if (isnew)
		spawnfunc_prop_vehicle_driveable();

	veh.ReadEntity(flags, isnew);
}
#endif