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

/* NSTrigger class is responsible for the legacy trigger architecture.
   In the future, NSEntity can be configured so that legacy
   triggers can be disabled. That's why this class is separate from NSIO.

   This is a very low-level class. You're never meant to use this.
   Use NSEntity as a basis for your classes.
*/

#define CENVGLOBAL_CVAR "env_global_data"

typedef enum
{
	GLOBAL_OFF,
	GLOBAL_ON,
	GLOBAL_DEAD
} globalstate_t;

typedef enum
{ 
	USE_TOGGLE,
	USE_CONTINOUS
} usetype_t;

typedef enum
{
	TRIG_OFF,
	TRIG_ON,
	TRIG_TOGGLE
} triggermode_t;


/** NSTrigger handles all the non-input as well as Legacy (Quake, GoldSource) style
trigger behaviour. It also deals with masters, touches, blocking and so on.
*/
class NSTrigger:NSIO
{
public:
	void NSTrigger(void);

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

	/* override */
	virtual void SpawnKey(string,string);

#ifdef SERVER
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Input(entity,string,string);

	/** Called whenever we're legacy triggered by another object or function. */
	virtual void Trigger(entity, triggermode_t);

	/* master feature */
	/** Returns what we will pass onto other's `::GetMaster()` calls if we're their master. */
	/* multisource overrides this, so keep virtual */
	virtual int GetValue(void);

	/** When called will trigger its legacy targets with a given delay. */
	nonvirtual void UseTargets(entity,int,float);

	/** Sets the legacy target for this entity. */
	nonvirtual void SetTriggerTarget(string);

	/** Returns whether our master allows us to be triggered. */
	nonvirtual int GetMaster(void);

	/** Returns the value of a given env_global property */
	nonvirtual globalstate_t GetGlobalValue(string);

	/** Returns the name of the entity group it can trigger (legacy style). */
	nonvirtual string GetTriggerTarget(void);

	/** Returns TRUE if the entity has a legacy trigger target. */
	nonvirtual bool HasTriggerTarget(void);

	/** Returns TRUE if the entity has a name that can be used for messaging. */
	nonvirtual bool HasTargetname(void);

	/** Assigns the entity to a given team value. */
	nonvirtual void SetTeam(float);

	/** Retrives the team value of a given entity. */
	nonvirtual float GetTeam(void);
#endif

private:
	/* not needed to be saved right now */
	float m_flTouchTime;
	bool m_beingTouched;
	entity m_eTouchLast;

	nonvirtual void _TouchHandler(void);
	nonvirtual void _BlockedHandler(void);

#ifdef SERVER
	string m_oldstrTarget; /* needed due to trigger_changetarget */

	string m_strGlobalState;
	string m_strKillTarget;
	string m_strMessage;
	string m_strMaster;
	int m_iUseType;
	int m_iValue;

	/* legacy trigger architecture */
	float m_flDelay;
#else
	float team;
#endif
};