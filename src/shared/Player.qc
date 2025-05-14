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
ncPlayer::ncPlayer(void)
{
	_isPlayer = true;
	vehicle = __NULL__;
	anim_top = 0;
	anim_top_time = 0;
	anim_top_delay = 0;
	anim_bottom = 0;
	anim_bottom_time = 0;
}

ncWeapon
GetWeaponEntity(int theclientsnumber)
{
	entity e = edict_num((float)theclientsnumber);

	if (wasfreed(e)) {
		e = world;
	}

	return e;
}


bool
ncPlayer::CanPickupEntity(ncEntity toPickUp, float massLimit, float sizeLimit)
{
	if (!toPickUp) {
		return (false);
	}

	if (massLimit > 0.0 && toPickUp.GetMovetype() == MOVETYPE_PHYSICS) {
		ncPhysicsEntity physicsEntity = (ncPhysicsEntity)toPickUp;
		float entityMass = physicsEntity.GetMass();

		if (entityMass > massLimit) {
			EntError("%s (%d) is above mass limit (%d kg > %d kg)", toPickUp.classname, num_for_edict(toPickUp), entityMass, massLimit);
			return (false);
		}
	}

	if (sizeLimit > 0.0) {
		vector entitySize = GetSize();

		/* if any dimension  is above the size limit, prevent it */
		if (entitySize[0] > sizeLimit ||
			entitySize[1] > sizeLimit ||
			entitySize[2] > sizeLimit) {
			EntError("%s (%d) is above size limit (%v > %d)", toPickUp.classname, num_for_edict(toPickUp), entitySize, sizeLimit);
			return (false);
		}
	}

	return (true);
}

void
ncPlayer::SharedInputFrame(void)
{
	/* if spectator, we want to make sure we call this */
	if (!Client_InIntermission() && IsFakeSpectator()) {
		ncSpectator::SharedInputFrame();
		return;
	}

#ifdef SERVER
	/* here is where we check if the clients' desired weapon object exists,
	   is valid and is assigned to us. clients may send outdated or straight
	   up bogus values to mess with the server game. any checks go here
	   as this is where they'll be received first. */
	if (input_cursor_entitynumber) {
		ncWeapon nextWeapon = GetWeaponEntity(input_cursor_entitynumber);

		/* might be nothing */
		if (nextWeapon != __NULL__) {
			/* item is not ours */
			if (nextWeapon.owner != this) {
				return;
			}

			/* item isn't a weapon */
			if (nextWeapon.IsWeapon() == false) {
				return;
			}
		}

		input_cursor_entitynumber = 0;

		if (nextWeapon != m_activeWeapon) {
			if (nextWeapon && HasExactItem(nextWeapon)) {
				ncWeapon oldWeapon = m_activeWeapon;
				m_activeWeapon = nextWeapon;
				m_activeWeapon._SwitchedToCallback();
				
				if (oldWeapon) {
					oldWeapon._SwitchedFromCallback();
				}
			}
		}
	}
#endif
}

bool
ncPlayer::IsRealSpectator(void)
{
	return (false);
}

bool
ncPlayer::IsDead(void)
{
	return (health > 0) ? (false) : true;
}

bool
ncPlayer::IsPlayer(void)
{
	return (true);
}

bool
ncPlayer::IsFakeSpectator(void)
{
	return HasVFlags(VFL_FAKESPEC);
}

bool
ncPlayer::CanSprint(void)
{
	if ((IsProne() == true) || (IsCrouching() == true))
		return (false);

	return m_pmoveVars.pm_runspeed > 0 ? (true) : false;
}

bool
ncPlayer::CanProne(void)
{
	return m_pmoveVars.pm_proneheight > 0 ? (true) : false;
}

bool
ncPlayer::CanLean(void)
{
	return (true);
}

bool
ncPlayer::CanCrouch(void)
{
	return m_pmoveVars.pm_crouchheight > 0 ? (true) : false;
}

void
ncPlayer::_UpdatePMoveVars(void)
{
	if (m_pmoveVars) {
		m_pmoveVars.Destroy();
		m_pmoveVars = 0;
	}

	m_pmoveVars = spawn(ncPMoveVars);
	m_pmoveVars.LinkToEntity(declclass);
}

void
ncPlayer::PreFrame(void)
{
#ifdef CLIENT
	if (Util_IsPaused()) {
		return;
	}

	/* this is where a game/mod would decide to add more prediction rollback
	 * information. */
	PredictPreFrame();

	ncItem itemEntry = m_itemList;

	while (itemEntry) {
		if (itemEntry.PredictPreFrame) {
			itemEntry.PredictPreFrame();
		}
		itemEntry = (ncItem)itemEntry.m_nextItem;
	}

	if (vehicle) {
		ncVehicle veh = (ncVehicle)vehicle;
		veh.PredictPreFrame();
	}

	/* run physics code for all the input frames which we've not heard back
	 * from yet. This continues on in Player_ReceiveEntity! */
	for (float i = sequence + 1; i <= clientcommandframe; i++) {
		bool inputPackets = getinputstate(i);

		if (inputPackets == false) {
			continue;
		}

		/* don't do partial frames, aka incomplete input packets */
		if (input_timelength <= 0) {
			break;
		}

		if (i == clientcommandframe){
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
ncPlayer::PostFrame(void)
{
#ifdef CLIENT
	if (Util_IsPaused()) {
		return;
	}

	/* give the game/mod a chance to roll back its values too */
	PredictPostFrame();

	ncItem itemEntry = m_itemList;

	while (itemEntry) {
		if (itemEntry.PredictPostFrame) {
			itemEntry.PredictPostFrame();
		}
		itemEntry = (ncItem)itemEntry.m_nextItem;
	}

	setorigin(this, origin);  /* update bounds */

	if (vehicle) {
		ncVehicle veh = (ncVehicle)vehicle;
		veh.PredictPostFrame();
		setorigin(veh, veh.origin);
	}
#endif
}

void
ncPlayer::ProcessInput(void)
{
	bool canfire = true;
	ncVehicle veh = (ncVehicle)vehicle;

	//printf("%d\n", input_buttons);

	if (Util_IsPaused())
		return;

	XR_InputFrame(this);

	if (!Client_InIntermission() && IsFakeSpectator()) {
		ncSpectator::ProcessInput();
		SpectatorTrackPlayer();
		return;
	}

	/* allow vehicles to prevent weapon logic from happening */
	if (vehicle && !Client_InIntermission()) {
		if (veh.PlayerInput)
			veh.PlayerInput();
	}

#ifdef SERVER
	ncRuleDelegate rules = (ncRuleDelegate)ncRuleDelegate::ActiveInstance();

	if (rules.m_iIntermission) {
		rules.IntermissionEnd();
		return;
	} else if (is.Alive(this) == false) {
		/* don't go when left click was held... */
		if (input_buttons & INPUT_PRIMARY && !(gflags & GF_SEMI_TOGGLED)) {
			if (TimeSinceDeath() > 1.0f) {
				rules.PlayerRequestRespawn(this);
			}
		} else if (input_buttons & INPUT_PRIMARY) {
			gflags &= ~GF_SEMI_TOGGLED; /* this is usually done in the weapon code, which won't be run. */
		}
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

	if (m_nuclideFlags & VFL_HOLDING) {
		canfire = false;
	}

	/* throw it if we're holding something */
	if (m_nuclideFlags & VFL_HOLDING && input_buttons & INPUT_PRIMARY) {
#ifdef SERVER
		ncEntity heldProp = (ncEntity)m_holdingEntity;
		m_holdingEntity = false;
		heldProp.m_holdingPlayer = __NULL__;
		heldProp.think = __NULL__;
		heldProp.nextthink = 0.0f;
		heldProp.m_lastHeldTime = time;
		heldProp.SetVelocity(anglesToForward(GetViewAngle()) * 1024.0f);
#endif
		m_nuclideFlags &= ~VFL_HOLDING;
	}

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

	if (wasfreed(m_activeWeapon)) {
		m_activeWeapon = __NULL__;
	}

	if (!m_activeWeapon) {
		return;
	}

	m_activeWeapon.velocity = velocity;
	m_activeWeapon.origin = origin;
	m_activeWeapon.Relink();

	m_activeWeapon.InputFrame();

	/* weapon system */
	if (input_buttons & INPUT_SECONDARY) {
		m_activeWeapon._SecondaryAttack();
	} else if (input_buttons & INPUT_PRIMARY) {
		m_activeWeapon._PrimaryAttack();
	} else if (input_buttons & INPUT_RELOAD) {
		m_activeWeapon.Reload();
	} else {
		m_activeWeapon._WeaponStoppedFiring();
		m_activeWeapon.Release();
	}
}

/* this is where it gets mod specific really fast,
   as some models may not even support skeletal animation */
void
ncPlayer::UpdatePlayerAnimation(float timelength)
{
	float maxTopTime;
	float maxBottomTime;
	vector forwardDir;

	if (!skeletonindex) {
		skeletonindex = skel_create(modelindex);
	}

	if (anim_top_delay <= 0.0f) {
		anim_top = m_actAim;
	}

	if (vlen(velocity) < 1) {
		if (IsCrouching()) {
			anim_bottom = m_actIdleCrouch;
		} else if (IsProne()) {
			anim_bottom = m_actIdleProne;
		} else {
			anim_bottom = m_actIdle;
		}
	} else if (vlen(velocity) < 150) {
		if (IsCrouching()) {
			anim_bottom = m_actWalkCrouch;
		} else if (IsProne()) {
			anim_bottom = m_actWalkProne;
		} else {
			anim_bottom = m_actWalk;
		}
	} else if (vlen(velocity) > 200) {
		if (IsCrouching()) {
			anim_bottom = m_actWalkCrouch;
		} else if (IsProne()) {
			anim_bottom = m_actWalkProne;
		} else {
			anim_bottom = m_actRun;
		}
	}

	if (anim_top == ACTIVITY_NOTFOUND) {
		if (m_actAim == ACTIVITY_NOTFOUND) {
			anim_top = anim_bottom;
		}
	}

	/* hack, we can't play the animations in reverse the normal way */
	if (frame1time < 0.0f) {
		frame1time = 10.0f;
	}

	angles[0] = 0.0f;
	angles[1] = v_angle[1];
	angles[2] = 0.0f;

	makevectors([0, v_angle[1], 0]);
	forwardDir = v_forward;
	float fCorrect = dotproduct(velocity, v_right) * 0.25f;

	/* Correct the legs */
	angles[1] -= fCorrect;

	if (HasVFlags(VFL_INVEHICLE)) {
		float rq = -1;
		ncVehicle veh = (ncVehicle)vehicle;

		if (veh) {
			rq = veh.DriverAnimation();
		}

		if (rq == -1) {
			//anim_top = ANIMATION_CAR_SIT_IDLE;
			//anim_bottom = ANIMATION_CAR_SIT_IDLE;
			angles = vehicle.angles;
		} else {
			anim_top = rq;
			anim_bottom = rq;
			angles = vehicle.angles;
		}
	}

	maxTopTime = frameduration(modelindex, anim_top);
	maxBottomTime = frameduration(modelindex, anim_bottom);

	if (anim_bottom_time > maxBottomTime) {
		anim_bottom_time = (anim_bottom_time - maxBottomTime);
	} else if (anim_bottom_time < 0.0f) {
		anim_bottom_time = (maxBottomTime - anim_bottom_time);
	}

	if (anim_top_time > maxTopTime) {
		anim_top_time = (anim_top_time - maxTopTime);
	} else if (anim_bottom_time < 0.0f) {
		anim_top_time = (maxTopTime - anim_top_time);
	}

	/* TODO: Needs interpolation */
	/* lower body */
	frame = anim_bottom;
	frame1time = anim_bottom_time;
	skel_build(skeletonindex, this, modelindex, 0, 0, 0, 1);

	// Build the top body
	frame = anim_top;
	frame1time = anim_top_time;
//  	lerpfrac = 1.0f;
	skel_build(skeletonindex, this, modelindex, 0.001, m_torsoFirst, m_torsoLast ); // The 0.0001 comes from a stupid bug?

	makevectors( [ 0, -fCorrect, 0 ] );
	skel_postmul_bone( skeletonindex, autocvar(skel_bone, 5), [0,0,0], v_forward );

	/* counter act our crouching spine animation */
	if (IsCrouching())
		makevectors( [ 0, -25, fCorrect ] );
	else
		makevectors( [ 0, v_angle[0] * 0.5f, fCorrect ] );

	skel_postmul_bone( skeletonindex, m_boneSpine, [0,0,0], v_forward );

	/* timer update last */
	/* top animation is always just being incremented */
	anim_top_time += timelength;
	anim_top_delay -= timelength;

	/* we may be walking backwards, thus decrement bottom */
	if (dotproduct(velocity, forwardDir) < 0) {
		anim_bottom_time -= timelength;
	} else {
		anim_bottom_time += timelength;
	}
}

void
ncPlayer::Event_DrawWeapon(void)
{
	PlayGesture(m_actDraw, -1);
}

void
ncPlayer::Event_FireWeapon(void)
{
	PlayGesture(m_actAttack, -1);
}

void
ncPlayer::Event_ReloadWeaponStart(void)
{
	PlayGesture(m_actReloadStart, -1);
}

void
ncPlayer::Event_ReloadWeapon(void)
{
	PlayGesture(m_actReload, -1);
}

void
ncPlayer::Event_ReloadWeaponEnd(void)
{
	PlayGesture(m_actReloadEnd, -1);
}

void
ncPlayer::Event_HolsterWeapon(void)
{
	PlayGesture(m_actHolster, -1);
}

void
ncPlayer::PlayGesture(float gestureAnim, float overrideTime)
{
	if (gestureAnim == ACTIVITY_NOTFOUND) {
		return;
	}

	if (overrideTime == -1) {
		overrideTime = frameduration(modelindex, gestureAnim);
	}

	anim_top = gestureAnim;
	anim_top_time = 0.0f;
	anim_top_delay = overrideTime;
}

#ifdef CLIENT
void
ncPlayer::UpdatePlayerJaw(float voip_volume)
{
}

void
ncPlayer::UpdatePlayerAttachments(bool visible)
{

}

float
ncPlayer::predraw(void)
{
	bool localplayer = false;

	ncPlayer cl = (ncPlayer)pSeat->m_ePlayer;

	/* figure out if this is the local player. it's either us or us spectating */
	if (Client_IsSpectator(cl)) {
		ncSpectator spec = (ncSpectator)pSeat->m_ePlayer;
		if (entnum == spec.m_spectatingEntity && spec.m_spectatingMode == SPECMODE_FIRSTPERSON) {
			localplayer = true;
		}
	} else {
		if (entnum == player_localentnum) {
			localplayer = true;
		}
	}

	if (!p_model) {
		p_model = spawn(ncRenderableEntity);
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

	/* looping idle noise */
	if (sndindex_idle != 0) {
		string sndSample = soundnameforindex(sndindex_idle);
		SoundDef_Precache(sndSample);
		SoundDef_Update(this, CHAN_VOICE, SoundDef_GetID(sndSample), 1.0);
	}

	if (sndindex_idle != clsndindex_idle) {
		if (sndindex_idle == 0) {
			SoundDef_Stop(this, CHAN_VOICE);
		}

		clsndindex_idle = sndindex_idle;
	}

	/* mouth flapping */
	UpdatePlayerJaw(getplayerkeyfloat(this.entnum - 1, "voiploudness"));

	/* apply any necessary filters from ncRenderableEntity */
	RenderFXPass();

	/* apply any fire effects, if we're burning (we're of type ncSurfacePropEntity that can burn) */
	RenderFire();

	/* if we're inside of a vehicle, it may want to hide or show us regardless */
	if (localplayer && HasVFlags(VFL_INVEHICLE)) {
		ncVehicle veh = (ncVehicle)vehicle;

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
ncPlayer::postdraw(void)
{
}

void
ncPlayer::VehicleRelink(void)
{
	ncWeapon oldWeapon = m_activeWeapon;

	if (!vehicle_entnum)
		vehicle = __NULL__;
	else
		vehicle = findentity(world, ::entnum, vehicle_entnum);

	if (!activeweapon)
		m_activeWeapon = __NULL__;
	else
		m_activeWeapon = (ncWeapon)findentity(world, ::entnum, activeweapon);

	if (!m_itemStart)
		m_itemList = __NULL__;
	else {
		m_itemList = (ncItem)findentity(world, ::entnum, m_itemStart);
	}

	/* that state has only just changed. */
	if (oldWeapon != __NULL__ && m_activeWeapon == __NULL__) {
		oldWeapon._SwitchedFromCallback();
	}

	/* complete new weapon */
	if (m_activeWeapon != __NULL__ && oldWeapon == __NULL__) {
		m_activeWeapon.SetOwner(this);
		m_activeWeapon._AddedCallback();
		m_activeWeapon._SwitchedToCallback();
	} else if (m_activeWeapon != __NULL__ && oldWeapon != m_activeWeapon) {
		m_activeWeapon._SwitchedToCallback();
	}
}

void
ncPlayer::OnRemoveEntity(void)
{
	if (p_model)
		p_model.Destroy();

	if (m_pmoveVars)
		m_pmoveVars.Destroy();

	super::OnRemoveEntity();
}

vector
ncPlayer::CalculateLean(vector viewAngle)
{
	vector shift = anglesToRight(viewAngle);
	vector output;
	vector srcPos;
	float heightChange;
	ncPlayer pl = (ncPlayer)pSeat->m_ePlayer;

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
ncPlayer::UpdateAliveCam(void)
{
	vector cam_pos = GetEyePos();

#if defined(VALVE) || defined(CSTRIKE) || defined(GEARBOX) || defined(TFC) || defined(REWOLF)
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
		ncVehicle veh = (ncVehicle)vehicle;

		if (veh.UpdateView)
			veh.UpdateView();
	} else if (health) {
		if (autocvar_pm_thirdPerson == TRUE) {
			makevectors(view_angles);
			vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + maxs[2]] + (v_right * 4);
			vector vEnd = vStart + (v_forward * -48) + (v_right * 4);
			traceline(vStart, vEnd, FALSE, this);
			g_view.SetCameraOrigin(trace_endpos + (v_forward * 5));
		}
	}

	Shake_Update(this);
	g_view.AddPunchAngle(m_punchAngle);
}

var float autocvar_cl_forwardspeed = 190;
var float autocvar_cl_sidespeed = 152;
var float autocvar_cl_backspeed = 133;

void
ncPlayer::ClientInputFrame(void)
{
	if (Util_IsPaused())
		return;

	/* fake spectators want the same input as real ones. */
	if (IsFakeSpectator()) {
		ncSpectator::ClientInputFrame();
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

	if (pSeat->m_iHUDWeaponSelected) {
		input_cursor_entitynumber = pSeat->m_iHUDWeaponSelected;
	} else {
		input_cursor_entitynumber = 0;
	}

	/* IW style stance override */
	if (pSeat->m_dForceStance == STANCE_CROUCH) {
		input_buttons |= INPUT_CROUCH;
	} else if (pSeat->m_dForceStance == STANCE_PRONE) {
		input_buttons |= INPUT_PRONE;
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
	} else {
		input_buttons &= ~INPUT_SPRINT;
	}

	input_movevalues[0] = floor(input_movevalues[0]);
	input_movevalues[1] = floor(input_movevalues[1]);
	input_movevalues[2] = floor(input_movevalues[2]);
}

void
ncPlayer::_ReceiveComplete(float flNew, float flChanged)
{

}

void
ncPlayer::ReceiveEntity(float new, float flChanged)
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

	READENTITY_INT(entityDefID, PLAYER_MODELINDEX)
	READENTITY_INT(modelindex, PLAYER_MODELINDEX)
	READENTITY_INT(vw_index, PLAYER_MODELINDEX)
	READENTITY_BYTE(colormap, PLAYER_MODELINDEX)

	/* crap the render mode updates in here */
	READENTITY_BYTE(m_renderMode, PLAYER_MODELINDEX)
	READENTITY_BYTE(m_renderFX, PLAYER_MODELINDEX)
	READENTITY_BYTE(m_renderColor[0], PLAYER_MODELINDEX)
	READENTITY_BYTE(m_renderColor[1], PLAYER_MODELINDEX)
	READENTITY_BYTE(m_renderColor[2], PLAYER_MODELINDEX)
	READENTITY_BYTE(m_renderAmount, PLAYER_MODELINDEX)

	READENTITY_ENTNUM(m_itemStart, PLAYER_ITEMS)
	READENTITY_ENTNUM(activeweapon, PLAYER_WEAPON)

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
	READENTITY_COORD(m_pmoveBaseVelocity[0], PLAYER_VELOCITY)
	READENTITY_COORD(m_pmoveBaseVelocity[1], PLAYER_VELOCITY)
	READENTITY_COORD(m_pmoveBaseVelocity[2], PLAYER_VELOCITY)
	READENTITY_COORD(m_pmoveHookVelocity[0], PLAYER_VELOCITY)
	READENTITY_COORD(m_pmoveHookVelocity[1], PLAYER_VELOCITY)
	READENTITY_COORD(m_pmoveHookVelocity[2], PLAYER_VELOCITY)
	READENTITY_INT(flags, PLAYER_FLAGS)
	READENTITY_INT(m_nuclideFlags, PLAYER_FLAGS)
	READENTITY_INT(gflags, PLAYER_FLAGS)
	READENTITY_FLOAT(gravity, PLAYER_FLAGS)
	READENTITY_FLOAT(friction, PLAYER_FLAGS)
	READENTITY_FLOAT(m_timeSinceJump, PLAYER_FLAGS)
	READENTITY_FLOAT(m_timeSinceTeleport, PLAYER_FLAGS)
	READENTITY_BYTE(m_weaponAnimSequence, PLAYER_WEAPONFRAME)
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
	READENTITY_FLOAT(m_punchAngle[0], PLAYER_PUNCHANGLE)
	READENTITY_FLOAT(m_punchAngle[1], PLAYER_PUNCHANGLE)
	READENTITY_FLOAT(m_punchAngle[2], PLAYER_PUNCHANGLE)
	READENTITY_FLOAT(m_punchVelocity[0], PLAYER_PUNCHANGLE)
	READENTITY_FLOAT(m_punchVelocity[1], PLAYER_PUNCHANGLE)
	READENTITY_FLOAT(m_punchVelocity[2], PLAYER_PUNCHANGLE)
	READENTITY_FLOAT(viewzoom, PLAYER_VIEWZOOM)
	READENTITY_FLOAT(sndindex_idle, PLAYER_VIEWZOOM)
	READENTITY_FLOAT(m_timeSinceTeleport, PLAYER_TIMINGS)
	READENTITY_FLOAT(m_currentStamina, PLAYER_TIMINGS)
	READENTITY_FLOAT(m_weaponAnimTime, PLAYER_TIMINGS)
	READENTITY_FLOAT(m_timeUntilNextAttack, PLAYER_TIMINGS)
	READENTITY_FLOAT(m_timeUntilNextIdle, PLAYER_TIMINGS)
	READENTITY_FLOAT(m_timeUntilReloaded, PLAYER_TIMINGS)
	READENTITY_ENTNUM(vehicle_entnum, PLAYER_VEHICLE)
	READENTITY_BYTE(m_spectatingEntity, PLAYER_SPECTATE)
	READENTITY_BYTE(m_spectatingMode, PLAYER_SPECTATE)
	READENTITY_BYTE(m_spectatingFlags, PLAYER_SPECTATE)

	READENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	READENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	READENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		READENTITY_INT(m_ammoTypes[i], PLAYER_AMMOTYPES)

		if (m_ammoTypes[i] != m_ammoTypes_net[i]) {
			HUD_AmmoChanged(i, m_ammoTypes[i], m_ammoTypes[i] - m_ammoTypes_net[i]);
		}
	}

	/* we only really care about the declclass for decl lookups. */
	if (flChanged & PLAYER_MODELINDEX) {
		declclass = EntityDef_NameFromNetID(entityDefID);
	}

	if (flChanged & PLAYER_SIZE) {
		setsize(this, mins, maxs);
	}

	/* our decl class has changed. refresh movement values. */
	if (flChanged & PLAYER_MODELINDEX && STRING_SET(declclass)) {
		_UpdatePMoveVars();
	}

	if (flChanged & PLAYER_MODELINDEX) {
		SetAnimationPrefix(m_activeWeapon.classname);
	}

	if (pSeat->m_ePlayer != this) {
		return;
	}

	if (new) {
		mins = m_pmoveVars.GetStandingMins();
		maxs = m_pmoveVars.GetStandingMaxs();
		Physics_SetViewParms();
	}

	VehicleRelink();
	PredictPreFrame();
	Relink();

	if (flChanged & PLAYER_SPECTATE) {
		m_flLastSpecTargetChange = time;
	}
}

void
ncPlayer::PredictPreFrame(void)
{
	if (!vehicle_entnum)
		vehicle = __NULL__;
	else
		vehicle = findentity(world, ::entnum, vehicle_entnum);

	if (!activeweapon)
		m_activeWeapon = __NULL__;
	else
		m_activeWeapon = (ncWeapon)findentity(world, ::entnum, activeweapon);

	if (!m_itemStart)
		m_itemList = __NULL__;
	else {
		m_itemList = (ncItem)findentity(world, ::entnum, m_itemStart);
	}

	if (m_activeWeapon)
		if (m_activeWeapon.PredictPreFrame)
			m_activeWeapon.PredictPreFrame();

	if (vehicle) {
		ncVehicle veh = (ncVehicle)vehicle;
		veh.PredictPreFrame();
	}

	SAVE_STATE(modelindex)
	SAVE_STATE(colormap)
	SAVE_STATE(m_renderMode)
	SAVE_STATE(m_renderFX)
	SAVE_STATE(m_renderColor)
	SAVE_STATE(m_renderAmount)
	SAVE_STATE(origin)
	SAVE_STATE(v_angle)
	SAVE_STATE(angles)
	SAVE_STATE(velocity)
	SAVE_STATE(m_pmoveBaseVelocity)
	SAVE_STATE(m_pmoveHookVelocity)
	SAVE_STATE(flags)
	SAVE_STATE(m_nuclideFlags)
	SAVE_STATE(gflags)
	SAVE_STATE(gravity)
	SAVE_STATE(friction)
	SAVE_STATE(m_timeSinceJump)
	SAVE_STATE(m_timeSinceTeleport)
	SAVE_STATE(m_itemList)
	SAVE_STATE(activeweapon)
	SAVE_STATE(m_weaponAnimSequence)
	SAVE_STATE(health)
	SAVE_STATE(armor)
	SAVE_STATE(mins)
	SAVE_STATE(maxs)
	SAVE_STATE(view_ofs)
	SAVE_STATE(movetype)
	SAVE_STATE(solid)
	SAVE_STATE(m_punchAngle)
	SAVE_STATE(m_punchVelocity)
	SAVE_STATE(viewzoom)
	SAVE_STATE(m_timeSinceTeleport)
	SAVE_STATE(m_currentStamina)
	SAVE_STATE(m_weaponAnimTime)
	SAVE_STATE(m_timeUntilNextAttack)
	SAVE_STATE(m_timeUntilNextIdle)
	SAVE_STATE(m_timeUntilReloaded)
	SAVE_STATE(vehicle_entnum)
	SAVE_STATE(m_spectatingEntity)
	SAVE_STATE(m_spectatingMode)
	SAVE_STATE(m_spectatingFlags)

	SAVE_STATE(m_itemList)
	SAVE_STATE(m_activeWeapon)

	SAVE_STATE(anim_top)
	SAVE_STATE(anim_top_delay)
	SAVE_STATE(anim_top_time)
	SAVE_STATE(anim_bottom)
	SAVE_STATE(anim_bottom_time)
	SAVE_STATE(sndindex_idle)

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		m_ammoTypes_net[i] = m_ammoTypes[i];
	}
}

void
ncPlayer::PredictPostFrame(void)
{
	ROLL_BACK(modelindex)
	ROLL_BACK(colormap)
	ROLL_BACK(m_renderMode)
	ROLL_BACK(m_renderFX)
	ROLL_BACK(m_renderColor)
	ROLL_BACK(m_renderAmount)
	ROLL_BACK(origin)
	ROLL_BACK(v_angle)
	ROLL_BACK(angles)
	ROLL_BACK(velocity)
	ROLL_BACK(m_pmoveBaseVelocity)
	ROLL_BACK(m_pmoveHookVelocity)
	ROLL_BACK(flags)
	ROLL_BACK(m_nuclideFlags)
	ROLL_BACK(gflags)
	ROLL_BACK(gravity)
	ROLL_BACK(friction)
	ROLL_BACK(m_timeSinceJump)
	ROLL_BACK(m_timeSinceTeleport)
	ROLL_BACK(m_itemList)
	ROLL_BACK(activeweapon)
	ROLL_BACK(m_weaponAnimSequence)
	ROLL_BACK(health)
	ROLL_BACK(armor)
	ROLL_BACK(mins)
	ROLL_BACK(maxs)
	ROLL_BACK(view_ofs)
	ROLL_BACK(movetype)
	ROLL_BACK(solid)
	ROLL_BACK(m_punchAngle)
	ROLL_BACK(m_punchVelocity)
	ROLL_BACK(viewzoom)
	ROLL_BACK(m_timeSinceTeleport)
	ROLL_BACK(m_currentStamina)
	ROLL_BACK(m_weaponAnimTime)
	ROLL_BACK(m_timeUntilNextAttack)
	ROLL_BACK(m_timeUntilNextIdle)
	ROLL_BACK(m_timeUntilReloaded)
	ROLL_BACK(vehicle_entnum)
	ROLL_BACK(m_spectatingEntity)
	ROLL_BACK(m_spectatingMode)
	ROLL_BACK(m_spectatingFlags)

	ROLL_BACK(m_itemList)
	ROLL_BACK(m_activeWeapon)

	ROLL_BACK(anim_top)
	ROLL_BACK(anim_top_delay)
	ROLL_BACK(anim_top_time)
	ROLL_BACK(anim_bottom)
	ROLL_BACK(anim_bottom_time)
	ROLL_BACK(sndindex_idle)

	VehicleRelink();

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		m_ammoTypes[i] = m_ammoTypes_net[i];
	}

	if (m_activeWeapon) {
		if (m_activeWeapon.PredictPostFrame) {
			m_activeWeapon.PredictPostFrame();
		}
	}

	if (vehicle) {
		ncVehicle veh = (ncVehicle)vehicle;
		veh.PredictPostFrame();
	}
}
#else
void
ncPlayer::ServerInputFrame(void)
{
	/* wait a few seconds, as we may not have been spawned yet */
	if (is.Bot(this)) {
		((ncBot)this).RunAI();
	}

	Physics_Run();
}

void
ncPlayer::Save(float handle)
{
	super::Save(handle);

	SaveBool(handle, "_isPlayer", _isPlayer);
	SaveEntity(handle, "last_used", last_used);
	SaveEntity(handle, "m_holdingEntity", m_holdingEntity);
	SaveEntity(handle, "m_pmoveVars", m_pmoveVars);
	SaveEntity(handle, "vehicle", vehicle);
	SaveFloat(handle, "activeweapon", activeweapon);
	SaveFloat(handle, "colormap", colormap);
	SaveFloat(handle, "friction", friction);
	SaveFloat(handle, "gflags", gflags);
	SaveFloat(handle, "gravity", gravity);
	SaveFloat(handle, "health", health);
	SaveFloat(handle, "m_timeSinceJump", m_timeSinceJump);
	SaveFloat(handle, "m_timeUntilNextPainSFX", m_timeUntilNextPainSFX);
	SaveFloat(handle, "m_timeUnderwater", m_timeUnderwater);
	SaveFloat(handle, "m_weaponCookingTime", m_weaponCookingTime);
	SaveFloat(handle, "pb_angle_delta", pb_angle_delta);
	SaveFloat(handle, "pb_player_delta", pb_player_delta);
	SaveFloat(handle, "m_timeUntilNextFootstep", m_timeUntilNextFootstep);
	SaveFloat(handle, "m_timeSinceTeleport", m_timeSinceTeleport);
	SaveFloat(handle, "viewzoom", viewzoom);
	SaveFloat(handle, "sndindex_idle", sndindex_idle);
	SaveFloat(handle, "m_timeUntilNextAttack", m_timeUntilNextAttack);
	SaveFloat(handle, "m_timeUntilNextIdle", m_timeUntilNextIdle);
	SaveFloat(handle, "m_timeUntilReloaded", m_timeUntilReloaded);
	SaveFloat(handle, "m_weaponAnimTime", m_weaponAnimTime);
	SaveInt(handle, "m_friendlyFireDamageDealt", m_friendlyFireDamageDealt);
	SaveInt(handle, "m_underwaterDamageDealt", m_underwaterDamageDealt);
	SaveInt(handle, "step", step);
	SaveInt(handle, "voted", voted);
	SaveInt(handle, "m_weaponAnimSequence", m_weaponAnimSequence);
	SaveVector(handle, "m_pmoveBaseVelocity", m_pmoveBaseVelocity);
	SaveVector(handle, "m_pmoveHookVelocity", m_pmoveHookVelocity);
	SaveVector(handle, "pb_last_angles", pb_last_angles);
	SaveVector(handle, "m_punchAngle", m_punchAngle);
	SaveVector(handle, "m_punchVelocity", m_punchVelocity);
	SaveVector(handle, "v_angle", v_angle);
	SaveVector(handle, "view_ofs", view_ofs);
}

void
ncPlayer::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "_isPlayer":
		_isPlayer = ReadBool(setValue);
		break;
	case "last_used":
		last_used = ReadEntity(setValue);
		break;
	case "m_holdingEntity":
		m_holdingEntity = ReadEntity(setValue);
		break;
	case "m_pmoveVars":
		m_pmoveVars = (ncPMoveVars)ReadEntity(setValue);
		break;
	case "vehicle":
		vehicle = ReadEntity(setValue);
		break;
	case "activeweapon":
		activeweapon = ReadFloat(setValue);
		break;
	case "colormap":
		colormap = ReadFloat(setValue);
		break;
	case "friction":
		friction = ReadFloat(setValue);
		break;
	case "gflags":
		gflags = ReadFloat(setValue);
		break;
	case "gravity":
		gravity = ReadFloat(setValue);
		break;
	case "health":
		health = ReadFloat(setValue);
		break;
	case "m_timeSinceJump":
		m_timeSinceJump = ReadFloat(setValue);
		break;
	case "m_timeUntilNextPainSFX":
		m_timeUntilNextPainSFX = ReadFloat(setValue);
		break;
	case "m_timeUnderwater":
		m_timeUnderwater = ReadFloat(setValue);
		break;
	case "m_weaponCookingTime":
		m_weaponCookingTime = ReadFloat(setValue);
		break;
	case "pb_angle_delta":
		pb_angle_delta = ReadFloat(setValue);
		break;
	case "pb_player_delta":
		pb_player_delta = ReadFloat(setValue);
		break;
	case "m_timeUntilNextFootstep":
		m_timeUntilNextFootstep = ReadFloat(setValue);
		break;
	case "m_timeSinceTeleport":
		m_timeSinceTeleport = ReadFloat(setValue);
		break;
	case "viewzoom":
		viewzoom = ReadFloat(setValue);
		break;
	case "sndindex_idle":
		sndindex_idle = ReadFloat(setValue);
		break;
	case "m_timeUntilNextAttack":
		m_timeUntilNextAttack = ReadFloat(setValue);
		break;
	case "m_timeUntilNextIdle":
		m_timeUntilNextIdle = ReadFloat(setValue);
		break;
	case "m_timeUntilReloaded":
		m_timeUntilReloaded = ReadFloat(setValue);
		break;
	case "m_weaponAnimTime":
		m_weaponAnimTime = ReadFloat(setValue);
		break;
	case "m_friendlyFireDamageDealt":
		m_friendlyFireDamageDealt = ReadInt(setValue);
		break;
	case "m_underwaterDamageDealt":
		m_underwaterDamageDealt = ReadInt(setValue);
		break;
	case "step":
		step = ReadInt(setValue);
		break;
	case "voted":
		voted = ReadInt(setValue);
		break;
	case "m_weaponAnimSequence":
		m_weaponAnimSequence = ReadInt(setValue);
		break;
	case "m_pmoveBaseVelocity":
		m_pmoveBaseVelocity = ReadVector(setValue);
		break;
	case "m_pmoveHookVelocity":
		m_pmoveHookVelocity = ReadVector(setValue);
		break;
	case "pb_last_angles":
		pb_last_angles = ReadVector(setValue);
		break;
	case "m_punchAngle":
		m_punchAngle = ReadVector(setValue);
		break;
	case "m_punchVelocity":
		m_punchVelocity = ReadVector(setValue);
		break;
	case "v_angle":
		v_angle = ReadVector(setValue);
		break;
	case "view_ofs":
		view_ofs = ReadVector(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

/*
=================
ncPlayer::Respawn

it'd be pretty unfortunate if 'sv respawn_ents' or something called this
=================
*/
void
ncPlayer::Respawn(void)
{
	/* make sure nothing happens here */
}

void
ncPlayer::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Message":
		env_message_single(this, strData);
		break;
	case "Spectate":
		MakeTempSpectator();
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

/*
=================
ncPlayer::MakeTempSpectator

This is what dead players in round matches become, or when we spawn
for the first time before selecting a loadout or something.
=================
 */
void
ncPlayer::MakeTempSpectator(void)
{
	flags = FL_CLIENT;
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NOCLIP);
	MakeInvulnerable();
	AddVFlags(VFL_FAKESPEC);
	max_health = health = 0;
	armor = 0;

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
	SetInfoKey("*spectator", "0"); /* not a real spectator */
	SetInfoKey("*dead", "0");
}

void
ncPlayer::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	RemoveAllItems(false);
	health = max_health = 0;
	armor = 0;
	effects = 0;
	alpha = 1.0f;
	SetModelindex(0);
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_NOT);
	MakeInvulnerable();
	viewzoom = 1.0;
	sndindex_idle = 0;
	view_ofs = [0,0,0];
	vehicle = __NULL__;
	SetVelocity([0,0,0]);
	SetGravity(1.0f);
	customphysics = Empty;
	setsize(this, [0,0,0], [0,0,0]);
	SetInfoKey("*deaths", ftos(deaths));
	SetInfoKey("*dead", "1");
	SetInfoKey("*spectator", "0");
	m_timeOfDeath = time;
}

void
ncPlayer::Spawned(void)
{
	super::Spawned();
	_isPlayer = true;
	vehicle = __NULL__;

	/* we really need to check if whether we're a real client yet. */
	if (clienttype(this) == CLIENTTYPE_REAL || clienttype(this) == CLIENTTYPE_BOT) {
		MakePlayer();
	} else {
		Disappear(); /* hide us for now */
	}

	_UpdatePMoveVars();
}

void
ncPlayer::MakePlayer(void)
{
	AddFlags(FL_CLIENT);
	RemoveVFlags(VFL_FAKESPEC);

	if (health <= 0) {
		health = max_health = 100;
		armor = 0;
	}

	effects = 0;
	alpha = 1.0f;
	SetSolid(SOLID_SLIDEBOX);
	SetMovetype(MOVETYPE_WALK);
	MakeVulnerable();
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	ClearVelocity();
	viewzoom = 1.0;
	sndindex_idle = 0;
	vehicle = __NULL__;
	SetGravity(1.0f);
	SendFlags = UPDATE_ALL;
	customphysics = Empty;
	SetScale(1.0f);
	Physics_SetViewParms();
	SetSize(m_pmoveVars.GetStandingMins(), m_pmoveVars.GetStandingMaxs());
	SetInfoKeyFloat("*spectator", false);
	SetInfoKeyFloat("*deaths", deaths);
	SetInfoKeyFloat("*dead", 0);
	SetInfoKeyFloat("*spec", 0);
}

void
ncPlayer::MakeSpectator(void)
{
	ClientKill();
	MakeTempSpectator();
	SetTeam(TEAM_SPECTATOR);
	SetInfoKeyFloat("*team", team);
}

void
ncPlayer::EvaluateEntity(void)
{
	pvsflags = !HasVFlags(VFL_FAKESPEC) ? 0 : PVSF_IGNOREPVS;

	EVALUATE_FIELD(entityDefID, PLAYER_MODELINDEX)
	EVALUATE_FIELD(modelindex, PLAYER_MODELINDEX)
	EVALUATE_FIELD(vw_index, PLAYER_MODELINDEX)
	EVALUATE_FIELD(colormap, PLAYER_MODELINDEX)
	EVALUATE_FIELD(m_renderMode, PLAYER_MODELINDEX)
	EVALUATE_FIELD(m_renderFX, PLAYER_MODELINDEX)
	EVALUATE_VECTOR(m_renderColor, 0, PLAYER_MODELINDEX)
	EVALUATE_VECTOR(m_renderColor, 1, PLAYER_MODELINDEX)
	EVALUATE_VECTOR(m_renderColor, 2, PLAYER_MODELINDEX)
	EVALUATE_FIELD(m_renderAmount, PLAYER_MODELINDEX)
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
	EVALUATE_VECTOR(m_pmoveBaseVelocity, 0, PLAYER_VELOCITY)
	EVALUATE_VECTOR(m_pmoveBaseVelocity, 1, PLAYER_VELOCITY)
	EVALUATE_VECTOR(m_pmoveBaseVelocity, 2, PLAYER_VELOCITY)
	EVALUATE_VECTOR(m_pmoveHookVelocity, 0, PLAYER_VELOCITY)
	EVALUATE_VECTOR(m_pmoveHookVelocity, 1, PLAYER_VELOCITY)
	EVALUATE_VECTOR(m_pmoveHookVelocity, 2, PLAYER_VELOCITY)
	EVALUATE_FIELD(flags, PLAYER_FLAGS)
	EVALUATE_FIELD(m_nuclideFlags, PLAYER_FLAGS)
	EVALUATE_FIELD(gflags, PLAYER_FLAGS)
	EVALUATE_FIELD(gravity, PLAYER_FLAGS)
	EVALUATE_FIELD(friction, PLAYER_FLAGS)
	EVALUATE_FIELD(m_timeSinceJump, PLAYER_FLAGS)
	EVALUATE_FIELD(m_timeSinceTeleport, PLAYER_FLAGS)
	EVALUATE_FIELD(m_itemList, PLAYER_ITEMS)
	EVALUATE_FIELD(m_activeWeapon, PLAYER_WEAPON)
	EVALUATE_FIELD(m_weaponAnimSequence, PLAYER_WEAPONFRAME)
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
	EVALUATE_VECTOR(m_punchAngle, 0, PLAYER_PUNCHANGLE)
	EVALUATE_VECTOR(m_punchAngle, 1, PLAYER_PUNCHANGLE)
	EVALUATE_VECTOR(m_punchAngle, 2, PLAYER_PUNCHANGLE)
	EVALUATE_VECTOR(m_punchVelocity, 0, PLAYER_PUNCHANGLE)
	EVALUATE_VECTOR(m_punchVelocity, 1, PLAYER_PUNCHANGLE)
	EVALUATE_VECTOR(m_punchVelocity, 2, PLAYER_PUNCHANGLE)
	EVALUATE_FIELD(viewzoom, PLAYER_VIEWZOOM)
	EVALUATE_FIELD(sndindex_idle, PLAYER_VIEWZOOM)
	EVALUATE_FIELD(m_timeSinceTeleport, PLAYER_TIMINGS)
	EVALUATE_FIELD(m_currentStamina, PLAYER_TIMINGS)
	EVALUATE_FIELD(m_weaponAnimTime, PLAYER_TIMINGS)
	EVALUATE_FIELD(m_timeUntilNextAttack, PLAYER_TIMINGS)
	EVALUATE_FIELD(m_timeUntilNextIdle, PLAYER_TIMINGS)
	EVALUATE_FIELD(m_timeUntilReloaded, PLAYER_TIMINGS)
	EVALUATE_FIELD(vehicle, PLAYER_VEHICLE)
	EVALUATE_FIELD(m_spectatingEntity, PLAYER_SPECTATE)
	EVALUATE_FIELD(m_spectatingMode, PLAYER_SPECTATE)
	EVALUATE_FIELD(m_spectatingFlags, PLAYER_SPECTATE)

	EVALUATE_FIELD(anim_top, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_time, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_delay, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_bottom, PLAYER_BOTTOMFRAME)
	EVALUATE_FIELD(anim_bottom_time, PLAYER_BOTTOMFRAME)

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		EVALUATE_VECTOR(m_ammoTypes, i, PLAYER_AMMOTYPES)
	}
}

float
ncPlayer::SendEntity(entity ePEnt, float flChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this) {
		return (0);
	}
	if (!GetModelindex() && ePEnt != this) {
		return (0);
	}

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_INT(entityDefID, PLAYER_MODELINDEX)
	SENDENTITY_INT(modelindex, PLAYER_MODELINDEX)
	SENDENTITY_INT(vw_index, PLAYER_MODELINDEX)
	SENDENTITY_BYTE(colormap, PLAYER_MODELINDEX)

	/* crap the render mode updates in here */
	SENDENTITY_BYTE(m_renderMode, PLAYER_MODELINDEX)
	SENDENTITY_BYTE(m_renderFX, PLAYER_MODELINDEX)
	SENDENTITY_BYTE(m_renderColor[0], PLAYER_MODELINDEX)
	SENDENTITY_BYTE(m_renderColor[1], PLAYER_MODELINDEX)
	SENDENTITY_BYTE(m_renderColor[2], PLAYER_MODELINDEX)
	SENDENTITY_BYTE(m_renderAmount, PLAYER_MODELINDEX)

	SENDENTITY_ENTITY(m_itemList, PLAYER_ITEMS)
	SENDENTITY_ENTITY(m_activeWeapon, PLAYER_WEAPON)

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
	SENDENTITY_COORD(m_pmoveBaseVelocity[0], PLAYER_VELOCITY)
	SENDENTITY_COORD(m_pmoveBaseVelocity[1], PLAYER_VELOCITY)
	SENDENTITY_COORD(m_pmoveBaseVelocity[2], PLAYER_VELOCITY)
	SENDENTITY_COORD(m_pmoveHookVelocity[0], PLAYER_VELOCITY)
	SENDENTITY_COORD(m_pmoveHookVelocity[1], PLAYER_VELOCITY)
	SENDENTITY_COORD(m_pmoveHookVelocity[2], PLAYER_VELOCITY)
	SENDENTITY_INT(flags, PLAYER_FLAGS)
	SENDENTITY_INT(m_nuclideFlags, PLAYER_FLAGS)
	SENDENTITY_INT(gflags, PLAYER_FLAGS)
	SENDENTITY_FLOAT(gravity, PLAYER_FLAGS)
	SENDENTITY_FLOAT(friction, PLAYER_FLAGS)
	SENDENTITY_FLOAT(m_timeSinceJump, PLAYER_FLAGS)
	SENDENTITY_FLOAT(m_timeSinceTeleport, PLAYER_FLAGS)
	SENDENTITY_BYTE(m_weaponAnimSequence, PLAYER_WEAPONFRAME)
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
	SENDENTITY_FLOAT(m_punchAngle[0], PLAYER_PUNCHANGLE)
	SENDENTITY_FLOAT(m_punchAngle[1], PLAYER_PUNCHANGLE)
	SENDENTITY_FLOAT(m_punchAngle[2], PLAYER_PUNCHANGLE)
	SENDENTITY_FLOAT(m_punchVelocity[0], PLAYER_PUNCHANGLE)
	SENDENTITY_FLOAT(m_punchVelocity[1], PLAYER_PUNCHANGLE)
	SENDENTITY_FLOAT(m_punchVelocity[2], PLAYER_PUNCHANGLE)
	SENDENTITY_FLOAT(viewzoom, PLAYER_VIEWZOOM)
	SENDENTITY_FLOAT(sndindex_idle, PLAYER_VIEWZOOM)
	SENDENTITY_FLOAT(m_timeSinceTeleport, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(m_currentStamina, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(m_weaponAnimTime, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(m_timeUntilNextAttack, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(m_timeUntilNextIdle, PLAYER_TIMINGS)
	SENDENTITY_FLOAT(m_timeUntilReloaded, PLAYER_TIMINGS)
	SENDENTITY_ENTITY(vehicle, PLAYER_VEHICLE)
	SENDENTITY_BYTE(m_spectatingEntity, PLAYER_SPECTATE)
	SENDENTITY_BYTE(m_spectatingMode, PLAYER_SPECTATE)
	SENDENTITY_BYTE(m_spectatingFlags, PLAYER_SPECTATE)

	SENDENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	SENDENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	SENDENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		SENDENTITY_INT(m_ammoTypes[i], PLAYER_AMMOTYPES)
	}

	return (1);
}

float
ncPlayer::OptimiseChangedFlags(entity ePEnt, float flChanged)
{
	bool is_spec = false;
	bool spectarget = false;

	/* figure out if we should optimise this player */
	if (ePEnt.flags & FL_CLIENT && ePEnt != this) {
		ncSpectator sp = (ncSpectator)ePEnt;
		is_spec = (sp.IsFakeSpectator() || sp.IsRealSpectator());
		spectarget = (is_spec == true && edict_num(sp.m_spectatingEntity) == this);
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
		//flChanged |= PLAYER_MODELINDEX;
	}

	return flChanged;
}

void
_ncPlayer_useworkaround(entity eTarget)
{
	eActivator = (ncEntity)self;
	entity eOldSelf = self;
	self = eTarget;
	self.PlayerUse();
	self = eOldSelf;
}


void
_ncPlayer_unuseworkaround(entity eTarget)
{
	eActivator = (ncEntity)self;
	entity eOldSelf = self;
	self = eTarget;
	if (self.PlayerUseUnpressed)
		self.PlayerUseUnpressed();
	self = eOldSelf;
}

void
Holding_UpdatePos(void)
{
	ncEntity meSelf = (ncEntity)self;
	ncPlayer ourOwner = (ncPlayer)meSelf.m_holdingPlayer;

	/* did the owner die? unpickup */
	if (ourOwner.health <= 0) {
		ourOwner.m_holdingEntity = false;
		meSelf.m_holdingPlayer = __NULL__;
		meSelf.think = __NULL__;
		meSelf.nextthink = 0.0f;
		meSelf.m_lastHeldTime = time;
		ourOwner.m_nuclideFlags &= ~VFL_HOLDING;
#ifdef SERVER
		ncLog("%s stopped holding onto %s", ourOwner.netname, meSelf.classname);
#endif
		return;
	}

	vector forwardDir = anglesToForward(ourOwner.v_angle);
	vector targetOrg = ourOwner.GetEyePos() + forwardDir * 96.0f;
	meSelf.velocity = (targetOrg - meSelf.origin) * 10.0;
	meSelf.nextthink = time;
	meSelf.think = Holding_UpdatePos;
}

void
ncPlayer::PickupEntity(ncEntity toPickUp)
{
	if (!toPickUp) {
		EntError("Cannot pickup null entity.");
		return;
	}

	/* make it impossible to pick it back up in a short amount of time */
	if ((toPickUp.m_lastHeldTime + 1.0f) > time) {
		return;
	}

	m_nuclideFlags |= VFL_HOLDING;
	m_holdingEntity = toPickUp;
	toPickUp.m_holdingPlayer = this;
	toPickUp.ScheduleThink(Holding_UpdatePos, 0.0f);
	EntLog("Now holding %s", toPickUp.classname);
}

void
ncPlayer::InputUse_Down(void)
{
	if (IsDead()) {
		return;
	} else if (!(m_nuclideFlags & VFL_USE_RELEASED)) {
		return;
	}

	if (m_nuclideFlags & VFL_HOLDING) {
		ncEntity heldProp = (ncEntity)m_holdingEntity;
		m_holdingEntity = false;
		heldProp.m_holdingPlayer = __NULL__;
		heldProp.think = __NULL__;
		heldProp.nextthink = 0.0f;
		heldProp.m_lastHeldTime = time;
		m_nuclideFlags &= ~VFL_HOLDING;
		return;
	}

	vector vecSource, vecDest;
	entity eRad = __NULL__;
	bool found_use = false;

	/* TODO: Expand this to provide for XR input based pickup. instead of casting a trace from
	 * the eye position, we see if we're able close to our desired input hand. */

	/* how way we trace from the FPS/HMD view */
	vecSource = GetEyePos();
	vecDest = vecSource + (anglesToForward(GetViewAngle()) * 96);
	traceline(vecSource, vecDest, MOVE_EVERYTHING, this);

	/* first see if we traced something head-on, else we'll findradius something */
	if (trace_fraction < 1.0f) {
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
	}

	/* TODO: maybe eRad will return something in the future that'll suppress a successfull use? */
	if (eRad && found_use == true) {
		RemoveVFlags(VFL_USE_RELEASED);
		_ncPlayer_useworkaround(eRad);
		last_used = eRad;

		/* Some entities want to support Use spamming */
		if (HasVFlags(VFL_USE_RELEASED) == false) {
			StartSoundDef(m_sndUseSuccess, CHAN_ITEM, false);
		}
	} else {
		StartSoundDef(m_sndUseDeny, CHAN_ITEM, false);
		RemoveVFlags(VFL_USE_RELEASED);
	}
}

void
ncPlayer::InputUse_Up(void)
{
	if (HasVFlags(VFL_USE_RELEASED) == false) {
		_ncPlayer_unuseworkaround(last_used);
		last_used = world;
		AddVFlags(VFL_USE_RELEASED);
	}
}
#endif

float
ncPlayer::WeaponAnimTime(void)
{
	return (m_weaponAnimTime);
}

void
ncPlayer::Footsteps_Update(void)
{
#ifdef SERVER
	string mat_name = "";
	string tex_name = "";
	string sound = "";

	/* mp_footsteps is only available in MP matches */
	if (Util_IsSingleplayer() == false) {
		if (autocvar(mp_footsteps, 1) == 0) {
			return;
		}
	}

	if (GetMovetype() != MOVETYPE_WALK) {
		return;
	}

	if ((velocity[0] == 0 && velocity[1] == 0) || m_timeUntilNextFootstep > time)
		return;

	if (waterlevel == 1) {
		StartSoundDef(m_sndWaterWade, CHAN_BODY, true);
		m_timeUntilNextFootstep = time + 2.0f;
		return;
	} else if (waterlevel == 2) {
		StartSoundDef(m_sndWaterWade, CHAN_BODY, true);
		m_timeUntilNextFootstep = time + 2.0f;
		return;
	} else if (waterlevel == 3) {
		StartSoundDef(m_sndWaterSwim, CHAN_BODY, true);
		m_timeUntilNextFootstep = time + 2.0f;
		return;
	} else {
		/* make it so we step once we land */
		if (HasFlags(FL_ONGROUND) == false && HasVFlags(VFL_ONLADDER) == false) {
			m_timeUntilNextFootstep = 0.0f;
			return;
		}
	}

	/* the footsteps call might overwrite this later */
	m_timeUntilNextFootstep = time + 0.35;

	//tracebox(origin, PHY_HULL_MIN, PHY_HULL_MAX, origin + [0,0,-48], MOVE_NORMAL, target);
	traceline(origin + view_ofs, origin + [0,0,-48], MOVE_NORMAL, this);
	tex_name = getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos));

	/* don't step in air */
	if (HasFlags(FL_ONGROUND) == false && HasVFlags(VFL_ONLADDER) == false) {
		return;
	} else if (HasVFlags(VFL_ONLADDER) && HasFlags(FL_ONGROUND) == false) { /* play ladder sounds */
		if (step)
			StartSoundDef(m_sndStepLadderLeft, CHAN_BODY, true);
		else
			StartSoundDef(m_sndStepLadderRight, CHAN_BODY, true);

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
ncPlayer::Damage(entity inflictor, entity attacker, ncDict damageDecl, float damageScale, vector dmgDir, vector hitLocation)
{
#ifdef SERVER
	float armorDamage = 0;
	bool isFriendlyFire = false;
	string damageString = ReadString(damageDecl.GetString("damage"));
	float damagePoints = (float)rint(stof(damageString) * damageScale);
	ncSurfacePropEntity ourAttacker = (ncSurfacePropEntity)attacker;
	ncRuleDelegate rules = (ncRuleDelegate)ncRuleDelegate::ActiveInstance();

	/* sanity check */
	if (is.Alive(this) == false) {
		return;
	}

	/* friendly fire check */
	if (this != attacker && attacker != world) {
		if (rules.IsTeamplay()) {
			if (is.Player(this) && is.Player(attacker)) {
				if (team == attacker.team) {
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
	if (GetHealth() <= 0) {
		return;
	}

	/* player god mode */
	if (damageDecl.GetBool("noGod") == false && is.GodMode(this)) {
		return;
	}

	/* don't allow any damage */
	if (rules.PlayerCanAttack(this) == false) {
		return;
	}

	/* skip armor */
	if (damageDecl.GetBool("noArmor") == false) {
		if (GetArmor() >= 1.0f && damagePoints >= 1.0f) {
			float postArmorDamage = 0;
			float armorRatio = GetDefFloat("armorProtection");
			float armorBonus = GetDefFloat("armorBonus");

			/* amount of damage the armor absorbs */
			if (armorRatio <= 0.0) {
				armorRatio = 0.2;
			}

			/* armor point cost for health point */
			if (armorBonus <= 0.0) {
				armorBonus = 1.0;
			}

			/* damage to be applied to health value */
			postArmorDamage = (damagePoints * armorRatio);

			/* figure out how much to deduct from armor. */
			armorDamage = (damagePoints - postArmorDamage) * armorBonus;

			/* to-deduct value exceeds armor value */
			if (armorDamage > GetArmor()) {
				/* armor points left will cushion whatever damage they can */
				armorDamage = GetArmor() * (1.0 / armorBonus);
				SetArmor(0);
				postArmorDamage = (damagePoints - armorDamage);
			} else {
				SetArmor(GetArmor() - armorDamage);
			}

			damagePoints = postArmorDamage;
		}
	}

	damagePoints = rint(damagePoints);
	SetHealth(GetHealth() - damagePoints);

	/* friendly fire penalty */
	if (isFriendlyFire) {
		int lastDmg = 0i;
		ncPlayer plC = (ncPlayer)attacker;
		lastDmg = plC.m_friendlyFireDamageDealt;
		plC.m_friendlyFireDamageDealt += damagePoints;

		/* kick the client. */
		if (plC.m_friendlyFireDamageDealt >= autocvar_mp_td_dmgToKick) {
			ncLog("Kicking %S due to team damage rules.", plC.netname);
			dropclient(plC);
		} else if (plC.m_friendlyFireDamageDealt >= autocvar_mp_td_dmgToWarn) {
			if (lastDmg < autocvar_mp_td_dmgToKick) {
				// warn player here
				sprint(plC, PRINT_CHAT, "Keep attacking teammates and you will be kicked!\n");
			}
		}

		bprint(PRINT_CHAT, sprintf("%s ^7attacked a teammate.\n", attacker.netname));
	}

	if (damagePoints > 0 || armorDamage > 0) {
		vector dmg_origin;

		if (attacker.origin == [0,0,0])
			dmg_origin = this.origin;
		else
			dmg_origin = attacker.origin;

		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_DAMAGE);
		WriteCoord(MSG_MULTICAST, dmg_origin[0]);
		WriteCoord(MSG_MULTICAST, dmg_origin[1]);
		WriteCoord(MSG_MULTICAST, dmg_origin[2]);
		WriteInt(MSG_MULTICAST, damagePoints);
		WriteInt(MSG_MULTICAST, damageDecl.GetInteger("flags"));
		msg_entity = this;
		multicast([0,0,0], MULTICAST_ONE_R);
	}

	/* only hit notify on clients */
	if ((this.flags & FL_CLIENT) || (this.flags & FL_MONSTER)) {
		/* server-side hitnotify */
		if ((attacker.flags & FL_CLIENT) && (this != attacker)) {
			WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
			WriteByte(MSG_MULTICAST, EV_HITNOTIFY);
			msg_entity = attacker;
			multicast([0,0,0], MULTICAST_ONE);
		}
	}

	/* apply knockback, but only on death */
	float knockBack = damageDecl.GetFloat("knockback");
	if (knockBack >= 0) {
		AddVelocity(dmgDir * knockBack);
	}

	/* they died */
	if (GetHealth() <= 0) {
		rules.PlayerDeath(this, (ncActor)inflictor, (ncActor)attacker, damageDecl.GetString("weapon"));
		Death(inflictor, attacker, (int)damagePoints, dmgDir, hitLocation, 0i);
	} else {
		rules.PlayerPain(this, (ncActor)attacker, damageDecl);
		Pain(inflictor, attacker, (int)damagePoints, dmgDir, hitLocation, 0i);
	}

#endif
}

