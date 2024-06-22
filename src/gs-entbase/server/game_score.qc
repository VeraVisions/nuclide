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

/*! \brief Server-Entity: Player Score Controller */
/*!QUAKED game_score (1 .5 0) (-8 -8 -8) (8 8 8) NEGATIVE TEAMSCORE
# OVERVIEW
Awards points to the activator when triggered.

# KEYS
- "targetname" : Name
- "master" : Name of the multisource or game_team_master regulating this entity.
- "points" : Amount of points to add.

# SPAWNFLAGS
- NEGATIVE (1) : Allow negative values.
- TEAMSCORE (2) : Will affect whole team their score.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup server
@ingroup pointentity
*/
class
game_score:NSPointTrigger
{
public:
	void game_score(void);

	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void SpawnKey(string, string);
	virtual void Trigger(entity, triggermode_t);

private:
	int m_iPoints;
};

void
game_score::game_score(void)
{
	m_iPoints = 0i;
}

void
game_score::Save(float handle)
{
	SaveInt(handle, "m_iPoints", m_iPoints);
}

void
game_score::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_iPoints":
		m_iPoints = ReadInt(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
game_score::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "points":
		m_iPoints = ReadInt(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
game_score::Trigger(entity entityActivator, triggermode_t state)
{
	int toAdd = m_iPoints;

	if (GetMaster(entityActivator) == FALSE) {
		return;
	}

	/* don't allow negative values. */
	if (HasSpawnFlags(1) == false) {
		toAdd = m_iPoints < 0i ? 0i : m_iPoints;
	}

	if (HasSpawnFlags(2) == false) {
		entityActivator.frags += (float)toAdd;
	} else {
		int targetTeam = (int)entityActivator.team;
		string targetKey = sprintf("teamscore_%i", targetTeam);
		int currentPoints = (int)serverkeyfloat(targetKey);
		string targetValue = sprintf("%i", currentPoints + toAdd);
		forceinfokey(world, targetKey, targetValue);
	}
}