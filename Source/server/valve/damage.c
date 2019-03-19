/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
Damage_CastOrbituary

Sends a message to the clients to display a death message
=================
*/
void Damage_CastOrbituary(entity eAttacker, entity eTarget, float fWeapon)
{
	WriteByte(MSG_BROADCAST, SVC_CGAMEPACKET);
	WriteByte(MSG_BROADCAST, EV_ORBITUARY);
	WriteByte(MSG_BROADCAST, num_for_edict(eAttacker) - 1);
	WriteByte(MSG_BROADCAST, eAttacker.team);
	WriteByte(MSG_BROADCAST, num_for_edict(eTarget) - 1);
	WriteByte(MSG_BROADCAST, eTarget.team);
	WriteByte(MSG_BROADCAST, fWeapon);
	msg_entity = self;
	multicast([0,0,0], MULTICAST_ALL);
}

/*
=================
Damage_Apply

Generic function that applies damage, pain and suffering
=================
*/
void Damage_Apply(entity eTarget, entity eAttacker, float fDamage, vector vHitPos, int a)
{
	// Apply the damage finally
	if (eTarget.armor && fDamage > 0) {
		float flArmor;
		float flNewDamage;

		flNewDamage = fDamage * 0.2;
		flArmor = (fDamage - flNewDamage) * 0.5;

		if (flArmor > eTarget.armor) {
			flArmor = eTarget.armor;
			flArmor *= (1/0.5);
			flNewDamage = fDamage - flArmor;
			eTarget.armor = 0;
		} else {
			eTarget.armor -= flArmor;
		}
		fDamage = flNewDamage;
	}
	
	fDamage = rint(fDamage);
	eTarget.health -= fDamage;
	
	if (fDamage > 0) {
		eTarget.dmg_take = fDamage;
		eTarget.dmg_inflictor = eAttacker;
	} else if (eTarget.max_health && eTarget.health > eTarget.max_health) {
		eTarget.health = eTarget.max_health;
	}

	// Target is dead and a client....
	if (eTarget.health <= 0) {
		if (eTarget.flags & FL_CLIENT) {
			eTarget.deaths++;
			forceinfokey(eTarget, "*deaths", ftos(eTarget.deaths));
		}

		if ((eTarget.flags & FL_CLIENT) && (eAttacker.flags & FL_CLIENT)) {
			if (eTarget == eAttacker) {
				eAttacker.frags--;
			} else {
				eAttacker.frags++;
			}
			//Damage_CastOrbituary(eAttacker, eTarget, eAttacker.weapon);
		}
	}

	entity eOld = self;
	self = eTarget;

	if (self.health <= 0) {
		self.vDeath(trace_surface_id);
	} else {
		self.vPain(trace_surface_id);
	}

	if (self.iBleeds == TRUE && fDamage > 0) {
		Effect_CreateBlood(vHitPos, [0,0,0]);
	} 

	self = eOld;
}

/*
=================
Damage_CheckAttack

This verifies that the entity is actually able to receive some damage,
from a plain geographical standpoint
=================
*/
float Damage_CheckAttack(entity eTarget, vector vAttackPos)
{
	/* We're lazy. Who cares */
	if (eTarget.solid == SOLID_BSP) {
		return TRUE;
	}
	
	traceline(vAttackPos, eTarget.origin, TRUE, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vAttackPos, eTarget.origin + [15,15,0], TRUE, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vAttackPos, eTarget.origin + [-15,-15,0], TRUE, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vAttackPos, eTarget.origin + [-15,15,0], TRUE, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vAttackPos, eTarget.origin + [15,-15,0], TRUE, self);
	if (trace_fraction == 1) {
		return TRUE;
	}

	return FALSE;
}

/*
=================
Damage_Radius

Even more pain and suffering, mostly used for explosives
=================
*/
void Damage_Radius(vector org, entity eAttacker, float fDamage, float fRadius, int iCheckClip)
{
	for (entity c = world; (c = findfloat(c, takedamage, DAMAGE_YES));) {
		vector vecRealPos;
		vecRealPos[0] = c.absmin[0] + (0.5 * (c.absmax[0] - c.absmin[0]));
		vecRealPos[1] = c.absmin[1] + (0.5 * (c.absmax[1] - c.absmin[1]));
		vecRealPos[2] = c.absmin[2] + (0.5 * (c.absmax[2] - c.absmin[2]));

		float fDist = vlen(org - vecRealPos);
		//vector vPush;

		if (fDist > fRadius) {
			continue;
		}

		if (Damage_CheckAttack(c, org) || iCheckClip == FALSE) {
			float fDiff = vlen(org - vecRealPos);

			fDiff = (fRadius - fDiff) / fRadius;
			fDamage = rint(fDamage * fDiff);

			if (fDiff > 0) {
				Damage_Apply(c, eAttacker, fDamage, vecRealPos, 0);
			}
			
		}
	}
}
