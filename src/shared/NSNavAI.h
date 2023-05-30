/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
_NSNavAI_Log(string msg)
{
	if (autocvar_ai_debugNav == true)
		print(sprintf("%f %s\n", time, msg));
}
#define NSNavAI_Log(...) _NSNavAI_Log(sprintf(__VA_ARGS__))

#ifndef MAX_AMMO_TYPES
#define MAX_AMMO_TYPES 16
#endif

/** This entity class represents a moving/pathfinding object.
It knows how to deal with waypoint based nodes and possibly other
types of pathfinding in the future.
*/
class
NSNavAI:NSSurfacePropEntity
{
private:
#ifdef SERVER
	/* pathfinding */
	int m_iNodes;
	int m_iCurNode;
	nodeslist_t *m_pRoute;
	vector m_vecLastNode;
	vector m_vecTurnAngle;

	/* These are defined in side defs\*.def, ammo_types and ammo_names */
	int m_iAmmoTypes[MAX_AMMO_TYPES];
#endif

public:
	void NSNavAI(void);

#ifdef SERVER
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void RestoreComplete(void);

	/* methods we'd like others to override */
	/** Returns if this class is capable of crouching. */
	virtual bool CanCrouch(void);
	/** Returns the current movement values in a single vector (x = fwd, y = rt, y = up) */
	nonvirtual vector GetRouteMovevalues(void);
	/** Returns the current movement direction. */
	nonvirtual vector GetRouteDirection(void);
	/** Called when the object is done moving to its destination. */
	virtual void RouteEnded(void);
	/** When called, will wipe any memory of an ongoing route. */
	virtual void RouteClear(void);
	/** Internal use only. Called every frame to see our route progression. */
	virtual void CheckRoute(void);
	/** When called, will plot a route to a given world coordinate and start moving. */
	virtual void RouteToPosition(vector);
#endif
};
