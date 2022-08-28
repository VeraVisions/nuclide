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

/*QUAKED func_vehicle (0 .5 .8) ? FUNCVEH_NOPITCH FUNCVEH_NOUSER x FUNCVEH_PASSABLE FUNCVEH_FWDRIVE FUNCVEH_RWDRIVE
Primitive brush-based vehicle entity.

-------- KEYS --------
"targetname" : Name
"target" : Name of the first path_track/corner (See Notes)
"acceleration" : Acceleration multiplier
"speed" : Top-speed of the vehicle in q-units per second
"height" : Wheel-height in units
"width" : Width of the vehicle, used to calculate the wheels
"length" : Length of the vehicle, used to calculate the wheels
"bouncefactor" : Multiplier for the bouncyness of the vehicle
"skidspeed" : At which speed the vehicle starts skidding
"traction" : Multiplier for the traction affecting the vehicle
"breakfactor" : Multiplier for the breaking mechanics
"steerfactor" : Multiplier for the steering speed
"straightenfactor" : Multiplier for affecting the straightening mechanism
"gravitydir" : Normalized vector setting the direction of gravity

Unimplemented:
"sounds" : A sound-set to use
"volume" : Volume at which said sounds play at (from 0-10)
"dmg" : Damage inflicted upon entities when blocked

-------- SPAWNFLAGS --------
FUNCVEH_NOPITCH : Don't adjust the pitch angle of the vehicle, only point forward.
FUNCVEH_NOUSER : Don't allow pressing "use" key/button to control it.
FUNCVEH_PASSABLE : Don't do collision testing against this entity.
FUNCVEH_FWDRIVE : Front wheel drive mode.
FUNCVEH_RWDRIVE : Rear wheel drive mode.

-------- NOTES --------
The vehicle's position is set via the 'target' key, which sets the first
path_track/corner. The vehicle is then teleported to the 'target' but
it stays at the same vertical position as originally placed.

The angle is calculated by aiming the 'target' path_track/corner entity
to its own 'target' entity. So yes, you need two of these path_track/corner
entities.

-------- TRIVIA --------
This entity was introduced in Counter-Strike (2000).
*/

enumflags
{
	FUNCVEH_NOPITCH,
	FUNCVEH_NOUSER,
	FUNCVEH_UNUSED,
	FUNCVEH_PASSABLE,
	FUNCVEH_FWDRIVE,
	FUNCVEH_RWDRIVE
};

enumflags
{
	FNCVEHNET_DRIVER,
	FNCVEHNET_MODELINDEX,
	FNCVEHNET_ORIGIN,
	FNCVEHNET_ANGLES,
	FNCVEHNET_VELOCITY,
	FNCVEHNET_TURNING,
	FNCVEHNET_SOLIDMOVETYPE,
	FNCVEHNET_FLAGS
};

class
func_vehicle_wheel
{
	void() func_vehicle_wheel;

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

class
func_vehicle:NSVehicle
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
	float m_flUseTime;
	float m_flTimeLength;
	vector m_vecSeatOffest;

	func_vehicle_wheel m_wlFL;
	func_vehicle_wheel m_wlFR;
	func_vehicle_wheel m_wlBL;
	func_vehicle_wheel m_wlBR;
	vector m_vecControlMins;
	vector m_vecControlMaxs;
	float m_flHeight;
	float m_flWidth;
	float m_flLength;

	PREDICTED_FLOAT(m_flTurn);

	void(void) func_vehicle;
	virtual void(void) Spawned;
	virtual void(void) Physics;
	virtual void(void) RunVehiclePhysics;
	virtual void(void) PlayerInput;
	virtual void(void) OnRemoveEntity;

#ifdef CLIENT
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void(float, float) ReceiveEntity;
	virtual void(void) UpdateView;
#else
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(string, string) SpawnKey;
	virtual void(void) Respawn;
	virtual void(void) Realign;
	virtual void(void) OnPlayerUse;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif
};

void
func_vehicle_wheel::func_vehicle_wheel(void)
{
	mins = [-8,-8,-8];
	maxs = [8,8,8];
	hitcontentsmaski = CONTENTBIT_BODY | CONTENTBITS_POINTSOLID | CONTENTBIT_VEHICLECLIP;
}

#ifdef CLIENT
void
func_vehicle_wheel::PredictPreFrame(void)
{
	SAVE_STATE(angles);
	SAVE_STATE(origin);
	SAVE_STATE(velocity);
}

void
func_vehicle_wheel::PredictPostFrame(void)
{
	ROLL_BACK(angles);
	ROLL_BACK(origin);
	ROLL_BACK(velocity);
}
#endif

void
func_vehicle_wheel::Bounce(vector normal)
{
	func_vehicle vehParent;
	vehParent = (func_vehicle)owner;
	velocity -= (velocity * normal) * normal * vehParent.m_flBounceFactor;
}

void
func_vehicle_wheel::Move(float flTimeLength)
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
				trace_endpos[2] += 4;

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
func_vehicle_wheel::Accel(float flMoveTime, float m_flTurn)
{
	func_vehicle vehParent;
	entity eDriver;
	float flTraction;
	vector vecAngle;

	vehParent = (func_vehicle)owner;
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
			velocity -= v_forward * bound(-1, vehParent.m_vecMoveValues[0] / 400, 1) * vehParent.m_flAcceleration * flMoveTime * flTraction;
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
func_vehicle_wheel::Physics(float turnrate, float flTimeLength)
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
func_vehicle::func_vehicle(void)
{
	m_flBounceFactor = 1.0f;
	m_flAcceleration = 200.0f;
	m_flSkidSpeed = 256.0f;
	m_flTraction = 1.0f;
	m_flBreakFactor = 2.0f;
	m_flSteerFactor = 1.0f;
	m_flStraightenFactor = 1.0f;
	m_vecGravityDir = [0,0,-1];
	m_iVehicleFlags |= VHF_FROZEN;
	hitcontentsmaski = CONTENTBIT_BODY | CONTENTBITS_POINTSOLID | CONTENTBIT_VEHICLECLIP;
	m_flWidth = 40;
	m_flLength = 85;
	m_flHeight = 32;

	if (!m_wlFL)
		m_wlFL = spawn(func_vehicle_wheel);
	if (!m_wlFR)
		m_wlFR = spawn(func_vehicle_wheel);
	if (!m_wlBL)
		m_wlBL = spawn(func_vehicle_wheel);
	if (!m_wlBR)
		m_wlBR = spawn(func_vehicle_wheel);

	m_wlFL.owner = m_wlFR.owner = m_wlBL.owner = m_wlBR.owner = this;
	customphysics = Physics;
}

#ifdef CLIENT
void
func_vehicle::UpdateView(void)
{
	if (GetDriver() != __NULL__) {
		PlayerAlign();
	}
}

void
func_vehicle::PredictPreFrame(void)
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
func_vehicle::PredictPostFrame(void)
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
#else

void
func_vehicle::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flBounceFactor", m_flBounceFactor);
	SaveFloat(handle, "m_flAcceleration", m_flAcceleration);
	SaveFloat(handle, "m_flSkidSpeed", m_flSkidSpeed);
	SaveFloat(handle, "m_flTraction", m_flTraction);
	SaveFloat(handle, "m_flBreakFactor", m_flBreakFactor);
	SaveFloat(handle, "m_flSteerFactor", m_flSteerFactor);
	SaveFloat(handle, "m_flStraightenFactor", m_flStraightenFactor);
	SaveVector(handle, "m_vecGravityDir", m_vecGravityDir);
	SaveEntity(handle, "m_wlFL", m_wlFL);
	SaveEntity(handle, "m_wlFR", m_wlFR);
	SaveEntity(handle, "m_wlBL", m_wlBL);
	SaveEntity(handle, "m_wlBR", m_wlBR);
	SaveVector(handle, "m_vecControlMins", m_vecControlMins);
	SaveVector(handle, "m_vecControlMaxs", m_vecControlMaxs);
	SaveFloat(handle, "m_flHeight", m_flHeight);
	SaveFloat(handle, "m_flWidth", m_flWidth);
	SaveFloat(handle, "m_flLength", m_flLength);
	SaveFloat(handle, "m_flTurn", m_flTurn);
}

void
func_vehicle::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flBounceFactor":
		m_flBounceFactor = ReadFloat(strValue);
		break;
	case "m_flAcceleration":
		m_flAcceleration = ReadFloat(strValue);
		break;
	case "m_flSkidSpeed":
		m_flSkidSpeed = ReadFloat(strValue);
		break;
	case "m_flTraction":
		m_flTraction = ReadFloat(strValue);
		break;
	case "m_flBreakFactor":
		m_flBreakFactor = ReadFloat(strValue);
		break;
	case "m_flSteerFactor":
		m_flSteerFactor = ReadFloat(strValue);
		break;
	case "m_flStraightenFactor":
		m_flStraightenFactor = ReadFloat(strValue);
		break;
	case "m_vecGravityDir":
		m_vecGravityDir = ReadVector(strValue);
		break;
	case "m_wlFL":
		m_wlFL = (func_vehicle_wheel)ReadEntity(strValue);
		break;
	case "m_wlFR":
		m_wlFR = (func_vehicle_wheel)ReadEntity(strValue);
		break;
	case "m_wlBL":
		m_wlBL = (func_vehicle_wheel)ReadEntity(strValue);
		break;
	case "m_wlBR":
		m_wlBR = (func_vehicle_wheel)ReadEntity(strValue);
		break;
	case "m_vecControlMins":
		m_vecControlMins = ReadVector(strValue);
		break;
	case "m_vecControlMaxs":
		m_vecControlMaxs = ReadVector(strValue);
		break;
	case "m_flHeight":
		m_flHeight = ReadFloat(strValue);
		break;
	case "m_flWidth":
		m_flWidth = ReadFloat(strValue);
		break;
	case "m_flLength":
		m_flLength = ReadFloat(strValue);
		break;
	case "m_flTurn":
		m_flTurn = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_vehicle::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "acceleration":
		// TODO
		break;
	case "speed":
		m_flAcceleration = stof(strValue);
		break;
	case "height":
		m_flHeight = stof(strValue);
		break;
	case "width":
		m_flWidth = stof(strValue) / 2;
		break;
	case "length":
		m_flLength = stof(strValue) / 2;
		break;
	case "bouncefactor":
		m_flBounceFactor = stof(strValue);
		break;
	case "skidspeed":
		m_flSkidSpeed = stof(strValue);
		break;
	case "traction":
		m_flTraction = stof(strValue);
		break;
	case "breakfactor":
		m_flBreakFactor = stof(strValue);
		break;
	case "steerfactor":
		m_flSteerFactor = stof(strValue);
		break;
	case "straightenfactor":
		m_flStraightenFactor = stof(strValue);
		break;
	case "gravitydir":
		m_vecGravityDir = stov(strValue);
		break;
	case "sounds":
		// TODO
		break;
	case "volume":
		// TODO
		break;
	case "dmg":
		// TODO
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_vehicle::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetAngles([0,0,0]);
	ScheduleThink(Realign, 0.0f);

	m_wlFL.velocity =
	m_wlFR.velocity =
	m_wlBL.velocity =
	m_wlBR.velocity = [0.0f, 0.0f, 0.0f];
	ClearVelocity();

	PlayerUse = OnPlayerUse;

	if (m_eDriver)
		PlayerLeave((NSClientPlayer)m_eDriver);
}

void
func_vehicle::OnPlayerUse(void)
{
	vector matrix;
	vector offs;
	offs = eActivator.origin - origin;

	if (m_flUseTime > time)
		return;

	makevectors(angles);
	matrix[0] = dotproduct(offs, v_forward);
	matrix[1] = -dotproduct(offs, v_right);
	matrix[2] = dotproduct(offs, v_up);

	if not (matrix[0] >= m_vecControlMins[0] && matrix[0] <= m_vecControlMaxs[0])
		return;
	if not (matrix[1] >= m_vecControlMins[1] && matrix[1] <= m_vecControlMaxs[1])
		return;
	if not (matrix[2] >= m_vecControlMins[2] && matrix[2] <= m_vecControlMaxs[2])
		return;

	if (m_eDriver == eActivator) {
		PlayerLeave((NSClientPlayer)eActivator);
	} else if (!m_eDriver) {
		PlayerEnter((NSClientPlayer)eActivator);
	}

	m_flUseTime = time + 2.0f;
}

void
func_vehicle::Realign(void)
{
	entity t;
	entity f;
	NSEntity first, second;
	string strFirst, strSecond;

	first = second = __NULL__;
	t = f = __NULL__;

	for (f = world; (f = find(f, ::target, targetname));) {
		/* we found the right entity */
		if (f.classname == "func_vehiclecontrols") {
			t = f;
		}
	}

	if (t) {
		vector offs;
		offs = t.origin - origin;
		m_vecControlMins = t.mins + offs;
		m_vecControlMaxs = t.maxs + offs;
	}

	/* we rotate and position ourselves after the first path_track/corner */
	strFirst = target;
	for (f = world; (f = find(f, ::targetname, strFirst));) {
		/* we found the right entity */
		if (f.classname == "path_track" || f.classname == "path_corner") {
			first = (NSEntity)f;
		}
	}

	/* now get the second one... */
	strSecond = first.target;
	for (f = world; (f = find(f, ::targetname, strSecond));) {
		/* we found the right entity */
		if (f.classname == "path_track" || f.classname == "path_corner") {
			second = (NSEntity)f;
		}
	}

	if (first && second) {
		vector end_pos;
		first = (NSEntity)first;
		second = (NSEntity)second;
		NSLog("func_vehicle angles were: %v\n", angles);
		angles = vectoangles(first.origin - second.origin);
		NSLog("func_vehicle angles is now: %v\n", angles);

		end_pos = first.origin;
		end_pos[2] = m_oldOrigin[2] + 64;
		setorigin(this, end_pos);
		setorigin(m_wlFR, origin + v_right * m_flWidth + v_forward * m_flLength);
		setorigin(m_wlFL, origin - v_right * m_flWidth + v_forward * m_flLength);
		setorigin(m_wlBR, origin + v_right * m_flWidth - v_forward * m_flLength);
		setorigin(m_wlBL, origin - v_right * m_flWidth - v_forward * m_flLength);
	}
}
#endif

void
func_vehicle::Spawned(void)
{
	super::Spawned();
}

void
func_vehicle::OnRemoveEntity(void)
{
	if (m_wlFL)
		remove(m_wlFL);
	if (m_wlFR)
		remove(m_wlFR);
	if (m_wlBL)
		remove(m_wlBL);
	if (m_wlBR)
		remove(m_wlBR);
}

void
func_vehicle::Physics(void)
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

void
func_vehicle::PlayerInput(void)
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

	//WeaponInput();

	/* only allow use key */
	input_buttons = (input_buttons & INPUT_BUTTON5);

	input_movevalues = [0,0,0];
}

void
func_vehicle::RunVehiclePhysics(void)
{
#ifdef SERVER
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

	angles[0] = Math_FixDelta(angles[0]);
	angles[1] = Math_FixDelta(angles[1]);
	angles[2] = Math_FixDelta(angles[2]);
	angles[0] = bound (-45, angles[0], 45);
	angles[2] = bound (-45, angles[2], 45);

	velocity[0] = bound(-1000, velocity[0], 1000);
	velocity[1] = bound(-1000, velocity[1], 1000);
	velocity[2] = bound(-1000, velocity[2], 1000);

	makevectors(angles);
	setorigin(m_wlFR, origin + v_right * m_flWidth + v_forward * m_flLength);
	setorigin(m_wlFL, origin - v_right * m_flWidth + v_forward * m_flLength);
	setorigin(m_wlBR, origin + v_right * m_flWidth - v_forward * m_flLength);
	setorigin(m_wlBL, origin - v_right * m_flWidth - v_forward * m_flLength);

	m_wlFL.mins[2] = m_flHeight * -1;
	m_wlFR.mins[2] = m_flHeight * -1;
	m_wlBL.mins[2] = m_flHeight * -1;
	m_wlBR.mins[2] = m_flHeight * -1;

	if (HasSpawnFlags(FUNCVEH_FWDRIVE)) {
		m_wlFL.Physics(0, m_flTimeLength);
		m_wlFR.Physics(0, m_flTimeLength);
		m_wlBL.Physics(m_flTurn, m_flTimeLength);
		m_wlBR.Physics(m_flTurn, m_flTimeLength);
	} else if (HasSpawnFlags(FUNCVEH_RWDRIVE)) {
		m_wlFL.Physics(-m_flTurn, m_flTimeLength);
		m_wlFR.Physics(-m_flTurn, m_flTimeLength);
		m_wlBL.Physics(0, m_flTimeLength);
		m_wlBR.Physics(0, m_flTimeLength);
	} else {
		m_wlFL.Physics(-m_flTurn, m_flTimeLength);
		m_wlFR.Physics(-m_flTurn, m_flTimeLength);
		m_wlBL.Physics(m_flTurn, m_flTimeLength);
		m_wlBR.Physics(m_flTurn, m_flTimeLength);
	}

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
	angles = vectoangles(v_forward, v_up);

	angles[0] = Math_FixDelta(angles[0]);
	angles[1] = Math_FixDelta(angles[1]);
	angles[2] = Math_FixDelta(angles[2]);

	/* figure out the new chassis position */
	vector new_origin;
	new_origin = m_wlFL.origin;
	new_origin += m_wlFR.origin;
	new_origin += m_wlBL.origin;
	new_origin += m_wlBR.origin;
	new_origin *= 0.25f;
	SetOrigin(new_origin);
	PlayerAlign();
}

#ifdef CLIENT
void
func_vehicle::ReceiveEntity(float flChanged, float flNew)
{
	if (flChanged & FNCVEHNET_DRIVER) {
		driver_entnum = readentitynum();
		DriverRelink();
	}

	READENTITY_COORD(m_vecPlayerPos[0], FNCVEHNET_DRIVER)
	READENTITY_COORD(m_vecPlayerPos[1], FNCVEHNET_DRIVER)
	READENTITY_COORD(m_vecPlayerPos[2], FNCVEHNET_DRIVER)

	READENTITY_SHORT(modelindex, FNCVEHNET_MODELINDEX)
	READENTITY_FLOAT(m_vecSeatOffest[0], FNCVEHNET_MODELINDEX)
	READENTITY_FLOAT(m_vecSeatOffest[1], FNCVEHNET_MODELINDEX)
	READENTITY_FLOAT(m_vecSeatOffest[2], FNCVEHNET_MODELINDEX)

	READENTITY_FLOAT(m_flWidth, FNCVEHNET_MODELINDEX)
	READENTITY_FLOAT(m_flLength, FNCVEHNET_MODELINDEX)
	READENTITY_COORD(origin[0], FNCVEHNET_ORIGIN)
	READENTITY_COORD(origin[1], FNCVEHNET_ORIGIN)
	READENTITY_COORD(origin[2], FNCVEHNET_ORIGIN)
	READENTITY_ANGLE(angles[0], FNCVEHNET_ANGLES)
	READENTITY_ANGLE(angles[1], FNCVEHNET_ANGLES)
	READENTITY_ANGLE(angles[2], FNCVEHNET_ANGLES)
	READENTITY_COORD(velocity[0], FNCVEHNET_VELOCITY)
	READENTITY_COORD(velocity[1], FNCVEHNET_VELOCITY)
	READENTITY_COORD(velocity[2], FNCVEHNET_VELOCITY)
	READENTITY_INT(flags, FNCVEHNET_FLAGS)
	READENTITY_BYTE(solid, FNCVEHNET_SOLIDMOVETYPE)
	READENTITY_BYTE(movetype, FNCVEHNET_SOLIDMOVETYPE)
	READENTITY_INT(flags, FNCVEHNET_SOLIDMOVETYPE)
	READENTITY_COORD(mins[0], FNCVEHNET_SOLIDMOVETYPE)
	READENTITY_COORD(mins[1], FNCVEHNET_SOLIDMOVETYPE)
	READENTITY_COORD(mins[2], FNCVEHNET_SOLIDMOVETYPE)
	READENTITY_COORD(maxs[0], FNCVEHNET_SOLIDMOVETYPE)
	READENTITY_COORD(maxs[1], FNCVEHNET_SOLIDMOVETYPE)
	READENTITY_COORD(maxs[2], FNCVEHNET_SOLIDMOVETYPE)

	if (flChanged & FNCVEHNET_SOLIDMOVETYPE)
		setsize(this, mins, maxs);

	if (flChanged & FNCVEHNET_DRIVER) {
		DriverRelink();
	}

	if (flChanged & FNCVEHNET_MODELINDEX) {
		//setsize( this, [-50,-50,0], [50,50,64]);
	}

	if (flChanged & FNCVEHNET_ORIGIN) {
		setorigin(this, origin);
		makevectors(angles);
		setorigin(m_wlFR, origin + v_right * m_flWidth + v_forward * m_flLength);
		setorigin(m_wlFL, origin - v_right * m_flWidth + v_forward * m_flLength);
		setorigin(m_wlBR, origin + v_right * m_flWidth - v_forward * m_flLength);
		setorigin(m_wlBL, origin - v_right * m_flWidth - v_forward * m_flLength);
	}

	if (flNew) {
		drawmask = MASK_ENGINE;
		SetMovetype(MOVETYPE_NONE);
		SetSolid(SOLID_BSP);

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
func_vehicle::EvaluateEntity(void)
{
	EVALUATE_FIELD(m_eDriver, FNCVEHNET_DRIVER)
	EVALUATE_FIELD(modelindex, FNCVEHNET_MODELINDEX)
	EVALUATE_FIELD(origin, FNCVEHNET_ORIGIN)
	EVALUATE_FIELD(angles, FNCVEHNET_ANGLES)
	EVALUATE_FIELD(velocity, FNCVEHNET_VELOCITY)
	EVALUATE_FIELD(m_flTurn, FNCVEHNET_TURNING)
	EVALUATE_FIELD(flags, FNCVEHNET_FLAGS)
	EVALUATE_FIELD(solid, FNCVEHNET_SOLIDMOVETYPE)
	EVALUATE_FIELD(movetype, FNCVEHNET_SOLIDMOVETYPE)
	EVALUATE_FIELD(mins, FNCVEHNET_SOLIDMOVETYPE)
	EVALUATE_FIELD(maxs, FNCVEHNET_SOLIDMOVETYPE)
}

float
func_vehicle::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_VEH_BRUSH);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_ENTITY(m_eDriver, FNCVEHNET_DRIVER)
	SENDENTITY_COORD(m_vecPlayerPos[0], FNCVEHNET_DRIVER)
	SENDENTITY_COORD(m_vecPlayerPos[1], FNCVEHNET_DRIVER)
	SENDENTITY_COORD(m_vecPlayerPos[2], FNCVEHNET_DRIVER)
	SENDENTITY_SHORT(modelindex, FNCVEHNET_MODELINDEX)
	SENDENTITY_FLOAT(m_vecSeatOffest[0], FNCVEHNET_MODELINDEX)
	SENDENTITY_FLOAT(m_vecSeatOffest[1], FNCVEHNET_MODELINDEX)
	SENDENTITY_FLOAT(m_vecSeatOffest[2], FNCVEHNET_MODELINDEX)
	SENDENTITY_FLOAT(m_flWidth, FNCVEHNET_MODELINDEX)
	SENDENTITY_FLOAT(m_flLength, FNCVEHNET_MODELINDEX)
	SENDENTITY_COORD(origin[0], FNCVEHNET_ORIGIN)
	SENDENTITY_COORD(origin[1], FNCVEHNET_ORIGIN)
	SENDENTITY_COORD(origin[2], FNCVEHNET_ORIGIN)
	SENDENTITY_ANGLE(angles[0], FNCVEHNET_ANGLES)
	SENDENTITY_ANGLE(angles[1], FNCVEHNET_ANGLES)
	SENDENTITY_ANGLE(angles[2], FNCVEHNET_ANGLES)
	SENDENTITY_COORD(velocity[0], FNCVEHNET_VELOCITY)
	SENDENTITY_COORD(velocity[1], FNCVEHNET_VELOCITY)
	SENDENTITY_COORD(velocity[2], FNCVEHNET_VELOCITY)
	SENDENTITY_INT(flags, FNCVEHNET_FLAGS)
	SENDENTITY_BYTE(solid, FNCVEHNET_SOLIDMOVETYPE)
	SENDENTITY_BYTE(movetype, FNCVEHNET_SOLIDMOVETYPE)
	SENDENTITY_INT(flags, FNCVEHNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(mins[0], FNCVEHNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(mins[1], FNCVEHNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(mins[2], FNCVEHNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(maxs[0], FNCVEHNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(maxs[1], FNCVEHNET_SOLIDMOVETYPE)
	SENDENTITY_COORD(maxs[2], FNCVEHNET_SOLIDMOVETYPE)


	return true;
}
#endif

#ifdef CLIENT
void
func_vehicle_readentity(float isnew)
{
	func_vehicle veh = (func_vehicle)self;
	float flags = readfloat();

	if (isnew)
		spawnfunc_func_vehicle();

	veh.ReceiveEntity(flags, isnew);
}
#endif