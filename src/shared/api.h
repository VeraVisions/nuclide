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

@{
*/

typedef struct
{
	/** Returns the name of the specified ammo type. Returns __NULL__ when invalid. */
	string NameForNum(int);
	/** Returns the ammo id of a given name of ammo. Return -1 when invalid. */
	int NumForName(string);
	/** Returns the max ammo given name of ammo. Returns 0 when invalid. */
	int MaxForName(string);
	/** Returns the max ammo given name of ammo. Returns 0 when invalid. */
	int MaxForNum(int);
} ammoAPI_t;

ammoAPI_t ammo;


/* CVar library */
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

cvarAPI_t cvars;

/* ServerInfo library */
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
	/** Sets the specified server info-key to a set string value.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetString(string serverKey, string setValue);
	/** Sets the specified server info-key to a set integer value.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetInteger(string serverKey, int setValue);
	/** Sets the specified server info-key to a set boolean value.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetBool(string serverKey, bool setValue);
	/** Sets the specified server info-key to a set floating-point value.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetFloat(string serverKey, float setValue);
	/** Sets the specified server info-key to a set vector.

	@param serverKey specifies the server info-key to set.
	@param setValue specifies the value of said key. */
	void SetVector(string serverKey, vector setValue);
} serverinfoAPI_t;

serverinfoAPI_t serverinfo;

/* UserInfo library */
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
	/** Sets the specified user info-key to a set string value.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetString(entity clientEnt, string userKey, string setValue);
	/** Sets the specified user info-key to a set integer value.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetInteger(entity clientEnt, string userKey, int setValue);
	/** Sets the specified user info-key to a set boolean value.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetBool(entity clientEnt, string userKey, bool setValue);
	/** Sets the specified user info-key to a set floating-point value.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetFloat(entity clientEnt, string userKey, float setValue);
	/** Sets the specified user info-key to a set vector.

	@param clientEnt specifies which user to query.
	@param userKey specifies the user info-key to set.
	@param setValue specifies the value of said key. */
	void SetVector(entity clientEnt, string userKey, vector setValue);
} userinfoAPI_t;

userinfoAPI_t userinfo;

typedef struct
{
	/** @return the "attack" type of the weapon.
	@param weaponDef the name of the entityDef that defines the weapon.
	@return Attack type of the weapon. */
	string Type(string weaponDef);
	/** @return The amount of ammo the specified weapon is meant to start with, when first given to the player. This can be distributed to both clip and reserve ammo types.
	@param weaponDef the name of the entityDef that defines the weapon. */
	int StartAmmo(string weaponDef);
	/** @return The amount of ammo the weapon can hold in total when it comes to reserve ammo. So this is really returning the max ammo of a given ammo type.
	@param weaponDef the name of the entityDef that defines the weapon. */
	int MaxAmmo(string weaponDef);
	/** @return Whether the weapon is semi automatic.
	@param weaponDef the name of the entityDef that defines the weapon. */
	bool IsSemiAuto(string weaponDef);

	/** @return How this weapon is stored. Usually "item", unless it's temporary.
	@param weaponDef the name of the entityDef that defines the weapon. */
	string InventoryType(string weaponDef);
	/** @return The delay (in seconds) betwen shots of the specified weapon.
	@param weaponDef the name of the entityDef that defines the weapon. */
	float FireTime(string weaponDef);
	/**
	@return The delay (in seconds) betwen shots of the specified weapon.
	@param weaponDef the name of the entityDef that defines the weapon. */
	int ClipSize(string weaponDef);
	/**
	@return The 'class' of weapon. Not spawnclass.
	@param weaponDef the name of the entityDef that defines the weapon.*/
	string Class(string weaponDef);
	/**
	@return true/false whether the weapon takes its ammo only through its clip.
	@param weaponDef the name of the entityDef that defines the weapon.*/
	bool IsClipOnly(string weaponDef);
	/**
	@return true/false whether or not the weapon creates a timed, fused detonating charge of sorts.
	@param weaponDef the name of the entityDef that defines the weapon.*/
	bool IsDetonationTimed(string weaponDef);
} weaponInfo_t;

weaponInfo_t weaponInfo;

/* Team library */
typedef struct
{
	 int BestAutoJoinTeam(void);
	 int TeamCount(void);
	 int OpenTeamCount(void);
	 vector Color(int);
	 string Name(int);
	 int Score(int);
	 string SpawnPoint(int);
	 int NumPlayers(int);
	 int NumAlivePlayers(int);
	 int NumDeadPlayers(int);
	 int TotalDeaths(int);
	 int TotalFrags(int);
	 bool Valid(int);

	 void AddScore(int, int);
	 void SetScore(int, int);
	 entity RandomPlayer(int);


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


	/** Returns the maximum number of classes this team can select.

	@param teamID specifies which team slot to query for class types. */
	int TotalClasses(int teamID);

	/** Returns the class type of a given team + index.

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

teamAPI_t teams;



/* ServerInfo library */
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
entityDefAPI_t entityDef;

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
} precacheAPI_t;
precacheAPI_t precache;



typedef struct
{
	float Play(string soundDef, float level = 75, float pitch = 100, float volume = 100, float channel = CHAN_AUTO);
} soundAPI_t;
soundAPI_t soundKit;


typedef string decl;

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

declAPI_t declManager;
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

	/* server */
	teams.AddScore = linkToSharedProgs("SHPF_teams_AddScore");
	teams.SetScore = linkToSharedProgs("SHPF_teams_SetScore");
	teams.SetUp = linkToSharedProgs("SHPF_teams_SetUp");
	teams.AddClass = linkToSharedProgs("SHPF_teams_AddClass");
	teams.TotalClasses = linkToSharedProgs("SHPF_teams_TotalClasses");
	teams.ClassForIndex = linkToSharedProgs("SHPF_teams_ClassForIndex");
	teams.SetSpawnPoint = linkToSharedProgs("SHPF_teams_SetSpawnPoint");

	precache.Model = linkToSharedProgs("SHPF_precache_Model");
	precache.Sound = linkToSharedProgs("SHPF_precache_Sound");
	precache.Particle = linkToSharedProgs("SHPF_precache_Particle");
	precache.Entity = linkToSharedProgs("EntityDef_Precache");

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
}
