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

/** This entity class represents every player client.

When clients connect via the connect command, they will findthemselves
of type NSClientPlayer.
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
	
	/** Empty & shared between Client and Server. This is run on every player, every frame, to update their animation cycle. */
	virtual void UpdatePlayerAnimation(float);
	

#ifdef CLIENT
	virtual void VehicleRelink(void);
	virtual void OnRemoveEntity(void);
	virtual void ReceiveEntity(float,float);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void ClientInputFrame(void);
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
	virtual void Respawn(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Death(void);
	virtual void ServerInputFrame(void);

	/** Helper function that will optimise the changed-flags of your player entity. */
	virtual float OptimiseChangedFlags(entity,float);

	/** When called, will turn the client into a proper player. */
	virtual void MakePlayer(void);
	/** When called, will turn the client into a spectator. */
	virtual void MakeTempSpectator(void);

	/** Called when we press the button bound to +use. */
	virtual void InputUse_Down(void);
	/** Called when we let go of the button bound to +use. */
	virtual void InputUse_Up(void);

#endif

	virtual void Footsteps_Update(void);

private:

#ifdef CLIENT
	PREDICTED_INT(weaponframe)
	PREDICTED_FLOAT(vehicle_entnum)
#endif

#ifdef SERVER
	PREDICTED_INT_N(weaponframe)
#endif

	PREDICTED_FLOAT(health)
	PREDICTED_FLOAT(armor)

	PREDICTED_FLOAT_N(colormap)
	PREDICTED_FLOAT_N(gflags)
	PREDICTED_FLOAT(viewzoom)
	PREDICTED_VECTOR_N(view_ofs)
	PREDICTED_VECTOR_N(basevelocity)
	PREDICTED_VECTOR(v_angle)
	PREDICTED_FLOAT_N(pmove_flags)

	PREDICTED_FLOAT(w_attack_next)
	PREDICTED_FLOAT(w_idle_next)
	PREDICTED_FLOAT(teleport_time)
	PREDICTED_FLOAT(weapontime)
	PREDICTED_VECTOR(punchangle)

	/* We can't use the default .items field, because FTE will assume
	 * effects of some bits. Such as invisibility, quad, etc. 
	 * also, modders probably want 32 bits for items. */
	PREDICTED_INT(g_items)
	PREDICTED_FLOAT(activeweapon)

#ifdef NEW_INVENTORY
	NSWeapon m_weapons[MAX_WEAPONS];
	NSWeapon m_activeweapon;
#endif

	/* vehicle info */
	PREDICTED_ENT(vehicle)

	/* these are NOT networked */
	int a_ammo1;
	int a_ammo2;
	int a_ammo3;

	/* any mods that use hooks */
	entity hook;

#ifdef CLIENT
	int sequence;

	/* external weapon model */
	NSRenderableEntity p_model;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;
#endif

#ifdef SERVER
	int voted;
	int step;
	float step_time;

	int m_iUnderwaterDamage;
	float m_flUnderwaterTime;
	float m_flPainTime;

	entity last_used;
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
	PLAYER_CUSTOMFIELDSTART,
};
