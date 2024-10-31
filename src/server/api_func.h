.float deaths;

/** @defgroup serverAPI Server-side multiprogs API
    @brief Server-side multiprogs API
    @ingroup multiprogs
    @ingroup server

APIs used by MapC progs, game rules and the server progs exclusively.

![Package](package_add.png)

@{
*/

/* Util library */
typedef struct
{
	/** Returns the current time.

	@param realTime specifies the time in seconds since 01/01/1970.
	@param zoneType specifies the time zone to use. 0 = UTC, 1 = Local.
	@param formatString is a C-language, strftime styled string setting the output format
	@return Euler-angles generated from the input. */
	string TimeToString(int realTime, int zoneType, string formatString);
} utilAPI_t;
var utilAPI_t util;

/* Exists library */
typedef struct
{
	bool InMap(string);
	bool InPVS(entity, vector);
	bool InVFS(string fileName);
} existsAPI_t;
var existsAPI_t exists;

/* Ents library */
typedef struct
{
	/** Creates a new entity of a given class name.
	It is guaranteed to return an entity, unless you
	have run out of memory.

	@param className the type of entity class to create.
	@param spawnPos the position at which it should spawn.
	@return The created entity. */
	entity Create(string className, vector spawnPos);
	/** Precaches a given entity class.
	Ensuring models, sounds and other assets referenced
	within are loaded ahead of time.

	@param className to precache
	@return Success. */
	bool Precache(string className);
	/** Transitions an entity from one class to another.

	@param targetEntity is the target entity.
	@param className is the class type to change targetEntity to.
	@return The created entity. */
	entity ChangeToClass(entity targetEntity, string className);
	/** Sends an input (See NSIO::Input) to an entity.

	While you're able to manipulate entities in most ways using bare MapC, you might want to change Nuclide specific attributes of them as well. This can only be done using the I/O system.

	For the variety of inputs an entity supports, please look at the respective entity-specific documentation.

	@param target is the entity which will receive the input
	@param inputName is the name of the input. E.g. "SetOrigin"
	@param dataString contains parameters for the input. E.g. "0 0 0"
	@param activator references which entity is "responsible" for triggering this input. */
	entity Input(entity target, string inputName, string dataString, entity activator);
	/** Returns true/false depending on if the entity is an AI character.

	@param entityToCheck specifies the entity to check.*/
	bool isAI(entity entityToCheck);
	/** Returns true/false depending on if the entity is alive.

	@param entityToCheck specifies the entity to check.*/
	bool isAlive(entity entityToCheck);
	/** Returns true/false depending on if the entity is in "god" mode.

	@param entityToCheck specifies the entity to check.*/
	bool isGodMode(entity entityToCheck);
	/** Returns true/false depending on if the entity is a player.

	@param entityToCheck specifies the entity to check.*/
	bool isPlayer(entity entityToCheck);
	/** Returns true/false depending on if the entity is either a player, or AI character.

	@param entityToCheck specifies the entity to check.*/
	bool isSentient(entity entityToCheck);
	/** Returns true/false depending on if the entity is a bot.

	@param entityToCheck specifies the entity to check.*/
	bool isBot(entity entityToCheck);
} entsAPI_t;
var entsAPI_t ents;

/* Game library */
typedef struct
{
	void LoadNextMap(void);
	void CleanUpMap(void);
	string GetMap(void);
	string GetNextMap(void);
	void SetSpawnPoint(string);
	void TeleportToSpawn(entity);
} gameAPI_t;
var gameAPI_t game;

/* MOTD library */
typedef struct
{
	void LoadDefault(void);
	void LoadFromFile(string);
} motdAPI_t;
var motdAPI_t motd;

/* MOTD library */
typedef struct
{
	string GetInventory(entity);
	int GetReserveAmmo(entity, int);
	bool MaxAmmo(entity, int);
	int TotalActors(void);
	int TotalActorsOnTeam(int);

	float AimAtPos(entity, vector);
	float MoveToPos(entity, vector);
	bool CanSee(entity, entity);
	bool CanShoot(entity, vector, vector);
	bool ClearEnemy();
	entity FindCoverNode(entity);
} actorAPI_t;
var actorAPI_t actor;

typedef struct
{
	/** Applies damage to a given entity.
	Requires the use of damageDef/entityDef since we're run out of parameters in QuakeC.

	@param targetEnt is the entity receiving the damage.
	@param inflictingEnt is the entity causing the damage (e.g. a projectile, rocket)
	@param attackingEnt is the entity owning up to the damage.
	@param damageDef is the damageDef containing all the info, including damage points
	@param damageOrigin is the location where the damage comes from.
	@param damageDir is the direction the damage is coming from.
	@param hitLocation is the final hit location, where the damage is applied. */
	void Damage(entity targetEnt, entity inflictingEnt, entity attackingEnt, string damageDef, vector damageOrigin, vector damageDir, vector hitLocation);
	/** Does damage to all entities within a specified radius with a linear falloff.
	If a negative damageMax value is supplied, then no collision checks will be performed.
	So radiusDamage calls will not be obstructed by level or entity geometry.

	@param damageCenter is the location of the center, at which the wave originates.
	@param damageRange is the radius (in game units) of the wave.
	@param damageMax is the maximum damage that can be done by this wave.
	@param damageMin is the minimum amount of damage done, at the very edge.
	@param attackingEnt is the entity owning up to the damage.
	@param attackingEnt is the entity owning up to the damage. */
	void RadiusDamage(vector damageCenter, float damageRange, int damageMin, int damageMax, entity attackingEnt, string damageDef);
	/** Lets everyone in the game know that something, or something, has passed.

	@param targetName is the entity that has passed away.
	@param attackerName is responsible. Can be empty.
	@param weaponDef is the weapon used. Can be empty.
	@param meansOfDeath is the additional means. Could mean something extra. */
	void Obituary(string targetName, string attackerName, string weaponDef, string meansOfDeath);
} combatAPI_t;
var combatAPI_t combat;

/** @} */ // end of multiprogs

__variant
linkToServerProgs(string funcName)
{
	static void empty(void)
	{
		print("Called unimplemented server-side API call.\n");
		breakpoint();
	}

	void *func = externvalue(0, funcName);

	if (func) {
		return ((__variant)func);
	} else {
		return (empty);
	}
}

void
_server_main(void)
{
	game.LoadNextMap = linkToServerProgs("SVPF_game_LoadNextMap");
	game.CleanUpMap = linkToServerProgs("SVPF_game_CleanUpMap");
	game.GetMap = linkToServerProgs("SVPF_game_GetMap");
	game.GetNextMap = linkToServerProgs("SVPF_game_GetNextMap");
	game.SetSpawnPoint = linkToServerProgs("SVPF_game_SetSpawnPoint");
	game.TeleportToSpawn = linkToServerProgs("SVPF_game_TeleportToSpawn");

	combat.Damage = linkToServerProgs("SVPF_combat_Damage");
	combat.RadiusDamage = linkToServerProgs("SVPF_combat_RadiusDamage");
	combat.Obituary = linkToServerProgs("SVPF_combat_Obituary");

	ents.Create = linkToServerProgs("spawnClass");
	ents.ChangeToClass = linkToServerProgs("changeClass");
	ents.Precache = linkToServerProgs("EntityDef_Precache");
	ents.Input = linkToServerProgs("sendInput");
	ents.isAI = linkToServerProgs("isAI");
	ents.isAlive = linkToServerProgs("isAlive");
	ents.isGodMode = linkToServerProgs("isGodMode");
	ents.isPlayer = linkToServerProgs("isPlayer");
	ents.isSentient = linkToServerProgs("isSentient");

	actor.GetInventory = linkToServerProgs("SVPF_actor_GetInventory");
	actor.GetReserveAmmo = linkToServerProgs("SVPF_actor_GetReserveAmmo");
	actor.MaxAmmo = linkToServerProgs("SVPF_actor_MaxAmmo");
	actor.TotalActors = linkToServerProgs("SVPF_actor_TotalActors");
	actor.TotalActorsOnTeam = linkToServerProgs("SVPF_actor_TotalActorsOnTeam");
	actor.MoveToPos = linkToServerProgs("SVPF_actor_MoveToPos");

	exists.InMap = linkToServerProgs("SVPF_exists_InMap");
	exists.InVFS = linkToServerProgs("SVPF_exists_InVFS");
	exists.InPVS = linkToServerProgs("SVPF_exists_InPVS");

	motd.LoadDefault = linkToServerProgs("MOTD_LoadDefault");
	motd.LoadFromFile = linkToServerProgs("MOTD_LoadFromFile");

	util.TimeToString = linkToServerProgs("SVPF_util_TimeToString");
}
