/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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

#define bool float
#define true 1
#define false 0

/** @defgroup sharedAPI API: Shared
    @brief Shared Game-Logic APIs
    @ingroup multiprogs
    @ingroup shared

APIs used by both client and server progs.

You can use these functions in any [progs or multi-progs](@ref progs).

Certain functions may do nothing on the client-side.
If that is the case, a note is made in function documentation.

@{
*/

/** Ammo library */
typedef struct
{
	/** Find out the internal name of an ammo ID. These match the names provided in the ammo decl.
	@param ammoID is the unique identifier for an ammo type.
	@return string containing the name of the specified ammo type. Returns `__NULL__` when invalid. */
	string NameForNum(int ammoID);
	/** Get the internal ID of an ammo type. 
	@param ammoName is the name of the ammo type, such as `"ammo_shells"`.
	@return the ammo id of a given name of ammo. Return `-1i` when invalid. */
	int NumForName(string ammoName);
	/** Find out the maximum ammo of a named ammo type. 
	@param ammoName is the name of the ammo type, such as `"ammo_bullets"`.
	@return the max ammo given name of ammo. Returns `0i` when invalid. */
	int MaxForName(string ammoName);
	/** Find out the maximum ammo of a ammo type given the ID. 
	@param ammoID is the unique identifier for an ammo type.
	@return integer value containing the max ammo count. Returns `0i` when invalid. */
	int MaxForNum(int ammoID);
} ammoAPI_t;

ammoAPI_t ammo; /**< Access ammoAPI_t functions using this variable. */


/** CVar library.

Depending on if you're on the **client** or **server** side, it will only ever affect its respective side. 

You can not change cvars of other players when called on the server.

Likewise you are unable to alter server-side cvars from a client. */
typedef struct
{
	/** Returns the string value of a console variable.

	@param cvarName specifies the console variable key to query.
	@return The value in string format. */
	string GetString(string cvarName);
	/** Returns the integer value of a console variable.

	@param cvarName specifies the console variable key to query.
	@return The value in integer format. */
	int GetInteger(string cvarName);
	/** Returns the floating-point value of a console variable.

	@param cvarName specifies the console variable key to query.
	@return The value in floating-point format. */
	float GetFloat(string cvarName);
	/** Returns the boolean value of a console variable.

	@param cvarName specifies the console variable key to query.
	@return The value in boolean form. */
	bool GetBool(string cvarName);
	/** Returns the vector value of a console variable.

	@param cvarName specifies the console variable key to query.
	@return The value in vector form. */
	vector GetVector(string cvarName);
	/** Sets the specified console variable to a set string value.

	@param cvarName specifies the console variable to set.
	@param setValue specifies the value of said key. */
	void SetString(string cvarName, string setValue);
	/** Sets the specified console variable to a set integer value.

	@param cvarName specifies the console variable to set.
	@param setValue specifies the value of said key. */
	void SetInteger(string cvarName, int setValue);
	/** Sets the specified console variable to a set boolean value.

	@param cvarName specifies the console variable to set.
	@param setValue specifies the value of said key. */
	void SetBool(string cvarName, bool setValue);
	/** Sets the specified console variable to a set floating-point value.

	@param cvarName specifies the console variable to set.
	@param setValue specifies the value of said key. */
	void SetFloat(string cvarName, float setValue);
	/** Sets the specified console variable to a set vector.

	@param cvarName specifies the console variable to set.
	@param setValue specifies the value of said key. */
	void SetVector(string cvarName, vector setValue);
} cvarAPI_t;

cvarAPI_t cvars; /**< Access cvarAPI_t functions using this variable. */

/** ServerInfo library */
typedef struct
{
	/** Returns the string value of a server info-key.

	@param serverKey specifies the server info-key to query.
	@return The value in string format. */
	string GetString(string serverKey);
	/** Returns the integer value of a server info-key.

	@param serverKey specifies the server info-key to query.
	@return The value in integer format. */
	int GetInteger(string serverKey);
	/** Returns the floating-point value of a server info-key.

	@param serverKey specifies the server info-key to query.
	@return The value in floating-point format. */
	float GetFloat(string serverKey);
	/** Returns the boolean value of a server info-key.

	@param serverKey specifies the server info-key to query.
	@return The value in boolean form. */
	bool GetBool(string serverKey);
	/** Returns the vector value of a server info-key.

	@param serverKey specifies the server info-key to query.
	@return The value in vector form. */
	vector GetVector(string serverKey);
	/** Server only. Sets the specified server info-key to a set string value.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetString(string serverKey, string setValue);
	/** Server only. Sets the specified server info-key to a set integer value.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetInteger(string serverKey, int setValue);
	/** Server only. Sets the specified server info-key to a set boolean value.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetBool(string serverKey, bool setValue);
	/** Server only. Sets the specified server info-key to a set floating-point value.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetFloat(string serverKey, float setValue);
	/** Server only. Sets the specified server info-key to a set vector.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetVector(string serverKey, vector setValue);
} serverinfoAPI_t;

serverinfoAPI_t serverinfo; /**< Access serverinfoAPI_t functions using this variable. */

/** UserInfo library */
typedef struct
{
	/** Returns the string value of a user info-key.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to query.
	@return The value in string format. */
	string GetString(entity clientEnt, string userKey);
	/** Returns the integer value of a user info-key.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to query.
	@return The value in integer format. */
	int GetInteger(entity clientEnt, string userKey);
	/** Returns the floating-point value of a user info-key.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to query.
	@return The value in floating-point format. */
	float GetFloat(entity clientEnt, string userKey);
	/** Returns the boolean value of a user info-key.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to query.
	@return The value in boolean form. */
	bool GetBool(entity clientEnt, string userKey);
	/** Returns the vector value of a user info-key.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to query.
	@return The value in vector form. */
	vector GetVector(entity clientEnt, string userKey);
	/** Server only. Sets the specified user info-key to a set string value.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetString(entity clientEnt, string userKey, string setValue);
	/** Server only. Sets the specified user info-key to a set integer value.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetInteger(entity clientEnt, string userKey, int setValue);
	/** Sets the specified user info-key to a set boolean value.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetBool(entity clientEnt, string userKey, bool setValue);
	/** Server only. Sets the specified user info-key to a set floating-point value.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetFloat(entity clientEnt, string userKey, float setValue);
	/** Server only. Sets the specified user info-key to a set vector.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetVector(entity clientEnt, string userKey, vector setValue);
} userinfoAPI_t;

userinfoAPI_t userinfo; /**< Access userinfoAPI_t functions using this variable. */

/** Weapon library */
typedef struct
{
	/** Get the "attack" type of the weapon.
	@param weaponDef the name of the entityDef that defines the weapon.
	@return Attack type of the weapon. */
	string Type(string weaponDef);
	/** The amount of ammo the specified weapon is meant to start with, when first given to the player. This can be distributed to both clip and reserve ammo types.
	@return integer value containing the start ammo of the weapon.
	@param weaponDef the name of the entityDef that defines the weapon. */
	int StartAmmo(string weaponDef);
	/** Find the amount of ammo a weapon can hold in total when it comes to reserve ammo. So this is really returning the max ammo of a given ammo type.
	@return integer value containing the max reserve ammo that weapon can have.
	@param weaponDef the name of the entityDef that defines the weapon. */
	int MaxAmmo(string weaponDef);
	/** Find out whether the weapon is semi-automatic. If yes, you can not hold down fire, you have to press the fire key for each individual shot.
	@return a value that when `true` means the weapon is semi-automatic.
	@param weaponDef the name of the entityDef that defines the weapon. */
	bool IsSemiAuto(string weaponDef);

	/** Find out how this weapon is stored.
	@return a string description of how it's stored. Usually "item", unless it's temporary.
	@param weaponDef the name of the entityDef that defines the weapon. */
	string InventoryType(string weaponDef);
	/** Find out the minimum delay between shots of a weapon, in seconds.
	@return floating point value containing the delay in seconds.
	@param weaponDef the name of the entityDef that defines the weapon. */
	float FireTime(string weaponDef);
	/** Find out what the clip size of a weapon is.
	@return integer value containing the size of the clip.
	@param weaponDef the name of the entityDef that defines the weapon. */
	int ClipSize(string weaponDef);
	/** Find the 'class' of a weapon. Not spawnclass, but rather type.
	@return string containing the type of weapon.  Such as `"melee"`. Otherwise, `"unknown"`.
	@param weaponDef the name of the entityDef that defines the weapon.*/
	string Class(string weaponDef);
	/** Find out if a weapon takes its ammo only through its clip.
	@return true/false whether the weapon takes its ammo only through its clip.
	@param weaponDef the name of the entityDef that defines the weapon.*/
	bool IsClipOnly(string weaponDef);
	/** Find out whether a weapon has anything to do with a timed detonation.
	@return true/false whether or not the weapon creates a timed, fused detonating charge of sorts.
	@param weaponDef the name of the entityDef that defines the weapon.*/
	bool IsDetonationTimed(string weaponDef);
} weaponInfo_t;

weaponInfo_t weaponInfo; /**< Access weaponInfo_t functions using this variable. */

/** Team library */
typedef struct
{
	/** Find out what the best choice of team it is to join.
	@return the team ID that needs an additional team member the most. */
	int BestAutoJoinTeam(void);
	/** Find out how many teams are registered in the current game.
	@return the amount of teams set up in the game. */
	int TeamCount(void);
	/** Find out how many teams are open to new players.
	@return the amount of teams open to join. */
	int OpenTeamCount(void);
	/** Find out which color represents a team.
	@return a normalized RGB color of a team.
	@param teamID specifies the team to query. */
	vector Color(int teamID);
	/** Find the name of a team, that you can use in prints and written text.
	@return the name of a team. 
	@param teamID specifies the team to query. */
	string Name(int teamID);
	/** Find the current score of a team. Usually tested against the [cvar](@ref cvars) `scorelimit`.
	@return the score of a team. 
	@param teamID specifies the team to query. */
	int Score(int teamID);
	/** Find the entity class name representing individual team spawn points.
	@return the default spawn point class of a team. 
	@param teamID specifies the team to query. */
	string SpawnPoint(int teamID);
	/** Find out how many players are in an active team.
	@return the number of players that are part of a team. 
	@param teamID specifies the team to query. */
	int NumPlayers(int teamID);
	/** Find out how many team players are active/alive in a match.
	@return the number of 'surviving' players that are part of a team. 
	@param teamID specifies the team to query. */
	int NumAlivePlayers(int teamID);
	/** Find out how many team players are currently inactive/dead in a match.
	@return the number of 'dead' players that are part of a team.
	@param teamID specifies the team to query. */
	int NumDeadPlayers(int teamID);
	/** Find out how many times all the players in a given team have 'died' in the game.
	@return the number of deaths in a given team.
	@param teamID specifies the team to query. */
	int TotalDeaths(int teamID);
	/** Find out how many times all the players in a given team have scored 'frags'.
	A frag can be a 'kill' or just an alternative way of saying scorepoints, specific to players.
	@return the number of frags in a given team.
	@param teamID specifies the team to query. */
	int TotalFrags(int teamID);
	/** Find out if a given team exists, or valid. Invalid teams should not be joined, and aren't offered on the client.
	@return whether a team ID is valid, set up. 
	@param teamID specifies the team to query. */
	bool Valid(int teamID);

	/** Increases the score of a specified team. 
	@param teamID specifies the team to query. 
	@param addedScore is the amount of points to add to the existing score. */
	void AddScore(int teamID, int addedScore);
	/** Overridess the score of a specified team. 
	@param teamID specifies the team to query.
	@param scoreValue is the value which the score should be set to. */
	void SetScore(int teamID, int scoreValue);
	/** Find a random player belonging to a given team.
	@return a single random entity reference to a player of a given team. Will return `__NULL__` if one does not exist.
	@param teamID specifies the team to query. */
	entity RandomPlayer(int teamID);


	/** Sets up a team for the current session. Will flush the team specific scores.

	@param teamID specifies which team slot to occupy.
	@param teamTitle specifies the title of the team.
	@param teamColor specifies the color of the team (e.g. [0, 255, 0] for green).
	@param openTeam specifies whether players can join the team manually. */
	void SetUp(int teamID, string teamTitle, vector teamColor, bool openTeam);


	/** Sets up a team class for the current session. Making them available to choose
	in the team selection menu. You can have different classes per teams also.

	@param teamID specifies which team slot to occupy.
	@param classType specifies the name of the player class. Used as an identifer in rules and menus.*/
	void AddClass(int teamID, string classType);


	/** Find out how many classes are registered within a team.
	@return the maximum number of classes this team can select.
	@param teamID specifies which team slot to query for class types. */
	int TotalClasses(int teamID);

	/** Find out the name of a team class given an index.
	@return the class type of a given team + index.
	@param teamID specifies which team slot to query for class types.
	@param classIndex specifies the index of the class to query. Use teams.TotalClasses() for the range. */
	string ClassForIndex(int teamID, int classIndex);

	/** Sets up a team spawn point for the current session.
	Using this function you can override the default team spawn, such as info_player_deathmatch
	type entities - and reroute spawns for a specific team to a different class.

	@param teamID specifies which team slot to occupy.
	@param spawnPointEntityClassname specifies the classname of this team's spawn point. */
	void SetSpawnPoint(int teamID, string spawnPointEntityClassname);
} teamAPI_t;

teamAPI_t teams; /**< Access teamAPI_t functions using this variable. */

/** EntityDef library */
typedef struct
{
	/** Returns the string value of a EntityDef key.

	@param defName specifies the EntityDef name in question
	@param keyName specifies the EntityDef key to query.
	@return The value in string format. */
	string GetString(string defName, string keyName);
	/** Returns the integer value of a EntityDef key.

	@param defName specifies the EntityDef name in question
	@param keyName specifies the EntityDef key to query.
	@return The value in integer format. */
	int GetInteger(string defName, string keyName);
	/** Returns the floating-point value of a EntityDef key.

	@param defName specifies the EntityDef name in question
	@param keyName specifies the EntityDef key to query.
	@return The value in floating-point format. */
	float GetFloat(string defName, string keyName);
	/** Returns the boolean value of a EntityDef key.

	@param defName specifies the EntityDef name in question
	@param keyName specifies the EntityDef key to query.
	@return The value in boolean form. */
	bool GetBool(string defName, string keyName);
	/** Returns the vector value of a EntityDef key.

	@param defName specifies the EntityDef name in question
	@param keyName specifies the EntityDef key to query.
	@return The value in vector form. */
	vector GetVector(string defName, string keyName);
} entityDefAPI_t;
entityDefAPI_t entityDef; /**< Access entityDefAPI_t functions using this variable. */

/** Precaching library */
typedef struct
{
	/** Precaches a given model file and additional helper files.

	`precache.Model("models/weapons/v_pistol.vvm");`

	@param pathToModel to precache
	@return modelindex value. */
	float Model(string pathToModel);

	/** Precaches a given sound def or sample.

	`precache.Sound("Foo.Bar");`
	`precache.Sound("foo/bar.wav");`

	@param soundDef to precache
	@return sound def id. */
	float Sound(string soundDef);

	/** Precaches a given particle effect.

	The following loads `r_part impactSpark` from `particles/weapon_laser.cfg`.

	`precache.Particle("weapon_laser.impactSpark");

	@param particleEffect to precache
	@return particle effect num. */
	float Particle(string particleEffect);

	/** Precaches a given entity class.
	Ensuring models, sounds and other assets referenced
	within are loaded ahead of time.

	@param className to precache
	@return Success. */
	bool Entity(string className);

	/** Precaches a given sprite frame to a material. An image from a .spr type sprite file.

	@param spritePath is the path to a sprite, e.g. "sprites/rain.spr"
	@param frameNum specifies the framegroup/sequence of which we pick from
	@param timeIntoFrame specifies the time into the sequence we'll pretend to be at
	@return name of a material containing the desired sprite frame */
	string SpriteFrame(string spritePath, float frameNum, float timeIntoFrame);
} precacheAPI_t;
precacheAPI_t precache; /**< Access precacheAPI_t functions using this variable. */

/** Sound library */
typedef struct
{
	void Play(string soundDef, float level = 75, float pitch = 100, float volume = 100, float channel = CHAN_AUTO);
} soundAPI_t;
soundAPI_t soundKit; /**< Access soundAPI_t functions using this variable. */

typedef struct
{
	/** Returns true/false depending on if the entity is an AI character.

	@param entityToCheck specifies the entity to check.*/
	bool AI(entity entityToCheck);
	/** Returns true/false depending on if the entity is alive.

	@param entityToCheck specifies the entity to check.*/
	bool Alive(entity entityToCheck);
	/** Returns true/false depending on if the entity is in "god" mode.

	@param entityToCheck specifies the entity to check.*/
	bool GodMode(entity entityToCheck);
	/** Returns true/false depending on if the entity is a client.

	@param entityToCheck specifies the entity to check.*/
	bool Client(entity entityToCheck);
	/** Returns true/false depending on if the entity is a player.

	@param entityToCheck specifies the entity to check.*/
	bool Player(entity entityToCheck);
	/** Returns true/false depending on if the entity is either a player, or AI character.

	@param entityToCheck specifies the entity to check.*/
	bool Sentient(entity entityToCheck);
	/** Returns true/false depending on if the entity is a bot.

	@param entityToCheck specifies the entity to check.*/
	bool Bot(entity entityToCheck);
} isAPI_t;
isAPI_t is; /**< Access nextAPI_t functions using this variable. */

typedef struct
{
	/** Returns the next entity of type 'Item' in the game.

	@param lastItem The previous item, can be `world` or `__NULL__` or `0` to retrieve the first item.
	@return The next item in the entity pool. Will be `world` or `__NULL__` if none are left. */
	entity Item(entity lastItem);


	/** Returns the next entity of type 'Weapon' in the game. 

	@param lastWeapon The previous item, can be `world` or `__NULL__` or `0` to retrieve the first item.
	@return The next item in the entity pool. Will be `world` or `__NULL__` if none are left. */
	entity Weapon(entity lastWeapon);


	/** Returns the next entity of type 'Actor' in the game.

	@param lastActor The previous item, can be `world` or `__NULL__` or `0` to retrieve the first item.
	@return The next item in the entity pool. Will be `world` or `__NULL__` if none are left. */
	entity Actor(entity lastActor);


	/** Returns the next entity of type 'Player' in the game.

	@param lastPlayer The previous item, can be `world` or `__NULL__` or `0` to retrieve the first item.
	@return The next item in the entity pool. Will be `world` or `__NULL__` if none are left. */
	entity Player(entity lastPlayer);
} nextAPI_t;
nextAPI_t next; /**< Access nextAPI_t functions using this variable. */

typedef string decl; /**< storage type of a [decl](@ref decl) reference. */

/** Decl library */
typedef struct
{
	/** Returns the name of a new decl in which you can store
	 * key/value pairs in. */
	decl New(void);

	/** Returns the string value of a key from a decl.

	@param declHandle is the `decl` reference to update.
	@param keyName specifies the name of the key to query within the decl.
	@return The key its value in string format. */
	string GetString(decl declHandle, string keyName);
	/** Returns the integer value of a decl key.

	@param declHandle is the `decl` reference to update.
	@param keyName specifies the name of the key to query within the decl.
	@return The key its value in integer format. */
	int GetInteger(decl declHandle, string keyName);
	/** Returns the floating-point value of a decl key.

	@param declHandle is the `decl` reference to update.
	@param keyName specifies the name of the key to query within the decl.
	@return The key its value in floating-point format. */
	float GetFloat(decl declHandle, string keyName);
	/** Returns the boolean value of a decl key.

	@param declHandle is the `decl` reference to update.
	@param keyName specifies the name of the key to query within the decl.
	@return The key its value in boolean form. */
	bool GetBool(decl declHandle, string keyName);
	/** Returns the vector value of a decl key.

	@param declHandle is the `decl` reference to update.
	@param keyName specifies the name of the key to query within the decl.
	@return The key its value in vector form. */
	vector GetVector(decl declHandle, string keyName);

	/** Adds/updates a named key within a decl with
	a new string value.

	@param declHandle is the `decl` reference to update.
	@param keyName specifies the key to set.
	@param setValue specifies the value we'll set the key to. */
	void AddKey(decl declHandle, string keyName, string setValue);

	/** Removes a named key from a decl entirely.

	@param declHandle is the `decl` reference to update.
	@param keyName specifies the key to remove. */
	void RemoveKey(decl declHandle, string keyName);

	/** Removes a named decl from the game.

	@param declHandle specifies the decl to delete. */
	void Delete(decl declHandle);
} declAPI_t;

declAPI_t declManager; /**< Access declAPI_t functions using this variable. */
/** @} */ // end of shared

void
setorigin_safe(entity target, vector testorg)
{
	for (int i = 0; i < 16; i++) {
		tracebox(testorg, target.mins, target.maxs, testorg, MOVE_NORMAL, target);

		if (!trace_startsolid) {
			break;
		}

		testorg[2] += 1.0;
	}

	setorigin(target, testorg);
}

__variant
linkToSharedProgs(string funcName)
{
	static void empty(void)
	{
		print("Called unimplemented shared API call.\n");
		breakpoint();
	}

	float func = externvalue( 0, funcName);

	if (func) {
		return ((__variant)func);
	} else {
		return (empty);
	}
}

void
_shared_main(void)
{
	ammo.NameForNum = linkToSharedProgs("SHPF_ammo_NameForNum");
	ammo.NumForName = linkToSharedProgs("SHPF_ammo_NumForName");
	ammo.MaxForName = linkToSharedProgs("SHPF_ammo_MaxForName");
	ammo.MaxForNum = linkToSharedProgs("SHPF_ammo_MaxForNum");

	cvars.SetString = linkToSharedProgs("SHPF_cvars_SetString");
	cvars.SetBool = linkToSharedProgs("SHPF_cvars_SetBool");
	cvars.SetInteger = linkToSharedProgs("SHPF_cvars_SetInteger");
	cvars.SetFloat = linkToSharedProgs("SHPF_cvars_SetFloat");
	cvars.SetVector = linkToSharedProgs("SHPF_cvars_SetVector");
	cvars.GetString = linkToSharedProgs("SHPF_cvars_GetString");
	cvars.GetInteger = linkToSharedProgs("SHPF_cvars_GetInteger");
	cvars.GetBool = linkToSharedProgs("SHPF_cvars_GetBool");
	cvars.GetFloat = linkToSharedProgs("SHPF_cvars_GetFloat");
	cvars.GetVector = linkToSharedProgs("SHPF_cvars_GetVector");

	declManager.New = linkToSharedProgs("SHPF_declManager_New");
	declManager.GetFloat = linkToSharedProgs("SHPF_declManager_GetFloat");
	declManager.GetString = linkToSharedProgs("SHPF_declManager_GetString");
	declManager.GetVector = linkToSharedProgs("SHPF_declManager_GetVector");
	declManager.GetBool = linkToSharedProgs("SHPF_declManager_GetBool");
	declManager.AddKey = linkToSharedProgs("SHPF_declManager_AddKey");
	declManager.RemoveKey = linkToSharedProgs("SHPF_declManager_RemoveKey");
	declManager.Delete = linkToSharedProgs("SHPF_declManager_Delete");

	userinfo.SetString = linkToSharedProgs("SHPF_userinfo_SetString");
	userinfo.SetBool = linkToSharedProgs("SHPF_userinfo_SetBool");
	userinfo.SetInteger = linkToSharedProgs("SHPF_userinfo_SetInteger");
	userinfo.SetFloat = linkToSharedProgs("SHPF_userinfo_SetFloat");
	userinfo.SetVector = linkToSharedProgs("SHPF_userinfo_SetVector");
	userinfo.GetString = linkToSharedProgs("SHPF_userinfo_GetString");
	userinfo.GetInteger = linkToSharedProgs("SHPF_userinfo_GetInteger");
	userinfo.GetBool = linkToSharedProgs("SHPF_userinfo_GetBool");
	userinfo.GetFloat = linkToSharedProgs("SHPF_userinfo_GetFloat");
	userinfo.GetVector = linkToSharedProgs("SHPF_userinfo_GetVector");

	serverinfo.SetString = linkToSharedProgs("SHPF_serverinfo_SetString");
	serverinfo.SetBool = linkToSharedProgs("SHPF_serverinfo_SetBool");
	serverinfo.SetInteger = linkToSharedProgs("SHPF_serverinfo_SetInteger");
	serverinfo.SetFloat = linkToSharedProgs("SHPF_serverinfo_SetFloat");
	serverinfo.SetVector = linkToSharedProgs("SHPF_serverinfo_SetVector");
	serverinfo.GetString = linkToSharedProgs("SHPF_serverinfo_GetString");
	serverinfo.GetInteger = linkToSharedProgs("SHPF_serverinfo_GetInteger");
	serverinfo.GetBool = linkToSharedProgs("SHPF_serverinfo_GetBool");
	serverinfo.GetFloat = linkToSharedProgs("SHPF_serverinfo_GetFloat");
	serverinfo.GetVector = linkToSharedProgs("SHPF_serverinfo_GetVector");

	teams.BestAutoJoinTeam = linkToSharedProgs("SHPF_teams_BestAutoJoinTeam");
	teams.TeamCount = linkToSharedProgs("SHPF_teams_TeamCount");
	teams.OpenTeamCount = linkToSharedProgs("SHPF_teams_OpenTeamCount");
	teams.Color = linkToSharedProgs("SHPF_teams_Color");
	teams.Name = linkToSharedProgs("SHPF_teams_Name");
	teams.Score = linkToSharedProgs("SHPF_teams_Score");
	teams.SpawnPoint = linkToSharedProgs("SHPF_teams_SpawnPoint");
	teams.NumPlayers = linkToSharedProgs("SHPF_teams_NumPlayers");
	teams.NumAlivePlayers = linkToSharedProgs("SHPF_teams_NumAlivePlayers");
	teams.NumDeadPlayers = linkToSharedProgs("SHPF_teams_NumDeadPlayers");
	teams.TotalDeaths = linkToSharedProgs("SHPF_teams_TotalDeaths");
	teams.TotalFrags = linkToSharedProgs("SHPF_teams_TotalFrags");
	teams.Valid = linkToSharedProgs("SHPF_teams_Valid");
	teams.RandomPlayer = linkToSharedProgs("SHPF_teams_RandomPlayer");
	teams.TotalClasses = linkToSharedProgs("SHPF_teams_TotalClasses");
	teams.ClassForIndex = linkToSharedProgs("SHPF_teams_ClassForIndex");

	/* server */
	teams.AddScore = linkToSharedProgs("SHPF_teams_AddScore");
	teams.SetScore = linkToSharedProgs("SHPF_teams_SetScore");
	teams.SetUp = linkToSharedProgs("SHPF_teams_SetUp");
	teams.AddClass = linkToSharedProgs("SHPF_teams_AddClass");
	teams.SetSpawnPoint = linkToSharedProgs("SHPF_teams_SetSpawnPoint");

	precache.Model = linkToSharedProgs("SHPF_precache_Model");
	precache.Sound = linkToSharedProgs("SHPF_precache_Sound");
	precache.Particle = linkToSharedProgs("SHPF_precache_Particle");
	precache.Entity = linkToSharedProgs("SHPF_precache_Entity");
	precache.SpriteFrame = linkToSharedProgs("SHPF_precache_SpriteFrame");

	soundKit.Play = linkToSharedProgs("SHPF_sounds_Play");

	weaponInfo.Type = linkToSharedProgs("SHPF_weaponInfo_Type");
	weaponInfo.StartAmmo = linkToSharedProgs("SHPF_weaponInfo_StartAmmo");
	weaponInfo.MaxAmmo = linkToSharedProgs("SHPF_weaponInfo_MaxAmmo");
	weaponInfo.IsSemiAuto = linkToSharedProgs("SHPF_weaponInfo_IsSemiAuto");
	weaponInfo.InventoryType = linkToSharedProgs("SHPF_weaponInfo_InventoryType");
	weaponInfo.FireTime = linkToSharedProgs("SHPF_weaponInfo_FireTime");
	weaponInfo.ClipSize = linkToSharedProgs("SHPF_weaponInfo_ClipSize");
	weaponInfo.Class = linkToSharedProgs("SHPF_weaponInfo_Class");
	weaponInfo.IsClipOnly = linkToSharedProgs("SHPF_weaponInfo_IsClipOnly");
	weaponInfo.IsDetonationTimed = linkToSharedProgs("SHPF_weaponInfo_IsDetonationTimed");

	entityDef.GetString = linkToSharedProgs("SHPF_entityDef_GetString");
	entityDef.GetInteger = linkToSharedProgs("SHPF_entityDef_GetInteger");
	entityDef.GetBool = linkToSharedProgs("SHPF_entityDef_GetBool");
	entityDef.GetFloat = linkToSharedProgs("SHPF_entityDef_GetFloat");
	entityDef.GetVector = linkToSharedProgs("SHPF_entityDef_GetVector");

	is.AI = linkToSharedProgs("SHPF_is_AI");
	is.Bot = linkToSharedProgs("SHPF_is_Bot");
	is.Alive = linkToSharedProgs("SHPF_is_Alive");
	is.GodMode = linkToSharedProgs("SHPF_is_GodMode");
	is.Client = linkToSharedProgs("SHPF_is_Client");
	is.Player = linkToSharedProgs("SHPF_is_Player");
	is.Sentient = linkToSharedProgs("SHPF_is_Sentient");

	/* helpful finder */
	next.Actor = linkToSharedProgs("SHPF_next_Actor");
	next.Item = linkToSharedProgs("SHPF_next_Item");
	next.Weapon = linkToSharedProgs("SHPF_next_Weapon");
	next.Player = linkToSharedProgs("SHPF_next_Player");
}
