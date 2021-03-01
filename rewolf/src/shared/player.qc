/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_KEEPALIVE,
	PLAYER_MODELINDEX,
	PLAYER_ORIGIN,
	PLAYER_ORIGIN_Z,
	PLAYER_ANGLES_X,
	PLAYER_ANGLES_Y,
	PLAYER_ANGLES_Z,
	PLAYER_VELOCITY,
	PLAYER_VELOCITY_Z,
	PLAYER_FLAGS,
	PLAYER_WEAPON,
	PLAYER_ITEMS,
	PLAYER_HEALTH,
	PLAYER_ARMOR,
	PLAYER_MOVETYPE,
	PLAYER_VIEWOFS,
	PLAYER_BASEFRAME,
	PLAYER_FRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED1,
	PLAYER_UNUSED2
};

noref int input_sequence;
class player:base_player
{
	/* Weapon specific */
	int ammo_battery; int ammo_battery_net; // beamgun
	int ammo_chem; int ammo_chem_net; // chemicalgun
	int ammo_rocket; int ammo_rocket_net; // dml / grenades
	int ammo_gauss; int ammo_gauss_net; // gauspistol
	int ammo_minigun; int ammo_minigun_net; // minigun
	int ammo_buckshot; int ammo_buckshot_net; // shotgun
	int fist_mode; int fist_mode_net; // knife/fists
	int gauss_mode; int gauss_mode_net;
	int shotgun_shells; int shotgun_shells_net;
	int shotgun_spread; int shotgun_spread_net;
	
	int dml_launch; int dml_launch_net; /* when fired, when targeted */
	int dml_flightpath; int dml_flightpath_net; /* guided, homing, spiral */
	int dml_detonate; int dml_detonate_net; /* on impact, in proximity, timed, when tripped */
	int dml_payload; int dml_payload_net; /* explosive, cluster */
	int chem_acid; int chem_acid_net;
	int chem_neutral; int chem_neutral_net;
	int chem_base; int chem_base_net;
	int chem_pressure; int chem_pressure_net;

	int beam_range; int beam_range_net; /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
	int beam_poweracc; int beam_poweracc_net; /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
	int beam_lightning; int beam_lightning_net; /* BEAM, CHAIN, BALL */
	int gren_detonate; int gren_detonate_net; /* when tripped (tripmine), timed, on impact */
	int gren_payload; int gren_payload_net; /* cluster, explosive */

	int menu_active; int menu_active_net;
	int dml_state; int dml_state_net;

#ifdef CLIENT
	/* External model */
	entity p_model;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;

	virtual void(void) gun_offset;
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
	virtual void(float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#else
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif
};

#ifdef CLIENT
void Weapons_AmmoUpdate(entity);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new)
{
	float fl;
	if (new == FALSE) {
		/* Go through all the physics code between the last received frame
		 * and the newest frame and keep the changes this time around instead
		 * of rolling back, because we'll apply the new server-verified values
		 * right after anyway. */
		/* FIXME: splitscreen */
		if (entnum == player_localentnum) {
			/* FIXME: splitscreen */
			pSeat = &g_seats[0];

			for (int i = sequence+1; i <= servercommandframe; i++) {
				/* ...maybe the input state is too old? */
				if (!getinputstate(i)) {
					break;
				}
				input_sequence = i;
				PMove_Run();
			}

			/* any differences in things that are read below are now
			 * officially from prediction misses. */
		}
	}

	/* seed for our prediction table */
	sequence = servercommandframe;

	fl = readfloat();

	/* HACK: we need to make this more reliable */
	if (fl == UPDATE_ALL) {
		/* we respawned */
		gravity = __NULL__;
	}

	if (fl & PLAYER_MODELINDEX)
		modelindex = readshort();

	if (fl & PLAYER_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
	}

	if (fl & PLAYER_ORIGIN_Z)
		origin[2] = readcoord();
	if (fl & PLAYER_ANGLES_X)
		pitch = readfloat();
	if (fl & PLAYER_ANGLES_Y)
		angles[1] = readfloat();
	if (fl & PLAYER_ANGLES_Z)
		angles[2] = readfloat();

	if (fl & PLAYER_VELOCITY) {
		velocity[0] = readcoord();
		velocity[1] = readcoord();
	}

	if (fl & PLAYER_VELOCITY_Z)
		velocity[2] = readcoord();
	if (fl & PLAYER_FLAGS) {
		flags = readfloat();
		gflags = readfloat();
	}
	if (fl & PLAYER_WEAPON)
		activeweapon = readbyte();
	if (fl & PLAYER_ITEMS)
		g_items = (__variant)readfloat();
	if (fl & PLAYER_HEALTH)
		health = readbyte();
	if (fl & PLAYER_ARMOR)
		armor = readbyte();
	if (fl & PLAYER_MOVETYPE)
		movetype = readbyte();
	if (fl & PLAYER_VIEWOFS)
		view_ofs[2] = readfloat();
	if (fl & PLAYER_BASEFRAME)
		baseframe = readbyte();
	if (fl & PLAYER_FRAME) {
		frame = readbyte();
		frame1time = 0.0f;
		frame2time = 0.0f;
	}

	if (fl & PLAYER_AMMO1) {
		ammo_battery = readbyte();
		ammo_chem = readbyte();
		ammo_rocket = readbyte();
		ammo_gauss = readbyte();
		ammo_minigun = readbyte();
		ammo_buckshot = readbyte();
		fist_mode = readbyte();
		gauss_mode = readbyte();
		shotgun_shells = readbyte();
		shotgun_spread = readbyte();
	}
	
	if (fl & PLAYER_AMMO2) {
		dml_launch = readbyte();
		dml_flightpath = readbyte();
		dml_detonate = readbyte();
		dml_payload = readbyte();
		chem_acid = readbyte();
		chem_neutral = readbyte();
		chem_base = readbyte();
		chem_pressure = readbyte();
	}

	if (fl & PLAYER_AMMO3) {
		beam_range = readbyte();
		beam_poweracc = readbyte();
		beam_lightning = readbyte();
		gren_detonate = readbyte();
		gren_payload = readbyte();
		menu_active = readbyte();
		dml_state = readbyte();
	}

	if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3)
		Weapons_AmmoUpdate(this);

	setorigin(this, origin);
}

/*
=================
player::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
player::PredictPreFrame(void)
{
	ammo_battery_net = ammo_battery; // beamgun
	ammo_chem_net = ammo_chem; // chemicalgun
	ammo_rocket_net = ammo_rocket; // dml / grenades
	ammo_gauss_net = ammo_gauss; // gauspistol
	ammo_minigun_net = ammo_minigun; // minigun
	ammo_buckshot_net = ammo_buckshot; // shotgun
	fist_mode_net = fist_mode; // knife/fists
	gauss_mode_net = gauss_mode;
	shotgun_shells_net = shotgun_shells;
	shotgun_spread_net = shotgun_spread;
	
	dml_launch_net = dml_launch; /* when fired, when targeted */
	dml_flightpath_net = dml_flightpath; /* guided, homing, spiral */
	dml_detonate_net = dml_detonate; /* on impact, in proximity, timed, when tripped */
	dml_payload_net = dml_payload; /* explosive, cluster */
	chem_acid_net = chem_acid;
	chem_neutral_net = chem_neutral;
	chem_base_net = chem_base;
	chem_pressure_net = chem_pressure;

	beam_range_net = beam_range; /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
	beam_poweracc_net = beam_poweracc; /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
	beam_lightning_net = beam_lightning; /* BEAM, CHAIN, BALL */
	gren_detonate_net = gren_detonate; /* when tripped (tripmine), timed, on impact */
	gren_payload_net = gren_payload; /* cluster, explosive */
	menu_active_net = menu_active;
	dml_state_net = dml_state;
}

/*
=================
player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
player::PredictPostFrame(void)
{
	ammo_battery = ammo_battery_net; // beamgun
	ammo_chem = ammo_chem_net; // chemicalgun
	ammo_rocket = ammo_rocket_net; // dml / grenades
	ammo_gauss = ammo_gauss_net; // gauspistol
	ammo_minigun = ammo_minigun_net; // minigun
	ammo_buckshot = ammo_buckshot_net; // shotgun
	fist_mode = fist_mode_net; // knife/fists
	gauss_mode = gauss_mode_net;
	shotgun_shells = shotgun_shells_net;
	shotgun_spread = shotgun_spread_net;
	
	dml_launch = dml_launch_net; /* when fired, when targeted */
	dml_flightpath = dml_flightpath_net; /* guided, homing, spiral */
	dml_detonate = dml_detonate_net; /* on impact, in proximity, timed, when tripped */
	dml_payload = dml_payload_net; /* explosive, cluster */
	chem_acid = chem_acid_net;
	chem_neutral = chem_neutral_net;
	chem_base = chem_base_net;
	chem_pressure = chem_pressure_net;

	beam_range = beam_range_net; /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
	beam_poweracc = beam_poweracc_net; /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
	beam_lightning = beam_lightning_net; /* BEAM, CHAIN, BALL */
	gren_detonate = gren_detonate_net; /* when tripped (tripmine), timed, on impact */
	gren_payload = gren_payload_net; /* cluster, explosive */
	menu_active = menu_active_net;
}

#else
void
player::EvaluateEntity(void)
{
	SendFlags |= PLAYER_KEEPALIVE;

	if (old_modelindex != modelindex)
		SendFlags |= PLAYER_MODELINDEX;

	if (old_origin[0] != origin[0])
		SendFlags |= PLAYER_ORIGIN;

	if (old_origin[1] != origin[1])
		SendFlags |= PLAYER_ORIGIN;

	if (old_origin[2] != origin[2])
		SendFlags |= PLAYER_ORIGIN_Z;

	if (old_angles[0] != v_angle[0])
		SendFlags |= PLAYER_ANGLES_X;

	if (old_angles[1] != angles[1])
		SendFlags |= PLAYER_ANGLES_Y;

	if (old_angles[2] != angles[2])
		SendFlags |= PLAYER_ANGLES_Z;

	if (old_velocity[0] != velocity[0])
		SendFlags |= PLAYER_VELOCITY;

	if (old_velocity[1] != velocity[1])
		SendFlags |= PLAYER_VELOCITY;

	if (old_velocity[2] != velocity[2])
		SendFlags |= PLAYER_VELOCITY_Z;

	if (old_flags != flags)
		SendFlags |= PLAYER_FLAGS;

	if (old_gflags != gflags)
		SendFlags |= PLAYER_FLAGS;

	if (old_activeweapon != activeweapon)
		SendFlags |= PLAYER_WEAPON;

	if (old_items != g_items)
		SendFlags |= PLAYER_ITEMS;

	if (old_health != health)
		SendFlags |= PLAYER_HEALTH;

	if (old_armor != armor)
		SendFlags |= PLAYER_ARMOR;

	if (old_movetype != movetype)
		SendFlags |= PLAYER_MOVETYPE;

	if (old_viewofs != view_ofs[2])
		SendFlags |= PLAYER_VIEWOFS;

	if (old_baseframe != baseframe)
		SendFlags |= PLAYER_BASEFRAME;

	if (old_frame != frame)
		SendFlags |= PLAYER_FRAME;

	/* ammo 1 type updates */
 	if (ammo_battery_net == ammo_battery)
		SendFlags |= PLAYER_AMMO1;
 	if (ammo_chem_net == ammo_chem)
		SendFlags |= PLAYER_AMMO1;
 	if (ammo_rocket_net == ammo_rocket)
		SendFlags |= PLAYER_AMMO1;
 	if (ammo_gauss_net == ammo_gauss)
		SendFlags |= PLAYER_AMMO1;
 	if (ammo_minigun_net == ammo_minigun)
		SendFlags |= PLAYER_AMMO1;
 	if (ammo_buckshot_net == ammo_buckshot)
		SendFlags |= PLAYER_AMMO1;
 	if (fist_mode_net == fist_mode)
		SendFlags |= PLAYER_AMMO1;
 	if (gauss_mode_net == gauss_mode)
		SendFlags |= PLAYER_AMMO1;
 	if (shotgun_shells_net == shotgun_shells)
		SendFlags |= PLAYER_AMMO1;
 	if (shotgun_spread_net == shotgun_spread)
		SendFlags |= PLAYER_AMMO1;

 	if (dml_launch_net == dml_launch)
		SendFlags |= PLAYER_AMMO2;
 	if (dml_flightpath_net == dml_flightpath)
		SendFlags |= PLAYER_AMMO2;
 	if (dml_detonate_net == dml_detonate)
		SendFlags |= PLAYER_AMMO2;
 	if (dml_payload_net == dml_payload)
		SendFlags |= PLAYER_AMMO2;
 	if (chem_acid_net == chem_acid)
		SendFlags |= PLAYER_AMMO2;
 	if (chem_neutral_net == chem_neutral)
		SendFlags |= PLAYER_AMMO2;
 	if (chem_base_net == chem_base)
		SendFlags |= PLAYER_AMMO2;
 	if (chem_pressure_net == chem_pressure)
		SendFlags |= PLAYER_AMMO2;

 	if (beam_range_net == beam_range)
		SendFlags |= PLAYER_AMMO3;
 	if (beam_poweracc_net == beam_poweracc)
		SendFlags |= PLAYER_AMMO3;
 	if (beam_lightning_net == beam_lightning)
		SendFlags |= PLAYER_AMMO3;
 	if (gren_detonate_net == gren_detonate)
		SendFlags |= PLAYER_AMMO3;
 	if (gren_payload_net == gren_payload)
		SendFlags |= PLAYER_AMMO3;
 	if (menu_active_net == menu_active)
		SendFlags |= PLAYER_AMMO3;
	if (dml_state_net == dml_state)
		SendFlags |= PLAYER_AMMO3;

	old_modelindex = modelindex;
	old_origin = origin;
	old_angles = angles;
	old_angles[0] = v_angle[0];
	old_velocity = velocity;
	old_flags = flags;
	old_gflags = gflags;
	old_activeweapon = activeweapon;
	old_items = g_items;
	old_health = health;
	old_armor = armor;
	old_movetype = movetype;
	old_viewofs = view_ofs[2];
	old_baseframe = baseframe;
	old_frame = frame;

	ammo_battery_net = ammo_battery;
	ammo_chem_net = ammo_chem;
	ammo_rocket_net = ammo_rocket;
	ammo_gauss_net = ammo_gauss;
	ammo_minigun_net = ammo_minigun;
	ammo_buckshot_net = ammo_buckshot;
	fist_mode_net = fist_mode;
	gauss_mode_net = gauss_mode;
	shotgun_shells_net = shotgun_shells;
	shotgun_spread_net = shotgun_spread;
	
	dml_launch_net = dml_launch;
	dml_flightpath_net = dml_flightpath;
	dml_detonate_net = dml_detonate;
	dml_payload_net = dml_payload;
	chem_acid_net = chem_acid;
	chem_neutral_net = chem_neutral;
	chem_base_net = chem_base;
	chem_pressure_net = chem_pressure;

	beam_range_net = beam_range;
	beam_poweracc_net = beam_poweracc;
	beam_lightning_net = beam_lightning;
	gren_detonate_net = gren_detonate;
	gren_payload_net = gren_payload;
	menu_active_net = menu_active;
	dml_state_net = dml_state;
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float fChanged)
{
	if (health <= 0 && ePEnt != this) {
		return FALSE;
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return FALSE;
	}

	if (ePEnt != self) {
		fChanged &= ~PLAYER_ITEMS;
		fChanged &= ~PLAYER_HEALTH;
		fChanged &= ~PLAYER_ARMOR;
		fChanged &= ~PLAYER_VIEWOFS;
		fChanged &= ~PLAYER_AMMO1;
		fChanged &= ~PLAYER_AMMO2;
		fChanged &= ~PLAYER_AMMO3;
	}

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, fChanged);

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & PLAYER_MODELINDEX)
		WriteShort(MSG_ENTITY, modelindex);
	if (fChanged & PLAYER_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
	}
	if (fChanged & PLAYER_ORIGIN_Z)
		WriteCoord(MSG_ENTITY, origin[2]);
	if (fChanged & PLAYER_ANGLES_X)
		WriteFloat(MSG_ENTITY, v_angle[0]);
	if (fChanged & PLAYER_ANGLES_Y)
		WriteFloat(MSG_ENTITY, angles[1]);
	if (fChanged & PLAYER_ANGLES_Z)
		WriteFloat(MSG_ENTITY, angles[2]);
	if (fChanged & PLAYER_VELOCITY) {
		WriteCoord(MSG_ENTITY, velocity[0]);
		WriteCoord(MSG_ENTITY, velocity[1]);
	}
	if (fChanged & PLAYER_VELOCITY_Z)
		WriteCoord(MSG_ENTITY, velocity[2]);
	if (fChanged & PLAYER_FLAGS) {
		WriteFloat(MSG_ENTITY, flags);
		WriteFloat(MSG_ENTITY, gflags);
	}
	if (fChanged & PLAYER_WEAPON)
		WriteByte(MSG_ENTITY, activeweapon);
	if (fChanged & PLAYER_ITEMS)
		WriteFloat(MSG_ENTITY, (__variant)g_items);
	if (fChanged & PLAYER_HEALTH)
		WriteByte(MSG_ENTITY, bound(0, health, 255));
	if (fChanged & PLAYER_ARMOR)
		WriteByte(MSG_ENTITY, armor);
	if (fChanged & PLAYER_MOVETYPE)
		WriteByte(MSG_ENTITY, movetype);
	if (fChanged & PLAYER_VIEWOFS)
		WriteFloat(MSG_ENTITY, view_ofs[2]);
	if (fChanged & PLAYER_BASEFRAME)
		WriteByte(MSG_ENTITY, baseframe);
	if (fChanged & PLAYER_FRAME)
		WriteByte(MSG_ENTITY, frame);

	if (fChanged & PLAYER_AMMO1) {
		WriteByte(MSG_ENTITY, ammo_battery);
		WriteByte(MSG_ENTITY, ammo_chem);
		WriteByte(MSG_ENTITY, ammo_rocket);
		WriteByte(MSG_ENTITY, ammo_gauss);
		WriteByte(MSG_ENTITY, ammo_minigun);
		WriteByte(MSG_ENTITY, ammo_buckshot);
		WriteByte(MSG_ENTITY, fist_mode);
		WriteByte(MSG_ENTITY, gauss_mode);
		WriteByte(MSG_ENTITY, shotgun_shells);
		WriteByte(MSG_ENTITY, shotgun_spread);
	}
	
	if (fChanged & PLAYER_AMMO2) {
		WriteByte(MSG_ENTITY, dml_launch);
		WriteByte(MSG_ENTITY, dml_flightpath);
		WriteByte(MSG_ENTITY, dml_detonate);
		WriteByte(MSG_ENTITY, dml_payload);
		WriteByte(MSG_ENTITY, chem_acid);
		WriteByte(MSG_ENTITY, chem_neutral);
		WriteByte(MSG_ENTITY, chem_base);
		WriteByte(MSG_ENTITY, chem_pressure);
	}

	if (fChanged & PLAYER_AMMO3) {
		WriteByte(MSG_ENTITY, beam_range);
		WriteByte(MSG_ENTITY, beam_poweracc);
		WriteByte(MSG_ENTITY, beam_lightning);
		WriteByte(MSG_ENTITY, gren_detonate);
		WriteByte(MSG_ENTITY, gren_payload);
		WriteByte(MSG_ENTITY, menu_active);
		WriteByte(MSG_ENTITY, dml_state);
	}

	return TRUE;
}
#endif
