/*
 * Copyright (c) 2023 Vera Visions LLC.
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

#ifdef SERVER
/*! \brief Shared-Entity: Achievement Manager */
/*!QUAKED logic_achievement (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
# OVERVIEW
Unlocks achievements or aids in the progression of them.

# KEYS
- "targetname" : Name
- "AchievementEvent" : Identifier of the achievement.
- "StartDisabled" : Entity will have to be enabled in order to work when set to 1.

# INPUTS
- "FireEvent" : Triggers the achievement.
- "Enable" : Enable the entity.
- "Disable" : Disable the entity.
- "Toggle" : Toggles between enabled/disabled states.

# OUTPUTS
- "OnFired" : Triggered when the 'FireEvent' is received.

# NOTES
Ensure to prefix the value of the `AchievementEvent` key with `ACHIEVEMENT_EVENT_`. For example, if you are using SteamWorks and have your achievement on there named `FOOBAR` then you want the value to be `ACHIEVEMENT_EVENT_FOOBAR`.

# TRIVIA
This entity was introduced in The Orange Box (2007) for Xbox 360.

@ingroup sharedentity
@ingroup pointentity
*/
class
logic_achievement:ncPointTrigger
{
public:
	void logic_achievement(void);

	/** overrides */
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void SpawnKey(string, string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Input(entity, string, string);
	virtual void Trigger(entity, triggermode_t);

	nonvirtual void CallEvent(entity);

private:
	string m_strAchievementEvent;
	string m_outputOnFired;
};

void
logic_achievement::logic_achievement(void)
{
	m_strAchievementEvent = __NULL__;
	m_outputOnFired = __NULL__;
}

void
logic_achievement::Save(float handle)
{
	SaveString(handle, "m_strAchievementEvent", m_strAchievementEvent);
	SaveString(handle, "m_outputOnFired", m_outputOnFired);
}

void
logic_achievement::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_strAchievementEvent":
		m_strAchievementEvent = ReadString(setValue);
		break;
	case "m_outputOnFired":
		m_outputOnFired = ReadString(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
logic_achievement::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "AchievementEvent":
		m_strAchievementEvent = ReadString(setValue);
		break;
	case "OnFired":
		m_outputOnFired = PrepareOutput(m_outputOnFired, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
logic_achievement::Spawned(void)
{
	super::Spawned();

	if (m_outputOnFired)
		m_outputOnFired = CreateOutput(m_outputOnFired);
}

void
logic_achievement::Respawn(void)
{
	InitPointTrigger();
}

void
logic_achievement::Input(entity activatorEntity, string inputName, string dataField)
{
	switch (inputName) {
	case "FireEvent":
		CallEvent(activatorEntity);
		break;
	default:
		super::Input(activatorEntity, inputName, dataField);
	}
}

void
logic_achievement::Trigger(entity activatorEntity, triggermode_t state)
{
	CallEvent(activatorEntity);
}

void
logic_achievement::CallEvent(entity targetPlayer)
{
	if (TriggerEnabled() == false) {
		return;
	}

	UseOutput(targetPlayer, m_outputOnFired);

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_ACHIEVEMENT);
	WriteString(MSG_MULTICAST, m_strAchievementEvent);
	msg_entity = targetPlayer;
	multicast([0,0,0], MULTICAST_ONE_R);
}
#endif