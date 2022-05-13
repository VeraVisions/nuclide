/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

bool
NSClientPlayer::IsRealSpectator(void)
{
	return (false);
}

bool
NSClientPlayer::IsDead(void)
{
	if (health > 0)
		return (false);
	else
		return (true);
}

bool
NSClientPlayer::IsPlayer(void)
{
	return (false);
}

bool
NSClientPlayer::IsFakeSpectator(void)
{
	if (GetFlags() & FL_FAKESPEC)
		return (true);

	return (false);
}

void
NSClientPlayer::PreFrame(void)
{
#ifdef CLIENT
	/* this is where a game/mod would decide to add more prediction rollback
	 * information. */
	PredictPreFrame();

	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;
		veh.PredictPreFrame();
	}

	/* run physics code for all the input frames which we've not heard back
	 * from yet. This continues on in Player_ReceiveEntity! */
	for (int i = sequence + 1; i <= clientcommandframe; i++) {
		float flSuccess = getinputstate(i);
		if (flSuccess == FALSE) {
			continue;
		}

		/* don't do partial frames, aka incomplete input packets */
		if (input_timelength == 0) {
			break;
		}

		if (i==clientcommandframe){
			CSQC_Input_Frame();
		}

		/* this global is for our shared random number seed */
		input_sequence = i;

		/* run our custom physics */
		Physics_Run();
	}
#endif
}
void
NSClientPlayer::PostFrame(void)
{
#ifdef CLIENT
	/* give the game/mod a chance to roll back its values too */
	PredictPostFrame();
	setorigin(this, origin);  /* update bounds */

	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;
		veh.PredictPostFrame();
		setorigin(veh, veh.origin);
	}
#endif
}


void
NSClientPlayer::ClientInput(void)
{
	XR_InputFrame(this);

	if (!Client_InIntermission() && IsFakeSpectator()) {
		NSClientSpectator::ClientInput();
		SpectatorTrackPlayer();
		return;
	}

	/* allow vehicles to prevent weapon logic from happening */
	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh.PlayerInput)
			veh.PlayerInput();
	}

	/* weapon/item logic of what the player controls */
	Game_Input((player)this);
}

#ifdef CLIENT
void
NSClientPlayer::VehicleRelink(void)
{
	if (!vehicle_entnum)
		vehicle = __NULL__;
	else
		vehicle = findentity(world, ::entnum, vehicle_entnum);
}

void
NSClientPlayer::OnRemoveEntity(void)
{
	if (p_model)
		remove(p_model);

	super::OnRemoveEntity();
}

/*
=================
NSClientPlayer::ClientInputFrame

This is basically CSQC_Input_Frame! So games can override this as they please.
=================
*/
void
NSClientPlayer::ClientInputFrame(void)
{
	if (IsFakeSpectator()) {
		NSClientSpectator::ClientInputFrame();
		return;
	}

	/* If we are inside a VGUI, don't let the client do stuff outside */
	if (VGUI_Active()) {
		input_impulse = 0;
		input_buttons = 0;
		return;
	}

	/* background maps have no input */
	if (serverkeyfloat("background") == 1)
		return;

	if (pSeat->m_iInputAttack2 == TRUE) {
		input_buttons |= INPUT_BUTTON3;
	}

	if (pSeat->m_iInputReload == TRUE) {
		input_buttons |= INPUT_BUTTON4;
	}

	if (pSeat->m_iInputUse == TRUE) {
		input_buttons |= INPUT_BUTTON5;
	}

	if (pSeat->m_iInputDuck == TRUE) {
		input_buttons |= INPUT_BUTTON8;
	}

	/* The HUD needs more time */
	if (pSeat->m_iHUDWeaponSelected) {
		if ((input_buttons & INPUT_BUTTON0))
			HUD_DrawWeaponSelect_Trigger();
		else if ((input_buttons & INPUT_BUTTON3))
			pSeat->m_iHUDWeaponSelected = pSeat->m_flHUDWeaponSelectTime = 0;

		pSeat->m_flInputBlockTime = time + 0.2;
	}

	/* prevent accidental input packets */
	if (pSeat->m_flInputBlockTime > time) {
		input_buttons &= ~INPUT_BUTTON0;
		input_buttons &= ~INPUT_BUTTON3;
		pSeat->m_iInputAttack2 = FALSE;
		return;
	}

	/* some input overrides for XR */
	if (XR_Available(this)) {
		if (pSeat->m_bMoveForward) {
			input_movevalues[0] = 100;
		}

		if (pSeat->m_iInputAttack) {
			input_buttons |= INPUT_BUTTON0;
		}
	}

	/* compat*/
	if (input_impulse == 201) {
		sendevent("Spraylogo", "");
	}

	if (pSeat->m_flCameraTime > time) {
		/* TODO: Supress the changing of view_angles/input_angles. */
	}
}

/*
=================
NSClientPlayer::ReceiveEntity

Receive the generic client attributes from the server.
If you want to override this, do not call this
at the top of player::ReceiveEntity
=================
*/
void
NSClientPlayer::ReceiveEntity(float new, float fl)
{
	/* store which input sequence we're on, this helps us
	 * later when we run prediction again between last/latest
	 * servercommandframe */
	sequence = servercommandframe;

	/* HACK: we need to make this more reliable */
	if (fl == UPDATE_ALL) {
		/* we respawned */
		gravity = 1.0f;
	}

	if (fl & PLAYER_MODELINDEX) {
		modelindex = readshort();
	}

	if (fl & PLAYER_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
	}

	if (fl & PLAYER_ORIGIN_Z)
		origin[2] = readcoord();
	if (fl & PLAYER_ANGLES_X) {
		v_angle[0] = readshort() / (32767 / 360);
		v_angle[1] = readshort() / (32767 / 360);
		v_angle[2] = readshort() / (32767 / 360);
	}
	if (fl & PLAYER_ANGLES_Y) {
		angles[0] = readshort() / (32767 / 360);
		angles[1] = readshort() / (32767 / 360);
		angles[2] = readshort() / (32767 / 360);
	}
	if (fl & PLAYER_COLORMAP)
		colormap = readbyte();

	if (fl & PLAYER_VELOCITY) {
		velocity[0] = readcoord();
		velocity[1] = readcoord();
	}

	if (fl & PLAYER_VELOCITY_Z)
		velocity[2] = readcoord();
	if (fl & PLAYER_FLAGS) {
		flags = readfloat();
		gflags = readfloat();
		pmove_flags = readfloat();

		/* mainly used for other players receiving us */
		if (flags & FL_CROUCHING)
			setsize(self, PHY_HULL_CROUCHED_MIN, PHY_HULL_CROUCHED_MAX);
		else
			setsize(self, PHY_HULL_MIN, PHY_HULL_MAX);
	}
	if (fl & PLAYER_WEAPON) {
		activeweapon = readbyte();
		weaponframe = (int)readbyte();
	}
	if (fl & PLAYER_ITEMS)
		g_items = (__variant)readfloat();
	if (fl & PLAYER_HEALTH)
		health = readbyte();
	if (fl & PLAYER_ARMOR)
		armor = readbyte();
	if (fl & PLAYER_MOVETYPE) {
		movetype = readbyte();
		solid = readbyte();
	}
	if (fl & PLAYER_VIEWOFS)
		view_ofs[2] = readfloat();

	/* TO OPTIMISE */
	teleport_time = readfloat();
	viewzoom = readfloat();
	weapontime = readfloat();
	w_attack_next = readfloat();
	w_idle_next = readfloat();
	punchangle[0] = readfloat();
	punchangle[1] = readfloat();
	punchangle[2] = readfloat();
	vehicle_entnum = readentitynum();
	VehicleRelink();

	/* FIXME: Make this temp spec only */
	spec_ent = readbyte();
	spec_mode = readbyte();
	spec_flags = readbyte();

	PredictPreFrame();
}

/*
=================
NSClientPlayer::PredictPreFrame

Save the state of the last server-confirmed attributes.
If you want to override this, do not call this
at the top of player::PredictPreFrame
=================
*/
void
NSClientPlayer::PredictPreFrame(void)
{
	/* base player attributes/fields we're going to roll back */
	SAVE_STATE(modelindex);
	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(v_angle);
	SAVE_STATE(colormap);
	SAVE_STATE(velocity);
	SAVE_STATE(flags);
	SAVE_STATE(gflags);
	SAVE_STATE(pmove_flags);
	SAVE_STATE(activeweapon);
	SAVE_STATE(g_items);
	SAVE_STATE(health);
	SAVE_STATE(armor);
	SAVE_STATE(movetype);
	SAVE_STATE(solid);
	SAVE_STATE(view_ofs);

	/* TO OPTIMISE */
	SAVE_STATE(teleport_time);
	SAVE_STATE(viewzoom);
	SAVE_STATE(weaponframe);
	SAVE_STATE(weapontime);
	SAVE_STATE(w_attack_next);
	SAVE_STATE(w_idle_next);
	SAVE_STATE(punchangle);
	SAVE_STATE(vehicle_entnum);

	SAVE_STATE(spec_ent);
	SAVE_STATE(spec_mode);
	SAVE_STATE(spec_flags);
}

/*
=================
NSClientPlayer::PredictPostFrame

After running prediction on the client, roll back the values
to the server's confirmed saved attributes from PredictPreFrame.
If you want to override this, do not call this
at the top of player::PredictPostFrame
=================
*/
void
NSClientPlayer::PredictPostFrame(void)
{
	/* finally roll the values back */
	ROLL_BACK(modelindex);
	ROLL_BACK(origin);
	ROLL_BACK(angles);
	ROLL_BACK(v_angle);
	ROLL_BACK(colormap);
	ROLL_BACK(velocity);
	ROLL_BACK(flags);
	ROLL_BACK(gflags);
	ROLL_BACK(pmove_flags);
	ROLL_BACK(activeweapon);
	ROLL_BACK(g_items);
	ROLL_BACK(health);
	ROLL_BACK(armor);
	ROLL_BACK(movetype);
	ROLL_BACK(solid);
	ROLL_BACK(view_ofs);

	/* TO OPTIMISE */
	ROLL_BACK(teleport_time);
	ROLL_BACK(viewzoom);
	ROLL_BACK(weaponframe);
	ROLL_BACK(weapontime);
	ROLL_BACK(w_attack_next);
	ROLL_BACK(w_idle_next);
	ROLL_BACK(punchangle);
	ROLL_BACK(vehicle_entnum);

	ROLL_BACK(spec_ent);
	ROLL_BACK(spec_mode);
	ROLL_BACK(spec_flags);
}
#else
void
NSClientPlayer::Save(float handle)
{
	SaveFloat(handle, "health", health);
	SaveFloat(handle, "armor", armor);
	SaveFloat(handle, "modelindex", modelindex);
	SaveVector(handle, "origin", origin);
	SaveVector(handle, "velocity", velocity);
	SaveVector(handle, "angles", angles);
	SaveFloat(handle, "colormap", colormap);
	SaveFloat(handle, "flags", flags);
	SaveFloat(handle, "gflags", gflags);
	SaveFloat(handle, "viewzoom", viewzoom);
	SaveVector(handle, "view_ofs", view_ofs);
	SaveVector(handle, "v_angle", v_angle);
	SaveVector(handle, "punchangle", punchangle);
	SaveFloat(handle, "movetype", movetype);
	SaveFloat(handle, "pmove_flags", pmove_flags);
	SaveFloat(handle, "w_attack_next", w_attack_next);
	SaveFloat(handle, "w_idle_next", w_idle_next);
	SaveFloat(handle, "teleport_time", teleport_time);
	SaveInt(handle, "weaponframe", weaponframe);
	SaveFloat(handle, "weapontime", weapontime);
	SaveInt(handle, "g_items", g_items);
	SaveFloat(handle, "activeweapon", activeweapon);
	SaveFloat(handle, "vehicle", num_for_edict(vehicle));
}

void
NSClientPlayer::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "health":
		health = ReadFloat(strValue);
		break;
	case "armor":
		armor = ReadFloat(strValue);
		break;
	case "modelindex":
		modelindex = ReadFloat(strValue);
		break;
	case "origin":
		origin = ReadVector(strValue);
		break;
	case "velocity":
		velocity = ReadVector(strValue);
		break;
	case "angles":
		angles = ReadVector(strValue);
		break;
	case "colormap":
		colormap = ReadFloat(strValue);
		break;
	case "flags":
		flags = ReadFloat(strValue);
		break;
	case "gflags":
		gflags = ReadFloat(strValue);
		break;
	case "view_ofs":
		view_ofs = ReadVector(strValue);
		break;
	case "v_angle":
		v_angle = ReadVector(strValue);
		break;
	case "punchangle":
		punchangle = ReadVector(strValue);
		break;
	case "movetype":
		movetype = ReadFloat(strValue);
		break;
	case "pmove_flags":
		pmove_flags = ReadFloat(strValue);
		break;
	case "w_attack_next":
		w_attack_next = ReadFloat(strValue);
		break;
	case "w_idle_next":
		w_idle_next = ReadFloat(strValue);
		break;
	case "teleport_time":
		teleport_time = ReadFloat(strValue);
		break;
	case "weaponframe":
		weaponframe = ReadInt(strValue);
		break;
	case "weapontime":
		weapontime = ReadFloat(strValue);
		break;
	case "g_items":
		g_items = ReadInt(strValue);
		break;
	case "activeweapon":
		activeweapon = ReadFloat(strValue);
		break;
	case "vehicle":
		vehicle = edict_num(ReadFloat(strValue));
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

/*
=================
NSClientPlayer::Respawn

it'd be pretty unfortunate if 'sv respawn_ents' or something called this
=================
*/
void
NSClientPlayer::Respawn(void)
{
	/* make sure nothing happens here */
}

/*
=================
NSClientPlayer::MakeTempSpectator
 
This is what dead players in round matches become, or when we spawn
for the first time before selecting a loadout or something.
=================
 */
void
NSClientPlayer::MakeTempSpectator(void)
{
	classname = "player";
	flags = FL_CLIENT;
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NOCLIP);
	SetTakedamage(DAMAGE_NO);
	maxspeed = 250;
	flags |= FL_FAKESPEC;
	max_health = health = 0;
	armor = 0;
	g_items = 0;
	activeweapon = 0;
	effects = 0;
	alpha = 0.0f;
}

/*
=================
NSClientPlayer::MakeDead
 
Sets all the appropriate attributes to make sure we're dead
=================
 */
void
NSClientPlayer::Death(void)
{
	classname = "player";
	health = max_health = 0;
	armor = 0;
	g_items = 0;
	activeweapon = 0;
	effects = 0;
	alpha = 1.0f;
	SetModelindex(0);
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_NOT);
	SetTakedamage(DAMAGE_NO);
	viewzoom = 1.0;
	view_ofs = [0,0,0];
	vehicle = __NULL__;
	SetVelocity([0,0,0]);
	SetGravity(1.0f);
	customphysics = Empty;
	iBleeds = FALSE;
	forceinfokey(this, "*deaths", ftos(deaths));
	setsize(this, [0,0,0], [0,0,0]);
}

/*
=================
NSClientPlayer::MakePlayer
 
True participating player, can walk around and everything.
=================
 */
void
NSClientPlayer::MakePlayer(void)
{
	classname = "player";
	flags = FL_CLIENT;
	health = max_health = 100;
	armor = 0;
	g_items = 0;
	activeweapon = 0;
	effects = 0;
	alpha = 1.0f;
	SetSolid(SOLID_SLIDEBOX);
	SetMovetype(MOVETYPE_WALK);
	SetTakedamage(DAMAGE_YES);
	SetVelocity([0,0,0]);
	viewzoom = 1.0;
	vehicle = __NULL__;
	SetGravity(1.0f);
	SendFlags = UPDATE_ALL;
	customphysics = Empty;
	iBleeds = TRUE;
	forceinfokey(this, "*deaths", ftos(deaths));
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
}

/*
=================
NSClientPlayer::EvaluateEntity

Check which attributes have changed and flag the ones that did.
If you want to override this, do not call this
at the top of player::EvaluateEntity
=================
*/
void
NSClientPlayer::EvaluateEntity(void)
{
	SetSendFlags(PLAYER_KEEPALIVE);

	if (ATTR_CHANGED(modelindex))
		SetSendFlags(PLAYER_MODELINDEX);

	if (VEC_CHANGED(origin, 0))
		SetSendFlags(PLAYER_ORIGIN);

	if (VEC_CHANGED(origin, 1))
		SetSendFlags(PLAYER_ORIGIN);

	if (VEC_CHANGED(origin, 2))
		SetSendFlags(PLAYER_ORIGIN_Z);

	if (VEC_CHANGED(v_angle, 0) || VEC_CHANGED(v_angle, 1) || VEC_CHANGED(v_angle, 2))
		SetSendFlags(PLAYER_ANGLES_X);

	if (VEC_CHANGED(angles, 0) || VEC_CHANGED(angles, 1) || VEC_CHANGED(angles, 2))
		SetSendFlags(PLAYER_ANGLES_Y);

	if (ATTR_CHANGED(colormap))
		SetSendFlags(PLAYER_COLORMAP);

	if (VEC_CHANGED(velocity, 0))
		SetSendFlags(PLAYER_VELOCITY);

	if (VEC_CHANGED(velocity, 1))
		SetSendFlags(PLAYER_VELOCITY);

	if (VEC_CHANGED(velocity, 2))
		SetSendFlags(PLAYER_VELOCITY_Z);

	if (ATTR_CHANGED(flags))
		SetSendFlags(PLAYER_FLAGS);

	if (ATTR_CHANGED(gflags))
		SetSendFlags(PLAYER_FLAGS);

	if (ATTR_CHANGED(pmove_flags))
		SetSendFlags(PLAYER_FLAGS);

	if (ATTR_CHANGED(weaponframe))
		SetSendFlags(PLAYER_WEAPON);

	if (ATTR_CHANGED(activeweapon))
		SetSendFlags(PLAYER_WEAPON);

	if (ATTR_CHANGED(g_items))
		SetSendFlags(PLAYER_ITEMS);

	if (ATTR_CHANGED(health))
		SetSendFlags(PLAYER_HEALTH);

	if (ATTR_CHANGED(armor))
		SetSendFlags(PLAYER_ARMOR);

	if (ATTR_CHANGED(movetype))
		SetSendFlags(PLAYER_MOVETYPE);

	if (ATTR_CHANGED(solid))
		SetSendFlags(PLAYER_MOVETYPE);

	if (ATTR_CHANGED(view_ofs))
		SetSendFlags(PLAYER_VIEWOFS);

	SAVE_STATE(modelindex);
	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(colormap);
	SAVE_STATE(velocity);
	SAVE_STATE(flags);
	SAVE_STATE(gflags);
	SAVE_STATE(pmove_flags);
	SAVE_STATE(activeweapon);
	SAVE_STATE(g_items);
	SAVE_STATE(health);
	SAVE_STATE(armor);
	SAVE_STATE(movetype);
	SAVE_STATE(solid);
	SAVE_STATE(view_ofs);

	/* TO OPTIMISE */
	SAVE_STATE(teleport_time);
	SAVE_STATE(viewzoom);
	SAVE_STATE(weaponframe);
	SAVE_STATE(weapontime);
	SAVE_STATE(w_attack_next);
	SAVE_STATE(w_idle_next);
	SAVE_STATE(punchangle);
	SAVE_STATE(vehicle);

	/* FIXME: Make this temp spec only */
	SAVE_STATE(spec_ent);
	SAVE_STATE(spec_mode);
	SAVE_STATE(spec_flags);
}

/*
=================
NSClientPlayer::SendEntity

Network any attributes that have been flagged for networking.
If you want to override this, do not call this
at the top of player::SendEntity
=================
*/
float
NSClientPlayer::SendEntity(entity ePEnt, float fChanged)
{
	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & PLAYER_MODELINDEX) {
		WriteShort(MSG_ENTITY, modelindex);
	}

	/* if origin[0] changes, it's very likely [1] changes too, since
	 * we rarely ever walk in a straight line on the world grid */
	if (fChanged & PLAYER_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
	}
	/* the height doesn't change as much */
	if (fChanged & PLAYER_ORIGIN_Z)
		WriteCoord(MSG_ENTITY, origin[2]);

	if (fChanged & PLAYER_ANGLES_X) {
		WriteShort(MSG_ENTITY, v_angle[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, v_angle[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, v_angle[2] * 32767 / 360);
	}
	if (fChanged & PLAYER_ANGLES_Y) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
	}
	if (fChanged & PLAYER_COLORMAP)
		WriteByte(MSG_ENTITY, colormap);

	/* similar as with origin, we separate x/y from z */
	if (fChanged & PLAYER_VELOCITY) {
		WriteCoord(MSG_ENTITY, velocity[0]);
		WriteCoord(MSG_ENTITY, velocity[1]);
	}
	if (fChanged & PLAYER_VELOCITY_Z)
		WriteCoord(MSG_ENTITY, velocity[2]);

	if (fChanged & PLAYER_FLAGS) {
		WriteFloat(MSG_ENTITY, flags);
		WriteFloat(MSG_ENTITY, gflags);
		WriteFloat(MSG_ENTITY, pmove_flags);
	}
	if (fChanged & PLAYER_WEAPON) {
		WriteByte(MSG_ENTITY, activeweapon);
		WriteByte(MSG_ENTITY, weaponframe);
	}

	/* g_items is a proper integer, so we can't let WriteFloat truncate it (hence __variant) */
	if (fChanged & PLAYER_ITEMS)
		WriteFloat(MSG_ENTITY, (__variant)g_items);

	/* only got byte precision, clamp to avoid weird values on the client-side */
	if (fChanged & PLAYER_HEALTH)
		WriteByte(MSG_ENTITY, bound(0, health, 255));
	if (fChanged & PLAYER_ARMOR)
		WriteByte(MSG_ENTITY, bound(0, armor, 255));

	if (fChanged & PLAYER_MOVETYPE) {
		WriteByte(MSG_ENTITY, movetype);
		WriteByte(MSG_ENTITY, solid);
	}

	/* the view_ofs[0] and [1] are rarely changed */
	if (fChanged & PLAYER_VIEWOFS)
		WriteFloat(MSG_ENTITY, view_ofs[2]);

	/* TO OPTIMISE */
	WriteFloat(MSG_ENTITY, teleport_time);
	WriteFloat(MSG_ENTITY, viewzoom);
	WriteFloat(MSG_ENTITY, weapontime);
	WriteFloat(MSG_ENTITY, w_attack_next);
	WriteFloat(MSG_ENTITY, w_idle_next);
	WriteFloat(MSG_ENTITY, punchangle[0]);
	WriteFloat(MSG_ENTITY, punchangle[1]);
	WriteFloat(MSG_ENTITY, punchangle[2]);

	if (vehicle)
		WriteEntity(MSG_ENTITY, vehicle);
	else
		WriteEntity(MSG_ENTITY, __NULL__);

	/* FIXME: Make this fake NSClientSpectator only. */
	WriteByte(MSG_ENTITY, spec_ent);
	WriteByte(MSG_ENTITY, spec_mode);
	WriteByte(MSG_ENTITY, spec_flags);

	return (1);
}

/*
====================
_NSClientPlayer_useworkaround

A wrapper to cleanly reset 'self' as to not mess up the QC VM
====================
*/
void
_NSClientPlayer_useworkaround(entity eTarget)
{
	eActivator = self;
	entity eOldSelf = self;
	self = eTarget;
	self.PlayerUse();
	self = eOldSelf;
}

/*
====================
_NSClientPlayer_useworkaround

A wrapper to cleanly reset 'self' as to not mess up the QC VM
====================
*/
void
_NSClientPlayer_unuseworkaround(entity eTarget)
{
	eActivator = self;
	entity eOldSelf = self;
	self = eTarget;
	if (self.PlayerUseUnpressed)
		self.PlayerUseUnpressed();
	self = eOldSelf;
}

/*
=================
NSClientPlayer:: InputUse_Down

Called when we hold down the +use button for the first time,
looks for an entity that has the .PlayerUse field set to a function and calls it.
=================
*/
void
NSClientPlayer::InputUse_Down(void)
{
	if (health <= 0) {
		return;
	} else if (!(flags & FL_USE_RELEASED)) {
		return;
	}
	
	vector vecSource;
	entity eRad;
	bool found_use = false;

	makevectors(v_angle);
	vecSource = origin + view_ofs;
	traceline(vecSource, vecSource + (v_forward * 64), MOVE_EVERYTHING, this);

	/* first see if we traced something head-on, else we'll findradius something */
	if (trace_ent.PlayerUse) {
		found_use = true;
		eRad = trace_ent;
	} else {
		/* find anything in a 8 unit radius, including certain non-solids (func_door, func_rot_button etc. */
		eRad = findradius(trace_endpos, 8);

		/* loop through our chain and just pick the first valid one */
		while (eRad) {
			if (eRad.PlayerUse) {
				found_use = true;
				break;
			}
			eRad = eRad.chain;
		}
	}

	/* TODO: maybe eRad will return something in the future that'll suppress a successfull use? */
	if (eRad && found_use == true) {
		flags &= ~FL_USE_RELEASED;
		_NSClientPlayer_useworkaround(eRad);
		last_used = eRad;

		/* Some entities want to support Use spamming */
		if (!(flags & FL_USE_RELEASED)) {
			sound(this, CHAN_ITEM, "common/wpn_select.wav", 0.25, ATTN_IDLE);
		}
	} else {
		sound(this, CHAN_ITEM, "common/wpn_denyselect.wav", 0.25, ATTN_IDLE);
		flags &= ~FL_USE_RELEASED;
	}
}

/*
=================
NSClientPlayer:: InputUse_Down

Called when we let go of the +use button
=================
*/
void
NSClientPlayer::InputUse_Up(void)
{
	if (!(flags & FL_USE_RELEASED)) {
		_NSClientPlayer_unuseworkaround(last_used);
		last_used = world;
		flags |= FL_USE_RELEASED;
	}
}
#endif

void
NSClientPlayer::NSClientPlayer(void)
{
	super::NSClientSpectator();
	vehicle = __NULL__;
}