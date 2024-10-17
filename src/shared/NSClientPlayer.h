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

noref .vector v_angle;

/** This entity class represents every player client.

When clients connect via the connect command, they will findthemselves
of type NSClientPlayer.

@ingroup baseclass
*/
class
NSClientPlayer:NSClientSpectator
{
public:
	void NSClientPlayer(void);
	
	virtual void ProcessInput(void);
	virtual void PreFrame(void);
	virtual void PostFrame(void);
	
	virtual void Physics_Fall(float);
	virtual void Physics_Crouch(void);
	virtual void Physics_Prone(void);
	virtual void Physics_Jump(void);
	virtual void Physics_CheckJump(float);
	virtual void Physics_SetViewParms(void);
	virtual void Physics_WaterJump(void);
	virtual void Physics_WaterMove(void);
	virtual float Physics_MaxSpeed(void);
	virtual void Physics_InputPreMove(void);
	virtual void Physics_InputPostMove(void);
	virtual void Physics_Run(void);
	
	virtual bool IsFakeSpectator(void);
	virtual bool IsRealSpectator(void);
	virtual bool IsDead(void);
	virtual bool IsPlayer(void);
	virtual void SharedInputFrame(void);

	/** Overridable: Returns whether the client can sprint, with the command +sprint */
	virtual bool CanSprint(void);
	/** Overridable: Returns whether the client can prone, with the commands +prone and goprone */
	virtual bool CanProne(void);
	/** Overridable: Returns whether the client can crouch, with the commands +crouch and gocrouch */
	virtual bool CanCrouch(void);
	/** Overridable: Returns whether the client can lean, with the commands +leanleft and +leanright */
	virtual bool CanLean(void);
	
	/** Empty & shared between Client and Server. This is run on every player, every frame, to update their animation cycle. */
	virtual void UpdatePlayerAnimation(float);

	virtual void Damage(entity, entity, NSDict, float, vector, vector);
	

#ifdef CLIENT
	virtual void VehicleRelink(void);
	virtual void OnRemoveEntity(void);
	virtual void ReceiveEntity(float,float);
	virtual void _ReceiveComplete(float, float);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void ClientInputFrame(void);

	virtual vector CalculateLean(vector);
	virtual void UpdateAliveCam(void);

	/** Empty. Updates the bone controller responsible for mouth movement. */
	virtual void UpdatePlayerJaw(float);

	/** Empty. This is run on every player, every frame to update attachments. */
	virtual void UpdatePlayerAttachments(bool);

	virtual float predraw(void);
	virtual void postdraw(void);

#endif

#ifdef SERVER
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Death(entity, entity, int, vector, int);
	virtual void ServerInputFrame(void);
	virtual void Input(entity, string, string);

	/** Helper function that will optimise the changed-flags of your player entity. */
	virtual float OptimiseChangedFlags(entity,float);

	/** When called, will turn the client into a proper player. */
	virtual void MakePlayer(void);
	/** When called, will turn the client into a spectator until the next round. */
	virtual void MakeTempSpectator(void);
	/** When called, will turn the client into a general spectator. */
	virtual void MakeSpectator(void);

	/** Called when we press the button bound to +use. */
	virtual void InputUse_Down(void);
	/** Called when we let go of the button bound to +use. */
	virtual void InputUse_Up(void);

#endif

	virtual void Footsteps_Update(void);

	nonvirtual void _UpdatePMoveVars(void);

private:

#ifdef CLIENT
	NETWORKED_INT(weaponframe)
	NETWORKED_FLOAT(vehicle_entnum)
#endif

#ifdef SERVER
	NETWORKED_INT_N(weaponframe)
	float nadeCookingTime;
#endif

	NETWORKED_FLOAT(health)

	NETWORKED_FLOAT_N(colormap)
	NETWORKED_FLOAT_N(gflags)
	NETWORKED_FLOAT(viewzoom)
	NETWORKED_VECTOR_N(view_ofs)
	NETWORKED_VECTOR_N(basevelocity)
	NETWORKED_VECTOR_N(v_angle)
	NETWORKED_FLOAT_N(pmove_flags)

	NETWORKED_FLOAT(w_attack_next)
	NETWORKED_FLOAT(w_idle_next)
	NETWORKED_FLOAT(w_reload_next)
	NETWORKED_FLOAT(teleport_time)
	NETWORKED_FLOAT(weapontime)
	NETWORKED_VECTOR(punchangle)

	/* We can't use the default .items field, because FTE will assume
	 * effects of some bits. Such as invisibility, quad, etc. 
	 * also, modders probably want 32 bits for items. */
	NETWORKED_INT(g_items)
	NETWORKED_FLOAT_N(activeweapon)
	NSItem m_itemList_net;
	int m_iAmmoTypes_net[MAX_AMMO_TYPES];


	/* vehicle info */
	NETWORKED_ENT(vehicle)

	/* these are NOT networked */
	int a_ammo1;
	int a_ammo2;
	int a_ammo3;

	NETWORKED_VECTOR(grapvelocity)

#ifdef CLIENT
	int sequence;

	/* external weapon model */
	NSRenderableEntity p_model;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;
#endif
	NSPMoveVars m_pmoveVars;

#ifdef SERVER
	int voted;
	int step;
	float step_time;

	int m_iUnderwaterDamage;
	float m_flUnderwaterTime;
	float m_flPainTime;

	entity last_used;

	float pb_angle_delta;
	float pb_player_delta;
	vector pb_last_angles;

	int m_iFriendlyDMG;
#endif
};

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_MODELINDEX,
	PLAYER_ORIGIN,
	PLAYER_ANGLES,
	PLAYER_VELOCITY,
	PLAYER_FLAGS,
	PLAYER_WEAPON,
	PLAYER_ITEMS,
	PLAYER_HEALTH,
	PLAYER_SIZE,
	PLAYER_MOVETYPE,
	PLAYER_PUNCHANGLE,
	PLAYER_VIEWZOOM,
	PLAYER_TIMINGS,
	PLAYER_VEHICLE,
	PLAYER_SPECTATE,
	PLAYER_AMMOTYPES,
	PLAYER_WEAPONFRAME,
	PLAYER_CUSTOMFIELDSTART,
};

#ifdef SERVER
void obituary(string, string, string, string);
#endif
