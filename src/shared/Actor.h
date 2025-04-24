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

/* TODO: serverinfo based checks for prediction reasons */
var bool autocvar_g_infiniteAmmo = false;

var bool autocvar_ai_debugNav = false;
void
_ncActor_Log(string className, string functionName, float edictNum, string warnMessage)
{
	if (autocvar_g_logTimestamps)
		printf("^9%f ^5%s (%d) ^7: %s\n", time, functionName, edictNum, warnMessage);
	else
		printf("^5%s (%d) ^7: %s\n", functionName, edictNum, warnMessage);
}
#define ncActor_Log(...) if (autocvar_g_logLevel >= LOGLEVEL_DEBUG) _ncActor_Log(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))

/* for AI identification purposes */
typedef enum
{
	WPNTYPE_INVALID,	/* no logic */
	WPNTYPE_RANGED,		/* will want to keep their distance mostly */
	WPNTYPE_THROW,		/* has to keep some distance, but not too far */
	WPNTYPE_CLOSE,		/* have to get really close */
	WPNTYPE_FULLAUTO,	/* for things that need to be held down */
	WPNTYPE_SEMI		/* semi automatic */
} weapontype_t;

/** This entity class represents an object with choreographed/free-form movement.
It knows how to deal with waypoint based nodes and possibly other
types of pathfinding in the future.

# KEYS

- "snd_stepladder" : Sound to play when climbing a ladder.
- "snd_death" : Sound to play upon death.
- "snd_fall" : Sound to play upon taking falldamage.
- "snd_painSmall" : Sound to play when their health is still above 75%.
- "snd_painMedium" : Sound to play when their health is still above 50%.
- "snd_painLarge" : Sound to play when their health is still above 25%.
- "snd_painHuge" : Sound to play when their health is below 25%.
- "snd_landSoft" : Sound to play when landing from any height.
- "snd_landHard" : Sound to play upon a fall, although not damaging.
- "snd_hitArmor" : Sound to play when receiving damage and having some armor protection.
- "snd_hitFlesh" : Sound to play when receiving damage and having no armor protection.
- "snd_airGasp" : Sound to play when coming back up from under water.
- "snd_noAir" : Sound to play when struggling to breathe under water.
- "snd_teleportExit" : Sound to play when having exited a teleporter.
- "snd_teleportStart" : Sound to play when having entered a teleporter.
- "snd_burn" : Sound to play whenever incremental burn damage occurs.
- "snd_healthtake" : Sound to play when receiving a health increase.
- "snd_waterEnter" : Sound to play when entering water.
- "snd_waterExit" : Sound to play when exiting water.

# INPUTS

- "UseItem" : Uses a named item in the actor their inventory.
- "GiveItem" : Gives a named item to the actor.
- "GiveAmmo" : Gives a named ammo type with a specific amount. Two arguments: "ammoTypeName" "count"
- "ChangeMindset" : Tells the actor to choose a different type of schedule.
- "PerformSchedule" : Performs a named schedule, defined in `<gamedir>/decls/schedules/`.
- "WalkToTarget" : Instruct the actor to walk to the last set target.
- "RunToTarget" : Instruct the actor to run to the last set target.
- "CrouchToTarget" : Instruct the actor to crouch to the last set target.
- "ProneToTarget" : Instruct the actor to prone to the last set target.
- "TargetNearestPlayer" : Target the nearest player from the actor's current position.
- "GoToCover" : Plot a route to promptly take cover.
- "GoToSpotInRadius" : Plot a route to an empty spot within a certain radius of the current position.
- "AvoidSpotInRadius" : Plot a route to a spot outside of a specified radius from the current position.
- "TurnToRandomYaw" : Turns the actor to a random direction.
- "GoForward" : Instruct to keep going forward.

@ingroup baseclass
*/
class
ncActor:ncSurfacePropEntity
{

public:
	void ncActor(void);

	/** Overridable: Returns whether the client can sprint, with the command +sprint */
	virtual bool CanSprint(void);
	/** Overridable: Returns whether the client can prone, with the commands +prone and goprone */
	virtual bool CanProne(void);
	/** Overridable: Returns whether the client can crouch, with the commands +crouch and gocrouch */
	virtual bool CanCrouch(void);
	/** Overridable: Returns whether the client can lean, with the commands +leanleft and +leanright */
	virtual bool CanLean(void);

	/** Overridable: Returns the desired maximum forward movement speed. */
	virtual float GetForwardSpeed(void);
	/** Overridable: Returns the desired maximum side movement speed. */
	virtual float GetSideSpeed(void);
	/** Overridable: Returns the desired maximum backwardss movement speed. */
	virtual float GetBackSpeed(void);
	

	nonvirtual float GetStamina(void);

	/** Returns `true` when the entity is ducked/crouching */
	nonvirtual bool IsCrouching(void);
	/** Returns `true` when the entity is ducked/crouching */
	nonvirtual bool IsProne(void);
	/** Returns `true` when the entity is standing, walking. */
	nonvirtual bool IsStanding(void);
	/** Returns `true` when the entity is running. */
	nonvirtual bool IsSprinting(void);
	/** Returns `true` when the entity is leaning */
	nonvirtual bool IsLeaning(void);

	/* ammo handling */
	/** Returns whether the specified type is maxed out. */
	nonvirtual bool MaxAmmo(int);
	/** Gives ammo up of a specified type. Returns `false` when impossible. */
	nonvirtual bool GiveAmmo(int, int);
	/** Uses ammo up of a specified type. Returns `false` when impossible. */
	nonvirtual bool UseAmmo(int, int);
	/** Returns whether or not the entity has enough of the specified ammo and type. */
	nonvirtual bool HasAmmo(int, int);
	/** Returns the amount of reserve ammo of a given type. */
	nonvirtual int GetReserveAmmo(int);

	/* inventory handling */
	/** Adds a named ncItem to the inventory. Returns `false` when impossible. */
	nonvirtual bool GiveItem(string);
	nonvirtual bool GiveExactItem(ncItem);
	/** Removes a named ncItem from the inventory Returns `false` when impossible. */
	nonvirtual bool RemoveItem(string);
	/** Adds the specified ncItem to the inventory. Returns `false` when impossible. */
	nonvirtual bool AddItem(ncItem);
	/** Returns `true` or `false` depending on if the entity has the named item. */
	nonvirtual ncItem GetItem(string);
	/** Returns `true` or `false` depending on if the entity has the named item. */
	nonvirtual bool HasItem(string);
	/** Returns `true` or `false` depending on if the entity has the exact item. */
	nonvirtual bool HasExactItem(ncItem);
	/** Removes all items from the inventory. Returns `false` when already empty. */
	nonvirtual bool RemoveAllItems(bool);
	/** Removes all weapons from the inventory. Returns `false` when already clear. */
	nonvirtual bool RemoveAllWeapons(void);
	/** Returns the name of the current weapon. E.g. "weapon_foobar" */
	nonvirtual string GetCurrentWeapon(void);
	/** Switches the entity to use the desired weapon. */
	nonvirtual void SwitchToWeapon(string);
	/** Switches the entity to use the desired weapon. */
	nonvirtual void SwitchToExactWeapon(ncWeapon);
	nonvirtual void SwitchToBestWeapon(bool);

	nonvirtual void LaunchProjectile(string, bool, float);
	nonvirtual bool PlantCharge(string);

	/** Returns the first weapon in the chain, while ensuring the inventory is sorted. */
	virtual ncWeapon SortWeaponChain(void);
	/** Retrieve the 'next' weapon in the inventory, sorted by SortWeaponChain(). */
	nonvirtual ncWeapon GetNextWeapon(void);
	/** Retrieve the 'previous' weapon in the inventory, sorted by SortWeaponChain(). */
	nonvirtual ncWeapon GetPreviousWeapon(void);
	/** Retrieve the 'last' weapon they had chosen. If not valid, returns the next best. */
	nonvirtual ncWeapon GetLastWeapon(void);

	virtual void AddedItemCallback(ncItem);
	virtual void SpawnKey(string,string);
	virtual void ReloadCachedAttributes(void);

#ifdef SERVER
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void RestoreComplete(void);
	virtual void Spawned(void);
	virtual void Input(entity, string, string);
	virtual void DebugDraw(void);

	/** Overridable: Called regularily to select a new schedule to perform. */
	virtual void SelectNewSchedule(void);
	nonvirtual void ThinkSchedules(void);

	/** Forces a named schedule to be performed. */
	nonvirtual bool CancelSchedule(void);
	nonvirtual void PerformSchedule(string);
	nonvirtual void MessageSchedule(string);
	nonvirtual bool IsPerforming(void);
	
	nonvirtual int PathNodeCount(void);
	nonvirtual int PathCurrentNode(void);
	nonvirtual vector PathDestination(void);

	/** Call to make a corpse of this actor. */
	nonvirtual void MakeCorpse(float deathSequence);

	/* methods we'd like others to override */
	/** Returns if this class is capable of crouching. */
	virtual bool CanCrouch(void);
	/** Returns the current movement values in a single vector (x = fwd, y = rt, y = up) */
	nonvirtual vector GetRouteMovevalues(void);
	/** Returns the current movement direction. */
	nonvirtual vector GetRouteDirection(void);
	/** Sets the scale on the movement before physics are run. This is used to simulate walking. 0 is treated as 1 (no change).*/
	nonvirtual void SetMoveSpeedScale(float);
	/** Returns the movement speed scale. */
	nonvirtual float GetMoveSpeedScale(void);

	/** Called when the object is done moving to its destination. */
	virtual void RouteEnded(void);
	/** When called, will wipe any memory of an ongoing route. */
	virtual void RouteClear(void);
	/** Internal use only. Called every frame to see our route progression. */
	virtual void CheckRouteProgression(void);
	/** When called, will plot a route to a given world coordinate and start moving. */
	virtual void RouteToPosition(vector);
	/** When called, will plot a route to a given world coordinate and start moving, ignoring any links that contain the given link flags. */
	virtual void RouteToPositionDenyFlags(vector, int);
	/** When called, will start following a path_corner */
	virtual void ChasePath(string startPath);
	/** Internal use only. Called every frame to see our route progression. */
	virtual void CheckRouteProgression_Path(void);
	/** Overridable: Called when the entity is ready to move. When overridden, will no longer move until super function is called, or physics is handled within. */
	virtual void Physics_Run(void);
#endif

private:

#ifdef SERVER
	/* pathfinding */
	int m_pathfindingNodeCount;
	int m_pathfindingCurrentNode;
	nodeslist_t *m_pathfindingGraph;
	vector m_pathfindingDestination;
	string m_pathTarget;
	ncEntity m_pathEntity;
	float m_timeUntilDroppingRoute;
	vector m_pathfindingLastPos;
	entity m_followingEntity;
	float m_moveSpeedKey;
	string m_mindset;
	entity m_hook;
#endif

	/* These are defined in side defs\*.def, ammo_types and ammo_names */
	int m_ammoTypes[MAX_AMMO_TYPES];
	float activeweapon;
	NETWORKED_FLOAT(m_itemStart)
	NETWORKED_FLOAT(m_currentStamina)
	float m_weaponCookingTime;

	/* networking/prediction */
	ncWeapon m_activeWeapon_net;

	/* non-state heavy cached values, reloaded frequently. */
	string m_sndStepLadderLeft;
	string m_sndStepLadderRight;
	string m_sndDeath;
	string m_sndFall;
	string m_sndPainSmall;
	string m_sndPainMedium;
	string m_sndPainLarge;
	string m_sndPainHuge;
	string m_sndLandSoft;
	string m_sndLandHard;
	string m_sndHitArmor;
	string m_sndHitFlesh;
	string m_sndAirGaspHeavy;
	string m_sndAirGaspLight;
	string m_sndNoAir;
	string m_sndTeleportExit;
	string m_sndTeleportStart;
	string m_sndWaterExit;
	string m_sndWaterEnter;
	string m_sndWaterWade;
	string m_sndWaterSwim;
	string m_sndBurn;
	string m_sndHealthtake;
	string m_sndUseDeny;
	string m_sndUseSuccess;
};

/* for now here to make debugging easier */
.ncItem m_itemList;
.ncWeapon m_activeWeapon;
.ncWeapon m_firstWeapon;
.bool _isActor;

void ncActor_ListInventory(ncActor);
