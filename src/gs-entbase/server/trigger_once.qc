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

enumflags
{
	TO_MONSTERS,
	TO_NOCLIENTS,
	TO_PUSHABLES
};

/*!QUAKED trigger_once (.5 .5 .5) ? CLIENTS NPCS PUSHABLES PHYSICS FRIENDLIES CLIENTSINVEHICLES EVERYTHING x x CLIENTSNOTINVEHICLES DEBRIS NPCSINVEHICLES NOBOTS
# OVERVIEW
A trigger volume which works only once.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "delay" : Delay until target is triggered.
- "StartDisabled" : Entity will have to be enabled in order to work when set to 1.

# INPUTS
- "Enable" : Enable the entity.
- "Disable" : Disable the entity.
- "Toggle" : Toggles between enabled/disabled states.

# SPAWNFLAGS
- TF_CLIENTS (1) : Clients can touch it.
- TF_NPCS (2) : NPCs can touch it.
- TF_PUSHABLE (4) : Pushables can touch it.
- TF_PHYSICS (8) : NSPhysicsEntity based classes can touch it.
- TF_FRIENDLIES (16) : Friendly NPCs can touch it.
- TF_CLIENTSINVEHICLES (32) : Clients within vehicles can touch it.
- TF_EVERYTHING (64) : Everything can touch it.
- TF_CLIENTSNOTINVEHICLES (512) : Clients outside vehicles can touch it.
- TF_DEBRIS (1024) : Debris can touch it.
- TF_NPCSINVEHICLES (2048) : NPCs in vehicles can touch it.
- TF_NOBOTS (4096) : Bots are never allowed to touch it.

# SPAWNFLAGS (LEGACY)
These work when 'StartDisabled' is not set in the entity definition.

- TM_MONSTERS (1) : Allow NPCs to activate this entity.
- TM_NOCLIENTS (2) : Don't allow players to activate this entity.
- TM_PUSHABLES (4) : Allow func_pushables to trigger this entity.

# NOTES
If you want an entity like this that can be used more than once, see trigger_multiple.

# TRIVIA
This entity was introduced in Quake (1996).
*/
class trigger_once:NSBrushTrigger
{
public:
	void trigger_once(void);

	/* overrides */
	virtual void Spawned(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Touch(entity);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);

	virtual void Input(entity, string, string);

private:
	string m_strOnStartTouch;
	string m_strOnTrigger;
};

void
trigger_once::trigger_once(void)
{
	m_strOnStartTouch =
	m_strOnTrigger = __NULL__;
}

void
trigger_once::Spawned(void)
{
	super::Spawned();

	if (m_strOnTrigger)
		m_strOnTrigger = CreateOutput(m_strOnTrigger);
	if (m_strOnStartTouch)
		m_strOnStartTouch = CreateOutput(m_strOnStartTouch);
}

void
trigger_once::Respawn(void)
{
	InitBrushTrigger();
	m_iValue = 0;
}

void
trigger_once::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strOnStartTouch", m_strOnStartTouch);
	SaveString(handle, "m_strOnTrigger", m_strOnTrigger);
}

void
trigger_once::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strOnStartTouch":
		m_strOnStartTouch = ReadString(strValue);
		break;
	case "m_strOnTrigger":
		m_strOnTrigger = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_once::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "OnStartTouch":
		m_strOnStartTouch = PrepareOutput(m_strOnStartTouch, strValue);
		break;
	case "OnTrigger":
		m_strOnTrigger = PrepareOutput(m_strOnTrigger, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
trigger_once::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "StartTouch":
		StartTouch(entityActivator);
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
		break;
	}
}

void
trigger_once::Touch(entity eToucher)
{
	bool isPushable = (substring(eToucher.classname, 0, 5) == "func_") ? true : false;

	if (GetMaster(eToucher) == FALSE)
		return;

	if (m_bEnabled == false)
		return;

	/* legacy entity check */
	if (m_bIsModern == false) {
		if (HasSpawnFlags(TO_NOCLIENTS) && eToucher.flags & FL_CLIENT)
			return;
		if (!HasSpawnFlags(TO_MONSTERS) && eToucher.flags & FL_MONSTER)
			return;
		if (!HasSpawnFlags(TO_PUSHABLES) && isPushable == true)
			return;
	} else if (CanBeTriggeredBy(eToucher) == false) {
		return;
	}

	SetSolid(SOLID_NOT); /* make inactive */
	m_iValue = 1;

	if (!target && !m_strKillTarget) {
		EntLog("%S is triggering OnStartTouch", eToucher.classname);
		UseOutput(eToucher, m_strOnStartTouch);
		return;
	}

	EntLog("%S is triggering %S", eToucher.classname, target);
	UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);
}
