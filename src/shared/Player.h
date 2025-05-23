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
of type ncPlayer.

# KEYS
- "armorProtection" : Amount of damage the armor absorbs.
- "armorBonus" : Armor point cost per health point.

## PHYSICS KEYS
- "pm_accelerate" : Movement speed acceleration.
- "pm_airaccelerate" : Movement speed acceleration when in air.
- "pm_airstepsize" : In-air stepping size. You will be able to climb stair-steps this high.
- "pm_boxcenter" : When 1, will indicate that the [0,0,0] coordinate is at the center of the bounding box.
- "pm_boxwidth" : Width of the bounding box, in in-game units.
- "pm_crouchheight" : Physical height when crouched.
- "pm_crouchspeed" : Movement speed when crouched.
- "pm_crouchviewheight" : Eye height from local [0,0,0] player coordinate when crouched.
- "pm_edgefriction" : Friction value to use when near edges, helps to prevent falling off ledges.
- "pm_friction" : Friction value for when walking on ground.
- "pm_gravity" : Gravity for this player.
- "pm_jumpheight" : Jump height (vertical upwards velocity, units per second) the player can perform.
- "pm_maxviewpitch" : Maximum camera pitch.
- "pm_minviewpitch" : Minimum camera pitch.
- "pm_noclipaccelerate" : Movement speed acceleration when noclip/spectating.
- "pm_noclipspeed" : Movement speed when noclip/spectating.
- "pm_normalheight" : Physical height when standing.
- "pm_normalviewheight" : Eye height from local [0,0,0] player coordinate when standing.
- "pm_nospeedcap" : When 1, will enable limit-less bunnyhopping exploits.
- "pm_proneheight" : Physical height when prone.
- "pm_pronespeed" : Movement speed when prone.
- "pm_proneviewheight" : Eye height from local [0,0,0] player coordinate when prone.
- "pm_runspeed" : Movement speed when running.
- "pm_runfiring" : When 1, will enable firing weapons while running.
- "pm_stamina" : Stamina, the number of seconds you're able to run.
- "pm_staminarate" : The rate at which stamina replenishes.
- "pm_staminathreshold" : The stamina-value at which speed will be reduced.
- "pm_stepsize" : Stepping size. You will be able to climb stair-steps this high.
- "pm_stopspeed" : The speed at which the player stops moving.
- "pm_walkspeed" : Movement speed when walking (regular movement).
- "pm_wateraccelerate" : Movement speed acceleration, when underwater.
- "pm_waterjumpheight" : Jump height when underwater.

## ANIMATION KEYS

- "act_idle" : Animation to play when standing still.
- "act_idle_crouch"  : Animation to play when standing still, while crouched.
- "act_idle_prone" : Animation to play when standing still, while prone.
- "act_walk" : Animation to play when walking.
- "act_walk_crouch" : Animation to play when moving while crouched.
- "act_walk_prone" : Animation to play when moving while prone.
- "act_run" : Animation to play when running.
- "act_jump" : Animation to play when jumping in the air.
- "act_swim" : Animation to play when swimming underwater.
- "act_treadwater" : Animation to play when treading through water.
- "act_aim" : Torso animation to play when standing still, aiming your gun.
- "act_draw" : Torso animation to play when drawing a weapon.
- "act_attack" : Torso animation to play when attacking with a weapon.
- "act_reload" : Torso animation to play when reloading a weapon.

@note Much like the rest of Nuclide, we abstracted animations through [Activities](@ref activities). [Read up on Activities before proceeding](@ref activities).

The player animation system that is built-into Nuclide allows for players to strafe,
look up/down and flap character their mouths when they're talking on voice chat.

- "spine" : The bone to be treated as a spine bone. This one will be twisted according to the pitch of the first-person camera.
- "torsoStart" : First bone in the skeleton that belongs to the upper body/torso.
- "torsoStart" Last bone in the skeleton that belongs to the upper body/torso.

If your model format doesn't let you define activities, you can always force them in the decl.

### Making Weapons Use Different Animation Sets

When a weapon sets an "animPrefix", it will switch to an alternative set of activities, but only if it is present. T

For example, if you're firing a weapon with the "animPrefix" set to `foobar` while crouching, then we will first look if `act_attack_crouch_foobar` is set, and if that doesn't exist it will check for `act_attack_crouch`, and as a last resort possibly even `act_attack`. The weapon and stance are optional, as you will see. This will also allow you to set up a fallback for any unknown stances.

A more colorful example, from Rad-Therapy, highlighting the fields relevant to player animation:

`valve/decls/def/player.def`:
```
entityDef player
{
...
	"model"				"models/player.mdl"
	"spine"				"Bip01 Spine"
	"torsoStart"		"Bip01 Spine"
	"torsoEnd"			"Bip01 R Finger12"
	"act_idle"			"0"
	"act_jump"			"8"
	"act_walk_crouch"	"6"
	"act_idle_crouch"	"7"
	"act_run"			"12"
	"act_walk"			"13"

	"act_aim"			"16,14"
	"act_attack"		"17,15"

	"act_aim_crowbar"				"25"
	"act_attack_crowbar"			"26"
	"act_aim_crouch_crowbar"		"27"
	"act_attack_crouch_crowbar"		"28"
...
}
```

`valve/decls/def/weapons/crowbar.def`:
```
entityDef weapon_crowbar
{
...
	"model_player"		"models/p_crowbar.mdl"
	"animPrefix"		"crowbar"
...
}
```

With the above definitions, the crowbar will select the activities for `act_aim_crowbar` instead of `act_aim`, same with `act_attack` - in both regular and crouched stance.

@ingroup baseclass
*/
class
ncPlayer:ncSpectator
{
public:
	void ncPlayer(void);

	virtual void PlayGesture(float gestureAnim, float overrideTime);
	
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

	virtual void Damage(entity, entity, ncDict, float, vector, vector);
	virtual bool CanPickupEntity(ncEntity toPickUp, float massLimit, float sizeLimit);

#ifdef CLIENT
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

	virtual void Spawned(void);

#ifdef SERVER
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Respawn(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Death(entity, entity, int, vector, vector, int);
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

	/* Returns whether we're able to pick up an entity in the game with +use. If `true` you can then use PickupEntity() to attach it to the player. */
	virtual bool  CanPickupEntity(ncEntity, float, float);
	/* Will attach an entity to the player. It's position will continously update in front of the player camera, but in XR modes it may be attached to one of the hands instead.*/
	nonvirtual void PickupEntity(ncEntity);

#endif

	nonvirtual float WeaponAnimTime(void);

	virtual void Footsteps_Update(void);

private:
	nonvirtual void _UpdatePMoveVars(void);

#ifdef CLIENT
	NETWORKED_INT(m_weaponAnimSequence)
	NETWORKED_FLOAT(vehicle_entnum)

	float clsndindex_idle;
#endif

#ifdef SERVER
	float m_weaponCookingTime;
#endif

	NETWORKED_FLOAT(health)
	NETWORKED_FLOAT(sndindex_idle)

	/* animation */
	PREDICTED_FLOAT(anim_top)
	PREDICTED_FLOAT(anim_top_time)
	PREDICTED_FLOAT(anim_top_delay)
	PREDICTED_FLOAT(anim_bottom)
	PREDICTED_FLOAT(anim_bottom_time)

	NETWORKED_FLOAT_N(colormap)
	NETWORKED_FLOAT_N(gflags)
	NETWORKED_FLOAT(viewzoom)
	NETWORKED_VECTOR_N(view_ofs)
	NETWORKED_FLOAT_N(vw_index)
	NETWORKED_VECTOR_N(m_pmoveBaseVelocity)
	NETWORKED_VECTOR_N(v_angle)
	NETWORKED_FLOAT_N(gravity)
	NETWORKED_FLOAT_N(friction)

	NETWORKED_FLOAT(m_timeUntilNextAttack)
	NETWORKED_FLOAT(m_timeUntilNextIdle)
	NETWORKED_FLOAT(m_timeUntilReloaded)
	NETWORKED_FLOAT(m_timeSinceJump)
	NETWORKED_FLOAT(m_timeSinceTeleport)
	NETWORKED_VECTOR(m_punchAngle)
	NETWORKED_VECTOR(m_punchVelocity)

	NETWORKED_INT(m_weaponAnimSequence)
	NETWORKED_FLOAT(m_weaponAnimTime)

	/* We can't use the default .items field, because FTE will assume
	 * effects of some bits. Such as invisibility, quad, etc. 
	 * also, modders probably want 32 bits for items. */
	NETWORKED_FLOAT_N(activeweapon)
	ncItem m_itemList_net;
	int m_ammoTypes_net[MAX_AMMO_TYPES];

	/* vehicle info */
	NETWORKED_ENT(vehicle)
	NETWORKED_VECTOR(m_pmoveHookVelocity)

#ifdef CLIENT
	int sequence;

	/* external weapon model */
	ncRenderableEntity p_model;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;
#endif
	ncPMoveVars m_pmoveVars;

#ifdef SERVER
	int voted;
	int step;
	float m_timeUntilNextFootstep;

	int m_underwaterDamageDealt;
	float m_timeUnderwater;
	float m_timeUntilNextPainSFX;

	entity last_used;

	float pb_angle_delta;
	float pb_player_delta;
	vector pb_last_angles;

	int m_friendlyFireDamageDealt;
#endif

	entity m_holdingEntity;



	virtual void Event_DrawWeapon(void);
	virtual void Event_FireWeapon(void);
	virtual void Event_ReloadWeaponStart(void);
	virtual void Event_ReloadWeapon(void);
	virtual void Event_ReloadWeaponEnd(void);
	virtual void Event_HolsterWeapon(void);
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
	PLAYER_TOPFRAME,
	PLAYER_BOTTOMFRAME,
	PLAYER_CUSTOMFIELDSTART,
};

.bool _isPlayer;
