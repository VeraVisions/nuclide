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

/*! \brief Server-Entity: Team Trigger Controller */
/*!QUAKED game_team_master (1 .5 0) (-8 -8 -8) (8 8 8) REMOVE
# OVERVIEW
Regulates triggers in team based modes.

# KEYS
- "targetname" : Name
- "master" : Name of the multisource or game_team_master regulating this entity.
- "target" : Name of the entity to trigger.
- "triggerstate" : Desired trigger state.
- "teamindex" : Which team to affect. -1 means none.

# SPAWNFLAGS
- REMOVE (1) : Will be removed once triggered.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
game_team_master:multisource
{
public:
	void game_team_master(void);

	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);
	virtual void Trigger(entity, triggermode_t);
	virtual int GetValue(entity);
	nonvirtual void SetTeamIndex(int);
	nonvirtual int GetTeamIndex(void);

private:
	int m_iTeamIndex;
	triggermode_t m_iTriggerState;
};

void
game_team_master::game_team_master(void)
{
	m_iTeamIndex = 0i;
	m_iTriggerState = TRIG_TOGGLE;
}

void
game_team_master::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_iTriggerState", m_iTriggerState);
	SaveInt(handle, "m_iTeamIndex", m_iTeamIndex);
}

void
game_team_master::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_iTriggerState":
		m_iTriggerState = ReadFloat(setValue);
		break;
	case "m_iTeamIndex":
		m_iTeamIndex = ReadInt(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
game_team_master::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "triggerstate":
		m_iTriggerState = ReadInt(setValue);
		break;
	case "teamindex":
		m_iTeamIndex = ReadInt(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
game_team_master::Trigger(entity entityActivator, triggermode_t state)
{
	if (GetMaster(entityActivator) == FALSE) {
		return;
	}

	if (m_iTeamIndex != -1i) {
		if (entityActivator.team != (float)m_iTeamIndex) {
			return;
		}
	}

	super::Trigger(entityActivator, state);
}

void
game_team_master::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "SetTeamIndex":
		SetTeamIndex(ReadInt(dataField));
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
		break;
	}
}

int
game_team_master::GetValue(entity queryingEntity)
{
	if (queryingEntity.team == (float)m_iTeamIndex)
		return TRUE;

	return FALSE;
}

void
game_team_master::SetTeamIndex(int newIndex)
{
	m_iTeamIndex = newIndex;
}

int
game_team_master::GetTeamIndex(void)
{
	return m_iTeamIndex;
}