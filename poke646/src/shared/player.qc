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
	int bradnailer_mag; int bradnailer_mag_net;
	int nailgun_mag; int nailgun_mag_net;
	int shotgun_mag; int shotgun_mag_net;
	int cmlwbr_mag; int cmlwbr_mag_net;
	int xs_mag; int xs_mag_net;
	int satchel_chg; int satchel_chg_net;

	int ammo_nail; int ammo_nail_net;
	int ammo_buckshot; int ammo_buckshot_net;
	int ammo_bolts; int ammo_bolts_net;
	int ammo_xencandy; int ammo_xencandy_net;
	int ammo_satchel; int ammo_satchel_net;

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
		bradnailer_mag = readbyte();
		nailgun_mag = readbyte();
		shotgun_mag = readbyte();
		cmlwbr_mag = readbyte();
		xs_mag = readbyte();
		satchel_chg = readbyte();
	}
	
	if (fl & PLAYER_AMMO2) {
		ammo_nail = readbyte();
		ammo_buckshot = readbyte();
		ammo_bolts = readbyte();
		ammo_xencandy = readbyte();
		ammo_satchel = readbyte();
	}

	if (fl & PLAYER_AMMO3) {
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
	bradnailer_mag_net = bradnailer_mag;
	nailgun_mag_net = nailgun_mag;
	shotgun_mag_net = shotgun_mag;
	cmlwbr_mag_net = cmlwbr_mag;
	xs_mag_net = xs_mag;
	satchel_chg_net = satchel_chg;

	ammo_nail_net = ammo_nail;
	ammo_buckshot_net = ammo_buckshot;
	ammo_bolts_net = ammo_bolts;
	ammo_xencandy_net = ammo_xencandy;
	ammo_satchel_net = ammo_satchel;
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
	bradnailer_mag = bradnailer_mag_net;
	nailgun_mag = nailgun_mag_net;
	shotgun_mag = shotgun_mag_net;
	cmlwbr_mag = cmlwbr_mag_net;
	xs_mag = xs_mag_net;
	satchel_chg = satchel_chg_net;

	ammo_nail = ammo_nail_net;
	ammo_buckshot = ammo_buckshot_net;
	ammo_bolts = ammo_bolts_net;
	ammo_xencandy = ammo_xencandy_net;
	ammo_satchel = ammo_satchel_net;
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

	if (bradnailer_mag_net != bradnailer_mag)
		SendFlags |= PLAYER_AMMO1;
	if (nailgun_mag_net != nailgun_mag)
		SendFlags |= PLAYER_AMMO1;
	if (shotgun_mag_net != shotgun_mag)
		SendFlags |= PLAYER_AMMO1;
	if (cmlwbr_mag_net != cmlwbr_mag)
		SendFlags |= PLAYER_AMMO1;
	if (xs_mag_net != xs_mag)
		SendFlags |= PLAYER_AMMO1;
	if (satchel_chg_net != satchel_chg)
		SendFlags |= PLAYER_AMMO1;

	if (ammo_nail_net != ammo_nail)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_buckshot_net != ammo_buckshot)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_bolts_net != ammo_bolts)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_xencandy_net != ammo_xencandy)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_satchel_net != ammo_satchel)
		SendFlags |= PLAYER_AMMO2;
	
	bradnailer_mag_net = bradnailer_mag;
	nailgun_mag_net = nailgun_mag;
	shotgun_mag_net = shotgun_mag;
	cmlwbr_mag_net = cmlwbr_mag;
	xs_mag_net = xs_mag;
	satchel_chg_net = satchel_chg;

	ammo_nail_net = ammo_nail;
	ammo_buckshot_net = ammo_buckshot;
	ammo_bolts_net = ammo_bolts;
	ammo_xencandy_net = ammo_xencandy;
	ammo_satchel_net = ammo_satchel;
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
		WriteByte(MSG_ENTITY, bradnailer_mag);
		WriteByte(MSG_ENTITY, nailgun_mag);
		WriteByte(MSG_ENTITY, shotgun_mag);
		WriteByte(MSG_ENTITY, cmlwbr_mag);
		WriteByte(MSG_ENTITY, xs_mag);
		WriteByte(MSG_ENTITY, satchel_chg);
	}
	
	if (fChanged & PLAYER_AMMO2) {
		WriteByte(MSG_ENTITY, ammo_nail);
		WriteByte(MSG_ENTITY, ammo_buckshot);
		WriteByte(MSG_ENTITY, ammo_bolts);
		WriteByte(MSG_ENTITY, ammo_xencandy);
		WriteByte(MSG_ENTITY, ammo_satchel);
	}

	if (fChanged & PLAYER_AMMO3) {
	}

	return TRUE;
}
#endif
