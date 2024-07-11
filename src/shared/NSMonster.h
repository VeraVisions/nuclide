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

var bool autocvar_ai_debugLogic = false;
void
_NSMonster_Log(string className, string functionName, float edictNum, string warnMessage)
{
	if (autocvar_g_logTimestamps)
		printf("^9%f ^5%s (%d) ^7: %s\n", time, functionName, edictNum, warnMessage);
	else
		printf("^5%s (%d) ^7: %s\n", functionName, edictNum, warnMessage);
}
#define NSMonsterLog(...) if (autocvar_ai_debugLogic == true) _NSMonster_Log(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))

/**
Bitfield enumeration for NSMonster its SendFlags field.

These give hint as to which internal fields get networked to the client.
*/
typedef enumflags
{
	MONFL_CHANGED_ORIGIN_X,
	MONFL_CHANGED_ORIGIN_Y,
	MONFL_CHANGED_ORIGIN_Z,
	MONFL_CHANGED_ANGLES_X,
	MONFL_CHANGED_ANGLES_Y,
	MONFL_CHANGED_ANGLES_Z,
	MONFL_CHANGED_MODELINDEX,
	MONFL_CHANGED_SIZE,
	MONFL_CHANGED_FLAGS,
	MONFL_CHANGED_SOLID,
	MONFL_CHANGED_FRAME,
	MONFL_CHANGED_SKINHEALTH,
	MONFL_CHANGED_MOVETYPE,
	MONFL_CHANGED_EFFECTS,
	MONFL_CHANGED_BODY,
	MONFL_CHANGED_SCALE,
	MONFL_CHANGED_VELOCITY,
	MONFL_CHANGED_RENDERCOLOR,
	MONFL_CHANGED_RENDERAMT,
	MONFL_CHANGED_RENDERMODE,
	MONFL_CHANGED_HEADYAW
} nsmonster_changed_t;

/** List of supported ACT types.
These originate from GoldSrc and framegroups within models can be tagged
with them. This way the game-logic doesn't need to know the exact framegroup
but can instead pick a random ACT and we'll pick the right framegroup for you. */
typedef enum {
	ACT_RESET = 0,
	ACT_IDLE = 1i,
	ACT_GUARD,
	ACT_WALK,
	ACT_RUN,
	ACT_FLY,
	ACT_SWIM,
	ACT_HOP,
	ACT_LEAP,
	ACT_FALL,
	ACT_LAND,
	ACT_STRAFE_LEFT,
	ACT_STRAFE_RIGHT,
	ACT_ROLL_LEFT,
	ACT_ROLL_RIGHT,
	ACT_TURN_LEFT,
	ACT_TURN_RIGHT,
	ACT_CROUCH,
	ACT_CROUCHIDLE,	
	ACT_STAND,
	ACT_USE,
	ACT_SIGNAL1,
	ACT_SIGNAL2,
	ACT_SIGNAL3,
	ACT_TWITCH,
	ACT_COWER,
	ACT_SMALL_FLINCH,
	ACT_BIG_FLINCH,
	ACT_RANGE_ATTACK1,
	ACT_RANGE_ATTACK2,
	ACT_MELEE_ATTACK1,
	ACT_MELEE_ATTACK2,
	ACT_RELOAD,
	ACT_ARM,
	ACT_DISARM,
	ACT_EAT,
	ACT_DIESIMPLE,
	ACT_DIEBACKWARD,
	ACT_DIEFORWARD,
	ACT_DIEVIOLENT,
	ACT_BARNACLE_HIT,
	ACT_BARNACLE_PULL,
	ACT_BARNACLE_CHOMP,
	ACT_BARNACLE_CHEW,
	ACT_SLEEP,
	ACT_INSPECT_FLOOR,
	ACT_INSPECT_WALL,
	ACT_IDLE_ANGRY,
	ACT_WALK_HURT,
	ACT_RUN_HURT,
	ACT_HOVER,
	ACT_GLIDE,
	ACT_FLY_LEFT,
	ACT_FLY_RIGHT,
	ACT_DETECT_SCENT,
	ACT_SNIFF,
	ACT_BITE,
	ACT_THREAT_DISPLAY,
	ACT_FEAR_DISPLAY,
	ACT_EXCITED,
	ACT_SPECIAL_ATTACK1,
	ACT_SPECIAL_ATTACK2,	
	ACT_COMBAT_IDLE,
	ACT_WALK_SCARED,
	ACT_RUN_SCARED,
	ACT_VICTORY_DANCE,
	ACT_DIE_HEADSHOT,
	ACT_DIE_CHESTSHOT,
	ACT_DIE_GUTSHOT,
	ACT_DIE_BACKSHOT,
	ACT_FLINCH_HEAD,
	ACT_FLINCH_CHEST,
	ACT_FLINCH_STOMACH,
	ACT_FLINCH_LEFTARM,
	ACT_FLINCH_RIGHTARM,
	ACT_FLINCH_LEFTLEG,
	ACT_FLINCH_RIGHTLEG,
} monster_activity_t;

/** Monster flags, these are defined by the level designers. */
typedef enumflags
{
	MSF_WAITTILLSEEN,	/**< AI will be enabled once seen (1) */
	MSF_GAG,			/**< Won't talk (2) */
	MSF_MONSTERCLIP,	/**< Collides against func_monsterclip (4) */
	MSF_RESERVED1,		/**< Reserved for entityDef (8) */
	MSF_PRISONER,		/**< Only reacts to scripted sequences (16) */
	MSF_RESERVED2,		/**< Reserved for entityDef (32) */
	MSF_IGNOREPLAYER,	/**< Ignores players (64) */
	MSF_WAITFORSCRIPT,	/**< AI waits for scripted_sequence to end (128) */
	MSF_RESERVED3,		/**< Reserved for entityDef (256) */
	MSF_FADECORPSE,		/**< Corpse fades instead of staying (512) */
	MSF_MULTIPLAYER,	/**< Will spawn in multiplayer NSGameRules (1024) */
	MSF_FALLING,		/**< Is falling (2048) */
	MSF_HORDE			/**< Part of a horde (4096) */
} monsterFlag_t;

/** For future use: SpawnFlags used in Source */
typedef enumflags
{
	SMSF_WAITTILLSEEN,		/**< AI will be enable once seen (1) */
	SMSF_GAG,				/**< Won't talk (2) */
	SMSF_FALLTOGROUND,		/**< Fall to ground, instead of dropping instantly (4) */
	SMSF_DROPHEALTHKIT,		/**< Drops healthkit (8) */
	SMSF_EFFICIENT,			/**< Walks direct paths (16) */
	SMSF_RESERVED1,			/**< Reserved for entityDef (32) */
	SMSF_RESERVED2,			/**< Reserved for entityDef (64) */
	SMSF_WAITFORSCRIPT,		/**< AI waits for scripted_sequence to end (128) */
	SMSF_LONGVISIBILITY,	/**< Long visibility and line of sight (256) */
	SMSF_FADECORPSE,		/**< Corpse fades instead of staying (512) */
	SMSF_THINKOUTPVS,		/**< Think outside the PVS (1024) */
	SMSF_TEMPLATE,			/**< Will spawn through npc_maker (2048) */
	SMSF_ALTCOLLISION,		/**< Alternative collision, avoiding players (4096) */
	SMSF_NODROPWEAPONS,		/**< Don't drop weapons (8192) */
	SMSF_IGNOREPLAYERPUSH	/**< Ignore pushing players (16384) */
} sourceMonsterFlag_t;

/** Behaviour states. */
typedef enum
{
	MONSTER_IDLE,
	MONSTER_ALERT,
	MONSTER_FOLLOWING,
	MONSTER_CHASING,
	MONSTER_AIMING,
	MONSTER_DEAD,
	MONSTER_GIBBED
} monsterState_t;

/** Scripted sequence states. */
typedef enum
{
	SEQUENCESTATE_NONE,
	SEQUENCESTATE_IDLE,
	SEQUENCESTATE_ACTIVE,
	SEQUENCESTATE_ENDING
} sequenceState_t;

/** Alliance states. */
typedef enum
{
	MAL_FRIEND, /**< 1, friendly towards the player */
	MAL_ENEMY,  /**< 2, unfriendly towards the player */
	MAL_ALIEN,  /**< 3, unfriendly towards anyone but themselves */
	MAL_ROGUE,   /**< 4, no allies, not even amongst themselves */
	MAL_NEUTRAL	/**< 5, neutral - will not attack, will not be attacked */
} allianceState_t;

/** Movement states */
typedef enum
{
	MOVESTATE_IDLE,
	MOVESTATE_WALK,
	MOVESTATE_RUN
} movementState_t;

/** These numerations involve the m_iTriggerCondition attribute.
Basically these conditions are being checked and triggered depending on what
it's set to. If any of those checks are successful, we trigger our target
under the m_strTriggerTarget attribute. */
typedef enum
{
	MTRIG_NONE,					/**< 1, nothing */
	MTRIG_SEEPLAYER_ANGRY,		/**< 2, we see an enemy player, that we want to harm */
	MTRIG_PAIN,					/**< 3, taken damage */ 
	MTRIG_HALFHEALTH,			/**< 4, lost half of our base_health */
	MTRIG_DEATH,				/**< 5, we have died. */
	MTRIG_SQUADMEMBERDEAD,		/**< 6, a squad member died */
	MTRIG_SQUADLEADERDEAD,		/**< 7, the squad leader died */
	MTRIG_HEARNOISE,			/**< 8, we hear some noise around the world. */
	MTRIG_HEARENEMYPLAYER,		/**< 9, we hear a player we are enemies with */
	MTRIG_HEARWEAPONS,			/**< 10, we hear weapons being fired */
	MTRIG_SEEPLAYER,			/**< 11, we see a player, don't have to be angry at him. */
	MTRIG_SEEPLAYER_RELAXED,	/**< 12, we see a player and we're currently attacking anything */
} triggerCondition_t;

/* FIXME: I'd like to move this into NSMonster, but our current IsFriend()
 * check is currently only checking on a .takedamage basis. */
.int m_iAlliance;

/*! \brief This entity class represents non-player characters. */
/*!QUAKED NSMonster (0 0.8 0.8) (-16 -16 0) (16 16 72) WAITTILLSEEN GAG MONSTERCLIP x PRISONER x IGNOREPLAYER WAITFORSCRIPT PREDISASTER FADECORPSE MULTIPLAYER FALLING HORDE
# OVERVIEW
This entity class represents non-player characters. 
They have the ability to move around (or stand still) but are all
capable of fighting if prompted to.

# KEYS
- "targetname" : Name
- "netname" :	Name used for obituaries and debug info.
- "maxs" : Bounding box mins.
- "mins" : Bounding box maxs.

## KEYS - TRIGGERS
- "TriggerCondition" : See triggerCondition_t for which numerical values to pick.
- "TriggerTarget" : Will trigger this entity when TriggerCondition (triggerCondition_t) is met.

## KEYS - BEHAVIOUR
- "health" : Starting health.
- "dead" : Whether to start the monster in a dead state (0 or 1).
- "team" : Alliance. See allianceState_t for which numerical values to pick.
- "speed_walk" : Walk speed in units per second.
- "speed_run" : Run speed in units per second.
- "eye_height" : Height in units at which to place the eyes from the origin. Use the cvar r_showViewCone to debug it.
- "snd_sight" : SoundDef to play upon 'alert'.
- "snd_idle" : SoundDef to play when the monster is idle.
- "idle_min" : Min idle delay in seconds.
- "idle_max" : Max idle delay in seconds.
- "snd_footstep" : Which soundDef to play when a footstep should occur.
- "snd_chatter" : An idle type soundDef to play.
- "snd_chatter_combat" : An idle type soundDef, only during combat.
- "snd_pain" : SoundDef to play when in pain.
- "snd_death" : SoundDef to play when death settles in.
- "snd_thud" : SoundDef to play when the monster falls to the ground.

## KEYS - ATTACK (MELEE)
- "def_attack_melee" : Which entityDef to look into for a melee attack. [CONTINUED] 
- "attack_melee_range" : Range under which melee attacks occur.
- "snd_melee_attack" : SoundDef to play when melee attacking.
- "snd_melee_attack_hit" : SoundDef to play when a successful melee attack occurs.
- "snd_melee_attack_miss" : SoundDef to play when a melee attack misses.

## KEYS - ATTACK (RANGED)
- "def_attack_ranged_1" : EntityDef that contains primary ranged attack info.
- "attack_ranged1_range" : Range for the primary ranged attack.
- "def_attack_ranged_2" :  EntityDef that contains secondary ranged attack info.
- "attack_ranged2_range" : Range for the secondary ranged attack.
- "snd_ranged_attack" : SoundDef to play upon ranged attack.
- "reload_count" : how many ranged attacks until reload. Only affects primary ranged attacks.
- "reload_delay" : Time between reloads in seconds. Requires `reload_count` to be set > 0.
- "snd_reload" : SoundDef to play when reloading.
- "reserve_ammo" : The amount of reserve ammo. -1 is infinite (default)
- "attack_cone" : Cone in which to attack.
- "attack_accuracy" : Accuracy (or rather, lack of) multiplier.

## KEYS - ATTACK (SPECIAL)
- "def_attack_special_1" : EntityDef that contains primary special attack info. Intended for projectiles.
- "attack_special1_range" : Range for the primary special attack.
- "num_projectiles" : The number of primary special projectiles to shoot.
- "projectile_spread" : Spread of the projectiles. 0 is none. 1 is the max.
- "projectile_delay" : Delay in seconds until a special attack projectile is thrown.

- "weapon_drawn" : Whether or not the weapon is drawn by default. Either 0 or 1.
- "body_on_draw" : Which bodygroup to switch to when the monster has drawn its weapon.
- "leap_damage" : Amount of damage appled when the enemy leaps towards you and hits.

# SPAWNFLAGS
- WAITTILLSEEN (1) - Play scripted sequence only once the monster gets seen by a player.
- GAG (2) - Won't speak.
- MONSTERCLIP (4) - Interacts with monsterclips?
- PRISONER (16) - Never used.
- IGNOREPLAYER (64) - Ignores the player. Like 'notarget'.
- WAITFORSCRIPT (128) - Does nothing, until a scripted sequence runs on the monster. Then becomes alive.
- PREDISASTER (256) - Special flag used in Half-Life.
- FADECORPSE (512) - Corpse will disappear on its own.
- MULTIPLAYER (1024) - Available in multiplayer.
- FALLING (2048) - Will not drop to the floor upon level spawn - but fall when in-game.
- HORDE (4096) - Never used.

@ingroup baseclass
*/
class NSMonster:NSNavAI
{
public:
	void NSMonster(void);

#ifdef SERVER	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Touch(entity);
	//virtual void Hide(void);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Input(entity,string,string);
	virtual void Pain(entity, entity, int, vector, int);
	virtual void Death(entity, entity, int, vector, int);
	virtual void Physics(void);
	virtual void Gib(void);
	virtual void Sound(string);
	virtual void SpawnKey(string,string);

	/** Internal use only.
	Run every frame to go through the main AI loop. */
	virtual void RunAI(void);
	/** Overridable: Called after a while when they've got nothing to do. */
	virtual void IdleNoise(void);
	/** Overridable: Called when they start falling. */
	virtual void FallNoise(void);
	/** Overridable: Called when this monster gets 'alerted' to something new. */
	virtual void AlertNoise(void);

	/** Returns if they're considered alive. */
	virtual bool IsAlive(void);
	/** Returns whether they are allied with the type in question */
	virtual bool IsFriend(int);
	/** Overridable: Called once, when the monster has died. */
	virtual void HasBeenKilled(void);
	/** Overridable: Called every time the monster is hurt, while still alive. */
	virtual void HasBeenHit(void);
	/* Overridable: Called when the monster was gibbed. */
	virtual void HasBeenGibbed(void);
	/* Overridable: Called when the monster has been alerted to threat. */
	virtual void HasBeenAlerted(void);

	/* see/hear subsystem */
	/** Internal use only. Called every frame to simulate vision. */
	virtual void SeeThink(void);
	/** Overridable: Returns the field of view in degrees. */
	virtual float SeeFOV(void);

	/** FIXME: Same as WarnAllies/StartleAllies? WTF? */
	virtual void AlertNearby(void);

	/* movement */
	/** Overridable: Returns the walking speed in Quake units per second. */
	virtual float GetWalkSpeed(void);
	/** Overridable: Returns the chase speed in Quake units per second. */
	virtual float GetChaseSpeed(void);
	/** Overridable: Returns the running speed in Quake units per second. */
	virtual float GetRunSpeed(void);
	/** Overridable: Returns the turning speed in euler-angle units per second. */
	virtual float GetYawSpeed(void);

	/* attack system */
	/** Overridable: Called when they're drawing a weapon. */
	virtual void AttackDraw(void);
	/** Overridable: Called when they're holstering a weapon. */
	virtual void AttackHolster(void);
	/** Overridable: Called when aiming their weapon. */
	virtual void AttackThink(void);
	/** Overridable: Called when attempting to melee attack. Return 0 if impossible. */
	virtual int AttackMelee(void);
	/** Overridable: Called when attempting to attack from a distance. Return 0 if impossible. */
	virtual int AttackRanged(void);

	/** Overridable: Returns the distance in qu of what'll be a successfull melee attack. */
	virtual float MeleeMaxDistance(void);

	/** Returns whether or not we should attempt a melee attack.
		FIXME: Should pass a parameter for the enemy in question instead! */
	virtual bool MeleeCondition(void);

	/** Returns TRUE if 'enemy' should be considered a valid target for killing */
	nonvirtual bool IsValidEnemy(entity);
	/** Returns TRUE if the monster is currently on route to a position. */
	virtual bool IsOnRoute(void);

	/* sequences */
	/** Internal use only. Called when a sequence is done. */
	virtual void FreeState(void);
	/** Internal use only. Called when a sequence is done. */
	virtual void FreeStateMoved(void);
	/** Internal use only. Called when a sequence is done and we leave a corpse. */
	virtual void FreeStateDead(void);
	/** Internal use only. Called when a movement route is done. */
	virtual void RouteEnded(void);
	/** Internal use only. Called every frame to progress through a route. */
	virtual void WalkRoute(void);
	
	/** Returns the type of sequence they're currently in. */
	nonvirtual int GetSequenceState(void);
	/** Returns if they're currently in a scripted sequence. */
	nonvirtual bool InSequence(void);

	/* animation cycles */
	/** DEPRECATED, Overridable: Called when we need to play a fresh idle framegroup. */
	virtual int AnimIdle(void);
	/** DEPRECATED, Overridable: Called when we need to play a fresh walking framegroup. */
	virtual int AnimWalk(void);
	/** DEPRECATED, Overridable: Called when we need to play a fresh running framegroup. */
	virtual int AnimRun(void);
	/** Overridable: Returns which framegroup to play for a given ACT. */
	virtual float FramegroupForAct(float);
	/** Call to play an ACT on the given NSMonster. */
	nonvirtual void ActPlay(float);
	/** Call to play a single animation onto it, which cannot be interrupted by movement. */
	virtual void AnimPlay(float);
	/** Internal use only. Run every frame to update animation parameters. */
	virtual void AnimationUpdate(void);
	/** Returns if we're currently in a forced animation sequence. */
	nonvirtual bool InAnimation(void);
	nonvirtual void AnimReset(void);

	/* states */
	/** Called whenever the state of this NSMonster changes. */
	virtual void StateChanged(monsterState_t,monsterState_t);
	/** Sets the current state of this NSMonster. */
	nonvirtual void SetState(monsterState_t);
	/** Returns the current state of this NSMonster. */
	nonvirtual monsterState_t GetState(void);

	/* TriggerTarget/Condition */
	/** Returns the condition under which they'll trigger their targets. */
	nonvirtual int GetTriggerCondition(void);
	/** Call to trigger their targets manually. */
	virtual void TriggerTargets(void);

	virtual void Trigger(entity, triggermode_t);
#endif

#ifdef CLIENT

	/** overrides */
	virtual void customphysics(void);
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
#endif

private:

	vector v_angle_net;

#ifdef CLIENT
	nonvirtual void _RenderDebugViewCone();
#endif

	PREDICTED_FLOAT(m_flHeadYaw)
	PREDICTED_FLOAT_N(subblendfrac)
	PREDICTED_FLOAT_N(bonecontrol1)

#ifdef SERVER
	entity m_eLookAt;
	entity m_ssLast;
	vector oldnet_velocity;
	float m_flPitch;
	int m_iFlags;
	vector base_mins;
	vector base_maxs;
	float base_health;

	/* sequences */
	string m_strRouteEnded;
	int m_iSequenceRemove;
	int m_iSequenceState;
	float m_flSequenceEnd;
	float m_flSequenceSpeed;
	vector m_vecSequenceAngle;
	int m_iSequenceFlags;
	movementState_t m_iMoveState;
	string m_strSequenceKillTarget;

	int m_iTriggerCondition;
	string m_strTriggerTarget;

	/* model events */
	float m_flBaseTime;

	/* attack/alliance system */
	entity m_eEnemy;
	float m_flAttackThink;
	monsterState_t m_iMState;
	monsterState_t m_iOldMState;
	vector m_vecLKPos; /* last-known pos */

	/* see/hear subsystem */
	float m_flSeeTime;
	/* animation cycles */
	float m_flAnimTime;

	/* timer for keeping track of the target */
	float m_flTrackingTime;

	PREDICTED_VECTOR_N(view_ofs)

	/* caching variables, don't save these */
	float m_actIdle;
	bool m_bTurning;
	float m_flIdleNext;
	float _m_flMeleeAttempts;
	float _m_flMeleeDelay;
	float _m_flBurstCount;
	bool _m_bShouldThrow;
	bool _m_bStartDead;
	float _m_flFrame;

	/* save these please */
	float _m_flReloadTracker;
	bool m_bWeaponDrawn;

	/* entityDef related */
	float m_flEyeHeight;
	string m_sndSight;
	string m_sndIdle;
	float m_flIdleMin;
	float m_flIdleMax;
	string m_sndFootstep;
	string m_sndChatter;
	string m_sndChatterCombat;
	string m_sndPain;

	string m_sndMeleeAttack;
	string m_sndMeleeAttackHit;
	string m_sndMeleeAttackMiss;

	string m_sndDeath;
	string m_sndThud;

	/* attack definitions, if defined will fire projectiles */
	string m_defSpecial1;
	float m_flSpecial1Range;
	string m_defSpecial2;
	float m_flSpecial2Range;
	string m_defRanged1;
	float m_flRanged1Range;
	string m_defRanged2;
	float m_flRanged2Range;

	/* ranged1 only */
	int m_iNumProjectiles;
	float m_flProjectileDelay;
	float m_flProjectileSpread;

	/* general */
	float m_flAttackCone;
	float m_flAttackAccuracy;

	/* melee attack */
	string m_defMelee;
	float m_flMeleeRange;

	string m_sndRangedAttack;
	float m_flReloadCount;
	float m_flReloadDelay;
	string m_sndReload;
	float m_flReserveAmmo;

	string m_sndRangedAttack2;

	bool m_bWeaponStartsDrawn;
	string m_strBodyOnDraw;

	float m_flWalkSpeed;
	float m_flRunSpeed;

	float m_flLeapDamage;
	bool m_bLeapAttacked;
	float m_flForceSequence;
	float m_flSkin;
	bool m_bGagged;

	nonvirtual void _LerpTurnToEnemy(void);
	nonvirtual void _LerpTurnToPos(vector);
	nonvirtual void _LerpTurnToYaw(vector);
	virtual void _Alerted(void);
	nonvirtual void _ChaseAfterSpawn(void);
#endif
};

#ifdef CLIENT
string Sentences_GetSamples(string);
string Sentences_ProcessSample(string);
#endif

#ifdef SERVER
void NSMonster_AlertEnemyAlliance(vector pos, float radius, int alliance);
entity NSMonster_FindClosestPlayer(entity);
#endif

.float baseframe2;
.float baseframe1time;
.float baseframe2time;
.float baselerpfrac;
.float bonecontrol1;
.float bonecontrol2;
.float bonecontrol3;
.float bonecontrol4;
.float bonecontrol5;
.float subblendfrac;
.float subblend2frac;
.float basesubblendfrac;
.float basesubblend2frac;
