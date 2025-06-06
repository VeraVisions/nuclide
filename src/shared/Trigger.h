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

/* ncTrigger class is responsible for the legacy trigger architecture.
   In the future, ncEntity can be configured so that legacy
   triggers can be disabled. That's why this class is separate from ncIO.

   This is a very low-level class. You're never meant to use this.
   Use ncEntity as a basis for your classes.
*/

#define CENVGLOBAL_CVAR "env_global_data"

/** States for env_global data. */
typedef enum
{
	/** env_global data in question is set to 'off'. */
	GLOBAL_OFF,
	/** env_global data in question is set to 'on'. */
	GLOBAL_ON,
	/** env_global data in question is dead. */
	GLOBAL_DEAD
} globalstate_t;

/** The type of trigger activation. Used by trigger_auto and trigger_relay to specifically trigger states. TRIG_TOGGLE is the safe option, as it'll cause something to happen either way. The way an entity responds to the described state is up to how it is programmed. Many entities do not react to a change in state at all. */
typedef enum
{
	/** Trigger the target 'off', for doors that may tell them to close. */
	TRIG_OFF,
	/** Trigger the target 'on', for doors that may tell them to open. */
	TRIG_ON,
	/** Trigger the target the opposite to whatever they're currently in. */
	TRIG_TOGGLE
} triggermode_t;

enumflags
{
	TOUCHFILTER_CLIENTS,
	TOUCHFILTER_NPCS,
	TOUCHFILTER_PUSHABLE,
	TOUCHFILTER_PHYSICS,
	TOUCHFILTER_FRIENDLIES,
	TOUCHFILTER_CLIENTSINVEHICLES,
	TOUCHFILTER_EVERYTHING,
	TOUCHFILTER_PADDING1,
	TOUCHFILTER_PADDING2,
	TOUCHFILTER_CLIENTSNOTINVEHICLES,
	TOUCHFILTER_DEBRIS,
	TOUCHFILTER_NPCSINVEHICLES,
	TOUCHFILTER_NOBOTS
};


/** ncTrigger handles all the non-input as well as Legacy (Quake, GoldSource) style
trigger behaviour. It also deals with masters, touches, blocking and so on.

# Master

When an entity sets a 'master', it will only activate (which often includes firing its targets) when their specified 'master' itself returns a positive state.

The state can be set with SetValue() and is queried with GetValue().
*/
class ncTrigger:ncIO
{
public:
	void ncTrigger(void);

	/* touch/blocked */
	/** Called whenever out movement is being blocked by an entity.
		This is currently only relevant on entities that are of `MOVETYPE_PUSH`. */
	virtual void Blocked(entity);
	/** Called when we started touching another entity. */
	virtual void StartTouch(entity);

	/** Called whenever we're touching another entity. */
	virtual void Touch(entity);

	/** Called when we stopped touching the last touched entity. */
	virtual void EndTouch(entity);

	/* overrides */
	virtual void SpawnKey(string,string);

	virtual void OnRemoveEntity(void);

#ifdef SERVER
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Spawned(void);
	virtual void Input(entity,string,string);

	/** Sets the internal value of the entity as queried by GetValue(). This is used to to communicate whether or not the entity will permit triggers to fire that have this entity set as their 'master'. See the section regarding 'masters' for details. */
	nonvirtual void SetValue(int newValue);

	/* Called to check if the target entity can touch trigger itself. */
	virtual bool CanBeTriggeredBy(entity);

	/** Called whenever we're legacy triggered by another object or function. */
	virtual void Trigger(entity, triggermode_t);

	/* master feature */
	/** Returns what we will pass onto other's `ncTrigger::GetMaster()` calls if we're their master. */
	/* multisource overrides this, so keep virtual */
	virtual int GetValue(entity);

	/** When called will trigger its legacy targets with a given delay. */
	nonvirtual void UseTargets(entity,int,float);

	/** Sets the legacy target for this entity. */
	nonvirtual void SetTriggerTarget(string);

	/** Returns whether our master allows us to be triggered. The argument specifies who's requesting the info for the master. Required for game_team_master to verify against players. */
	nonvirtual int GetMaster(entity);

	/** Returns whether the trigger functionality of this entity is enabled. */
	nonvirtual bool TriggerEnabled(void);

	nonvirtual void EnableTrigger(void);
	nonvirtual void DisableTrigger(void);
	nonvirtual void ToggleTrigger(void);

	/** Returns the value of a given env_global property */
	nonvirtual globalstate_t GetGlobalValue(string);

	/** Returns the message which will be displayed upon trigger. */
	nonvirtual string GetTriggerMessage(void);

	/** Returns the name of the entity group it will remove from the game upon trigger. */
	nonvirtual string GetTriggerKillTarget(void);

	/** Returns the name of the entity group it can trigger (legacy style). */
	nonvirtual string GetTriggerTarget(void);

	/** Returns the time until this triggers is scheduled to fire its targets, relative time in seconds. */
	nonvirtual float GetTriggerDelay(void);

	/** Returns the first entity named after the target field. */
	nonvirtual entity GetTargetEntity(void);

	/** Returns TRUE if the entity has a legacy trigger target. */
	nonvirtual bool HasTriggerTarget(void);

	/** Returns TRUE if the entity has a name that can be used for messaging. */
	nonvirtual bool HasTargetname(void);

	/** Assigns the entity to a given team value. */
	nonvirtual void SetTeam(float);

	/** Retrives the team value of a given entity. */
	nonvirtual float GetTeam(void);
#endif
	/** Returns the last valid point the entity has touched. */
	nonvirtual vector GetTouchPosition(void);
	/** Returns the normal of the last valid surface the entity has touched. */
	nonvirtual vector GetTouchNormal(void);

private:
	/* not needed to be saved right now */
	float m_timeSinceLastTouch;
	bool m_beingTouched;
	entity m_touchingEntity;
	vector m_touchPosition;
	vector m_touchNormal;

	nonvirtual void _TouchHandler(void);
	nonvirtual void _BlockedHandler(void);

#ifdef SERVER
	nonvirtual void _TouchEnded(void);

	string m_globalName;
	string m_globalState;
	string m_triggerKillTarget;
	string m_triggerMessage;
	string m_masterName;
	int m_triggerValue;

	bool m_triggerEnabled;
	bool m_triggerStartsDisabled;
	bool m_triggerSpawnflagFilter;

	float m_touchingOnlyTeam;

	string m_outputOnStartTouch;
	string m_outputOnEndTouch;

	/* legacy trigger architecture */
	float m_triggerDelay;
#endif

#ifdef CLIENT
	float team;
#endif
};
