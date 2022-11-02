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
#ifdef SERVER
	PREDICTED_INT_N(weaponframe);
#else
	PREDICTED_INT(weaponframe);
	PREDICTED_FLOAT(vehicle_entnum);
#endif
	PREDICTED_FLOAT(health);
	PREDICTED_FLOAT(armor);

	PREDICTED_FLOAT_N(colormap);
	PREDICTED_FLOAT_N(gflags);
	PREDICTED_FLOAT(viewzoom);
	PREDICTED_VECTOR_N(view_ofs);
	PREDICTED_VECTOR(v_angle);
	PREDICTED_FLOAT_N(pmove_flags);

	PREDICTED_FLOAT(w_attack_next);
	PREDICTED_FLOAT(w_idle_next);
	PREDICTED_FLOAT(teleport_time);
	PREDICTED_FLOAT(weapontime);
	PREDICTED_VECTOR(punchangle);

	/* We can't use the default .items field, because FTE will assume
	 * effects of some bits. Such as invisibility, quad, etc. 
	 * also, modders probably want 32 bits for items. */
	PREDICTED_INT(g_items);
	PREDICTED_FLOAT(activeweapon);

#ifdef NEW_INVENTORY
	NSWeapon m_weapons[MAX_WEAPONS];
	NSWeapon m_activeweapon;
#endif

	/* vehicle info */
	PREDICTED_ENT(vehicle);

	/* these are NOT networked */
	int a_ammo1;
	int a_ammo2;
	int a_ammo3;

	/* any mods that use hooks */
	entity hook;

	void(void) NSClientPlayer;

	virtual void(void) ClientInput;

	virtual void(void) PreFrame;
	virtual void(void) PostFrame;

	virtual void(float) Physics_Fall;
	virtual void(void) Physics_Crouch;
	virtual void(void) Physics_Jump;
	virtual void(float) Physics_CheckJump;
	virtual void(void) Physics_SetViewParms;
	virtual void(void) Physics_WaterJump;
	virtual void(void) Physics_WaterMove;
	virtual float(void) Physics_MaxSpeed;
	virtual void(void) Physics_InputPreMove;
	virtual void(void) Physics_InputPostMove;
	virtual void(void) Physics_Run;

	virtual bool(void) IsFakeSpectator;
	virtual bool(void) IsRealSpectator;
	virtual bool(void) IsDead;
	virtual bool(void) IsPlayer;

	/** Empty & shared between Client and Server. This is run on every player, every frame, to update their animation cycle. */
	virtual void UpdatePlayerAnimation(void);

#ifdef CLIENT
	int sequence;

	/* external weapon model */
	entity p_model;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;

	virtual void(void) VehicleRelink;
	virtual void(void) OnRemoveEntity;
	virtual void(float, float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void(void) ClientInputFrame;
	virtual void(void) UpdateAliveCam;

	virtual float predraw(void);
	virtual void postdraw(void);

	/** Empty. Updates the bone controller responsible for mouth movement. */
	virtual void UpdatePlayerJaw(float);

	/** Empty. This is run on every player, every frame to update attachments. */
	virtual void UpdatePlayerAttachments(bool);
#else
	int voted;
	int step;
	float step_time;

	int m_iUnderwaterDamage;
	float m_flUnderwaterTime;
	float m_flPainTime;

	entity last_used;

	virtual void(float) Save;
	virtual void(string,string) Restore;
	virtual void(void) Respawn;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	virtual float(entity, float) OptimiseChangedFlags;

	virtual void(void) Death;
	virtual void(void) MakePlayer;
	virtual void(void) MakeTempSpectator;

	virtual void(void) InputUse_Down;
	virtual void(void) InputUse_Up;
#endif

	virtual void Footsteps_Update(void);
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
