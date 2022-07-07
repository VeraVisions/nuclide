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

/* entity update identifiers */
enum
{
	ENT_NONE,
	ENT_ENTITY,
	ENT_ENTITYRENDERABLE,
	ENT_SURFPROP,
	ENT_PHYSICS,
	ENT_MONSTER,
	ENT_TALKMONSTER,
	ENT_PLAYER,
	ENT_SPECTATOR,
	ENT_AMBIENTSOUND,
	ENT_DLIGHT,
	ENT_PROJECTEDTEXTURE,
	ENT_FOGCONTROLLER,
	ENT_ENVLASER,
	ENT_PARTSYSTEM,
	ENT_SPRITE,
	ENT_SPRAY,
	ENT_DECAL,
	ENT_OLDCAMERA,
	ENT_MONITOR,
	ENT_VEHICLE,
	ENT_VEH_TANKMORTAR,
	ENT_VEH_4WHEEL,
	ENT_PROPROPE,
	ENT_BUBBLES,
	ENT_SEPARATOR,
};


/*
=================
Entity_FindClosest

Returns the closest point entity of a given classname.
world means it failed. most likely.
=================
*/
entity Entity_FindClosest(entity target, string cname) {
	entity best = world;
	float bestdist;
	float dist;

	bestdist = 9999999;

	for (entity e = world; (e = find(e, classname, cname));) {
		dist = vlen(target.origin - e.origin);

		if (dist < bestdist) {
			bestdist = dist;
			best = e;
		}
	}

	return best;
}

/*
=================
Entity_SelectRandom

Returns a random entity of a given classname.
Check for world at all times. If world is returned then the given classname
will most likely never return anything valid.
=================
*/
entity Entity_SelectRandom(string cname) 
{
	entity spot = world;
	float max = 0;

	/* count our max count */
	for (entity e = world;(e = find(e, ::classname, cname));) {
		max++;
	}

	/* immediately exit out */
	if (max == 0) {
		print(sprintf("^1Error: %s is not present on this map.\n", cname));
		return __NULL__;
	}

	/* select a random point */
	for (int i = random(1, max); i > 0; i--) {
		spot = find(spot, classname, cname);
	}

	/* we might end up not finding anything, wrap around? */
	if (spot == __NULL__) {
		spot = find(spot, classname, cname);
	}

	/* we should have returned something valid now */
	return spot;
}
