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

class NSTrigger:NSIO
{
	void(void) NSTrigger;

#ifdef SERVER
	string m_oldstrTarget; /* needed due to trigger_changetarget */

	string m_strGlobalState;
	string m_strKillTarget;
	string m_strMessage;
	string m_strMaster;
	int m_iUseType;
	int m_iTeam;
	int m_iValue;

	/* legacy trigger architecture */
	float m_flDelay;
	virtual void(entity, int) Trigger;
	virtual void(entity, int, float) UseTargets;
	virtual void(string) SetTriggerTarget;

	/* master feature */
	nonvirtual int(void) GetValue;
	nonvirtual int(void) GetMaster;
	nonvirtual globalstate_t(string) GetGlobalValue;
	nonvirtual string(void) GetTriggerTarget;
	nonvirtual bool(void) HasTriggerTarget;
	nonvirtual bool(void) HasTargetname;

	/* overrides */
	virtual void(float) Save;
	virtual void(string,string) Restore;
	virtual void(entity, string, string) Input;
#endif
	virtual void(string, string) SpawnKey;
};

enum
{ 
	USE_TOGGLE,
	USE_CONTINOUS
};

enum
{
	TRIG_OFF,
	TRIG_ON,
	TRIG_TOGGLE
};
