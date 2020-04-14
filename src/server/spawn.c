/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

void
Spawn_ObserverCam(void)
{
	entity eTarget;

	// Go find a camera if we aren't dead
	entity eCamera = find(world, ::classname, "trigger_camera");

	if (eCamera) {
		self.origin = eCamera.origin;
		
		if (eCamera.target) {
			eTarget = find(world, ::targetname, eCamera.target);
			if (eTarget) {
				self.angles = vectoangles(eTarget.origin - eCamera.origin);
				self.angles[0] *= -1;
			}
		}
	} else {
		// Can't find a camera? Just do this lazy thing, CS seems to do the same
		eCamera = find (world, ::classname, "info_player_start");
		
		if (eCamera) {
			self.origin = eCamera.origin;
			
			if (eCamera.target) {
				eTarget = find(world, ::targetname, eCamera.target);
				if (eTarget) {
					self.angles = vectoangles(eTarget.origin - eCamera.origin);
					self.angles[0] *= -1;
				}
			}
		}
	}

	Client_FixAngle(self, self.angles);
}

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
