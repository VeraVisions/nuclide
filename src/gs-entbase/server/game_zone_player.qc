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

/*! \brief Server-Entity: game_counter Zone Controller */
/*!QUAKED game_zone_player (1 .5 0) ?
# OVERVIEW
When triggered, will cause players inside/outside this volume to trigger entities. It also has the ability to set game_counter entities to the amount of players inside/outside of the volume.

# KEYS
- "targetname" : Name
- "intarget" : Target that the players inside this volume will trigger.
- "outtarget" : Target that the players outside this volume will trigger.
- "incount" : Specifies the game_counter which will be set to the 'in' player count.
- "outcount" : Specifies the game_counter which will be set to the 'out' player count.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
game_zone_player:ncBrushTrigger
{
public:
	void game_zone_player(void);

	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void SpawnKey(string, string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);

private:
	string m_strInTarget;
	string m_strOutTarget;
	string m_strInCount;
	string m_strOutCount;
};

void
game_zone_player::game_zone_player(void)
{
	m_strInTarget = __NULL__;
	m_strOutTarget = __NULL__;
	m_strInCount = __NULL__;
	m_strOutCount = __NULL__;
}

void
game_zone_player::Save(float handle)
{
	super::Save(handle);

	SaveString(handle, "m_strInTarget", m_strInTarget);
	SaveString(handle, "m_strOutTarget", m_strOutTarget);
	SaveString(handle, "m_strInCount", m_strInCount);
	SaveString(handle, "m_strOutCount", m_strOutCount);
}

void
game_zone_player::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_strInTarget":
		m_strInTarget = ReadString(setValue);
		break;
	case "m_strOutTarget":
		m_strOutTarget = ReadString(setValue);
		break;
	case "m_strInCount":
		m_strInCount = ReadString(setValue);
		break;
	case "m_strOutCount":
		m_strOutCount = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
game_zone_player::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "intarget":
		m_strInTarget = ReadString(setValue);
		break;
	case "incount":
		m_strInCount = ReadString(setValue);
		break;
	case "outtarget":
		m_strOutTarget = ReadString(setValue);
		break;
	case "outcount":
		m_strOutCount = ReadString(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
game_zone_player::Respawn(void)
{
	InitBrushTrigger();
}

void
game_zone_player::Trigger(entity entityActivator, triggermode_t state)
{
	int playersIn = 0i;
	int playersOut = 0i;
	ncEntity inTarget = (ncEntity)find(world, ::targetname, m_strInTarget);
	ncEntity outTarget = (ncEntity)find(world, ::targetname, m_strOutTarget);

	for (other = world; (other = next.Player(other));) {
		if (IntersectsWith(other)) {
			if (inTarget) {
				inTarget.Trigger(other, state);
			}
			playersIn++;
		} else {
			if (outTarget) {
				outTarget.Trigger(other, state);
			}
			playersOut++;
		}
	}

	if (m_strInCount) {
		game_counter inCounter = (game_counter)find(world, ::targetname, m_strInCount);

		if (inCounter) {
			inCounter.SetCount(playersIn);
			inCounter.Trigger(entityActivator, TRIG_TOGGLE);
		}
	}

	if (m_strOutCount) {
		game_counter outCounter = (game_counter)find(world, ::targetname, m_strOutCount);

		if (outCounter) {
			outCounter.SetCount(playersIn);
			outCounter.Trigger(entityActivator, TRIG_TOGGLE);
		}
	}
}
