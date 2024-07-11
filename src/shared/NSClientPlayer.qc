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
NSClientPlayer::NSClientPlayer(void)
{
	flags |= FL_CLIENT;
	vehicle = __NULL__;
}

NSWeapon GetWeaponEntity(int theclientsnumber)
{
	entity e = edict_num((float)theclientsnumber); //can return world when out of range...

	if (wasfreed(e))
		e = world; //might have been freed...

	return e; 
}

void
NSClientPlayer::SharedInputFrame(void)
{
	/* if spectator, we want to make sure we call this */
	if (!Client_InIntermission() && IsFakeSpectator()) {
		NSClientSpectator::SharedInputFrame();
		return;
	}

#ifdef SERVER
	if (input_cursor_entitynumber) {
		NSWeapon nextWeapon = GetWeaponEntity(input_cursor_entitynumber);

		if (nextWeapon != m_activeWeapon) {
			if (nextWeapon && HasExactItem(nextWeapon)) {
				m_activeWeapon = nextWeapon;
				m_activeWeapon._SwitchedToCallback();
			}
		}
	}
#endif
}

bool
NSClientPlayer::IsRealSpectator(void)
{
	return (false);
}

bool
NSClientPlayer::IsDead(void)
{
	return (health > 0) ? (false) : true;
}

bool
NSClientPlayer::IsPlayer(void)
{
	return !HasVFlags(VFL_FAKESPEC);
}

bool
NSClientPlayer::IsFakeSpectator(void)
{
	return HasVFlags(VFL_FAKESPEC);
}

bool
NSClientPlayer::CanSprint(void)
{
	return g_pmoveVars.pm_runspeed > 0 ? (true) : false;
}

bool
NSClientPlayer::CanProne(void)
{
	return g_pmoveVars.pm_proneheight > 0 ? (true) : false;
}

bool
NSClientPlayer::CanLean(void)
{
	return (true);
}

bool
NSClientPlayer::CanCrouch(void)
{
	return g_pmoveVars.pm_crouchheight > 0 ? (true) : false;
}

void
NSClientPlayer::PreFrame(void)
{
#ifdef CLIENT
	if (Util_IsPaused()) {
		return;
	}

	/* this is where a game/mod would decide to add more prediction rollback
	 * information. */
	PredictPreFrame();

	NSItem itemEntry = m_itemList;

	while (itemEntry) {
		itemEntry.PredictPreFrame();
		itemEntry = (NSItem)itemEntry.chain;
	}

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
	if (Util_IsPaused()) {
		return;
	}

	/* give the game/mod a chance to roll back its values too */
	PredictPostFrame();

	NSItem itemEntry = m_itemList;

	while (itemEntry) {
		itemEntry.PredictPostFrame();
		itemEntry = (NSItem)itemEntry.chain;
	}

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

	//printf("%d\n", input_buttons);

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
		if (input_buttons & INPUT_PRIMARY)
			rules.PlayerRequestRespawn(this);
	}

	/* handle use button presses */
	if (input_buttons & INPUT_USE)
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
		if (m_activeWeapon) {
			m_activeWeapon.Release();
		}

		return;
	}

	if (!m_activeWeapon) {
		return;
	}

	/* weapon system */
	if (input_buttons & INPUT_SECONDARY)
		m_activeWeapon.SecondaryAttack();
	else if (input_buttons & INPUT_PRIMARY)
		m_activeWeapon.PrimaryAttack();
	else if (input_buttons & INPUT_RELOAD)
		m_activeWeapon.Reload();
	else
		m_activeWeapon.Release();
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
		p_model.effects = 0; /* we want p-models to cast shadows, just like players */
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
			input_buttons = (flags & FL_JUMPRELEASED) ? 0 : INPUT_JUMP; /* this may not help that much... */
			input_buttons |= IsCrouching() ? INPUT_CROUCH : 0;
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
	if (localplayer && HasVFlags(VFL_INVEHICLE)) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh)
			localplayer = veh.HidePlayermodel();
	}

	p_model.SetRenderMode(GetRenderMode());
	p_model.SetRenderColor(GetRenderColor());
	p_model.SetRenderFX(GetRenderFX());
	p_model.SetRenderAmt(GetRenderAmt());

	/* if we're forcing third-person.. or this is not us - render this player */
	if (autocvar_pm_thirdPerson == TRUE || !localplayer) {
		/* mark as not-mirror-only */
		renderflags &= ~RF_EXTERNALMODEL;

		/* same for our attachment */
		p_model.renderflags &= ~RF_EXTERNALMODEL;

		/* let mods override attachments and whatnot */
		UpdatePlayerAttachments(true);

		/* draw a 3D voice blob over its head */
		Voice_Draw3D(this);

		if (m_activeWeapon)
			m_activeWeapon.ClientFX(true);

		/* force drawing us if it's our local player and we're meant to show */
		if (entnum == player_localentnum)
			g_view.SetDrawLocalPlayer(true);

	} else { /* we're doing first person stuff */
		/* flags that the model appear in mirrors only */
		renderflags |= RF_EXTERNALMODEL;
		p_model.renderflags |= RF_EXTERNALMODEL;

		/* give mods a chance to de-render attachments */
		UpdatePlayerAttachments(true);

		/* this is here just to make sure our view hides us if it's the local player */
		if (entnum == player_localentnum)
			g_view.SetDrawLocalPlayer(false);
	}

	if (p_model) {
		p_model.entnum = entnum;
		p_model.drawmask = 0;

		if (p_model.GetRenderMode() != RM_DONTRENDER)
			addentity(p_model);

		p_model.entnum = 0;
	}

	/* this needs to be called absolutely last */
	/* we're calling this so that the shadow can still be drawn */
	if (GetRenderMode() != RM_DONTRENDER)
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
	NSWeapon oldWeapon = m_activeWeapon;

	if (!vehicle_entnum)
		vehicle = __NULL__;
	else
		vehicle = findentity(world, ::entnum, vehicle_entnum);

	if (!activeweapon)
		m_activeWeapon = __NULL__;
	else
		m_activeWeapon = (NSWeapon)findentity(world, ::entnum, activeweapon);

	if (!m_flFirstInventoryItem)
		m_itemList = __NULL__;
	else {
		m_itemList = (NSItem)findentity(world, ::entnum, m_flFirstInventoryItem);
	}

	/* that state has only just changed. */
	if (oldWeapon != __NULL__ && m_activeWeapon == __NULL__) {
		oldWeapon._SwitchedFromCallback();
	}

	if (m_activeWeapon != __NULL__ && oldWeapon == __NULL__) {
		m_activeWeapon.SetOwner(this);
		m_activeWeapon._SwitchedToCallback();
		m_activeWeapon._AddedCallback();
	}
}

void
NSClientPlayer::OnRemoveEntity(void)
{
	if (p_model)
		p_model.Destroy();

	super::OnRemoveEntity();
}

vector
NSClientPlayer::CalculateLean(vector viewAngle)
{
	vector shift = anglesToRight(viewAngle);
	vector output;
	vector srcPos;
	float heightChange;
	NSClientPlayer pl = (NSClientPlayer)pSeat->m_ePlayer;

	if (pSeat->m_iLeanDir > 0i) {
		pSeat->m_flLeaning += frametime * 5;
	} else if (pSeat->m_iLeanDir < 0i) {
		pSeat->m_flLeaning -= frametime * 5;
	} else {
		pSeat->m_flLeaning = lerp(pSeat->m_flLeaning, 0.0, frametime * 10);
	}

	if (pSeat->m_flLeaning > 1.0) {
		pSeat->m_flLeaning = 1.0f;
	}

	if (pSeat->m_flLeaning < -1.0) {
		pSeat->m_flLeaning = -1.0f;
	}

	heightChange = cos(pSeat->m_flLeaning) * 4;
	srcPos = pl.GetEyePos();
	output = shift * (pSeat->m_flLeaning * 15.0);
	tracebox(srcPos, [-8,-8,-8], [8,8,8], srcPos + output, MOVE_NORMAL, pl);

	return output * trace_fraction + (shift * -1.0) + [0, 0, heightChange];
}

void
NSClientPlayer::UpdateAliveCam(void)
{
	vector cam_pos = GetEyePos();

#if defined(VALVE) || defined(CSTRIKE) || defined(GEARBOX) || defined(TFC)
	//view_angles = Camera_RunBob(view_angles);
	//view_angles = Camera_StrafeRoll(view_angles);
	cam_pos += CalculateLean(view_angles);
	g_view.SetCameraAngle(view_angles);
	g_view.SetCameraOrigin(cam_pos );
#else
	view_angles = Camera_RunBob(view_angles);
	view_angles = Camera_StrafeRoll(view_angles);
	cam_pos += CalculateLean(view_angles);
	g_view.SetCameraAngle(view_angles);
	g_view.SetCameraOrigin(cam_pos + Camera_AddCamBob(view_angles));
#endif

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

var float autocvar_cl_forwardspeed = 190;
var float autocvar_cl_sidespeed = 152;
var float autocvar_cl_backspeed = 133;

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

	if (pSeat->m_iInputAttack2 == true) {
		input_buttons |= INPUT_SECONDARY;
	}
	if (pSeat->m_iInputReload == true) {
		input_buttons |= INPUT_RELOAD;
	}
	if (pSeat->m_iInputUse == true) {
		input_buttons |= INPUT_USE;
	}
	if (pSeat->m_iInputDuck == true) {
		input_buttons |= INPUT_CROUCH;
	}
	if (pSeat->m_iInputProne == true) {
		input_buttons |= INPUT_PRONE;
	}
	if (pSeat->m_iInputSprint == true) {
		input_buttons |= INPUT_SPRINT;
	}
	if (pSeat->m_iInputJump == true) {
		input_buttons |= INPUT_JUMP;
	}

	if (pSeat->m_iHUDWeaponSelected)
		input_cursor_entitynumber = pSeat->m_iHUDWeaponSelected;

	/* IW style stance override */
	if (pSeat->m_dForceStance == STANCE_CROUCH) {
		input_buttons |= INPUT_CROUCH;
	} else if (pSeat->m_dForceStance == STANCE_PRONE) {
		input_buttons |= INPUT_PRONE;
	}

#if 0
	/* The HUD needs more time */
	if (pSeat->m_iHUDWeaponSelected) {
		if ((input_buttons & INPUT_PRIMARY))
			HUD_DrawWeaponSelect_Trigger();
		else if ((input_buttons & INPUT_SECONDARY))
			pSeat->m_iHUDWeaponSelected = pSeat->m_flHUDWeaponSelectTime = 0;

		pSeat->m_flInputBlockTime = time + 0.2;
	}
#endif

	/* prevent accidental input packets */
	if (pSeat->m_flInputBlockTime > time) {
		input_buttons &= ~INPUT_PRIMARY;
		input_buttons &= ~INPUT_SECONDARY;
		pSeat->m_iInputAttack2 = false;
		return;
	}

	/* some input overrides for XR */
	if (XR_Available(this)) {
		if (pSeat->m_bMoveForward) {
			input_movevalues[0] = 100;
		}

		if (pSeat->m_iInputAttack) {
			input_buttons |= INPUT_PRIMARY;
		}
	}

	/* compat */
	if (input_impulse == 201) {
		sendevent("Spraylogo", "");
	}

	if (pSeat->m_flCameraTime > time) {
		/* TODO: Supress the changing of view_angles/input_angles. */
	}

	vector movementDir = vectorNormalize(input_movevalues);

	/* normalize movement values */
	input_movevalues[0] = movementDir[0] * fabs(input_movevalues[0]);
	input_movevalues[1] = movementDir[1] * fabs(input_movevalues[1]);

	//if (mode_tempstate == 0)
	if (input_movevalues[0] > 0)
	if (pSeat->m_iSprinting == true) {
		input_buttons |= INPUT_SPRINT;
		input_movevalues[0] *= 1.5f;
		input_movevalues[1] *= 1.5f;
		input_movevalues[2] *= 1.5f;

		/* prevent firing of weapons */
		input_buttons &= ~INPUT_PRIMARY;
		input_buttons &= ~INPUT_SECONDARY;
		input_buttons &= ~INPUT_RELOAD;
	} else {
		input_buttons &= ~INPUT_SPRINT;
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

	if (new) {
		classname = "player";
	}

	READENTITY_INT(modelindex, PLAYER_MODELINDEX)
	READENTITY_BYTE(colormap, PLAYER_MODELINDEX)

	/* crap the render mode updates in here */
	READENTITY_BYTE(m_iRenderMode, PLAYER_MODELINDEX)
	READENTITY_BYTE(m_iRenderFX, PLAYER_MODELINDEX)
	READENTITY_FLOAT(m_vecRenderColor[0], PLAYER_MODELINDEX)
	READENTITY_FLOAT(m_vecRenderColor[1], PLAYER_MODELINDEX)
	READENTITY_FLOAT(m_vecRenderColor[2], PLAYER_MODELINDEX)
	READENTITY_FLOAT(m_flRenderAmt, PLAYER_MODELINDEX)

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
	READENTITY_COORD(grapvelocity[0], PLAYER_VELOCITY)
	READENTITY_COORD(grapvelocity[1], PLAYER_VELOCITY)
	READENTITY_COORD(grapvelocity[2], PLAYER_VELOCITY)
	READENTITY_INT(flags, PLAYER_FLAGS)
	READENTITY_INT(vv_flags, PLAYER_FLAGS)
	READENTITY_INT(gflags, PLAYER_FLAGS)
	READENTITY_INT(pmove_flags, PLAYER_FLAGS)
	READENTITY_ENTNUM(m_flFirstInventoryItem, PLAYER_ITEMS)
	READENTITY_ENTNUM(activeweapon, PLAYER_WEAPON)
	READENTITY_BYTE(weaponframe, PLAYER_WEAPONFRAME)
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
	READENTITY_FLOAT(m_flStamina, PLAYER_TIMINGS)
	READENTITY_FLOAT(weapontime, PLAYER_TIMINGS)
	READENTITY_FLOAT(w_attack_next, PLAYER_TIMINGS)
	READENTITY_FLOAT(w_idle_next, PLAYER_TIMINGS)
	READENTITY_ENTNUM(vehicle_entnum, PLAYER_VEHICLE)
	READENTITY_BYTE(spec_ent, PLAYER_SPECTATE)
	READENTITY_BYTE(spec_mode, PLAYER_SPECTATE)
	READENTITY_BYTE(spec_flags, PLAYER_SPECTATE)

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		READENTITY_INT(m_iAmmoTypes[i], PLAYER_AMMOTYPES)
	}

	if (flChanged & PLAYER_AMMOTYPES) {
		HUD_AmmoNotify_Check(this);
	}

	/* the entities might not be networked yet,
	   so by tracking desired entnums and updating
	   them every time they change is sensible. */
	if (flChanged & PLAYER_VEHICLE) {
		vehicle = __NULL__;
	}

	if (flChanged & PLAYER_WEAPON) {
		m_activeWeapon = __NULL__;
	}

	if (flChanged & PLAYER_ITEMS) {
		m_itemList = __NULL__;
	}

	/* only do as often as necessary */
	if ((vehicle_entnum && !vehicle) || (m_flFirstInventoryItem && !m_itemList) || (activeweapon && !m_activeWeapon))
		VehicleRelink();

	PredictPreFrame();

	if (flChanged & PLAYER_SIZE)
		setsize(this, mins, maxs);

	Relink();

	if (flChanged & PLAYER_SPECTATE) {
		m_flLastSpecTargetChange = time;
	}
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
	if (m_activeWeapon)
		m_activeWeapon.PredictPreFrame();

	SAVE_STATE(modelindex)
	SAVE_STATE(origin)
	SAVE_STATE(v_angle)
	SAVE_STATE(angles)
	SAVE_STATE(colormap)
	SAVE_STATE(velocity)
	SAVE_STATE(basevelocity)
	SAVE_STATE(grapvelocity)
	SAVE_STATE(flags)
	SAVE_STATE(vv_flags)
	SAVE_STATE(gflags)
	SAVE_STATE(pmove_flags)
	SAVE_STATE(m_itemList)
	SAVE_STATE(m_activeWeapon)
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
	SAVE_STATE(m_flStamina)
	SAVE_STATE(weapontime)
	SAVE_STATE(w_attack_next)
	SAVE_STATE(w_idle_next)
	SAVE_STATE(vehicle_entnum)
	SAVE_STATE(spec_ent)
	SAVE_STATE(spec_mode)
	SAVE_STATE(spec_flags)

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		m_iAmmoTypes_net[i] = m_iAmmoTypes[i];
	}
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
	ROLL_BACK(basevelocity)
	ROLL_BACK(grapvelocity)
	ROLL_BACK(flags)
	ROLL_BACK(vv_flags)
	ROLL_BACK(gflags)
	ROLL_BACK(pmove_flags)
	ROLL_BACK(m_itemList)
	ROLL_BACK(m_activeWeapon)
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
	ROLL_BACK(m_flStamina)
	ROLL_BACK(weapontime)
	ROLL_BACK(w_attack_next)
	ROLL_BACK(w_idle_next)
	ROLL_BACK(vehicle_entnum)
	ROLL_BACK(spec_ent)
	ROLL_BACK(spec_mode)
	ROLL_BACK(spec_flags)

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		m_iAmmoTypes[i] = m_iAmmoTypes_net[i];
	}

	if (m_activeWeapon) {
		m_activeWeapon.PredictPostFrame();
	}
}
#else
void
NSClientPlayer::ServerInputFrame(void)
{
#ifdef BOT_INCLUDED
	/* wait a few seconds, as we may not have been spawned yet */
	if (clienttype(this) == CLIENTTYPE_BOT) {
		((NSBot)this).RunAI();
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
	SaveFloat(handle, "vv_flags", vv_flags);
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
	SaveFloat(handle, "m_flStamina", m_flStamina);
	SaveInt(handle, "weaponframe", weaponframe);
	SaveFloat(handle, "weapontime", weapontime);
	SaveInt(handle, "g_items", g_items);
	SaveEntity(handle, "m_itemList", m_itemList);
	SaveEntity(handle, "m_activeWeapon", m_activeWeapon);
	SaveEntity(handle, "vehicle", vehicle);
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
	case "vv_flags":
		vv_flags = ReadFloat(strValue);
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
	case "m_flStamina":
		m_flStamina = ReadFloat(strValue);
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
	case "m_itemList":
		m_itemList = ReadEntity(strValue);
		break;
	case "m_activeWeapon":
		m_activeWeapon = ReadEntity(strValue);
		break;
	case "vehicle":
		vehicle = ReadEntity(strValue);
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
	AddVFlags(VFL_FAKESPEC);
	max_health = health = 0;
	armor = 0;
	g_items = 0;

	if (m_activeWeapon) {
		m_activeWeapon.Destroy();
		m_activeWeapon = __NULL__;
	}

	if (m_itemList) {
		m_itemList.Destroy();
		m_itemList = __NULL__;
	}

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
NSClientPlayer::Death(entity inflictor, entity attacker, int damage, vector dir, int location)
{
	classname = "player";
	health = max_health = 0;
	armor = 0;
	g_items = 0;

	if (m_activeWeapon) {
		m_activeWeapon.Destroy();
		m_activeWeapon = __NULL__;
	}

	if (m_itemList) {
		m_itemList.Destroy();
		m_itemList = __NULL__;
	}

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
	DisableBleeding();
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
	AddFlags(FL_CLIENT);
	RemoveVFlags(VFL_FAKESPEC);

	if (health <= 0) {
		health = max_health = 100;
		armor = 0;
	}

	if (m_activeWeapon) {
		m_activeWeapon.Destroy();
		m_activeWeapon = __NULL__;
	}

	if (m_itemList) {
		m_itemList.Destroy();
		m_itemList = __NULL__;
	}

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
	EnableBleeding();
	scale = 1.0f;
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	forceinfokey(this, "*spectator", "0");
	forceinfokey(this, "*deaths", ftos(deaths));
	forceinfokey(this, "*dead", "0");
	forceinfokey(this, "*spec", "0");
}

void
NSClientPlayer::MakeSpectator(void)
{
	ClientKill();
	MakeTempSpectator();
	team = 0;
	forceinfokey(this, "*team", ftos(team)); 
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
	pvsflags = !HasVFlags(VFL_FAKESPEC) ? 0 : PVSF_IGNOREPVS;

	EVALUATE_FIELD(modelindex, PLAYER_MODELINDEX)
	EVALUATE_FIELD(colormap, PLAYER_MODELINDEX)

	/* crap the render mode updates in here */
	EVALUATE_FIELD(m_iRenderMode, PLAYER_MODELINDEX)
	EVALUATE_FIELD(m_iRenderFX, PLAYER_MODELINDEX)
	EVALUATE_VECTOR(m_vecRenderColor, 0, PLAYER_MODELINDEX)
	EVALUATE_VECTOR(m_vecRenderColor, 1, PLAYER_MODELINDEX)
	EVALUATE_VECTOR(m_vecRenderColor, 2, PLAYER_MODELINDEX)
	EVALUATE_FIELD(m_flRenderAmt, PLAYER_MODELINDEX)

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
	EVALUATE_VECTOR(grapvelocity, 0, PLAYER_VELOCITY)
	EVALUATE_VECTOR(grapvelocity, 1, PLAYER_VELOCITY)
	EVALUATE_VECTOR(grapvelocity, 2, PLAYER_VELOCITY)
	EVALUATE_FIELD(flags, PLAYER_FLAGS)
	EVALUATE_FIELD(vv_flags, PLAYER_FLAGS)
	EVALUATE_FIELD(gflags, PLAYER_FLAGS)
	EVALUATE_FIELD(pmove_flags, PLAYER_FLAGS)
	EVALUATE_FIELD(m_itemList, PLAYER_ITEMS)
	EVALUATE_FIELD(m_activeWeapon, PLAYER_WEAPON)
	EVALUATE_FIELD(weaponframe, PLAYER_WEAPONFRAME)
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
	EVALUATE_FIELD(m_flStamina, PLAYER_TIMINGS)
	EVALUATE_FIELD(weapontime, PLAYER_TIMINGS)
	EVALUATE_FIELD(w_attack_next, PLAYER_TIMINGS)
	EVALUATE_FIELD(w_idle_next, PLAYER_TIMINGS)
	EVALUATE_FIELD(vehicle, PLAYER_VEHICLE)
	EVALUATE_FIELD(spec_ent, PLAYER_SPECTATE)
	EVALUATE_FIELD(spec_mode, PLAYER_SPECTATE)
	EVALUATE_FIELD(spec_flags, PLAYER_SPECTATE)

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		EVALUATE_VECTOR(m_iAmmoTypes, i, PLAYER_AMMOTYPES)
	}
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
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_INT(modelindex, PLAYER_MODELINDEX)
	SENDENTITY_BYTE(colormap, PLAYER_MODELINDEX)

	/* crap the render mode updates in here */
	SENDENTITY_BYTE(m_iRenderMode, PLAYER_MODELINDEX)
	SENDENTITY_BYTE(m_iRenderFX, PLAYER_MODELINDEX)
	SENDENTITY_FLOAT(m_vecRenderColor[0], PLAYER_MODELINDEX)
	SENDENTITY_FLOAT(m_vecRenderColor[1], PLAYER_MODELINDEX)
	SENDENTITY_FLOAT(m_vecRenderColor[2], PLAYER_MODELINDEX)
	SENDENTITY_FLOAT(m_flRenderAmt, PLAYER_MODELINDEX)

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
	SENDENTITY_COORD(grapvelocity[0], PLAYER_VELOCITY)
	SENDENTITY_COORD(grapvelocity[1], PLAYER_VELOCITY)
	SENDENTITY_COORD(grapvelocity[2], PLAYER_VELOCITY)
	SENDENTITY_INT(flags, PLAYER_FLAGS)
	SENDENTITY_INT(vv_flags, PLAYER_FLAGS)
	SENDENTITY_INT(gflags, PLAYER_FLAGS)
	SENDENTITY_INT(pmove_flags, PLAYER_FLAGS)
	SENDENTITY_ENTITY(m_itemList, PLAYER_ITEMS)
	SENDENTITY_ENTITY(m_activeWeapon, PLAYER_WEAPON)
	SENDENTITY_BYTE(weaponframe, PLAYER_WEAPONFRAME)
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
	SENDENTITY_FLOAT(m_flStamina, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(weapontime, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(w_attack_next, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(w_idle_next, PLAYER_TIMINGS)
	SENDENTITY_ENTITY(vehicle, PLAYER_VEHICLE)
	SENDENTITY_BYTE(spec_ent, PLAYER_SPECTATE)
	SENDENTITY_BYTE(spec_mode, PLAYER_SPECTATE)
	SENDENTITY_BYTE(spec_flags, PLAYER_SPECTATE)

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		SENDENTITY_INT(m_iAmmoTypes[i], PLAYER_AMMOTYPES)
	}

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
	eActivator = (NSEntity)self;
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
	eActivator = (NSEntity)self;
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
	if (IsDead()) {
		return;
	} else if (!(vv_flags & VFL_USE_RELEASED)) {
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
		RemoveVFlags(VFL_USE_RELEASED);
		_NSClientPlayer_useworkaround(eRad);
		last_used = eRad;

		/* Some entities want to support Use spamming */
		if (HasVFlags(VFL_USE_RELEASED) == false) {
			StartSoundDef("Player.WeaponSelected", CHAN_ITEM, false);
		}
	} else {
		StartSoundDef("Player.DenyWeaponSelection", CHAN_ITEM, false);
		RemoveVFlags(VFL_USE_RELEASED);
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
	if (HasVFlags(VFL_USE_RELEASED) == false) {
		_NSClientPlayer_unuseworkaround(last_used);
		last_used = world;
		AddVFlags(VFL_USE_RELEASED);
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
		StartSoundDef("Player.Wade", CHAN_BODY, true);
		step_time = time + 2.0f;
		return;
	} else if (waterlevel == 2) {
		StartSoundDef("Player.Wade", CHAN_BODY, true);
		step_time = time + 2.0f;
		return;
	}  else if (waterlevel == 3) {
		StartSoundDef("Player.Swim", CHAN_BODY, true);
		step_time = time + 2.0f;
		return;
	} else {
		/* make it so we step once we land */
		if (HasFlags(FL_ONGROUND) == false && HasVFlags(VFL_ONLADDER) == false) {
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
	if (HasFlags(FL_ONGROUND) == false && HasVFlags(VFL_ONLADDER) == false) {
		return;
	} else if (HasVFlags(VFL_ONLADDER) && HasFlags(FL_ONGROUND) == false) { /* play ladder sounds */
		if (step)
			StartSoundDef("step_ladder.left", CHAN_BODY, true);
		else
			StartSoundDef("step_ladder.right", CHAN_BODY, true);

		/* switch between feet */
		step = 1 - step;
		return;
	} else if (HasVFlags(VFL_ONLADDER) && HasFlags(FL_ONGROUND)) { /* at a ladder, but not moving */
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

void
NSClientPlayer::Damage(entity inflictor, entity attacker, string damageDef, float damageScale, vector dmgDir, vector hitLocation)
{
#ifdef SERVER
	super::Damage(inflictor, attacker, damageDef, damageScale, dmgDir, hitLocation);

#if 0
	bool isFriendlyFire = false;

	/* Damage */
	NSSurfacePropEntity eTarget = (NSSurfacePropEntity)t;

	/* sanity check */
	if (t.takedamage == DAMAGE_NO)
		return;

	/* for armor damage */
	float flArmor = 0;
	float flNewDamage = 0;

	/* player god mode */
	if (eTarget.flags & FL_CLIENT && eTarget.flags & FL_GODMODE)
		return;

	/* friendly fire check */
	if (t != c) {
		if (IsTeamplay()) {
			if (t.flags & FL_CLIENT && c.flags & FL_CLIENT) {
				if (t.team == c.team) {
					if (autocvar_sv_friendlyFire == false) {
						return;
					} else {
						isFriendlyFire = true;
					}
				}
			}
		}
	}

	/* already dead, please avoid recursion */
	if (eTarget.GetHealth() <= 0)
		return;

	/* before any calculation is done... */
	g_dmg_iRealDamage = dmg;

	/* only clients have armor */
	if (eTarget.flags & FL_CLIENT) {
		NSClientPlayer tp = (NSClientPlayer)t;

		/* don't allow any damage */
		if (PlayerCanAttack(tp) == false) {
			g_dmg_eAttacker = (NSEntity)c;
			g_dmg_eTarget = (NSEntity)t;
			g_dmg_iDamage = 0;
			g_dmg_iHitBody = 0;
			g_dmg_iFlags = type;
			g_dmg_iWeapon = w;
			return;
		}

		/* skip armor */
		if not (type & DMG_SKIP_ARMOR)
		if (tp.armor && dmg > 0) {

			flNewDamage = dmg * 0.2;
			flArmor = (dmg - flNewDamage) * 0.5;

			if (flArmor > tp.armor) {
				flArmor = tp.armor;
				flArmor *= (1/0.5);
				flNewDamage = dmg - flArmor;
				tp.armor = 0;
			} else {
				tp.armor -= flArmor;
			}
			dmg = flNewDamage;
		}
	}

	dmg = rint(dmg);
	eTarget.SetHealth(eTarget.GetHealth() - dmg);

	/* the globals... */
	g_dmg_eAttacker = (NSEntity)c;
	g_dmg_eTarget = (NSEntity)t;
	g_dmg_iDamage = dmg;
	g_dmg_iHitBody = trace_surface_id;
	g_dmg_iFlags = type;
	g_dmg_iWeapon = w;

	NSLog("%S does %d dmg to %S (body: %d, flags: %i, weapon: %i)",
		c.classname, dmg, t.classname, g_dmg_iHitBody, g_dmg_iFlags, g_dmg_iWeapon);

	/* friendly fire penalty */
	if (isFriendlyFire) {
		int lastDmg = 0i;
		NSClientPlayer plC = (NSClientPlayer)c;
		lastDmg = plC.m_iFriendlyDMG;
		plC.m_iFriendlyDMG += dmg;

		/* kick the client. */
		if (plC.m_iFriendlyDMG >= autocvar_mp_td_dmgToKick) {
			NSLog("Kicking %S due to team damage rules.", plC.netname);
			dropclient(plC);
		} else if (plC.m_iFriendlyDMG >= autocvar_mp_td_dmgToWarn) {
			if (lastDmg < autocvar_mp_td_dmgToKick) {
				// warn player here
				sprint(plC, PRINT_CHAT, "Keep attacking teammates and you will be kicked!\n");
			}
		}

		bprint(PRINT_CHAT, sprintf("%s ^7attacked a teammate.\n", c.netname));
	}

	if (dmg > 0 || flArmor > 0) {
		vector dmg_origin;

		if (c.origin == [0,0,0])
			dmg_origin = g_dmg_eTarget.origin;
		else
			dmg_origin = g_dmg_eAttacker.origin;

		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_DAMAGE);
		WriteCoord(MSG_MULTICAST, dmg_origin[0]);
		WriteCoord(MSG_MULTICAST, dmg_origin[1]);
		WriteCoord(MSG_MULTICAST, dmg_origin[2]);
		WriteInt(MSG_MULTICAST, g_dmg_iRealDamage);
		WriteInt(MSG_MULTICAST, g_dmg_iFlags);
		msg_entity = g_dmg_eTarget;
		multicast([0,0,0], MULTICAST_ONE_R);
	}

	/* only hit notify on clients */
	if ((g_dmg_eTarget.flags & FL_CLIENT) || (g_dmg_eTarget.flags & FL_MONSTER)) {
		/* server-side hitnotify */
		if ((g_dmg_eAttacker.flags & FL_CLIENT) && (g_dmg_eTarget != g_dmg_eAttacker)) {
			WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
			WriteByte(MSG_MULTICAST, EV_HITNOTIFY);
			msg_entity = c;
			multicast([0,0,0], MULTICAST_ONE);
		}
	}

	/* they died */
	if (eTarget.GetHealth() <= 0) {
		if (eTarget.flags & FL_CLIENT) {
			PlayerDeath(eTarget);
		} else {
			eTarget.Death();
		}
	} else {
		if (eTarget.flags & FL_CLIENT) {
			PlayerPain(eTarget);
		} else {
			eTarget.Pain();
		}
	}
#endif
#endif
}