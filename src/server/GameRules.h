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

/*! @file ncGameRules.h
    @brief Gamerule top level class.

    There's a lot of methods you're allowed to override.
*/

/** This class represents active gamerules. 
@ingroup baseclass
*/
class ncGameRules:ncIO
{
public:
	void ncGameRules(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void RestoreComplete(void);
	virtual void Input(entity, string, string);

	/** Overridable: Called when all map entities have initialized. */
	virtual void InitPostEnts(void);
	
	/* logic */
	/** Overridable: Called every server frame. */
	virtual void FrameStart(void);
	/** Overridable: Called when a client issues a console command. */
	virtual bool ConsoleCommand(ncPlayer,string);
	/** Overridable: Called when a client issues a client command. */
	virtual bool ClientCommand(ncClient,string);
	/** Overridable: Called when a client issues an impulse command. */
	virtual bool ImpulseCommand(ncClient, float);
	
	/* client */
	/** Overridable: Called when a ncPlayer joins the server. */
	virtual void PlayerConnect(ncPlayer);
	/** Overridable: Called when a ncPlayer leaves the server. */
	virtual void PlayerDisconnect(ncPlayer);
	/** Overridable: Called when a ncPlayer issues the `kill` console command. */
	virtual void PlayerKill(ncPlayer);
	/** Overridable: Called when a ncPlayer spawns, called sometime after joining. */
	virtual void PlayerSpawn(ncPlayer);
	/** Overridable: Called before running physics on the ncPlayer in question. */
	virtual void PlayerPreFrame(ncPlayer);
	/** Overridable: Called after running physics on the ncPlayer in question. */
	virtual void PlayerPostFrame(ncPlayer);
	/** Overridable: Called when a ncPlayer dies in the game. */
	virtual void PlayerDeath(ncPlayer, ncEntity, ncEntity, string);
	/** Overridable: Called when a ncPlayer feels pain. */
	virtual void PlayerPain(ncPlayer, ncActor, ncDict);
	/** Overridable: Called to check if a ncPlayer can attack. */
	virtual bool PlayerCanAttack(ncPlayer);
	/** Overridable:: Called when an NPC gets killed. */
	virtual void NPCDeath(ncActor, ncEntity, ncEntity);

	/** Overridable: called when a ncPlayer requests a respawn.
	In a multiplayer game, it'll put you back into the game as a player.
	In a singleplayer game, it might load the most recent save.
	@return True/false depending on the respawn succeeded. */
	virtual bool PlayerRequestRespawn(ncPlayer);

	/** Overridable: called when a ncPlayer requests joining a specific team.
	@return True/false depending on the team change success. */
	virtual bool PlayerRequestTeam(ncPlayer, int team);
	
	/* level transitions */
	/** Overridable: Called to set up new level parms for any ncPlayer. */
	virtual void LevelNewParms(void);
	/** Overridable: Called to store parms for a specific ncPlayer. */
	virtual void LevelChangeParms(ncPlayer);
	
	/* Entities/Item manipulation */
	/** Overridable: Returns how many items players can carry in a given slot. */
	virtual int MaxItemPerSlot(int);
	/** Overridable: Returns if ncMonster or ncTalkMonster entities can spawn. */
	virtual bool MonstersSpawn(void);
	
	/* end of a game */
	/** Called when intermission starts. Will send all current players to the intermission screen. */
	virtual void IntermissionStart(void);
	/** Called when the intermission system calls a new map. */
	virtual void IntermissionCycle(void);
	/** Called when intermission ends. */
	virtual void IntermissionEnd(void);
	/** Run to send a specific player to an intermission. Like when joining late. */
	virtual void IntermissionToPlayer(ncPlayer);
	/** Returns if the gamerules find themselves in an intermission. */
	virtual bool InIntermission(void);

	/** Returns if this gamerule considers itself teamplay oriented. */
	virtual bool IsTeamplay(void);
	/** Returns if the gamerule is a multiplayer game. */
	virtual bool IsMultiplayer(void);


	/* chat related methods */
	/** Called by Nuclide when the server has received a chat message
		that is to be distributed amongst all clients, regardless of team. */
	virtual void ChatMessageAll(ncClient, string);

	/** Called by Nuclide when the server has received a chat message
		that is to be distributed amongst all clients of the same team. */
	virtual void ChatMessageTeam(ncClient, string);

	/** Returns the title of the gamemode running. */
	virtual string Title(void);

	nonvirtual ncGameRules CreateRules(void);
	
	/* spectator */
	/*
	virtual void SpectatorConnect(ncPlayer);
	virtual void SpectatorDisconnect(ncPlayer);
	virtual void SpectatorThink(ncPlayer);
	*/
private:
	int m_iIntermission;
	float m_flIntermissionTime;
	float m_flIntermissionCycle;
	entity m_eIntermissionPoint;
};

/* our currently running mode */
ncGameRules g_grMode;
var float g_ruleCProgs;
var string g_ruleCName;

#define CGameRules ncGameRules
#define RULEMAP(x, y, z) x.y = externvalue(g_ruleCProgs, z); if (!x.y) { x.y = ncGameRules::y; }
