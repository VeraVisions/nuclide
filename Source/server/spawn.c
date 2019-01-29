/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

float Spawn_PlayerRange(entity spot) {
	entity pl;
	float bestdist;
	float dist;

	bestdist = 9999999;

	for (pl = world; (pl = find(pl, classname, "player"));) {
		if (pl->health <= 0) {
			continue;
		}
		dist = vlen(spot.origin - pl.origin);
		if (dist < bestdist) {
			bestdist = dist;
		}
	}

	return bestdist;
}

entity Spawn_SelectRandom(string cname) 
{
	static entity lastspot;
	entity spot = lastspot;

	for (int i = random(1, 5); i > 0; i--) {
		spot = find(spot, classname, cname);
	}

	if (spot == __NULL__) {
		spot = find(spot, classname, cname);
	}

	entity eFirstSpot = spot;
	do {
		if (spot) {
			if (Spawn_PlayerRange(spot) > 128) {
				if (spot.origin == [0,0,0]) {
					spot = find(spot, classname, cname);
					continue;
				}
				lastspot = spot;
				return spot;
			}
		}
		spot = find(spot, classname, cname);
	} while (spot != eFirstSpot);

	if (!spot) {
		lastspot = spot;
		return spot;
	}

	// We still haven't found one
	if (spot == __NULL__) {
		error(sprintf("Spawn_SelectRandom: no %s on level", cname));
		return world;
	}

	lastspot = spot;
	return spot;
}
