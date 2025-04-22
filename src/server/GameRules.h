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

/*! @file ncRuleDelegate.h
    @brief Gamerule top level class.

    There's a lot of methods you're allowed to override.
*/

/** This class represents active gamerules. 

The ncRuleDelegate class is for any set of active gamerules.
It can be accessed in QuakeC via the global `g_grMode` from the server-side.

# Choosing A Ruleset

Upon server init, the game will query the *weak* function Game_DefaultRules(), which can be re-implemented with the same name by the game developer in their server game. The return value should either be `__NULL__` or the name of a [progs](@ref progs) within `<gamedir>/progs/`. 

By default, the game will load either `<gamedir>/progs/singleplayer.dat` when it's only a singleplayer client or the [console variable](@ref cvar) for `coop` is `1`, or `<gamedir>/progs/deathmatch.dat` in any other case.
If you happen to set the server-side console variable `g_gametype` to a custom string, it will attempt to load
a named progs that can be found under `<gamedir>/progs/`.

Here's the current implementation of said function:

```
__weak string
Game_DefaultRules(void)
{
	string gameType = cvars.GetString("g_gametype");

	if (!STRING_SET(gameType)) {
		bool isCoop = cvars.GetBool("coop");
		bool isSingle = (cvars.GetInteger("sv_playerslots") <= 1) ? (true) : (false);
		gameType = (isSingle || isCoop) == (true) ? "singleplayer" : "deathmatch";
	}

	return (gameType);
}
```

If you only plan on having one mode, ever, and disallow custom game modes - you can define it like this anywhere:

```
string
Game_DefaultRules(void)
{
	return ("deathmatch");
}
```

The progs in question is then able to override any methods of the ncGameRule class.

# Implementing RuleC Progs

When we decide to load a rule from an external progs, that progs can be implemented with
as many binds as you like. The only requirement is you include the header found under `src/server/api.h`.

## Example RuleC

Here's a simple deathmatch rule, which will increment the score on the score-board for every
player frag:

```
#pragma PROGS_DAT  "../../progs/deathmatch.dat"

#include "../../../src/server/api.h"

void
CodeCallback_Precaches(void)
{
	precache.Entity("player");	// Precache everything associated with the player decl
}

void
CodeCallback_StartGameType(void)
{
	motd.LoadDefault();			// Multiplayer game, so load the message of the day
}

void
CodeCallback_PlayerSpawn(entity playerTarget)
{
	ents.ChangeToClass(playerTarget, "player");	// Turn the client into a fresh player
	game.TeleportToSpawn(playerTarget);			// Teleport the player to its destined start position
}

bool
CodeCallback_PlayerRequestRespawn(entity playerTarget)
{
	CodeCallback_PlayerSpawn(playerTarget);		// When we request a respawn, let it happen
	return (true);
}

void
CodeCallback_PlayerKilled(entity playerTarget, entity inflictor, entity attacker, string weapon)
{
	playerTarget.deaths++;		// increment death counter

	if (is.Player(attacker)) {
		if (playerTarget == attacker) {
			attacker.frags--;	// scoreboard penalty for the flub
		} else {
			attacker.frags++;	// scoreboard reward
		}
	}
}
```


## Class To Progs Callback Mappings

Left = class method, right = name of the callback function for you to implement in progs.

ncRuleDelegate::Title = CodeCallback_Title  
ncRuleDelegate::ClientCommand = CodeCallback_ClientCommand  
ncRuleDelegate::ConsoleCommand = CodeCallback_ConsoleCommand  
ncRuleDelegate::FrameStart = CodeCallback_FrameStart  
ncRuleDelegate::ImpulseCommand = CodeCallback_ImpulseCommand  
ncRuleDelegate::InitPostEnts = CodeCallback_StartGameType  
ncRuleDelegate::Input = CodeCallback_Input  
ncRuleDelegate::NPCDeath = CodeCallback_NPCKilled  
ncRuleDelegate::PlayerCanAttack = CodeCallback_PlayerCanAttack  
ncRuleDelegate::PlayerConnect = CodeCallback_PlayerConnect  
ncRuleDelegate::PlayerDeath = CodeCallback_PlayerKilled  
ncRuleDelegate::PlayerDisconnect = CodeCallback_PlayerDisconnect  
ncRuleDelegate::PlayerPain = CodeCallback_PlayerDamage  
ncRuleDelegate::PlayerPreFrame = CodeCallback_PlayerPreFrame  
ncRuleDelegate::PlayerRequestRespawn = CodeCallback_PlayerRequestRespawn  
ncRuleDelegate::PlayerRequestTeam = CodeCallback_CallRequestTeam  
ncRuleDelegate::PlayerSpawn = CodeCallback_PlayerSpawn  

The underlying return values and parameters are inherited from its class counter-part.


@ingroup baseclass
*/
class ncRuleDelegate:ncIO
{
public:
	void ncRuleDelegate(void);

	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void RestoreComplete(void);
	virtual void Input(entity, string, string);

	/** Overridable: Called when all map entities have initialized. */
	virtual void InitPostEnts(void);
	
	/* logic */
	/** Overridable: Called from initents(). */
	virtual void Precache(void);

	/** Overridable: Called every server frame. */
	virtual void FrameStart(void);
	/** Overridable: Called when the server issues a console command. */
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

	nonvirtual void LinkProgs(void);
	nonvirtual ncRuleDelegate ActiveInstance(void);
	
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
ncRuleDelegate g_grMode;
var float g_ruleCProgs;
var string g_ruleCName;

#define CGameRules ncRuleDelegate
#define RULEMAP(x, y, z) x.y = externvalue(g_ruleCProgs, z); if (!x.y) { x.y = ncRuleDelegate::y; }

void RuleC_Init(void);