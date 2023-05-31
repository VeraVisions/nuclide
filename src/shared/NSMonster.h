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

var bool autocvar_ai_debugLogic = false;
void
_NSMonster_Log(string msg)
{
	if (autocvar_ai_debugLogic == true)
		print(sprintf("%f %s\n", time, msg));
}
#define NSMonster_Log(...) _NSMonster_Log(sprintf(__VA_ARGS__))

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
	MSF_WAITTILLSEEN,
	MSF_GAG,
	MSF_MONSTERCLIP,
	MSF_RESERVED1,
	MSF_PRISONER,
	MSF_RESERVED2,
	MSF_IGNOREPLAYER,
	MSF_WAITFORSCRIPT,
	MSF_PREDISASTER,
	MSF_FADECORPSE,
	MSF_MULTIPLAYER,
	MSF_FALLING,
	MSF_HORDE
} monsterFlag_t;

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
	MAL_FRIEND, /* friendly towards the player */
	MAL_ENEMY,  /* unfriendly towards the player */
	MAL_ALIEN,  /* unfriendly towards anyone but themselves */
	MAL_ROGUE   /* no allies, not even amongst themselves */
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
	MTRIG_NONE,					/**< nothing */
	MTRIG_SEEPLAYER_ANGRY,		/**< we see an enemy player, that we want to harm */
	MTRIG_PAIN,					/**< taken damage */ 
	MTRIG_HALFHEALTH,			/**< lost half of our base_health */
	MTRIG_DEATH,				/**< we have died. */
	MTRIG_SQUADMEMBERDEAD,		/**< a squad member died */
	MTRIG_SQUADLEADERDEAD,		/**< the squad leader died */
	MTRIG_HEARNOISE,			/**< we hear some noise around the world. */
	MTRIG_HEARENEMYPLAYER,		/**< we hear a player we are enemies with */
	MTRIG_HEARWEAPONS,			/**< we hear weapons being fired */
	MTRIG_SEEPLAYER,			/**< we see a player, don't have to be angry at him. */
	MTRIG_SEEPLAYER_RELAXED,	/**< we see a player and we're currently attacking anything */
} triggerCondition_t;

/* FIXME: I'd like to move this into NSMonster, but our current IsFriend()
 * check is currently only checking on a .takedamage basis. */
.int m_iAlliance;

/** This entity class represents non-player characters. 
They have the ability to move around (or stand still) but are all
capable of fighting if prompted to.

There are a few methods that you need to reimplement in order for them
to do some basic combat:

	virtual void(void) AttackDraw;
	virtual void(void) AttackHolster;
	virtual int(void) AttackMelee;
	virtual int(void) AttackRanged;

Check their individual descriptions as to how you're supposed to approach them.
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
	virtual void Respawn(void);
	virtual void Pain(void);
	virtual void Death(void);
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

	/* sequences */
	/** Internal use only. Called when a sequence is done. */
	virtual void FreeState(void);
	/** Internal use only. Called when a sequence is done. */
	virtual void FreeStateMoved(void);
	/** Internal use only. Called when a movement route is done. */
	virtual void RouteEnded(void);
	/** Internal use only. Called every frame to progress through a route. */
	virtual void WalkRoute(void);
	
	/** Returns the type of sequence they're currently in. */
	nonvirtual int GetSequenceState(void);
	/** Returns if they're currently in a scripted sequence. */
	nonvirtual bool InSequence(void);

	/* animation cycles */
	/** Overridable: Called when we need to play a fresh idle framegroup. */
	virtual int AnimIdle(void);
	/** Overridable: Called when we need to play a fresh walking framegroup. */
	virtual int AnimWalk(void);
	/** Overridable: Called when we need to play a fresh running framegroup. */
	virtual int AnimRun(void);
	/** Call to play a single animation onto it, which cannot be interrupted by movement. */
	virtual void AnimPlay(float);
	/** Internal use only. Run every frame to update animation parameters. */
	virtual void AnimationUpdate(void);
	/** Returns if we're currently in a forced animation sequence. */
	nonvirtual bool InAnimation(void);

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
#endif

#ifdef CLIENT

	/** overrides */
	virtual void customphysics(void);
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
#endif

private:

#ifdef CLIENT
	nonvirtual void _RenderDebugViewCone();
#endif

#ifdef SERVER
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

	nonvirtual void _LerpTurnToEnemy(void);
	virtual void _Alerted(void);
#endif
};

#ifdef CLIENT
string Sentences_GetSamples(string);
string Sentences_ProcessSample(string);
void NSMonster_ReadEntity(bool);
#endif

#ifdef SERVER
void NSMonster_AlertEnemyAlliance(vector pos, float radius, int alliance);
entity NSMonster_FindClosestPlayer(entity);
#endif
