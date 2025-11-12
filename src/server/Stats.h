/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/** @defgroup logging Logging
    @brief Server-side logging functions.
    @ingroup server

Various helper functions, mainly used internally by Nuclide, to aid in logging common game activity.

The logs are usually processed for a display of stats of a player of a server. That is generally up to the implementation.

These logs can be imported into software akin to [UTStatsDB](https://utstatsdb.com/) or [UltraStats](https://code.idtech.space/ultrastats/ultrastats).

Our implementation exports roughly compatible logs with Q2OSP, UT99. There's an experimental Q3A log exporter also.

@{

*/

var bool autocvar_logging_enabled = false;

/* ncStats Logging

A detailed record of a match or any game session.

*/
class
ncStats
{
public:
	nonvirtual void Init(void);
	nonvirtual void Shutdown(void);
	
	nonvirtual string OutputFilename(void);
	
	nonvirtual void Game(string keyName, string setValue);
	nonvirtual void Player(string keyName, string setValue);
	nonvirtual void Map(string keyName, string setValue);
	nonvirtual void JoinTeam(int teamID, ncPlayer leavingPlayer);
	nonvirtual void LeaveTeam(int teamID, ncPlayer leavingPlayer);

	/* player activities */
	nonvirtual void Connect(ncClient connectingClient);
	/** Player has entered the game. */
	nonvirtual void Enter(ncPlayer enteringPlayer);
	/** Player has left the game. */
	nonvirtual void Leave(ncPlayer leavingPlayer);
	/** Player has disconnected from the server. */
	nonvirtual void Disconnect(ncPlayer disconnectinggPlayer);
	/** Player has respawned */
	nonvirtual void Respawn(ncPlayer respawningPlayer);
	/** Player has changed their name. */
	nonvirtual void NameChange(ncPlayer changedPlayer, string newName);
	/** Player has been fragged. Counts number of 'kills' to a valid enemy. */
	nonvirtual void Kill(ncPlayer killedPlayer, ncEntity inflicingEntity, ncEntity attackingEntity, int attackerScoreChange, string attackerWeapon, int killedScoreChange, string deadWeapon);

	/** Log: Item was picked up by a player */
	nonvirtual void PickupItem(ncItem takenItem, ncPlayer inflictingPlayer);
	/** Log: Item was used by a player. */
	nonvirtual void UseItem(ncItem useditem, ncPlayer inflictingPlayer);
	/** Log: Item was dropped by the specified player */
	nonvirtual void DropItem(ncItem droppedItem, ncPlayer inflictingPlayer);
	/** Log: Item has expired, its time of use has run out. */
	nonvirtual void ExpireItem(ncItem expiredItem, ncPlayer inflictingPlayer);

	/* game state */
	/** Log: The beginning of gameplay. */
	nonvirtual void StartGame(void);
	/** Log: The end of a game. */
	nonvirtual void EndGame(string reasonString);

private:
	nonvirtual void Info(string, string);
	nonvirtual string LocalTime(void);
	nonvirtual string NetGamesTime(void);
};

/** @} */ // end of logging
