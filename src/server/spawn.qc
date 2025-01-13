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

/*
=================
Spawn_ObserverCam

Find a spawnpoint for spectators and set origin and angle of the 'pl' target.
=================
*/
void
Spawn_ObserverCam(ncPlayer pl)
{
	entity eTarget;
	entity eCamera = find(world, ::classname, "trigger_camera");

	if (eCamera) {
		pl.origin = eCamera.origin;
		
		if (eCamera.target) {
			eTarget = find(world, ::targetname, eCamera.target);
			if (eTarget) {
				pl.angles = vectoangles(eTarget.origin - eCamera.origin);
				//pl.angles[0] *= -1;
			}
		}
	} else {
		/* can't find a camera? CS chooses to pick a spawnpoint instead */
		eCamera = find (world, ::classname, "info_player_start");
		
		if (eCamera) {
			pl.origin = eCamera.origin;
			pl.angles = eCamera.angles;
		}
	}

	Client_FixAngle(pl, pl.angles);
}

/*
=================
Spawn_PlayerRange

Returns how close the closest player is to any given spot.
=================
*/
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

	for (pl = world; (pl = findfloat(pl, takedamage, DAMAGE_AIM));) {
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

/*
=================
Spawn_SelectRandom

Return a point in the map that's both 'random' and also not too close to any
living player.
=================
*/
entity Spawn_SelectRandom(string cname) 
{
	static entity lastspot;
	entity spot = lastspot;

	float max = 0;

	/* check if _any_ entity of this type exists */
	entity testcase = find(world, ::classname, cname);

	/* count our max count */
	for (entity e = world;(e = find(e, ::classname, cname));) {
		max++;
	}

	if (max <= 0) {
		print(sprintf("^1Error: %s is not present on this map.\n", cname));
		return __NULL__;
	}

	for (int i = random(1, max); i > 0; i--) {
		spot = find(spot, classname, cname);
	}

	if (spot == __NULL__) {
		spot = find(spot, classname, cname);
	}

	entity firstspot = spot;
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
	} while (spot != firstspot);

	if (!spot) {
		lastspot = spot;
		return spot;
	}

	/* still not found any */
	if (spot == __NULL__) {
		error(sprintf("Spawn_SelectRandom: no %s on level", cname));
		return (__NULL__);
	}

	lastspot = spot;
	return spot;
}


void
Spawn_TeleportToSpawn(entity targetEnt)
{
	string desiredSpawn = teams.SpawnPoint((int)targetEnt.team);

	/* singleplayer */
	if (STRING_SET(startspot)) {
		targetEnt.origin = Landmark_GetSpot();
		setorigin_safe(targetEnt, targetEnt.origin);
		return;
	}

	/* if not set, don't bother teleporting */
	if (!STRING_SET(desiredSpawn)) {
		return;
	}

	entity spawnPoint = Spawn_SelectRandom(desiredSpawn);

	if (spawnPoint) {
		targetEnt.origin = spawnPoint.origin;
		targetEnt.angles = spawnPoint.angles;
		setorigin_safe(targetEnt, targetEnt.origin);
		return;
	}

	spawnPoint = Spawn_SelectRandom("info_player_start");

	if (spawnPoint) {
		targetEnt.origin = spawnPoint.origin;
		targetEnt.angles = spawnPoint.angles;
		setorigin_safe(targetEnt, targetEnt.origin);
	}
}
