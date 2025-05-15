/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

/* cvars library */
string
SHPF_cvars_GetString(string cvarName)
{
	return cvar_string(cvarName);
}

float
SHPF_cvars_GetFloat(string cvarName)
{
	return cvar(cvarName);
}

int
SHPF_cvars_GetInteger(string cvarName)
{
	return (int)cvar(cvarName);
}

bool
SHPF_cvars_GetBool(string cvarName)
{
	return (cvar(cvarName) > 0) ? (true) : (false);
}

vector
SHPF_cvars_GetVector(string cvarName)
{
	return stov(cvar_string(cvarName));
}

void
SHPF_cvars_SetString(string cvarName, string setValue)
{
	cvar_set(cvarName, setValue);
}

void
SHPF_cvars_SetInteger(string cvarName, int setValue)
{
	cvar_set(cvarName, itos(setValue));
}

void
SHPF_cvars_SetBool(string cvarName, bool setValue)
{
	cvar_set(cvarName, ftos(setValue));
}

void
SHPF_cvars_SetFloat(string cvarName, float setValue)
{
	cvar_set(cvarName, ftos(setValue));
}

void
SHPF_cvars_SetVector(string cvarName, vector setValue)
{
	cvar_set(cvarName, vtos(setValue));
}

/* decl library */
string
SHPF_declManager_New(void)
{
	ncDict newDict = spawn(ncDict);

	/* not out of memory */
	if (newDict) {
		/* assign it a new name, return */
		newDict.declclass = sprintf("ncDict_%x", num_for_edict(newDict));
		return (newDict.declclass);
	}

	ncError("Unable to create decl");
	return (__NULL__);
}

string
SHPF_declManager_GetString(string defName, string keyName)
{
	ncDict findDecl = (ncDict)find(world, ::declclass, defName);

	if (findDecl) {
		return (findDecl.GetString(keyName));
	}

	ncError("Decl %S is not loaded.", defName);
	return (__NULL__);
}

int
SHPF_declManager_GetInteger(string defName, string keyName)
{
	ncDict findDecl = (ncDict)find(world, ::declclass, defName);

	if (findDecl) {
		return (findDecl.GetInteger(keyName));
	}

	ncError("Decl %S is not loaded.", defName);
	return (__NULL__);
}

float
SHPF_declManager_GetFloat(string defName, string keyName)
{
	ncDict findDecl = (ncDict)find(world, ::declclass, defName);

	if (findDecl) {
		return (findDecl.GetFloat(keyName));
	}

	ncError("Decl %S is not loaded.", defName);
	return (__NULL__);
}

bool
SHPF_declManager_GetBool(string defName, string keyName)
{
	ncDict findDecl = (ncDict)find(world, ::declclass, defName);

	if (findDecl) {
		return (findDecl.GetBool(keyName));
	}

	ncError("Decl %S is not loaded.", defName);
	return (__NULL__);
}

vector
SHPF_declManager_GetVector(string defName, string keyName)
{
	ncDict findDecl = (ncDict)find(world, ::declclass, defName);

	if (findDecl) {
		return (findDecl.GetVector(keyName));
	}

	ncError("Decl %S is not loaded.", defName);
	return (__NULL__);
}

void
SHPF_declManager_AddKey(string defName, string keyName, string setValue)
{
	ncDict findDecl = (ncDict)find(world, ::declclass, defName);

	if (findDecl) {
		findDecl.AddKey(keyName, setValue);
		return;
	}

	ncError("Decl %S is not loaded.", defName);
}

void
SHPF_declManager_RemoveKey(string defName, string keyName)
{
	ncDict findDecl = (ncDict)find(world, ::declclass, defName);

	if (findDecl) {
		findDecl.RemoveKey(keyName);
		return;
	}

	ncError("Decl %S is not loaded.", defName);
}

void
SHPF_declManager_Delete(string defName, string keyName)
{
	ncDict findDecl = (ncDict)find(world, ::declclass, defName);

	if (findDecl) {
		remove(findDecl);
		return;
	}

	ncError("Decl %S is not loaded.", defName);
}

/* ammo library */
string
SHPF_ammo_NameForNum(int ammoIndex)
{
	return ammoNameForNum(ammoIndex);
}

int
SHPF_ammo_NumForName(string ammoName)
{
	return ammoNumForName(ammoName);
}

int
SHPF_ammo_MaxForName(string ammoName)
{
	return ammoMaxForName(ammoName);
}

int
SHPF_ammo_MaxForNum(int ammoIndex)
{
	return ammoMaxForNum(ammoIndex);
}

/* userinfo library */
string
SHPF_userinfo_GetString(entity client, string keyName)
{
#ifdef SERVER
	return infokey(client, keyName);
#endif

#ifdef CLIENT
	return getplayerkeyvalue(client.entnum-1, keyName);
#endif
}

int
SHPF_userinfo_GetInteger(entity client, string keyName)
{
	return stoi(SHPF_userinfo_GetString(client, keyName));
}

float
SHPF_userinfo_GetFloat(entity client, string keyName)
{
	return stof(SHPF_userinfo_GetString(client, keyName));
}

bool
SHPF_userinfo_GetBool(entity client, string keyName)
{
	return stof(SHPF_userinfo_GetString(client, keyName)) ? (true) : (false);
}

vector
SHPF_userinfo_GetVector(entity client, string keyName)
{
	return stov(SHPF_userinfo_GetString(client, keyName));
}

void
SHPF_userinfo_SetString(entity client, string keyName, string setValue)
{
#ifdef SERVER
	forceinfokey(client, keyName, setValue);
#endif
}

void
SHPF_userinfo_SetInteger(entity client, string keyName, int setValue)
{
	SHPF_userinfo_SetString(client, keyName, itos(setValue));
}

void
SHPF_userinfo_SetFloat(entity client, string keyName, float setValue)
{
	SHPF_userinfo_SetString(client, keyName, ftos(setValue));
}

void
SHPF_userinfo_SetBool(entity client, string keyName, bool setValue)
{
	SHPF_userinfo_SetString(client, keyName, ftos(setValue));
}

void
SHPF_userinfo_SetVector(entity client, string keyName, vector setValue)
{
	SHPF_userinfo_SetString(client, keyName, vtos(setValue));
}


/* serverinfo library */
string
SHPF_serverinfo_GetString(string serverKey)
{
	return serverkey(serverKey);
}

float
SHPF_serverinfo_GetFloat(string serverKey)
{
	return serverkeyfloat(serverKey);
}

int
SHPF_serverinfo_GetInteger(string serverKey)
{
	return (int)serverkeyfloat(serverKey);
}

bool
SHPF_serverinfo_GetBool(string serverKey)
{
	return (serverkeyfloat(serverKey) > 0) ? (true) : (false);
}

vector
SHPF_serverinfo_GetVector(string serverKey)
{
	return stov(serverkey(serverKey));
}

void
SHPF_serverinfo_SetString(string serverKey, string setValue)
{
#ifdef SERVER
	forceinfokey(world, serverKey, setValue);
#else
#endif
}

void
SHPF_serverinfo_SetInteger(string serverKey, int setValue)
{
#ifdef SERVER
	forceinfokey(world, serverKey, itos(setValue));
#else
#endif
}

void
SHPF_serverinfo_SetBool(string serverKey, bool setValue)
{
#ifdef SERVER
	forceinfokey(world, serverKey, ftos(setValue));
#else
#endif
}

void
SHPF_serverinfo_SetFloat(string serverKey, float setValue)
{
#ifdef SERVER
	forceinfokey(world, serverKey, ftos(setValue));
#else
#endif
}

void
SHPF_serverinfo_SetVector(string serverKey, vector setValue)
{
#ifdef SERVER
	forceinfokey(world, serverKey, vtos(setValue));
#else
#endif
}


/* team library */
string
SHPF_teams_Name(int teamID)
{
	return SHPF_serverinfo_GetString(sprintf("team_%i", teamID));
}

bool
SHPF_teams_Valid(int teamID)
{
	string teamName = SHPF_teams_Name(teamID);

	if (teamName == "") {
		return (false);
	}

	if (teamID <= 0i) {
		ncError("Team ID cannot be 0 or negative.");
	}

	if (teamID > 1000i) {
		ncError("Team ID cannot be over 1000. Reserved.");
	}

	return (true);
}

int
SHPF_teams_TeamCount(void)
{
	return SHPF_serverinfo_GetInteger("teams");
}

int
SHPF_teams_OpenTeamCount(void)
{
	int openTeams = 0i;

	for (int i = 1; i <= 1000; i++) {
		if (SHPF_teams_Valid(i) == true) {
			if (SHPF_serverinfo_GetBool(sprintf("teamclosed_%i", i)) == false) {
				openTeams++;
			}
		}
	}

	return (openTeams);
}

vector
SHPF_teams_Color(int teamID)
{
	return SHPF_serverinfo_GetVector(sprintf("teamcolor_%i", teamID));
}

int
SHPF_teams_Score(int teamID)
{
	return SHPF_serverinfo_GetInteger(sprintf("teamscore_%i", teamID));
}

string
SHPF_teams_SpawnPoint(int teamID)
{
	return SHPF_serverinfo_GetString(sprintf("teamspawn_%i", teamID));
}

int
SHPF_teams_NumPlayers(int teamID)
{
	int countedPlayers = 0i;

#ifdef CLIENT
	for (int i = -1; i > -32; i--) {
		int playerTeam = (int)getplayerkeyfloat(i, "*team");

		if (playerTeam == teamID) {
			countedPlayers++;
		}
	}
#else
	for (entity teamPlayer = world; (teamPlayer = next.Player(teamPlayer));) {
		if (teamPlayer.team == (float)teamID) {
			countedPlayers++;
		}
	}
#endif

	return (countedPlayers);
}

int
SHPF_teams_NumAlivePlayers(int teamID)
{
	int countedPlayers = 0i;

#ifdef CLIENT
	for (int i = -1; i > -32; i--) {
		int playerTeam = (int)getplayerkeyfloat(i, "*team");
		bool playerDead = getplayerkeyfloat(i, "*dead");

		if (playerTeam == teamID && playerDead == false) {
			countedPlayers++;
		}
	}
#else
	for (entity teamPlayer = world; (teamPlayer = next.Player(teamPlayer));) {
		if (teamPlayer.team == (float)teamID && teamPlayer.health > 0) {
			countedPlayers++;
		}
	}
#endif

	return (countedPlayers);
}

entity
SHPF_teams_RandomPlayer(int teamID)
{
#ifdef SERVER
	int randomCounter = floor(random(1, (float)SHPF_teams_NumAlivePlayers(teamID)));
	int countVal = 0i;

	for (entity teamPlayer = world; (teamPlayer = next.Player(teamPlayer));) {
		if (teamPlayer.team == teamID) {
			countVal++;

			if (countVal == randomCounter) {
				return (teamPlayer);
			}
		}
	}
#endif

	return __NULL__;
}

int
SHPF_teams_NumDeadPlayers(int teamID)
{
	int countedPlayers = 0i;

#ifdef CLIENT
	for (int i = -1; i > -32; i--) {
		int playerTeam = (int)getplayerkeyfloat(i, "*team");
		bool playerDead = getplayerkeyfloat(i, "*dead");

		if (playerTeam == teamID && playerDead == true) {
			countedPlayers++;
		}
	}
#else
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		if (is.Player(a)) {
			ncPlayer pl = (ncPlayer)a;
			if (pl.GetTeam() == (float)teamID && pl.IsAlive() == false) {
				countedPlayers++;
			}
		}
	}
#endif

	return (countedPlayers);
}

int
SHPF_teams_TotalDeaths(int teamID)
{
	int deathCounter = 0i;

#ifdef CLIENT
	for (int i = -1; i > -32; i--) {
		int playerTeam = (int)getplayerkeyfloat(i, "*team");

		if (playerTeam == teamID) {
			deathCounter += (int)getplayerkeyfloat(i, "*deaths");
		}
	}
#else
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		if (is.Player(a)) {
			ncPlayer pl = (ncPlayer)a;
			if (pl.GetTeam() == (float)teamID) {
				deathCounter += pl.deaths;
			}
		}
	}
#endif
	return (deathCounter);
}

int
SHPF_teams_TotalFrags(int teamID)
{
	int fragCounter = 0i;

#ifdef CLIENT
	for (int i = -1; i > -32; i--) {
		int playerTeam = (int)getplayerkeyfloat(i, "*team");

		if (playerTeam == teamID) {
			fragCounter += (int)getplayerkeyfloat(i, INFOKEY_P_FRAGS);
		}
	}
#else
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		if (is.Player(a)) {
			ncPlayer pl = (ncPlayer)a;
			if (pl.GetTeam() == (float)teamID) {
				fragCounter += pl.frags;
			}
		}
	}
#endif

	return (fragCounter);
}


int
SHPF_teams_BestAutoJoinTeam(void)
{
	int sadTeam = 0i;
	int sadCount = 1995i; /* unlikely high player number. */

	/* maximum of 1000 teams. */
	for (int i = 1; i <= 1000; i++) {
		/* gaps in team id setup can now act as divider, allowing which teams are auto-join. */
		if (SHPF_teams_Valid(i) == false) {
			break;
		}

		int playerCount = SHPF_teams_NumPlayers(i);

		if (playerCount < sadCount) {
			sadCount = playerCount;
			sadTeam = i;
		}
	}

	return (sadTeam);
}

void
SHPF_teams_SetScore(int teamID, int setValue)
{
	if (SHPF_teams_Valid(teamID) == false) {
		return;
	}

#ifdef SERVER
	SHPF_serverinfo_SetInteger(sprintf("teamscore_%i", teamID), setValue);

	int scoreLimit = cvars.GetInteger("scorelimit");

	if (scoreLimit >= 1i) {
		if (setValue >= scoreLimit) {
			ncRuleDelegate activeRules = ncRuleDelegate::ActiveInstance();
			activeRules.IntermissionStart();
		}
	}
#else
#endif
}

void
SHPF_teams_AddScore(int teamID, int addValue)
{
	if (SHPF_teams_Valid(teamID) == false) {
		return;
	}

#ifdef SERVER
	int newValue = SHPF_teams_Score(teamID) + addValue;
	SHPF_teams_SetScore(teamID, newValue);
#endif
}

void
SHPF_teams_SetUp(int teamID, string teamTitle, vector teamColor, bool openTeam)
{
#ifdef SERVER
	int teamCount = 0i;

	if (!STRING_SET(teamTitle)) {
		ncError("Team title cannot be empty.");
	}

	if (teamID <= 0i) {
		ncError("Team ID cannot be 0 or negative.");
	}

	if (teamID > 1000i) {
		ncError("Team ID cannot be over 1000. Reserved.");
	}

	SHPF_serverinfo_SetString(sprintf("team_%i", teamID), teamTitle);
	SHPF_serverinfo_SetString(sprintf("teamscore_%i", teamID), "0");
	SHPF_serverinfo_SetVector(sprintf("teamcolor_%i", teamID), teamColor / 255);

	if (openTeam) {
		SHPF_serverinfo_SetString(sprintf("teamclosed_%i", teamID), "");
	} else {
		SHPF_serverinfo_SetString(sprintf("teamclosed_%i", teamID), "1");
	}

	/* buh */
	for (teamCount = 0i; teamCount <= 1000; teamCount++) {
		//printf("Checking validity of team %i\n", teamCount + 1i);

		if (SHPF_teams_Valid(teamCount + 1i) == false) {
			break;
		}
	}

	//printf("SHPF_serverinfo_SetInteger %i\n", teamCount);
	SHPF_serverinfo_SetInteger("teams", teamCount);
#else
#endif
}

void
SHPF_teams_AddClass(int teamID, string classType)
{
	if (SHPF_teams_Valid(teamID) == false) {
		return;
	}

#ifdef SERVER
	int teamCount = 0i;
	string teamInfo = __NULL__;
	string currentClasses = __NULL__;

	if (!STRING_SET(classType)) {
		ncError("Class type cannot be empty.");
	}

	teamInfo = sprintf("teamclass_%i", teamID);
	currentClasses = SHPF_serverinfo_GetString(teamInfo);
	SHPF_serverinfo_SetString(teamInfo, strcat(currentClasses, classType, " "));
#else
#endif
}

int
SHPF_teams_TotalClasses(int teamID)
{
	if (SHPF_teams_Valid(teamID) == false) {
		return 0i;
	}

	int numClasses = 0i;
	int realCount = 0i;
	string teamInfo = sprintf("teamclass_%i", teamID);
	string currentClasses = SHPF_serverinfo_GetString(teamInfo);
	return (int)tokenize_console(currentClasses);
}

string
SHPF_teams_ClassForIndex(int teamID, int classIndex)
{
	if (SHPF_teams_Valid(teamID) == false) {
		return "";
	}

	int numClasses = 0i;
	int realCount = 0i;
	string teamInfo = sprintf("teamclass_%i", teamID);
	string currentClasses = SHPF_serverinfo_GetString(teamInfo);
	numClasses = (int)tokenize_console(currentClasses);

	if (numClasses < classIndex) {
		return "";
	}

	return (argv(classIndex));
}

void
SHPF_teams_SetSpawnPoint(int teamID, string spawnPoint)
{
	if (SHPF_teams_Valid(teamID) == false) {
		return;
	}

#ifdef SERVER
	SHPF_serverinfo_SetString(sprintf("teamspawn_%i", teamID), spawnPoint);
#else
#endif
}

/* weaponInfo library */

/* required because we might need to look it up inside the
info for the primary attack mode. */
static string
ncWeapon_GetPrimaryKeyValue(string weaponDef, string keyName)
{
	string fireInfo1 = EntityDef_GetKeyValue(weaponDef, "def_fireInfo");
	string defValue = EntityDef_GetKeyValue(weaponDef, keyName);
	string fireInfoValue = EntityDef_GetKeyValue(fireInfo1, keyName);

	/* fireinfo takes priority */
	if (fireInfoValue) {
		return (fireInfoValue);
	}

	return (defValue);
}

string
SHPF_weaponInfo_Type(string weaponDef)
{
	return ("unknown");
}

int
SHPF_weaponInfo_StartAmmo(string weaponDef)
{
	return (int)stof(EntityDef_GetKeyValue(weaponDef, "clipSize"));
}

int
SHPF_weaponInfo_MaxAmmo(string weaponDef)
{
	string ammoType = ncWeapon_GetPrimaryKeyValue(weaponDef, "ammoType");
	return (ammoMaxForName(ammoType));
}

bool
SHPF_weaponInfo_IsSemiAuto(string weaponDef)
{
	return (bool)stof(ncWeapon_GetPrimaryKeyValue(weaponDef, "semiAuto"));
}

string
SHPF_weaponInfo_InventoryType(string weaponDef)
{
	return ("item");
}

float
SHPF_weaponInfo_FireTime(string weaponDef)
{
	return stof(ncWeapon_GetPrimaryKeyValue(weaponDef, "fireRate"));
}

int
SHPF_weaponInfo_ClipSize(string weaponDef)
{
	return (int)stoi(EntityDef_GetKeyValue(weaponDef, "clipSize"));
}

string
SHPF_weaponInfo_Class(string weaponDef)
{
	return ("unknown");
}

bool
SHPF_weaponInfo_IsClipOnly(string weaponDef)
{
	int clipSize = (int)stoi(EntityDef_GetKeyValue(weaponDef, "clipSize"));
	string ammoType = ncWeapon_GetPrimaryKeyValue(weaponDef, "ammoType");

	/* no ammo type... */
	if (!ammoType) {
		/* but a clip is defined */
		if (clipSize > 0i) {
			return (true);
		}
	}
	return (false);
}

bool
SHPF_weaponInfo_IsDetonationTimed(string weaponDef)
{
	string projectileDef = ncWeapon_GetPrimaryKeyValue(weaponDef, "def_projectile");
	bool isFused = (bool)stof(EntityDef_GetKeyValue(projectileDef, "detonate_on_fuse"));
	return (isFused);
}

ncEntity
spawnClass(string className, vector desiredPos)
{
	ncEntity newEntity = __NULL__;

#ifdef SERVER
	newEntity = Entity_CreateClass(className);

	/* That class didn't exist, so let's take the base Nuclide one */
	if (!newEntity) {
		newEntity = Entity_CreateClass("ncEntity");
	}

	/* OOM. It's over. */
	if (!newEntity) {
		return (__NULL__);
	}

	newEntity.classname = className;
	newEntity.SetOrigin(desiredPos);
	newEntity.Spawn();
#endif

	return (newEntity);
}

#ifdef SERVER
bool
changeClass(entity target, string className)
{
	/* hijack that decl. you don't to mess with this. */
	if (target.flags & FL_CLIENT) {
		if (className == "spectator") {
			ncPlayer theClient = (ncPlayer)target;
			changeClass(theClient, "player");
			theClient.MakeTempSpectator();
			theClient.team = TEAM_SPECTATOR;
			return (true);
		}
	}

	return EntityDef_SwitchClass((ncEntity)target, className) ? (true) : (false);
}
#endif

void
sendInput(entity target, string inputName, string dataString, entity activator)
{
	ncEntity targetEntity = (ncEntity)target;

	if (!target) {
		ncError("target entity is nil");
		return;
	}

	if (!STRING_SET(inputName)) {
		ncError("No input specified.");
		return;
	}

#ifdef SERVER
	targetEntity.Input(activator, inputName, dataString);
#endif
}

/* helper functions */
bool
SHPF_is_AI(entity entityToCheck)
{
	if (!entityToCheck) {
		return (false);
	}

	if (entityToCheck.flags & FL_MONSTER) {
		return (true);
	}

	return (false);
}

bool
SHPF_is_Alive(entity entityToCheck)
{
	if (!entityToCheck) {
		return (false);
	}

#ifdef SERVER
	if (entityToCheck.takedamage != DAMAGE_NO) {
		ncSurfacePropEntity livingEnt = (ncSurfacePropEntity)entityToCheck;
		return livingEnt.IsAlive();
	}
#endif

	return (false);
}

bool
SHPF_is_GodMode(entity entityToCheck)
{
	if (!entityToCheck) {
		return (false);
	}

	if (entityToCheck.flags & FL_GODMODE) {
		return (true);
	}

	return (false);
}

bool
SHPF_is_Client(entity entityToCheck)
{
	if (!entityToCheck) {
		return (false);
	}

	return (entityToCheck.flags & FL_CLIENT) ? (true) : (false);
}

bool
SHPF_is_Player(entity entityToCheck)
{
	if (STRING_SET(entityToCheck.classname))

	if (SHPF_is_Client(entityToCheck)) {
		ncClient pl = (ncClient)entityToCheck;
		return pl.IsPlayer();
	}

	return (false);
}

bool
SHPF_is_Sentient(entity entityToCheck)
{
	if (SHPF_is_AI(entityToCheck) || SHPF_is_Player(entityToCheck)) {
		return (true);
	}

	return (false);
}

bool
SHPF_is_Bot(entity entityToCheck)
{
	if (!entityToCheck) {
		return (false);
	}

#ifdef SERVER
	return (clienttype(entityToCheck) == CLIENTTYPE_BOT) ? (true) : (false);
#else
	return userinfo.GetBool(entityToCheck, "*bot");
#endif
}

bool
SHPF_is_Weapon(entity entityToCheck)
{
	if (!entityToCheck) {
		return (false);
	}

	return (entityToCheck._isWeapon) ? (true) : (false);
}

bool
SHPF_is_Item(entity entityToCheck)
{
	if (!entityToCheck) {
		return (false);
	}

	return (entityToCheck._isItem) ? (true) : (false);
}

entity
SHPF_next_Item(entity lastItem)
{
	return findfloat(lastItem, ::_isItem, 1);
}

entity
SHPF_next_Weapon(entity lastItem)
{
	return findfloat(lastItem, ::_isWeapon, 1);
}

entity
SHPF_next_Actor(entity lastItem)
{
	return findfloat(lastItem, ::_isActor, 1);
}

entity
SHPF_next_Player(entity lastItem)
{
	return findfloat(lastItem, ::_isPlayer, 1);
}

string
SHPF_entityDef_GetString(string declName, string keyName)
{
	return EntityDef_GetKeyValue(declName, keyName);
}

int
SHPF_entityDef_GetInteger(string declName, string keyName)
{
	return (int)stoi(SHPF_entityDef_GetString(declName, keyName));
}

bool
SHPF_entityDef_GetBool(string declName, string keyName)
{

	return stof(SHPF_entityDef_GetString(declName, keyName)) ? (true) : (false);
}

float
SHPF_entityDef_GetFloat(string declName, string keyName)
{

	return stof(SHPF_entityDef_GetString(declName, keyName));
}

vector
SHPF_entityDef_GetVector(string declName, string keyName)
{
	return stov(SHPF_entityDef_GetString(declName, keyName));
}

int
SHPF_precache_Model(string modelPath)
{
	if (!STRING_SET(modelPath)) {
		return (0i);
	}

	modelPath = Util_FixModel(modelPath);
	precache_model(modelPath);
	PropData_ForModel(modelPath);
	return (int)getmodelindex(modelPath, false);
}

int
SHPF_precache_Sound(string soundDecl)
{
	if (!STRING_SET(soundDecl)) {
		return (-1i);
	}

	return (int)SoundDef_Precache(soundDecl);
}

int
SHPF_precache_Particle(string particleName)
{
	if (!STRING_SET(particleName)) {
		return (0i);
	}

	return (int)particleeffectnum(particleName);
}


bool
SHPF_precache_Entity(string defName)
{
	if (!STRING_SET(defName)) {
		return (false);
	}

#ifdef SERVER
	return EntityDef_Precache(defName);
#else
	return (false);
#endif
}

string
SHPF_precache_SpriteFrame(string spritePath, float frameNum, float timeIntoFrame)
{
#ifdef CLIENT
	return spriteframe(spritePath, frameNum, timeIntoFrame);
#else
	return "";
#endif
}

void
SHPF_sounds_Play(string soundDef, float level = 75, float pitch = 100, float volume = 100, float channel = CHAN_AUTO)
{

}
