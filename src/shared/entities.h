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

/** Entity update identifiers */
typedef enum
{
	ENT_NONE = 0,	/**< invalid, but reserved. */
	ENT_ENTITY,	/**< of type NSEntity */
	ENT_ENTITYRENDERABLE, /**< of type NSRenderableEntity */
	ENT_ENTITYPROJECTILE, /**< of type NSProjectile */
	ENT_SURFPROP, /**< of type NSSurfacePropEntity */
	ENT_PHYSICS,	/**< of type NSPhysicsEntity */
	ENT_MONSTER,	/**< of type NSMonster */
	ENT_TALKMONSTER,	/**< of type NSTalkMonster */
	ENT_PLAYER,	/**< of type NSClientPlayer */
	ENT_WEAPON, /**< of type NSWeapon */
	ENT_SPECTATOR,	/**< of type NSClientSpectator */
	ENT_PORTAL,		/**< of type NSPortal */
	ENT_AMBIENTSOUND,	/**< of type ambient_generic */
	ENT_BEAM,	/**< of type env_beam */
	ENT_DLIGHT,	/**< of type light_dynamic */
	ENT_PROJECTEDTEXTURE, /**< of type env_projectedtexture */
	ENT_SPOTLIGHT, /**< of type point_spotlight */
	ENT_FOG,			/*<< of type env_fog */
	ENT_STEAM,
	ENT_FOGCONTROLLER, /**< of type env_fog_controller */
	ENT_LASER,	/**< of type env_laser */
	ENT_PARTSYSTEM,	/**< of type info_particle_system */
	ENT_SPRITE,	/**< of type env_sprite */
	ENT_GLOW, /**< of type env_glow */
	ENT_SPRAY,	/**< of type spray */
	ENT_DECAL,	/**< of type infodecal */
	ENT_OLDCAMERA,	/**< of type trigger_camera */
	ENT_MONITOR,	/**< of type func_monitor */
	ENT_VEHICLE,	/**< Reserved. */
	ENT_VEH_BRUSH,	/**< of type func_vehicle */
	ENT_VEH_TANKMORTAR,	/**< of type func_tankmortar */
	ENT_VEH_4WHEEL,	/**< of type prop_vehicle_driveable */
	ENT_PROPROPE,	/**< of type prop_rope */
	ENT_PHYSROPE,	/**< of type phys_rope */
	ENT_BUBBLES,	/**< of type env_bubbles */
	ENT_CONVEYOR,	/**< of type func_conveyor */
	ENT_WAYPOINT,	/**< of type info_waypoint */
	ENT_PUSH,		/**< of type trigger_push */
	ENT_SEPARATOR,	/**< This is a separator. This separator is used by you to add game-specific networked entities. When declaring your own entity-update types, you want the first value to equal ENT_SEPARATOR at all times to ensure you'll not be overriding existing slots. */
} entupdate_t;


/** Returns the closest point entity of a given classname.
Returns 'world' or '__NULL__' if it fails to find anything. */
entity
Entity_FindClosest(entity startTarget, string className)
{
	entity best = world;
	float bestdist;
	float dist;

	bestdist = 9999999;

	for (entity e = world; (e = find(e, classname, className));) {
		dist = vlen(startTarget.origin - e.origin);

		if (dist < bestdist) {
			bestdist = dist;
			best = e;
		}
	}

	return best;
}


/** Returns a random entity of a given classname.
If world or '__NULL__' is returned, then the given classname is not present in the map. */
entity
Entity_SelectRandom(string className)
{
	entity spot = world;
	int max = 0i;

	/* count the total number of entities of the desired class */
	for (entity e = world; (e = find(e, ::classname, className));) {
		max++;
	}

	/* immediately exit out if we've got none */
	if (max < 1i) {
		print(sprintf("^1Error: %s is not present on this map.\n", className));
		return __NULL__;
	}

	/* select a random point */
	for (int i = random(1, max); i > 0; i--) {
		spot = find(spot, ::classname, className);
	}

	/* we might end up not finding anything, wrap around? */
	if (spot == __NULL__) {
		spot = find(spot, ::classname, className);
	}

	/* we should have returned something valid now */
	return spot;
}
