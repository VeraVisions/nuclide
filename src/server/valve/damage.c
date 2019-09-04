/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

/* someone dieded */
void
Damage_CastObituary(entity eCulprit, entity eTarget, float weapon, float flags)
{
	/*WriteByte(MSG_BROADCAST, SVC_CGAMEPACKET);
	WriteByte(MSG_BROADCAST, EV_OBITUARY);
	WriteByte(MSG_BROADCAST, num_for_edict(eCulprit) - 1);
	WriteByte(MSG_BROADCAST, num_for_edict(eTarget) - 1);
	WriteByte(MSG_BROADCAST, weapon);
	WriteByte(MSG_BROADCAST, flags);
	msg_entity = self;
	multicast([0,0,0], MULTICAST_ALL);*/
}

/* generic function that applies damage, pain and suffering */
void
Damage_Apply(entity eTarget, entity eCulprit, float fDmg, vector pos, int a)
{
	if (eTarget.flags & FL_GODMODE) {
		return;
	}

	/* skip armor */
	if (!a)
	if (eTarget.armor && fDmg > 0) {
		float flArmor;
		float flNewDamage;

		flNewDamage = fDmg * 0.2;
		flArmor = (fDmg - flNewDamage) * 0.5;

		if (flArmor > eTarget.armor) {
			flArmor = eTarget.armor;
			flArmor *= (1/0.5);
			flNewDamage = fDmg - flArmor;
			eTarget.armor = 0;
		} else {
			eTarget.armor -= flArmor;
		}
		fDmg = flNewDamage;
	}

	fDmg = rint(fDmg);
	eTarget.health -= fDmg;

	if (fDmg > 0) {
		eTarget.dmg_take = fDmg;
		eTarget.dmg_inflictor = eCulprit;
	} else if (eTarget.max_health && eTarget.health > eTarget.max_health) {
		eTarget.health = eTarget.max_health;
	}

	// Target is dead and a client....
	if (eTarget.health <= 0) {
		if (eTarget.flags & FL_CLIENT) {
			eTarget.deaths++;
			forceinfokey(eTarget, "*deaths", ftos(eTarget.deaths));
		}

		if (eCulprit.flags & FL_CLIENT) {
			if (eTarget == eCulprit) {
				eCulprit.frags--;
			} else {
				eCulprit.frags++;
			}
		}
	}

	entity eOld = self;
	self = eTarget;

	if (self.health <= 0) {
		self.vDeath(trace_surface_id);
	} else {
		self.vPain(trace_surface_id);
	}

	self = eOld;
}

/* physical check of whether or not we can trace important parts of an ent */
float
Damage_CheckTrace(entity eTarget, vector vecHitPos)
{
	/* We're lazy. Who cares */
	if (eTarget.solid == SOLID_BSP) {
		return TRUE;
	}

	traceline(vecHitPos, eTarget.origin, 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vecHitPos, eTarget.origin + [15,15,0], 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vecHitPos, eTarget.origin + [-15,-15,0], 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vecHitPos, eTarget.origin + [-15,15,0], 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vecHitPos, eTarget.origin + [15,-15,0], 1, self);
	if (trace_fraction == 1) {
		return TRUE;
	}

	return FALSE;
}

/* even more pain and suffering, mostly used for explosives */
void
Damage_Radius(vector org, entity attacker, float dmg, float radius, int check)
{
	float new_dmg;
	float dist;
	float diff;
	vector pos;

	for (entity e = world; (e = findfloat(e, takedamage, DAMAGE_YES));) {
		pos[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
		pos[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
		pos[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));

		/* don't bother if it's not anywhere near us */
		dist = vlen(org - pos);
		if (dist > radius) {
			continue;
		}

		/* can we physically hit this thing? */
		if (Damage_CheckTrace(e, org) == FALSE) {
			if (check == TRUE) {
				continue;
			}
		}

		/* calculate new damage values */
		diff = vlen(org - pos);
		diff = (radius - diff) / radius;
		new_dmg = rint(dmg * diff);

		if (diff > 0) {
			Damage_Apply(e, attacker, new_dmg, pos, 0);

			/* approximate, feel free to tweak */
			if (e.movetype == MOVETYPE_WALK) {
				makevectors(vectoangles(e.origin - org));
				e.velocity += v_forward * (new_dmg * 5); 
			}
		}
	}
}
