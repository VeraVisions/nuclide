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

/*!QUAKED game_team_set (1 .5 0) (-8 -8 -8) (8 8 8) REMOVE
# OVERVIEW
When triggered, will set the target game_team_master's team-index value to the team of the activating player.

# KEYS
- "targetname" : Name
- "master" : Name of the multisource or game_team_master regulating this entity.
- "target" : The name of the game_team_master we'll be affecting.

# SPAWNFLAGS
- REMOVE (1) : Will be removed once triggered.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
game_team_set:NSPointTrigger
{
public:
	void game_team_set(void);

	virtual void Trigger(entity, triggermode_t);
};

void
game_team_set::game_team_set(void)
{
}

void
game_team_set::Trigger(entity activatorEntity, triggermode_t state)
{
	game_team_master toChange = __NULL__;

	if (GetMaster(activatorEntity) == FALSE) {
		return;
	}

	toChange = (game_team_master)GetTargetEntity();

	if (!toChange) {
		NSEntWarning("Unable to find game_team_master named %S", GetTriggerTarget());
		return;
	}

	toChange.SetTeamIndex((int)activatorEntity.team);

	if (HasSpawnFlags(1)) {
		Destroy();
	}
}