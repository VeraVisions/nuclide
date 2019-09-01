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

/*
=================
Damage_CastOrbituary

Sends a message to the clients to display a death message
=================
*/
void Damage_CastOrbituary(entity eAttacker, entity eTarget, float fWeapon, float fHeadShot)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_ORBITUARY);
	WriteByte(MSG_MULTICAST, num_for_edict(eAttacker) - 1);
	WriteByte(MSG_MULTICAST, eAttacker.team);
	WriteByte(MSG_MULTICAST, num_for_edict(eTarget) - 1);
	WriteByte(MSG_MULTICAST, eTarget.team);
	WriteByte(MSG_MULTICAST, fWeapon);
	WriteByte(MSG_MULTICAST, fHeadShot);
	msg_entity = self;
	multicast([0,0,0], MULTICAST_ALL);
}

/*
=================
Damage_GetHitLocation

Debug function
=================
*/
string Damage_GetHitLocation(int iSurface)
{
#ifdef CSTRIKE
	switch (iSurface) {
		case BODY_HEAD:
			return "Head";
			break;
		case BODY_CHEST:
			return "Chest";
			break;
		case BODY_STOMACH:
			return "Stomach";
			break;
		case BODY_ARMLEFT:
			return "Left Arm";
			break;
		case BODY_ARMRIGHT:
			return "Right Arm";
			break;
		case BODY_LEGLEFT:
			return "Left leg";
			break;
		case BODY_LEGRIGHT:
			return "Right Leg";
			break;
		default:
			return "Generic";
	}
#endif
}

int Damage_ShouldDamage(float fTargetTeam, float fAttackerTeam)
{
#ifdef CSTRIKE
	if (fTargetTeam == TEAM_VIP) {
		fTargetTeam = TEAM_CT;
	} else if (fAttackerTeam == TEAM_VIP) {
		fAttackerTeam = TEAM_CT;
	}

	if (fTargetTeam == fAttackerTeam) {
		return FALSE;
	}

	return TRUE;
#endif
}

/*
=================
Damage_Apply

Generic function that applies damage, pain and suffering
=================
*/
void Damage_Apply(entity eTarget, entity eAttacker, float iDamage, vector vHitPos, int iSkipArmor)
{
	if (eTarget.flags & FL_GODMODE) {
		return;
	}

	/* Modify the damage based on the location */
	switch (trace_surface_id) {
	case BODY_HEAD:
		if (eTarget.iEquipment & EQUIPMENT_HELMET) {
			sound(self, CHAN_ITEM, "weapons/ric_metal-2.wav", 1, ATTN_IDLE);
			iDamage = 0;
			eTarget.iEquipment -= EQUIPMENT_HELMET;
		} else {
			iDamage *= 4;
		}
		break;
	case BODY_STOMACH:
		iDamage *= 0.9;
		break;
	case BODY_LEGLEFT:
	case BODY_LEGRIGHT:
		iDamage *= 0.4;
		break;
	}

	dprint(sprintf("[DEBUG] Hit Bodypart: %s\n", Damage_GetHitLocation(trace_surface_id)));

	if (eTarget != eAttacker) {
		if (!Damage_ShouldDamage(eTarget.team, eAttacker.team)) {
			if (!autocvar_mp_friendlyfire) {
				return;
			}
		}
	}

	eTarget.velocity = [0,0,0];

	/* Apply the damage finally */
	if (eTarget.armor) {
		float fRatio = 0.5;
		
		if (eAttacker.weapon) { 
			fRatio *= wptTable[eAttacker.weapon].fWeaponArmorRatio;
		}

		/* Simple implementation of how kevlar damage is calculated */
		float fNewDmg = iDamage * fRatio;
		float fNewArmor = (iDamage - fNewDmg) / 2;
		
		if (fNewArmor > eTarget.armor) {
			fNewArmor = eTarget.armor;
			fNewArmor *= (1/0.5);
			fNewDmg = rint(iDamage - fNewArmor);
			eTarget.armor = 0;
			eTarget.iEquipment -= EQUIPMENT_KEVLAR;
		} else {
			if (fNewArmor < 0) {
				fNewArmor = 1;
			}
			eTarget.armor = rint(eTarget.armor - fNewArmor);
		}
		
		if (iSkipArmor == TRUE) {
			eTarget.health = rint(eTarget.health -= iDamage);
			eTarget.dmg_take = (float)iDamage;
		} else {
			eTarget.health = rint(eTarget.health -= fNewDmg);
			eTarget.dmg_take = (float)fNewDmg;
		}
	} else {
		// No armor
		eTarget.health -= iDamage;
		eTarget.dmg_take = (float)iDamage;
	}
	eTarget.dmg_inflictor = eAttacker;

	/* Special monetary punishment for hostage murderers */
	if (eTarget.classname == "hostage_entity") {
		if (eTarget.health > 0) {
			Money_AddMoney(eAttacker, autocvar_fcs_penalty_pain); // Pain
		} else {
			Money_AddMoney(eAttacker, autocvar_fcs_penalty_kill); // Death
		}
	}

	/* Target is dead and a client.... */
	if (eTarget.health <= 0) {
		if (eTarget.flags & FL_CLIENT) {
			eTarget.fDeaths++;
			forceinfokey(eTarget, "*deaths", ftos(eTarget.fDeaths));
		}

		if ((eTarget.flags & FL_CLIENT)  && (eAttacker.flags & FL_CLIENT)) {
			/* Don't encourage them to kill their own team members for $$$ */
			if (Damage_ShouldDamage(eTarget.team, eAttacker.team) == TRUE) {
				eAttacker.frags++;
				Money_AddMoney(eAttacker, autocvar_fcs_reward_kill);
			} else {
				eAttacker.frags--;
				/* Team killer */
				if (eTarget != eAttacker) {
					Money_AddMoney(eAttacker, -3300);
				}
			}
			Damage_CastOrbituary(eAttacker, eTarget, eAttacker.weapon, trace_surface_id == BODY_HEAD ? TRUE:FALSE);
		}
	}

	entity eOld = self;
	self = eTarget;

	if (self.health <= 0) {
		self.health = 0;
		self.vDeath(trace_surface_id);
	} else {
		self.vPain(trace_surface_id);
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
	if (eTarget.solid == SOLID_BSP) {
		return TRUE;
	}
	
	traceline(vAttackPos, eTarget.origin, TRUE, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vAttackPos, eTarget.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vAttackPos, eTarget.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vAttackPos, eTarget.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1) {
		return TRUE;
	}
	traceline(vAttackPos, eTarget.origin + '15 -15 0', TRUE, self);
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
