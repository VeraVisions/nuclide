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
	TM_MONSTERS,
	TM_NOCLIENTS,
	TM_PUSHABLES
};

/*! \brief Server-Entity: Multi Use Trigger Volume */
/*!QUAKED trigger_multiple (.5 .5 .5) ? CLIENTS NPCS PUSHABLES PHYSICS FRIENDLIES CLIENTSINVEHICLES EVERYTHING x x CLIENTSNOTINVEHICLES DEBRIS NPCSINVEHICLES NOBOTS
# OVERVIEW
A trigger volume which works more than once. 

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "delay" : Delay until target is triggered.
- "wait" : Time until this entity can trigger again
- "StartDisabled" : Entity will have to be enabled in order to work when set to 1.

# INPUTS
- "Enable" : Enable the entity.
- "Disable" : Disable the entity.
- "Toggle" : Toggles between enabled/disabled states.

# OUTPUTS
- "OnStartTouch": Triggered when something starts touching this volume
- "OnEndTouchAll": Triggered when nothing touched the entity no more

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
If you want an entity like this that can only be used once, see trigger_once.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup server
@ingroup brushentity
*/
class
trigger_multiple:NSBrushTrigger
{
public:
	void trigger_multiple(void);
	
	virtual void Spawned(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Touch(entity);
	virtual void SpawnKey(string,string);
	virtual void Input(entity,string,string);
	virtual void EndTouch(entity);

private:
	float m_flWait;

	/* Input/Output */
	string m_strOnStartTouch;
	string m_strOnEndTouchAll;
	string m_strOnTrigger;
};

void
trigger_multiple::trigger_multiple(void)
{
	m_flWait = 0.0f;

	/* Input/Output */
	m_strOnStartTouch =
	m_strOnEndTouchAll =
	m_strOnTrigger =  __NULL__;
}

void
trigger_multiple::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveString(handle, "m_strOnStartTouch", m_strOnStartTouch);
	SaveString(handle, "m_strOnEndTouchAll", m_strOnEndTouchAll);
	SaveString(handle, "m_strOnTrigger", m_strOnTrigger);
}

void
trigger_multiple::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flWait":
		m_flWait = ReadFloat(strValue);
		break;
	case "m_strOnStartTouch":
		m_strOnStartTouch = ReadString(strValue);
		break;
	case "m_strOnEndTouchAll":
		m_strOnEndTouchAll = ReadString(strValue);
		break;
	case "m_strOnTrigger":
		m_strOnTrigger = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_multiple::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "wait":
		m_flWait = ReadFloat(strValue);
		break;
	case "StartDisabled":
		m_bStartDisabled = ReadBool(strValue);
		m_bIsModern = true;
		break;
	case "OnStartTouch":
	case "OnStartTouchAll":
		m_strOnStartTouch = PrepareOutput(m_strOnStartTouch, strValue);
		break;
	case "OnEndTouchAll":
		m_strOnEndTouchAll = PrepareOutput(m_strOnEndTouchAll, strValue);
		break;
	case "OnTrigger":
		m_strOnTrigger = PrepareOutput(m_strOnTrigger, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_multiple::Spawned(void)
{
	super::Spawned();

	if (m_strOnTrigger)
		m_strOnTrigger = CreateOutput(m_strOnTrigger);
	if (m_strOnStartTouch)
		m_strOnStartTouch = CreateOutput(m_strOnStartTouch);
	if (m_strOnEndTouchAll)
		m_strOnEndTouchAll = CreateOutput(m_strOnEndTouchAll);
}

void
trigger_multiple::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "TouchTest":
		Touch(entityActivator);
		break;
	case "StartTouch":
		StartTouch(entityActivator);
		break;
	case "EndTouch":
		EndTouch(entityActivator);
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
		break;
	}
}

void
trigger_multiple::Touch(entity eToucher)
{
	if (IsThinking() == true)
		return;

	if (GetMaster(eToucher) == false)
		return;

	if (m_bEnabled == false)
		return;

	/* legacy entity check */
	if (m_bIsModern == false) {
		if (HasSpawnFlags(TM_NOCLIENTS) && eToucher.flags & FL_CLIENT)
			return;
		if (!HasSpawnFlags(TM_MONSTERS) && eToucher.flags & FL_MONSTER)
			return;
		if (!HasSpawnFlags(TM_PUSHABLES) && eToucher.classname == "func_pushable")
			return;
		if (eToucher.solid == SOLID_TRIGGER)
			return;
	} else if (CanBeTriggeredBy(eToucher) == false) {
		return;
	}

	/* if the target key isn't used, assume we're using the new I/O system */
	if (HasTriggerTarget() == false)
		UseOutput(eToucher, m_strOnStartTouch);
	else
		UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);

	/* This is effectively a trigger_once...*/
	if (m_flWait != -1) {
		ScheduleThink(Respawn, m_flWait);
	}

	SetSolid(SOLID_NOT);
}

void
trigger_multiple::EndTouch(entity eToucher)
{
	if (m_strOnEndTouchAll)
		UseOutput(eToucher, m_strOnEndTouchAll);
}
