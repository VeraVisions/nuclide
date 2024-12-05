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

/* used to keep track of decl across different classnames */
.string declclass;

/** @defgroup entities Entities
    @brief Objects within the game world, serving various functions.

Entities are what we call instantiated objects within our game world.
They belong to a class, which can be read from their `.classname` field
at any given time.

In Nuclide, the lowest entity class you're meant to instantiate is ncEntity.
There are multiple child-classes that do a lot more advanced and or specific
things.

@{
*/

/** Entity update identifiers */
typedef enum
{
	ENT_NONE = 0,	/**< invalid, but reserved. */
	ENT_ENTITY,	/**< of type ncEntity */
	ENT_SOUND,	/**< of type ncSound */
	ENT_PMOVEVARS, /**< of type ncPMoveVars */
	ENT_ENTITYRENDERABLE, /**< of type ncRenderableEntity */
	ENT_ENTITYPROJECTILE, /**< of type ncProjectile */
	ENT_SURFPROP, /**< of type ncSurfacePropEntity */
	ENT_PHYSICS,	/**< of type ncPhysicsEntity */
	ENT_MONSTER,	/**< of type ncMonster */
	ENT_TALKMONSTER,	/**< of type ncTalkMonster */
	ENT_SPEAKER, /**< of type speaker */
	ENT_PLAYER,	/**< of type ncPlayer */
	ENT_ITEM, /**< of type ncItem */
	ENT_WEAPON, /**< of type ncWeapon */
	ENT_RAGDOLL, /**< of type ncRagdoll */
	ENT_SPECTATOR,	/**< of type ncSpectator */
	ENT_PORTAL,		/**< of type ncPortal */
	ENT_AMBIENTSOUND,	/**< of type ambient_generic */
	ENT_BEAM,	/**< of type env_beam */
	ENT_FUNNEL, /**< of type env_funnel */
	ENT_SMOKER, /**< of type env_smoker */
	ENT_DLIGHT,	/**< of type light_dynamic */
	ENT_PROJECTEDTEXTURE, /**< of type env_projectedtexture */
	ENT_SPOTLIGHT, /**< of type point_spotlight */
	ENT_FOG,			/**< of type env_fog */
	ENT_STEAM,	/**< of type env_steam */
	ENT_FOGCONTROLLER, /**< of type env_fog_controller */
	ENT_CASCADELIGHT, /**< of type env_cascade_light */
	ENT_LASER,	/**< of type env_laser */
	ENT_PARTSYSTEM,	/**< of type info_particle_system */
	ENT_SPRITE,	/**< of type env_sprite */
	ENT_GLOW, /**< of type env_glow */
	ENT_SPRAY,	/**< of type ncSpraylogo */
	ENT_DECAL,	/**< of type ncDecal */
	ENT_OLDCAMERA,	/**< of type trigger_camera */
	ENT_MONITOR,	/**< of type func_monitor */
	ENT_VEHICLE,	/**< Reserved. */
	ENT_TRACKTRAIN, /**< of type func_tracktrain */
	ENT_VEH_BRUSH,	/**< of type func_vehicle */
	ENT_VEH_TANKMORTAR,	/**< of type func_tankmortar */
	ENT_VEH_4WHEEL,	/**< of type prop_vehicle_driveable */
	ENT_PROPROPE,	/**< of type prop_rope */
	ENT_PHYSROPE,	/**< of type phys_rope */
	ENT_BUBBLES,	/**< of type env_bubbles */
	ENT_CONVEYOR,	/**< of type func_conveyor */
	ENT_WAYPOINT,	/**< of type info_waypoint */
	ENT_INSTRUCTOR, /**< of type env_instructor_hint */
	ENT_PUSH,		/**< of type trigger_push */
	ENT_SOUNDSCAPE, /**< of type ncSoundScape */
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
		NSError("%S is not present on this map.", className);
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


/** @} */ // end of entities
