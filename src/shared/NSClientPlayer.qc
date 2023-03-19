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

void
NSClientPlayer::NSClientPlayer(void)
{
	flags |= FL_CLIENT;
	vehicle = __NULL__;
}


void
NSClientPlayer::SharedInputFrame(void)
{
	/* if spectator, we want to make sure we call this */
	if (!Client_InIntermission() && IsFakeSpectator()) {
		NSClientSpectator::SharedInputFrame();
		return;
	}
}

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
	return (true);
}

bool
NSClientPlayer::IsFakeSpectator(void)
{
	if (HasFlags(FL_FAKESPEC))
		return (true);

	return (false);
}

void
NSClientPlayer::PreFrame(void)
{
#ifdef CLIENT
	if (Util_IsPaused())
		return;

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
	if (Util_IsPaused())
		return;

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
NSClientPlayer::ProcessInput(void)
{
	NSVehicle veh = (NSVehicle)vehicle;

	if (Util_IsPaused())
		return;

	XR_InputFrame(this);

	if (!Client_InIntermission() && IsFakeSpectator()) {
		NSClientSpectator::ProcessInput();
		SpectatorTrackPlayer();
		return;
	}

	/* allow vehicles to prevent weapon logic from happening */
	if (vehicle && !Client_InIntermission()) {
		if (veh.PlayerInput)
			veh.PlayerInput();
	}

#ifdef SERVER
	CGameRules rules = (CGameRules)g_grMode;

	if (rules.m_iIntermission) {
		rules.IntermissionEnd();
		return;
	} else if (IsAlive() == false) {
		if (input_buttons & INPUT_BUTTON0)
			rules.PlayerRequestRespawn(this);
	}

	/* handle use button presses */
	if (input_buttons & INPUT_BUTTON5)
		InputUse_Down(); 
	else
		InputUse_Up();

	/* handle impulse commands */
	rules.ImpulseCommand(this, impulse);
	impulse = 0;
#endif

	bool canfire = true;

	/* can't fire in some vehicles */
	if (veh)
		if (veh.PreventPlayerFire() == true)
			canfire = false;

	/* can't fire when dead, sorry. */
	if (health <= 0)
		canfire = false;
	
	if (canfire == false) {
		Weapons_Release((player)this);
		return;
	}

	/* weapon system */
	if (input_buttons & INPUT_BUTTON3)
		Weapons_Secondary((player)this);
	else if (input_buttons & INPUT_BUTTON0)
		Weapons_Primary((player)this);
	else if (input_buttons & INPUT_BUTTON4)
		Weapons_Reload((player)this);
	else
		Weapons_Release((player)this);
}

/* this is where it gets mod specific really fast,
   as some models may not even support skeletal animation */
void
NSClientPlayer::UpdatePlayerAnimation(float timelength)
{

}

#ifdef CLIENT
void
NSClientPlayer::UpdatePlayerJaw(float voip_volume)
{
}

void
NSClientPlayer::UpdatePlayerAttachments(bool visible)
{

}

float
NSClientPlayer::predraw(void)
{
	bool localplayer = false;

	NSClient cl = (NSClient)pSeat->m_ePlayer;

	/* figure out if this is the local player. it's either us or us spectating */
	if (Client_IsSpectator(cl)) {
		NSClientSpectator spec = (NSClientSpectator)pSeat->m_ePlayer;
		if (entnum == spec.spec_ent && spec.spec_mode == SPECMODE_FIRSTPERSON) {
			localplayer = true;
		}
	} else {
		if (entnum == player_localentnum) {
			localplayer = true;
		}
	}

	if (!p_model) {
		p_model = spawn(NSRenderableEntity);
	}

	/* make sure we're enabling shadow rendering on us! */
	effects &= ~EF_NOSHADOW;

	/* if this player is not the local player, then physics aren't being run on them
      so we need to advance their animation manually */
	if (entnum != player_localentnum) {
		if (autocvar(cg_extrapolateClients, 1)) {
			makevectors(v_angle);
			input_movevalues[0] = dotproduct(velocity, v_forward);
			input_movevalues[1] = dotproduct(velocity, v_right);
			input_movevalues[2] = dotproduct(velocity, v_up);
			input_buttons = (flags & FL_JUMPRELEASED) ? 0 : INPUT_BUTTON2; /* this may not help that much... */
			input_buttons |= (flags & FL_CROUCHING) ? INPUT_BUTTON8 : 0;
			input_angles = v_angle;
			input_impulse = 0;
			input_timelength = clframetime;
			Physics_Run();
		} else {
			/* advance animation, usually done in physics */
			UpdatePlayerAnimation(clframetime);
		}
	}

	/* mouth flapping */
	UpdatePlayerJaw(getplayerkeyfloat(this.entnum - 1, "voiploudness"));

	/* apply any necessary filters from NSRenderableEntity */
	RenderFXPass();

	/* apply any fire effects, if we're burning (we're of type NSSurfacePropEntity that can burn) */
	RenderFire();

	/* if we're inside of a vehicle, it may want to hide or show us regardless */
	if (localplayer && HasFlags(FL_INVEHICLE)) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh)
			localplayer = veh.HidePlayermodel();
	}

	/* if we're forcing third-person.. or this is not us - render this player */
	if (autocvar_pm_thirdPerson == TRUE || !localplayer) {
		/* mark as not-mirror-only */
		renderflags &= ~RF_EXTERNALMODEL;

		/* same for our attachment */
		if (p_model)
			p_model.renderflags &= ~RF_EXTERNALMODEL;

		/* let mods override attachments and whatnot */
		UpdatePlayerAttachments(true);

		/* draw a 3D voice blob over its head */
		Voice_Draw3D(this);
		Weapons_PreDraw((player)this, true);

		/* force drawing us if it's our local player and we're meant to show */
		if (entnum == player_localentnum)
			g_view.SetDrawLocalPlayer(true);

		/* sucks we can't draw a shadow on this thing, maybe in the future when FTEQW allows it */
		if (p_model)
			addentity(p_model);
	} else { /* we're doing first person stuff */
		/* flags that the model appear in mirrors only */
		renderflags |= RF_EXTERNALMODEL;

		/* ditto */
		if (p_model)
			p_model.renderflags |= RF_EXTERNALMODEL;

		/* give mods a chance to de-render attachments */
		UpdatePlayerAttachments(false);
		Weapons_PreDraw((player)this, false);

		/* this is here just to make sure our view hides us if it's the local player */
		if (entnum == player_localentnum)
			g_view.SetDrawLocalPlayer(false);
	}

	/* this needs to be called absolutely last */
	/* we're calling this so that the shadow can still be drawn */
	addentity(this);

	return (PREDRAW_NEXT);
}

void
NSClientPlayer::postdraw(void)
{
}

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
		p_model.Destroy();

	super::OnRemoveEntity();
}

void
NSClientPlayer::UpdateAliveCam(void)
{
	g_view.SetCameraOrigin(GetEyePos());
	Camera_RunBob(view_angles);
	Camera_StrafeRoll(view_angles);
	g_view.SetCameraAngle(view_angles);

	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh.UpdateView)
			veh.UpdateView();
	} else if (health) {
		if (autocvar_pm_thirdPerson == TRUE) {
			makevectors(view_angles);
			vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
			vector vEnd = vStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
			traceline(vStart, vEnd, FALSE, this);
			g_view.SetCameraOrigin(trace_endpos + (v_forward * 5));
		}
	}

	Shake_Update(this);
	g_view.AddPunchAngle(punchangle);
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
	if (Util_IsPaused())
		return;

	/* fake spectators want the same input as real ones. */
	if (IsFakeSpectator()) {
		NSClientSpectator::ClientInputFrame();
		return;
	}

	/* If we are inside a VGUI, don't let the client do stuff outside */
	if (VGUI_Active() || pSeat->m_bInterfaceFocused) {
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

	if (pSeat->m_iInputExtra1 == TRUE) {
		input_buttons |= INPUT_BUTTON6;
	}

	if (pSeat->m_iInputExtra2 == TRUE) {
		input_buttons |= INPUT_BUTTON7;
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

	/* compat */
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
NSClientPlayer::ReceiveEntity(float new, float flChanged)
{
	/* store which input sequence we're on, this helps us
	 * later when we run prediction again between last/latest
	 * servercommandframe */
	sequence = servercommandframe;

	/* HACK: we need to make this more reliable */
	if (flChanged == UPDATE_ALL) {
		/* we respawned */
		gravity = 1.0f;
	}

	READENTITY_INT(modelindex, PLAYER_MODELINDEX)
	READENTITY_BYTE(colormap, PLAYER_MODELINDEX)
	READENTITY_COORD(origin[0], PLAYER_ORIGIN)
	READENTITY_COORD(origin[1], PLAYER_ORIGIN)
	READENTITY_COORD(origin[2], PLAYER_ORIGIN)
	READENTITY_ANGLE(v_angle[0], PLAYER_ANGLES)
	READENTITY_ANGLE(v_angle[1], PLAYER_ANGLES)
	READENTITY_ANGLE(v_angle[2], PLAYER_ANGLES)
	READENTITY_ANGLE(angles[0], PLAYER_ANGLES)
	READENTITY_ANGLE(angles[1], PLAYER_ANGLES)
	READENTITY_ANGLE(angles[2], PLAYER_ANGLES)
	READENTITY_COORD(velocity[0], PLAYER_VELOCITY)
	READENTITY_COORD(velocity[1], PLAYER_VELOCITY)
	READENTITY_COORD(velocity[2], PLAYER_VELOCITY)
	READENTITY_COORD(basevelocity[0], PLAYER_VELOCITY)
	READENTITY_COORD(basevelocity[1], PLAYER_VELOCITY)
	READENTITY_COORD(basevelocity[2], PLAYER_VELOCITY)
	READENTITY_INT(flags, PLAYER_FLAGS)
	READENTITY_INT(gflags, PLAYER_FLAGS)
	READENTITY_INT(pmove_flags, PLAYER_FLAGS)
	READENTITY_BYTE(activeweapon, PLAYER_WEAPON)
	READENTITY_BYTE(weaponframe, PLAYER_WEAPON)
	READENTITY_INT(g_items, PLAYER_ITEMS)
	READENTITY_BYTE(health, PLAYER_HEALTH)
	READENTITY_BYTE(armor, PLAYER_HEALTH)
	READENTITY_COORD(mins[0], PLAYER_SIZE)
	READENTITY_COORD(mins[1], PLAYER_SIZE)
	READENTITY_COORD(mins[2], PLAYER_SIZE)
	READENTITY_COORD(maxs[0], PLAYER_SIZE)
	READENTITY_COORD(maxs[1], PLAYER_SIZE)
	READENTITY_COORD(maxs[2], PLAYER_SIZE)
	READENTITY_BYTE(view_ofs[2], PLAYER_SIZE)
	READENTITY_BYTE(movetype, PLAYER_MOVETYPE)
	READENTITY_BYTE(solid, PLAYER_MOVETYPE)
	READENTITY_FLOAT(punchangle[0], PLAYER_PUNCHANGLE)
	READENTITY_FLOAT(punchangle[1], PLAYER_PUNCHANGLE)
	READENTITY_FLOAT(punchangle[2], PLAYER_PUNCHANGLE)
	READENTITY_FLOAT(viewzoom, PLAYER_VIEWZOOM)
	READENTITY_FLOAT(teleport_time, PLAYER_TIMINGS)
	READENTITY_FLOAT(weapontime, PLAYER_TIMINGS)
	READENTITY_FLOAT(w_attack_next, PLAYER_TIMINGS)
	READENTITY_FLOAT(w_idle_next, PLAYER_TIMINGS)
	READENTITY_ENTNUM(vehicle_entnum, PLAYER_VEHICLE)
	READENTITY_BYTE(spec_ent, PLAYER_SPECTATE)
	READENTITY_BYTE(spec_mode, PLAYER_SPECTATE)
	READENTITY_BYTE(spec_flags, PLAYER_SPECTATE)

	VehicleRelink();
	PredictPreFrame();

	if (flChanged & PLAYER_SIZE)
		setsize(this, mins, maxs);

	setorigin(this, origin);
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
	SAVE_STATE(modelindex)
	SAVE_STATE(origin)
	SAVE_STATE(v_angle)
	SAVE_STATE(angles)
	SAVE_STATE(colormap)
	SAVE_STATE(velocity)
	SAVE_STATE(flags)
	SAVE_STATE(gflags)
	SAVE_STATE(pmove_flags)
	SAVE_STATE(activeweapon)
	SAVE_STATE(weaponframe)
	SAVE_STATE(g_items)
	SAVE_STATE(health)
	SAVE_STATE(armor)
	SAVE_STATE(mins)
	SAVE_STATE(maxs)
	SAVE_STATE(view_ofs)
	SAVE_STATE(movetype)
	SAVE_STATE(solid)
	SAVE_STATE(punchangle)
	SAVE_STATE(viewzoom)
	SAVE_STATE(teleport_time)
	SAVE_STATE(weapontime)
	SAVE_STATE(w_attack_next)
	SAVE_STATE(w_idle_next)
	SAVE_STATE(vehicle_entnum)
	SAVE_STATE(spec_ent)
	SAVE_STATE(spec_mode)
	SAVE_STATE(spec_flags)
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
	ROLL_BACK(modelindex)
	ROLL_BACK(origin)
	ROLL_BACK(v_angle)
	ROLL_BACK(angles)
	ROLL_BACK(colormap)
	ROLL_BACK(velocity)
	ROLL_BACK(flags)
	ROLL_BACK(gflags)
	ROLL_BACK(pmove_flags)
	ROLL_BACK(activeweapon)
	ROLL_BACK(weaponframe)
	ROLL_BACK(g_items)
	ROLL_BACK(health)
	ROLL_BACK(armor)
	ROLL_BACK(mins)
	ROLL_BACK(maxs)
	ROLL_BACK(view_ofs)
	ROLL_BACK(movetype)
	ROLL_BACK(solid)
	ROLL_BACK(punchangle)
	ROLL_BACK(viewzoom)
	ROLL_BACK(teleport_time)
	ROLL_BACK(weapontime)
	ROLL_BACK(w_attack_next)
	ROLL_BACK(w_idle_next)
	ROLL_BACK(vehicle_entnum)
	ROLL_BACK(spec_ent)
	ROLL_BACK(spec_mode)
	ROLL_BACK(spec_flags)
}
#else
void
NSClientPlayer::ServerInputFrame(void)
{
#ifdef BOT_INCLUDED
	/* wait a few seconds, as we may not have been spawned yet */
	if (clienttype(this) == CLIENTTYPE_BOT) {
		((bot)this).RunAI();
	}
#endif

	Physics_Run();
}

void
NSClientPlayer::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "max_health", max_health);
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
	SaveFloat(handle, "solid", solid);
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
	case "max_health":
		max_health = ReadFloat(strValue);
		break;
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
	case "solid":
		solid = ReadFloat(strValue);
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
	scale = 1.0f;
	forceinfokey(this, "*spectator", "0"); /* not a real spectator */
	forceinfokey(this, "*dead", "0");
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
	setsize(this, [0,0,0], [0,0,0]);
	forceinfokey(this, "*deaths", ftos(deaths));
	forceinfokey(this, "*dead", "1");
	forceinfokey(this, "*spectator", "0");
	m_flDeathTime = time;
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
	scale = 1.0f;
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	forceinfokey(this, "*spectator", "0");
	forceinfokey(this, "*deaths", ftos(deaths));
	forceinfokey(this, "*dead", "0");
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
	EVALUATE_FIELD(modelindex, PLAYER_MODELINDEX)
	EVALUATE_FIELD(colormap, PLAYER_MODELINDEX)
	EVALUATE_VECTOR(origin, 0, PLAYER_ORIGIN)
	EVALUATE_VECTOR(origin, 1, PLAYER_ORIGIN)
	EVALUATE_VECTOR(origin, 2, PLAYER_ORIGIN)
	EVALUATE_VECTOR(v_angle, 0, PLAYER_ANGLES)
	EVALUATE_VECTOR(v_angle, 1, PLAYER_ANGLES)
	EVALUATE_VECTOR(v_angle, 2, PLAYER_ANGLES)
	EVALUATE_VECTOR(angles, 0, PLAYER_ANGLES)
	EVALUATE_VECTOR(angles, 1, PLAYER_ANGLES)
	EVALUATE_VECTOR(angles, 2, PLAYER_ANGLES)
	EVALUATE_VECTOR(velocity, 0, PLAYER_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, PLAYER_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, PLAYER_VELOCITY)
	EVALUATE_VECTOR(basevelocity, 0, PLAYER_VELOCITY)
	EVALUATE_VECTOR(basevelocity, 1, PLAYER_VELOCITY)
	EVALUATE_VECTOR(basevelocity, 2, PLAYER_VELOCITY)
	EVALUATE_FIELD(flags, PLAYER_FLAGS)
	EVALUATE_FIELD(gflags, PLAYER_FLAGS)
	EVALUATE_FIELD(pmove_flags, PLAYER_FLAGS)
	EVALUATE_FIELD(activeweapon, PLAYER_WEAPON)
	EVALUATE_FIELD(weaponframe, PLAYER_WEAPON)
	EVALUATE_FIELD(g_items, PLAYER_ITEMS)
	EVALUATE_FIELD(health, PLAYER_HEALTH)
	EVALUATE_FIELD(armor, PLAYER_HEALTH)
	EVALUATE_VECTOR(mins, 0, PLAYER_SIZE)
	EVALUATE_VECTOR(mins, 1, PLAYER_SIZE)
	EVALUATE_VECTOR(mins, 2, PLAYER_SIZE)
	EVALUATE_VECTOR(maxs, 0, PLAYER_SIZE)
	EVALUATE_VECTOR(maxs, 1, PLAYER_SIZE)
	EVALUATE_VECTOR(maxs, 2, PLAYER_SIZE)
	EVALUATE_VECTOR(view_ofs, 2, PLAYER_SIZE)
	EVALUATE_FIELD(movetype, PLAYER_MOVETYPE)
	EVALUATE_FIELD(solid, PLAYER_MOVETYPE)
	EVALUATE_VECTOR(punchangle, 0, PLAYER_PUNCHANGLE)
	EVALUATE_VECTOR(punchangle, 1, PLAYER_PUNCHANGLE)
	EVALUATE_VECTOR(punchangle, 2, PLAYER_PUNCHANGLE)
	EVALUATE_FIELD(viewzoom, PLAYER_VIEWZOOM)
	EVALUATE_FIELD(teleport_time, PLAYER_TIMINGS)
	EVALUATE_FIELD(weapontime, PLAYER_TIMINGS)
	EVALUATE_FIELD(w_attack_next, PLAYER_TIMINGS)
	EVALUATE_FIELD(w_idle_next, PLAYER_TIMINGS)
	EVALUATE_FIELD(vehicle, PLAYER_VEHICLE)
	EVALUATE_FIELD(spec_ent, PLAYER_SPECTATE)
	EVALUATE_FIELD(spec_mode, PLAYER_SPECTATE)
	EVALUATE_FIELD(spec_flags, PLAYER_SPECTATE)
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
NSClientPlayer::SendEntity(entity ePEnt, float flChanged)
{
	SENDENTITY_INT(modelindex, PLAYER_MODELINDEX)
	SENDENTITY_BYTE(colormap, PLAYER_MODELINDEX)
	SENDENTITY_COORD(origin[0], PLAYER_ORIGIN)
	SENDENTITY_COORD(origin[1], PLAYER_ORIGIN)
	SENDENTITY_COORD(origin[2], PLAYER_ORIGIN)
	SENDENTITY_ANGLE(v_angle[0], PLAYER_ANGLES)
	SENDENTITY_ANGLE(v_angle[1], PLAYER_ANGLES)
	SENDENTITY_ANGLE(v_angle[2], PLAYER_ANGLES)
	SENDENTITY_ANGLE(angles[0], PLAYER_ANGLES)
	SENDENTITY_ANGLE(angles[1], PLAYER_ANGLES)
	SENDENTITY_ANGLE(angles[2], PLAYER_ANGLES)
	SENDENTITY_COORD(velocity[0], PLAYER_VELOCITY)
	SENDENTITY_COORD(velocity[1], PLAYER_VELOCITY)
	SENDENTITY_COORD(velocity[2], PLAYER_VELOCITY)
	SENDENTITY_COORD(basevelocity[0], PLAYER_VELOCITY)
	SENDENTITY_COORD(basevelocity[1], PLAYER_VELOCITY)
	SENDENTITY_COORD(basevelocity[2], PLAYER_VELOCITY)
	SENDENTITY_INT(flags, PLAYER_FLAGS)
	SENDENTITY_INT(gflags, PLAYER_FLAGS)
	SENDENTITY_INT(pmove_flags, PLAYER_FLAGS)
	SENDENTITY_BYTE(activeweapon, PLAYER_WEAPON)
	SENDENTITY_BYTE(weaponframe, PLAYER_WEAPON)
	SENDENTITY_INT(g_items, PLAYER_ITEMS)
	SENDENTITY_BYTE(health, PLAYER_HEALTH)
	SENDENTITY_BYTE(armor, PLAYER_HEALTH)
	SENDENTITY_COORD(mins[0], PLAYER_SIZE)
	SENDENTITY_COORD(mins[1], PLAYER_SIZE)
	SENDENTITY_COORD(mins[2], PLAYER_SIZE)
	SENDENTITY_COORD(maxs[0], PLAYER_SIZE)
	SENDENTITY_COORD(maxs[1], PLAYER_SIZE)
	SENDENTITY_COORD(maxs[2], PLAYER_SIZE)
	SENDENTITY_BYTE(view_ofs[2], PLAYER_SIZE)
	SENDENTITY_BYTE(movetype, PLAYER_MOVETYPE)
	SENDENTITY_BYTE(solid, PLAYER_MOVETYPE)
	SENDENTITY_FLOAT(punchangle[0], PLAYER_PUNCHANGLE)
	SENDENTITY_FLOAT(punchangle[1], PLAYER_PUNCHANGLE)
	SENDENTITY_FLOAT(punchangle[2], PLAYER_PUNCHANGLE)
	SENDENTITY_FLOAT(viewzoom, PLAYER_VIEWZOOM)
	SENDENTITY_FLOAT(teleport_time, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(weapontime, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(w_attack_next, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(w_idle_next, PLAYER_TIMINGS)
	SENDENTITY_ENTITY(vehicle, PLAYER_VEHICLE)
	SENDENTITY_BYTE(spec_ent, PLAYER_SPECTATE)
	SENDENTITY_BYTE(spec_mode, PLAYER_SPECTATE)
	SENDENTITY_BYTE(spec_flags, PLAYER_SPECTATE)

	return (1);
}

float
NSClientPlayer::OptimiseChangedFlags(entity ePEnt, float flChanged)
{
	bool is_spec = false;
	bool spectarget = false;

	/* figure out if we should optimise this player */
	if (ePEnt.flags & FL_CLIENT && ePEnt != this) {
		NSClientSpectator sp = (NSClientSpectator)ePEnt;
		is_spec = (sp.IsFakeSpectator() || sp.IsRealSpectator());
		spectarget = (is_spec == true && edict_num(sp.spec_ent) == this);
	}

	/* if we're a spectator of any type and spectate this player */
	if (ePEnt != this && spectarget == false) {
		flChanged &= ~PLAYER_ITEMS;
		//flChanged &= ~PLAYER_HEALTH;
		flChanged &= ~PLAYER_TIMINGS;
		flChanged &= ~PLAYER_AMMO1;
		flChanged &= ~PLAYER_AMMO2;
		flChanged &= ~PLAYER_AMMO3;
		//flChanged &= ~PLAYER_FLAGS;
		flChanged &= ~PLAYER_PUNCHANGLE;
		flChanged &= ~PLAYER_VIEWZOOM;
		flChanged &= ~PLAYER_SPECTATE;
	} else {
		/* always keep us alive to ourselves or the person spectating */
		/* this will make prediction smoother */
		flChanged |= PLAYER_MODELINDEX;
	}

	return flChanged;
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
		if (HasFlags(FL_USE_RELEASED) == false) {
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
	if (HasFlags(FL_USE_RELEASED) == false) {
		_NSClientPlayer_unuseworkaround(last_used);
		last_used = world;
		flags |= FL_USE_RELEASED;
	}
}
#endif

void
NSClientPlayer::Footsteps_Update(void)
{
#ifdef SERVER
	string mat_name = "";
	string tex_name = "";
	string sound = "";

	/* mp_footsteps is only available in MP matches */
	if (Util_IsSingleplayer() == false)
		if (autocvar(mp_footsteps, 1) == 0)
			return;

	if (movetype != MOVETYPE_WALK)
		return;

	if ((velocity[0] == 0 && velocity[1] == 0) || step_time > time)
		return;

	if (waterlevel == 1) {
		if (step)
			StartSoundDef("step_slosh.left", CHAN_BODY, true);
		else
			StartSoundDef("step_slosh.right", CHAN_BODY, true);

		step_time = time + 0.35f;
	} else if (waterlevel == 2) {
		if (step)
			StartSoundDef("step_wade.left", CHAN_BODY, true);
		else
			StartSoundDef("step_wade.right", CHAN_BODY, true);
		
		step_time = time + 1.0f;
	}  else if (waterlevel == 3) {
		if (step)
			StartSoundDef("step_swim.left", CHAN_BODY, true);
		else
			StartSoundDef("step_swim.right", CHAN_BODY, true);

		step_time = time + 2.0f;
	} else {
		/* make it so we step once we land */
		if (HasFlags(FL_ONGROUND | FL_ONLADDER) == false) {
			step_time = 0.0f;
			return;
		}
	}

	/* the footsteps call might overwrite this later */
	step_time = time + 0.35;

	//tracebox(origin, PHY_HULL_MIN, PHY_HULL_MAX, origin + [0,0,-48], MOVE_NORMAL, target);
	traceline(origin + view_ofs, origin + [0,0,-48], MOVE_NORMAL, this);
	tex_name = getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos));

	/* don't step in air */
	if (HasFlags(FL_ONGROUND | FL_ONLADDER) == false) {
		return;
	} else if (HasFlags(FL_ONLADDER) && HasFlags(FL_ONGROUND) == false) { /* play ladder sounds */
		if (step)
			StartSoundDef("step_ladder.left", CHAN_BODY, true);
		else
			StartSoundDef("step_ladder.right", CHAN_BODY, true);

		/* switch between feet */
		step = 1 - step;
		return;
	} else if (HasFlags(FL_ONLADDER) && HasFlags(FL_ONGROUND)) { /* at a ladder, but not moving */
		return;
	}

	if (step) {
		StartSoundDef(
			SurfData_GetInfo(SurfData_TexToSurfData(tex_name), SURFDATA_SND_STEPLEFT),
			CHAN_BODY,
			true);
	} else {
		StartSoundDef(
			SurfData_GetInfo(SurfData_TexToSurfData(tex_name), SURFDATA_SND_STEPRIGHT),
			CHAN_BODY,
			true);
	}

	/* switch between feet */
	step = 1 - step;
#endif
}
