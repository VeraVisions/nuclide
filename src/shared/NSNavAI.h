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

var bool autocvar_ai_debugNav = false;
void
_NSNavAI_Log(string className, string functionName, float edictNum, string warnMessage)
{
	if (autocvar_g_developerTimestamps)
		printf("^9%f ^5%s (%d) ^7: %s\n", time, functionName, edictNum, warnMessage);
	else
		printf("^5%s (%d) ^7: %s\n", functionName, edictNum, warnMessage);
}
#define NSNavAI_Log(...) _NSNavAI_Log(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))

#ifndef MAX_AMMO_TYPES
#define MAX_AMMO_TYPES 16
#endif


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

/** This entity class represents a moving/pathfinding object.
It knows how to deal with waypoint based nodes and possibly other
types of pathfinding in the future.
*/
class
NSNavAI:NSSurfacePropEntity
{

public:
	void NSNavAI(void);

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
	/** Gives ammo up of a specified type. Returns `false` when impossible. */
	nonvirtual bool GiveAmmo(int, int);
	/** Uses ammo up of a specified type. Returns `false` when impossible. */
	nonvirtual bool UseAmmo(int, int);

	/* inventory handling */
	/** Adds a named NSItem to the inventory. Returns `false` when impossible. */
	nonvirtual bool GiveItem(string);
	/** Removes a named NSItem from the inventory Returns `false` when impossible. */
	nonvirtual bool RemoveItem(string);
	/** Adds the specified NSItem to the inventory. Returns `false` when impossible. */
	nonvirtual bool AddItem(NSItem);
	/** Returns `true` or `false` depending on if the entity has the named item. */
	nonvirtual bool HasItem(string);

#ifdef SERVER
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void RestoreComplete(void);
	virtual void DebugDraw(void);

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
	virtual void CheckRoute(void);
	/** When called, will plot a route to a given world coordinate and start moving. */
	virtual void RouteToPosition(vector);
	/** When called, will plot a route to a given world coordinate and start moving, ignoring any links that contain the given link flags. */
	virtual void RouteToPositionDenyFlags(vector, int);
	/** When called, will start following a path_corner */
	virtual void ChasePath(string startPath);
	/** Internal use only. Called every frame to see our route progression. */
	virtual void CheckRoute_Path(void);
	/** Overridable: Called when the entity is ready to move. When overridden, will no longer move until super function is called, or physics is handled within. */
	virtual void Physics_Run(void);
#endif

private:
#ifdef SERVER
	/* pathfinding */
	int m_iNodes;
	int m_iCurNode;
	nodeslist_t *m_pRoute;
	vector m_vecLastNode;
	vector m_vecTurnAngle;
	string m_pathTarget;
	NSEntity m_pathEntity;
	float _m_flRouteGiveUp;
	vector _m_vecRoutePrev;
	vector m_vecRouteEntity;
	entity m_eFollowing;
	float m_flMoveSpeedKey;
#endif

	/* These are defined in side defs\*.def, ammo_types and ammo_names */
	int m_iAmmoTypes[MAX_AMMO_TYPES];
	NSItem m_itemList;
	float activeweapon;
};
