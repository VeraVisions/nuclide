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

/*QUAKED prop_vehicle_driveable (0 0 1) (-50 -50 0) (50 50 70)
Point entity defining a 4-wheel vehicle that you can drive.

-------- KEYS --------
"targetname" : Name

-------- SPAWNFLAGS --------


-------- NOTES --------


-------- TRIVIA --------
This entity was introduced in Half-Life 2 (2004).
*/

#define VEH_SKIDDING FL_USE_RELEASED

#define VEHSF_NOFLIP 2048

enumflags
{
	VEHFL_DRIVER,
	VEHFL_MODELINDEX,
	VEHFL_ORIGIN,
	VEHFL_ANGLES,
	VEHFL_VELOCITY,
	VEHFL_TURNING,
	VEHFL_FLAGS
};

class prop_vehicle_driveable_wheel
{
	void() prop_vehicle_driveable_wheel;
	float m_flSuspension;
	float m_flSuspensionForce;

#ifdef CLIENT

	vector origin_net;
	vector velocity_net;
	vector angles_net;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#endif

	virtual void(float) UpdateSuspension;
	virtual void(float) Move;
	virtual void(vector) Bounce;
	virtual void(float, float m_flTurn) Accel;
	virtual void(float, float) Physics;
};

class prop_vehicle_driveable:NSVehicle
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
	vector m_vecSeatOffest;

	/* collision boxes */
	NSEntity m_eCollBox1;
	NSEntity m_eCollBox2;

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

	float m_flUseTime;

	void(void) prop_vehicle_driveable;

	virtual void(void) Spawned;
	virtual void(void) Physics;
	virtual void(void) RunVehiclePhysics;
	virtual void(void) WeaponInput;
	virtual void(void) PlayerInput;
	virtual void(void) OnRemoveEntity;

#ifdef CLIENT
	virtual bool(void) HideViewWeapon;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void(float, float) ReceiveEntity;
	virtual void(void) UpdateView;
#else
	virtual void(void) Respawn;
	virtual void(void) OnPlayerUse;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif
};

#ifdef CLIENT
bool
prop_vehicle_driveable::HideViewWeapon(void)
{
	return true;
}
#endif

void
prop_vehicle_driveable::Physics(void)
{
#ifdef CLIENT
	DriverRelink();
#endif

	/* if nobody is in the car, we need to run physics here
	 * with fake input frames */
	if (GetDriver() == __NULL__) {
#ifdef SERVER
		m_flTimeLength = frametime;
		m_vecMoveValues = [0,0,0];
		m_iMoveButtons = 0;
		RunVehiclePhysics();
#else
		setorigin(this, origin);
#endif
	} else {
		//crossprint(sprintf("Driver: %s\n", GetDriver().classname));
	}

	HandleThink();
}

void
prop_vehicle_driveable::OnRemoveEntity(void)
{
	remove(m_wlFL);
	remove(m_wlFR);
	remove(m_wlBL);
	remove(m_wlBR);
	remove(m_eCollBox1);
	remove(m_eCollBox2);
}

#ifdef CLIENT
void
prop_vehicle_driveable::UpdateView(void)
{
	vector vecStart, vecEnd;

	pSeat->m_vecPredictedOrigin = origin;
	makevectors(view_angles);
	vecStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
	vecEnd = vecStart + (v_forward * -256) + [0,0,16] + (v_right * 4);
	other = world;
	traceline(vecStart, vecEnd, MOVE_OTHERONLY, this);
	g_view.SetCameraOrigin(trace_endpos + (v_forward * 16));
	g_view.SetClientAngle(view_angles);
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

	vector vecBounce = (velocity * normal) * normal * vehParent.m_flBounceFactor;
	velocity -= vecBounce;
	vehParent.velocity = velocity;

#ifdef SERVER
	float flStregth = vlen((velocity * normal) * normal);

	if (flStregth > 96) {
		Sound_Play(vehParent, CHAN_VOICE, "prop_vehicle_driveable.bounce");
	}
#endif
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
		/* cripple turnrate by our current velocity */
		float turnbreak = bound(0, vlen(velocity), 100) * 0.5;

		/* rotates v_forward */
		rotatevectorsbyangle([ 0, m_flTurn * turnbreak, 0]);
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

		/* test if this car is skidding */
		float skid = (velocity * v_right);
		if ( fabs(skid) > vehParent.m_flSkidSpeed ) {
			vehParent.flags |= VEH_SKIDDING;
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

	tracebox(origin, mins * 4.0, maxs * 4.0, origin, MOVE_NORMAL, owner);
	if (trace_ent && trace_ent != vehParent.m_eDriver) {
		int iImpactDamage = vlen(velocity) / 10;

		if (iImpactDamage > 10) {
			trace_ent.velocity = velocity * 2.0 + [0,0,500];
			velocity *= 0.25f;
#ifdef SERVER
			if (trace_ent.takedamage) {
				NSSurfacePropEntity foo = (NSSurfacePropEntity)trace_ent;
				Damage_Apply(foo, vehParent.m_eDriver, iImpactDamage, 0, DMG_VEHICLE);
				//print(sprintf("Delivering %i impact damage\n", iImpactDamage));
			}
#endif
		}
	}
}

void
prop_vehicle_driveable_wheel::UpdateSuspension(float flTimeLength)
{
	float flDamp;
	float flForce;

	if (fabs(m_flSuspension) > 0.001 || fabs(m_flSuspensionForce) > 0.001) {
		m_flSuspension += m_flSuspensionForce * flTimeLength;
		
		flForce = bound(0, flTimeLength * 65, 2);
		flDamp = 1 - (flTimeLength * 4);
		if (flDamp < 0) {
			flDamp = 0;
		}
		m_flSuspensionForce *= flDamp;
		m_flSuspensionForce -= m_flSuspension * flForce;
		m_flSuspension = bound(-15, m_flSuspension, 15);
	}
}

void
prop_vehicle_driveable_wheel::Physics(float turnrate, float flTimeLength)
{
	vector owner_pos;

	/* try to correct the wheel's position, in case it got stuck */
	owner_pos = owner.origin + (owner.mins + owner.maxs) * 0.5f;
	tracebox(owner_pos, mins, maxs, origin, MOVE_NORMAL, owner);
	setorigin(this, trace_endpos);

	/* see if we're in-air */
	other = world;
	tracebox(origin, mins, maxs, origin - [0,0,1], MOVE_OTHERONLY, this);
	if (!trace_startsolid) {
		if ((trace_fraction < 1) && (trace_plane_normal[2] > 0.7)) {
			flags |= FL_ONGROUND;
		} else {
			flags &= ~FL_ONGROUND;
			m_flSuspensionForce += flTimeLength * 200.0;
		}
	}

	Accel(flTimeLength / 2, turnrate);
	Move(flTimeLength);
	Accel(flTimeLength / 2, turnrate);
	UpdateSuspension(flTimeLength);
	//print(sprintf("suspension: %d, force: %d\n", m_flSuspension, m_flSuspensionForce));
}

void
prop_vehicle_driveable_wheel::prop_vehicle_driveable_wheel(void)
{
	mins = [-8,-8,-35];
	maxs = [8,8,8];
	hitcontentsmaski = CONTENTBIT_BODY | CONTENTBITS_POINTSOLID | CONTENTBIT_VEHICLECLIP;
}

#ifdef CLIENT
void
prop_vehicle_driveable::PredictPreFrame(void)
{
	SAVE_STATE(modelindex);
	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(velocity);
	SAVE_STATE(m_flTurn);
	SAVE_STATE(flags);
	SAVE_STATE(driver_entnum);

	m_wlFL.PredictPreFrame();
	m_wlFR.PredictPreFrame();
	m_wlBL.PredictPreFrame();
	m_wlBR.PredictPreFrame();
}

void
prop_vehicle_driveable::PredictPostFrame(void)
{
	ROLL_BACK(modelindex);
	ROLL_BACK(angles);
	ROLL_BACK(origin);
	ROLL_BACK(velocity);
	ROLL_BACK(m_flTurn);
	ROLL_BACK(flags);
	ROLL_BACK(driver_entnum);

	m_wlFL.PredictPostFrame();
	m_wlFR.PredictPostFrame();
	m_wlBL.PredictPostFrame();
	m_wlBR.PredictPostFrame();
}
#endif

void
prop_vehicle_driveable::WeaponInput(void)
{

}

void
prop_vehicle_driveable::PlayerInput(void)
{
	m_vecMoveValues = input_movevalues;
	m_iMoveButtons = input_buttons;
	m_flTimeLength = input_timelength;

	/* prediction frame... */
	RunVehiclePhysics();

#ifdef SERVER
	/* allow us to exit */
	if (m_flUseTime < time) {
		if (input_buttons & INPUT_BUTTON5) {
			eActivator = m_eDriver;
			OnPlayerUse();
			input_buttons &= ~INPUT_BUTTON5;
		}
	}
#endif

	WeaponInput();

	/* only allow use key */
	input_buttons = (input_buttons & INPUT_BUTTON5);
}

void
prop_vehicle_driveable::RunVehiclePhysics(void)
{
#if SERVER
	/* eject the dead */
	if (m_eDriver && m_eDriver.health <= 0) {
		PlayerLeave((NSClientPlayer)m_eDriver);
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

	if (spawnflags & VEHSF_NOFLIP) {
		angles[0] = bound (-45, angles[0], 45);
		angles[2] = bound (-45, angles[2], 45);
	}

	flags &= ~VEH_SKIDDING;

	angles[0] = Math_FixDelta(angles[0]);
	angles[1] = Math_FixDelta(angles[1]);
	angles[2] = Math_FixDelta(angles[2]);

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

	makevectors(angles);
	m_eCollBox1.SetOrigin(origin + (v_forward * 64));
	m_eCollBox2.SetOrigin(origin + (v_forward * -72));
	m_eCollBox1.SetSolid(SOLID_BBOX);
	m_eCollBox2.SetSolid(SOLID_BBOX);

	PlayerAlign();

	/* actiony stuff */
}

#ifdef SERVER
void
prop_vehicle_driveable::OnPlayerUse(void)
{
	if (m_flUseTime > time)
		return;

	if (m_eDriver == eActivator) {
		PlayerLeave((NSClientPlayer)eActivator);
		setorigin(eActivator, GetExitPos());
	} else if (!m_eDriver) {
		PlayerEnter((NSClientPlayer)eActivator);
		m_vecPlayerPos = [0,0,0];
	}
	m_flUseTime = time + 2.0f;
}

void
prop_vehicle_driveable::Respawn(void)
{
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BBOX);
	SetOrigin(GetSpawnOrigin() + [0,0,32]);
	SetAngles(GetSpawnAngles());
	SetModel(GetSpawnModel());

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
	setsize( this, [-50,-50,0], [50,50,64]);

	if (m_eDriver)
		PlayerLeave((NSClientPlayer)m_eDriver);

	SendFlags = -1;
}
#endif

#ifdef CLIENT
void
prop_vehicle_driveable::ReceiveEntity(float flSendFlags, float flNew)
{
	if (flSendFlags & VEHFL_DRIVER) {
		driver_entnum = readentitynum();
		DriverRelink();
	}

	if (flSendFlags & VEHFL_MODELINDEX) {
		modelindex = readshort();
		m_vecSeatOffest[0] = readfloat();
		m_vecSeatOffest[1] = readfloat();
		m_vecSeatOffest[2] = readfloat();
		setsize( this, [-50,-50,0], [50,50,64]);
	}

	if (flSendFlags & VEHFL_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setorigin(this, origin);

		makevectors(angles);

		setorigin( m_wlFL, origin );
		setorigin( m_wlBL, m_wlFL.origin - v_forward * 85 );
		setorigin( m_wlFL, m_wlFL.origin + v_forward * 85 );
		setorigin( m_wlFR, m_wlFL.origin + v_right * 40 );
		setorigin( m_wlFL, m_wlFL.origin - v_right * 40 );
		setorigin( m_wlBR, m_wlBL.origin + v_right * 40 );
		setorigin( m_wlBL, m_wlBL.origin - v_right * 40 );
		m_eCollBox1.SetOrigin(origin + (v_forward * 64));
		m_eCollBox2.SetOrigin(origin + (v_forward * -72));
	}

	if (flSendFlags & VEHFL_ANGLES) {
		angles[0] = readfloat();
		angles[1] = readfloat();
		angles[2] = readfloat();
	}

	if (flSendFlags & VEHFL_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

	if (flSendFlags & VEHFL_TURNING)
		m_flTurn = readfloat();

	if (flSendFlags & VEHFL_FLAGS)
		flags = readfloat();

	if (flNew) {
		drawmask = MASK_ENGINE;
		SetMovetype(MOVETYPE_NONE);
		SetSolid(SOLID_BBOX);

		m_flBRWheelAxel = gettagindex( this, "RRWheelAxel" );
		m_flBLWheelAxel = gettagindex( this, "RLWheelAxel" );
		m_flFLWheelAxel = gettagindex( this, "FLWheelAxel" );
		m_flFRWheelAxel = gettagindex( this, "FRWheelAxel" );

		m_wlFL.velocity =
		m_wlFR.velocity =
		m_wlBL.velocity =
		m_wlBR.velocity =
		velocity = [0,0,0];
		RunVehiclePhysics();
		customphysics = Physics;
	}

	PredictPreFrame();
}
#else
void
prop_vehicle_driveable::EvaluateEntity(void)
{
	/* while the engine is still handling physics for these, we can't
	 * predict when origin/angle might change */
	if (ATTR_CHANGED(origin))
		SetSendFlags(VEHFL_ORIGIN);

	if (ATTR_CHANGED(angles)) {
		angles[0] = Math_FixDelta(angles[0]);
		angles[1] = Math_FixDelta(angles[1]);
		angles[2] = Math_FixDelta(angles[2]);

		SetSendFlags(VEHFL_ANGLES);
	}
	if (ATTR_CHANGED(modelindex))
		SetSendFlags(VEHFL_MODELINDEX);
	if (ATTR_CHANGED(velocity))
		SetSendFlags(VEHFL_VELOCITY);
	if (ATTR_CHANGED(m_flTurn))
		SetSendFlags(VEHFL_TURNING);
	if (ATTR_CHANGED(m_eDriver))
		SetSendFlags(VEHFL_DRIVER);
	if (ATTR_CHANGED(flags))
		SetSendFlags(VEHFL_FLAGS);

	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(modelindex);
	SAVE_STATE(velocity);
	SAVE_STATE(m_flTurn);
	SAVE_STATE(m_eDriver);
	SAVE_STATE(flags);
}

float
prop_vehicle_driveable::SendEntity(entity ePVSent, float flSendFlags)
{
	WriteByte(MSG_ENTITY, ENT_VEH_4WHEEL);
	WriteFloat(MSG_ENTITY, flSendFlags);

	if (!modelindex)
		return (false);

	if (flSendFlags & VEHFL_DRIVER) {
		WriteEntity(MSG_ENTITY, m_eDriver);
	}

	if (flSendFlags & VEHFL_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
		WriteFloat(MSG_ENTITY, m_vecSeatOffest[0]);
		WriteFloat(MSG_ENTITY, m_vecSeatOffest[1]);
		WriteFloat(MSG_ENTITY, m_vecSeatOffest[2]);
	}

	if (flSendFlags & VEHFL_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (flSendFlags & VEHFL_ANGLES) {
		WriteFloat(MSG_ENTITY, angles[0]);
		WriteFloat(MSG_ENTITY, angles[1]);
		WriteFloat(MSG_ENTITY, angles[2]);
	}

	if (flSendFlags & VEHFL_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

	if (flSendFlags & VEHFL_TURNING)
		WriteFloat(MSG_ENTITY, m_flTurn);

	if (flSendFlags & VEHFL_FLAGS)
		WriteFloat(MSG_ENTITY, flags);

	return true;
}
#endif

void
prop_vehicle_driveable::Spawned(void)
{
	super::Spawned();

#ifdef SERVER
	Sound_Precache("prop_vehicle_driveable.bounce");
#endif
}

void
prop_vehicle_driveable::prop_vehicle_driveable(void)
{
	m_eDriver = __NULL__;
	m_flBounceFactor = 1.25f;
	m_flAcceleration = 600.0f;
	m_flSkidSpeed = 256.0f;
	m_flTraction = 5.0f;
	m_flBreakFactor = 2.0f;
	m_flSteerFactor = 1.0f;
	m_flStraightenFactor = 1.0f;
	m_vecGravityDir = [0,0,-1];
	m_iVehicleFlags |= VHF_FROZEN;
	hitcontentsmaski = CONTENTBIT_BODY | CONTENTBITS_POINTSOLID | CONTENTBIT_VEHICLECLIP;

	if (!m_eCollBox1)
		m_eCollBox1 = spawn(NSEntity);
	if (!m_eCollBox2)
		m_eCollBox2 = spawn(NSEntity);

	{
		m_eCollBox1.SetSize([-32,-32,0], [32,32,32]);
		m_eCollBox2.SetSize([-32,-32,0], [32,32,32]);
	}

	m_eCollBox1.hitcontentsmaski = hitcontentsmaski;	
	m_eCollBox2.hitcontentsmaski = hitcontentsmaski;	

	if (!m_wlFL)
		m_wlFL = spawn(prop_vehicle_driveable_wheel);
	if (!m_wlFR)
		m_wlFR = spawn(prop_vehicle_driveable_wheel);
	if (!m_wlBL)
		m_wlBL = spawn(prop_vehicle_driveable_wheel);
	if (!m_wlBR)
		m_wlBR = spawn(prop_vehicle_driveable_wheel);

	m_eCollBox1.owner = m_eCollBox2.owner = \
		m_wlFL.owner = m_wlFR.owner = \
		m_wlBL.owner = m_wlBR.owner = this;

	customphysics = Physics;
}

#ifdef CLIENT
void
prop_vehicle_driveable_readentity(float isnew)
{
	prop_vehicle_driveable veh = (prop_vehicle_driveable)self;
	float flags = readfloat();

	if (isnew)
		spawnfunc_prop_vehicle_driveable();

	veh.ReceiveEntity(flags, isnew);
}
#endif
