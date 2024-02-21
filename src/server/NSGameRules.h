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

/*! @file NSGameRules.h
    @brief Gamerule top level class.

    There's a lot of methods you're allowed to override.
*/

/** This class represents active gamerules. */
class NSGameRules:NSIO
{
public:
	void NSGameRules(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void RestoreComplete(void);

	/** Overridable: Called when all map entities have initialized. */
	virtual void InitPostEnts(void);
	
	/* logic */
	/** Overridable: Called every server frame. */
	virtual void FrameStart(void);
	/** Overridable: Called when a client issues a console command. */
	virtual bool ConsoleCommand(NSClientPlayer,string);
	/** Overridable: Called when a client issues a client command. */
	virtual bool ClientCommand(NSClient,string);
	/** Overridable: Called when a client issues an impulse command. */
	virtual bool ImpulseCommand(NSClient, float);
	
	/* client */
	/** Overridable: Called when a NSClientPlayer joins the server. */
	virtual void PlayerConnect(NSClientPlayer);
	/** Overridable: Called when a NSClientPlayer leaves the server. */
	virtual void PlayerDisconnect(NSClientPlayer);
	/** Overridable: Called when a NSClientPlayer issues the `kill` console command. */
	virtual void PlayerKill(NSClientPlayer);
	/** Overridable: Called when a NSClientPlayer spawns, called sometime after joining. */
	virtual void PlayerSpawn(NSClientPlayer);
	/** Overridable: Called before running physics on the NSClientPlayer in question. */
	virtual void PlayerPreFrame(NSClientPlayer);
	/** Overridable: Called after running physics on the NSClientPlayer in question. */
	virtual void PlayerPostFrame(NSClientPlayer);
	/** Overridable: Called when a NSClientPlayer dies in the game. */
	virtual void PlayerDeath(NSClientPlayer);
	/** Overridable: Called when a NSClientPlayer feels pain. */
	virtual void PlayerPain(NSClientPlayer);
	/** Overridable: Called to check if a NSClientPlayer can attack. */
	virtual bool PlayerCanAttack(NSClientPlayer);

	/** Overridable: called when a NSClientPlayer requests a respawn.
	In a multiplayer game, it'll put you back into the game as a player.
	In a singleplayer game, it might load the most recent save.
	@return True/false depending on the respawn succeeded. */
	virtual bool PlayerRequestRespawn(NSClientPlayer);
	
	/* level transitions */
	/** Overridable: Called to set up new level parms for any NSClientPlayer. */
	virtual void LevelNewParms(void);
	/** Overridable: Called to store parms for a specific NSClientPlayer. */
	virtual void LevelChangeParms(NSClientPlayer);
	
	/* Entities/Item manipulation */
	/** Overridable: Returns how many items players can carry in a given slot. */
	virtual int MaxItemPerSlot(int);
	/** Overridable: Returns if NSMonster or NSTalkMonster entities can spawn. */
	virtual bool MonstersSpawn(void);
	/** Overridable: shim to handle application of direct damage. */
	virtual void DamageApply(entity,entity,float,int,damageType_t);
	/** Checks if an entity can be attacked from a given position. */
	virtual bool DamageCheckTrace(entity,vector);
	/** Overridable: shim to handle application of indirect radius damage. */
	virtual void DamageRadius(vector,entity,float,float,bool,int);
	
	/* end of a game */
	/** Called when intermission starts. Will send all current players to the intermission screen. */
	virtual void IntermissionStart(void);
	/** Called when the intermission system calls a new map. */
	virtual void IntermissionCycle(void);
	/** Called when intermission ends. */
	virtual void IntermissionEnd(void);
	/** Run to send a specific player to an intermission. Like when joining late. */
	virtual void IntermissionToPlayer(NSClientPlayer);
	/** Returns if the gamerules find themselves in an intermission. */
	virtual bool InIntermission(void);

	/** Returns if this gamerule considers itself teamplay oriented. */
	virtual bool IsTeamplay(void);
	/** Returns if the gamerule is a multiplayer game. */
	virtual bool IsMultiplayer(void);

	/* chat related methods */
	/** Called by Nuclide when the server has received a chat message
		that is to be distributed amongst all clients, regardless of team. */
	virtual void ChatMessageAll(NSClient, string);

	/** Called by Nuclide when the server has received a chat message
		that is to be distributed amongst all clients of the same team. */
	virtual void ChatMessageTeam(NSClient, string);

	/** Returns the title of the gamemode running. */
	virtual string Title(void);
	
	/* spectator */
	/*
	virtual void SpectatorConnect(NSClientPlayer);
	virtual void SpectatorDisconnect(NSClientPlayer);
	virtual void SpectatorThink(NSClientPlayer);
	*/
private:
	int m_iIntermission;
	float m_flIntermissionTime;
	float m_flIntermissionCycle;
	entity m_eIntermissionPoint;
};

/* our currently running mode */
NSGameRules g_grMode;

#define CGameRules NSGameRules
