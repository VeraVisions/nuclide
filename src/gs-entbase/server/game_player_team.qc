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

/*! \brief Server-Entity: Player Team Controller */
/*!QUAKED game_player_team (1 .5 0) (-8 -8 -8) (8 8 8) REMOVE KILL GIB
# OVERVIEW
Allows the player to change teams.

# KEYS
- "targetname" : Name
- "master" : Name of the multisource or game_team_master regulating this entity.
- "target" : Name of the game_team_master that specifies the new team.

# SPAWNFLAGS
- REMOVE (1) : Will be removed once triggered.
- KILL (2) : Kills the player when activated.
- GIB (4) : Gibs the player when activated.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
game_player_team:ncPointTrigger
{
public:
	void game_player_team(void);

	virtual void Trigger(entity, triggermode_t);
};

void
game_player_team::game_player_team(void)
{
}

void
game_player_team::Trigger(entity entityActivator, triggermode_t state)
{
	ncPlayer targetPlayer = __NULL__;
	game_team_master toRead = __NULL__;
	ncDict damageDecl;

	if (GetMaster(entityActivator) == FALSE) {
		return;
	}

	toRead = (game_team_master)GetTargetEntity();

	if (!toRead) {
		EntWarning("Unable to find game_team_master named %S", GetTriggerTarget());
		return;
	}

	targetPlayer = (ncPlayer)entityActivator;
	targetPlayer.SetTeam((float)toRead.GetTeamIndex());

	if (HasSpawnFlags(4) == true) {
		damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", ftos(targetPlayer.health + 100));
		damageDecl.AddKey("skip_armor", "1");
		targetPlayer.Damage(this, targetPlayer, damageDecl, 1.0f, GetOrigin(), g_vec_null, targetPlayer.origin);
		remove(damageDecl);
	} else if (HasSpawnFlags(2) == true) {
		damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", ftos(targetPlayer.health));
		damageDecl.AddKey("skip_armor", "1");
		targetPlayer.Damage(this, targetPlayer, damageDecl, 1.0f, GetOrigin(), g_vec_null, targetPlayer.origin);
		remove(damageDecl);
	}

	if (HasSpawnFlags(1)) {
		Destroy();
	}
}
